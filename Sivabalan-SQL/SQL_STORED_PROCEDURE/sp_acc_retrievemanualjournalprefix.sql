





create procedure sp_acc_retrievemanualjournalprefix
as
select Prefix from VoucherPrefix where [TranID]=N'MANUAL JOURNAL' 






