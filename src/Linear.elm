module Linear exposing (regression, forecast)

{-| Contains functions to create a linear forecast, i. e. a simple trend line.

@docs regression, forecast
-}


fold_helper points =
  List.foldr 
    (\(x, y) ((x_sumi, y_sumi), (x_sqri, xTimesyi)) ->
        ((x_sumi + x, y_sumi + y), (x_sqri + x * x, xTimesyi + x * y)))    
    ((0, 0), (0, 0)) points


{-| Expects a list of Float-tuples, where the first element is the x- and the second element is the y-coordinate of a point. It returns a linear function, that gets a Float and emits new values.

    vals = [(0, 0), (1, 0.5), (2, 1), (3, 1.5)]
    regressionFunction = regression vals

    regressionFunction 4 == 2
-}
regression : List (Float, Float) -> (Float -> Float)
regression points =
  let
    len = List.length points |> toFloat
    ((x_sum, y_sum), (x_sqr, xTimesy)) = fold_helper points
    m = (len * xTimesy - x_sum * y_sum) / (len * x_sqr - x_sum * x_sum)
    b = (y_sum / len) - (m * x_sum) / len
    fun x = x * m + b
  in
    fun


{-| Creates a list of tuples with forecasted values. The first parameter indicates how many values.

Please note that this function expects to get a sorted list of points. It will create a range based on the last point. 

    vals = [(0, 0), (0.5, 0.25), (1, 0.5), (3, 1.5)]
    
    forecast 3 vals == [(4, 2), (5, 2.5), (6, 3)]
-}
forecast : Int -> List (Float, Float) -> List (Float, Float)
forecast m points =
  let
    regressionFunction = regression points
    lastX = 
      points
      |> List.drop (List.length points - 1)
      |> List.head
      |> Maybe.withDefault (0,0)
      |> Tuple.first
      |> round
    range = 
      List.range (lastX + 1) (lastX + m)
      |> List.map toFloat 
  in
    List.map regressionFunction range
    |> List.map2 Tuple.pair range
