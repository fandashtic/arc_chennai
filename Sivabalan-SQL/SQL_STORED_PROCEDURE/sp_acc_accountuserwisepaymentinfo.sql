CREATE procedure sp_acc_accountuserwisepaymentinfo(@AccountID Int)
as
select PaymentType, AccountID,AccountName,'Balance' = dbo.sp_acc_getaccountbalance(AccountID,dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))),  
RetailPaymentMode from AccountsMaster,PaymentMode
where AccountsMaster.AccountID = @AccountID
and PaymentMode.Mode = AccountsMaster.RetailPaymentMode

