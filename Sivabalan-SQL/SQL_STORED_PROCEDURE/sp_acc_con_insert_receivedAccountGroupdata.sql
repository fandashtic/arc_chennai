
Create Procedure sp_acc_con_insert_receivedAccountGroupdata(
				@CompanyID nVarchar(15),
				@GroupID Int,
				@GroupName nVarchar (120),
				@ParentGroup Int,
				@AccountType Int,
				@Fixed Int)
As
If Not Exists(Select Top 1 GroupID from ReceiveAccountGroup Where CompanyID=@CompanyID and GroupID=@GroupID)
Begin
	Insert Into ReceiveAccountGroup Values(@CompanyID,
						@GroupID,
						@GroupName,
						@ParentGroup,
						@AccountType,
						@Fixed)
End
Else
Begin
	Update ReceiveAccountGroup Set ParentGroup=@ParentGroup,
					AccountTYpe=@AccountType,
					Fixed=@Fixed
	Where CompanyID=@CompanyID and GroupID=@GroupID
End


