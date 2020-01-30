Create Procedure sp_acc_updateARVContraDetail(@ContraSerialCode as int,@AdjustedFlag int,@ARVID int=0)
As
--@ARVID is Auto entry of an ARV
Update ContraDetail set AdjustedFlag=@AdjustedFlag where ContraSerialCode=@ContraSerialCode 


