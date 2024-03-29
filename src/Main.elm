module Main exposing (Model, Msg(..), init, main, subscriptions, update, view, viewLink)

import Bootstrap.Grid as Grid
import Bootstrap.Tab as Tab
import Browser
import Browser.Navigation as Nav
import Dialog
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode exposing (Decoder, at)
import Json.Decode.Pipeline as Pipeline exposing (optional, required)
import Json.Encode as JE
import List.Extra exposing (getAt, removeAt)
import Reorderable as R
import Url



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , app : App
    , error : Maybe String
    , tabState : Tab.State
    , editingAppInputId : String
    , editingAppParamId : String
    , inputToModify : Maybe AppInput
    , paramToModify : Maybe AppParam
    , incomingJson : Maybe String
    , appInputError : Maybe String
    , appParamError : Maybe String
    , jsonError : Maybe String
    }


type alias App =
    { name : String
    , version : String
    , available : Bool
    , checkpointable : Bool
    , defaultMemoryPerNode : Int
    , defaultProcessorsPerNode : Int
    , defaultMaxRunTime : String
    , defaultNodeCount : Int
    , defaultQueue : String
    , deploymentPath : String
    , deploymentSystem : String
    , executionSystem : String
    , executionType : String
    , helpUri : String
    , label : String
    , longDescription : String
    , shortDescription : String
    , templatePath : String
    , testPath : String
    , parallelism : String
    , modules : List String
    , ontology : List String
    , tags : List String
    , inputs : List AppInput
    , parameters : List AppParam
    , outputs : List String
    }


type alias AppInput =
    { id : String
    , defaultValue : String
    , displayOrder : Int
    , validator : String
    , required : Bool
    , visible : Bool
    , minCardinality : Int
    , maxCardinality : Int
    , ontology : List String
    , fileTypes : List String
    , description : String
    , label : String
    , argument : String
    , showArgument : Bool
    , repeatArgument : Bool
    , enquoteValue : Bool
    }


type alias EnumValue =
    ( String, String )


type alias AppParam =
    { id : String
    , defaultValue : AppParamDefaultValue
    , paramType : AppParamType
    , displayOrder : Int
    , required : Bool
    , validator : String
    , visible : Bool
    , description : String
    , label : String
    , argument : String
    , showArgument : Bool
    , repeatArgument : Bool
    , enquoteValue : Bool
    , enumValues : List ( String, String )
    , inputEnumKey : String
    , inputEnumValue : String
    }


type Direction
    = Up
    | Down


type AppParamDefaultValue
    = AppParamDefaultValString String
    | AppParamDefaultValNumber Float
    | AppParamDefaultValBool Bool


type AppParamType
    = StringParam
    | NumberParam
    | EnumerationParam
    | BoolParam
    | FlagParam


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { key = key
      , url = url
      , app = initialApp
      , error = Nothing
      , tabState = Tab.initialState
      , editingAppInputId = ""
      , editingAppParamId = ""
      , inputToModify = Nothing
      , paramToModify = Nothing
      , incomingJson = Nothing
      , appInputError = Nothing
      , appParamError = Nothing
      , jsonError = Nothing
      }
    , Cmd.none
    )


initialApp =
    { name = "my_new_app"
    , label = "My New App"
    , version = "0.0.1"
    , shortDescription = ""
    , longDescription = ""
    , available = True
    , checkpointable = False
    , defaultMemoryPerNode = 192
    , defaultProcessorsPerNode = 48
    , defaultMaxRunTime = "12:00:00"
    , defaultNodeCount = 1
    , defaultQueue = "normal"
    , deploymentPath = "user/applications/app_name-version/stampede"
    , deploymentSystem = "data.iplantcollaborative.org"
    , executionSystem = "tacc-stampede2-user"
    , executionType = "HPC"
    , helpUri = "http://google.com"
    , parallelism = "serial"
    , modules = [ "tacc-singularity", "launcher" ]
    , ontology = [ "http://sswapmeet.sswap.info/agave/apps/Application" ]
    , tags = [ "imicrobe" ]
    , testPath = "test.sh"
    , templatePath = "template.sh"
    , inputs = []
    , parameters = []
    , outputs = []
    }


initialAppInput =
    { id = "INPUT"
    , defaultValue = ""
    , displayOrder = 0
    , validator = ""
    , required = True
    , visible = True
    , ontology = [ "http://sswapmeet.sswap.info/mime/application/X-bam" ]
    , minCardinality = 1
    , maxCardinality = -1
    , fileTypes = [ "raw-0" ]
    , description = ""
    , label = "LABEL"
    , argument = ""
    , showArgument = True
    , repeatArgument = False
    , enquoteValue = False
    }


initialAppParam =
    { id = ""
    , defaultValue = AppParamDefaultValString ""
    , paramType = StringParam
    , displayOrder = 0
    , required = True
    , validator = ""
    , visible = True
    , description = ""
    , label = ""
    , argument = ""
    , showArgument = True
    , repeatArgument = False
    , enquoteValue = False
    , enumValues = []
    , inputEnumKey = ""
    , inputEnumValue = ""
    }



-- UPDATE


