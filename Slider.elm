port module Slider.Slider exposing (..)


import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Html.App as App
import Draggable.Draggable as Draggable
import Mouse exposing (Position)


main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL

type alias Model =
  { min   : Int
  , max   : Int
  , width : Int
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
    , draggable = draggableOptions
    }


init : (Model, Cmd Msg)
init =
  (initModel, getSize initModel.uuid)



-- UPDATE

type Msg
  = NoOp
  | SetWidth Int
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
        {-
        , Cmd.batch
            [ Cmd.map MsgDraggable fx
            , distance (toString model.draggable.position.x)
            ]
        -}
        )
    SetWidth width ->
      let
        initScope = Draggable.initScope
        draggable = model.draggable
        scopeX = { initScope | minX = Just 0, maxX = Just width }
        setDraggable = { draggable | scope = scopeX }
      in
        ( { model
              | width = width
              , draggable = setDraggable
          }
        , Cmd.none
        )
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
    _ =
      "1"--Debug.log "model" (getPrecentage model)
  in
    div [ class "slider"
        , attribute "data-uuid" (toString model.uuid)
        ]
      [ div [ class "slider__line" ]
       [ App.map MsgDraggable (Draggable.view model.draggable)
             {-
        div [ class "slider__cursor" ]
           [ App.map MsgDraggable (Draggable.view model.draggable)
           ]
           -}
       , div [ class "slider__fill" ] []
       ]
      ]


getPrecentage : Model -> Float
getPrecentage { draggable, width } =
  (toFloat draggable.position.x) / (toFloat width)
