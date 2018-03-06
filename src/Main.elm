module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


---- MODEL ----


type alias Model =
    { appName : String
    , version : String
    , inputs : List AppInput
    , parameters : List AppParam
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
    , inputs = []
    , parameters = []
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



---- UPDATE ----


type Msg
    = AddInput
    | UpdateApp String String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddInput ->
            ( model, Cmd.none )

        UpdateApp fldName newValue ->
            ( updateApp model fldName newValue, Cmd.none )


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


view : Model -> Html Msg
view model =
    Html.form []
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



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
