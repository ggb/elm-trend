# elm-trend

Calculate trend lines and forecast based on seasonal data.

![alt text](https://github.com/ggb/elm-trend/blob/master/trends.png "Trend line and seasonal trends")

**Green**: Actual Data; **Blue**: Trend Line; **Red**: Seasonal Forecast

The graph was created with the help of [wuct/elm-charts](http://package.elm-lang.org/packages/wuct/elm-charts/latest). 

## Installation

```bash
elm package install ggb/elm-trend
```

## Usage

Usage is straightforward: 

```elm
import Trend
import Seasonal

data = 
  [ 362, 385, 432, 341, 382, 409, ... ]

-- Create linear trend function
linearTrend = Trend.linear data

-- Seasonal forecast
period = 4
forecastData = Seasonal.calculate period
```

Take a look at example/SeasonalTest.elm for a more detailed example.

## Future

Ideas for future development:

* Implementing [ARIMA](https://en.wikipedia.org/wiki/Autoregressive_integrated_moving_average)
* Multivariant regression and other regression types