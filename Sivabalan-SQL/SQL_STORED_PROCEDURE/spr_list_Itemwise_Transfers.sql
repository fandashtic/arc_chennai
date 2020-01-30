CREATE Procedure [dbo].[spr_list_Itemwise_Transfers] (	@FromDate datetime,
@ToDate datetime ,@Uom nVarchar(30))
As
Create Table #Temp(
ItemCode nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
TransferOut Decimal(18,6) null,
TransferIn Decimal(18,6) null)

Insert Into #Temp (ItemCode, TransferIn)
(Select StockTransferInDetail.Product_Code, Sum(Quantity)
From StockTransferInAbstract, StockTransferInDetail, Items
Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial And
StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate And
StockTransferInDetail.Product_Code = Items.Product_Code
And StockTransferInAbstract.Status & 192 = 0
Group By StockTransferInDetail.Product_Code)

Insert Into #Temp (ItemCode, TransferOut)
(Select StockTransferOutDetail.Product_Code, Sum(Quantity)
From StockTransferOutAbstract, StockTransferOutDetail, Items
Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial And
StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate And
StockTransferOutDetail.Product_Code = Items.Product_Code
And StockTransferOutAbstract.Status & 192 = 0
Group By StockTransferOutDetail.Product_Code)

Select #Temp.ItemCode, "Item Name" = Items.ProductName,
"UOM" = CASE @UOM	WHEN 'Base UOM' THEN  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM)
WHEN 'UOM 1' THEN (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM1)
ELSE (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM2)
END,
"Transfer Out" = CASE @UOM	WHEN 'Base UOM' THEN Sum(TransferOut)
WHEN 'UOM 1' THEN Cast(Sum(TransferOut) / (Case IsNull(Max(Items.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM1_Conversion),1) End) As Decimal(18,6))
ELSE Cast(Sum(TransferOut) / (Case IsNull(Max(Items.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM2_Conversion),1) End) As Decimal(18,6))
END,
"Transfer In" = CASE @UOM	WHEN 'Base UOM' THEN Sum(TransferIn)
WHEN 'UOM 1' THEN Cast(Sum(TransferIn) / (Case IsNull(Max(Items.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM1_Conversion),1) End) As Decimal(18,6))
ELSE Cast(Sum(TransferIn) / (Case IsNull(Max(Items.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM2_Conversion),1) End) As Decimal(18,6))
END
From #Temp, Items
Where #Temp.ItemCode collate SQL_Latin1_General_Cp1_CI_AS = Items.Product_Code
Group By #Temp.ItemCode, Items.ProductName,Items.UOM,Items.UOM1,Items.UOM2


