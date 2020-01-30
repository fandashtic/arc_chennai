Create Procedure merp_Sp_CheckParamValues(@RepID int, @paramnames nVarchar(2000), @ParamValues nVarchar(2000))
As
Begin
Declare @TblItemInfo table([ID] Int Identity(1,1), ItemInfo nvarchar(2000))
Declare @TblItemInfo2 table([ID] Int Identity(1,1), ItemInfo2 nvarchar(2000))
Declare @WeekValue int
Declare @DefaultParameterValues int
Declare @ID int
Declare @ParamValueSended int

Declare @ReportDate DateTime
Declare @DateMonth  as nVarchar(25)
Declare @DayClose DateTime

Set Dateformat dmy

Insert Into @TblItemInfo
select * from dbo.sp_splitin2Rows(@ParamValues,'|')

Insert Into @TblItemInfo2
select * from dbo.sp_splitin2Rows(@paramnames,'|')
if (@RepID = 1330)
Begin

If (Select isNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') = 1
Select @DayClose = dbo.StripTimeFromDate(LastInventoryUpload) From Setup

Select @DateMonth = ItemInfo From @TblItemInfo
Set @ReportDate = cast(Cast('01' + '/' +  @DateMonth as nVarchar(15)) as datetime)
Set @ReportDate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@ReportDate)+1,0))

If dbo.Striptimefromdate(@ReportDate) <= @DayClose
Begin
Select 1 --True
End
Else
Select 0 --False
End

Else
Begin
If Exists ( Select ReportID from tbl_merp_Paramvalues where ReportID = @RepID)
Begin
If exists (Select T1.*, T2.* , NT.*
From @TblItemInfo T1 Inner join  @TblItemInfo2 T2 On T1.ID = T2.ID
Join tbl_merp_Paramvalues NT On NT.ParameterName = T2.ItemInfo2 and
T1.ItemInfo = NT.DefaultParameterValues
where  NT.ReportID = @RepID and IsNull(NT.DefaultParameterValues,'') <> '')
Begin
Select 1 --True
End
Else
Select 0 --False
End
Else
If Exists(Select 'x' From tbl_mERP_OtherReportsUpload Where ReportDataID = @RepID)
Begin
Create Table #ARUFDtTDt (FDt DateTime, TDt DateTime)
Declare @FDt DateTime
Declare @TDt DateTime
Select @FDt = ItemInfo From @TblItemInfo V Join @TblItemInfo2 P On P.ID = V.ID And P.ItemInfo2 = 'From Date'
Select @TDt = ItemInfo From @TblItemInfo V Join @TblItemInfo2 P On P.ID = V.ID And P.ItemInfo2 = 'To Date'
Insert Into #ARUFDtTDt (FDt ,TDt ) Exec mERP_sp_Get_ARUFromToDate @repID,@FDt ,@TDt
IF Exists(Select 'x' From #ARUFDtTDt Where FDt = @FDt And TDt = @TDt)
Select 1 --True
Else
Select 0 --False
Drop Table #ARUFDtTDt
End
Else
Select 1 --True
End
End
