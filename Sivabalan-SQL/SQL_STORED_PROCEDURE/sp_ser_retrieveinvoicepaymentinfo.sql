CREATE Procedure sp_ser_retrieveinvoicepaymentinfo(@ServiceInvoiceID Int) 
as
Declare @Mode int
Declare @CouponDetails nVarchar(4000)
Declare @ColSep nVarchar(10),@RowSep nVarchar(10)
Set @ColSep = Char(2)
Set @RowSep  = Char(3)
 
select @Mode = PaymentMode from ServiceInvoiceAbstract 
Where ServiceInvoiceID = @ServiceInvoiceID
if @Mode = 1 --Cash
begin
	select "Amount" = isNull(COL.Value,0) from ServiceInvoiceAbstract SIA
	Left Outer join Collections COL on SIA.PaymentDetails = COL.DocumentID
	where SIA.ServiceInvoiceID = @ServiceInvoiceID
end
else if @Mode = 2 or @Mode = 3  --Cheque and DD
begin
	select "ChequeNumber"=COL.ChequeNumber,"ChequeDate"=COL.ChequeDate,"BankCode"=COL.BankCode,
	"BankName"=BANK.BankName,"BranchCode"=COL.BranchCode,"BranchName"=BRANCH.BranchName,"Amount"=COL.Value
	from ServiceInvoiceAbstract SI
	Inner Join Collections COL on SI.PaymentDetails=COL.DocumentID
	Left Outer Join BankMaster BANK on BANK.Bankcode = COl.BankCode
	Left Outer Join BranchMaster BRANCH on BRANCH.Bankcode = COl.BankCode and BRANCH.BranchCode = COL.BranchCode
	Where SI.ServiceInvoiceID = @ServiceInvoiceID
End
else if @Mode = 4	--Credit Card
begin
	select "CardHolder"=isNull(COL.CardHolder,''),"CreditCard"=PAYMODE.Value,"CreditCardNumber"=isNull(COL.CreditCardNumber,0),"IssueBank"=isNull(ISSBM.BankName,''),"ExpiryDate"=COL.ChequeDate,
	"BankAccount"=BM.BankName + '-' + BANK.Account_number,"Amount"=COL.Value,
	"CustomerServiceCharge"=isNull(COL.CustomerServiceCharge,0),"ProviderServiceCharge"=isNull(COL.ProviderServiceCharge,0)
	from ServiceInvoiceAbstract SI
	Inner Join Collections COL on SI.PaymentDetails=COL.DocumentID
	Inner Join PaymentMode PAYMODE on COL.PaymentModeID  = PAYMODE.Mode
	Left Outer Join BankMaster ISSBM on ISSBM.Bankcode = isNull(COl.ChequeDetails,'')
	Left Outer Join Bank on BANK.BankID = COL.BankID
	Left Outer Join BankMaster BM on BM.Bankcode = BANK.BankCode
	Where SI.ServiceInvoiceID = @ServiceInvoiceID
End
else if @Mode = 5	--Coupon
begin
	select @CouponDetails = COALESCE(@CouponDetails + @RowSep ,'') + Cast(COU.SerialNo as nVarchar(10))
		+ @ColSep + COU.FromSerial  + @ColSep + COU.ToSerial  + 
		@ColSep + Cast(COU.Denomination as nVarchar(50)) + @ColSep + Cast(COU.Qty as nVarchar(10)) + @ColSep + Cast(COU.Value as nVarchar(50))
	from ServiceInvoiceAbstract SI
	Inner Join Collections COL on SI.PaymentDetails=COL.DocumentID
	Inner Join Coupon COU on COL.DocumentID = COU.CollectionID
	Where SI.ServiceInvoiceID = @ServiceInvoiceID
	
	Select "DepositTO"=ACC.AccountName,"CouponName" = PAYMODE.Value,
	"Amount" = COL.Value,"CustomerServiceCharge"=isNull(COL.CustomerServiceCharge,0),
	"ProviderServiceCharge"=isNull(COL.ProviderServiceCharge,0),"Denominations"=@CouponDetails
	from ServiceInvoiceAbstract SI
	Inner Join Collections COL on SI.PaymentDetails=COL.DocumentID 
	Inner join AccountsMaster ACC on COL.BankID = ACC.AccountID
	Inner Join PaymentMode PAYMODE on COL.PaymentModeID  = PAYMODE.Mode
	Where SI.ServiceInvoiceID = @ServiceInvoiceID
end

