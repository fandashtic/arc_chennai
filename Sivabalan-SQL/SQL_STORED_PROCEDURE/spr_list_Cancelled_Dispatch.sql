Create Procedure spr_list_Cancelled_Dispatch (	@FromDate datetime,
						@ToDate datetime)
As
Select "Doc Serial" = DispatchAbstract.DispatchID,
"Dispatch ID" = VoucherPrefix.Prefix + Cast(DispatchAbstract.DocumentID as nvarchar),
"Date" = DispatchAbstract.DispatchDate, "Customer" =  Customer.Company_Name,
"Ref No" = DispatchAbstract.NewRefNumber, 
"Inv Ref" = IPrefix.Prefix + Cast(DispatchAbstract.NewInvoiceID as nvarchar),
"Billing Address" = DispatchAbstract.BillingAddress,
"Shipping Address" = DispatchAbstract.ShippingAddress
From DispatchAbstract, VoucherPrefix, VoucherPrefix as IPrefix, Customer
Where DispatchAbstract.DispatchDate Between @FromDate And @ToDate And
DispatchAbstract.CustomerID = Customer.CustomerID And
(DispatchAbstract.Status & 64 <> 0) And
VoucherPrefix.TranID = 'DISPATCH NOTE' And
IPrefix.TranID = 'INVOICE'

