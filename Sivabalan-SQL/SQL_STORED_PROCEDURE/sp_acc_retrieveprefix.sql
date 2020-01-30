





CREATE procedure sp_acc_retrieveprefix(@transactionid nvarchar(30))
as
select Prefix from VoucherPrefix where [TranID]=@transactionid






