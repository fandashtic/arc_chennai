

Create Procedure sp_acc_prn_PrintDrillDown(@DocRef Int, @DocType INT,@Info nvarchar(4000) = Null)
As

Declare @RETAILINVOICE INT
Declare @RETAILINVOICEAMENDMENT INT
Declare @RETAILINVOICECANCELLATION INT
Declare @INVOICE INT
Declare @INVOICEAMENDMENT INT
Declare @INVOICECANCELLATION INT
Declare @SALESRETURN INT
Declare @BILL INT
Declare @BILLAMENDMENT INT
Declare @BILLCANCELLATION INT
Declare @PURCHASERETURN INT
Declare @PURCHASERETURNCANCELLATION INT
Declare @COLLECTIONS INT
Declare @DEPOSITS INT
Declare @BOUNCECHEQUE INT
Declare @REPOFBOUNCECHEQUE INT
Declare @PAYMENTS INT
Declare @PAYMENTCANCELLATION INT
Declare @AUTOENTRY INT
Declare @DEBITNOTE INT
Declare @CREDITNOTE INT
Declare @CLAIMSTOVENDOR INT
Declare @CLAIMSSETTLEMENT INT
Declare @CLAIMSCANCELLATION INT
Declare @COLLECTIONCANCELLATION INT
Declare @MANUALJOURNAL INT

Declare @MANUALJOURNALINVOICE int
Declare @MANUALJOURNALSALESRETURN int
Declare @MANUALJOURNALBILL int
Declare @MANUALJOURNALPURCHASERETURN int
Declare @MANUALJOURNALCOLLECTIONS int
Declare @MANUALJOURNALPAYMENTS int
Declare @MANUALJOURNALDEBITNOTE int
Declare @MANUALJOURNALCREDITNOTE int
Declare @MANUALJOURNALOLDREF int

Declare @ARV INT
Declare @ARVCANCELLATION INT
Declare @APV INT
Declare @APVCANCELLATION INT

Declare @APVDETAIL INT
Declare @ARVDETAIL INT

Declare @STOCKTRANSFERIN INT
Declare @STOCKTRANSFEROUT INT

Set @RETAILINVOICE = 1
Set @RETAILINVOICEAMENDMENT = 2
Set @RETAILINVOICECANCELLATION =3
Set @INVOICE =4
Set @INVOICEAMENDMENT = 5
Set @INVOICECANCELLATION = 6
Set @SALESRETURN = 7
Set @BILL = 8
Set @BILLAMENDMENT = 9
Set @BILLCANCELLATION = 10
Set @PURCHASERETURN = 11
Set @PURCHASERETURNCANCELLATION = 12
Set @COLLECTIONS = 13
Set @DEPOSITS =14
Set @BOUNCECHEQUE = 15
Set @REPOFBOUNCECHEQUE = 16
Set @PAYMENTS = 17
Set @PAYMENTCANCELLATION = 18
Set @AUTOENTRY = 19
Set @DEBITNOTE = 20
Set @CREDITNOTE = 21
Set @CLAIMSTOVENDOR = 22
Set @CLAIMSSETTLEMENT = 23
Set @CLAIMSCANCELLATION = 24
Set @COLLECTIONCANCELLATION = 25
Set @MANUALJOURNAL = 26

Set @MANUALJOURNALINVOICE =28
Set @MANUALJOURNALSALESRETURN =29
Set @MANUALJOURNALBILL =30
Set @MANUALJOURNALPURCHASERETURN =31
Set @MANUALJOURNALCOLLECTIONS =32
Set @MANUALJOURNALPAYMENTS =33
Set @MANUALJOURNALDEBITNOTE =34
Set @MANUALJOURNALCREDITNOTE =35
Set @MANUALJOURNALOLDREF =37

Set @APV =46
Set @APVCANCELLATION =47
Set @ARV = 48
Set @ARVCANCELLATION =49

Set @APVDETAIL =50
Set @ARVDETAIL =51

Set @STOCKTRANSFERIN = 54
Set @STOCKTRANSFEROUT = 55

