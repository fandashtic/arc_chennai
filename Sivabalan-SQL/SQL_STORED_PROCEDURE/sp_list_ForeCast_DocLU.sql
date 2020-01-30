CREATE Procedure sp_list_ForeCast_DocLU(@FromDoc int,
					@ToDoc int)
As
Select Forecast_Abstract.DocSerial, 
Forecast_Abstract.DocPrefix + Cast(Forecast_Abstract.DocumentID as nvarchar),
Vendors.Vendor_Name, Forecast_Abstract.VendorID, Forecast_Abstract.DocumentDate
From Forecast_Abstract, Vendors
Where Forecast_Abstract.VendorID = Vendors.VendorID And
Forecast_Abstract.DocumentID Between @FromDoc And @ToDoc
Order By Vendors.Vendor_Name, Forecast_Abstract.DocumentDate
