CREATE Procedure [dbo].[sp_acc_loadpettycashabstract](@fromdate datetime,@todate datetime,@accountid integer,@mode integer)
as
Declare @CANCEL int
Declare @VIEW int
Declare @ALL int
Declare @AMENDMENT int
Declare @PETTY_CASH int

set @CANCEL =1
set @VIEW =2
Set @AMENDMENT = 3
set @ALL=0
set @PETTY_CASH=4

if @mode = @CANCEL or @mode = @AMENDMENT
begin
	if @accountid = @ALL 
	begin
		select 'DocumentID'= Payments.DocumentID,'FullDocID'=Payments.FullDocID,
		'DocumentDate'=	Payments.DocumentDate,'Others'=Payments.ExpenseAccount,
		'Amount' = Value,'Total Amount' = Value ,'Status'=isnull(Status,0),
		'Petty Cash Type' =
			Case
				When (isnull(Others,0) =0 and Isnull(PaymentMode,0) = 5) or Isnull(Others,0) = 4 then dbo.LookupDictionaryItem('Payment for Expenses',Default)
				When Isnull(Others,0) > 0 and Isnull(PaymentMode,0) = 5 then dbo.LookupDictionaryItem('Payment to Party for Expenses',Default)
			End,
		'Party Name' = 
			Case 
				When Isnull(Others,0) > 0 and Isnull(PaymentMode,0) = 5 Then Isnull(AccountsMaster.AccountName,N'')
				else ''
			End,
		'RefDocID' = Isnull(RefDocID,0),
  'AccountName' = dbo.getAccountName(Payments.ExpenseAccount),'Value'=Value
		from Payments
		Left Outer Join AccountsMaster On payments.others = AccountsMaster.AccountID where 
		dbo.stripdatefromtime(Payments.DocumentDate) between
		@fromdate and @todate and 
		(Payments.Others = @PETTY_CASH or paymentmode = 5)
		and isnull(Status,0)= 0 
		order by Payments.DocumentDate,DocumentID
	End
	Else
	Begin
		select 'DocumentID'= Payments.DocumentID,'FullDocID'=Payments.FullDocID,
		'DocumentDate'=Payments.DocumentDate,'Others'=Payments.ExpenseAccount,
		'Amount' = Isnull(Value,0),'Total Amount' = Isnull(Value,0),
		'Status'=isnull(Status,0),
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
		'RefDocID' = Isnull(RefDocID,0),
  'AccountName' = dbo.getAccountName(Payments.ExpenseAccount),'Value'=Value
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
		and Isnull(Status,0) = 0 

		UNION

		select 'DocumentID'= Payments.DocumentID,'FullDocID'=Payments.FullDocID,
		'DocumentDate'=Payments.DocumentDate,'Others'=Payments.ExpenseAccount,
		'Amount' =
			Case 			
				When Isnull(Payments.Others,0) = @AccountID then Isnull(Value,0)
				Else
					(Select isnull(amount,0) from PaymentExpense where PaymentID = Payments.DocumentID
					and accountID = @AccountID)
			End,
		'Total Amount' = Isnull(Value,0),'Status'=isnull(Status,0),
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
		'RefDocID' = Isnull(RefDocID,0),
  'AccountName' = '','Value'=0/*Dummy Values*/
		from Payments,PaymentExpense
		where dbo.stripdatefromtime(Payments.DocumentDate)between
		@fromdate and @todate and 
		(PaymentExpense.AccountID =@accountID or Payments.Others = @accountID)
		and Payments.PaymentMode = 5
		and isnull(AccountMode,0) = 1
		and Payments.documentId = PaymentExpense.PaymentID
		and Isnull(Status,0) = 0 

		order by Payments.DocumentDate,DocumentID
	End
End
else if @mode = @VIEW 
begin
	if @accountid= @ALL  
	begin
		select 'DocumentID'= Payments.DocumentID,'FullDocID'=Payments.FullDocID,
		'DocumentDate'=	Payments.DocumentDate,'Others'=Payments.ExpenseAccount,
		'Amount' = Value,'Total Amount' = Value ,'Status'=isnull(Status,0),
		'Petty Cash Type' =
			Case
				When (isnull(Others,0) =0 and Isnull(PaymentMode,0) = 5) or Isnull(Others,0) = 4 then dbo.LookupDictionaryItem('Payment for Expenses',Default)
				When Isnull(Others,0) > 0 and Isnull(PaymentMode,0) = 5 then dbo.LookupDictionaryItem('Payment to Party for Expenses',Default)
			End,
		'Party Name' = 
			Case 
				When Isnull(Others,0) > 0 and Isnull(PaymentMode,0) = 5 Then Isnull(AccountsMaster.AccountName,N'')
				else ''
			End,
		'RefDocID' = Isnull(RefDocID,0),
  'AccountName' = dbo.getAccountName(Payments.ExpenseAccount),'Value'=Value
		from Payments
		Left Outer Join AccountsMaster On Payments.Others = AccountsMaster.AccountID where 
		dbo.stripdatefromtime(Payments.DocumentDate) between
		@fromdate and @todate and 
		(Payments.Others = @PETTY_CASH or paymentmode = 5)
		
		order by [Payments].[DocumentId],[Payments].[FullDocID]
	end
	else
	begin
		select 'DocumentID'= Payments.DocumentID,'FullDocID'=Payments.FullDocID,
		'DocumentDate'=Payments.DocumentDate,'Others'=Payments.ExpenseAccount,
		'Amount' = Isnull(Value,0),'Total Amount' = Isnull(Value,0),
		'Status'=isnull(Status,0),
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
		'RefDocID' = Isnull(RefDocID,0),
  'AccountName' = dbo.getAccountName(Payments.ExpenseAccount),'Value'=Value
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

		select 'DocumentID'= Payments.DocumentID,'FullDocID'=Payments.FullDocID,
		'DocumentDate'=Payments.DocumentDate,'Others'=Payments.ExpenseAccount,
		'Amount' =
			Case
				When Isnull(Payments.Others,0) = @AccountID then Isnull(Value,0)
				Else
					(Select isnull(amount,0) from PaymentExpense where PaymentID = Payments.DocumentID
						and accountID = @AccountID)
			End,
		'Total Amount' = Isnull(Value,0),'Status'=isnull(Status,0),
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
		'RefDocID' = Isnull(RefDocID,0),
  'AccountName' = '','Value'=0/*Dummy Values*/
		from Payments,PaymentExpense
		where dbo.stripdatefromtime(Payments.DocumentDate)between
		@fromdate and @todate and 
		(PaymentExpense.AccountID =@accountID or Payments.Others = @accountID)
		and Payments.PaymentMode = 5
		and isnull(AccountMode,0) = 1
		and Payments.documentId = PaymentExpense.PaymentID

		order by [Payments].[DocumentId],[Payments].[FullDocID]
	end
end
