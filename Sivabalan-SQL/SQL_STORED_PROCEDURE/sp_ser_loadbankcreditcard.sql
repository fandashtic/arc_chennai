CREATE procedure sp_ser_loadbankcreditcard 
as
Select distinct Value, mode from BankAccount_PaymentModes 
Inner Join PaymentMode On CreditCardID = Mode And PaymentType = 3
order by Value

/* Select BankID, Value, mode from BankAccount_PaymentModes 
Inner Join PaymentMode On CreditCardID = Mode And PaymentType = 3
Where BankID = @BankID */

