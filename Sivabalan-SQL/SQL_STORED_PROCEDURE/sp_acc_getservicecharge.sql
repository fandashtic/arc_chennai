CREATE procedure sp_acc_getservicecharge(@AccountID Int)
as
Declare @PaymentMode Int
Select IsNull(ServiceChargeProvider,0)
from AccountsMaster,PaymentMode
where AccountsMaster.AccountID = @AccountID
and PaymentMode.Mode = AccountsMaster.RetailPaymentMode







