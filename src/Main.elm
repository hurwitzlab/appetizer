module Main exposing (..)

import Bootstrap.Grid as Grid
import Bootstrap.Tab as Tab
import Dialog
import Dict
import Json.Decode as Decode exposing (Decoder, at)
import Json.Decode.Pipeline as Pipeline exposing (decode, optional, required, custom)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as JD
import Json.Encode as JE
import List.Extra exposing (zip)


---- MODEL ----


type alias Model =
    { app : App
    , testapp : TestApp
    , showJson : Bool
    , tabState : Tab.State
    , inputToModify : Maybe AppInput
    , paramToModify : Maybe AppParam
    , incomingJson : String
    , error : Maybe String
    }


type alias TestApp =
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
    , modules : List String
    , ontology : List String
    , tags : List String
    , parallelism : Parallelism
    , inputs : List AppInput
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
    , modules : List String
    , ontology : List String
    , tags : List String
    , parallelism : Parallelism
    , inputs : Dict.Dict String AppInput
    , parameters : Dict.Dict String AppParam
    , error : Maybe String
    }



-- Cf. http://developer.agaveapi.co/#inputs-and-parameters


type alias AppInput =
    { originalInputId : String
    , id : String
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
    , error : Maybe String
    }


type alias AppParam =
    { originalParamId : String
    , id : String
    , defaultValue : String
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
    , minCardinality : Int
    , maxCardinality : Int
    , enumValues : List EnumParamValue
    , error : Maybe String
    , inputEnumKey : String
    , inputEnumValue : String
    }


type alias EnumParamValue =
    { paramKey : String
    , paramValue : String
    }


type AppParamType
    = StringParam
    | NumberParam
    | EnumerationParam
    | BoolParam
    | FlagParam


type Parallelism
    = Serial
    | Parallel


initialModel =
    { app = initialApp
    , testapp = initialTestApp
    , showJson = False
    , tabState = Tab.initialState
    , inputToModify = Nothing
    , paramToModify = Nothing
    , incomingJson = ""
    , error = Nothing
    }


initialTestApp =
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
    , modules = [ "tacc-singularity", "launcher" ]
    , ontology = [ "http://sswapmeet.sswap.info/agave/apps/Application" ]
    , tags = [ "imicrobe" ]
    , testPath = "test.sh"
    , templatePath = "template.sh"
    , parallelism = Serial
    , inputs = []
    }


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
    , parallelism = Serial
    , modules = [ "tacc-singularity", "launcher" ]
    , ontology = [ "http://sswapmeet.sswap.info/agave/apps/Application" ]
    , tags = [ "imicrobe" ]
    , testPath = "test.sh"
    , templatePath = "template.sh"
    , inputs = Dict.empty
    , parameters = Dict.empty
    , error = Nothing
    }


initialAppInput =
    { originalInputId = ""
    , id = "INPUT"
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
    , error = Nothing
    }


