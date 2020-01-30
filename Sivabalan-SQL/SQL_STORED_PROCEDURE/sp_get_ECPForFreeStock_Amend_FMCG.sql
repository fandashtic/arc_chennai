CREATE procedure sp_get_ECPForFreeStock_Amend_FMCG(@Bill_ID int, @Product_Code nVarchar(100), 
@Batch nVarchar(50), @PKD DateTime, @Expiry DateTime) as
DECLARE @GRN_ID INT

SELECT @GRN_ID = GRNID FROM BillAbstract WHERE DocumentID = @Bill_ID

select "PRICE" = CASE Price_Option   
WHEN 1 THEN  
Batch_products.purchasePRICE  
ELSE  
Items.purchase_PRICE  
END,  
"MRP" = items.mrp  
from Items, Batch_Products, ItemCategories
where Batch_Products.GRN_ID = @GRN_ID
And Items.Product_Code = Batch_Products.Product_Code
And Items.CategoryID = ItemCategories.CategoryID 
And Batch_Products.Product_Code = @Product_Code
And Batch_Products.Batch_Number = @Batch
And IsNull(Batch_Products.PKD,'') = IsNull(@PKD,'')
And IsNull(Batch_Products.EXPIRY,'') = IsNull(@Expiry,'')
And IsNull(Batch_Products.Free,0) = 0 




