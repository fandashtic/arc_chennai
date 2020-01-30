create procedure sp_acc_checkdocumentadjusted(@ContraID Int)
as
Select 'AdjustedFlag' = IsNull(AdjustedFlag,0)
from ContraDetail where ContraID = @ContraID 
