port module Slider.Slider exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Html.App as App
import Draggable.Draggable as Draggable
import Mouse
import Json.Decode as Json


main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL

type alias Model =
  { min : Int
  , max : Int
  , draggable : Draggable.Model
  }


initModel : Model
initModel =
  { min = 0
  , max = 100
  , draggable = Draggable.initModel
  }


--TODO: replace init function.
init : (Model, Cmd Msg)
init =
  (initModel, Cmd.none)



-- UPDATE

type Msg
  = NoOp
  | MsgDraggable Draggable.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MsgDraggable msgDraggable ->
      let
        (m, fx) =
          Draggable.update msgDraggable model.draggable
      in
        ( { model | draggable = m }
        , Cmd.map MsgDraggable fx
        )
    _ ->
      (model, Cmd.none)



-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map MsgDraggable <| Draggable.subscriptions model.draggable
    ]



-- VIEW

view : Model -> Html Msg
view model =
  div [ class "slider" ]
    [ div [ class "slider__line" ]
       [ div [ class "slider__cursor" ] []
       , div [ class "slider__fill" ] []
       ]
    , App.map MsgDraggable (Draggable.view model.draggable)
    ]
