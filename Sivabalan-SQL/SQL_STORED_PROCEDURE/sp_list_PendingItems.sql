Create procedure sp_list_PendingItems (@DocumentSerial int,@Flag int=0)  
as  
if @Flag=0   
Begin   
	select VanStatementDetail.Product_Code, Items.ProductName,   
	VanStatementDetail.Batch_Number, Batch_Products.Expiry, Sum(VanStatementDetail.Quantity),  
	-- Sum(VanStatementDetail.Pending), 
	-- Modified for taking the Correct UOM
	Sum(VanStatementDetail.Pending)  /  IsNull(( Select Case VanStatementDetail.UOM 
	When Items.UOM then 1         
	When Items.UOM1 Then Case IsNull(UOM1_Conversion, 1) When 0 then 1 Else IsNull(UOM1_Conversion, 1) End   
	When Items.UOM2 Then Case IsNull(UOM2_Conversion, 1) When 0 Then 1 Else IsNull(UOM2_Conversion, 1) End 
	End  
	From Items Where Product_Code = VanStatementDetail.Product_Code), 1),
	Max(VanStatementDetail.UOMPrice) As SalePrice, Sum(VanStatementDetail.Amount),  
	ItemCategories.Price_Option, Items.Track_Batches, ItemCategories.Track_Inventory, MIN(VanStatementDetail.Batch_Code),   
	IsNull(Batch_Products.Free, 0),VanStatementDetail.ptr ,
	VanStatementDetail.UOM as UOMDesc,Sum(VanStatementDetail.Pending ) AS BaseQty,VanStatementDetail.VanTransferID,VanStatementDetail.TransferItemSerial
	, Batch_Products.MRPPerPack
	from VanStatementDetail
	Left Outer Join Batch_Products On VanStatementDetail.Batch_Code = Batch_Products.Batch_Code
	Inner Join Items On VanStatementDetail.Product_Code = Items.Product_Code
	Inner Join ItemCategories   On Items.CategoryID = ItemCategories.CategoryID  
	where VanStatementDetail.Pending > 0 and VanStatementDetail.DocSerial = @DocumentSerial
	group by VanStatementDetail.Product_Code, Items.ProductName, VanStatementDetail.Batch_Number,   
	VanStatementDetail.SalePrice, Batch_Products.Expiry, ItemCategories.Price_Option, Items.Track_Batches,   
	ItemCategories.Track_Inventory, Batch_Products.Free, VanStatementDetail.ptr ,VanStatementDetail.VanTransferID,VanStatementDetail.TransferItemSerial, Vanstatementdetail.UOM
	, Batch_Products.MRPPerPack
	order by VanStatementDetail.VanTransferID,VanStatementDetail.TransferItemSerial
End  
else if @Flag=1   
Begin  
	select VanStatementDetail.Product_Code As Product_Code,   
	Items.ProductName As ProductName,   
	Max(VanStatementDetail.Batch_Number) As Batch_Number, Max(Batch_Products.Expiry) As Expiry,   
	Sum(VanStatementDetail.UOMQty),
	--Sum(VanStatementDetail.Pending )
	Sum(VanStatementDetail.Pending)  /  IsNull(( Select Case VanStatementDetail.UOM 
	When Items.UOM then 1         
	When Items.UOM1 Then Case IsNull(UOM1_Conversion, 1) When 0 then 1 Else IsNull(UOM1_Conversion, 1) End   
	When Items.UOM2 Then Case IsNull(UOM2_Conversion, 1) When 0 Then 1 Else IsNull(UOM2_Conversion, 1) End 
	End  
	From Items Where Product_Code = VanStatementDetail.Product_Code), 1)  ,
	Max(VanStatementDetail.UOMPrice) As SalePrice, Sum(VanStatementDetail.Amount),  
	Max(ItemCategories.Price_Option) As Price_Option, Max(Items.Track_Batches) As Track_Batches,   
	Max(ItemCategories.Track_Inventory) As Track_Inventory, MIN(VanStatementDetail.Batch_Code),   
	IsNull(Max(Batch_Products.Free), 0),Max(VanStatementDetail.ptr) As PTR,
	VanStatementDetail.UOM as UOMDesc,Sum(VanStatementDetail.Pending ) AS BaseQty,VanStatementDetail.VanTransferID,VanStatementDetail.TransferItemSerial
	, Batch_Products.MRPPerPack
	from VanStatementDetail
	Left Outer Join  Batch_Products On VanStatementDetail.Batch_Code = Batch_Products.Batch_Code
	Inner Join Items On VanStatementDetail.Product_Code = Items.Product_Code
	Inner Join ItemCategories On  Items.CategoryID = ItemCategories.CategoryID  
	where VanStatementDetail.DocSerial = @DocumentSerial 
	group by VanStatementDetail.Product_Code,Items.ProductName,VanStatementDetail.VanTransferID,VanStatementDetail.TransferItemSerial,Vanstatementdetail.UOM  
	, Batch_Products.MRPPerPack
	order by VanStatementDetail.VanTransferID,VanStatementDetail.TransferItemSerial
End  
