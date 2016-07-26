module SeasonalTest exposing (..)

import Seasonal
import Svg exposing (svg)
import Svg.Attributes exposing (width, height)
import Chart exposing (Scale, Data)
import LineChart exposing (lineChart, color, width)


data = [
    362, 385, 432, 341, 382, 409,
    498, 387, 473, 513, 582, 474,
    544, 582, 681, 557, 628, 707,
    773, 592, 627, 725, 854, 661 ] 


renderData : Data msg
renderData = 
  data |> List.indexedMap (\index val -> (index + 1 |> toFloat, val, []))


forecast : Data msg
forecast = 
  data 
  |> Seasonal.calculate 4 6
  |> Maybe.withDefault []
  |> List.indexedMap (\index val -> (index + 1 |> toFloat, val, []))
  |> Debug.log "forecast"

xScale : Scale
xScale x =
  20 + x * 20


yScale : Scale
yScale y =
  600 - y / 3


main =
  svg
    [
      Svg.Attributes.width "1000",
      Svg.Attributes.height "600"
    ]
    [
      lineChart
        [
          LineChart.color "#7E94C7"
        ]
        { data = renderData
        , xScale = xScale
        , yScale = yScale
        },
      lineChart
        [
          LineChart.color "pink"
        ]
        { data = forecast
        , xScale = xScale
        , yScale = yScale
        }
    ]