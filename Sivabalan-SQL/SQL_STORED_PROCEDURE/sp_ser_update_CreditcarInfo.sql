CREATE procedure sp_ser_update_CreditcarInfo (@CollectionID int, @ExpiryDetails nvarchar(128), 
@ChequeDetails nvarchar(128), @BankID int, @CardHolder nvarchar(256), @CreditCardNumber nvarchar(20),
@CustomerServiceCharge decimal(18,6), @ProviderServiceCharge decimal(18,6), @PaymentModeID integer) 
as 
Declare @BankCode nvarchar(20) 
Select @BankCode = BankCode from BankMaster Where BankName = @ChequeDetails 

Update Collections set ChequeDate = @ExpiryDetails, ChequeDetails = isnull(@BankCode, ''), BankID = @BankID, 
CardHolder = @CardHolder, CreditCardNumber = @CreditCardNumber, CustomerServiceCharge = @CustomerServiceCharge,
ProviderServiceCharge = @ProviderServiceCharge, PaymentModeID = @PaymentModeID 
Where DocumentID = @CollectionID

/*
nCreditCardID = PaymentModeID
dServiceChargeValue = CustomerServiceCharge --Value
dProviderPercentage = ProviderServiceCharge --%
nBankAccountID = BankID
Trim(txtHolderName) = CardHolder
Trim(txtCardNumber) = CreditCardNumber
ChequeDetails = ChequeDetails
dtExpirydate.Value = ChequeDate
*/



