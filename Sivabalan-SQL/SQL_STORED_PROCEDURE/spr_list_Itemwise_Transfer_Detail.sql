Create Procedure dbo.spr_list_Itemwise_Transfer_Detail (@ItemCode nvarchar(20),
@FromDate datetime,
@ToDate datetime,@UOM nVarchar(30))
As

Declare @STOCKTRANSFEROUT As NVarchar(50)
Declare @FREE As NVarchar(50)
Declare @DIRECTSTOCKTRANSFERIN As NVarchar(50)
Declare @STOCKTRANSFERINFROMOUTNOTE As NVarchar(50)

Set @STOCKTRANSFEROUT = dbo.LookupDictionaryItem(N'Stock Transfer Out', Default)
Set @FREE = dbo.LookupDictionaryItem(N'Free', Default)
Set @DIRECTSTOCKTRANSFERIN = dbo.LookupDictionaryItem(N'Direct Stock Transfer In', Default)
Set @STOCKTRANSFERINFROMOUTNOTE = dbo.LookupDictionaryItem(N'Stock Transfer In From Out Note', Default)

Select StockTransferOutAbstract.DocSerial,
"Stock Transfer No" = IsNull(StockTransferOutAbstract.DocPrefix, N'')
+ Cast(StockTransferOutAbstract.DocumentID as nvarchar),
"Date" = StockTransferOutAbstract.DocumentDate,
"WareHouse" = WareHouse.WareHouse_Name,
"Reference" = StockTransferOutAbstract.Reference,
"Type" = @STOCKTRANSFEROUT,
"Quantity" =CASE @UOM	WHEN 'Base UOM' THEN  Sum(StockTransferOutDetail.Quantity)
WHEN 'UOM 1' THEN Cast(Sum(StockTransferOutDetail.Quantity) / (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(Sum(StockTransferOutDetail.Quantity) / (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Batch" = IsNull(StockTransferOutDetail.Batch_Number, N''),
"PKD" = Batch_Products.PKD,
"Expiry" = Batch_Products.Expiry,
"PTS" = CASE @UOM	WHEN 'Base UOM' THEN  IsNull(StockTransferOutDetail.PTS, 0)
WHEN 'UOM 1' THEN Cast(IsNull(StockTransferOutDetail.PTS, 0) * (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(IsNull(StockTransferOutDetail.PTS, 0) * (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"PTR" = CASE @UOM	WHEN 'Base UOM' THEN  IsNull(StockTransferOutDetail.PTR, 0)
WHEN 'UOM 1' THEN Cast(IsNull(StockTransferOutDetail.PTR, 0) * (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(IsNull(StockTransferOutDetail.PTR, 0) * (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"ECP" = CASE @UOM	WHEN 'Base UOM' THEN  IsNull(StockTransferOutDetail.ECP, 0)
WHEN 'UOM 1' THEN Cast(IsNull(StockTransferOutDetail.ECP, 0) * (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(IsNull(StockTransferOutDetail.ECP, 0) * (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"MRPPerPack" =  IsNull(StockTransferOutDetail.MRPPerPack, 0),
--CASE @UOM	WHEN 'Base UOM' THEN  IsNull(StockTransferOutDetail.MRPPerPack, 0)
--WHEN 'UOM 1' THEN Cast(IsNull(StockTransferOutDetail.MRPPerPack, 0) * (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
--ELSE Cast(IsNull(StockTransferOutDetail.MRPPerPack, 0) * (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
--END,
"Rate" = CASE @UOM	WHEN 'Base UOM' THEN Sum(StockTransferOutDetail.Rate)
WHEN 'UOM 1' THEN Cast(Sum(StockTransferOutDetail.Rate) * (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(Sum(StockTransferOutDetail.Rate) * (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Amount" = Sum(StockTransferOutDetail.Amount),
"Free" = Case
When IsNull(StockTransferOutDetail.Free, 0) = 0 then
N''
Else
@FREE
End
From StockTransferOutAbstract
Inner Join StockTransferOutDetail On StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial
Inner Join WareHouse On StockTransferOutAbstract.WareHouseID = WareHouse.WareHouseID
Left Outer Join Batch_Products  On StockTransferOutDetail.Batch_Code = Batch_Products.Batch_Code
Inner Join Items I on StockTransferOutDetail.Product_Code = I.Product_Code
Where StockTransferOutAbstract.DocumentDate Between  @FromDate And @ToDate And
StockTransferOutDetail.Product_Code = @ItemCode And
StockTransferOutAbstract.Status & 192 = 0
Group By StockTransferOutDetail.Product_Code,
StockTransferOutAbstract.DocSerial,
StockTransferOutAbstract.DocPrefix,
StockTransferOutAbstract.DocumentID,
StockTransferOutAbstract.DocumentDate,
StockTransferOutAbstract.Reference,
WareHouse.WareHouse_Name,
StockTransferOutDetail.Batch_Number,
Batch_Products.Expiry, Batch_Products.PKD,
IsNull(StockTransferOutDetail.PTS, 0),
IsNull(StockTransferOutDetail.PTR, 0), IsNull(StockTransferOutDetail.ECP, 0),
IsNull(StockTransferOutDetail.MRPPerPack, 0),
IsNull(StockTransferOutDetail.Free, 0) ,I.UOM2_Conversion,I.UOM1_Conversion

Union All

Select StockTransferInAbstract.DocSerial,
IsNull(StockTransferInAbstract.DocPrefix, N'') +
Cast(StockTransferInAbstract.DocumentID as nvarchar),
StockTransferInAbstract.DocumentDate,
WareHouse.WareHouse_Name,
ReferenceSerial,
Case DocReference
When N'' Then
@DIRECTSTOCKTRANSFERIN
Else
@STOCKTRANSFERINFROMOUTNOTE
End,
CASE @UOM	WHEN 'Base UOM' THEN  Sum(StockTransferInDetail.Quantity)
WHEN 'UOM 1' THEN Cast(Sum(StockTransferInDetail.Quantity) / (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(Sum(StockTransferInDetail.Quantity) / (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
IsNull(StockTransferInDetail.Batch_Number, N''),
StockTransferInDetail.PKD,
StockTransferInDetail.Expiry,

CASE @UOM	WHEN 'Base UOM' THEN  IsNull(StockTransferInDetail.PTS, 0)
WHEN 'UOM 1' THEN Cast(IsNull(StockTransferInDetail.PTS, 0) * (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(IsNull(StockTransferInDetail.PTS, 0) * (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
CASE @UOM	WHEN 'Base UOM' THEN  IsNull(StockTransferInDetail.PTR, 0)
WHEN 'UOM 1' THEN Cast(IsNull(StockTransferInDetail.PTR, 0) * (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(IsNull(StockTransferInDetail.PTR, 0) * (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
CASE @UOM	WHEN 'Base UOM' THEN  IsNull(StockTransferInDetail.ECP, 0)
WHEN 'UOM 1' THEN Cast(IsNull(StockTransferInDetail.ECP, 0) * (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(IsNull(StockTransferInDetail.ECP, 0) * (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
IsNull(StockTransferInDetail.MRPPerPack, 0),
--CASE @UOM	WHEN 'Base UOM' THEN  IsNull(StockTransferInDetail.MRPPerPack, 0)
--			WHEN 'UOM 1' THEN Cast(IsNull(StockTransferInDetail.MRPPerPack, 0) * (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
--			ELSE Cast(IsNull(StockTransferInDetail.MRPPerPack, 0) * (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
--			END,
CASE @UOM	WHEN 'Base UOM' THEN  Sum(StockTransferInDetail.Rate)
WHEN 'UOM 1' THEN Cast(Sum(StockTransferInDetail.Rate) * (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(Sum(StockTransferInDetail.Rate) * (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
Sum(StockTransferInDetail.Amount),
(Case
When IsNull(Batch_Products.Free, 0) = 0 then
N''
Else
@FREE
End)
From StockTransferInAbstract
Inner Join  StockTransferInDetail On  StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial
Inner Join WareHouse On StockTransferInAbstract.WareHouseID = WareHouse.WareHouseID
Left Outer join Batch_Products  On StockTransferInDetail.Batch_Code = Batch_Products.Batch_Code
Inner Join Items I on StockTransferInDetail.Product_Code = I.Product_Code
Where
StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate And
StockTransferInDetail.Product_Code = @ItemCode And
StockTransferInAbstract.Status & 192 = 0
Group By StockTransferInDetail.Product_Code,
StockTransferInAbstract.DocSerial,
StockTransferInAbstract.DocumentID,
StockTransferInAbstract.DocumentDate,
StockTransferInAbstract.ReferenceSerial,
StockTransferInAbstract.DocPrefix,
StockTransferInAbstract.DocReference,
IsNull(StockTransferInDetail.Batch_Number, N''), StockTransferInDetail.PKD,
StockTransferInDetail.Expiry, IsNull(StockTransferInDetail.PTS, 0),
IsNull(StockTransferInDetail.PTR, 0), IsNull(StockTransferInDetail.ECP, 0),
IsNull(StockTransferInDetail.MRPPerPack, 0),
IsNull(Batch_Products.Free, 0),
WareHouse.WareHouse_Name ,I.UOM2_Conversion,I.UOM1_Conversion