Declare @PaymentMode INT,@CustomerID nVarchar(30),@VendorID nVarchar(30)
Declare @SPECIALCASE2 INT
SET @SPECIALCASE2=5 --Restrict the link after leaf level

set dateformat dmy

If @DocType= @RETAILINVOICE OR @DocType=@RETAILINVOICEAMENDMENT OR @DocType=@RETAILINVOICECANCELLATION 
   OR @DocType= @INVOICE OR @DocType=@INVOICEAMENDMENT OR @DocType=@INVOICECANCELLATION OR @DocType=@SALESRETURN 
   OR @Doctype=@MANUALJOURNALINVOICE OR @Doctype=@MANUALJOURNALSALESRETURN
Begin
	Execute sp_acc_rpt_invoicedetail @DocRef
End
Else if @DocType= @BILL OR @DocType= @BILLAMENDMENT OR @DocType= @BILLCANCELLATION
	OR @DocType= @MANUALJOURNALBILL
Begin
	Execute sp_acc_rpt_billdetail @DocRef
End
Else If @DocType = @PURCHASERETURN OR @DocType = @PURCHASERETURNCANCELLATION OR @DocType = @MANUALJOURNALPURCHASERETURN
Begin
	Execute sp_acc_rpt_stkadjretdetail @DocRef
End
Else If @DocType= @COLLECTIONS OR @DocType=@COLLECTIONCANCELLATION OR @DocType= @MANUALJOURNALCOLLECTIONS
Begin
	
	Set @PaymentMode=(Select PaymentMode from Collections where DocumentID=@DocRef)
	Set @CustomerID=(Select CustomerID from Collections where DocumentID=@DocRef)
	If @CustomerID is not null
	Begin
		If @PaymentMode=0
		Begin
			select 'Document Date' = dbo.stripdatefromtime(CollectionDetail.DocumentDate), 
			'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=OriginalID,
			'Value'=DocumentValue,'Adjusted Amount' = AdjustedAmount, 
			Null,'Doc Ref'=case when documentType=4 then cast((Select InvoiceID from InvoiceAbstract where 
			DocumentID=dbo.gettrueval(OriginalID)) as nVarchar) else OriginalID end,
			'Doc Type'=case when documenttype=4 then @Invoice else DocumentType end,
			case when documentType =4 then 13 else @SPECIALCASE2 end from 
			CollectionDetail where CollectionID=@DocRef
		End
		Else
		Begin
				select 'Document Date' = dbo.stripdatefromtime(CollectionDetail.DocumentDate),
				'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=OriginalID,
				'Value'=DocumentValue,'Adjusted Amount' = AdjustedAmount,Null,
				'Doc Ref'=Case when documenttype=4 then cast((Select InvoiceID from InvoiceAbstract where DocumentID=dbo.gettrueval(OriginalID)) as nvarChar) else OriginalID end,
				'Doc Type'=case when documentType=4 then @Invoice else DocumentType end,
				'Cheque Date'=dbo.stripdatefromtime(Collections.ChequeDate),
				'Cheque Number'=Collections.ChequeNumber,case when documentType=4 then 13 else @SPECIALCASE2 end from
				CollectionDetail,Collections where CollectionID=@DocRef and Collections.DocumentID=CollectionDetail.CollectionID
		End
	End
	Else
	Begin
		If @PaymentMode=0
		Begin
			select 'Document Date' = dbo.stripdatefromtime(CollectionDetail.DocumentDate), 
			'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=OriginalID,
			'Value'=DocumentValue,'Adjusted Amount' = AdjustedAmount, 
			Null,'Doc Ref'=case when documentType=4 then cast((Select DocumentID from ARVAbstract where 
			ARVID=dbo.gettrueval(OriginalID)) as nVarchar) else OriginalID end,
			'Doc Type'=case when documenttype=4 then @ARV else DocumentType end,
			case when documentType =4 then 28 else @SPECIALCASE2 end from 
			CollectionDetail where CollectionID=@DocRef
		End
		Else
		Begin
				select 'Document Date' = dbo.stripdatefromtime(CollectionDetail.DocumentDate),
				'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=OriginalID,
				'Value'=DocumentValue,'Adjusted Amount' = AdjustedAmount,Null,
				'Doc Ref'=Case when documenttype=4 then cast((Select DocumentID from ARVAbstract where ARVID=dbo.gettrueval(OriginalID)) as nvarChar) else OriginalID end,
				'Doc Type'=case when documentType=4 then @ARV else DocumentType end,
				'Cheque Date'=dbo.stripdatefromtime(Collections.ChequeDate),
				'Cheque Number'=Collections.ChequeNumber,case when documentType=4 then 28 else @SPECIALCASE2 end from
				CollectionDetail,Collections where CollectionID=@DocRef and Collections.DocumentID=CollectionDetail.CollectionID
		End

	End
