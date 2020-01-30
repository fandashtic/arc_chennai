CREATE Procedure sp_ser_saveCreditCardInfo(@BankID int,
@CreditCardID int,
@ServiceChargePercentage Decimal(18,6))
As
insert into BankAccount_PaymentModes(BankID, CreditCardID, ServiceChargePercentage)
values(@BankID, @CreditCardID, @ServiceChargePercentage)

