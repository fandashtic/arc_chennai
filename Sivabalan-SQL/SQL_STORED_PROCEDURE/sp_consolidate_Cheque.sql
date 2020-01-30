
CREATE procedure sp_consolidate_Cheque (@Client_ID int,
					@ChequeID int,
					@Cheque_Start int,
					@Total_Leaves int,
					@Account_Number nvarchar(20),
					@Active int,
					@LastIssued int,
					@Cheque_Book_Name nvarchar(50),
					@BankCode nvarchar(20),
					@UsedCheques int)
as
Declare @BankID int
Select @BankID = BankID From Bank Where Account_Number = @Account_Number
If not Exists (Select OriginalChequeID From Cheques Where OriginalChequeID = @ChequeID 
And Client_ID = @Client_ID)
Begin
	Insert into Cheques (Client_ID, OriginalChequeID, Cheque_Start, Total_Leaves,
	BankID, Active, LastIssued, Cheque_Book_Name, BankCode, UsedCheques) Values
	(@Client_ID, @ChequeID, @Cheque_Start, @Total_Leaves, @BankID, @Active, @LastIssued,
	@Cheque_Book_Name, @BankCode, @UsedCheques)
End
Else
Begin
	Update Cheques Set Cheque_Start = @Cheque_Start, Total_Leaves = @Total_Leaves,
	BankID = @BankID, Active = @Active, LastIssued = @LastIssued, 
	Cheque_Book_Name = @Cheque_Book_Name, BankCode = @BankCode,
	UsedCheques = @UsedCheques
	Where Client_ID = @Client_ID And OriginalChequeID = @ChequeID
End

