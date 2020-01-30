CREATE Procedure sp_Get_Item_GV_FMCG_MUOM (@GRNID int,@Serial int,@uom int,@Product_Code nvarchar(15)  )        
As          
Declare @Locality int        
Select @Locality = Locality from Vendors,GrnAbstract where Vendors.VendorID = GrnAbstract.VendorID and GrnAbstract.GrnID=@GRNID        
        
Select Batch_Products.Product_Code,           
Sum(Batch_Products.QuantityReceived * Batch_Products.PurchasePrice + dbo.fn_calculateTax_FMCG(Batch_Products.Product_code,(Batch_Products.QuantityReceived * Batch_Products.PurchasePrice),Batch_Products.QuantityReceived,@Locality,Batch_Products.GRNTaxID)) 
From Batch_Products          
Where Batch_Products.GRN_ID = @GRNID and Batch_Products.free = 0         
and Batch_Products.Serial = @Serial and
Batch_Products.UOM = @uom and
batch_products.product_Code = @Product_Code
Group By Batch_Products.Product_Code, Batch_Products.free          
    
  


