CREATE procedure sp_ser_retrievedocumentid (@doctype integer)
as
select DocumentID from DocumentNumbers where [DocType]=@doctype
