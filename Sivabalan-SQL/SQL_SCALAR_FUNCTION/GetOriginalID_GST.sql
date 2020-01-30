CREATE Function GetOriginalID_GST(@DocRef INT,@DocType INT)        
Returns nvarchar(100)        
As        
Begin        
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
Declare @DEPOSITS_CANCELLATION INT    
Declare @BOUNCECHEQUE INT        
Declare @BOUNCECHEQUE_CANCELLATION INT        
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
Declare @ARV_AMENDMENT Int        
Declare @APV_AMENDMENT Int      
        
Declare @MANUALJOURNALINVOICE int        
Declare @MANUALJOURNALSALESRETURN int        
Declare @MANUALJOURNALBILL int        
Declare @MANUALJOURNALPURCHASERETURN int        
Declare @MANUALJOURNALCOLLECTIONS int        
Declare @MANUALJOURNALPAYMENTS int        
Declare @MANUALJOURNALDEBITNOTE int        
Declare @MANUALJOURNALCREDITNOTE int        
Declare @MANUALJOURNALOLDREF int        
Declare @CONTRAENTRYCANCELLATION int        
        
Declare @MANUALJOURNALAPV int        
Declare @MANUALJOURNALARV int        
Declare @MANUALJOURNALOTHERPAYMENTS int        
Declare @MANUALJOURNALOTHERRECEIPTS int        
        
Declare @MANUALJOURNALOTHERDEBITNOTE int        
Declare @MANUALJOURNALOTHERCREDITNOTE int        
        
Declare @SALESRETURNCANCELLATION INT        
Declare @DISPATCH int        
Declare @DISPATCHCANCELLATION int        
Declare @APV int        
Declare @APVCANCELLATION int        
Declare @ARV int        
Declare @ARVCANCELLATION int        
Declare @STOCKTRANSFERIN int        
Declare @STOCKTRANSFEROUT int        
Declare @PETTYCASH int        
Declare @PETTYCASHCANCELLATION int        
        
Declare @GRN int        
Declare @GRNCANCELLATION int        
        
Declare @DEBITNOTECANCELLATION INT        
Declare @CREDITNOTECANCELLATION INT        
        
Declare @STOCKTRANSFERINCANCELLATION int        
Declare @STOCKTRANSFEROUTCANCELLATION int        
Declare @STOCKTRANSFERINAMENDMENT int        
Declare @STOCKTRANSFEROUTAMENDMENT int        
Declare @DISPATCHAMENDMENT int        
Declare @SALESRETURNAMENDMENT int        
Declare @GRNAMENDMENT int        
Declare @PURCHASERETURNAMENDMENT int        
Declare @INTERNALCONTRA int        
Declare @INTERNALCONTRACANCELLATION int        
Declare @COLLECTIONAMENDMENT INT        
Declare @PAYMENT_AMENDMENT INT        
Declare @DocumentDesc nvarchar(50)        
Declare @MANUALJOURNAL_NEWREFERENCE Int        
Declare @MANUALJOURNALCLAIMS INT        
Declare @CREDITNOTE_AMENDMENT INT       
Declare @DEBITNOTE_AMENDMENT INT        
Declare @ISSUE_SPARES INT        
Declare @ISSUE_SPARES_CANCEL INT        
Declare @ISSUE_SPARES_RETURN INT        
Declare @SERVICE_INVOICE INT        
Declare @SERVICE_INVOICE_CANCEL INT        
      
Declare @DocumentNumber Int        
      
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
set @CONTRAENTRYCANCELLATION =38        
        
Set @SALESRETURNCANCELLATION =40        
Set @DISPATCH = 44        
Set @DISPATCHCANCELLATION = 45        
set @APV = 46        
set @APVCANCELLATION =47        
Set @ARV = 48        
Set @ARVCANCELLATION = 49        
        
Set @PETTYCASH =52        
Set @PETTYCASHCANCELLATION =53        
Set @STOCKTRANSFERIN = 54        
Set @STOCKTRANSFEROUT = 55        
        
Set @GRN = 41        
Set @GRNCANCELLATION =42        
        
