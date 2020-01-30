CREATE Procedure Spr_Purchase_Register_Adjustments (@Vendor_Name nvarchar(255), @Locality nvarchar(255),  
@FromDate DateTime, @ToDate DateTime)  
As  
Declare @LOCAL As NVarchar(50)
Declare @OUTSTATION As NVarchar(50)
Set @LOCAL = dbo.LookupDictionaryItem(N'Local',Default)
Set @OUTSTATION = dbo.LookupDictionaryItem(N'Outstation',Default)

Declare @Prefix nvarchar(255)  
Select @Prefix = Prefix From VoucherPrefix Where TranID = 'GOODS RECEIVED NOTE'  
Select ba.BillID, "Doc ID" = ba.DocIDReference, "GRN ID" = @Prefix + Cast(ga.DocumentID As nvarchar), "Bill Date" = BillDate,  
"Vendor Name" = v.Vendor_Name,   
"Gross" = Case ba.DiscountOption When 1 Then Sum((bd.Quantity * bd.PurchasePrice) - (bd.Quantity * bd.PurchasePrice * bd.Discount) / 100)  
   Else Sum((bd.Quantity * bd.PurchasePrice) - bd.Discount) End,  
"Tax Amount" = ba.TaxAmount, "Discount %" = ba.Discount,   
"Discount" = Sum(((bd.Quantity * bd.PurchasePrice) - (bd.Quantity * bd.PurchasePrice * bd.Discount) / 100) * ba.Discount / 100),  
"Adjustments" = ba.AdjustedAmount, "F11 Adjustments" = ba.AdjustmentValue,  
"Net Amount" = ba.Value + ba.TaxAmount + ba.AdjustmentAmount,  
"Balance" = ba.Balance From BillAbstract ba, BillDetail bd, Vendors v, GRNAbstract ga  
Where ba.BillID = bd.BillID And ba.VendorID = v.VendorID And ba.GRNID = ga.GRNID  
And v.Vendor_Name Like @Vendor_Name And v.Locality In 
(Select Case @Locality When @LOCAL Then 1 When '%' Then 1 End
Union Select Case @Locality When @OUTSTATION Then 2 When '%' Then 2 End) And BillDate Between @FromDate And @ToDate And ba.Status & 192 = 0 Group By ba.BillID, ba.DocIDReference, ga.DocumentID,  
BillDate, v.Vendor_Name, ba.TaxAmount, ba.Discount, ba.AdjustedAmount, ba.AdjustmentValue,  
ba.Value, ba.AdjustmentAmount, ba.Balance, ba.DiscountOption   

