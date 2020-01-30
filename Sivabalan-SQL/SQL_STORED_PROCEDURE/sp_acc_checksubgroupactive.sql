


CREATE Procedure sp_acc_checksubgroupactive(@GroupID Int)
As
Declare @Active Int,@Exists Int
DECLARE scanactive CURSOR KEYSET FOR
Select Active from Accountgroup where parentgroup=@GroupID

OPEN scanactive
FETCH FROM scanactive INTO @Active
While @@FETCH_STATUS=0
Begin
	If @Active=1
	Begin
		Set @Exists = 0
		break
	End
	Else
	Begin
		Set @Exists = 1
	End
	FETCH NEXT FROM scanactive INTO @Active
End
CLOSE scanactive
DEALLOCATE scanactive

If @Active=0
Begin
	DECLARE scanactive CURSOR KEYSET FOR
	Select Active from AccountsMaster where groupid=@GroupID
	
	OPEN scanactive
	FETCH FROM scanactive INTO @Active
	While @@FETCH_STATUS=0
	Begin
		If @Active=1
		Begin
			Set @Exists = 0
			break
		End
		Else
		Begin
			Set @Exists = 1
		End
		FETCH NEXT FROM scanactive INTO @Active
	End
	CLOSE scanactive
	DEALLOCATE scanactive

End
Select @Exists






