CREATE Procedure sp_Get_Item_GV (@GRNID int,@Serial int =0)          
As          
Declare @Locality int    
Select @Locality = Locality from Vendors,GrnAbstract where Vendors.VendorID = GrnAbstract.VendorID and GrnAbstract.GrnID=@GRNID    
    
Select Batch_Products.Product_Code,           
Case ItemCategories.Price_Option          
When 1 Then          
 Case Purchased_At          
 When 1 Then          
 Sum((Batch_Products.QuantityReceived * Batch_Products.PTS) + dbo.fn_calculateTax(Batch_Products.Product_code,(Batch_Products.QuantityReceived * Batch_Products.PTS),Batch_Products.QuantityReceived,@Locality,Batch_Products.GRNTaxID,Batch_Products.Batch_Code))          
 When 2 Then          
 Sum((Batch_Products.QuantityReceived * Batch_Products.PTR) + dbo.fn_calculateTax(Batch_Products.Product_code,(Batch_Products.QuantityReceived * Batch_Products.PTR),Batch_Products.QuantityReceived,@Locality,Batch_Products.GRNTaxID,Batch_Products.Batch_Code))          
 Else          
 Sum((Batch_Products.QuantityReceived * Batch_Products.PurchasePrice) + dbo.fn_calculateTax(Batch_Products.Product_code,(Batch_Products.QuantityReceived * Batch_Products.PurchasePrice),Batch_Products.QuantityReceived,@Locality,Batch_Products.GRNTaxID,Batch_Products.Batch_Code))          
 End          
Else          
 Sum((Batch_Products.QuantityReceived * Batch_Products.PurchasePrice) + dbo.fn_calculateTax(Batch_Products.Product_code,(Batch_Products.QuantityReceived * Batch_Products.PurchasePrice),Batch_Products.QuantityReceived,@Locality,Batch_Products.GRNTaxID,Batch_Products.Batch_Code))          
End          
From Items, Batch_Products, ItemCategories          
Where Batch_Products.Product_Code = Items.Product_Code And          
Items.CategoryID = ItemCategories.CategoryID And          
Batch_Products.GRN_ID = @GRNID and Batch_Products.free = 0
and Batch_Products.Serial = @Serial
Group By Batch_Products.Product_Code, Items.Purchased_At, ItemCategories.Price_Option,Batch_Products.free


