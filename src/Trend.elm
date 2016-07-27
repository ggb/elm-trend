module Trend exposing (..)


linear : List (Float, Float) -> (Float -> Float)
linear points =
  let
    len = List.length points
    (x_sum, y_sum, x_sqr, xTimesy) =
      List.foldr 
        (\(x, y) (x_sum, y_sum, x_sqr, xTimesy) -> 
          (x_sum + x, y_sum + y, x_sqr + x * x, xTimesy + x * y)
        )    
        (0, 0, 0, 0) points
    m = toFloat (len * xTimesy - x_sum * y_sum) / toFloat (len * x_sqr - x_sum * x_sum)
    b = (toFloat y_sum / toFloat len) - (m * x_sum) / toFloat len
    -- y = x * m + b
    fun x = x * m + b
  in
    fun


{-
var m = (count*sum_xy - sum_x*sum_y) / (count*sum_xx - sum_x*sum_x);
var b = (sum_y/count) - (m*sum_x)/count;
-}