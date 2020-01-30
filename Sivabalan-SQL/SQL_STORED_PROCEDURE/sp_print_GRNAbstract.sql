CREATE PROCEDURE sp_print_GRNAbstract(@GRNID INT)  
AS  
  
Declare @ItemCount as int  
Set @ItemCount = 0  
  
--To find Number of item's to be Printed  
--1 is added to Count(*) since GRN will have   
--one total Row, One Batch Row and another one row for Free item's   
--for a sigle item expect for Items with   
--Track batch and Capture Selling set to 0  
  
Select @ItemCount = Sum(NoofItems) From   
 (Select (Case   
   When (Items.Track_Batches = 1 OR ItemCategories.Price_Option = 1) Then  
     Count(*)  
   Else  
    0  
   End) + 1 NoofItems   
 from Batch_Products, GrnDetail, ItemCategories, Items   
 Where  GRNDetail.GRNID = Batch_Products.GRN_ID    
   AND GRNDetail.Product_Code = Batch_Products.Product_Code   
   And Items.Product_Code = GRNDetail.Product_Code  
   And Batch_Products.GRN_ID = @GRNID  
   AND ItemCategories.CategoryID = Items.CategoryID       
 Group By   
   GRNDetail.Product_Code,   
   Batch_Products.Batch_Number,   
   Items.Track_Batches,  
   ItemCategories.Price_Option) A  
  
SELECT "Bill No" = Bill.Prefix + CAST(BillID AS nvarchar),   
"GRN Date" = GRNDate, "Vendor" = Vendors.Vendor_Name,   
"PONumber" = PO.Prefix + CAST(PONumber AS nvarchar),   
"VendorID" = Vendors.VendorID + case when dbo.Fn_Get_PANNumber(@GRNID,'Bill','VENDOR')='' Then '' 
else ' PAN No:' + dbo.Fn_Get_PANNumber(@GRNID,'Bill','VENDOR') end,
"GRN No" = GRN.Prefix + CAST(DocumentID AS nvarchar),  
"Doc Ref" = GRNAbstract.DocRef,  
"Value" = Sum(Batch_Products.QuantityReceived * Batch_Products.PurchasePrice),  
"Doc ID" = GRNAbstract.DocumentReference,  
"ITEM COUNT" = @ITEMCOUNT,  
"TIN Number" = TIN_Number,  
"Doc Type" = DocSerialType  
FROM GRNAbstract, Vendors, VoucherPrefix Bill, VoucherPrefix GRN,  
VoucherPrefix PO, Batch_Products  
WHERE GRNID = @GRNID AND GRNAbstract.VendorID = Vendors.VendorID  
AND Bill.TranID = 'BILL' AND GRN.TranID = 'GOODS RECEIVED NOTE'  
AND PO.TranID = 'PURCHASE ORDER'AND GRNAbstract.GRNID = Batch_products.GRN_ID  
Group by Bill.Prefix, BillID, GRNDate, Vendors.Vendor_Name, PONumber,  
Vendors.VendorID, DocumentID, GRNAbstract.DocRef, PO.Prefix, GRN.Prefix,  
GRNAbstract.DocumentReference, TIN_Number, DocSerialType  

