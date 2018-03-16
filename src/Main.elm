module Main exposing (..)

import Bootstrap.Grid as Grid
import Bootstrap.Tab as Tab
import Dialog
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode as JE
import List.Extra exposing (zip)


---- MODEL ----


type alias Model =
    { appName : String
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
    , helpURI : String
    , label : String
    , longDescription : String
    , modules : List String
    , ontology : List String
    , parallelism : Parallelism
    , shortDescription : String
    , tags : List String
    , templatePath : String
    , testPath : String
    , inputs : Dict.Dict String AppInput
    , parameters : List AppParam
    , showJson : Bool
    , error : Maybe String
    , tabState : Tab.State
    , inputToModify : Maybe AppInput
    , editingInputId : Maybe Int
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
    , ontology : List String
    , minCardinality : Int
    , maxCardinality : Int
    , fileTypes : List String
    , description : String
    , label : String
    , argument : String
    , repeatArgument : Bool
    , showArgument : Bool
    , enquoteValue : Bool
    , error : Maybe String
    }


type alias AppParam =
    { id : String
    , default_value : String
    , value_type : AppParamType
    , display_order : Int
    , required : Bool
    , validator : String
    , visible : Bool
    , description : String
    , label : String
    , argument : String
    , showArgument : Bool
    , enquoteValue : Bool
    , minCardinality : Int
    , maxCardinality : Int
    , enumValues : Maybe List EnumParamValue
    }


