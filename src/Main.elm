module Main exposing (..)

import Dialog
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode as JE


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
    , parallelism : String
    , shortDescription : String
    , tags : List String
    , templatePath : String
    , testPath : String
    , inputs : List AppInput
    , parameters : List AppParam
    , showJson : Bool
    , showInputForm : Bool
    , error : Maybe String
    }



-- Cf. http://developer.agaveapi.co/#inputs-and-parameters


type alias AppInput =
    { id : String
    , default_value : String
    , display_order : Int
    , value_validator : String
    , required : Bool
    , visible : Bool
    , ontology : Bool
    , minCardinality : Int
    , maxCardinality : Int
    , fileTypes : List String
    , description : String
    , label : String
    , argument : String
    , repeatArgument : Bool
    , showArgument : Bool
    , enquote_value : Bool
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
    , enquote_value : Bool
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
    , parallelism = "SERIAL"
    , modules = [ "tacc-singularity", "launcher" ]
    , ontology = [ "http://sswapmeet.sswap.info/agave/apps/Application" ]
    , tags = [ "imicrobe" ]
    , testPath = "test.sh"
    , templatePath = "template.sh"
    , inputs = []
    , parameters = []
    , showJson = False
    , showInputForm = False
    , error = Nothing
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



---- UPDATE ----


type Msg
    = CloseJsonDialog
    | ShowJsonDialog
    | ToggleInputForm
    | ToggleAvailable
    | ToggleCheckpointable
    | UpdateAppName String
    | UpdateLabel String
    | UpdateVersion String
    | UpdateShortDescription String
    | UpdateLongDescription String
    | UpdateDefaultMemoryPerNode String
    | UpdateDefaultProcessorsPerNode String
    | UpdateDefaultMaxRunTime String
    | UpdateDefaultNodeCount String
    | UpdateDefaultQueue String
    | UpdateDeploymentPath String
    | UpdateDeploymentSystem String
    | UpdateExecutionSystem String
    | UpdateExecutionType String
    | UpdateHelpURI String
    | UpdateParallelism String
    | UpdateModules String
    | UpdateOntology String
    | UpdateTags String
    | UpdateTestPath String
    | UpdateTemplatePath String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CloseJsonDialog ->
            ( { model | showJson = False }, Cmd.none )

        ShowJsonDialog ->
            ( { model | showJson = True }, Cmd.none )

        ToggleInputForm ->
            ( { model | showInputForm = not model.showInputForm }, Cmd.none )

        ToggleAvailable ->
            ( { model | available = not model.available }, Cmd.none )

        ToggleCheckpointable ->
            ( { model | checkpointable = not model.checkpointable }, Cmd.none )

        UpdateAppName val ->
            ( { model | appName = val }, Cmd.none )

        UpdateLabel val ->
            ( { model | label = val }, Cmd.none )

        UpdateVersion val ->
            ( { model | version = val }, Cmd.none )

        UpdateShortDescription val ->
            ( { model | shortDescription = val }, Cmd.none )

        UpdateLongDescription val ->
            ( { model | longDescription = val }, Cmd.none )

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

        UpdateParallelism val ->
            ( { model | parallelism = val }, Cmd.none )

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

        UpdateTags val ->
            ( { model
                | tags = List.map String.trim (String.split "," val)
              }
            , Cmd.none
            )

        UpdateTestPath val ->
            ( { model | testPath = val }, Cmd.none )

        UpdateTemplatePath val ->
            ( { model | templatePath = val }, Cmd.none )


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
            , ( "parallelism", JE.string model.parallelism )
            , ( "templatePath", JE.string model.templatePath )
            , ( "testPath", JE.string model.testPath )
            , ( "modules", JE.list (List.map JE.string model.modules) )
            , ( "tags", JE.list (List.map JE.string model.tags) )
            , ( "ontology", JE.list (List.map JE.string model.ontology) )
            ]
        )


