CREATE proc sp_ser_bankdetails(@BankAccountID as int, @CreditCardID as int = 0 ) 
as

Select BankCode, BranchCode, IsNUll(c.ServiceChargePercentage, 0) ServiceChargePercentage
from Bank 
Left Outer Join BankAccount_PaymentModes c On c.BankID = Bank.BankID 
and CreditCardID = @CreditCardID
where Bank.BankId = @bankAccountID

