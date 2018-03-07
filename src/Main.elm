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
    | UpdateApp String String
    | ToggleAvailable
    | ToggleCheckpointable


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CloseJsonDialog ->
            ( { model | showJson = False }, Cmd.none )

        ShowJsonDialog ->
            ( { model | showJson = True }, Cmd.none )

        ToggleInputForm ->
            ( { model | showInputForm = not model.showInputForm }, Cmd.none )

        UpdateApp fldName newValue ->
            ( updateApp model fldName newValue, Cmd.none )

        ToggleAvailable ->
            ( { model | available = not model.available }, Cmd.none )

        ToggleCheckpointable ->
            ( { model | checkpointable = not model.checkpointable }, Cmd.none )


addInput model =
    model


updateApp model fldName newValue =
    case fldName of
        "appName" ->
            { model | appName = newValue }

        "version" ->
            { model | version = newValue }

        "defaultMemoryPerNode" ->
            let
                ( newMem, error ) =
                    case String.toInt newValue of
                        Ok n ->
                            ( n, Nothing )

                        _ ->
                            ( model.defaultMemoryPerNode, Just "Not a number" )
            in
            { model | defaultMemoryPerNode = newMem, error = error }

        _ ->
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
                                (div [ style [ ( "overflow-y", "auto" ) ] ]
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
        , Html.form []
            [ div [ class "form-group", onInput (UpdateApp "appName") ]
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
                , onInput (UpdateApp "label")
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
            , div [ class "form-group", onInput (UpdateApp "version") ]
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
                , onInput (UpdateApp "shortDescription")
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
                , onInput (UpdateApp "longDescription")
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
                , onInput (UpdateApp "defaultMemoryPerNode")
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
                , onInput (UpdateApp "defaultProcessorsPerNode")
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
                , onInput (UpdateApp "defaultMaxRunTime")
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
                , onInput (UpdateApp "defaultNodeCount")
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
                , onInput (UpdateApp "defaultQueue")
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
                , onInput (UpdateApp "deploymentPath")
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
                , onInput (UpdateApp "deploymentSystem")
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
                , onInput (UpdateApp "executionSystem")
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
                , onInput (UpdateApp "executionType")
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
                , onInput (UpdateApp "helpURI")
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
                , onInput (UpdateApp "parallelism")
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
                , onInput (UpdateApp "templatePath")
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
                , onInput (UpdateApp "testPath")
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
                , onInput (UpdateApp "modules")
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
                , onInput (UpdateApp "tags")
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
                , onInput (UpdateApp "ontology")
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
