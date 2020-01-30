CREATE procedure sp_acc_rpt_InternalContraDetail(@contraid int)
as

select 'From Account' = dbo.getaccountname(FromAccountID),
'To Account' = dbo.getaccountname(ToAccountID),
'Amount Transfer'= isnull(AdditionalInfo_Amount,0),5 
from ContraDetail 
where ContraID = @contraid 



