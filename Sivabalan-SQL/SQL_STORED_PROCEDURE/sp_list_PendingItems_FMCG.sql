CREATE procedure [dbo].[sp_list_PendingItems_FMCG] (@DocumentSerial int,@Flag int=0)
as
if @Flag=0 
Begin 
	select VanStatementDetail.Product_Code, Items.ProductName, 
	VanStatementDetail.Batch_Number, Batch_Products.Expiry, Sum(VanStatementDetail.Quantity),
	Sum(VanStatementDetail.Pending), VanStatementDetail.SalePrice, Sum(VanStatementDetail.Amount),
	ItemCategories.Price_Option, Items.Track_Batches, ItemCategories.Track_Inventory, MIN(VanStatementDetail.Batch_Code), 
	IsNull(Batch_Products.Free, 0),VanStatementDetail.SalePrice
	from VanStatementDetail, Batch_Products, Items, ItemCategories
	where VanStatementDetail.Batch_Code *= Batch_Products.Batch_Code
	And VanStatementDetail.Product_Code = Items.Product_Code
	And VanStatementDetail.Pending > 0 and VanStatementDetail.DocSerial = @DocumentSerial and 
	Items.CategoryID = ItemCategories.CategoryID
	group by VanStatementDetail.Product_Code, Items.ProductName, VanStatementDetail.Batch_Number, 
	VanStatementDetail.SalePrice, Batch_Products.Expiry, ItemCategories.Price_Option, Items.Track_Batches, 
	ItemCategories.Track_Inventory, Batch_Products.Free, VanStatementDetail.SalePrice
End
else if @Flag=1 
Begin
	select VanStatementDetail.Product_Code, Items.ProductName, 
	VanStatementDetail.Batch_Number, Batch_Products.Expiry, Sum(VanStatementDetail.Quantity),
	Sum(VanStatementDetail.Pending), VanStatementDetail.SalePrice, Sum(VanStatementDetail.Amount),
	ItemCategories.Price_Option, Items.Track_Batches, ItemCategories.Track_Inventory, MIN(VanStatementDetail.Batch_Code), 
	IsNull(Batch_Products.Free, 0),VanStatementDetail.SalePrice
	from VanStatementDetail, Batch_Products, Items, ItemCategories
	where VanStatementDetail.Batch_Code *= Batch_Products.Batch_Code
	And VanStatementDetail.Product_Code = Items.Product_Code
	and VanStatementDetail.DocSerial = @DocumentSerial and 
	Items.CategoryID = ItemCategories.CategoryID
	group by VanStatementDetail.Product_Code, Items.ProductName, VanStatementDetail.Batch_Number, 
	VanStatementDetail.SalePrice, Batch_Products.Expiry, ItemCategories.Price_Option, Items.Track_Batches,
    ItemCategories.Track_Inventory, Batch_Products.Free,VanStatementDetail.SalePrice
End
