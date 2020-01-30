Create Procedure sp_list_forecast_abstract (@DocSerial int)
As
Select Forecast_Abstract.DocPrefix + Cast(Forecast_Abstract.DocumentID as nvarchar), 
Forecast_Abstract.DocumentDate,
Forecast_Abstract.Forecast_Date, Vendors.Vendor_Name, 
Forecast_Abstract.VendorID
From Forecast_Abstract, Vendors
Where Forecast_Abstract.DocSerial = @DocSerial And
Forecast_Abstract.VendorID = Vendors.VendorID