Set @MANUALJOURNALAPV = 60        
Set @MANUALJOURNALARV = 61        
Set @MANUALJOURNALOTHERPAYMENTS = 62        
Set @MANUALJOURNALOTHERRECEIPTS = 63        
        
Set @DEBITNOTECANCELLATION = 64        
Set @CREDITNOTECANCELLATION = 65        
        
Set @GRNAMENDMENT = 66        
        
Set @STOCKTRANSFERINCANCELLATION =67        
Set @STOCKTRANSFEROUTCANCELLATION =68        
Set @STOCKTRANSFERINAMENDMENT =69        
Set @STOCKTRANSFEROUTAMENDMENT =70        
Set @DispatchAmendment=71        
Set @SalesReturnAmendment=72        
Set @PURCHASERETURNAMENDMENT = 73        
Set @INTERNALCONTRA = 74        
Set @INTERNALCONTRACANCELLATION = 75        
Set @COLLECTIONAMENDMENT=77        
Set @PAYMENT_AMENDMENT = 78        
Set @MANUALJOURNALOTHERDEBITNOTE = 79        
Set @MANUALJOURNALOTHERCREDITNOTE = 80        
Set @MANUALJOURNAL_NEWREFERENCE = 81        
Set @MANUALJOURNALCLAIMS = 82        
Set @ARV_AMENDMENT = 83        
Set @APV_AMENDMENT = 84      
Set @ISSUE_SPARES = 85        
Set @ISSUE_SPARES_CANCEL = 86        
Set @ISSUE_SPARES_RETURN = 87        
Set @SERVICE_INVOICE = 88        
Set @SERVICE_INVOICE_CANCEL = 89        
set @CREDITNOTE_AMENDMENT = 90      
Set @DEBITNOTE_AMENDMENT = 91      
Set @DEPOSITS_CANCELLATION = 92    
Set @BOUNCECHEQUE_CANCELLATION = 93  
Declare @RetValue nvarchar(100)
Declare @FindGiftVoucher Int

If @DocType = @CREDITNOTE Or @DocType = @MANUALJOURNALCREDITNOTE Or @DocType = @MANUALJOURNALOTHERCREDITNOTE Or @DocType = @CREDITNOTECANCELLATION Or @DocType = @CREDITNOTE_AMENDMENT
Begin
	If Exists (Select 'x' from clocrnote where isnull(creditID,0) = @DocRef  and isnull(isgenerated,0)=1)
				Begin
					Set @FindGiftVoucher = 1
				End
			Else
				Begin
					Set @FindGiftVoucher = 0
				End
End


    
If @DocType = @BILLAMENDMENT         
Begin        
 Set @DocumentDesc = dbo.sp_acc_getdocumentid(@DocType,@DocRef)        
End         
If @DocType = @MANUALJOURNAL_NEWREFERENCE         
Begin        
 Select @DocumentNumber = DocumentID from        
 ManualJournal Where NewRefID = @DocRef        
End         
 
If @DocType = @ISSUE_SPARES Or @DocType = @ISSUE_SPARES_CANCEL Or @DocType = @ISSUE_SPARES_RETURN  
 Set @RetValue=(dbo.getvoucherprefix('ISSUESPARES') + cast ((Select DocumentID from IssueAbstract where IssueID=@DocRef) as nvarchar))  
Else If @DocType = @SERVICE_INVOICE Or @DocType = @SERVICE_INVOICE_CANCEL  
 Set @RetValue=(dbo.getvoucherprefix('SERVICEINVOICE') + cast ((Select DocumentID from ServiceInvoiceAbstract where ServiceInvoiceID=@DocRef) as nvarchar))  
