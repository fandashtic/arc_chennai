
CREATE procedure sp_acc_apv(@apvid int)
as
select isnull(Saleable,0) from Batch_Assets
where isnull(APVID,0) =@apvid 

