CREATE procedure sp_get_GVCreditNo
as
select DocumentID from DocumentNumbers where DocType = 70
