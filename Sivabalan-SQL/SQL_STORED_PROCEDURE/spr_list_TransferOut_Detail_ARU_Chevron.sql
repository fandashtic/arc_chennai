CREATE Procedure spr_list_TransferOut_Detail_ARU_Chevron (@DocSerial int)
As

Declare @FREE As NVarchar(50)
Set @FREE = dbo.LookupDictionaryItem(N'Free', Default)

Select max(StockTransferOutDetail.Product_Code),
"Item Code" =  max(StockTransferOutDetail.Product_Code),
"Item Name" = max(Items.ProductName), "Batch" = max(StockTransferOutDetail.Batch_Number),
"PKD" = max(Batch_Products.PKD), "Expiry" = max(Batch_Products.Expiry),
"Quantity" =  Sum(StockTransferOutDetail.Quantity), 
"Rate" = max(StockTransferOutDetail.Rate),
"Amount" =  Sum(StockTransferOutDetail.Amount),
"PTS" = max(StockTransferOutDetail.PTS),
"PTR" = max(StockTransferOutDetail.PTR),
"ECP" = max(StockTransferOutDetail.ECP),
"Remarks" = Case 
When max(IsNull(StockTransferOutDetail.Free, 0)) = 0 Then
N''
Else
@FREE
End
From StockTransferOutDetail, Batch_Products, Items
Where StockTransferOutDetail.DocSerial = @DocSerial And
StockTransferOutDetail.Batch_Code = Batch_Products.Batch_Code And
StockTransferOutDetail.Product_Code = Items.Product_Code
Group By StockTransferOutDetail.Serial
Order By StockTransferOutDetail.Serial


