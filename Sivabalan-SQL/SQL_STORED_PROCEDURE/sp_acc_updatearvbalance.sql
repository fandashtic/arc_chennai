create procedure sp_acc_updatearvbalance(@ARVID int,@Adjusted decimal(18,6))
as
update ARVAbstract
Set Balance = Balance - @Adjusted
where [DocumentID]=@ARVID