type alias EnumParamValue =
    { param_key : String
    , param_value : String
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
    { appName = "my_new_app"
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
    , helpURI = "http://google.com"
    , parallelism = Serial
    , modules = [ "tacc-singularity", "launcher" ]
    , ontology = [ "http://sswapmeet.sswap.info/agave/apps/Application" ]
    , tags = [ "imicrobe" ]
    , testPath = "test.sh"
    , templatePath = "template.sh"
    , inputs = Dict.empty
    , parameters = []
    , showJson = False
    , error = Nothing
    , tabState = Tab.initialState
    , inputToModify = Nothing
    , editingInputId = Nothing
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
    , repeatArgument = False
    , showArgument = True
    , enquoteValue = False
    , error = Nothing
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp String
    | CloseJsonDialog
    | CloseAppInputDialog
    | CloseModifyAppInputDialog
    | ShowInputDialog Int
    | ShowJsonDialog
    | TabMsg Tab.State
    | OpenModifyAppInputDialog AppInput
    | SaveAppInput
    | SetAppInputToModify String
    | ToggleAvailable
    | ToggleCheckpointable
    | UpdateAppInputArgument String
    | UpdateAppInputDefaultValue String
    | UpdateAppInputDescription String
    | UpdateAppInputDisplayOrder String
    | UpdateAppInputFileTypes String
    | UpdateAppInputId String
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
    | UpdateAppName String
    | UpdateDefaultMaxRunTime String
    | UpdateDefaultMemoryPerNode String
    | UpdateDefaultNodeCount String
    | UpdateDefaultProcessorsPerNode String
    | UpdateDefaultQueue String
    | UpdateDeploymentPath String
    | UpdateDeploymentSystem String
    | UpdateExecutionSystem String
    | UpdateExecutionType String
    | UpdateHelpURI String
    | UpdateLabel String
    | UpdateLongDescription String
    | UpdateModules String
    | UpdateOntology String
    | UpdateParallelism Parallelism
    | UpdateShortDescription String
    | UpdateTags String
    | UpdateTemplatePath String
    | UpdateTestPath String
    | UpdateVersion String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp val ->
            ( model, Cmd.none )

        CloseAppInputDialog ->
            ( { model | inputToModify = Nothing }, Cmd.none )

        CloseJsonDialog ->
            ( { model | showJson = False }, Cmd.none )

        CloseModifyAppInputDialog ->
            ( { model | inputToModify = Nothing }, Cmd.none )

        OpenModifyAppInputDialog input ->
            ( { model
                | inputToModify = Just { input | originalInputId = input.id }
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
                                (Dict.remove input.originalInputId model.inputs)

                        _ ->
                            model.inputs
            in
            ( { model | inputs = newInputs, inputToModify = Nothing }
            , Cmd.none
            )

        SetAppInputToModify id ->
            let
                newInput =
                    case Dict.get id model.inputs of
                        Just input ->
                            Just { input | originalInputId = input.id }

                        _ ->
                            Nothing
            in
            ( { model | inputToModify = newInput }
            , Cmd.none
            )

        ShowInputDialog inputId ->
            -- Should I bother to check that inputNum is in the range of inputs?
            ( { model | editingInputId = Just inputId }, Cmd.none )

        ShowJsonDialog ->
            ( { model | showJson = True }, Cmd.none )

        TabMsg state ->
            ( { model | tabState = state }
            , Cmd.none
            )

        ToggleAvailable ->
            ( { model | available = not model.available }, Cmd.none )

        ToggleCheckpointable ->
            ( { model | checkpointable = not model.checkpointable }, Cmd.none )

        UpdateAppInputArgument val ->
            let
                newInput =
                    case model.inputToModify of
                        Just input ->
                            Just { input | argument = val }

                        _ ->
                            Nothing
            in
            ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppInputDefaultValue val ->
            let
                newInput =
                    case model.inputToModify of
                        Just input ->
                            Just { input | defaultValue = val }

                        _ ->
                            Nothing
            in
            ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppInputDescription val ->
            let
                newInput =
                    case model.inputToModify of
                        Just input ->
                            Just { input | description = val }

                        _ ->
                            Nothing
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
                    case model.inputToModify of
                        Just input ->
                            Just { input | fileTypes = newFileTypes }

                        _ ->
                            Nothing
            in
            ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppInputId val ->
            let
                newInput =
                    case model.inputToModify of
                        Just input ->
                            Just { input | id = val }

                        _ ->
                            Nothing
            in
            ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppInputLabel val ->
            let
                newInput =
                    case model.inputToModify of
                        Just input ->
                            Just { input | label = val }

                        _ ->
                            Nothing
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
                    case model.inputToModify of
                        Just input ->
                            Just
                                { input
                                    | enquoteValue = not input.enquoteValue
                                }

                        _ ->
                            Nothing
            in
            ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppInputToggleRepeatArgument ->
            let
                newInput =
                    case model.inputToModify of
                        Just input ->
                            Just
                                { input
                                    | repeatArgument = not input.repeatArgument
                                }

                        _ ->
                            Nothing
            in
            ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppInputToggleRequired ->
            let
                newInput =
                    case model.inputToModify of
                        Just input ->
                            Just { input | required = not input.required }

                        _ ->
                            Nothing
            in
            ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppInputToggleShowArgument ->
            let
                newInput =
                    case model.inputToModify of
                        Just input ->
                            Just
                                { input
                                    | showArgument = not input.showArgument
                                }

                        _ ->
                            Nothing
            in
            ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppInputToggleVisible ->
            let
                newInput =
                    case model.inputToModify of
                        Just input ->
                            Just { input | visible = not input.visible }

                        _ ->
                            Nothing
            in
            ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppInputValidator val ->
            let
                newInput =
                    case model.inputToModify of
                        Just input ->
                            Just { input | validator = val }

                        _ ->
                            Nothing
            in
            ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppInputOntology val ->
            let
                newOntology =
                    List.map String.trim (String.split "," val)

                newInput =
                    case model.inputToModify of
                        Just input ->
                            Just { input | ontology = newOntology }

                        _ ->
                            Nothing
            in
            ( { model | inputToModify = newInput }, Cmd.none )

        UpdateAppName val ->
            ( { model | appName = val }, Cmd.none )

        UpdateDefaultMaxRunTime val ->
            ( { model | defaultMaxRunTime = val }, Cmd.none )

        UpdateDefaultMemoryPerNode val ->
            let
                ( num, err ) =
                    case String.toInt val of
                        Ok n ->
                            ( n, Nothing )

                        Err _ ->
                            ( model.defaultMemoryPerNode
                            , Just
                                ("Default Mem Per Node ("
                                    ++ val
                                    ++ ") not a number"
                                )
                            )
            in
            ( { model | defaultMemoryPerNode = num, error = err }, Cmd.none )

        UpdateDefaultNodeCount val ->
            let
                ( num, err ) =
                    case String.toInt val of
                        Ok n ->
                            ( n, Nothing )

                        Err _ ->
                            ( model.defaultNodeCount
                            , Just
                                ("Default Node Count ("
                                    ++ val
                                    ++ ") not a number"
                                )
                            )
            in
            ( { model | defaultNodeCount = num, error = err }, Cmd.none )

        UpdateDefaultProcessorsPerNode val ->
            let
                ( num, err ) =
                    case String.toInt val of
                        Ok n ->
                            ( n, Nothing )

                        Err _ ->
                            ( model.defaultProcessorsPerNode
                            , Just
                                ("Default Processors Per Node ("
                                    ++ val
                                    ++ ") not a number"
                                )
                            )
            in
            ( { model | defaultProcessorsPerNode = num, error = err }
            , Cmd.none
            )

        UpdateDefaultQueue val ->
            ( { model | defaultQueue = val }, Cmd.none )

        UpdateDeploymentPath val ->
            ( { model | deploymentPath = val }, Cmd.none )

        UpdateDeploymentSystem val ->
            ( { model | deploymentSystem = val }, Cmd.none )

        UpdateExecutionSystem val ->
            ( { model | executionSystem = val }, Cmd.none )

        UpdateExecutionType val ->
            ( { model | executionType = val }, Cmd.none )

        UpdateHelpURI val ->
            ( { model | helpURI = val }, Cmd.none )

        UpdateLabel val ->
            ( { model | label = val }, Cmd.none )

        UpdateLongDescription val ->
            ( { model | longDescription = val }, Cmd.none )

        UpdateModules val ->
            ( { model
                | modules = List.map String.trim (String.split "," val)
              }
            , Cmd.none
            )

        UpdateOntology val ->
            ( { model
                | ontology = List.map String.trim (String.split "," val)
              }
            , Cmd.none
            )

        UpdateParallelism val ->
            ( { model | parallelism = val }, Cmd.none )

        UpdateShortDescription val ->
            ( { model | shortDescription = val }, Cmd.none )

        UpdateTags val ->
            ( { model
                | tags = List.map String.trim (String.split "," val)
              }
            , Cmd.none
            )

        UpdateTemplatePath val ->
            ( { model | templatePath = val }, Cmd.none )

        UpdateTestPath val ->
            ( { model | testPath = val }, Cmd.none )

        UpdateVersion val ->
            ( { model | version = val }, Cmd.none )



---- VIEW ----


encodeApp : Model -> String
encodeApp model =
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
    in
    JE.encode 4
        (JE.object
            [ ( "name", JE.string model.appName )
            , ( "version", JE.string model.version )
            , ( "shortDescription", JE.string model.shortDescription )
            , ( "longDescription", JE.string model.longDescription )
            , ( "available", JE.bool model.available )
            , ( "checkpointable", JE.bool model.checkpointable )
            , ( "defaultMemoryPerNode", JE.int model.defaultMemoryPerNode )
            , ( "defaultProcessorsPerNode"
              , JE.int model.defaultProcessorsPerNode
              )
            , ( "defaultMaxRunTime", JE.string model.defaultMaxRunTime )
            , ( "defaultNodeCount", JE.int model.defaultNodeCount )
            , ( "defaultQueue", JE.string model.defaultQueue )
            , ( "deploymentPath", JE.string model.deploymentPath )
            , ( "deploymentSystem", JE.string model.deploymentSystem )
            , ( "executionSystem", JE.string model.executionSystem )
            , ( "executionType", JE.string model.executionType )
            , ( "helpURI", JE.string model.helpURI )
            , ( "label", JE.string model.label )
            , ( "parallelism"
              , JE.string
                    (if model.parallelism == Serial then
                        "SERIAL"
                     else
                        "PARALLEL"
                    )
              )
            , ( "templatePath", JE.string model.templatePath )
            , ( "testPath", JE.string model.testPath )
            , ( "modules", JE.list (List.map JE.string model.modules) )
            , ( "tags", JE.list (List.map JE.string model.tags) )
            , ( "ontology", JE.list (List.map JE.string model.ontology) )
            , ( "inputs"
              , JE.list
                    (List.map encodeInput
                        (List.sortBy .displayOrder (Dict.values model.inputs))
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
                    (Dict.values model.inputs)
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
        , appInputTable model.inputs
        ]


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
                            , mkRowCheckbox "Required"
                                appInput.required
                                UpdateAppInputToggleRequired
                            , mkRowCheckbox
                                "Visible"
                                appInput.visible
                                UpdateAppInputToggleVisible
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


appInputTable : Dict.Dict String AppInput -> Html Msg
appInputTable inputs =
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


view : Model -> Html Msg
view model =
    let
        err =
            case model.error of
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
                    , pane = Tab.pane [] [ br [] [], paneMain model ]
                    }
                , Tab.item
                    { id = "tabInputs"
                    , link =
                        Tab.link []
                            [ text
                                ("Inputs ("
                                    ++ toString
                                        (List.length
                                            (Dict.keys model.inputs)
                                        )
                                    ++ ")"
                                )
                            ]
                    , pane = Tab.pane [] [ br [] [], paneInputs model ]
                    }
                , Tab.item
                    { id = "tabParams"
                    , link =
                        Tab.link []
                            [ text
                                ("Parameters ("
                                    ++ toString (List.length model.parameters)
                                    ++ ")"
                                )
                            ]
                    , pane = Tab.pane [] [ br [] [], text "Params" ]
                    }
                , Tab.item
                    { id = "tabAdvanced"
                    , link = Tab.link [] [ text "Advanced" ]
                    , pane = Tab.pane [] [ br [] [], viewAdvanced model ]
                    }
                , Tab.item
                    { id = "tabJson"
                    , link = Tab.link [] [ text "JSON" ]
                    , pane =
                        Tab.pane []
                            [ br [] []
                            , pre [] [ text (encodeApp model) ]
                            ]
                    }
                ]
            |> Tab.view model.tabState
        ]



-- # Helpers


mkTh label =
    th [ style [ ( "align", "right" ) ] ] [ text label ]


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


mkRowRadioButtonGroup label options =
    tr []
        [ mkTh label
        , td []
            [ fieldset [] (List.map mkRadio options) ]
        ]


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


paneMain : Model -> Html Msg
paneMain model =
    div []
        [ Html.form []
            [ table []
                [ mkRowTextEntry "Name" model.appName UpdateAppName
                , mkRowTextEntry "Label" model.label UpdateLabel
                , mkRowTextEntry "Version" model.version UpdateVersion
                , mkRowTextEntry "Help URI" model.helpURI UpdateHelpURI
                , mkRowTextArea "Short Description"
                    model.shortDescription
                    UpdateShortDescription
                , mkRowTextArea "Long Description"
                    model.longDescription
                    UpdateLongDescription
                ]
            ]
        ]


viewAdvanced : Model -> Html Msg
viewAdvanced model =
    div []
        [ Html.form []
            [ table []
                [ mkRowCheckbox "Available"
                    model.available
                    ToggleAvailable
                , mkRowCheckbox "Checkpointable"
                    model.checkpointable
                    ToggleCheckpointable
                , mkRowTextEntry "Default Memory Per Node"
                    (toString model.defaultMemoryPerNode)
                    UpdateDefaultMemoryPerNode
                , mkRowTextEntry "Default Processors Per Node"
                    (toString model.defaultProcessorsPerNode)
                    UpdateDefaultProcessorsPerNode
                , mkRowTextEntry "Default Max Run Time"
                    model.defaultMaxRunTime
                    UpdateDefaultMaxRunTime
                , mkRowTextEntry "Default Node Count"
                    (toString model.defaultNodeCount)
                    UpdateDefaultNodeCount
                , mkRowTextEntry "Default Queue"
                    model.defaultQueue
                    UpdateDefaultQueue
                , mkRowTextEntry "Deployment Path"
                    model.deploymentPath
                    UpdateDeploymentPath
                , mkRowTextEntry "Deployment System"
                    model.deploymentSystem
                    UpdateDeploymentSystem
                , mkRowTextEntry "Execution System"
                    model.executionSystem
                    UpdateExecutionSystem
                , mkRowTextEntry "Execution Type"
                    model.executionType
                    UpdateExecutionType
                , mkRowRadioButtonGroup "Parallelism"
                    [ ( "Serial"
                      , model.parallelism == Serial
                      , UpdateParallelism Serial
                      )
                    , ( "Parallel"
                      , model.parallelism == Parallel
                      , UpdateParallelism Parallel
                      )
                    ]
                , mkRowTextEntry "Template Path"
                    model.templatePath
                    UpdateTemplatePath
                , mkRowTextEntry "Test Path" model.testPath UpdateTestPath
                , mkRowTextEntry "Modules"
                    (String.join ", " model.modules)
                    UpdateModules
                , mkRowTextEntry "Tags"
                    (String.join ", " model.tags)
                    UpdateTags
                , mkRowTextEntry "Ontology"
                    (String.join ", " model.ontology)
                    UpdateOntology
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
