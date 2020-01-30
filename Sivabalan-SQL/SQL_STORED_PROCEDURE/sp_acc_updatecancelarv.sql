create procedure sp_acc_updatecancelarv(@ARVID int,@AdjustedAmount decimal(18,6))
as
Update ARVAbstract 
Set Balance = Balance + @AdjustedAmount
where DocumentID = @ARVID
