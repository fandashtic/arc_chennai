CREATE Procedure spr_list_Itemwise_Transfers_pidilite (	@FromDate datetime,
						@ToDate datetime)
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
"Transfer Out" = Sum(TransferOut), 
"Transfer Out Reporting UOM" = Sum(TransferOut / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 0) End),
"Transfer Out Conversion Factor" = Sum(TransferOut * IsNull(ConversionFactor, 0)),
"Transfer In" = Sum(TransferIn),
"Transfer In Reporting UOM" = Sum(TransferIn / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 0) End),
"Transfer In Conversion Factor" = Sum(TransferIn * IsNull(ConversionFactor, 0))
From #Temp, Items
Where #Temp.ItemCode collate SQL_Latin1_General_Cp1_CI_AS = Items.Product_Code
Group By #Temp.ItemCode, Items.ProductName


