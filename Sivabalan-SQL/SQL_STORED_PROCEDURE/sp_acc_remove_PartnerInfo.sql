CREATE Procedure sp_acc_remove_PartnerInfo
As
Declare @AccountID Int,@DrawingAccountID Int
--Begin Tran
Declare scansetupdetail Cursor Keyset for
Select AccountID,DrawingAccountID from SetupDetail
Open  scansetupdetail
Fetch From scansetupdetail into @AccountID,@DrawingAccountID
While @@FETCH_STATUS=0
Begin
	If @AccountID<>0 
	Begin
		--Update AccountsMaster Set Active=0 where AccountID=@AccountID
		Delete from AccountsMaster where AccountID=@AccountID
	End
	If @DrawingAccountID<>0 
	Begin
		--Update AccountsMaster Set Active=0 where AccountID=@DrawingAccountID
		Delete from AccountsMaster where AccountID=@DrawingAccountID
	End
	Fetch Next From scansetupdetail into @AccountID,@DrawingAccountID
End
CLOSE scansetupdetail
DEALLOCATE scansetupdetail
Delete SetupDetail
--Commit Tran


