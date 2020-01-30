CREATE procedure spr_list_AvailableChequeLeaves
as
Select BankMaster.BankCode, "Bank" = BankMaster.BankName, 
"Branch" = BranchMaster.BranchName, "Account No." = Bank.Account_Number, 
"Cheque Book" = Cheques.Cheque_Book_Name, "Book Start No." = Cheques.Cheque_Start, 
"No. Leaves" = Cheques.Total_Leaves, "Last Issued Cheque" = Cheques.LastIssued,
"No. Used Cheques" = Cheques.UsedCheques
From Cheques, BankMaster, Bank, BranchMaster
Where Cheques.BankID = Bank.BankID AND
Bank.BranchCode = BranchMaster.BranchCode AND
Bank.BankCode = BankMaster.BankCode AND
Bank.BankCode = BranchMaster.BankCode AND
ISNULL(Cheques.LastIssued, 0) < (Cheques.Cheque_Start + Cheques.Total_Leaves)
