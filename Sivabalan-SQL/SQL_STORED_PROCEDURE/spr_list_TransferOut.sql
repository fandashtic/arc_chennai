CREATE Procedure [dbo].[spr_list_TransferOut] (
@WareHouse	nVarchar(2550),
@FromDate 	DateTime,
@ToDate 	DateTime,
@UOM nVarchar(30)
)
As

Declare @Delimeter Char(1)
Declare @AMENDED As NVarchar(50)
Declare @AMENDMENT As NVarchar(50)
Declare @CANCELLED As NVarchar(50)

Set @AMENDED = dbo.LookupDictionaryItem(N'Amended', Default)
Set @AMENDMENT = dbo.LookupDictionaryItem(N'Amendment', Default)
Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default)
Set @Delimeter=Char(15)

Create Table #tmpWareHouse(WareHouse_Name nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

If @WareHouse=N'%'
Insert Into #tmpWareHouse Select WareHouse_Name From WareHouse
Else
Insert Into #tmpWareHouse Select * From dbo.sp_SplitIn2Rows(@WareHouse,@Delimeter)


Select
StockTransferOutAbstract.DocSerial,

"Stock Transfer ID" 	= 	IsNull(StockTransferOutAbstract.DocPrefix,N'') +
Cast(StockTransferOutAbstract.DocumentID as nVarchar),

"Date" 			= 	StockTransferOutAbstract.DocumentDate,

"WareHouse" 		= 	WareHouse.WareHouse_Name,

"Value" 		= 	StockTransferOutAbstract.NetValue,

"Reference" 		= 	StockTransferOutAbstract.Reference,

"User Name" 		= 	StockTransferOutAbstract.UserName,

"Status"		= 	Case
When Status & 64 <> 0 then
@CANCELLED
When Status & 128 <> 0 then
@AMENDED
When Status & 16 <> 0 then
@AMENDMENT
Else
N''
End
From
StockTransferOutAbstract, WareHouse
Where
StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate And
StockTransferOutAbstract.WareHouseID = WareHouse.WareHouseID And
WareHouse.WareHouse_Name In (Select WareHouse_Name From #tmpWareHouse)
Order By
StockTransferOutAbstract.DocumentID,
StockTransferOutAbstract.DocumentDate,
WareHouse.WareHouse_Name
