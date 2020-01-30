CREATE procedure sp_ser_collectioncreditcardinfo (@CollectionID int)
as
select ChequeDetails, 
ChequeDate, PaymentModeID, CustomerServiceCharge, ProviderServiceCharge, Collections.BankID, 
OtherDepositID, CardHolder, CreditCardNumber, 
IsNull(Paymentmode.value, '') Value, IsNull(Account_Number, '') AccNumber, 
isnull(accnumberbank.BankName, '') 'accnumberbankName', isnull(issbank.BankName, '') 'issbankName' 
from Collections 
Inner Join Bank On Bank.BankID = Collections.BankID
inner Join BankMaster accnumberbank On accnumberbank.BankCode = Bank.BankCode 
left outer Join BankMaster issbank On issbank.BankCode = isnull(ChequeDetails, '')
Inner Join Paymentmode On PaymentModeID = Mode
where Collections.DocumentID = @CollectionID 


