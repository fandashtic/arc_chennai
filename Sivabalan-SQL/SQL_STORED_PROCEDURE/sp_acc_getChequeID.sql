





create procedure sp_acc_getChequeID(@Cheque_Book_Name nvarchar(100))
as
select ChequeID from  Cheques where Cheque_Book_Name = @Cheque_Book_Name






