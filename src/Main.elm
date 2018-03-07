module Main exposing (..)

import Dialog
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


---- MODEL ----


type alias Model =
    { appName : String
    , version : String
    , available : Bool
    , checkpointable : Bool
    , inputs : List AppInput
    , parameters : List AppParam
    , showJson : Bool
    , showInputForm : Bool
    }


type alias AppInput =
    { id : String
    }


type alias AppParam =
    { id : String
    }


initialModel =
    { appName = "MyNewApp"
    , version = "0.0.1"
    , available = True
    , checkpointable = False
    , inputs = []
    , parameters = []
    , showJson = False
    , showInputForm = False
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

        _ ->
            model



---- VIEW ----


generateJson model =
    "{"
        ++ "\"name\": \""
        ++ model.appName
        ++ "\","
        ++ "\"version\": \""
        ++ model.version
        ++ "\","
        ++ "\"available\": "
        ++ (if model.available then
                "true"
            else
                "false"
           )
        ++ ","
        ++ "\"checkpointable\": "
        ++ (if model.checkpointable then
                "true"
            else
                "false"
           )
        ++ "}"


viewJson model =
    let
        json =
            if model.showJson then
                generateJson model
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
                        , header = Just (text model.appName)
                        , body = Just (p [] [ text json ])
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
    div []
        [ h1 [] [ text "Appetizer" ]
        , Html.form []
            [ div [ class "form-group", onInput (UpdateApp "appName") ]
                [ Html.label [] [ text "App Name" ]
                , Html.input
                    [ type_ "text"
                    , name "appName"
                    , placeholder model.appName
                    , class "form-control"
                    ]
                    []
                ]
            ]
        , div [ class "form-group", onInput (UpdateApp "version") ]
            [ Html.label [] [ text "Version" ]
            , Html.input
                [ type_ "text"
                , name "version"
                , placeholder model.version
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
