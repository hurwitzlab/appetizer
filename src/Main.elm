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
    , inputs : Dict.Dict Int AppInput
    , parameters : List AppParam
    , showJson : Bool
    , error : Maybe String
    , tabState : Tab.State
    , editingInputId : Maybe Int
    }



-- Cf. http://developer.agaveapi.co/#inputs-and-parameters


type alias AppInput =
    { id : String
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
    , editingInputId = Nothing
    }


initialInput =
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
    , label = "INPUT"
    , argument = ""
    , repeatArgument = False
    , showArgument = True
    , enquoteValue = False
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



---- UPDATE ----


type Msg
    = AddInput
    | CloseJsonDialog
    | ShowInputDialog Int
    | ShowJsonDialog
    | TabMsg Tab.State
    | ToggleAvailable
    | ToggleCheckpointable
      -- | ToggleInputForm
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
        AddInput ->
            let
                newId =
                    case List.maximum (Dict.keys model.inputs) of
                        Nothing ->
                            1

                        Just n ->
                            n + 1

                insertInput =
                    { initialInput
                        | displayOrder =
                            List.length (Dict.keys model.inputs) + 1
                    }
            in
            ( { model
                | inputs = Dict.insert newId insertInput model.inputs
              }
            , Cmd.none
            )

        CloseJsonDialog ->
            ( { model | showJson = False }, Cmd.none )

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

        {--
        ToggleInputForm ->
            ( { model | editingInputId = Nothing }, Cmd.none )
            --}
        UpdateAppName val ->
            ( { model | appName = val }, Cmd.none )

        UpdateDefaultMaxRunTime val ->
            ( { model | defaultMaxRunTime = val }, Cmd.none )

        UpdateDefaultMemoryPerNode val ->
            let
                num =
                    case String.toInt val of
                        Ok n ->
                            n

                        Err _ ->
                            model.defaultMemoryPerNode
            in
            ( { model | defaultMemoryPerNode = num }, Cmd.none )

        UpdateDefaultNodeCount val ->
            let
                num =
                    case String.toInt val of
                        Ok n ->
                            n

                        Err _ ->
                            model.defaultNodeCount
            in
            ( { model | defaultNodeCount = num }, Cmd.none )

        UpdateDefaultProcessorsPerNode val ->
            let
                num =
                    case String.toInt val of
                        Ok n ->
                            n

                        Err _ ->
                            model.defaultProcessorsPerNode
            in
            ( { model | defaultProcessorsPerNode = num }, Cmd.none )

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


addInput model =
    model



---- VIEW ----


encodeApp : Model -> String
encodeApp model =
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
            ]
        )


viewInputs : Model -> Html Msg
viewInputs model =
    let
        id =
            case model.editingInputId of
                Just n ->
                    toString n

                _ ->
                    "Nada"
    in
    div [ class "form-group", style [ ( "text-align", "center" ) ] ]
        [ button
            [ type_ "button"
            , class "btn btn-default"
            , onClick AddInput
            ]
            [ text "Add Input" ]
        , text ("editing " ++ id)

        --, inputDialog model
        , inputTable model.inputs
        ]


inputDialog model =
    let
        currentInput =
            case model.editingInputId of
                Just id ->
                    case Dict.get id model.inputs of
                        Just inp ->
                            inp

                        _ ->
                            Nothing

                _ ->
                    Nothing

        mkTr name defaultVal =
            tr []
                [ th [] [ text name ]
                , td []
                    [ Html.input
                        [ type_ "text"
                        , defaultValue defaultVal
                        , class "form-control"
                        ]
                        []
                    ]
                ]

        body =
            case currentInput of
                Just input ->
                    tbl input

                _ ->
                    text "Something went wobbly"

        tbl input =
            Html.form []
                [ table []
                    [ mkTr "Id" input.id
                    , mkTr "Default Value" input.defaultValue
                    , mkTr "Display Order" (toString input.displayOrder)
                    , mkTr "Validator" input.validator
                    , mkTr "Required"
                        (if input.required then
                            "Yes"
                         else
                            "No"
                        )
                    , mkTr "Visible"
                        (if input.visible then
                            "Yes"
                         else
                            "No"
                        )
                    , mkTr "Ontology" (String.join ", " input.ontology)
                    , mkTr "Min Cardinality" (toString input.minCardinality)
                    , mkTr "Max Cardinality" (toString input.maxCardinality)
                    ]
                ]
    in
    Dialog.view
        (Just
            { closeMessage = Nothing
            , containerClass = Nothing
            , header = Just (text "Add Param")
            , body = Just body
            , footer =
                Just
                    (div
                        []
                        [ button
                            [ class "btn btn-primary"
                            , type_ "button"

                            --, onClick ToggleInputForm
                            ]
                            [ text "Close" ]
                        ]
                    )
            }
        )



