CREATE PROCEDURE mERP_get_RecdInvVendorInfo(@RecdInvID as Int)
AS

Select 
"InvoiceID" = InvoiceID , 
"InvDate" = InvoiceDate, 
"InvNo" = DocumentID, 
"InvVal" = NetValue , 
"VendorID" = IAR.VendorID,
"VendorName" = V.Vendor_Name,
"TaxType" = IsNull(IAR.TaxType,1)
,"GSTFlag"=IAR.GSTFlag ,"StateType"=IAR.StateType ,"FromStateCode"=IAR.FromStateCode ,"ToStateCode"=IAR.ToStateCode ,"GSTIN"=IAR.GSTIN
,"ODNumber" = IAR.ODNumber
From InvoiceAbstractReceived IAR, Vendors V
Where IAR.InvoiceID = @RecdInvID
And IAR.VendorID = V.VendorID

