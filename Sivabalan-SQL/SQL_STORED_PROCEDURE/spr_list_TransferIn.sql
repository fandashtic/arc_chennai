CREATE Procedure spr_list_TransferIn (
@WareHouse nVarchar(2550),
@FromDate DateTime,
@ToDate  DateTime,
@UOM nVarchar(30)
)
As

Declare @Delimeter Char(1)
Declare @OPEN As NVarchar(50)
Declare @AMENDED As NVarchar(50)
Declare @AMENDMENT As NVarchar(50)
Declare @CANCELLED As NVarchar(50)
Declare @DIRECTSTOCKTRANSFERIN As NVarchar(50)
Declare @STOCKTRANSFERINFROMOUT As NVarchar(50)

Set @OPEN = dbo.LookupDictionaryItem(N'',Default)  --Open
Set @AMENDED = dbo.LookupDictionaryItem(N'Amended', Default)
Set @AMENDMENT = dbo.LookupDictionaryItem(N'Amendment', Default)
Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default)
Set @DIRECTSTOCKTRANSFERIN = dbo.LookupDictionaryItem(N'Direct Stock Transfer In', Default)
Set @STOCKTRANSFERINFROMOUT = dbo.LookupDictionaryItem(N'Stock Transfer In From Out', Default)

Set @Delimeter=Char(15)

Declare @tmpWareHouse Table(WareHouse_Name nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

If @WareHouse=N'%'
Insert Into @tmpWareHouse Select WareHouse_Name From WareHouse
Else
Insert Into @tmpWareHouse Select * From dbo.sp_SplitIn2Rows(@WareHouse,@Delimeter)

Select
StockTransferInAbstract.DocSerial,

"Stock Transfer ID" =  IsNull(StockTransferInAbstract.DocPrefix, N'')
+ Cast(StockTransferInAbstract.DocumentID as nVarchar),

"Date"    =  StockTransferInAbstract.DocumentDate,

"WareHouse"   =  WareHouse.WareHouse_Name,

"Reference"   =  IsNull(StockTransferInAbstract.ReferenceSerial, N''),

"User Name"   =  StockTransferInAbstract.UserName,

"Value"   = StockTransferInAbstract.NetValue,

"Type"    =  Case DocReference
When N'' Then
@DIRECTSTOCKTRANSFERIN
Else
@STOCKTRANSFERINFROMOUT
End,

"Status"   =  (Select Case
when IsNull(Status,0) & 64 <> 0 then @CANCELLED
when isnull(status & 128,0 ) = 128 and isnull(reference,0) <> 0 then @AMENDED
when isnull(status & 128,0 ) = 128 and isnull(reference,0) = 0  then @AMENDED
when isnull(status & 128,0 ) = 0 and isnull(reference,0) <> 0  then @AMENDMENT
when isnull(status & 128,0 ) = 0 and isnull(reference,0) = 0  then @OPEN
End
),

"Tax Type" = Case IsNull(StockTransferInAbstract.TaxType , 0) When 1 Then N'LST'
When 2 Then N'CST'
When 3 Then N'FLST' End

From
StockTransferInAbstract, WareHouse

Where
WareHouse.WareHouse_Name In (Select WareHouse_Name From @tmpWareHouse) And
StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate And
StockTransferInAbstract.WareHouseID = WareHouse.WareHouseID


Order By
StockTransferInAbstract.DocumentID,
StockTransferInAbstract.DocumentDate,
WareHouse.WareHouse_Name