Else    
 Begin  
  Set @RetValue=Case @DocType        
  When @RETAILINVOICE then (Select "DocumentID" = Case IsNULL(GSTFlag ,0) When 0 then dbo.getvoucherprefix('INVOICE') + CAST(DocumentID as nvarchar) Else IsNULL(GSTFullDocID,'') End from InvoiceAbstract where InvoiceID=@DocRef)         
  When @RETAILINVOICEAMENDMENT then(Select "DocumentID" = Case IsNULL(GSTFlag ,0) When 0 then dbo.getvoucherprefix('INVOICE') + CAST(DocumentID as nvarchar) Else IsNULL(GSTFullDocID,'') End from InvoiceAbstract where InvoiceID=@DocRef) 
  When @RETAILINVOICECANCELLATION then (Select "DocumentID" = Case IsNULL(GSTFlag ,0) When 0 then dbo.getvoucherprefix('INVOICE') + CAST(DocumentID as nvarchar) Else IsNULL(GSTFullDocID,'') End from InvoiceAbstract where InvoiceID=@DocRef) 
  When @INVOICE then (Select "DocumentID" = Case IsNULL(GSTFlag ,0) When 0 then dbo.getvoucherprefix('INVOICE') + CAST(DocumentID as nvarchar) Else IsNULL(GSTFullDocID,'') End from InvoiceAbstract where InvoiceID=@DocRef) 
  When @INVOICEAMENDMENT then (Select "DocumentID" = Case IsNULL(GSTFlag ,0) When 0 then dbo.getvoucherprefix('INVOICE') + CAST(DocumentID as nvarchar) Else IsNULL(GSTFullDocID,'') End from InvoiceAbstract where InvoiceID=@DocRef)
  When @INVOICECANCELLATION then (Select "DocumentID" = Case IsNULL(GSTFlag ,0) When 0 then dbo.getvoucherprefix('INVOICE') + CAST(DocumentID as nvarchar) Else IsNULL(GSTFullDocID,'') End from InvoiceAbstract where InvoiceID=@DocRef) 
  When @SALESRETURN then (Select "DocumentID" = Case IsNULL(GSTFlag ,0) When 0 then dbo.getvoucherprefix('INVOICE') + CAST(DocumentID as nvarchar) Else IsNULL(GSTFullDocID,'') End from InvoiceAbstract where InvoiceID=@DocRef) 
          
  When @BILL then (dbo.getvoucherprefix('BILL') + cast ((Select DocumentID from BillAbstract where BillID=@DocRef) as nvarchar))        
  When @BILLAMENDMENT then (dbo.getvoucherprefix(@DocumentDesc) + cast ((Select DocumentID from BillAbstract where BillID=@DocRef) as nvarchar))        
  When @BILLCANCELLATION then (dbo.getvoucherprefix('BILL') + cast ((Select DocumentID from BillAbstract where BillID=@DocRef) as nvarchar))        
  When @PURCHASERETURN then (Select "DocumentID" = Case IsNULL(GSTFullDocID,'') When '' then dbo.getvoucherprefix('STOCK ADJUSTMENT PURCHASE RETURN') + cast(DocumentID as nvarchar) Else IsNULL(GSTFullDocID,'') End from AdjustmentReturnAbstract where AdjustmentID=@DocRef) 
  When @PURCHASERETURNCANCELLATION then (Select "DocumentID" = Case IsNULL(GSTFullDocID,'') When '' then dbo.getvoucherprefix('STOCK ADJUSTMENT PURCHASE RETURN') + cast(DocumentID as nvarchar) Else IsNULL(GSTFullDocID,'') End from AdjustmentReturnAbstract where AdjustmentID=@DocRef) 
  When @PURCHASERETURNAMENDMENT then (Select "DocumentID" = Case IsNULL(GSTFullDocID,'') When '' then dbo.getvoucherprefix('STOCK ADJUSTMENT PURCHASE RETURN') + cast(DocumentID as nvarchar) Else IsNULL(GSTFullDocID,'') End  from AdjustmentReturnAbstract where AdjustmentID=@DocRef) 
           
  When @COLLECTIONS then (Select FullDocID from Collections where DocumentID=@DocRef)        
  When @DEPOSITS then (Select FullDocID from Deposits where DepositID=@DocRef)        
  When @DEPOSITS_CANCELLATION then (Select FullDocID from Deposits where DepositID=@DocRef)        
  When @BOUNCECHEQUE then (Select FullDocID from Collections where DocumentID=@DocRef)        
  When @BOUNCECHEQUE_CANCELLATION then (Select FullDocID from Collections where DocumentID=@DocRef)        
  When @REPOFBOUNCECHEQUE then (Select FullDocID from Deposits where DepositID=@DocRef)        
          
  When @PAYMENTS then (Select FullDocID from Payments where DocumentID=@DocRef)        
  When @PAYMENTCANCELLATION then (Select FullDocID from Payments where DocumentID=@DocRef)        
  When @AUTOENTRY then (Select FullDocID from Payments where DocumentID=@DocRef)        
  When @DEBITNOTE then (dbo.getvoucherprefix('DEBIT NOTE') + cast ((Select DocumentID from DebitNote where DebitID=@DocRef) as nvarchar))        
  When @CREDITNOTE then 
	Case When @FindGiftVoucher = 0 Then
	(dbo.getvoucherprefix('CREDIT NOTE') + cast ((Select DocumentID from CreditNote where CreditID=@DocRef) as nvarchar))
	Else
	(dbo.getvoucherprefix('GIFT VOUCHER') + cast ((Select DocumentID from CreditNote where CreditID=@DocRef) as nvarchar))
	End    
  When @CLAIMSTOVENDOR then (dbo.getvoucherprefix('CLAIMS NOTE') + cast ((Select DocumentID from ClaimsNote where ClaimID=@DocRef) as nvarchar))        
  When @CLAIMSSETTLEMENT then (dbo.getvoucherprefix('CLAIMS NOTE') + cast ((Select DocumentID from ClaimsNote where ClaimID=@DocRef) as nvarchar))        
  When @CLAIMSCANCELLATION then (dbo.getvoucherprefix('CLAIMS NOTE') + cast ((Select DocumentID from ClaimsNote where ClaimID=@DocRef) as nvarchar))        
  When @COLLECTIONCANCELLATION then (Select FullDocID from Collections where DocumentID=@DocRef)        
  When @MANUALJOURNAL then (dbo.getvoucherprefix('MANUAL JOURNAL') + cast ((Select @DocRef) as nvarchar))        
          
  When @MANUALJOURNALINVOICE then (Select "DocumentID" = Case IsNULL(GSTFlag ,0) When 0 then dbo.getvoucherprefix('INVOICE') + CAST(DocumentID as nvarchar) Else IsNULL(GSTFullDocID,'') End from InvoiceAbstract where InvoiceID=@DocRef)
  When @MANUALJOURNALSALESRETURN then (Select "DocumentID" = Case IsNULL(GSTFlag ,0) When 0 then dbo.getvoucherprefix('INVOICE') + CAST(DocumentID as nvarchar) Else IsNULL(GSTFullDocID,'') End from InvoiceAbstract where InvoiceID=@DocRef) 
  When @MANUALJOURNALBILL then (dbo.getvoucherprefix('BILL') + cast ((Select DocumentID from BillAbstract where BillID=@DocRef) as nvarchar))        
  When @MANUALJOURNALPURCHASERETURN then (Select "DocumentID" = Case IsNULL(GSTFullDocID,'') When '' then dbo.getvoucherprefix('STOCK ADJUSTMENT PURCHASE RETURN') + cast(DocumentID as nvarchar) Else IsNULL(GSTFullDocID,'') End from  AdjustmentReturnabstract  where AdjustmentID=@DocRef) 
  When @MANUALJOURNALCOLLECTIONS then (Select FullDocID from Collections where DocumentID=@DocRef)        
  When @MANUALJOURNALPAYMENTS then (Select FullDocID from Payments where DocumentID=@DocRef)        
  When @MANUALJOURNALDEBITNOTE then (dbo.getvoucherprefix('DEBIT NOTE') + cast ((Select DocumentID from DebitNote where DebitID=@DocRef) as nvarchar))        
  When @MANUALJOURNALCREDITNOTE then 
	Case When @FindGiftVoucher = 0 Then
	(dbo.getvoucherprefix('CREDIT NOTE') + cast ((Select DocumentID from CreditNote where CreditID=@DocRef) as nvarchar))
	Else
	(dbo.getvoucherprefix('GIFT VOUCHER') + cast ((Select DocumentID from CreditNote where CreditID=@DocRef) as nvarchar))
	End

  When @MANUALJOURNALOLDREF then (dbo.getvoucherprefix('MANUAL JOURNAL') + cast ((Select @DocRef) as nvarchar))        
  When @MANUALJOURNALOTHERDEBITNOTE then (dbo.getvoucherprefix('DEBIT NOTE') + cast ((Select DocumentID from DebitNote where DebitID=@DocRef) as nvarchar))        
  When @MANUALJOURNALOTHERCREDITNOTE then 
	Case When @FindGiftVoucher = 0 Then
		(dbo.getvoucherprefix('CREDIT NOTE') + cast ((Select DocumentID from CreditNote where CreditID=@DocRef) as nvarchar))
	Else
		(dbo.getvoucherprefix('GIFT VOUCHER') + cast ((Select DocumentID from CreditNote where CreditID=@DocRef) as nvarchar))
	End	        
  When @MANUALJOURNAL_NEWREFERENCE then (dbo.getvoucherprefix('MANUAL JOURNAL') + cast ((Select @DocumentNumber) as nvarchar))        
  When @MANUALJOURNALCLAIMS then (dbo.getvoucherprefix('CLAIMS NOTE') + cast ((Select DocumentID from ClaimsNote where ClaimID=@DocRef) as nvarchar))        
          
  When @CONTRAENTRYCANCELLATION then (Select FullDocID from Deposits where DepositID=@DocRef)        
          
  When @SALESRETURNCANCELLATION then (Select "DocumentID" = Case IsNULL(GSTFlag ,0) When 0 then dbo.getvoucherprefix('INVOICE') + CAST(DocumentID as nvarchar) Else IsNULL(GSTFullDocID,'') End from InvoiceAbstract where InvoiceID=@DocRef) 
  When @DISPATCH then (dbo.getvoucherprefix('DISPATCH') + cast ((Select DocumentID from DispatchAbstract where DispatchID=@DocRef) as nvarchar))        
  When @DISPATCHCANCELLATION then (dbo.getvoucherprefix('DISPATCH') + cast ((Select DocumentID from DispatchAbstract where DispatchID=@DocRef) as nvarchar))        
  When @APV then (dbo.getvoucherprefix('ACCOUNTS PAYABLE VOUCHER') + cast ((Select APVID from APVAbstract where DocumentID=@DocRef) as nvarchar))        
  When @APVCANCELLATION then (dbo.getvoucherprefix('ACCOUNTS PAYABLE VOUCHER') + cast ((Select APVID from APVAbstract where DocumentID=@DocRef) as nvarchar))        
  When @ARV then (dbo.getvoucherprefix('ACCOUNTS RECEIVABLE VOUCHER') + cast ((Select ARVID from ARVAbstract where DocumentID=@DocRef) as nvarchar))        
  When @ARVCANCELLATION then (dbo.getvoucherprefix('ACCOUNTS RECEIVABLE VOUCHER') + cast ((Select ARVID from ARVAbstract where DocumentID=@DocRef) as nvarchar))        
  When @STOCKTRANSFERIN then (Select DocPrefix + cast(DocumentID as nvarchar) from StockTransferinAbstract where DocSerial=@DocRef)        
  When @STOCKTRANSFEROUT then (Select DocPrefix + cast(DocumentID as nvarchar) from StockTransferoutAbstract where DocSerial=@DocRef)        
  When @PETTYCASH then (Select FullDocID from Payments where DocumentID=@DocRef)        
  When @PETTYCASHCANCELLATION then (Select FullDocID from Payments where DocumentID=@DocRef)        
  When @GRN then (dbo.getvoucherprefix('GOODS RECEIVED NOTE') + cast ((Select DocumentID from GRNAbstract where GRNID=@DocRef) as nvarchar))        
  When @GRNCANCELLATION then (dbo.getvoucherprefix('GOODS RECEIVED NOTE') + cast ((Select DocumentID from GRNAbstract where GRNID=@DocRef) as nvarchar))        
  When @GRNAMENDMENT then (dbo.getvoucherprefix('GOODS RECEIVED NOTE') + cast ((Select DocumentID from GRNAbstract where GRNID=@DocRef) as nvarchar))        
          
  When @MANUALJOURNALAPV then (dbo.getvoucherprefix('ACCOUNTS PAYABLE VOUCHER') + cast ((Select APVID from APVAbstract where DocumentID=@DocRef) as nvarchar))        
  When @MANUALJOURNALARV then (dbo.getvoucherprefix('ACCOUNTS RECEIVABLE VOUCHER') + cast ((Select ARVID from ARVAbstract where DocumentID=@DocRef) as nvarchar))        
  When @MANUALJOURNALOTHERPAYMENTS then (Select FullDocID from Payments where DocumentID=@DocRef)        
  When @MANUALJOURNALOTHERRECEIPTS then (Select FullDocID from Collections where DocumentID=@DocRef)        
  When @DEBITNOTECANCELLATION then (dbo.getvoucherprefix('DEBIT NOTE') + cast ((Select DocumentID from DebitNote where DebitID=@DocRef) as nvarchar))        
  When @CREDITNOTECANCELLATION then 
	Case When @FindGiftVoucher = 0 Then
		(dbo.getvoucherprefix('CREDIT NOTE') + cast ((Select DocumentID from CreditNote where CreditID=@DocRef) as nvarchar)) 
	Else
		(dbo.getvoucherprefix('GIFT VOUCHER') + cast ((Select DocumentID from CreditNote where CreditID=@DocRef) as nvarchar))
	End
       
  When @STOCKTRANSFERINCANCELLATION then (Select DocPrefix + cast(DocumentID as nvarchar) from StockTransferinAbstract where DocSerial=@DocRef)        
  When @STOCKTRANSFEROUTCANCELLATION then (Select DocPrefix + cast(DocumentID as nvarchar) from StockTransferoutAbstract where DocSerial=@DocRef)        
  When @STOCKTRANSFERINAMENDMENT then (Select DocPrefix + cast(DocumentID as nvarchar) from StockTransferinAbstract where DocSerial=@DocRef)        
  When @STOCKTRANSFEROUTAMENDMENT then (Select DocPrefix + cast(DocumentID as nvarchar) from StockTransferoutAbstract where DocSerial=@DocRef)        
  When @DISPATCHAMENDMENT then (dbo.getvoucherprefix('DISPATCH') + cast ((Select DocumentID from DispatchAbstract where DispatchID=@DocRef) as nvarchar))        
  When @SALESRETURNAMENDMENT then (Select "DocumentID" = Case IsNULL(GSTFlag ,0) When 0 then dbo.getvoucherprefix('INVOICE') + CAST(DocumentID as nvarchar) Else IsNULL(GSTFullDocID,'') End from InvoiceAbstract where InvoiceID=@DocRef) 
  When @INTERNALCONTRA then (dbo.getvoucherprefix('INTERNALCONTRA') + cast ((Select DocumentID from ContraAbstract where ContraID=@DocRef) as nvarchar))        
  When @INTERNALCONTRACANCELLATION then (dbo.getvoucherprefix('INTERNALCONTRA') + cast ((Select DocumentID from ContraAbstract where ContraID=@DocRef) as nvarchar))        
  When @COLLECTIONAMENDMENT then (Select FullDocID from Collections where DocumentID=@DocRef)        
  When @PAYMENT_AMENDMENT then (Select FullDocID from Payments where DocumentID=@DocRef)        
  When @ARV_AMENDMENT then (dbo.getvoucherprefix('ACCOUNTS RECEIVABLE VOUCHER') + cast ((Select ARVID from ARVAbstract where DocumentID=@DocRef) as nvarchar))        
  When @APV_AMENDMENT then (dbo.getvoucherprefix('ACCOUNTS PAYABLE VOUCHER') + cast ((Select APVID from APVAbstract where DocumentID=@DocRef) as nvarchar))      
  When @CREDITNOTE_AMENDMENT then 
	Case When @FindGiftVoucher = 0 Then
		(dbo.getvoucherprefix('CREDIT NOTE') + cast ((Select DocumentID from CreditNote where CreditID=@DocRef) as nvarchar)) 
	Else
		(dbo.getvoucherprefix('GIFT VOUCHER') + cast ((Select DocumentID from CreditNote where CreditID=@DocRef) as nvarchar))
	End     
  When @DEBITNOTE_AMENDMENT then (dbo.getvoucherprefix('DEBIT NOTE') + cast ((Select DocumentID from Debitnote where DebitID=@DocRef) as nvarchar))      
  End        
 End  
 Return @RetValue  
 
END
