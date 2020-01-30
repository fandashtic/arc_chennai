CREATE Procedure sp_Get_AmendBatch_FMCG(@GRNID Int,
					@ItemCode nvarchar(20),@Serial int=0)
As
Select Items.Virtual_Track_Batches, Items.TrackPKD, ItemCategories.Price_Option,
Replace(Batch_Products.Batch_Number, ',', Char(9)), Batch_Products.Expiry, Batch_Products.PKD,
Batch_Products.QuantityReceived, Batch_Products.SalePrice, Batch_Products.PurchasePrice,
Batch_Products.Batch_Code,batch_products.TaxSuffered,batch_products.GRNTaxID,batch_products.GRNTaxSuffered 
From Batch_Products, Items, ItemCategories
Where Batch_Products.Product_Code = Items.Product_Code 
And Items.CategoryID = ItemCategories.CategoryID 
And Batch_Products.GRN_ID = @GRNID 
And Batch_Products.serial = @serial 
and Batch_Products.Free = 0 
And Items.Product_Code = @ItemCode



