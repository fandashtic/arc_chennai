CREATE Procedure sp_list_ForeCast_Docs(	@Vendor nvarchar(20),
					@FromDate datetime,
					@ToDate datetime,
					@Status int)
As
Select Forecast_Abstract.DocSerial, 
Forecast_Abstract.DocumentDate, 
"Status" = dbo.LookupDictionaryItem(Case Isnull(Status, 0) & 32 When 32 Then 'Sent' Else 'Not Sent' End, Default),
Vendors.Vendor_Name, Forecast_Abstract.VendorID,
Forecast_Abstract.DocPrefix + Cast(Forecast_Abstract.DocumentID as nvarchar)
From Forecast_Abstract, Vendors
Where Forecast_Abstract.VendorID = Vendors.VendorID And
Forecast_Abstract.DocumentDate Between @FromDate And @ToDate And
IsNull(Forecast_Abstract.Status , 0) & @Status = 0 And
Forecast_Abstract.VendorID like @Vendor
Order By Vendors.Vendor_Name, DocumentDate
