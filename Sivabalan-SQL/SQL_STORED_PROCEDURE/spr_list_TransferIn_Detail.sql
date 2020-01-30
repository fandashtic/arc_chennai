CREATE Procedure dbo.spr_list_TransferIn_Detail (@DocSerial int,@UOM nVarchar(30))
As
Select StockTransferInDetail.Product_Code,
"Item Code" = StockTransferInDetail.Product_Code,
"Item Name" = Items.ProductName,
"UOM" = CASE @UOM	WHEN 'Base UOM' THEN  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM)
WHEN 'UOM 1' THEN (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM1)
ELSE (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM2)
END,
"Quantity" = CASE @UOM	WHEN 'Base UOM' THEN Sum(StockTransferInDetail.Quantity)
WHEN 'UOM 1' THEN Cast(Sum(StockTransferInDetail.Quantity) / (Case IsNull(Max(Items.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM1_Conversion),1) End) As Decimal(18,6))
ELSE Cast(Sum(StockTransferInDetail.Quantity) / (Case IsNull(Max(Items.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM2_Conversion),1) End) As Decimal(18,6))
END,
"Rate" = CASE @UOM	WHEN 'Base UOM' THEN StockTransferInDetail.Rate
WHEN 'UOM 1' THEN Cast(StockTransferInDetail.Rate * (Case IsNull(Max(Items.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM1_Conversion),1) End) As Decimal(18,6))
ELSE Cast(StockTransferInDetail.Rate * (Case IsNull(Max(Items.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM2_Conversion),1) End) As Decimal(18,6))
END,
"Amount" = Sum(StockTransferInDetail.Amount),
"Batch" = StockTransferInDetail.Batch_Number,
"Expiry" = StockTransferInDetail.Expiry, "PKD" = StockTransferInDetail.PKD,
"PTS" = CASE @UOM	WHEN 'Base UOM' THEN StockTransferInDetail.PTS
WHEN 'UOM 1' THEN Cast(StockTransferInDetail.PTS * (Case IsNull(Max(Items.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM1_Conversion),1) End) As Decimal(18,6))
ELSE Cast(StockTransferInDetail.PTS * (Case IsNull(Max(Items.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM2_Conversion),1) End) As Decimal(18,6))
END,
"PTR" = CASE @UOM	WHEN 'Base UOM' THEN StockTransferInDetail.PTR
WHEN 'UOM 1' THEN Cast(StockTransferInDetail.PTR * (Case IsNull(Max(Items.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM1_Conversion),1) End) As Decimal(18,6))
ELSE Cast(StockTransferInDetail.PTR * (Case IsNull(Max(Items.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM2_Conversion),1) End) As Decimal(18,6))
END,

"ECP" = CASE @UOM	WHEN 'Base UOM' THEN StockTransferInDetail.ECP
WHEN 'UOM 1' THEN Cast(StockTransferInDetail.ECP * (Case IsNull(Max(Items.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM1_Conversion),1) End) As Decimal(18,6))
ELSE Cast(StockTransferInDetail.ECP * (Case IsNull(Max(Items.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM2_Conversion),1) End) As Decimal(18,6))
END,
"MRPPerPack" = isnull(StockTransferInDetail.MRPPerPack,0)
--CASE @UOM	WHEN 'Base UOM' THEN isnull(StockTransferInDetail.MRPPerPack,0)
--				WHEN 'UOM 1' THEN Cast(isnull(StockTransferInDetail.MRPPerPack,0) * (Case IsNull(Max(Items.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM1_Conversion),1) End) As Decimal(18,6))
--				ELSE Cast(isnull(StockTransferInDetail.MRPPerPack,0) * (Case IsNull(Max(Items.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM2_Conversion),1) End) As Decimal(18,6))
--				END
From StockTransferInDetail, Items
Where StockTransferInDetail.DocSerial = @DocSerial And
StockTransferInDetail.Product_Code = Items.Product_Code
Group By StockTransferInDetail.Product_Code, Items.ProductName,
StockTransferInDetail.Batch_Number, StockTransferInDetail.Expiry, StockTransferInDetail.PKD,
StockTransferInDetail.PTS, StockTransferInDetail.PTR, StockTransferInDetail.ECP, StockTransferInDetail.MRPPerPack  ,
StockTransferInDetail.Rate,Items.UOM,Items.UOM1,Items.UOM2
