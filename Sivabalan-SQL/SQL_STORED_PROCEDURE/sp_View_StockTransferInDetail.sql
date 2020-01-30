CREATE Procedure sp_View_StockTransferInDetail (@DocSerial int)
As
Select StockTransferInDetail.Product_Code, Items.ProductName, Batch_Number, 
Case 
When IsNull(ItemCategories.Price_Option, 0) = 0 And Items.Virtual_Track_Batches = 0 And Items.TrackPKD = 0 Then
	Items.PTS
Else
	StockTransferInDetail.PTS
End, 
Case 
When IsNull(ItemCategories.Price_Option, 0) = 0 And Items.Virtual_Track_Batches = 0 And Items.TrackPKD = 0 Then
	Items.PTR
Else
	StockTransferInDetail.PTR
End, 
Case 
When IsNull(ItemCategories.Price_Option, 0) = 0 And Items.Virtual_Track_Batches = 0 And Items.TrackPKD = 0 Then
	Items.ECP
Else
	StockTransferInDetail.ECP
End, 
Case 
When IsNull(ItemCategories.Price_Option, 0) = 0 And Items.Virtual_Track_Batches = 0 And Items.TrackPKD = 0 Then
	Items.Company_Price
Else
	StockTransferInDetail.SpecialPrice
End, StockTransferInDetail.Rate, 
StockTransferInDetail.Quantity, StockTransferInDetail.Amount, StockTransferInDetail.Expiry, 
StockTransferInDetail.PKD, StockTransferInDetail.TaxSuffered, 
StockTransferInDetail.TaxAmount, StockTransferInDetail.TotalAmount
,StockTransferInDetail.Promotion,StockTransferInDetail.TaxCode,
StockTransferInDetail.Serial,StockTransferInDetail.QuantityReceived,StockTransferInDetail.QuantityRejected,
StockTransferInDetail.DocumentQuantity,StockTransferInDetail.DocumentFreeQty
From StockTransferInDetail, Items, ItemCategories
Where StockTransferInDetail.DocSerial = @DocSerial And
StockTransferInDetail.Product_Code = Items.Product_Code And
Items.CategoryID = ItemCategories.CategoryID And
(StockTransferInDetail.QuantityReceived-StockTransferInDetail.QuantityRejected > 0 Or
StockTransferInDetail.Quantity > 0)
Order By StockTransferInDetail.Product_Code, StockTransferInDetail.Rate Desc


