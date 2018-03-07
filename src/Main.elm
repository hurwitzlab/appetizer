module Main exposing (..)

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
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



---- UPDATE ----


type Msg
    = AddInput
    | ToggleShowJson
    | UpdateApp String String
    | ToggleAvailable
    | ToggleCheckpointable


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddInput ->
            ( model, Cmd.none )

        ToggleShowJson ->
            ( { model | showJson = not model.showJson }, Cmd.none )

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
        ++ "\"available\": \""
        ++ (if model.available then "true" else "false")
        ++ "\","
        ++ "\"checkpointable\": \""
        ++ (if model.checkpointable then "true" else "false")
        ++ "\","
        ++ "}"


jsonViewer model =
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
    in
    div []
        [ div [ onClick ToggleShowJson ] [ text (prompt ++ " JSON") ]
        , div [] [ text json ]
        ]


view : Model -> Html Msg
view model =
    Html.form []
        [ jsonViewer model
        , div [ class "form-group", onInput (UpdateApp "appName") ]
            [ Html.label [] [ text "App Name" ]
            , Html.input
                [ type_ "text"
                , name "appName"
                , placeholder model.appName
                , class "form-control"
                ]
                []
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
            , Html.button [ onClick AddInput ] [ text "Add Input" ]
            , showInputs model.inputs
            ]
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
