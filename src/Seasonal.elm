module Seasonal exposing (..)

import Array


initialTrend : Int -> List Float -> Float
initialTrend period data =
  let
    period' = toFloat period
    indexed = Array.fromList data 
    sum = 
      indexed
      |> Array.slice 0 period
      |> Array.indexedMap 
          (\index value -> 
              Array.get (index + period) indexed 
              |> Maybe.map (\ele -> ele - value) 
              |> Maybe.withDefault 0.0)
      |> Array.foldr (+) 0
  in
    sum / (period' * period')


split' : Int -> List Float -> List (List Float) -> List (List Float)
split' period data result =
  if data == [] then
    result
  else
    let
      chunk = List.take period data
      rest  = List.drop period data
    in
      split' period rest (chunk :: result) 


split : Int -> List Float -> List (List Float)
split period data =
  split' period data [] |> List.reverse


avgLists : Int -> List (List Float) -> List Float
avgLists period =
  List.map 
    (\l -> (List.sum l) / (toFloat period))


avgObservations : Int -> List Float -> List Float -> List Float
avgObservations period data avgs =
  List.concatMap (List.repeat period) avgs
  |> List.map2 (/) data


listUnzip : List (List a) -> List (List a)
listUnzip l =
  let 
    innerLength = 
      List.head l 
      |> Maybe.withDefault [] 
      |> List.length
    init = 
      List.map (\i -> []) [0..innerLength]
  in 
    List.foldr (List.map2 (::)) init l


seasonalIndices : Int -> Int -> List Float -> List Float
seasonalIndices period seasons data =
  split period data 
  |> avgLists period 
  |> avgObservations period data
  |> split period
  |> listUnzip
  |> avgLists seasons


check : Float -> Float -> Float -> Int -> Int -> Bool
check alpha beta gamma m period =
  let
    notBetweenZeroAndOne val = val < 0.0 || val > 1.0
  in
    if m <= 0 || m > period || List.any notBetweenZeroAndOne [alpha, beta, gamma] then
      False
    else 
      True

levelSmoothing
    : Float
    -> number
    -> Float
    -> number
    -> Float
    -> Float
    -> Float
    -> Float
levelSmoothing alpha period it index value last_st last_bt =
  if index - period >= 0 then
    ((alpha * value) / it) + ((1.0 - alpha) * (last_st + last_bt))
  else
    (alpha * value) + ((1.0 - alpha) * (last_st + last_bt))


trendSmoothing : Float -> Float -> Float -> Float -> Float
trendSmoothing gamma last_st last_bt st =
  (gamma * (st - last_st)) + ((1.0 - gamma) * last_bt)


seasonalSmoothing : Float -> Float -> Float -> Float -> Float
seasonalSmoothing beta value st it =
  ((beta * value) / st) + ((1.0 - beta) * it)


generateForcast : Float -> Int -> Float -> Float -> Float
generateForcast st m bt crazy_it =
  (st + (toFloat m * bt)) * crazy_it


calculateHoltWinters'
    : Float
    -> Float
    -> Float
    -> Int
    -> Int
    -> Array.Array Float
    -> Float
    -> Float
    -> Int
    -> List Float
    -> List Float
    -> List Float
calculateHoltWinters' alpha beta gamma period m it last_st last_bt index data result = 
  case data of
    (value::rest) ->
      let
        getWithDefault i a = Array.get i a |> Maybe.withDefault 0.0 
        st = levelSmoothing alpha period (getWithDefault (index - period) it) index value last_st last_bt
        bt = trendSmoothing gamma last_st last_bt st
        it' = 
          if index - period >= 0 then
            getWithDefault (index - period) it
            |> seasonalSmoothing beta value st 
            |> (flip Array.push) it
          else
            it
        ft = generateForcast st m bt (getWithDefault (index - period + m) it')
      in
        calculateHoltWinters' alpha beta gamma period m it' st bt (index + 1) rest (ft::result)
    [] ->
      result


calculateHoltWinters : Float -> Float -> Float -> Int -> Int -> Float -> List Float -> List Float -> List Float
calculateHoltWinters alpha beta gamma period m initTrend seasonal data =
  let
    firstObs = List.head data |> Maybe.withDefault 0.0
    restObs = List.drop 2 data
    it = Array.fromList seasonal
  in
    calculateHoltWinters' alpha beta gamma period m it firstObs initTrend 2 restObs []
  

calculateWith : Float -> Float -> Float -> Int -> Int -> List Float -> Maybe (List Float)
calculateWith alpha beta gamma m period data =
  if check alpha beta gamma m period && List.length data > 0 then
    let
      len = List.length data
      seasons = round (toFloat len / toFloat period)
      seasonal = seasonalIndices period 6 data
      initTrend = initialTrend period data      
    in
      calculateHoltWinters alpha beta gamma period m initTrend seasonal data
      |> List.reverse
      |> (++) (List.repeat 6 0)
      |> Just
  else
    Nothing


calculate : Int -> Int -> List Float -> Maybe (List Float)
calculate =
  calculateWith 0.5 0.4 0.6