viewJsonDialog model =
    let
        json =
            encodeApp model
    in
    Dialog.view
        (if model.showJson then
            Just
                { closeMessage = Nothing
                , containerClass = Nothing
                , header =
                    Just
                        (text
                            (model.appName
                                ++ "-"
                                ++ model.version
                            )
                        )
                , body =
                    Just
                        (div
                            [ style
                                [ ( "overflow-y", "auto" )
                                , ( "max-height", "60vh" )
                                ]
                            ]
                            [ pre [] [ text json ] ]
                        )
                , footer =
                    Just
                        (button
                            [ class "btn btn-default"
                            , type_ "button"
                            , onClick CloseJsonDialog
                            ]
                            [ text "OK" ]
                        )
                }
         else
            Nothing
        )


viewJson model =
    div []
        [ div []
            [ button
                [ type_ "button"
                , class "btn btn-primary"
                , onClick ShowJsonDialog
                ]
                [ text "Show JSON" ]
            ]
        , viewJsonDialog model
        ]


viewInputs model =
    let
        numInputs =
            List.length model.inputs

        inputs =
            if numInputs == 0 then
                ""
            else
                "Some"
    in
    div [ class "form-group" ]
        [ text ("Inputs (" ++ toString numInputs ++ ")")
        , button
            [ type_ "button"
            , class "btn btn-default"
            , onClick ToggleInputForm
            ]
            [ text "Add Input" ]
        , inputDialog model
        , text inputs
        ]


inputDialog model =
    let
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

        tbl =
            table []
                [ mkTr "Name" ""
                , mkTr "Value" ""
                , mkTr "Display Order" "1"
                , mkTr "Validator" ""
                ]
    in
    Dialog.view
        (if model.showInputForm then
            Just
                { closeMessage = Nothing
                , containerClass = Nothing
                , header = Just (text "Add Param")
                , body = Just tbl
                , footer =
                    Just
                        (div
                            []
                            [ button
                                [ class "btn btn-primary"
                                , type_ "button"
                                , onClick ToggleInputForm
                                ]
                                [ text "Add" ]
                            , button
                                [ class "btn btn-default"
                                , type_ "button"
                                , onClick ToggleInputForm
                                ]
                                [ text "Cancel" ]
                            ]
                        )
                }
         else
            Nothing
        )


view : Model -> Html Msg
view model =
    let
        errorMsg =
            case model.error of
                Just err ->
                    "Error: " ++ err

                _ ->
                    ""

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
    in
    div []
        [ h1 [] [ text "Appetizer" ]
        , viewJson model
        , div [] [ text errorMsg ]
        , Html.form []
            [ table []
                [ textEntry "Name" model.appName UpdateAppName
                , textEntry "Label" model.label UpdateLabel
                , textEntry "Version" model.version UpdateVersion
                , textEntry "Short Description" model.shortDescription UpdateShortDescription
                , textEntry "Long Description" model.longDescription UpdateLongDescription
                , checkbox "Available" ToggleAvailable model.available
                , checkbox "Checkpointable" ToggleCheckpointable model.checkpointable
                , textEntry "Default Memory Per Node" (toString model.defaultMemoryPerNode) UpdateDefaultMemoryPerNode
                , textEntry "Default Processors Per Node" (toString model.defaultProcessorsPerNode) UpdateDefaultProcessorsPerNode
                , textEntry "Default Max Run Time" model.defaultMaxRunTime UpdateDefaultMaxRunTime
                , textEntry "Default Node Count" (toString model.defaultNodeCount) UpdateDefaultNodeCount
                , textEntry "Default Queue" model.defaultQueue UpdateDefaultQueue
                , textEntry "Deployment Path" model.deploymentPath UpdateDeploymentPath
                , textEntry "Deployment System" model.deploymentSystem UpdateDeploymentSystem
                , textEntry "Execution System" model.executionSystem UpdateExecutionSystem
                , textEntry "Execution Type" model.executionType UpdateExecutionType
                , textEntry "Help URI" model.helpURI UpdateHelpURI
                , textEntry "Parallelism" model.parallelism UpdateParallelism
                , textEntry "Template Path" model.templatePath UpdateTemplatePath
                , textEntry "Test Path" model.testPath UpdateTestPath
                , textEntry "Modules" (String.join ", " model.modules) UpdateModules
                , textEntry "Tags" (String.join ", " model.tags) UpdateTags
                , textEntry "Ontology" (String.join ", " model.ontology) UpdateOntology
                ]
            ]
        , viewInputs model
        ]



{--
            ]
        ]
        --}


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
        , subscriptions = always Sub.none
        }
