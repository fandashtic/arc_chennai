CREATE Procedure sp_Get_BouncedCheques (@Customer nvarchar(20))
As
Select FullDocID, ChequeNumber, ChequeDate, BankName, Collections.BankCode, BranchName, 
Collections.BranchCode, Value, DocumentID, DebitID, Collections.SalesmanID
From Collections, BankMaster, BranchMaster 
Where Realised = 2 And CustomerID = @Customer And 
Collections.BankCode = BankMaster.BankCode And
Collections.BranchCode = BranchMaster.BranchCode And
Collections.BankCode = BranchMaster.BankCode And
DebitID In (Select DebitID From DebitNote Where NoteValue = Balance And Flag = 2)
