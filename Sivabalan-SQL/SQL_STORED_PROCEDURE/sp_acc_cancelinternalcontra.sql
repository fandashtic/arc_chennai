create procedure sp_acc_cancelinternalcontra(@contraid int)
as
Update ContraAbstract
Set Status = 192
where ContraID = @contraid


