CREATE procedure sp_acc_cancelapvbatch(@apvid integer)
as
update Batch_Assets
set Saleable =2
where [APVID]= @apvid


