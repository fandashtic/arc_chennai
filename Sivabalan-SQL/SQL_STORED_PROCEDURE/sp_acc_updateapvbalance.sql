


create procedure sp_acc_updateapvbalance(@apvid int,@adjusted decimal(18,2))
as
update APVAbstract
set Balance = Balance - @adjusted
where [DocumentID]=@apvid
 





