CREATE procedure sp_ser_retrieveprefix(@transactionid varchar(30))
as
select Prefix from VoucherPrefix where [TranID]=@transactionid
