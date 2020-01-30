CREATE Procedure mERP_spr_DSRouteInfo_Upload (@FromDate DateTime, @ToDate DateTime)
AS
Set dateformat dmy
Begin
Declare @WDCode nVarchar(50)
Select @WDCode = RegisteredOwner from Setup

Select 1 As SNo,@WDCode As 'WD Code',
@WDCode As 'WD Dest',
@FromDate As 'From Date',
@Todate As 'To Date',
D.DSID As 'DS ID',
S.Salesman_Name 'DS Name',
Case When S.Active = 1 Then 'Active' Else 'Inactive' End 'Active',
(Select DS.DSTypeValue From DSType_Details DD
Inner Join DSType_Master DS on DD.DsTypeID = DS.DSTypeID
Where DD.SalesmanID = D.DSID And DD.DSTypeCtlPos = 1) As 'DS Type',
D.BeatID 'Beat ID',
B.Description 'Beat Name',
Route,
Convert(nVarchar(10),D.CreationDate,103) + N' ' + Convert(nVarchar(8),D.CreationDate,108) As 'Last Upload Date',
D.Flag
Into #TempDSType
from  DSRouteInfo D
Inner Join SalesMan S On DsID = S.SalesmanID
Inner Join Beat B on D.BeatID = B.BeatID
--where dbo.StripDateFromTime(isnull(D.CreationDate,getdate())) between @Fromdate and @Todate


If (Select count(*) from #TempDSType Where Flag <> 0 or Flag IS NULL) = 0
Begin
If (Select count(*) from #TempDSType Where Flag = 0) = 0
Begin
Alter Table #TempDSType Drop Column Flag
Select * from #TempDSType
Goto SKIP
End
Else
Begin
Alter Table #TempDSType Drop Column Flag
Select * from #TempDSType
End
End

Skip:
Drop Table #TempDSType

End