-- inputTable : List Input -> Html Msg


inputTable inputs =
    let
        inputTr ( id, input ) =
            tr []
                [ td [] [ text input.id ]
                , td [] [ text (toString input.displayOrder) ]
                , td []
                    [ button
                        [ class "btn btn-default"
                        , onClick (ShowInputDialog id)
                        ]
                        [ text "Edit" ]
                    ]
                ]

        tbl =
            table []
                ([ tr []
                    [ th [] [ text "Id" ]
                    , th [] [ text "Order" ]
                    ]
                 ]
                    ++ List.map inputTr (Dict.toList inputs)
                )
    in
    case Dict.isEmpty inputs of
        True ->
            div [] [ text "No inputs" ]

        False ->
            tbl


view : Model -> Html Msg
view model =
    Grid.container []
        [ h1 [] [ text "The Appetizer" ]
        , Tab.config TabMsg
            |> Tab.withAnimation
            -- remember to wire up subscriptions when using this option
            |> Tab.right
            |> Tab.items
                [ Tab.item
                    { id = "tabMain"
                    , link = Tab.link [] [ text "Main" ]
                    , pane = Tab.pane [] [ br [] [], viewMain model ]
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
                    , pane = Tab.pane [] [ br [] [], viewInputs model ]
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


textEntry label defValue msg =
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


textArea label defValue msg =
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


checkbox label msg state =
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


radioButtonGroup label options =
    tr []
        [ mkTh label
        , td []
            [ fieldset [] (List.map radio options) ]
        ]


radio ( value, state, msg ) =
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


viewMain : Model -> Html Msg
viewMain model =
    div []
        [ Html.form []
            [ table []
                [ textEntry "Name" model.appName UpdateAppName
                , textEntry "Label" model.label UpdateLabel
                , textEntry "Version" model.version UpdateVersion
                , textEntry "Help URI" model.helpURI UpdateHelpURI
                , textArea "Short Description"
                    model.shortDescription
                    UpdateShortDescription
                , textArea "Long Description"
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
                [ checkbox "Available" ToggleAvailable model.available
                , checkbox "Checkpointable" ToggleCheckpointable model.checkpointable
                , textEntry "Default Memory Per Node"
                    (toString model.defaultMemoryPerNode)
                    UpdateDefaultMemoryPerNode
                , textEntry "Default Processors Per Node"
                    (toString model.defaultProcessorsPerNode)
                    UpdateDefaultProcessorsPerNode
                , textEntry "Default Max Run Time"
                    model.defaultMaxRunTime
                    UpdateDefaultMaxRunTime
                , textEntry "Default Node Count"
                    (toString model.defaultNodeCount)
                    UpdateDefaultNodeCount
                , textEntry "Default Queue"
                    model.defaultQueue
                    UpdateDefaultQueue
                , textEntry "Deployment Path"
                    model.deploymentPath
                    UpdateDeploymentPath
                , textEntry "Deployment System"
                    model.deploymentSystem
                    UpdateDeploymentSystem
                , textEntry "Execution System"
                    model.executionSystem
                    UpdateExecutionSystem
                , textEntry "Execution Type"
                    model.executionType
                    UpdateExecutionType
                , radioButtonGroup "Parallelism"
                    [ ( "Serial"
                      , model.parallelism == Serial
                      , UpdateParallelism Serial
                      )
                    , ( "Parallel"
                      , model.parallelism == Parallel
                      , UpdateParallelism Parallel
                      )
                    ]
                , textEntry "Template Path"
                    model.templatePath
                    UpdateTemplatePath
                , textEntry "Test Path" model.testPath UpdateTestPath
                , textEntry "Modules"
                    (String.join ", " model.modules)
                    UpdateModules
                , textEntry "Tags"
                    (String.join ", " model.tags)
                    UpdateTags
                , textEntry "Ontology"
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
