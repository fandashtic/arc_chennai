create procedure sp_acc_canceladvancepayment(@PaymentID Int,@AmountAdjusted Decimal(18,6))
as
Update Payments 
Set Balance = Balance + @AmountAdjusted
Where DocumentID = @PaymentID





