CREATE Procedure sp_list_ForeCast (	@Vendor nvarchar(20),
					@FromDate datetime,
					@ToDate datetime)
As
Select Forecast_Abstract.DocSerial, 
Forecast_Abstract.DocPrefix + Cast(Forecast_Abstract.DocumentID as nvarchar),
Vendors.Vendor_Name, Forecast_Abstract.VendorID, Forecast_Abstract.DocumentDate
From Forecast_Abstract, Vendors
Where Forecast_Abstract.VendorID = Vendors.VendorID And
Forecast_Abstract.VendorID like @Vendor And
Forecast_Abstract.DocumentDate Between @FromDate And @ToDate
Order By Vendors.Vendor_Name, Forecast_Abstract.DocumentDate