End
Else If @DocType= @DEPOSITS or @DocType=@REPOFBOUNCECHEQUE
Begin
		select 'Document Date' = dbo.stripdatefromtime(DocumentDate), 'Document ID'=FullDocID,'Description'=dbo.getdescription(DocumentID,@COLLECTIONS),
		'Particular' = case when CustomerID is not null then (Select Company_Name from Customer where Customer.CustomerID=Collections.CustomerID) 
		else (Case when isnull(Others,0) <>0 then dbo.getaccountname(Collections.Others) else dbo.getaccountname(Collections.ExpenseAccount) end) end,
		'Value'=Value,Null,'DocRef'=DocumentID,'DocType'=@COLLECTIONS, 'Cheque Date'=dbo.stripdatefromtime(Collections.ChequeDate),
		'Cheque Number'=Collections.ChequeNumber, 'Deposit date'=dbo.stripdatefromtime(Collections.DepositDate),
		'Expense'=Case when (Collections.CustomerID is Null and isnull(Others,0) <> 0 and isnull(ExpenseAccount,0) <> 0) 
		then dbo.getaccountname(ExpenseAccount) else '' end, 20
		from Collections where DepositID=@DocRef
/*
		select 'Document Date' = dbo.stripdatefromtime(CollectionDetail.DocumentDate),
		'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=OriginalID,
		'Value'=DocumentValue, 'Adjusted Amount' = AdjustedAmount,Null,
		'Doc Ref'=case when documentType=4 then cast((Select InvoiceID from InvoiceAbstract where DocumentID=dbo.gettrueval(OriginalID)) as nVarChar) else OriginalID end,		'Doc Type'=Case when DocumentType=4 then @Invoice else DocumentType end,
		'Cheque Date'=dbo.stripdatefromtime(Collections.ChequeDate),
		'Cheque Number'=Collections.ChequeNumber,
		'Deposit date'=dbo.stripdatefromtime(Collections.DepositDate), 
		Case when DocumentType=4 then 13 else @SPECIALCASE2 end 
		from CollectionDetail,Collections where CollectionID=@DocRef and 
		Collections.DocumentID=CollectionDetail.CollectionID 
*/
End
Else If @DocType= @BOUNCECHEQUE
Begin
	Set @CustomerID=(Select CustomerID from Collections where DocumentID=@DocRef)
	If @CustomerID is not null
	Begin
		select 'Document Date' = dbo.stripdatefromtime(CollectionDetail.DocumentDate),
		'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=OriginalID,
		'Value'=DocumentValue, 'Adjusted Amount' = AdjustedAmount,
		Null,'Doc Ref'=case when DocumentType=4 then cast((Select InvoiceID from InvoiceAbstract where DocumentID=dbo.gettrueval(OriginalID)) as nVarChar) else OriginalID end,
		'Doc Type'=Case when DocumentType=4 then @Invoice else DocumentType end, 
		'Cheque Date'=dbo.stripdatefromtime(Collections.ChequeDate),
		'Cheque Number'=Collections.ChequeNumber,'Deposit Date'=dbo.stripdatefromtime(Collections.DepositDate),
		'Realisation Date' = dbo.stripdatefromtime(Collections.RealisationDate),'Bank Charges'=Collections.BankCharges, 
		Case when DocumentType=4 then 13 else @SPECIALCASE2 end from CollectionDetail,Collections where 
		CollectionID=@DocRef and Collections.DocumentID=CollectionDetail.CollectionID 
	End
	Else
	Begin
		select 'Document Date' = dbo.stripdatefromtime(CollectionDetail.DocumentDate),
		'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=OriginalID,
		'Value'=DocumentValue, 'Adjusted Amount' = AdjustedAmount,
		Null,'Doc Ref'=case when DocumentType=4 then cast((Select DocumentID from ARVAbstract where ARVID=dbo.gettrueval(OriginalID)) as nVarChar) else OriginalID end,
		'Doc Type'=Case when DocumentType=4 then @ARV else DocumentType end, 
		'Cheque Date'=dbo.stripdatefromtime(Collections.ChequeDate),
		'Cheque Number'=Collections.ChequeNumber,'Deposit Date'=dbo.stripdatefromtime(Collections.DepositDate),
		'Realisation Date' = dbo.stripdatefromtime(Collections.RealisationDate),'Bank Charges'=Collections.BankCharges, 
		Case when DocumentType=4 then 28 else @SPECIALCASE2 end from CollectionDetail,Collections where 
		CollectionID=@DocRef and Collections.DocumentID=CollectionDetail.CollectionID 
	End
