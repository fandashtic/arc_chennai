CREATE procedure sp_get_ChequeID(@Cheque_Book_Name nvarchar(100), @BankID int)
as
select ChequeID from Cheques, Bank 
where Cheques.Cheque_Book_Name = @Cheque_Book_Name And
Cheques.BankID = Bank.BankID And
Bank.BankID = @BankID
