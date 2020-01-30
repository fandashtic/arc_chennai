CREATE procedure sp_acc_loaduserwisepaymentinfo(@username nvarchar(50),@Mode Int = 0)
as
set dateformat dmy
If @Mode = 1 
Begin
	select AccountID,AccountName,'Balance' = dbo.sp_acc_getaccountbalance(AccountID,dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))),  
	PaymentType,RetailPaymentMode from AccountsMaster,PaymentMode
	where AccountsMaster.UserName = @username and PaymentType in (1,5) 
	and PaymentMode.Mode = AccountsMaster.RetailPaymentMode
	order by PaymentType
End
Else
Begin
	select PaymentType, AccountID,AccountName,'Balance' = dbo.sp_acc_getaccountbalance(AccountID,dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))),  
	RetailPaymentMode from AccountsMaster,PaymentMode
	where AccountsMaster.UserName = @username
	and PaymentMode.Mode = AccountsMaster.RetailPaymentMode
	order by PaymentType
End


