Create Procedure spr_list_cancelled_SC(	@FromDate datetime,
					@ToDate datetime)
As
Select "Doc Serial" = SOAbstract.SONumber,
"SC Number" = VoucherPrefix.Prefix + Cast(SOAbstract.DocumentID as nvarchar),
"Date" = SOAbstract.SODate, "Delivery Date" = SOAbstract.DeliveryDate, 
"Customer" = Customer.Company_Name, "Value" = SOAbstract.Value,
"PO Ref" = SOAbstract.PODocReference
From SOAbstract, VoucherPrefix, Customer
Where SOAbstract.SODate Between @FromDate And @ToDate And
(SOAbstract.Status & 64) <> 0 And
SOAbstract.CustomerID = Customer.CustomerID And
VoucherPrefix.TranID = 'SALES CONFIRMATION'

