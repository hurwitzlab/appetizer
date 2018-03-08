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


type alias AppInput =
    { id : String
    }


type alias AppParam =
    { id : String
    }


initialModel =
    { appName = "my_new_app"
    , label = "My New App"
    , version = "0.0.1"
    , shortDescription = ""
    , longDescription = ""
    , available = True
    , checkpointable = False
    , defaultMemoryPerNode = 32
    , defaultProcessorsPerNode = 16
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
            , ( "defaultProcessorsPerNode", JE.int model.defaultProcessorsPerNode )
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


viewJson model =
    let
        json =
            if model.showJson then
                encodeApp model
            else
                ""

        prompt =
            if model.showJson then
                "Hide"
            else
                "Show"

        dialog =
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
                                (div [ style [ ( "overflow-y", "auto" ), ( "max-height", "60vh" ) ] ]
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
    in
    div []
        [ div []
            [ button
                [ type_ "button"
                , class "btn btn-primary"
                , onClick ShowJsonDialog
                ]
                [ text "Show JSON" ]
            ]
        , dialog
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

        form =
            Dialog.view
                (if model.showInputForm then
                    Just
                        { closeMessage = Nothing
                        , containerClass = Nothing
                        , header = Just (text "Alert!")
                        , body = Just (p [] [ text "Let me tell you something important..." ])
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
    in
    div [ class "form-group" ]
        [ text ("Inputs (" ++ toString numInputs ++ ")")
        , button
            [ type_ "button"
            , class "btn btn-default"
            , onClick ToggleInputForm
            ]
            [ text "Add Input" ]
        , form
        , text inputs
        ]


view : Model -> Html Msg
view model =
    let
        errorMsg =
            case model.error of
                Just err ->
                    "Error: " ++ err

                _ ->
                    ""
    in
    div []
        [ h1 [] [ text "Appetizer" ]
        , div [] [ text errorMsg ]
        , div [] [ text (toString model) ]
        , Html.form []
            [ div [ class "form-group", onInput UpdateAppName ]
                [ Html.label [] [ text "App Name" ]
                , Html.input
                    [ type_ "text"
                    , name "appName"
                    , defaultValue model.appName
                    , class "form-control"
                    ]
                    []
                ]
            , div
                [ class "form-group"
                , onInput UpdateLabel
                ]
                [ Html.label [] [ text "Label" ]
                , Html.input
                    [ type_ "text"
                    , name "label"
                    , defaultValue model.label
                    , class "form-control"
                    ]
                    []
                ]
            , div [ class "form-group", onInput UpdateVersion ]
                [ Html.label [] [ text "Version" ]
                , Html.input
                    [ type_ "text"
                    , name "version"
                    , defaultValue model.version
                    , class "form-control"
                    ]
                    []
                ]
            , div
                [ class "form-group"
                , onInput UpdateShortDescription
                ]
                [ Html.label [] [ text "Short Description" ]
                , Html.input
                    [ type_ "text"
                    , name "label"
                    , defaultValue model.shortDescription
                    , class "form-control"
                    ]
                    []
                ]
            , div
                [ class "form-group"
                , onInput UpdateLongDescription
                ]
                [ Html.label [] [ text "Long Description" ]
                , Html.input
                    [ type_ "text"
                    , name "label"
                    , defaultValue model.longDescription
                    , class "form-control"
                    ]
                    []
                ]
            , div [ class "form-group" ]
                [ Html.label [] [ text "Available" ]
                , checkbox ToggleAvailable model.available
                ]
            , div [ class "form-group" ]
                [ Html.label [] [ text "Checkpointable" ]
                , checkbox ToggleCheckpointable model.checkpointable
                ]
            , div
                [ class "form-group"
                , onInput UpdateDefaultMemoryPerNode
                ]
                [ Html.label [] [ text "Default Memory Per Node" ]
                , Html.input
                    [ type_ "text"
                    , name "defaultMemoryPerNode"
                    , defaultValue (toString model.defaultMemoryPerNode)
                    , class "form-control"
                    ]
                    []
                ]
            , div
                [ class "form-group"
                , onInput UpdateDefaultProcessorsPerNode
                ]
                [ Html.label [] [ text "Default Processors Per Node" ]
                , Html.input
                    [ type_ "text"
                    , name "defaultProcessorsPerNode"
                    , defaultValue (toString model.defaultProcessorsPerNode)
                    , class "form-control"
                    ]
                    []
                ]
            , div
                [ class "form-group"
                , onInput UpdateDefaultMaxRunTime
                ]
                [ Html.label [] [ text "Default Max Run Time" ]
                , Html.input
                    [ type_ "text"
                    , name "defaultMaxRunTime"
                    , defaultValue model.defaultMaxRunTime
                    , class "form-control"
                    ]
                    []
                ]
            , div
                [ class "form-group"
                , onInput UpdateDefaultNodeCount
                ]
                [ Html.label [] [ text "Default Node Count" ]
                , Html.input
                    [ type_ "text"
                    , name "defaultNodeCount"
                    , defaultValue (toString model.defaultNodeCount)
                    , class "form-control"
                    ]
                    []
                ]
            , div
                [ class "form-group"
                , onInput UpdateDefaultQueue
                ]
                [ Html.label [] [ text "Default Queue" ]
                , Html.input
                    [ type_ "text"
                    , name "defaultQueue"
                    , defaultValue model.defaultQueue
                    , class "form-control"
                    ]
                    []
                ]
            , div
                [ class "form-group"
                , onInput UpdateDeploymentPath
                ]
                [ Html.label [] [ text "Deployment Path" ]
                , Html.input
                    [ type_ "text"
                    , name "defaultQueue"
                    , defaultValue model.deploymentPath
                    , class "form-control"
                    ]
                    []
                ]
            , div
                [ class "form-group"
                , onInput UpdateDeploymentSystem
                ]
                [ Html.label [] [ text "Deployment System" ]
                , Html.input
                    [ type_ "text"
                    , name "deploymentSystem"
                    , defaultValue model.deploymentSystem
                    , class "form-control"
                    ]
                    []
                ]
            , div
                [ class "form-group"
                , onInput UpdateExecutionSystem
                ]
                [ Html.label [] [ text "Execution System" ]
                , Html.input
                    [ type_ "text"
                    , name "executionSystem"
                    , defaultValue model.executionSystem
                    , class "form-control"
                    ]
                    []
                ]
            , div
                [ class "form-group"
                , onInput UpdateExecutionType
                ]
                [ Html.label [] [ text "Execution Type" ]
                , Html.input
                    [ type_ "text"
                    , name "executionType"
                    , defaultValue model.executionType
                    , class "form-control"
                    ]
                    []
                ]
            , div
                [ class "form-group"
                , onInput UpdateHelpURI
                ]
                [ Html.label [] [ text "Help URI" ]
                , Html.input
                    [ type_ "text"
                    , name "helpURI"
                    , defaultValue model.helpURI
                    , class "form-control"
                    ]
                    []
                ]
            , div
                [ class "form-group"
                , onInput UpdateParallelism
                ]
                [ Html.label [] [ text "Parallelism" ]
                , Html.input
                    [ type_ "text"
                    , name "parallelism"
                    , defaultValue model.parallelism
                    , class "form-control"
                    ]
                    []
                ]
            , div
                [ class "form-group"
                , onInput UpdateTemplatePath
                ]
                [ Html.label [] [ text "Template Path" ]
                , Html.input
                    [ type_ "text"
                    , name "templatePath"
                    , defaultValue model.templatePath
                    , class "form-control"
                    ]
                    []
                ]
            , div
                [ class "form-group"
                , onInput UpdateTestPath
                ]
                [ Html.label [] [ text "Test Path" ]
                , Html.input
                    [ type_ "text"
                    , name "testPath"
                    , defaultValue model.testPath
                    , class "form-control"
                    ]
                    []
                ]
            , div
                [ class "form-group"
                , onInput UpdateModules
                ]
                [ Html.label [] [ text "Modules" ]
                , Html.input
                    [ type_ "text"
                    , name "modules"
                    , defaultValue (String.join ", " model.modules)
                    , class "form-control"
                    ]
                    []
                ]
            , div
                [ class "form-group"
                , onInput UpdateTags
                ]
                [ Html.label [] [ text "Tags" ]
                , Html.input
                    [ type_ "text"
                    , name "modules"
                    , defaultValue (String.join ", " model.tags)
                    , class "form-control"
                    ]
                    []
                ]
            , div
                [ class "form-group"
                , onInput UpdateOntology
                ]
                [ Html.label [] [ text "Ontology" ]
                , Html.input
                    [ type_ "text"
                    , name "ontology"
                    , defaultValue (String.join ", " model.ontology)
                    , class "form-control"
                    ]
                    []
                ]
            , div [ class "form-group" ]
                [ Html.label []
                    [ text
                        ("Inputs ("
                            ++ toString (List.length model.inputs)
                            ++ ")"
                        )
                    ]
                ]
            , viewInputs model
            ]
        , viewJson model
        ]


showInputs : List AppInput -> Html msg
showInputs inputs =
    case List.length inputs of
        0 ->
            text "None"

        _ ->
            text "Not none"


checkbox : msg -> Bool -> Html msg
checkbox msg state =
    Html.input
        [ type_ "checkbox"
        , onClick msg
        , checked state
        , class "form-control"
        ]
        []



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
