%[text] %[text:anchor:T_0B1C137A] # **Data Import and Processing**
%[text] In this example, we import historical price data for a set of commodities. We then organize and process the data into a suitable form for subsequent analysis.
%[text] *Copyright 2022-2026 The MathWorks, Inc.*
%[text:tableOfContents]{"heading":"Table of Contents"}
%[text] %[text:anchor:H_B8471C08] ## 
%%
%[text] %[text:anchor:H_C7D6807E] ## **Import the commodity price data.**
%[text] The data is sourced from The World Bank's monthly commodity price data set.
%[text] **Reference**
%[text] - The World Bank: "Pink Sheet" Data - Monthly prices ([https://www.worldbank.org/en/research/commodity-markets](https://www.worldbank.org/en/research/commodity-markets))
%[text] - Terms of use: [https://www.worldbank.org/en/about/legal/terms-of-use-for-datasets](https://www.worldbank.org/en/about/legal/terms-of-use-for-datasets) \
%[text] The data comprises monthly commodity prices for a diverse collection of commodities. 
%[text] In the following code, the data set (`CMO-Historical-Data-Monthly.xlsx`) is downloaded from the source above using the [`webread`](<matlab: doc webread>) command.
%[text] See also the local function [`importCommodityData`](internal:M_514590B0).
dataURL = "https://thedocs.worldbank.org/en/doc/5d903e848db1d1b83e0ec8f744e55570-0350012021/related/CMO-Historical-Data-Monthly.xlsx";
webOpts = weboptions("ContentReader", @importCommodityData);
Prices = webread(dataURL, webOpts);
%%
%[text] %[text:anchor:H_805ABB85] ## Process the raw commodity price data.
%[text] First, convert the dates to `datetime` values, then convert the table to a timetable.
Prices.Date = datetime(Prices.Date, ...
    "InputFormat", "yyyy'M'MM", ...
    "Format", "MMM yyyy");
Prices = table2timetable(Prices);
%[text] Associate high-level classes with each commodity. We will use these high-level classes to extract the soft commodities from the larger data set.
commodityClasses = categorical([repmat("Energy", 1, 10), ...
    repmat("Beverages", 1, 7), ...
    repmat("Oils and Meals", 1, 11), ...
    repmat("Grains", 1, 9), ...
    repmat("Other Food", 1, 10), ...
    repmat("Raw Materials", 1, 9), ...
    repmat("Fertilizers", 1, 5), ...
    repmat("Metals and Minerals", 1, 7), ...
    repmat("Precious Metals", 1, 3)] );

Prices = addprop(Prices, "CommodityClass", "variable");
Prices.Properties.CustomProperties.CommodityClass = commodityClasses;
%[text] Similarly, associate a hard/soft label with each commodity, using the commodity classes defined above.
commodityTypes = categorical(repmat("Soft", 1, width(Prices)));
hardClasses = categorical(["Energy", "Fertilizers", "Metals and Minerals", "Precious Metals"]);
hardIdx = ismember(commodityClasses, hardClasses);
commodityTypes(hardIdx) = "Hard";

Prices = addprop( Prices, "CommodityType", "variable" );
Prices.Properties.CustomProperties.CommodityType = commodityTypes;
%%
%[text] %[text:anchor:H_30121221] ## Create a portfolio of soft commodities.
%[text] Extract the soft commodities which have non-missing data for the entire period.
soft = Prices.Properties.CustomProperties.CommodityType == "Soft";
intact = all(~ismissing(Prices));
Prices = Prices(:, soft & intact);
%[text] Preview the commodity price data.
disp(head(Prices)) %[output:7bdab85e]
%%
%[text] %[text:anchor:H_696BDE68] ## Adjust the soft commodity price data.
%[text] The price data is recorded in nominal US dollars. We use an external inflation metric to adjust the nominal commodity prices and approximate a real (inflation-adjusted) price series.
%[text] First, obtain the external inflation metric (a consumer price index) over the same date range as observed in the commodity prices.
%[text] The series `CUUR0000SA0R` is obtained from the FRED (Federal Reserve Economic Data) data provider. This series can also be downloaded in CSV format if the Datafeed Toolbox is not available. Use the following code to create the `inflation` timetable in this case. This code assumes that the series data is saved in a file named **`CUUR0000SA0R.csv`** on the MATLAB path.
%[text] ```matlabCodeExample
%[text] [startDate, endDate] = bounds(Prices.Date);
%[text] inflation = readtimetable("CUUR0000SA0R.csv");
%[text] inflation = inflation(timerange(startDate, endDate), :);
%[text] ```
%[text] **Reference**
%[text] U.S. Bureau of Labor Statistics, Consumer Price Index for All Urban Consumers: Purchasing Power of the Consumer Dollar in U.S. City Average \[CUUR0000SA0R\], retrieved from FRED, Federal Reserve Bank of St. Louis; [https://fred.stlouisfed.org/series/CUUR0000SA0R](https://fred.stlouisfed.org/series/CUUR0000SA0R), October 5, 2022.
[startDate, endDate] = bounds(Prices.Date);
filename = "CUUR0000SA0R.csv";
if isfile(filename)
    inflation = readtimetable(filename);
    inflation = inflation(timerange(startDate, endDate), :);
else
    return
end % if
%[text] Adjust the data to reflect January 2022 US dollars. First, rebase the inflation index so that January 2022 has value 1.
rebaseDate = datetime(2022, 01, 01);
inflation{:, 1} = inflation{:, 1} / inflation{rebaseDate, 1};
%[text] Determine the common dates between the commodity series and the inflation metric.
[inflationIdx, commodityIdx] = intersect(inflation.Time, Prices.Date);
%[text] Adjust the commodity prices over this time range using the inflation metric.
Prices = Prices(commodityIdx, :);
inflation = inflation{inflationIdx, :};
Prices.Variables = Prices.Variables .* inflation;
%%
%[text] %[text:anchor:H_3E66CB2F] ## Visualize the adjusted commodity price data.
%[text] Plot each price series over time.
commodityNames = Prices.Properties.VariableNames;

figure
tiledlayout("flow", "TileSpacing", "tight")

for commodity = 1:width(Prices)
    nexttile
    plot(Prices.Date, Prices{:, commodity})
    title(commodityNames(commodity))   
    axis off
end

sgtitle("Commodity Prices")
%%
%[text] %[text:anchor:H_93E5AE6E] ## Compute the commodity price returns.
%[text] In subsequent analysis we will often require to work with the commodity price returns rather than the adjusted prices.
%[text] We convert the adjusted commodity prices $P\_t$ to the return series $R\_t$ as follows.
%[text] $R\_t = \\frac{P\_{t+1}}{P\_t}-1, \\quad t = 1, 2, 3, \\dots$
Returns = tick2ret(Prices);
%%
%[text] %[text:anchor:H_4DC3E9FC] ## Visualize the commodity price returns.
%[text] Plot each return series over time.
figure
tiledlayout("flow", "TileSpacing", "tight")

for commodity = 1:width(Returns)
    nexttile
    plot(Returns.Date, Returns{:, commodity})
    title(commodityNames(commodity))
    axis off
end

sgtitle("Commodity Returns")
%%
%[text] %[text:anchor:H_2611C266] ## Save the commodity data for subsequent modelling and analysis.
save("Commodities.mat", "Prices", "Returns")
%%
%[text] %[text:anchor:H_8D4269AE] ## Local function for importing the commodity data.
function Prices = importCommodityData(filename) %[text:anchor:M_514590B0]

% Detect the import options for the file CMO-Historical-Data-Monthly.xlsx.
opts = detectImportOptions(filename, ...
    "Sheet", "Monthly Prices", ...
    "VariableNamingRule", "preserve", ...
    "TextType", "string");

% Rename the first variable to Date.
opts.VariableNames = replace(opts.VariableNames, "Var1", "Date");

% Ensure that all variables apart from the first are numeric.
numVars = length(opts.VariableTypes);
opts.VariableTypes = ["string", repmat("double", 1, numVars - 1)];

% Ensure that the variable units are imported in addition to the data.
opts.VariableUnitsRange = "A6";

% Import the data.
Prices = readtable(filename, opts);

end % importCommodityData

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline","rightPanelPercent":57.8}
%---
%[output:7bdab85e]
%   data: {"dataType":"text","outputData":{"text":"      <strong>Date<\/strong>      <strong>Cocoa<\/strong>     <strong>Coffee, Arabica<\/strong>    <strong>Coffee, Robusta<\/strong>    <strong>Tea, avg 3 auctions<\/strong>    <strong>Tea, Colombo<\/strong>    <strong>Tea, Kolkata<\/strong>    <strong>Tea, Mombasa<\/strong>    <strong>Coconut oil<\/strong>    <strong>Groundnut oil **<\/strong>    <strong>Palm oil<\/strong>    <strong>Soybeans<\/strong>    <strong>Soybean oil<\/strong>    <strong>Soybean meal<\/strong>    <strong>Maize<\/strong>    <strong>Rice, Thai 5%<\/strong>    <strong>Wheat, US HRW<\/strong>    <strong>Banana, US<\/strong>    <strong>Orange<\/strong>    <strong>Beef **<\/strong>    <strong>Chicken **<\/strong>    <strong>Sugar, EU<\/strong>    <strong>Sugar, US<\/strong>    <strong>Sugar, world<\/strong>    <strong>Tobacco, US import u.v.<\/strong>    <strong>Logs, Malaysian<\/strong>    <strong>Sawnwood, Malaysian<\/strong>    <strong>Cotton, A Index<\/strong>    <strong>Rubber, RSS3<\/strong>\n    <strong>________<\/strong>    <strong>______<\/strong>    <strong>_______________<\/strong>    <strong>_______________<\/strong>    <strong>___________________<\/strong>    <strong>____________<\/strong>    <strong>____________<\/strong>    <strong>____________<\/strong>    <strong>___________<\/strong>    <strong>________________<\/strong>    <strong>________<\/strong>    <strong>________<\/strong>    <strong>___________<\/strong>    <strong>____________<\/strong>    <strong>_____<\/strong>    <strong>_____________<\/strong>    <strong>_____________<\/strong>    <strong>__________<\/strong>    <strong>______<\/strong>    <strong>_______<\/strong>    <strong>__________<\/strong>    <strong>_________<\/strong>    <strong>_________<\/strong>    <strong>____________<\/strong>    <strong>_______________________<\/strong>    <strong>_______________<\/strong>    <strong>___________________<\/strong>    <strong>_______________<\/strong>    <strong>____________<\/strong>\n\n    <strong>Jan 1960<\/strong>     0.634        0.9409             0.69686              1.0297              0.9303          1.1214          1.0374           390              334             233          94           204            91.9         45         104.45            59.89         0.14308      0.1151    0.7055      0.29737       0.12236      0.11684        0.0666               1736.9                  31.94               149.17               0.6486            0.8223   \n    <strong>Feb 1960<\/strong>     0.608        0.9469             0.68871              1.0297              0.9303          1.1214          1.0374           379              341             229          91           201            86.7         44         103.54            60.99         0.14308      0.1092    0.7121      0.29742       0.12236      0.11905        0.0679               1736.9                  31.94               149.17               0.6453            0.8289   \n    <strong>Mar 1960<\/strong>    0.5789        0.9281             0.68871              1.0297              0.9303          1.1214          1.0374           361              338             225          92           201            84.1         45         103.79            61.73         0.14308      0.1319    0.7694      0.29783       0.12236      0.12125        0.0683               1736.9                  31.94               149.17               0.6464            0.8576   \n    <strong>Apr 1960<\/strong>    0.5983        0.9303             0.68452              1.0297              0.9303          1.1214          1.0374           338              333             225          93           207            86.7         45         100.97            60.99         0.14308      0.1363    0.8378      0.29902       0.12236      0.12346        0.0681               1736.9                  31.94               149.17               0.6435            0.8642   \n    <strong>May 1960<\/strong>    0.6001          0.92             0.69069              1.0297              0.9303          1.1214          1.0374           321              335             225          93           209            81.5         48         102.15            57.69           0.149      0.1444    0.7562      0.29903       0.12236      0.12125        0.0683               1736.9                  31.94               149.17               0.6468            0.9281   \n    <strong>Jun 1960<\/strong>    0.5944        0.9123             0.69686              1.0297              0.9303          1.1214          1.0374           287              334             219          91           218            80.3         47         103.13            55.48           0.149      0.1385    0.7077      0.29964       0.12236      0.12566        0.0666               1736.9                  31.94               149.17               0.6559            0.8929   \n    <strong>Jul 1960<\/strong>    0.6045         0.916             0.69069              1.0297              0.9303          1.1214          1.0374           298              336             221          92           224            77.7         47         102.05            54.75           0.149      0.1292    0.7474      0.30002       0.12236      0.13228        0.0728               1736.9                  31.94               149.17               0.6572             0.787   \n    <strong>Aug 1960<\/strong>    0.5882        0.9292             0.69885              1.0297              0.9303          1.1214          1.0374           292              336             225          93           237            77.7         47         109.71            55.12         0.12699      0.1292    0.7826      0.30083       0.12236      0.12787        0.0741               1736.9                  31.94               149.17               0.6534            0.7209   \n\n","truncated":false}}
%---
