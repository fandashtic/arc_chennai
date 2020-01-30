
CREATE Procedure dbo.spr_list_TransferOut_Detail (@DocSerial int,@UOM nVarchar(30))
As

Declare @FREE As NVarchar(50)
Set @FREE = dbo.LookupDictionaryItem(N'Free', Default)

Select max(StockTransferOutDetail.Product_Code),
"Item Code" =  max(StockTransferOutDetail.Product_Code),
"Item Name" = max(Items.ProductName), "Batch" = max(StockTransferOutDetail.Batch_Number),
"PKD" = max(Batch_Products.PKD), "Expiry" = max(Batch_Products.Expiry),
"UOM" = CASE @UOM	WHEN 'Base UOM' THEN  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM)
WHEN 'UOM 1' THEN (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM1)
ELSE (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM2)
END,
"Quantity" =  CASE @UOM	WHEN 'Base UOM' THEN Sum(StockTransferOutDetail.Quantity)
WHEN 'UOM 1' THEN Cast(Sum(StockTransferOutDetail.Quantity) / (Case IsNull(Max(Items.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM1_Conversion),1) End) As Decimal(18,6))
ELSE Cast(Sum(StockTransferOutDetail.Quantity) / (Case IsNull(Max(Items.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM2_Conversion),1) End) As Decimal(18,6))
END,
"Rate" = CASE @UOM	WHEN 'Base UOM' THEN max(StockTransferOutDetail.Rate)
WHEN 'UOM 1' THEN Cast(max(StockTransferOutDetail.Rate) * (Case IsNull(Max(Items.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM1_Conversion),1) End) As Decimal(18,6))
ELSE Cast(max(StockTransferOutDetail.Rate) * (Case IsNull(Max(Items.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM2_Conversion),1) End) As Decimal(18,6))
END,
"Amount" =  Sum(StockTransferOutDetail.Amount),
"PTS" = CASE @UOM	WHEN 'Base UOM' THEN  max(StockTransferOutDetail.PTS)
WHEN 'UOM 1' THEN Cast(max(StockTransferOutDetail.PTS) * (Case IsNull(Max(Items.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM1_Conversion),1) End) As Decimal(18,6))
ELSE Cast(max(StockTransferOutDetail.PTS) * (Case IsNull(Max(Items.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM2_Conversion),1) End) As Decimal(18,6))
END,
"PTR" = CASE @UOM	WHEN 'Base UOM' THEN  max(StockTransferOutDetail.PTR)
WHEN 'UOM 1' THEN Cast(max(StockTransferOutDetail.PTR) * (Case IsNull(Max(Items.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM1_Conversion),1) End) As Decimal(18,6))
ELSE Cast(max(StockTransferOutDetail.PTR) * (Case IsNull(Max(Items.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM2_Conversion),1) End) As Decimal(18,6))
END,
"ECP" = CASE @UOM	WHEN 'Base UOM' THEN  max(StockTransferOutDetail.ECP)
WHEN 'UOM 1' THEN Cast(max(StockTransferOutDetail.ECP) * (Case IsNull(Max(Items.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM1_Conversion),1) End) As Decimal(18,6))
ELSE Cast(max(StockTransferOutDetail.ECP) * (Case IsNull(Max(Items.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM2_Conversion),1) End) As Decimal(18,6))
END,
"MRPPerPack" = max(isnull(StockTransferOutDetail.MRPPerPack,0)),
--CASE @UOM	WHEN 'Base UOM' THEN   max(isnull(StockTransferOutDetail.MRPPerPack,0))
--							WHEN 'UOM 1' THEN Cast(max(isnull(StockTransferOutDetail.MRPPerPack,0))  * (Case IsNull(Max(Items.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM1_Conversion),1) End) As Decimal(18,6))
--							ELSE Cast(max(isnull(StockTransferOutDetail.MRPPerPack,0)) * (Case IsNull(Max(Items.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM2_Conversion),1) End) As Decimal(18,6))
--							END,
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
Group By StockTransferOutDetail.Serial,Items.UOM,Items.UOM1,Items.UOM2
Order By StockTransferOutDetail.Serial
