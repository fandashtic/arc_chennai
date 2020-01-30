CREATE Procedure sp_print_BillAbstract_Pidilite_Template(@BILLNO INT)            
AS            

Declare @CANCELLED As NVarchar(50)
Declare @AMENDED As NVarchar(50)
Declare @AMENDMENT As NVarchar(50)

Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default)
Set @AMENDED = dbo.LookupDictionaryItem(N'Amended', Default)
Set @AMENDMENT = dbo.LookupDictionaryItem(N'Amendment', Default)

Declare @ItemCount int        
SELECT @ItemCount = Count(*) FROM BillDetail, Items        
WHERE BillDetail.BillID = @BillNo AND         
BillDetail.Product_Code = Items.Product_Code          
        
SELECT "Bill Date" = BillDate, "GRNID" = GRN.Prefix + CAST(NewGRNID AS VARCHAR),             
"Vendor" = Vendors.Vendor_Name, "VendorID" = BillAbstract.VendorID,            
"Value" = BillAbstract.Value,             
"Reference" = InvoiceReference,             
"Status" = Case When (Status & 192)=192 then @CANCELLED        
 When (Status & 128)=128 then @AMENDED        
 When (BillAbstract.Billreference)<>0 then @AMENDMENT        
Else '' End,         
"Bill No" = Bill.Prefix + CAST(DocumentID AS VARCHAR),             
"Tax Amount" = BillAbstract.TaxAmount,            
"Adjustment Amount" = BillAbstract.AdjustmentAmount,         
"Write Off" = (Select Sum(Amount) from AdjustmentReference Where InvoiceID = @BillNo        
And TransactionType = 1 and DocumentType = 2),        
"Additional Adjustment" = (Select Sum(Amount) from AdjustmentReference Where InvoiceID = @BillNo        
And TransactionType = 1 and DocumentType = 5),        
"Net Amount" = BillAbstract.Value + BillAbstract.TaxAmount,          
"Doc ID" = BillAbstract.DocIDReference,          
"TIN Number" = TIN_Number,          
"Doc Type" = DocSerialType,        
"ITEM COUNT" = @ItemCount,        
"Total Item Discount" = BillAbstract.ProductDiscount,        
"Octroi Amount" = BillAbstract.OctroiAmount,        
"Freight" = BillAbstract.Freight,        
"Trade Discount" = ((Select Sum(BD.PurchasePrice * BD.Quantity) From BillDetail BD Where BD.BillID = @BillNo)  - BillAbstract.ProductDiscount + BillAbstract.OctroiAmount + BillAbstract.Freight) * BillAbstract.Discount / 100,      
"Additional Discount" = BillAbstract.AddlDiscountAmount, 'BillDiscountMaster'     
FROM BillAbstract, Vendors, VoucherPrefix GRN, VoucherPrefix Bill            
WHERE BillAbstract.BillID = @BillNo             
AND BillAbstract.VendorID = Vendors.VendorID            
AND GRN.TranID = 'GOODS RECEIVED NOTE'            
AND Bill.TranID = 'BILL'        
    
  