type Msg
    = CloseAppInputDialog
    | CloseAppParamDialog
    | CloseJsonDialog
    | CloseModifyAppInputDialog
    | DecodeIncomingJson
    | DeleteAppInput Int
    | DeleteAppParam Int
    | LinkClicked Browser.UrlRequest
    | MoveAppInput Direction Int
    | MoveAppParam Direction Int
    | OpenModifyAppInputDialog AppInput
    | OpenModifyAppParamDialog AppParam
    | SaveAppInput
    | SaveAppParam
    | SetAppInputToModify Int
    | SetAppParamToModify Int
    | ShowJsonDialog
    | TabMsg Tab.State
    | ToggleAppAvailable
    | ToggleAppCheckpointable
    | UpdateAppDefaultMaxRunTime String
    | UpdateAppDefaultMemoryPerNode String
    | UpdateAppDefaultNodeCount String
    | UpdateAppDefaultProcessorsPerNode String
    | UpdateAppDefaultQueue String
    | UpdateAppDeploymentPath String
    | UpdateAppDeploymentSystem String
    | UpdateAppExecutionSystem String
    | UpdateAppExecutionType String
    | UpdateAppHelpUri String
    | UpdateAppInputArgument String
    | UpdateAppInputDefaultValue String
    | UpdateAppInputDescription String
    | UpdateAppInputDisplayOrder String
    | UpdateAppInputFileTypes String
    | UpdateAppInputId String
    | UpdateAppInputLabel String
    | UpdateAppInputMaxCardinality String
    | UpdateAppInputMinCardinality String
    | UpdateAppInputOntology String
    | UpdateAppInputToggleEnquoteValue
    | UpdateAppInputToggleRepeatArgument
    | UpdateAppInputToggleRequired
    | UpdateAppInputToggleShowArgument
    | UpdateAppInputToggleVisible
    | UpdateAppInputValidator String
    | UpdateAppLabel String
    | UpdateAppLongDescription String
    | UpdateAppModules String
    | UpdateAppName String
    | UpdateAppOntology String
    | UpdateAppParallelism String
    | UpdateAppParamAddEnum
    | UpdateAppParamArgument String
    | UpdateAppParamDefaultValue String
    | UpdateAppParamDeleteEnumValue Int
    | UpdateAppParamDescription String
    | UpdateAppParamDisplayOrder String
    | UpdateAppParamEnumKey String
    | UpdateAppParamEnumValue String
    | UpdateAppParamId String
    | UpdateAppParamLabel String
    | UpdateAppParamMoveEnumValue Direction Int
    | UpdateAppParamToggleEnquoteValue
    | UpdateAppParamToggleRepeatArgument
    | UpdateAppParamToggleRequired
    | UpdateAppParamToggleShowArgument
    | UpdateAppParamToggleVisible
    | UpdateAppParamType String
    | UpdateAppParamValidator String
    | UpdateAppShortDescription String
    | UpdateAppTags String
    | UpdateAppTemplatePath String
    | UpdateAppTestPath String
    | UpdateAppVersion String
    | UpdateIncomingJson String
    | UrlChanged Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CloseAppInputDialog ->
            ( { model | inputToModify = Nothing }, Cmd.none )

        CloseAppParamDialog ->
            ( { model | paramToModify = Nothing }, Cmd.none )

        CloseJsonDialog ->
            ( { model | incomingJson = Nothing }, Cmd.none )

        CloseModifyAppInputDialog ->
            ( { model | inputToModify = Nothing }, Cmd.none )

        DeleteAppInput index ->
            let
                app =
                    model.app

                newApp =
                    { app | inputs = removeAt index app.inputs }
            in
            ( { model | app = newApp }, Cmd.none )

        DeleteAppParam index ->
            let
                app =
                    model.app

                newApp =
                    { app | parameters = removeAt index app.parameters }
            in
            ( { model | app = newApp }, Cmd.none )

        DecodeIncomingJson ->
            let
                newModel =
                    decodeIncomingJson model

                newJson =
                    case newModel.jsonError of
                        Nothing ->
                            Nothing

                        _ ->
                            model.incomingJson
            in
            ( { newModel | incomingJson = newJson }, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        MoveAppInput direction index ->
            let
                app =
                    model.app

                newInputs =
                    alterDisplayOrder direction index app.inputs

                newApp =
                    { app | inputs = newInputs }
            in
            ( { model | app = newApp }, Cmd.none )

        MoveAppParam direction index ->
            let
                app =
                    model.app

                newParams =
                    alterDisplayOrder direction index app.parameters

                newApp =
                    { app | parameters = newParams }
            in
            ( { model | app = newApp }, Cmd.none )

        OpenModifyAppInputDialog newInput ->
            ( { model
                | inputToModify = Just newInput
                , editingAppInputId = newInput.id
              }
            , Cmd.none
            )

        OpenModifyAppParamDialog newParam ->
            ( { model
                | paramToModify = Just newParam
                , editingAppParamId = newParam.id
              }
            , Cmd.none
            )

        SaveAppInput ->
            let
                newInputs =
                    case model.inputToModify of
                        Just input ->
                            let
                                ( this, notThis ) =
                                    List.partition
                                        (\x -> x.id == model.editingAppInputId)
                                        model.app.inputs
                            in
                            List.sortBy (\x -> x.displayOrder)
                                (input :: notThis)

                        _ ->
                            model.app.inputs

                curApp =
                    model.app

                newApp =
                    { curApp | inputs = newInputs }
            in
            ( { model
                | app = newApp
                , inputToModify = Nothing
                , editingAppInputId = ""
              }
            , Cmd.none
            )

        SaveAppParam ->
            let
                newParams =
                    case model.paramToModify of
                        Just param ->
                            let
                                ( this, notThis ) =
                                    List.partition
                                        (\x -> x.id == model.editingAppParamId)
                                        model.app.parameters
                            in
                            List.sortBy (\x -> x.displayOrder)
                                (param :: notThis)

                        _ ->
                            model.app.parameters

                curApp =
                    model.app

                newApp =
                    { curApp | parameters = newParams }
            in
            ( { model
                | app = newApp
                , paramToModify = Nothing
                , editingAppParamId = ""
              }
            , Cmd.none
            )

        SetAppInputToModify index ->
            let
                newInput =
                    getAt index model.app.inputs

                inputId =
                    case newInput of
                        Just input ->
                            input.id

                        _ ->
                            ""
            in
            ( { model
                | inputToModify = newInput
                , editingAppInputId = inputId
              }
            , Cmd.none
            )

        SetAppParamToModify index ->
            let
                newParam =
                    getAt index model.app.parameters

                paramId =
                    case newParam of
                        Just param ->
                            param.id

                        _ ->
                            ""
            in
            ( { model
                | paramToModify = newParam
                , editingAppParamId = paramId
              }
            , Cmd.none
            )

        ShowJsonDialog ->
            ( { model | incomingJson = Just (encodeApp model.app) }
            , Cmd.none
            )

        TabMsg state ->
            ( { model | tabState = state }
            , Cmd.none
            )

        ToggleAppAvailable ->
            let
                app =
                    model.app

                newApp =
                    { app | available = not app.available }
            in
            ( { model | app = newApp }, Cmd.none )

        ToggleAppCheckpointable ->
            let
                app =
                    model.app

                newApp =
                    { app | checkpointable = not app.checkpointable }
            in
            ( { model | app = newApp }, Cmd.none )

        UpdateAppInputArgument val ->
            let
                newInput =
                    Maybe.map (\input -> { input | argument = val })
                        model.inputToModify
            in
            ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppInputDefaultValue val ->
            let
                newInput =
                    Maybe.map (\input -> { input | defaultValue = val })
                        model.inputToModify
            in
            ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppInputDescription val ->
            let
                newInput =
                    Maybe.map (\input -> { input | description = val })
                        model.inputToModify
            in
            ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppInputDisplayOrder val ->
            let
                ( newInput, newError ) =
                    case model.inputToModify of
                        Just input ->
                            let
                                ( newDisplayOrder, err ) =
                                    case String.toInt val of
                                        Just n ->
                                            ( n, Nothing )

                                        Nothing ->
                                            ( input.displayOrder
                                            , Just "Invalid value"
                                            )
                            in
                            ( Just
                                { input
                                    | displayOrder = newDisplayOrder
                                }
                            , err
                            )

                        _ ->
                            ( Nothing, Nothing )
            in
            ( { model | inputToModify = newInput, appInputError = newError }
            , Cmd.none
            )

        UpdateAppInputFileTypes val ->
            let
                newFileTypes =
                    List.map String.trim (String.split "," val)

                newInput =
                    Maybe.map (\input -> { input | fileTypes = newFileTypes })
                        model.inputToModify
            in
            ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppInputId val ->
            let
                newInput =
                    Maybe.map (\input -> { input | id = val })
                        model.inputToModify
            in
            ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppInputLabel val ->
            let
                newInput =
                    Maybe.map (\input -> { input | label = val })
                        model.inputToModify
            in
            ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppInputMaxCardinality val ->
            let
                ( newInput, newError ) =
                    case model.inputToModify of
                        Just input ->
                            let
                                ( newVal, err ) =
                                    case String.toInt val of
                                        Just n ->
                                            ( n, Nothing )

                                        Nothing ->
                                            ( input.maxCardinality, Just "Invalid value" )
                            in
                            ( Just
                                { input | maxCardinality = newVal }
                            , err
                            )

                        _ ->
                            ( Nothing, Nothing )
            in
            ( { model | inputToModify = newInput, appInputError = newError }
            , Cmd.none
            )

        UpdateAppInputMinCardinality val ->
            let
                ( newInput, newError ) =
                    case model.inputToModify of
                        Just input ->
                            let
                                ( newVal, err ) =
                                    case String.toInt val of
                                        Just n ->
                                            ( n, Nothing )

                                        Nothing ->
                                            ( input.minCardinality, Just "Invalid value" )
                            in
                            ( Just
                                { input
                                    | minCardinality = newVal
                                }
                            , err
                            )

                        _ ->
                            ( Nothing, Nothing )
            in
            ( { model
                | inputToModify = newInput
                , appInputError = newError
              }
            , Cmd.none
            )

        UpdateAppInputToggleEnquoteValue ->
            let
                newInput =
                    Maybe.map
                        (\input ->
                            { input
                                | enquoteValue = not input.enquoteValue
                            }
                        )
                        model.inputToModify
            in
            ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppInputToggleRepeatArgument ->
            let
                newInput =
                    Maybe.map
                        (\input ->
                            { input
                                | repeatArgument = not input.repeatArgument
                            }
                        )
                        model.inputToModify
            in
            ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppInputToggleRequired ->
            let
                newInput =
                    Maybe.map
                        (\input ->
                            { input | required = not input.required }
                        )
                        model.inputToModify
            in
            ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppInputToggleShowArgument ->
            let
                newInput =
                    Maybe.map
                        (\input ->
                            { input
                                | showArgument = not input.showArgument
                            }
                        )
                        model.inputToModify
            in
            ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppInputToggleVisible ->
            let
                newInput =
                    Maybe.map
                        (\input -> { input | visible = not input.visible })
                        model.inputToModify
            in
            ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppInputValidator val ->
            let
                newInput =
                    Maybe.map (\input -> { input | validator = val })
                        model.inputToModify
            in
            ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppInputOntology val ->
            let
                newOntology =
                    List.map String.trim (String.split "," val)

                newInput =
                    Maybe.map (\input -> { input | ontology = newOntology })
                        model.inputToModify
            in
            ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppParamAddEnum ->
            let
                newParam =
                    Maybe.map (\p -> addEnum p) model.paramToModify

                addEnum param =
                    let
                        keyOk =
                            String.length param.inputEnumKey > 0

                        valOk =
                            String.length param.inputEnumValue > 0

                        ( newEnum, newEnumKey, newEnumValue ) =
                            if keyOk && valOk then
                                ( Just
                                    ( param.inputEnumKey, param.inputEnumValue )
                                , ""
                                , ""
                                )

                            else
                                ( Nothing
                                , param.inputEnumKey
                                , param.inputEnumValue
                                )

                        newEnums =
                            case newEnum of
                                Just e ->
                                    param.enumValues ++ [ e ]

                                _ ->
                                    param.enumValues
                    in
                    { param
                        | enumValues = newEnums
                        , inputEnumKey = newEnumKey
                        , inputEnumValue = newEnumValue
                    }
            in
            ( { model | paramToModify = newParam }, Cmd.none )

        UpdateAppParamArgument val ->
            let
                newParam =
                    Maybe.map (\x -> { x | argument = val })
                        model.paramToModify
            in
            ( { model | paramToModify = newParam }, Cmd.none )

        UpdateAppParamDeleteEnumValue index ->
            let
                newParam =
                    Maybe.map (\p -> deleteEnum index p) model.paramToModify

                deleteEnum idx param =
                    { param | enumValues = removeAt idx param.enumValues }
            in
            ( { model | paramToModify = newParam }, Cmd.none )

        UpdateAppParamDisplayOrder val ->
            let
                ( newParam, newError ) =
                    case model.paramToModify of
                        Just param ->
                            let
                                ( newDisplayOrder, err ) =
                                    case String.toInt val of
                                        Just n ->
                                            ( n, Nothing )

                                        Nothing ->
                                            ( param.displayOrder, Just "Invalid value" )
                            in
                            ( Just
                                { param
                                    | displayOrder = newDisplayOrder
                                }
                            , err
                            )

                        _ ->
                            ( Nothing, Nothing )
            in
            ( { model | paramToModify = newParam, appParamError = newError }
            , Cmd.none
            )

        UpdateAppParamDefaultValue val ->
            let
                toBool s =
                    String.toUpper s == "TRUE"

                ( newParam, err ) =
                    case model.paramToModify of
                        Just p ->
                            let
                                ( newVal, newErr ) =
                                    case p.paramType of
                                        BoolParam ->
                                            ( AppParamDefaultValBool
                                                (toBool val)
                                            , Nothing
                                            )

                                        FlagParam ->
                                            ( AppParamDefaultValBool
                                                (toBool val)
                                            , Nothing
                                            )

                                        NumberParam ->
                                            case String.toFloat val of
                                                Just n ->
                                                    ( AppParamDefaultValNumber n, Nothing )

                                                Nothing ->
                                                    ( p.defaultValue, Just "Invalid value" )

                                        _ ->
                                            ( AppParamDefaultValString val, Nothing )
                            in
                            ( Just { p | defaultValue = newVal }, newErr )

                        _ ->
                            ( Nothing, Nothing )
            in
            ( { model | paramToModify = newParam, appParamError = err }
            , Cmd.none
            )

        UpdateAppParamDescription val ->
            let
                newParam =
                    Maybe.map (\x -> { x | description = val })
                        model.paramToModify
            in
            ( { model | paramToModify = newParam }, Cmd.none )

        UpdateAppParamEnumKey val ->
            let
                newParam =
                    Maybe.map (\param -> { param | inputEnumKey = val })
                        model.paramToModify
            in
            ( { model | paramToModify = newParam }, Cmd.none )

        UpdateAppParamEnumValue val ->
            let
                newParam =
                    Maybe.map (\param -> { param | inputEnumValue = val })
                        model.paramToModify
            in
            ( { model | paramToModify = newParam }, Cmd.none )

        UpdateAppParamId val ->
            let
                newParam =
                    Maybe.map (\param -> { param | id = val })
                        model.paramToModify
            in
            ( { model | paramToModify = newParam }, Cmd.none )

        UpdateAppParamLabel val ->
            let
                newParam =
                    Maybe.map (\x -> { x | label = val })
                        model.paramToModify
            in
            ( { model | paramToModify = newParam }, Cmd.none )

        UpdateAppParamMoveEnumValue direction index ->
            let
                newParam =
                    Maybe.map (\p -> moveEnum p)
                        model.paramToModify

                moveEnum param =
                    let
                        mover =
                            if direction == Up then
                                R.moveUp

                            else
                                R.moveDown
                    in
                    { param
                        | enumValues =
                            R.toList <|
                                mover 1 (R.fromList param.enumValues)
                    }
            in
            ( { model | paramToModify = newParam }, Cmd.none )

        UpdateAppParamToggleEnquoteValue ->
            let
                newParam =
                    Maybe.map
                        (\param ->
                            { param
                                | enquoteValue = not param.enquoteValue
                            }
                        )
                        model.paramToModify
            in
            ( { model | paramToModify = newParam }, Cmd.none )

        UpdateAppParamToggleRequired ->
            let
                newParam =
                    Maybe.map
                        (\param ->
                            { param
                                | required = not param.required
                            }
                        )
                        model.paramToModify
            in
            ( { model | paramToModify = newParam }, Cmd.none )

        UpdateAppParamToggleRepeatArgument ->
            let
                newParam =
                    Maybe.map
                        (\param ->
                            { param
                                | repeatArgument = not param.repeatArgument
                            }
                        )
                        model.paramToModify
            in
            ( { model | paramToModify = newParam }, Cmd.none )

        UpdateAppParamToggleShowArgument ->
            let
                newParam =
                    Maybe.map
                        (\param ->
                            { param
                                | showArgument = not param.showArgument
                            }
                        )
                        model.paramToModify
            in
            ( { model | paramToModify = newParam }, Cmd.none )

        UpdateAppParamToggleVisible ->
            let
                newParam =
                    Maybe.map
                        (\param ->
                            { param
                                | visible = not param.visible
                            }
                        )
                        model.paramToModify
            in
            ( { model | paramToModify = newParam }, Cmd.none )

        UpdateAppParamType val ->
            let
                newType =
                    case val of
                        "Number" ->
                            NumberParam

                        "Enumeration" ->
                            EnumerationParam

                        "Boolean" ->
                            BoolParam

                        "Flag" ->
                            FlagParam

                        _ ->
                            StringParam

                newDefaultValue =
                    case newType of
                        BoolParam ->
                            AppParamDefaultValBool True

                        FlagParam ->
                            AppParamDefaultValBool True

                        NumberParam ->
                            AppParamDefaultValNumber 0

                        _ ->
                            AppParamDefaultValString ""

                newParam =
                    Maybe.map
                        (\param ->
                            { param
                                | paramType = newType
                                , defaultValue = newDefaultValue
                            }
                        )
                        model.paramToModify
            in
            ( { model | paramToModify = newParam }, Cmd.none )

        UpdateAppParamValidator val ->
            let
                newParam =
                    Maybe.map (\param -> { param | validator = val })
                        model.paramToModify
            in
            ( { model | paramToModify = newParam }, Cmd.none )

        UpdateAppDefaultMaxRunTime val ->
            let
                app =
                    model.app

                newApp =
                    { app | defaultMaxRunTime = val }
            in
            ( { model | app = newApp }, Cmd.none )

        UpdateAppDefaultMemoryPerNode val ->
            let
                app =
                    model.app

                ( num, err ) =
                    case String.toInt val of
                        Just n ->
                            ( n, Nothing )

                        Nothing ->
                            ( app.defaultMemoryPerNode
                            , Just "Invalid value"
                            )

                newApp =
                    { app | defaultMemoryPerNode = num }
            in
            ( { model | app = newApp, error = err }, Cmd.none )

        UpdateAppDefaultNodeCount val ->
            let
                app =
                    model.app

                ( num, err ) =
                    case String.toInt val of
                        Just n ->
                            ( n, Nothing )

                        Nothing ->
                            ( app.defaultNodeCount
                            , Just "Invalid value"
                            )

                newApp =
                    { app | defaultNodeCount = num }
            in
            ( { model | app = newApp, error = err }, Cmd.none )

        UpdateAppDefaultProcessorsPerNode val ->
            let
                app =
                    model.app

                ( num, err ) =
                    case String.toInt val of
                        Just n ->
                            ( n, Nothing )

                        Nothing ->
                            ( app.defaultProcessorsPerNode
                            , Just "Invalid value"
                            )

                newApp =
                    { app | defaultProcessorsPerNode = num }
            in
            ( { model | app = newApp, error = err }, Cmd.none )

        UpdateAppDefaultQueue val ->
            let
                app =
                    model.app

                newApp =
                    { app | defaultQueue = val }
            in
            ( { model | app = newApp }, Cmd.none )

        UpdateAppDeploymentPath val ->
            let
                app =
                    model.app

                newApp =
                    { app | deploymentPath = val }
            in
            ( { model | app = newApp }, Cmd.none )

        UpdateAppDeploymentSystem val ->
            let
                app =
                    model.app

                newApp =
                    { app | deploymentSystem = val }
            in
            ( { model | app = newApp }, Cmd.none )

        UpdateAppExecutionSystem val ->
            let
                app =
                    model.app

                newApp =
                    { app | executionSystem = val }
            in
            ( { model | app = newApp }, Cmd.none )

        UpdateAppExecutionType val ->
            let
                app =
                    model.app

                newApp =
                    { app | executionType = val }
            in
            ( { model | app = newApp }, Cmd.none )

        UpdateAppHelpUri val ->
            let
                app =
                    model.app

                newApp =
                    { app | helpUri = val }
            in
            ( { model | app = newApp }, Cmd.none )

        UpdateAppLabel val ->
            let
                app =
                    model.app

                newApp =
                    { app | label = val }
            in
            ( { model | app = newApp }, Cmd.none )

        UpdateAppLongDescription val ->
            let
                app =
                    model.app

                newApp =
                    { app | longDescription = val }
            in
            ( { model | app = newApp }, Cmd.none )

        UpdateAppModules val ->
            let
                app =
                    model.app

                newModules =
                    List.map String.trim (String.split "," val)

                newApp =
                    { app | modules = newModules }
            in
            ( { model | app = newApp }, Cmd.none )

        UpdateAppName val ->
            let
                app =
                    model.app

                newApp =
                    { app | name = val }
            in
            ( { model | app = newApp }, Cmd.none )

        UpdateAppOntology val ->
            let
                app =
                    model.app

                newOntology =
                    List.map String.trim (String.split "," val)

                newApp =
                    { app | ontology = newOntology }
            in
            ( { model | app = newApp }, Cmd.none )

        UpdateAppParallelism val ->
            let
                app =
                    model.app

                newApp =
                    { app | parallelism = val }
            in
            ( { model | app = newApp }, Cmd.none )

        UpdateAppShortDescription val ->
            let
                app =
                    model.app

                newApp =
                    { app | shortDescription = val }
            in
            ( { model | app = newApp }, Cmd.none )

        UpdateAppTags val ->
            let
                app =
                    model.app

                newTags =
                    List.map String.trim (String.split "," val)

                newApp =
                    { app | tags = newTags }
            in
            ( { model | app = newApp }, Cmd.none )

        UpdateAppTemplatePath val ->
            let
                app =
                    model.app

                newApp =
                    { app | templatePath = val }
            in
            ( { model | app = newApp }, Cmd.none )

        UpdateAppTestPath val ->
            let
                app =
                    model.app

                newApp =
                    { app | testPath = val }
            in
            ( { model | app = newApp }, Cmd.none )

        UpdateAppVersion val ->
            let
                app =
                    model.app

                newApp =
                    { app | version = val }
            in
            ( { model | app = newApp }, Cmd.none )

        UpdateIncomingJson json ->
            ( { model | incomingJson = Just json }, Cmd.none )

        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Tab.subscriptions model.tabState TabMsg



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        title =
            "The Appetizer"

        err =
            case model.error of
                Nothing ->
                    div [] [ text "" ]

                Just e ->
                    div [ class "alert alert-danger" ]
                        [ text ("Error: " ++ e) ]
    in
    { title = title
    , body =
        [ Grid.container []
            [ h1 [] [ text title ]
            , err
            , Tab.config TabMsg
                |> Tab.withAnimation
                |> Tab.right
                |> Tab.items
                    [ Tab.item
                        { id = "tabMain"
                        , link = Tab.link [] [ text "Main" ]
                        , pane =
                            Tab.pane []
                                [ br [] []
                                , paneMain model.app
                                ]
                        }
                    , Tab.item
                        { id = "tabInputs"
                        , link =
                            Tab.link []
                                [ text
                                    ("Inputs ("
                                        ++ String.fromInt
                                            (List.length model.app.inputs)
                                        ++ ")"
                                    )
                                ]
                        , pane =
                            Tab.pane []
                                [ br [] []
                                , paneInputs model
                                ]
                        }
                    , Tab.item
                        { id = "tabParams"
                        , link =
                            Tab.link []
                                [ text
                                    ("Parameters ("
                                        ++ String.fromInt
                                            (List.length model.app.parameters)
                                        ++ ")"
                                    )
                                ]
                        , pane =
                            Tab.pane []
                                [ br [] []
                                , paneParameters model
                                ]
                        }
                    , Tab.item
                        { id = "tabAdvanced"
                        , link = Tab.link [] [ text "Advanced" ]
                        , pane =
                            Tab.pane []
                                [ br [] []
                                , paneAdvanced model.app
                                ]
                        }
                    , Tab.item
                        { id = "tabJson"
                        , link = Tab.link [] [ text "JSON" ]
                        , pane =
                            Tab.pane []
                                [ br [] []
                                , paneJson model
                                ]
                        }
                    , Tab.item
                        { id = "tabHelp"
                        , link = Tab.link [] [ text "Help" ]
                        , pane =
                            Tab.pane []
                                [ br [] []
                                , paneHelp
                                ]
                        }
                    ]
                |> Tab.view model.tabState
            ]
        ]
    }


viewLink : String -> Html msg
viewLink path =
    li [] [ a [ href path ] [ text path ] ]


paneInputs : Model -> Html Msg
paneInputs model =
    let
        nextDisplayOrder =
            1
                + Maybe.withDefault 0
                    (List.maximum
                        (List.map
                            (\d -> d.displayOrder)
                            model.app.inputs
                        )
                    )
    in
    div [ class "form-group", style "text-align" "center" ]
        [ button
            [ type_ "button"
            , class "btn btn-default"
            , onClick
                (OpenModifyAppInputDialog
                    { initialAppInput
                        | id = "INPUT" ++ String.fromInt nextDisplayOrder
                        , label = "LABEL" ++ String.fromInt nextDisplayOrder
                        , displayOrder = nextDisplayOrder
                    }
                )
            ]
            [ text "Add Input" ]
        , modifyAppInputDialog model
        , appInputsTable model.app.inputs
        ]


paneParameters : Model -> Html Msg
paneParameters model =
    let
        nextDisplayOrder =
            1
                + Maybe.withDefault 0
                    (List.maximum
                        (List.map
                            (\d -> d.displayOrder)
                            model.app.parameters
                        )
                    )
    in
    div [ class "form-group", style "text-align" "center" ]
        [ button
            [ type_ "button"
            , class "btn btn-default"
            , onClick
                (OpenModifyAppParamDialog
                    { initialAppParam
                        | id = "PARAM" ++ String.fromInt nextDisplayOrder
                        , label = "PARAM" ++ String.fromInt nextDisplayOrder
                        , displayOrder = nextDisplayOrder
                    }
                )
            ]
            [ text "Add Param" ]
        , modifyAppParamDialog model
        , appParamsTable model.app.parameters
        ]


paneMain : App -> Html Msg
paneMain app =
    div []
        [ Html.form []
            [ table []
                [ mkRowTextEntry "Name" app.name UpdateAppName
                , mkRowTextEntry "Label" app.label UpdateAppLabel
                , mkRowTextEntry "Version" app.version UpdateAppVersion
                , mkRowTextEntry "Help URI" app.helpUri UpdateAppHelpUri
                , mkRowTextArea "Short Description"
                    app.shortDescription
                    UpdateAppShortDescription
                , mkRowTextArea "Long Description"
                    app.longDescription
                    UpdateAppLongDescription
                ]
            ]
        ]


paneAdvanced : App -> Html Msg
paneAdvanced app =
    div []
        [ Html.form []
            [ table []
                [ mkRowCheckbox "Available"
                    app.available
                    ToggleAppAvailable
                , mkRowCheckbox "Checkpointable"
                    app.checkpointable
                    ToggleAppCheckpointable
                , mkRowTextEntry "Default Memory Per Node"
                    (String.fromInt app.defaultMemoryPerNode)
                    UpdateAppDefaultMemoryPerNode
                , mkRowTextEntry "Default Processors Per Node"
                    (String.fromInt app.defaultProcessorsPerNode)
                    UpdateAppDefaultProcessorsPerNode
                , mkRowTextEntry "Default Max Run Time"
                    app.defaultMaxRunTime
                    UpdateAppDefaultMaxRunTime
                , mkRowTextEntry "Default Node Count"
                    (String.fromInt app.defaultNodeCount)
                    UpdateAppDefaultNodeCount
                , mkRowSelect "Default Queue"
                    [ "normal", "skx" ]
                    app.defaultQueue
                    UpdateAppDefaultQueue
                , mkRowTextEntry "Deployment Path"
                    app.deploymentPath
                    UpdateAppDeploymentPath
                , mkRowTextEntry "Deployment System"
                    app.deploymentSystem
                    UpdateAppDeploymentSystem
                , mkRowTextEntry "Execution System"
                    app.executionSystem
                    UpdateAppExecutionSystem
                , mkRowSelect "Execution Type"
                    [ "HPC", "Condor", "CLI" ]
                    app.executionType
                    UpdateAppExecutionType
                , mkRowSelect "Parallelism"
                    [ "Parallel", "Serial" ]
                    app.parallelism
                    UpdateAppParallelism
                , mkRowTextEntry "Template Path"
                    app.templatePath
                    UpdateAppTemplatePath
                , mkRowTextEntry "Test Path"
                    app.testPath
                    UpdateAppTestPath
                , mkRowTextEntry "Modules"
                    (String.join ", " app.modules)
                    UpdateAppModules
                , mkRowTextEntry "Tags"
                    (String.join ", " app.tags)
                    UpdateAppTags
                , mkRowTextEntry "Ontology"
                    (String.join ", " app.ontology)
                    UpdateAppOntology
                ]
            ]
        ]


paneJson : Model -> Html Msg
paneJson model =
    div []
        [ div [ style "text-align" "center" ]
            [ button [ class "btn btn-primary", onClick ShowJsonDialog ]
                [ text "Manual Edit" ]
            ]
        , br [] []
        , pre [] [ text (encodeApp model.app) ]
        , modifyJsonDialog model
        ]


paneHelp : Html Msg
paneHelp =
    let
        helpUrl =
            "http://developer.agaveapi.co/#inputs-and-parameters"
    in
    div []
        [ h2 [] [ text "Docs" ]
        , text
            ("This interface is intended to help you to describe all the "
                ++ "command-line arguments for a tool you wish to encode "
                ++ "as an app. It will generate the JSON needed to "
                ++ "describe the app to the Agave API. The official "
                ++ "documentation is available at "
            )
        , a [ href helpUrl ] [ text helpUrl ]
        , text "."
        , h2 [] [ text "Main" ]
        , text "Basic information we need about your tool."
        , h2 [] [ text "Inputs" ]
        , text
            ("Input are assets from the user that must be transferred "
                ++ "to the compute nodes for your app to run."
            )
        , h2 [] [ text "Parameters" ]
        , text "Parameters describe how the app will behave."
        , h2 [] [ text "Advanced" ]
        , text
            ("These are options to be configured by our developers, "
                ++ "so you can safely ignore anything that doesn't make "
                ++ "sense to you."
            )
        , h2 [] [ text "JSON" ]
        , text
            ("Once you have used the form to describe your app, "
                ++ "you can view/copy the JSON from this tab into a text "
                ++ "file that you can provide as an argument to "
                ++ "apps-add-update."
            )
        , br [] []
        , text
            ("You can also click the Manual Edit button to tweak the "
                ++ "JSON by hand or paste in an existing app's JSON "
                ++ "definition in order to edit it."
            )
        ]


mkTh : String -> Html msg
mkTh label =
    th [ style "align" "right" ] [ text label ]


mkRowSelect : String -> List String -> String -> (String -> Msg) -> Html Msg
mkRowSelect label optList curOpt msg =
    let
        mkOption val =
            option [ value val, selected (val == curOpt) ] [ text val ]
    in
    tr []
        [ mkTh label
        , td []
            [ select [ onInput msg ] (List.map mkOption optList) ]
        ]


mkRowTextEntry : String -> String -> (String -> Msg) -> Html Msg
mkRowTextEntry label defValue msg =
    tr []
        [ mkTh label
        , td []
            [ input
                [ type_ "text"
                , value defValue
                , class "form-control"
                , onInput msg
                , size 60
                ]
                []
            ]
        ]


mkRowTextArea : String -> String -> (String -> Msg) -> Html Msg
mkRowTextArea label defValue msg =
    tr []
        [ mkTh label
        , td []
            [ textarea
                [ value defValue
                , class "form-control"
                , onInput msg
                , rows 10
                , cols 40
                ]
                []
            ]
        ]


mkRowCheckbox : String -> Bool -> Msg -> Html Msg
mkRowCheckbox label state msg =
    tr []
        [ mkTh label
        , td []
            [ input
                [ type_ "checkbox"
                , onClick msg
                , checked state
                , class "form-control"
                ]
                []
            ]
        ]


mkRowRadioButtonGroup : String -> List ( String, Bool, Msg ) -> Html Msg
mkRowRadioButtonGroup label options =
    tr []
        [ mkTh label
        , td []
            [ fieldset [] (List.map mkRadio options) ]
        ]


mkRadio : ( String, Bool, Msg ) -> Html Msg
mkRadio ( value, state, msg ) =
    label []
        [ input
            [ type_ "radio"
            , onClick msg
            , checked state
            , class "form-control"
            ]
            []
        , text value
        ]


decoderApp : Decoder App
decoderApp =
    Decode.succeed App
        |> Pipeline.required "name" Decode.string
        |> Pipeline.required "version" Decode.string
        |> Pipeline.required "available" Decode.bool
        |> Pipeline.required "checkpointable" Decode.bool
        |> Pipeline.required "defaultMemoryPerNode" Decode.int
        |> Pipeline.required "defaultProcessorsPerNode" Decode.int
        |> Pipeline.required "defaultMaxRunTime" Decode.string
        |> Pipeline.required "defaultNodeCount" Decode.int
        |> Pipeline.required "defaultQueue" Decode.string
        |> Pipeline.required "deploymentPath" Decode.string
        |> Pipeline.required "deploymentSystem" Decode.string
        |> Pipeline.required "executionSystem" Decode.string
        |> Pipeline.required "executionType" Decode.string
        |> Pipeline.required "helpURI" Decode.string
        |> Pipeline.required "label" Decode.string
        |> Pipeline.required "longDescription" Decode.string
        |> Pipeline.required "shortDescription" Decode.string
        |> Pipeline.required "templatePath" Decode.string
        |> Pipeline.required "testPath" Decode.string
        |> Pipeline.required "parallelism" Decode.string
        |> Pipeline.optional "modules" (Decode.list Decode.string) []
        |> Pipeline.optional "ontology" (Decode.list Decode.string) []
        |> Pipeline.optional "tags" (Decode.list Decode.string) []
        |> Pipeline.optional "inputs" (Decode.list decoderAppInput) []
        |> Pipeline.optional "parameters" (Decode.list decoderAppParam) []
        |> Pipeline.hardcoded []


decoderAppInput : Decoder AppInput
decoderAppInput =
    Decode.succeed AppInput
        |> Pipeline.required "id" Decode.string
        |> Pipeline.optionalAt [ "value", "default" ] Decode.string ""
        |> Pipeline.custom (at [ "value", "order" ] Decode.int)
        |> Pipeline.optionalAt [ "value", "validator" ] Decode.string ""
        |> Pipeline.optionalAt [ "value", "required" ] Decode.bool True
        |> Pipeline.optionalAt [ "value", "visible" ] Decode.bool True
        |> Pipeline.optionalAt [ "semantics", "minCardinality" ] Decode.int 1
        |> Pipeline.optionalAt [ "semantics", "maxCardinality" ] Decode.int -1
        |> Pipeline.optionalAt [ "semantics", "ontology" ]
            (Decode.list Decode.string)
            []
        |> Pipeline.optionalAt [ "semantics", "fileTypes" ]
            (Decode.list Decode.string)
            []
        |> Pipeline.optionalAt [ "details", "description" ] Decode.string ""
        |> Pipeline.optionalAt [ "details", "label" ] Decode.string ""
        |> Pipeline.optionalAt [ "details", "argument" ] Decode.string ""
        |> Pipeline.optionalAt [ "details", "showArgument" ] Decode.bool True
        |> Pipeline.optionalAt [ "details", "repeatArgument" ] Decode.bool False
        |> Pipeline.optionalAt [ "value", "enquote" ] Decode.bool False


decoderAppParam : Decoder AppParam
decoderAppParam =
    Decode.succeed AppParam
        |> Pipeline.required "id" Decode.string
        |> Pipeline.optionalAt [ "value", "default" ]
            decoderAppParamDefaultValue
            (AppParamDefaultValString "")
        |> Pipeline.optionalAt [ "value", "type" ]
            decoderAppParamType
            StringParam
        |> Pipeline.optionalAt [ "value", "order" ] Decode.int 1
        |> Pipeline.optionalAt [ "value", "required" ] Decode.bool True
        |> Pipeline.optionalAt [ "value", "validator" ] Decode.string ""
        |> Pipeline.optionalAt [ "value", "visible" ] Decode.bool True
        |> Pipeline.optionalAt [ "details", "description" ] Decode.string ""
        |> Pipeline.optionalAt [ "details", "label" ] Decode.string ""
        |> Pipeline.optionalAt [ "details", "argument" ] Decode.string ""
        |> Pipeline.optionalAt [ "details", "showArgument" ] Decode.bool True
        |> Pipeline.optionalAt [ "details", "repeatArgument" ] Decode.bool False
        |> Pipeline.optionalAt [ "value", "enquote" ] Decode.bool False
        |> Pipeline.optionalAt [ "value", "enumValues" ]
            (Decode.list decoderAppParamEnumValue)
            []
        |> Pipeline.hardcoded ""
        |> Pipeline.hardcoded ""


decoderAppParamDefaultValue =
    Decode.oneOf
        [ Decode.string
            |> Decode.andThen
                (\s -> Decode.succeed (AppParamDefaultValString s))
        , Decode.float
            |> Decode.andThen
                (\f -> Decode.succeed (AppParamDefaultValNumber f))
        , Decode.int
            |> Decode.andThen
                (\i -> Decode.succeed (AppParamDefaultValNumber (toFloat i)))
        , Decode.bool
            |> Decode.andThen
                (\b -> Decode.succeed (AppParamDefaultValBool b))
        ]


decoderAppParamEnumValue =
    Decode.dict Decode.string
        |> Decode.andThen
            (\d ->
                case Dict.toList d of
                    ( k, v ) :: [] ->
                        Decode.succeed ( k, v )

                    _ ->
                        Decode.fail <| "Too many keys"
            )


decoderAppParamType =
    Decode.string
        |> Decode.andThen
            (\str ->
                case String.toUpper str of
                    "STRING" ->
                        Decode.succeed StringParam

                    "NUMBER" ->
                        Decode.succeed NumberParam

                    "ENUMERATION" ->
                        Decode.succeed EnumerationParam

                    "BOOL" ->
                        Decode.succeed BoolParam

                    "FLAG" ->
                        Decode.succeed FlagParam

                    _ ->
                        Decode.fail <| "Unknown param type: " ++ str
            )


appParamsTable : List AppParam -> Html Msg
appParamsTable params =
    let
        checkIfTrue b =
            if b then
                "Yes"

            else
                "No"

        defVal param =
            case param.defaultValue of
                AppParamDefaultValString s ->
                    s

                AppParamDefaultValNumber n ->
                    String.fromFloat n

                AppParamDefaultValBool b ->
                    if b then
                        "True"

                    else
                        "False"

        lastParam =
            List.length params - 1

        paramTr index param =
            tr []
                [ td [] [ text param.id ]
                , td [] [ text param.label ]
                , td [] [ text (String.fromInt param.displayOrder) ]
                , td [] [ text (paramTypeToString param.paramType) ]
                , td [] [ text param.argument ]
                , td [] [ text (defVal param) ]
                , td [] [ text (checkIfTrue param.required) ]
                , td []
                    [ button
                        [ class "btn btn-default"
                        , onClick (SetAppParamToModify index)
                        ]
                        [ text "Edit" ]
                    ]
                , td []
                    [ button
                        [ class "btn btn-default"
                        , onClick (DeleteAppParam index)
                        ]
                        [ text "Delete" ]
                    ]
                , td []
                    [ button
                        [ class "btn btn-default"
                        , onClick (MoveAppParam Up index)
                        , disabled (index == 0)
                        ]
                        [ text "^" ]
                    ]
                , td []
                    [ button
                        [ class "btn btn-default"
                        , onClick (MoveAppParam Down index)
                        , disabled (index == lastParam)
                        ]
                        [ text "v" ]
                    ]
                ]

        tbl =
            table [ class "table" ]
                [ thead []
                    [ tr []
                        [ th [] [ text "Id" ]
                        , th [] [ text "Label" ]
                        , th [] [ text "Order" ]
                        , th [] [ text "Type" ]
                        , th [] [ text "Arg" ]
                        , th [] [ text "Val" ]
                        , th [] [ text "Required" ]
                        , th [] [ text "" ]
                        , th [] [ text "" ]
                        , th [] [ text "" ]
                        ]
                    ]
                , tbody []
                    (List.indexedMap paramTr params)
                ]
    in
    case List.isEmpty params of
        True ->
            div [] [ text "No params" ]

        False ->
            tbl


appInputsTable : List AppInput -> Html Msg
appInputsTable inputs =
    let
        checkIfTrue b =
            if b then
                "Yes"

            else
                "No"

        lastInput =
            List.length inputs - 1

        inputTr index input =
            tr []
                [ td [] [ text input.id ]
                , td [] [ text input.label ]
                , td [] [ text (String.fromInt input.displayOrder) ]
                , td [] [ text input.argument ]
                , td [] [ text input.defaultValue ]
                , td [] [ text (checkIfTrue input.required) ]
                , td []
                    [ button
                        [ class "btn btn-default"
                        , onClick (SetAppInputToModify index)
                        ]
                        [ text "Edit" ]
                    ]
                , td []
                    [ button
                        [ class "btn btn-default"
                        , onClick (DeleteAppInput index)
                        ]
                        [ text "Delete" ]
                    ]
                , td []
                    [ button
                        [ class "btn btn-default"
                        , onClick (MoveAppInput Up index)
                        , disabled (index == 0)
                        ]
                        [ text "^" ]
                    ]
                , td []
                    [ button
                        [ class "btn btn-default"
                        , onClick (MoveAppInput Down index)
                        , disabled (index == lastInput)
                        ]
                        [ text "v" ]
                    ]
                ]

        tbl =
            table [ class "table" ]
                [ thead []
                    [ tr []
                        [ th [] [ text "Id" ]
                        , th [] [ text "Label" ]
                        , th [] [ text "Order" ]
                        , th [] [ text "Arg" ]
                        , th [] [ text "Val" ]
                        , th [] [ text "Required" ]
                        , th [] [ text "" ]
                        , th [] [ text "" ]
                        , th [] [ text "" ]
                        , th [] [ text "" ]
                        ]
                    ]
                , tbody []
                    (List.indexedMap inputTr inputs)
                ]
    in
    case List.isEmpty inputs of
        True ->
            div [] [ text "No inputs" ]

        False ->
            tbl


decodeIncomingJson : Model -> Model
decodeIncomingJson model =
    let
        ( newApp, err ) =
            case model.incomingJson of
                Just json ->
                    case Decode.decodeString decoderApp json of
                        Ok a ->
                            ( a, Nothing )

                        Err e ->
                            ( model.app, Just (Decode.errorToString e) )

                _ ->
                    ( model.app, Just "No JSON" )
    in
    { model | app = newApp, jsonError = err }


encodeApp : App -> String
encodeApp app =
    let
        encodeInput input =
            JE.object
                [ ( "id", JE.string input.id )
                , ( "value"
                  , JE.object
                        [ ( "default", JE.string input.defaultValue )
                        , ( "order", JE.int input.displayOrder )
                        , ( "validator", JE.string input.validator )
                        , ( "required", JE.bool input.required )
                        , ( "visible", JE.bool input.visible )
                        , ( "enquote", JE.bool input.enquoteValue )
                        ]
                  )
                , ( "semantics"
                  , JE.object
                        [ ( "ontology"
                          , JE.list JE.string input.ontology
                          )
                        , ( "minCardinality", JE.int input.minCardinality )
                        , ( "maxCardinality", JE.int input.maxCardinality )
                        , ( "fileTypes"
                          , JE.list JE.string input.fileTypes
                          )
                        ]
                  )
                , ( "details"
                  , JE.object
                        [ ( "description", JE.string input.description )
                        , ( "label", JE.string input.label )
                        , ( "argument", JE.string input.argument )
                        , ( "repeatArgument", JE.bool input.repeatArgument )
                        , ( "showArgument", JE.bool input.showArgument )
                        ]
                  )
                ]

        paramValueSection param =
            let
                validator =
                    case param.paramType of
                        EnumerationParam ->
                            []

                        _ ->
                            [ ( "validator", JE.string param.validator ) ]

                enumVals =
                    case param.paramType of
                        EnumerationParam ->
                            [ ( "enumValues"
                              , JE.list
                                    (\e ->
                                        JE.object
                                            [ ( Tuple.first e
                                              , JE.string (Tuple.second e)
                                              )
                                            ]
                                    )
                                    param.enumValues
                              )
                            ]

                        _ ->
                            []

                defValue =
                    case param.defaultValue of
                        AppParamDefaultValNumber n ->
                            JE.float n

                        AppParamDefaultValString s ->
                            JE.string s

                        AppParamDefaultValBool b ->
                            JE.bool b
            in
            [ ( "default", defValue )
            , ( "type"
              , JE.string
                    (String.toLower
                        (paramTypeToString param.paramType)
                    )
              )
            , ( "order", JE.int param.displayOrder )
            , ( "required", JE.bool param.required )
            , ( "visible", JE.bool param.visible )
            , ( "enquote", JE.bool param.enquoteValue )
            ]
                ++ validator
                ++ enumVals

        encodeParameter param =
            JE.object
                [ ( "id", JE.string param.id )
                , ( "value"
                  , JE.object (paramValueSection param)
                  )
                , ( "details"
                  , JE.object
                        [ ( "description", JE.string param.description )
                        , ( "label", JE.string param.label )
                        , ( "argument", JE.string param.argument )
                        , ( "repeatArgument", JE.bool param.repeatArgument )
                        , ( "showArgument", JE.bool param.showArgument )
                        ]
                  )
                ]
    in
    JE.encode 4
        (JE.object
            [ ( "name", JE.string app.name )
            , ( "version", JE.string app.version )
            , ( "shortDescription", JE.string app.shortDescription )
            , ( "longDescription", JE.string app.longDescription )
            , ( "available", JE.bool app.available )
            , ( "checkpointable", JE.bool app.checkpointable )
            , ( "defaultMemoryPerNode", JE.int app.defaultMemoryPerNode )
            , ( "defaultProcessorsPerNode"
              , JE.int app.defaultProcessorsPerNode
              )
            , ( "defaultMaxRunTime", JE.string app.defaultMaxRunTime )
            , ( "defaultNodeCount", JE.int app.defaultNodeCount )
            , ( "defaultQueue", JE.string app.defaultQueue )
            , ( "deploymentPath", JE.string app.deploymentPath )
            , ( "deploymentSystem", JE.string app.deploymentSystem )
            , ( "executionSystem", JE.string app.executionSystem )
            , ( "executionType", JE.string app.executionType )
            , ( "helpURI", JE.string app.helpUri )
            , ( "label", JE.string app.label )
            , ( "parallelism", JE.string app.parallelism )
            , ( "templatePath", JE.string app.templatePath )
            , ( "testPath", JE.string app.testPath )
            , ( "modules", JE.list JE.string app.modules )
            , ( "tags", JE.list JE.string app.tags )
            , ( "ontology", JE.list JE.string app.ontology )
            , ( "inputs", JE.list encodeInput app.inputs )
            , ( "parameters", JE.list encodeParameter app.parameters )
            , ( "outputs", JE.list JE.string app.outputs )
            ]
        )


alterDisplayOrder direction indexToMove list =
    List.sortBy (\i -> i.displayOrder)
        (List.indexedMap
            (\thisIndex this ->
                let
                    newOrder =
                        case direction of
                            Up ->
                                if thisIndex == indexToMove - 1 then
                                    this.displayOrder + 1

                                else if thisIndex == indexToMove then
                                    this.displayOrder - 1

                                else
                                    this.displayOrder

                            Down ->
                                if thisIndex == indexToMove + 1 then
                                    this.displayOrder - 1

                                else if thisIndex == indexToMove then
                                    this.displayOrder + 1

                                else
                                    this.displayOrder
                in
                { this | displayOrder = newOrder }
            )
            list
        )


modifyAppParamDialog : Model -> Html Msg
modifyAppParamDialog model =
    let
        body param =
            let
                err =
                    case model.appParamError of
                        Nothing ->
                            div [] [ text "" ]

                        Just e ->
                            div [ class "alert alert-danger" ]
                                [ text ("Error: " ++ e) ]

                mkBool val =
                    mkRowSelect "Default Value"
                        [ "True", "False" ]
                        val
                        UpdateAppParamDefaultValue

                defValEntry =
                    case param.paramType of
                        BoolParam ->
                            mkBool defVal

                        FlagParam ->
                            mkBool defVal

                        NumberParam ->
                            mkRowTextEntry "Default Value"
                                defVal
                                UpdateAppParamDefaultValue

                        _ ->
                            mkRowTextEntry "Default Value"
                                defVal
                                UpdateAppParamDefaultValue

                defVal =
                    case param.defaultValue of
                        AppParamDefaultValNumber n ->
                            String.fromFloat n

                        AppParamDefaultValBool b ->
                            if b then
                                "True"

                            else
                                "False"

                        AppParamDefaultValString v ->
                            v
            in
            div []
                [ err
                , div
                    [ style "overflow-y" "auto"
                    , style "max-height" "60vh"
                    ]
                    [ Html.form []
                        [ table []
                            [ mkRowTextEntry "Id"
                                param.id
                                UpdateAppParamId
                            , mkRowTextEntry "Label"
                                param.label
                                UpdateAppParamLabel
                            , mkRowTextEntry "Description"
                                param.description
                                UpdateAppParamDescription
                            , mkRowTextEntry "Display Order"
                                (String.fromInt param.displayOrder)
                                UpdateAppParamDisplayOrder
                            , mkRowTextEntry "Argument"
                                param.argument
                                UpdateAppParamArgument
                            , mkRowSelect "Type"
                                (List.map
                                    paramTypeToString
                                    [ StringParam
                                    , NumberParam
                                    , EnumerationParam
                                    , BoolParam
                                    , FlagParam
                                    ]
                                )
                                (paramTypeToString param.paramType)
                                UpdateAppParamType
                            , showEnumValues param
                            , defValEntry
                            , mkRowTextEntry "Validator"
                                param.validator
                                UpdateAppParamValidator
                            , mkRowCheckbox "Show Argument"
                                param.showArgument
                                UpdateAppParamToggleShowArgument
                            , mkRowCheckbox "Repeat Argument"
                                param.repeatArgument
                                UpdateAppParamToggleRepeatArgument
                            , mkRowCheckbox "Required"
                                param.required
                                UpdateAppParamToggleRequired
                            , mkRowCheckbox
                                "Visible"
                                param.visible
                                UpdateAppParamToggleVisible
                            , mkRowCheckbox "Enquote Value"
                                param.enquoteValue
                                UpdateAppParamToggleEnquoteValue
                            ]
                        ]
                    ]
                ]
    in
    Dialog.view
        (case model.paramToModify of
            Just param ->
                Just
                    { closeMessage = Nothing
                    , containerClass = Nothing
                    , header = Just (text "Add Param")
                    , body = Just (body param)
                    , footer =
                        Just
                            (div
                                []
                                [ button
                                    [ class "btn btn-primary"
                                    , type_ "button"
                                    , onClick SaveAppParam
                                    ]
                                    [ text "Save" ]
                                , button
                                    [ class "btn btn-default"
                                    , type_ "button"
                                    , onClick CloseAppParamDialog
                                    ]
                                    [ text "Cancel" ]
                                ]
                            )
                    }

            Nothing ->
                Nothing
        )


modifyAppInputDialog : Model -> Html Msg
modifyAppInputDialog model =
    let
        tbl appInput =
            let
                err =
                    case model.appInputError of
                        Nothing ->
                            div [] [ text "" ]

                        Just e ->
                            div [ class "alert alert-danger" ]
                                [ text ("Error: " ++ e) ]
            in
            div []
                [ err
                , div
                    [ style "overflow-y" "auto"
                    , style "max-height" "60vh"
                    ]
                    [ Html.form []
                        [ table []
                            [ mkRowTextEntry "Id"
                                appInput.id
                                UpdateAppInputId
                            , mkRowTextEntry "Label"
                                appInput.label
                                UpdateAppInputLabel
                            , mkRowTextEntry
                                "Description"
                                appInput.description
                                UpdateAppInputDescription
                            , mkRowTextEntry "Argument"
                                appInput.argument
                                UpdateAppInputArgument
                            , mkRowCheckbox "Repeat Argument"
                                appInput.repeatArgument
                                UpdateAppInputToggleRepeatArgument
                            , mkRowCheckbox "Show Argument"
                                appInput.showArgument
                                UpdateAppInputToggleShowArgument
                            , mkRowCheckbox "Required"
                                appInput.required
                                UpdateAppInputToggleRequired
                            , mkRowCheckbox
                                "Visible"
                                appInput.visible
                                UpdateAppInputToggleVisible
                            , mkRowCheckbox "Enquote Value"
                                appInput.enquoteValue
                                UpdateAppInputToggleEnquoteValue
                            , mkRowTextEntry "Default Value"
                                appInput.defaultValue
                                UpdateAppInputDefaultValue
                            , mkRowTextEntry
                                "Display Order"
                                (String.fromInt appInput.displayOrder)
                                UpdateAppInputDisplayOrder
                            , mkRowTextEntry
                                "Validator"
                                appInput.validator
                                UpdateAppInputValidator
                            , mkRowTextEntry
                                "Ontology"
                                (String.join ", " appInput.ontology)
                                UpdateAppInputOntology
                            , mkRowTextEntry
                                "Min Cardinality"
                                (String.fromInt appInput.minCardinality)
                                UpdateAppInputMinCardinality
                            , mkRowTextEntry
                                "Max Cardinality"
                                (String.fromInt appInput.maxCardinality)
                                UpdateAppInputMaxCardinality
                            , mkRowTextEntry
                                "File Types"
                                (String.join ", " appInput.fileTypes)
                                UpdateAppInputFileTypes
                            ]
                        ]
                    ]
                ]
    in
    Dialog.view
        (case model.inputToModify of
            Just input ->
                Just
                    { closeMessage = Nothing
                    , containerClass = Nothing
                    , header = Just (text "Add Input")
                    , body = Just (tbl input)
                    , footer =
                        Just
                            (div
                                []
                                [ button
                                    [ class "btn btn-primary"
                                    , type_ "button"
                                    , onClick SaveAppInput
                                    ]
                                    [ text "Save" ]
                                , button
                                    [ class "btn btn-default"
                                    , type_ "button"
                                    , onClick CloseAppInputDialog
                                    ]
                                    [ text "Cancel" ]
                                ]
                            )
                    }

            Nothing ->
                Nothing
        )


modifyJsonDialog : Model -> Html Msg
modifyJsonDialog model =
    let
        err =
            case model.jsonError of
                Nothing ->
                    div [] [ text "" ]

                Just e ->
                    div [ class "alert alert-danger" ]
                        [ text ("Error: " ++ e) ]

        body =
            div
                [ style "overflow-y" "auto"
                , style "max-height" "60vh"
                ]
                [ err
                , textarea
                    [ cols 80, rows 30, onInput UpdateIncomingJson ]
                    [ text (encodeApp model.app) ]
                ]
    in
    Dialog.view
        (case model.incomingJson of
            Just json ->
                Just
                    { closeMessage = Nothing
                    , containerClass = Nothing
                    , header = Just (text "Edit JSON")
                    , body = Just body
                    , footer =
                        Just
                            (div
                                []
                                [ button
                                    [ class "btn btn-primary"
                                    , type_ "button"
                                    , onClick DecodeIncomingJson
                                    ]
                                    [ text "Save" ]
                                , button
                                    [ class "btn btn-default"
                                    , type_ "button"
                                    , onClick CloseJsonDialog
                                    ]
                                    [ text "Cancel" ]
                                ]
                            )
                    }

            _ ->
                Nothing
        )


paramTypeToString : AppParamType -> String
paramTypeToString paramType =
    case paramType of
        StringParam ->
            "String"

        NumberParam ->
            "Number"

        EnumerationParam ->
            "Enumeration"

        BoolParam ->
            "Boolean"

        FlagParam ->
            "Flag"


showEnumValues : AppParam -> Html Msg
showEnumValues param =
    let
        mkRow lastEnum index ( enumKey, enumVal ) =
            tr []
                [ td [] [ text enumKey ]
                , td [] [ text enumVal ]
                , td []
                    [ button
                        [ type_ "button"
                        , class "btn btn-default"
                        , onClick (UpdateAppParamDeleteEnumValue index)
                        ]
                        [ text "Delete" ]
                    ]
                , td []
                    [ button
                        [ type_ "button"
                        , class "btn btn-default"
                        , disabled (index == 0)
                        , onClick (UpdateAppParamMoveEnumValue Up index)
                        ]
                        [ text "^" ]
                    ]
                , td []
                    [ button
                        [ type_ "button"
                        , class "btn btn-default"
                        , disabled (index == lastEnum)
                        , onClick (UpdateAppParamMoveEnumValue Down index)
                        ]
                        [ text "v" ]
                    ]
                ]

        enumList enumValues =
            let
                lastEnum =
                    List.length enumValues - 1
            in
            case List.isEmpty enumValues of
                True ->
                    text ""

                False ->
                    table [ class "table" ]
                        [ thead []
                            [ tr []
                                [ th [] [ text "Name" ]
                                , th [] [ text "Value" ]
                                ]
                            ]
                        , tbody []
                            (List.indexedMap
                                (mkRow lastEnum)
                                enumValues
                            )
                        ]

        inputTable =
            table []
                [ thead []
                    [ th [] [ text "Key" ]
                    , th [] [ text "Value" ]
                    ]
                , tbody []
                    [ tr []
                        [ td []
                            [ input
                                [ onInput UpdateAppParamEnumKey
                                , value param.inputEnumKey
                                ]
                                []
                            ]
                        , td []
                            [ input
                                [ onInput UpdateAppParamEnumValue
                                , value param.inputEnumValue
                                ]
                                []
                            ]
                        , td []
                            [ button
                                [ onClick UpdateAppParamAddEnum
                                , class "btn btn-primary"
                                , type_ "button"
                                ]
                                [ text "Add" ]
                            ]
                        ]
                    ]
                ]

        tbl =
            table []
                [ tr [] [ td [] [ enumList param.enumValues ] ]
                , tr [] [ td [] [ inputTable ] ]
                ]
    in
    case param.paramType of
        EnumerationParam ->
            tr []
                [ mkTh "Enum Values"
                , td [] [ tbl ]
                ]

        _ ->
            tr [] []
