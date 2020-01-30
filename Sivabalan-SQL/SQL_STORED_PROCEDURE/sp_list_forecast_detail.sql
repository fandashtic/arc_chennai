CREATE Procedure sp_list_forecast_detail (@DocSerial int)
As
Select Forecast.Product_Code, Items.ProductName, Items.Description, Forecast.MRP, 
Forecast.Wk1Qty, Forecast.Wk2Qty, 
Forecast.Wk3Qty, Forecast.Wk4Qty, Forecast.Wk5Qty, Forecast.Wk6Qty, Forecast.Wk7Qty,
Forecast.Wk8Qty, Forecast.Wk9Qty, Forecast.Wk10Qty, Forecast.Wk11Qty, 
Forecast.Wk12Qty, Forecast.Wk13Qty 
From Forecast, Items
Where Forecast.Product_Code = Items.Product_Code And
Forecast.DocSerial = @DocSerial
