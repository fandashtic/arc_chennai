





create procedure sp_acc_retrievetransactionid(@doctype integer)
as
select DocumentID from DocumentNumbers where [DocType]=@doctype







