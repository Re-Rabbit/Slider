port module Slider.Slider exposing (..)


import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Html.App as App
import Draggable.Draggable as Draggable
import Mouse exposing (Position)
import Json.Decode as Json
--import Util.Style exposing (floatToPrecentage)


main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL


type alias Size =
  { left  : Float
  , width : Float
  }

type alias Model =
  { min   : Int
  , max   : Int
  , width : Int
  , value : Float
  , uuid  : Int
  , draggable : Draggable.Model
  }


initModel : Model
initModel =
  let
    draggableInitModel = Draggable.initModel
    draggableOptions =
      { draggableInitModel
          | axis = Draggable.X
      }
  in
    { min = 0
    , max = 100
    , uuid = 1
    , width = 0
    , value = 0
    , draggable = draggableOptions
    }


init : (Model, Cmd Msg)
init =
  (initModel, getSize initModel.uuid)



-- UPDATE

type Msg
  = NoOp
  | SetWidth Int
  | SetValue Position
  | MsgDraggable Draggable.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MsgDraggable msgDraggable ->
      let
        (m, fx) =
          Draggable.update msgDraggable model.draggable
      in
        ( { model
              | draggable = m
              , value = getPrecentage model
          }
        , Cmd.map MsgDraggable fx
        )
    SetWidth width ->
      let
        initScope = Draggable.initScope
        draggable = model.draggable
        scopeX = { initScope | minX = Just 0, maxX = Just width }
        resetX =
          model.value * (toFloat width)
        setDraggable =
          { draggable
              | scope = scopeX
              , position = Position (round resetX) draggable.position.y
          }
      in
        ( { model
              | width = width
              , draggable = setDraggable
          }
        , Cmd.none
        )
    SetValue position ->
      let
        _ =
          Debug.log "pos" position
      in
        (model, Cmd.none)
    _ ->
      (model, Cmd.none)



port getSize : Int -> Cmd msg
port setSize : (Int -> msg) -> Sub msg



-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map MsgDraggable <| Draggable.subscriptions model.draggable
    , setSize SetWidth
    ]



-- VIEW

view : Model -> Html Msg
view model =
  let
    viewDraggable =
      Draggable.view [ class "slider__cursor" ] model.draggable
    viewCursor =
      App.map MsgDraggable viewDraggable
    fillWidth =
      toString (model.value * 100) ++ "%"
    viewFill =
      div [ class "slider__fill"
          , style [( "width", fillWidth )]
          ] []
    viewLine =
      div [ class "slider__line"
          , on "mousedown" (Json.map SetValue Mouse.position)
          ] [ viewCursor, viewFill ]
    viewSlider =
      div [ class "slider"
          , attribute "data-uuid" (toString model.uuid)
          ] [ viewLine, text fillWidth ]
  in
    viewSlider


getPrecentage : Model -> Float
getPrecentage { draggable, width } =
  (toFloat (Draggable.getPosition draggable).x) / (toFloat width)
