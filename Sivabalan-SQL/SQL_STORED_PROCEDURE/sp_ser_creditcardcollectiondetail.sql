CREATE procedure sp_ser_creditcardcollectiondetail(@PaymentType as int,@PartyAccountID as int)
as
If @PaymentType = 3 /* Credit card */ 
begin 
	Select 0 'Checked', DocumentID 'DOCID', FullDocID, Company_Name 'Name', CreditCardNumber, 
	PayMentMode.Value 'CreditCardType', '' 'INVID',  
	(c.Value + IsNull(c.CustomerServiceCharge, 0)) 'Amount', 
	ProviderServiceCharge 'ServiceCharge', 1 'DocType'  
	from Collections c 
	Inner Join Bank b On b.BankID = c.BankID and AccountID = @PartyAccountID 
	Inner Join PayMentMode On Mode = PaymentModeID 
	Inner Join Customer On Customer.CustomerID = c.CustomerID 
	Where IsNull(Status, 0) & 192 = 0 and IsNull(OtherDepositID,0) = 0  and IsNull(c.PaymentMode,0) = 3
	UNION
	Select 0 'Checked',ContraSerialCode 'DOCID', 
	dbo.getoriginalid(ContraDetail.ContraID,74) 'FullDocID',AdditionalInfo_Customer 'Name',
	AdditionalInfo_Number 'CreditCardNumber',AdditionalInfo_Type 'CreditCardType',
	OriginalID 'INVID', AdditionalInfo_Amount 'Amount', 
	AdditionalInfo_ServiceCharge 'ServiceCharge', 0 from 
	ContraDetail,ContraAbstract where ContraAbstract.ContraID=ContraDetail.ContraID and 
	ContraAbstract.ToUser='Main' and  IsNull(ContraAbstract.Status,0)=0 and
	AdditionalInfo_Party=@PartyAccountID and IsNull(AdjustedFlag,0)=0 and
	PaymentType=@PaymentType and ToAccountID=94 
	Order by 3,2 -- Credit Card Account (Main)
	
end 

/*
10.05.05 -- 
Internal contral included in the same procedure to include the information in same listview 
Flag Value 0 for Internal contra, 1 for Collection
--CardHolder, ChequeDetails, 
*/




