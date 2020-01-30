CREATE Procedure [dbo].[sp_acc_rpt_pettycash]
(@FromDate Datetime,@Todate Datetime,@AccountID Int,@Active INT = 0)
as
Declare @ALL int
Declare @PETTY_CASH int
Declare @DETAIL int

set @ALL=0
set @PETTY_CASH=4
Set @DETAIL = 99

Create Table #PettyCash
(
	SerialNo		Int Identity,
	TransactionID 	nVarchar(100),
	DocumentID 		Int,
	DocumentDate	Datetime,
	ExpenseAC		Int,
	Amount			Decimal(18,6),
	NetAmount		Decimal(18,6),
	Status			Int,	
	Type			nVarchar(100),
	PartyName		nVarchar(255),
	RefDOCId		Int,
	Display			Int 
)

if @accountid= @ALL  
begin
	Insert into #PettyCash
	select Payments.FullDocID, Payments.DocumentID,
	Payments.DocumentDate,Payments.ExpenseAccount,
	Value,Value ,isnull(Status,0),
	'Petty Cash Type' =
		Case
			When (isnull(Others,0) =0 and Isnull(PaymentMode,0) = 5) or Isnull(Others,0) = 4 then dbo.LookupDictionaryItem('Payment for Expenses',Default)
			When Isnull(Others,0) > 0 and Isnull(PaymentMode,0) = 5 then dbo.LookupDictionaryItem('Payment to Party for Expenses',Default)
		End,
	'Party Name' = 
		Case 
			When Isnull(Others,0) > 0 and Isnull(PaymentMode,0) = 5 Then AccountsMaster.AccountName
			else ''
		End,
	RefDocID,@DETAIL
	from Payments
	Left Outer Join AccountsMaster on Payments.Others = AccountsMaster.AccountID
	where dbo.stripdatefromtime(Payments.DocumentDate) between
	@fromdate and @todate and 
	(Payments.Others = @PETTY_CASH or paymentmode = 5)
	--and Payments.Others *= AccountsMaster.AccountID
	order by [Payments].[DocumentId],[Payments].[FullDocID]
end
else
begin
	/* OLD IMPLEMENTATION */
	Insert into #PettyCash
	select Payments.FullDocID, Payments.DocumentID,
	Payments.DocumentDate,Payments.ExpenseAccount,
	Isnull(Value,0),Isnull(Value,0),isnull(Status,0),
	'Petty Cash Type' = 
		Case
			When (Isnull(PaymentMode,0) = 0 and Others = @PETTY_CASH) then dbo.LookupDictionaryItem('Payment for Expenses',Default)
			When (isnull(Others,0) =0 and Isnull(PaymentMode,0) = 5)then dbo.LookupDictionaryItem('Payment for Expenses',Default)
			When Isnull(Others,0) > 0 and Isnull(PaymentMode,0) = 5 then dbo.LookupDictionaryItem('Payment to Party for Expenses',Default)
		End,
	'Party Name' = 
		Case 
			When Isnull(Others,0) > 0 and Isnull(PaymentMode,0) = 5 then
				(Select Isnull(AccountName,N'') from AccountsMaster where 
					AccountsMaster.AccountID = Payments.Others )
			Else ''
		End,
	RefDocID,@DETAIL
	from Payments
	where 
	dbo.stripdatefromtime(Payments.DocumentDate)between
	@fromdate and @todate and 
	(
	 	(Payments.ExpenseAccount = @accountID and others = @PETTY_CASH and Isnull(PaymentMode,0) = 0) -- Old Implementation
	  	or (Payments.others = @AccountId and Isnull(PaymentMode,0) = 5)
	  	or (Payments.ExpenseAccount =@accountID and Isnull(PaymentMode,0) = 5)
	)
	and Isnull(accountmode,0) = 0

	UNION

	/* Since AccountMode is 1 , link PaymenExpense to get the data */
	select Payments.FullDocID, Payments.DocumentID,
	Payments.DocumentDate,Payments.ExpenseAccount,
	'Amount' =
		Case
			When Isnull(Payments.Others,0) = @AccountID then Isnull(Value,0)
			Else
				(Select isnull(amount,0) from PaymentExpense where PaymentID = Payments.DocumentID
				 	and accountID = @AccountID)
		End,
	Isnull(Value,0),isnull(Status,0),
	'Petty Cash Type' = 
		Case
			When (isnull(Others,0) =0 and Isnull(PaymentMode,0) = 5)then dbo.LookupDictionaryItem('Payment for Expenses',Default)
			When Isnull(Others,0) > 0 and Isnull(PaymentMode,0) = 5 then dbo.LookupDictionaryItem('Payment to Party for Expenses',Default)
		End,
	'Party Name' = 
		Case
			When Isnull(Others,0) > 0 and Isnull(PaymentMode,0) = 5 then
				(Select Isnull(AccountName,N'') from AccountsMaster where 
					AccountsMaster.AccountID = Payments.Others)
			Else ''
		End,
	RefDocID,@DETAIL
	from Payments,PaymentExpense
	where dbo.stripdatefromtime(Payments.DocumentDate)between
	@fromdate and @todate and 
	(PaymentExpense.AccountID =@accountID or Payments.Others = @accountID)
	and Payments.PaymentMode = 5
	and isnull(AccountMode,0) = 1
	and Payments.documentId = PaymentExpense.PaymentID
	order by [Payments].[DocumentId],[Payments].[FullDocID]
End

/* Blank Row */
Insert into #PettyCash(PartyName,Display)
Select '',1

/* total Row */
Insert into #PettyCash(PartyName,Amount,Display)
Select 'Total',Sum(Amount),1 from #Pettycash
Where Isnull(Status,0) = 0

select 
'Transaction ID' =TransactionID,
'DocumentID' = DocumentID,
'Document Date' =DocumentDate,
'Petty Cash Type' = Type,
'Party Name' = PartyName,
'Expense Amount' = Amount,
'Net Amount' = NetAmount,
'Status' =
	Case 
		When (Isnull(Status,0) = 128 and Isnull(RefdocID,0) >= 0 and Display > 1) then dbo.LookupDictionaryItem('Amended',Default)
		When (Isnull(Status,0) = 0 and Isnull(RefdocID,0) > 0 and Display > 1) then dbo.LookupDictionaryItem('Amendment',Default)
		When (Isnull(Status,0) = 192 and Display > 1) then dbo.LookupDictionaryItem('Cancelled',Default)
		Else ''
	End,
'Display' = Display
from #PettyCash
Order by SerialNo
Drop Table #PettyCash