End

Else If @DocType= @PAYMENTS or @DocType= @AUTOENTRY or @DocType= @PAYMENTCANCELLATION
	OR @DocType= @MANUALJOURNALPAYMENTS
Begin

	Set @PaymentMode=(Select PaymentMode from Payments where DocumentID=@DocRef)
	Set @VendorID=(Select VendorID from Payments where DocumentID=@DocRef)
	If @VendorID is not Null
	Begin
		If @PaymentMode=0
		Begin
			
			select 'Document Date' = dbo.stripdatefromtime(DocumentDate), 
			'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),
			'Document ID'=OriginalID,'Value'=DocumentValue,'Adjusted Amount' = AdjustedAmount, 
			Null,'Doc Ref'=case when DocumentType=4 then cast((Select BillID from BillAbstract where DocumentID=dbo.gettrueval(OriginalID)) as nVarchar) else OriginalID End,
			'Doc Type'=Case when DocumentType=4 then @Bill else DocumentType end,Case when DocumentType=4 then 14 else @SPECIALCASE2 end from PaymentDetail where PaymentID=@DocRef
		End
		Else
		Begin
			
			select 'Document Date' = dbo.stripdatefromtime(PaymentDetail.DocumentDate),
			'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=OriginalID,
			'Value'=DocumentValue,'Adjusted Amount' = AdjustedAmount,Null,
			'Doc Ref'=case when DocumentType=4 then cast((Select BillID from BillAbstract where DocumentID=dbo.gettrueval(OriginalID)) as nVarChar) else OriginalID end,
	
			'Doc Type'=Case when DocumentType=4 then @Bill else DocumentType end,
			'Cheque Date'=dbo.stripdatefromtime(Payments.Cheque_Date),
			'Cheque Number'= case when @PaymentMode =1 then dbo.GetChequeNumber(Payments.Cheque_ID,Payments.Cheque_Number)
			else cast(Cheque_Number as nvarchar(30)) end,	Case when DocumentType=4 then 14 else @SPECIALCASE2 end 
			from PaymentDetail,Payments where PaymentID=@DocRef and payments.DocumentID=PaymentDetail.PaymentID
		
		End
	End
	Else
	Begin
		If @PaymentMode=0
		Begin
			
			select 'Document Date' = dbo.stripdatefromtime(DocumentDate), 
			'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),
			'Document ID'=OriginalID,'Value'=DocumentValue,'Adjusted Amount' = AdjustedAmount, 
			Null,'Doc Ref'=case when DocumentType=4 then cast((Select DocumentID 
			from APVAbstract where APVID=dbo.gettrueval(OriginalID)) as nVarchar) else OriginalID End,
			'Doc Type'=Case when DocumentType=4 then @APV else DocumentType end,
			Case when DocumentType=4 then 28 else @SPECIALCASE2 end from 
			PaymentDetail where PaymentID=@DocRef
		End
		Else
		Begin
			
			select 'Document Date' = dbo.stripdatefromtime(PaymentDetail.DocumentDate),
			'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=OriginalID,
			'Value'=DocumentValue,'Adjusted Amount' = AdjustedAmount,Null,
			'Doc Ref'=case when DocumentType=4 then cast((Select DocumentID from APVAbstract 
			where APVID=dbo.gettrueval(OriginalID)) as nVarChar) else OriginalID end,
			'Doc Type'=Case when DocumentType=4 then @APV else DocumentType end,
			'Cheque Date'=dbo.stripdatefromtime(Payments.Cheque_Date),
		        'Cheque Number'= case when @PaymentMode =1 then dbo.GetChequeNumber(Payments.Cheque_ID,Payments.Cheque_Number) 
			else cast(Cheque_Number as nvarchar(30)) end, Case when DocumentType=4 then 28 else @SPECIALCASE2 end
			from PaymentDetail,Payments where PaymentID=@DocRef
			and payments.DocumentID=PaymentDetail.PaymentID
		
		End
	End

