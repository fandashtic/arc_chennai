


create procedure sp_acc_updatecancelapv(@apvid int,@adjustedamount decimal(18,6))
as
update apvabstract 
set Balance = Balance + @adjustedamount
where DocumentID = @apvid