initialAppParam =
    { originalParamId = ""
    , id = ""
    , defaultValue = ""
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
    , minCardinality = -1
    , maxCardinality = 1
    , enumValues = []
    , error = Nothing
    , inputEnumKey = ""
    , inputEnumValue = ""
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp String
    | CloseJsonDialog
    | CloseAppInputDialog
    | CloseAppParamDialog
    | CloseModifyAppInputDialog
    | DecodeIncomingJson
    | ShowJsonDialog
    | TabMsg Tab.State
    | OpenModifyAppInputDialog AppInput
    | OpenModifyAppParamDialog AppParam
    | SaveAppInput
    | SaveAppParam
    | SetAppInputToModify String
    | SetAppParamToModify String
    | ToggleAppAvailable
    | ToggleAppCheckpointable
    | UpdateAppInputId String
    | UpdateAppInputArgument String
    | UpdateAppInputDefaultValue String
    | UpdateAppInputDescription String
    | UpdateAppInputDisplayOrder String
    | UpdateAppInputFileTypes String
    | UpdateAppInputLabel String
    | UpdateAppInputMaxCardinality String
    | UpdateAppInputMinCardinality String
    | UpdateAppInputValidator String
    | UpdateAppInputToggleEnquoteValue
    | UpdateAppInputToggleRepeatArgument
    | UpdateAppInputToggleRequired
    | UpdateAppInputToggleShowArgument
    | UpdateAppInputToggleVisible
    | UpdateAppInputOntology String
    | UpdateAppParamAddEnum
    | UpdateAppParamArgument String
    | UpdateAppParamDisplayOrder String
    | UpdateAppParamDefaultValue String
    | UpdateAppParamDescription String
    | UpdateAppParamEnumKey String
    | UpdateAppParamEnumValue String
    | UpdateAppParamLabel String
    | UpdateAppParamId String
    | UpdateAppParamMaxCardinality String
    | UpdateAppParamMinCardinality String
    | UpdateAppParamToggleEnquoteValue
    | UpdateAppParamToggleRequired
    | UpdateAppParamToggleRepeatArgument
    | UpdateAppParamToggleShowArgument
    | UpdateAppParamToggleVisible
    | UpdateAppParamType String
    | UpdateAppParamValidator String
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
    | UpdateAppLabel String
    | UpdateAppLongDescription String
    | UpdateAppModules String
    | UpdateAppName String
    | UpdateAppOntology String
    | UpdateAppParallelism Parallelism
    | UpdateAppShortDescription String
    | UpdateAppTags String
    | UpdateAppTemplatePath String
    | UpdateAppTestPath String
    | UpdateAppVersion String
    | UpdateIncomingJson String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp val ->
            ( model, Cmd.none )

        CloseAppInputDialog ->
            ( { model | inputToModify = Nothing }, Cmd.none )

        CloseAppParamDialog ->
            ( { model | paramToModify = Nothing }, Cmd.none )

        CloseJsonDialog ->
            ( { model | showJson = False }, Cmd.none )

        CloseModifyAppInputDialog ->
            ( { model | inputToModify = Nothing }, Cmd.none )

        DecodeIncomingJson ->
            ( decodeIncomingJson model, Cmd.none )

        OpenModifyAppInputDialog input ->
            ( { model
                | inputToModify = Just { input | originalInputId = input.id }
              }
            , Cmd.none
            )

        OpenModifyAppParamDialog param ->
            ( { model
                | paramToModify = Just { param | originalParamId = param.id }
              }
            , Cmd.none
            )

        SaveAppInput ->
            let
                newInputs =
                    case model.inputToModify of
                        Just input ->
                            Dict.update input.id
                                (\_ -> Just input)
                                (Dict.remove
                                    input.originalInputId
                                    model.app.inputs
                                )

                        _ ->
                            model.app.inputs

                curApp =
                    model.app

                newApp =
                    { curApp | inputs = newInputs }
            in
                ( { model | app = newApp, inputToModify = Nothing }
                , Cmd.none
                )

        SaveAppParam ->
            let
                newParams =
                    case model.paramToModify of
                        Just param ->
                            Dict.update param.id
                                (\_ -> Just param)
                                (Dict.remove param.originalParamId
                                    model.app.parameters
                                )

                        _ ->
                            model.app.parameters

                curApp =
                    model.app

                newApp =
                    { curApp | parameters = newParams }
            in
                ( { model | app = newApp, paramToModify = Nothing }
                , Cmd.none
                )

        SetAppInputToModify id ->
            let
                newInput =
                    Maybe.map
                        (\input -> { input | originalInputId = input.id })
                        (Dict.get id model.app.inputs)
            in
                ( { model | inputToModify = newInput }, Cmd.none )

        SetAppParamToModify id ->
            let
                newParam =
                    Maybe.map
                        (\param -> { param | originalParamId = param.id })
                        (Dict.get id model.app.parameters)
            in
                ( { model | paramToModify = newParam }, Cmd.none )

        ShowJsonDialog ->
            ( { model | showJson = True }, Cmd.none )

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
                newInput =
                    case model.inputToModify of
                        Just input ->
                            let
                                ( newDisplayOrder, err ) =
                                    case String.toInt val of
                                        Ok n ->
                                            ( n, Nothing )

                                        Err e ->
                                            ( input.displayOrder
                                            , Just e
                                            )
                            in
                                Just
                                    { input
                                        | displayOrder = newDisplayOrder
                                        , error = err
                                    }

                        _ ->
                            Nothing
            in
                ( { model | inputToModify = newInput }, Cmd.none )

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
                newInput =
                    case model.inputToModify of
                        Just input ->
                            let
                                ( newVal, err ) =
                                    case String.toInt val of
                                        Ok n ->
                                            ( n, Nothing )

                                        Err e ->
                                            ( input.maxCardinality, Just e )
                            in
                                Just
                                    { input
                                        | maxCardinality = newVal
                                        , error = err
                                    }

                        _ ->
                            Nothing
            in
                ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppInputMinCardinality val ->
            let
                newInput =
                    case model.inputToModify of
                        Just input ->
                            let
                                ( newVal, err ) =
                                    case String.toInt val of
                                        Ok n ->
                                            ( n, Nothing )

                                        Err e ->
                                            ( input.minCardinality, Just e )
                            in
                                Just
                                    { input
                                        | minCardinality = newVal
                                        , error = err
                                    }

                        _ ->
                            Nothing
            in
                ( { model | inputToModify = newInput }, Cmd.none )

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
                                    { paramKey = param.inputEnumKey
                                    , paramValue = param.inputEnumValue
                                    }
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

        UpdateAppParamDisplayOrder val ->
            let
                newParam =
                    case model.paramToModify of
                        Just param ->
                            let
                                ( newDisplayOrder, err ) =
                                    case String.toInt val of
                                        Ok n ->
                                            ( n, Nothing )

                                        Err e ->
                                            ( param.displayOrder, Just e )
                            in
                                Just
                                    { param
                                        | displayOrder = newDisplayOrder
                                        , error = err
                                    }

                        _ ->
                            Nothing
            in
                ( { model | paramToModify = newParam }, Cmd.none )

        UpdateAppParamDefaultValue val ->
            let
                newParam =
                    Maybe.map (\x -> { x | defaultValue = val })
                        model.paramToModify
            in
                ( { model | paramToModify = newParam }, Cmd.none )

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

        UpdateAppParamMaxCardinality val ->
            let
                newParam =
                    case model.paramToModify of
                        Just param ->
                            let
                                ( newVal, err ) =
                                    case String.toInt val of
                                        Ok n ->
                                            ( n, Nothing )

                                        Err e ->
                                            ( param.maxCardinality, Just e )
                            in
                                Just
                                    { param
                                        | maxCardinality = newVal
                                        , error = err
                                    }

                        _ ->
                            Nothing
            in
                ( { model | paramToModify = newParam }, Cmd.none )

        UpdateAppParamMinCardinality val ->
            let
                newParam =
                    case model.paramToModify of
                        Just param ->
                            let
                                ( newVal, err ) =
                                    case String.toInt val of
                                        Ok n ->
                                            ( n, Nothing )

                                        Err e ->
                                            ( param.minCardinality, Just e )
                            in
                                Just
                                    { param
                                        | minCardinality = newVal
                                        , error = err
                                    }

                        _ ->
                            Nothing
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
                ( newType, err ) =
                    case val of
                        "String" ->
                            ( StringParam, Nothing )

                        "Number" ->
                            ( NumberParam, Nothing )

                        "Enum" ->
                            ( EnumerationParam, Nothing )

                        "Boolean" ->
                            ( BoolParam, Nothing )

                        "Flag" ->
                            ( FlagParam, Nothing )

                        _ ->
                            ( StringParam, Just "Unknown parameter type" )

                newParam =
                    Maybe.map
                        (\param ->
                            { param
                                | paramType = newType
                                , error = err
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
                        Ok n ->
                            ( n, Nothing )

                        Err e ->
                            ( app.defaultMemoryPerNode
                            , Just e
                            )

                newApp =
                    { app | defaultMemoryPerNode = num, error = err }
            in
                ( { model | app = newApp }, Cmd.none )

        UpdateAppDefaultNodeCount val ->
            let
                app =
                    model.app

                ( num, err ) =
                    case String.toInt val of
                        Ok n ->
                            ( n, Nothing )

                        Err e ->
                            ( app.defaultNodeCount
                            , Just e
                            )

                newApp =
                    { app | defaultNodeCount = num, error = err }
            in
                ( { model | app = newApp }, Cmd.none )

        UpdateAppDefaultProcessorsPerNode val ->
            let
                app =
                    model.app

                ( num, err ) =
                    case String.toInt val of
                        Ok n ->
                            ( n, Nothing )

                        Err e ->
                            ( app.defaultProcessorsPerNode
                            , Just e
                            )

                newApp =
                    { app | defaultProcessorsPerNode = num, error = err }
            in
                ( { model | app = newApp }, Cmd.none )

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

        UpdateIncomingJson val ->
            ( { model | incomingJson = val }, Cmd.none )



---- VIEW ----


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
                          , JE.list (List.map JE.string input.ontology)
                          )
                        , ( "minCardinality", JE.int input.minCardinality )
                        , ( "maxCardinality", JE.int input.maxCardinality )
                        , ( "fileTypes"
                          , JE.list (List.map JE.string input.fileTypes)
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
                enumVals =
                    case param.paramType of
                        EnumerationParam ->
                            [ ( "enumValues"
                              , JE.object
                                    (List.map
                                        (\e ->
                                            ( e.paramKey
                                            , JE.string e.paramValue
                                            )
                                        )
                                        param.enumValues
                                    )
                              )
                            ]

                        _ ->
                            []
            in
                [ ( "default", JE.string param.defaultValue )
                , ( "type"
                  , JE.string
                        (String.toLower
                            (paramTypeToString param.paramType)
                        )
                  )
                , ( "order", JE.int param.displayOrder )
                , ( "validator", JE.string param.validator )
                , ( "required", JE.bool param.required )
                , ( "visible", JE.bool param.visible )
                , ( "enquote", JE.bool param.enquoteValue )
                ]
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
                , ( "parallelism"
                  , JE.string
                        (if app.parallelism == Serial then
                            "SERIAL"
                         else
                            "PARALLEL"
                        )
                  )
                , ( "templatePath", JE.string app.templatePath )
                , ( "testPath", JE.string app.testPath )
                , ( "modules", JE.list (List.map JE.string app.modules) )
                , ( "tags", JE.list (List.map JE.string app.tags) )
                , ( "ontology", JE.list (List.map JE.string app.ontology) )
                , ( "inputs"
                  , JE.list
                        (List.map encodeInput
                            (List.sortBy .displayOrder
                                (Dict.values app.inputs)
                            )
                        )
                  )
                , ( "parameters"
                  , JE.list
                        (List.map encodeParameter
                            (List.sortBy .displayOrder
                                (Dict.values app.parameters)
                            )
                        )
                  )
                ]
            )


paneInputs : Model -> Html Msg
paneInputs model =
    let
        maxDisplayOrder =
            List.maximum
                (List.map
                    (\d -> d.displayOrder)
                    (Dict.values model.app.inputs)
                )

        nextDisplayOrder =
            case maxDisplayOrder of
                Nothing ->
                    1

                Just n ->
                    n + 1
    in
        div [ class "form-group", style [ ( "text-align", "center" ) ] ]
            [ button
                [ type_ "button"
                , class "btn btn-default"
                , onClick
                    (OpenModifyAppInputDialog
                        { initialAppInput
                            | id = "INPUT" ++ toString nextDisplayOrder
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
        maxDisplayOrder =
            List.maximum
                (List.map
                    (\d -> d.displayOrder)
                    (Dict.values model.app.parameters)
                )

        nextDisplayOrder =
            case maxDisplayOrder of
                Nothing ->
                    1

                Just n ->
                    n + 1
    in
        div [ class "form-group", style [ ( "text-align", "center" ) ] ]
            [ button
                [ type_ "button"
                , class "btn btn-default"
                , onClick
                    (OpenModifyAppParamDialog
                        { initialAppParam
                            | id = "PARAM" ++ toString nextDisplayOrder
                            , label = "PARAM" ++ toString nextDisplayOrder
                            , displayOrder = nextDisplayOrder
                        }
                    )
                ]
                [ text "Add Param" ]
            , modifyAppParamDialog model
            , appParamsTable model.app.parameters
            ]


modifyAppInputDialog : Model -> Html Msg
modifyAppInputDialog model =
    let
        tbl appInput =
            let
                err =
                    case appInput.error of
                        Nothing ->
                            div [] [ text "" ]

                        Just e ->
                            div [ class "alert alert-danger" ]
                                [ text ("Error: " ++ e) ]
            in
                div []
                    [ err
                    , div
                        [ style
                            [ ( "overflow-y", "auto" )
                            , ( "max-height", "60vh" )
                            ]
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
                                    (toString appInput.displayOrder)
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
                                    (toString appInput.minCardinality)
                                    UpdateAppInputMinCardinality
                                , mkRowTextEntry
                                    "Max Cardinality"
                                    (toString appInput.maxCardinality)
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


modifyAppParamDialog : Model -> Html Msg
modifyAppParamDialog model =
    let
        body param =
            let
                err =
                    case param.error of
                        Nothing ->
                            div [] [ text "" ]

                        Just e ->
                            div [ class "alert alert-danger" ]
                                [ text ("Error: " ++ e) ]
            in
                div []
                    [ err
                    , div
                        [ style
                            [ ( "overflow-y", "auto" )
                            , ( "max-height", "60vh" )
                            ]
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
                                    (toString param.displayOrder)
                                    UpdateAppParamDisplayOrder
                                , mkRowTextEntry "Argument"
                                    param.argument
                                    UpdateAppParamArgument
                                , mkRowSelect "Type"
                                    param.paramType
                                    UpdateAppParamType
                                , showEnumValues param
                                , mkRowTextEntry "Default Value"
                                    param.defaultValue
                                    UpdateAppParamDefaultValue
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
                                , mkRowTextEntry "Min. Cardinality"
                                    (toString param.minCardinality)
                                    UpdateAppParamMinCardinality
                                , mkRowTextEntry "Max. Cardinality"
                                    (toString param.maxCardinality)
                                    UpdateAppParamMaxCardinality
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


showEnumValues : AppParam -> Html Msg
showEnumValues param =
    let
        vals =
            case param.paramType of
                EnumerationParam ->
                    tbl

                _ ->
                    text "NA"

        enumList enumValues =
            case List.length enumValues of
                0 ->
                    text "None"

                _ ->
                    ol []
                        (List.map
                            (\v ->
                                li []
                                    [ text
                                        (v.paramKey
                                            ++ " = "
                                            ++ v.paramValue
                                        )
                                    ]
                            )
                            enumValues
                        )

        tbl =
            table []
                [ tr []
                    [ td []
                        [ text "Key: "
                        , input
                            [ onInput UpdateAppParamEnumKey
                            , value param.inputEnumKey
                            ]
                            []
                        ]
                    , td []
                        [ text "Value: "
                        , input
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
                , tr []
                    [ td [] [ enumList param.enumValues ]
                    ]
                ]
    in
        tr []
            [ mkTh "Enum Values"
            , td [] [ vals ]
            ]


appInputsTable : Dict.Dict String AppInput -> Html Msg
appInputsTable inputs =
    let
        checkIfTrue b =
            if b then
                "✓"
            else
                "✗"

        inputTr ( id, input ) =
            tr []
                [ td [] [ text input.id ]
                , td [] [ text (toString input.displayOrder) ]
                , td [] [ text input.argument ]
                , td [] [ text input.defaultValue ]
                , td [] [ text (checkIfTrue input.required) ]
                , td [] [ text (checkIfTrue input.visible) ]
                , td []
                    [ button
                        [ class "btn btn-default"
                        , onClick (SetAppInputToModify id)
                        ]
                        [ text "Edit" ]
                    ]
                ]

        tbl =
            table []
                ([ tr []
                    [ th [] [ text "Id" ]
                    , th [] [ text "Order" ]
                    , th [] [ text "Arg" ]
                    , th [] [ text "Val" ]
                    , th [] [ text "Required" ]
                    , th [] [ text "Visible" ]
                    ]
                 ]
                    ++ List.map inputTr
                        (List.sortBy (\( id, d ) -> d.displayOrder)
                            (Dict.toList inputs)
                        )
                )
    in
        case Dict.isEmpty inputs of
            True ->
                div [] [ text "No inputs" ]

            False ->
                tbl


appParamsTable : Dict.Dict String AppParam -> Html Msg
appParamsTable params =
    let
        checkIfTrue b =
            if b then
                "✓"
            else
                "✗"

        paramTr ( id, param ) =
            tr []
                [ td [] [ text param.id ]
                , td [] [ text (toString param.displayOrder) ]
                , td [] [ text (toString param.paramType) ]
                , td [] [ text param.argument ]
                , td [] [ text param.defaultValue ]
                , td [] [ text (checkIfTrue param.required) ]
                , td [] [ text (checkIfTrue param.visible) ]
                , td []
                    [ button
                        [ class "btn btn-default"
                        , onClick (SetAppParamToModify id)
                        ]
                        [ text "Edit" ]
                    ]
                ]

        tbl =
            table []
                ([ tr []
                    [ th [] [ text "Id" ]
                    , th [] [ text "Order" ]
                    , th [] [ text "Type" ]
                    , th [] [ text "Arg" ]
                    , th [] [ text "Val" ]
                    , th [] [ text "Required" ]
                    , th [] [ text "Visible" ]
                    ]
                 ]
                    ++ List.map paramTr
                        (List.sortBy (\( id, d ) -> d.displayOrder)
                            (Dict.toList params)
                        )
                )
    in
        case Dict.isEmpty params of
            True ->
                div [] [ text "No params" ]

            False ->
                tbl


view : Model -> Html Msg
view model =
    let
        err =
            case model.app.error of
                Nothing ->
                    div [] [ text "" ]

                Just e ->
                    div [ class "alert alert-danger" ]
                        [ text ("Error: " ++ e) ]
    in
        Grid.container []
            [ h1 [] [ text "The Appetizer" ]
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
                                , pre [] [ text (toString model.app) ]
                                ]
                        }
                    , Tab.item
                        { id = "tabInputs"
                        , link =
                            Tab.link []
                                [ text
                                    ("Inputs ("
                                        ++ toString
                                            (List.length
                                                (Dict.keys model.app.inputs)
                                            )
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
                                        ++ toString
                                            (List.length
                                                (Dict.keys model.app.parameters)
                                            )
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
                    ]
                |> Tab.view model.tabState
            ]



-- # Helpers


mkTh : String -> Html msg
mkTh label =
    th [ style [ ( "align", "right" ) ] ] [ text label ]


mkRowSelect : String -> AppParamType -> (String -> Msg) -> Html Msg
mkRowSelect label appType msg =
    let
        cur =
            paramTypeToString appType

        mkOption val =
            option [ value val, selected (val == cur) ] [ text val ]
    in
        tr []
            [ mkTh label
            , td []
                [ select
                    [ onInput msg ]
                    (List.map mkOption
                        [ "String", "Number", "Enum", "Boolean", "Flag" ]
                    )
                ]
            ]


mkRowTextEntry : String -> String -> (String -> Msg) -> Html Msg
mkRowTextEntry label defValue msg =
    tr []
        [ mkTh label
        , td []
            [ input
                [ type_ "text"
                , defaultValue defValue
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
                [ defaultValue defValue
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


paneJson : Model -> Html Msg
paneJson model =
    let
        err =
            case model.error of
                Nothing ->
                    div [] [ text "" ]

                Just e ->
                    div [ class "alert alert-danger" ]
                        [ text ("Error: " ++ e) ]
    in
        div []
            [ err
            , pre [] [ text (toString model.testapp) ]
            , textarea
                [ defaultValue (encodeApp model.app)
                , onInput UpdateIncomingJson
                , cols 100
                , rows 40
                ]
                []
            , button
                [ type_ "button"
                , onClick DecodeIncomingJson
                , class "btn btn-primary"
                ]
                [ text "Update App" ]
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
                    (toString app.defaultMemoryPerNode)
                    UpdateAppDefaultMemoryPerNode
                , mkRowTextEntry "Default Processors Per Node"
                    (toString app.defaultProcessorsPerNode)
                    UpdateAppDefaultProcessorsPerNode
                , mkRowTextEntry "Default Max Run Time"
                    app.defaultMaxRunTime
                    UpdateAppDefaultMaxRunTime
                , mkRowTextEntry "Default Node Count"
                    (toString app.defaultNodeCount)
                    UpdateAppDefaultNodeCount
                , mkRowTextEntry "Default Queue"
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
                , mkRowTextEntry "Execution Type"
                    app.executionType
                    UpdateAppExecutionType
                , mkRowRadioButtonGroup "Parallelism"
                    [ ( "Serial"
                      , app.parallelism == Serial
                      , UpdateAppParallelism Serial
                      )
                    , ( "Parallel"
                      , app.parallelism == Parallel
                      , UpdateAppParallelism Parallel
                      )
                    ]
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


showInputs : List AppInput -> Html msg
showInputs inputs =
    case List.length inputs of
        0 ->
            text "None"

        _ ->
            text "Not none"


paramTypeToString : AppParamType -> String
paramTypeToString paramType =
    case paramType of
        StringParam ->
            "String"

        NumberParam ->
            "Number"

        EnumerationParam ->
            "Enum"

        BoolParam ->
            "Boolean"

        FlagParam ->
            "Flag"


decoderApp : Decoder TestApp
decoderApp =
    decode TestApp
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
        |> Pipeline.required "modules" (Decode.list Decode.string)
        |> Pipeline.required "ontology" (Decode.list Decode.string)
        |> Pipeline.required "tags" (Decode.list Decode.string)
        |> Pipeline.required "parallelism" decoderParallelism
        |> Pipeline.required "inputs" (Decode.list decoderAppInput)


decoderParallelism =
    JD.string
        |> JD.andThen
            (\str ->
                case (String.toUpper str) of
                    "SERIAL" ->
                        JD.succeed Serial

                    "PARALLEL" ->
                        JD.succeed Parallel

                    _ ->
                        JD.fail <| "Unknown parallelism: " ++ str
            )


decoderAppInput : Decoder AppInput
decoderAppInput =
    decode AppInput
        |> Pipeline.hardcoded ""
        |> Pipeline.required "id" Decode.string
        |> custom (at [ "value", "default" ] Decode.string)
        |> custom (at [ "value", "order" ] Decode.int)
        |> custom (at [ "value", "validator" ] Decode.string)
        |> custom (at [ "value", "required" ] Decode.bool)
        |> custom (at [ "value", "visible" ] Decode.bool)
        |> custom (at [ "semantics", "minCardinality" ] Decode.int)
        |> custom (at [ "semantics", "maxCardinality" ] Decode.int)
        |> custom (at [ "semantics", "ontology" ] (Decode.list Decode.string))
        |> custom
            (at [ "semantics", "fileTypes" ]
                (Decode.list Decode.string)
            )
        |> custom (at [ "details", "description" ] Decode.string)
        |> custom (at [ "details", "label" ] Decode.string)
        |> custom (at [ "details", "argument" ] Decode.string)
        |> custom (at [ "details", "showArgument" ] Decode.bool)
        |> custom (at [ "details", "repeatArgument" ] Decode.bool)
        |> Pipeline.optionalAt [ "value", "enquote" ] Decode.bool False
        |> Pipeline.hardcoded Nothing


decodeIncomingJson : Model -> Model
decodeIncomingJson model =
    let
        ( app, err ) =
            case JD.decodeString decoderApp model.incomingJson of
                Ok a ->
                    ( a, Nothing )

                Err e ->
                    ( model.testapp, Just e )
    in
        { model | testapp = app, error = err }



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Tab.subscriptions model.tabState TabMsg
