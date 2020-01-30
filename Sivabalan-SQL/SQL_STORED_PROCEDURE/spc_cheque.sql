
CREATE procedure spc_cheque
as
select ChequeID, Cheque_Start, Total_Leaves, Bank.Account_Number, Cheques.Active, 
LastIssued, Cheque_Book_Name, Cheques.BankCode, UsedCheques
From Cheques, Bank
Where Cheques.BankID = Bank.BankID