End
Else if @DocType = @CLAIMSTOVENDOR OR @DocType = @CLAIMSSETTLEMENT OR @DocType = @CLAIMSCANCELLATION
Begin
	Execute sp_acc_rpt_ClaimsDetail @DocRef
End
Else if @DocType = @MANUALJOURNALOLDREF
Begin

	Select 'Document Date'=dbo.stripdatefromtime(TransactionDate),'Document ID'=dbo.GetOriginalID(DocumentReference,DocumentType),
	'Description'=dbo.GetDescription(DocumentReference,DocumentType),'','Debit'=Debit,'Credit'=Credit,
	'DocRef'= Documentreference,
	'DocType'=DocumentType,'AccountID'=GeneralJournal.AccountID,'High Light'=dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference) 
	from GeneralJournal,AccountsMaster where 
	GeneralJournal.AccountID = AccountsMaster.AccountID and 
	TransactionID=@DocRef and DocumentType not in (36,37) --36 is diplay entry in manual journal form
End
Else IF @DocType = @ARV OR @DocType = @ARVCANCELLATION
Begin
	select 'Type'=Case when Type=0 then dbo.LookupDictionaryItem('Asset',Default)  else dbo.LookupDictionaryItem('Others',Default)  end,'Account Name'=dbo.getaccountName(AccountID),'Amount'=Amount,
--	Particular,AccountID,Type,'Doc Ref'=@DocRef,'Doc Type'=@ARVDETAIL,'Info'=cast(Type as varchar) + char(3) + Particular,
	Particular,AccountID,'Doc Ref'=@DocRef,Type,'Doc Type'=@ARVDETAIL,Particular,
	'High Light'=Case when Type=0 then 26 else 27 end from ARVDetail where DocumentID=@DocRef

End
Else IF @DocType = @APV OR @DocType = @APVCANCELLATION
Begin
	select 'Type'=Case when Type=0 then dbo.LookupDictionaryItem('Items',Default)  else (case when Type=1 then dbo.LookupDictionaryItem('others',Default)  else dbo.LookupDictionaryItem('Asset',Default)  end) end,'Account Name'=dbo.getaccountName(AccountID),'Amount'=Amount,
--	Particular,AccountID,Type,'Doc Ref'=@DocRef,'Doc Type'=@ARVDETAIL,Cast(Type as Varchar) + char(3) + Particular,
	Particular,AccountID,'Doc Ref'=@DocRef,Type,'Doc Type'=@ARVDETAIL,Particular,
	'High Light'=Case when Type=0 then 25 else (case when Type=1 then 26 else 27 end) end from APVDetail where DocumentID=@DocRef
End
Else IF @DocType = @ARVDETAIL
Begin
	Execute sp_acc_rpt_arvsubdetail @DocRef,@Info --here @DocRef contains Type 
End

Else IF @DocType = @APVDETAIL
Begin
	Execute sp_acc_rpt_apvsubdetail @DocRef,@Info
End
Else if @DocType= @STOCKTRANSFERIN
Begin
	Execute sp_acc_rpt_stocktransferindetail @DocRef
End
Else if @DocType= @STOCKTRANSFEROUT
Begin
	Execute sp_acc_rpt_stocktransferoutdetail @DocRef
End




































