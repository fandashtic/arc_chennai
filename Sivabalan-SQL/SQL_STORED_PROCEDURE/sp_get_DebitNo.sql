
CREATE procedure sp_get_DebitNo
as
select DocumentID from DocumentNumbers where DocType = 11

