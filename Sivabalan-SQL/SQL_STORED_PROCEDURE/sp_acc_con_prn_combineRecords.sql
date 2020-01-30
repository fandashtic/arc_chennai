CREATE Procedure sp_acc_con_prn_combineRecords(@fromdate datetime,@todate datetime ,@parentid  integer,@parentid1 integer,@ReportHeader nVarchar(255) = Null)
As
DECLARE @MaxRows1 int
DECLARE @MaxRows2 int
DECLARE @MaxRows int
DECLARE @Ctr int
DECLARE @AccountName nvarchar(128)
Declare @Amount decimal(18,2)

Create Table #TempRec1(RowID int identity not null, AccountName1 nVarchar(255),Amount1 Decimal(18,2))
Create Table #TempRec2(RowID int identity not null, AccountName1 nVarchar(255),Amount1 Decimal(18,2))
Create Table #TempRec(RowID int , AccountName1 nVarchar(255),Amount1 Decimal(18,2), AccountName2 nVarchar(255),Amount2 Decimal(18,2))

If @ParentID<>0
Begin
	Insert #TempRec1(AccountName1, Amount1)
	Exec sp_acc_con_prn_FSDrillDownRecords @FromDate,@ToDate,@ParentID,@ReportHeader
End
If @ParentID1<>0
Begin
	Insert #TempRec2(AccountName1, Amount1)
	Exec sp_acc_con_prn_FSDrillDownRecords @FromDate,@ToDate,@ParentID1,@ReportHeader
End
Select @MaxRows1 = Count(*) From #TempRec1
Select @MaxRows2 = Count(*) From #TempRec2
Set @MaxRows = @MaxRows1
IF @MaxRows < @MaxRows2 Set @MaxRows = @MaxRows2
Set @Ctr = 1
While @Ctr <= @MaxRows
Begin
	Insert Into #TempRec(RowID) Values(@Ctr)
	If @Ctr <= @MaxRows1
	Begin
	Select @AccountName = AccountName1, @Amount = Amount1 From #TempRec1 Where RowID = @Ctr
	Update #TempRec Set AccountName1=@AccountName,Amount1=@Amount Where RowID = @Ctr
	End
	If @Ctr <= @MaxRows2
	Begin
	Select @AccountName = AccountName1, @Amount = Amount1 From #TempRec2 Where RowID = @Ctr
	Update #TempRec Set AccountName2=@AccountName,Amount2=@Amount Where RowID = @Ctr
	End
	Set @Ctr = @Ctr + 1
End
Select * From #TempRec
drop table #TempRec
drop table #TempRec1
drop table #TempRec2

