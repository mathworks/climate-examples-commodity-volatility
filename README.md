# Commodity Volatility Modelling

[![View Climate Examples: Commodity Volatility Modelling on File Exchange](readme/matlab-file-exchange.svg)](https://uk.mathworks.com/matlabcentral/fileexchange/123335-climate-examples-commodity-volatility-modelling)
[![Open in MATLAB Online](readme/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=mathworks/climate-examples-commodity-volatility&project=Commodities.prj&file=S01_DataProcessing.mlx)

Modelling and forecasting volatility is a common task in many financial applications. This collection of examples analyzes, models, and forecasts the volatility associated with a collection of soft commodities.

Soft commodities are impacted by uncertainties associated with both short and long-term changes in weather patterns caused by climate change. As these uncertainties increase, we expect volatility modelling to increase in importance as practitioners seek to improve their forecasts of market responses to the impacts of climate change.

The examples in this collection are designed to showcase a range of statistical methods, machine learning techniques, and time-series models which are broadly applicable in the volatility modelling area.

The examples were developed by Phoebe Piercy and Ken Deeley at MathWorks.

![](readme/Tea.png)

## Installation and Getting Started
The examples are provided in a MATLAB project.
1. Double-click on the project archive (`Commodities.mlproj`) to extract it using MATLAB.
2. With MATLAB open, navigate to the newly-created project folder and double-click on the project file (`Commodities.prj`) to open the project.
3. The example files are the live scripts within the project.
   - `S01_DataProcessing.mlx`: This script imports and processes the data for subsequent modelling.
   - `S02_TrendDecomposition.mlx`: This script clusters the commodities based on trend analysis.
   - `S03_NonParametricVolatility`: This script performs nonparametric volatility estimates and further clustering on the commodities.
   - `S04_ModelBasedVolatility`: This script forecasts volatility using time-series models for the principal components of the volatility.
4. The examples rely on external commodity data provided by the World Bank. The example file `S01_DataProcessing.mlx` downloads this data, and requires an internet connection.

### [MathWorks&reg;](https://www.mathworks.com) Product Requirements

These examples were developed for MATLAB release R2022b or later.
- [MATLAB&reg;](https://www.mathworks.com/products/matlab.html)
- [Statistics and Machine Learning Toolbox&trade;](https://www.mathworks.com/products/statistics.html)
- [Econometrics Toolbox&trade;](https://www.mathworks.com/products/econometrics.html)
- [Datafeed Toolbox&trade;](https://www.mathworks.com/products/datafeed.html)
- [Optimization Toolbox&trade;](https://www.mathworks.com/products/optimization.html)
- [Financial Toolbox&trade;](https://www.mathworks.com/products/finance.html)

## License
The license for this entry is available in the [license.txt](license.txt) file in this GitHub repository.

Copyright 2022-2025 The MathWorks, Inc.

## Community Support
[MATLAB Central](https://www.mathworks.com/matlabcentral)