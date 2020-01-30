CREATE procedure sp_acc_con_rpt_fixedAssetrecursive(@accountid integer,@Exists Int output)
as
Declare @FIXEDASSETS Int
Set @FIXEDASSETS=13
Set @Exists=0
Create Table #TempFixedAssets(GroupID int,
		   Status int)
Declare @GroupID int
Insert into #TempFixedAssets select GroupID, 0 From ConsolidateAccountGroup Where 
ParentGroup = @FIXEDASSETS --and isnull(Active,0)=1
Declare scanfixedassets Cursor Dynamic For
Select GroupID From #TempFixedAssets --Where Status = 0
Open scanfixedassets
Fetch From scanfixedassets Into @GroupID
While @@Fetch_Status = 0
Begin
	Insert into #TempFixedAssets
	Select GroupID, 0 From ConsolidateAccountGroup
	Where ParentGroup = @GroupID --and isnull(Active,0)=1
	--Update #temp Set Status = 1 Where GroupID = @GroupID
	Fetch Next From scanfixedassets Into @GroupID
End
Close scanfixedassets
DeAllocate scanfixedassets

insert into #TempFixedAssets values(@FIXEDASSETS,0)
If not exists(Select Top 1 AccountID from ConsolidateAccount where GroupID in (Select GroupID from #TempFixedAssets) and AccountID=@accountid)
Begin
--If not exists(Select Top 1 AccountID from AccountsMaster where GroupID =13 and AccountID=23)
	Set @Exists = 0
End
Else
Begin
	Set @Exists = 1 
End


