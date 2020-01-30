CREATE procedure [dbo].[sp_Print_StockTransferOutDetailReceived] (@DocSerial int)
As

Declare @FREE As NVarchar(50)

Set @FREE = dbo.LookupDictionaryItem(N'Free', Default)

Select "Item Code" = Case IsNull(StockTransferOutDetailReceived.Product_Code, N'')
When N'' Then
StockTransferOutDetailReceived.ForumCode
Else
StockTransferOutDetailReceived.Product_Code
End,
"Item Name" = Items.ProductName, "Batch" = StockTransferOutDetailReceived.Batch_Number,
"PTS" = StockTransferOutDetailReceived.PTS,
"PTR" = StockTransferOutDetailReceived.PTR,
"ECP" = StockTransferOutDetailReceived.ECP,
"SpecialPrice" = StockTransferOutDetailReceived.SpecialPrice,
"Rate" = Case StockTransferOutDetailReceived.Rate
When 0 then
@FREE
Else
Cast(StockTransferOutDetailReceived.Rate as nvarchar)
End,
"Quantity" = StockTransferOutDetailReceived.Quantity,
"Free" = IsNull(StockTransferOutDetailReceived.Free, 0),
"Amount" = StockTransferOutDetailReceived.Amount,
"Expiry" = IsNull(StockTransferOutDetailReceived.Expiry, N''),
"PKD" = IsNull(StockTransferOutDetailReceived.PKD, N''),
"Tax Suffered" = IsNull(StockTransferOutDetailReceived.TaxSuffered, 0),
"Tax Amount" = IsNull(StockTransferOutDetailReceived.TaxAmount, 0),
"Total Amount" = IsNull(StockTransferOutDetailReceived.TotalAmount, 0)
From StockTransferOutDetailReceived, Items
Where StockTransferOutDetailReceived.DocSerial = @DocSerial And
StockTransferOutDetailReceived.Product_Code *= Items.Product_Code
