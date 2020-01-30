CREATE function sp_acc_con_fixedAssetrecursivefn(@accountid integer)
Returns Int
as
Begin
Declare @FIXEDASSETS Int
Declare @Exists Int

Set @FIXEDASSETS=13
Set @Exists=0

Declare @TempFixedAssets Table(GroupID Int,Status Int)
Declare @GroupID int
Insert into @TempFixedAssets select GroupID, 0 From AccountGroup Where 
ParentGroup = @FIXEDASSETS --and isnull(Active,0)=1
Declare scanfixedassets Cursor Dynamic For
Select GroupID From @TempFixedAssets --Where Status = 0
Open scanfixedassets
Fetch From scanfixedassets Into @GroupID
While @@Fetch_Status = 0
Begin
	Insert into @TempFixedAssets
	Select GroupID, 0 From AccountGroup
	Where ParentGroup = @GroupID

	Fetch Next From scanfixedassets Into @GroupID
End
Close scanfixedassets
DeAllocate scanfixedassets

insert into @TempFixedAssets values(@FIXEDASSETS,0)
If not exists(Select Top 1 AccountID from AccountsMaster where GroupID in (Select GroupID from @TempFixedAssets) and AccountID=@accountid)
Begin
	Set @Exists = 0
End
Else
Begin
	Set @Exists = 1 
End

Return @Exists
End

