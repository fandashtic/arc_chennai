CREATE Procedure sp_acc_rpt_LedgerDetail(@DocRef Int, @DocType INT,@Info nvarchar(4000)=Null)            
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
Declare @DEPOSITS_CANCELLATION INT            
Declare @BOUNCECHEQUE INT            
Declare @BOUNCECHEQUE_CANCEL INT            
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
Declare @CREDITNOTE_AMENDMENT INT       
Declare @DEBITNOTE_AMENDMENT INT       
      
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
Declare @MANUALJOURNALAPV int            
Declare @MANUALJOURNALARV int            
Declare @MANUALJOURNALOTHERPAYMENTS int            
Declare @MANUALJOURNALOTHERRECEIPTS int            
Declare @MANUALJOURNAL_NEWREFERENCE int            
Declare @MANUALJOURNAL_CLAIMS int            
      
Declare @ARV_AMENDMENT INT            
Declare @APV_AMENDMENT INT            
Declare @ARV INT            
Declare @ARVCANCELLATION INT            
Declare @APV INT            
Declare @APVCANCELLATION INT            
Declare @APVDETAIL INT            
Declare @ARVDETAIL INT            
            
Declare @STOCKTRANSFERIN INT            
Declare @STOCKTRANSFERINAMENDMENT int        
Declare @STOCKTRANSFERINCANCELLATION int        
    
Declare @STOCKTRANSFEROUT INT            
Declare @STOCKTRANSFEROUTAMENDMENT int        
Declare @STOCKTRANSFEROUTCELLATION int        
    
Declare @DISPATCH INT            
Declare @DISPATCHAMENDMENT INT            
Declare @DISPATCHCANCELLATION INT            
Declare @GRN INT            
Declare @GRNAMENDMENT INT            
Declare @GRNCANCELLATION INT            
Declare @INTERNALCONTRA INT            
Declare @INTERNALCONTRACANCELLATION INT            
Declare @INTERNALCONTRADETAIL INT            
Declare @COLLECTIONAMENDMENT INT            
Declare @PAYMENT_AMENDMENT INT            
Declare @PURCHASERETURN_AMENDMENT INT            
Declare @PaymentType int            
    
Declare @ISSUE_SPARES INT            
Declare @ISSUE_SPARES_CANCEL INT            
Declare @ISSUE_SPARES_RETURN INT            
Declare @SERVICE_INVOICE INT            
Declare @SERVICE_INVOICE_CANCEL INT            
Declare @SERVICE_INVOICE_SUBDETAIL INT            
    
Set @RETAILINVOICE=1            
Set @RETAILINVOICEAMENDMENT=2            
Set @RETAILINVOICECANCELLATION=3            
Set @INVOICE=4            
Set @INVOICEAMENDMENT=5            
Set @INVOICECANCELLATION=6            
Set @SALESRETURN=7            
Set @BILL=8            
Set @BILLAMENDMENT=9            
Set @BILLCANCELLATION=10            
Set @PURCHASERETURN=11            
Set @PURCHASERETURNCANCELLATION=12    
Set @COLLECTIONS=13            
Set @DEPOSITS=14            
Set @BOUNCECHEQUE=15            
Set @REPOFBOUNCECHEQUE=16            
Set @PAYMENTS=17            
Set @PAYMENTCANCELLATION=18   
Set @AUTOENTRY=19            
Set @DEBITNOTE=20            
Set @CREDITNOTE=21            
Set @CLAIMSTOVENDOR=22            
Set @CLAIMSSETTLEMENT=23            
Set @CLAIMSCANCELLATION=24            
Set @COLLECTIONCANCELLATION=25            
Set @MANUALJOURNAL=26            
            
Set @MANUALJOURNALINVOICE=28            
Set @MANUALJOURNALSALESRETURN=29            
Set @MANUALJOURNALBILL=30            
Set @MANUALJOURNALPURCHASERETURN=31            
Set @MANUALJOURNALCOLLECTIONS=32            
Set @MANUALJOURNALPAYMENTS=33            
Set @MANUALJOURNALDEBITNOTE=34            
Set @MANUALJOURNALCREDITNOTE=35            
Set @MANUALJOURNALOLDREF=37            
            
Set @APV=46           
Set @APVCANCELLATION=47            
Set @ARV=48            
Set @ARVCANCELLATION=49            
Set @APVDETAIL=50            
Set @ARVDETAIL=51            
            
Set @STOCKTRANSFERIN=54            
Set @STOCKTRANSFERINAMENDMENT=69    
Set @STOCKTRANSFERINCANCELLATION=67    
    
Set @STOCKTRANSFEROUT=55            
Set @STOCKTRANSFEROUTAMENDMENT=70    
Set @STOCKTRANSFEROUTCELLATION=68    
            
Set @MANUALJOURNALAPV=60            
Set @MANUALJOURNALARV=61            
Set @MANUALJOURNALOTHERPAYMENTS=62            
Set @MANUALJOURNALOTHERRECEIPTS=63            
            
Set @DISPATCH=44            
Set @DISPATCHAMENDMENT=71            
Set @DISPATCHCANCELLATION=45            
Set @GRN=41            
Set @GRNAMENDMENT=66            
Set @GRNCANCELLATION=42            
Set @INTERNALCONTRA=74            
Set @INTERNALCONTRACANCELLATION=75            
Set @INTERNALCONTRADETAIL=76            
Set @COLLECTIONAMENDMENT=77            
Set @PAYMENT_AMENDMENT=78            
            
Set @MANUALJOURNAL_NEWREFERENCE=81            
Set @MANUALJOURNAL_CLAIMS=82            
Set @PURCHASERETURN_AMENDMENT=73            
Set @ARV_AMENDMENT=83            
Set @APV_AMENDMENT=84            
Set @ISSUE_SPARES=85            
Set @ISSUE_SPARES_CANCEL=86            
Set @ISSUE_SPARES_RETURN=87            
Set @SERVICE_INVOICE=88            
Set @SERVICE_INVOICE_CANCEL=89            
Set @CREDITNOTE_AMENDMENT=90      
set @DEBITNOTE_AMENDMENT=91      
Set @DEPOSITS_CANCELLATION=92        
Set @BOUNCECHEQUE_CANCEL=93    
Set @SERVICE_INVOICE_SUBDETAIL=94    
            
Declare @PaymentMode INT,@CustomerID nVarchar(30),@VendorID nVarchar(30)            
Declare @SPECIALCASE2 INT            
SET @SPECIALCASE2=5 --Restrict the link after leaf level            
            
set dateformat dmy            
            
If @DocType=@RETAILINVOICE OR @DocType=@RETAILINVOICEAMENDMENT OR @DocType=@RETAILINVOICECANCELLATION             
   OR @DocType=@INVOICE OR @DocType=@INVOICEAMENDMENT OR @DocType=@INVOICECANCELLATION OR @DocType=@SALESRETURN             
   OR @Doctype=@MANUALJOURNALINVOICE OR @Doctype=@MANUALJOURNALSALESRETURN            
Begin            
 Execute sp_acc_rpt_invoicedetail @DocRef            
End            
Else if @DocType=@BILL OR @DocType=@BILLAMENDMENT OR @DocType=@BILLCANCELLATION OR @DocType=@MANUALJOURNALBILL            
Begin            
 Execute sp_acc_rpt_billdetail @DocRef            
End            
Else If @DocType=@PURCHASERETURN OR @DocType=@PURCHASERETURNCANCELLATION OR @DocType=@MANUALJOURNALPURCHASERETURN OR @DocType=@PURCHASERETURN_AMENDMENT            
Begin            
 Execute sp_acc_rpt_stkadjretdetail @DocRef            
End            
Else If @DocType=@COLLECTIONS OR @DocType=@COLLECTIONCANCELLATION OR @DocType=@COLLECTIONAMENDMENT OR @DocType=@MANUALJOURNALCOLLECTIONS OR @DocType=@MANUALJOURNALOTHERRECEIPTS            
Begin            
 Set @PaymentMode=(Select PaymentMode from Collections where DocumentID=@DocRef)            
 Set @CustomerID=(Select CustomerID from Collections where DocumentID=@DocRef)            
 If @CustomerID is not null            
 Begin            
  If @PaymentMode=0            
  Begin            
   select 'Document Date'=dbo.stripdatefromtime(CollectionDetail.DocumentDate),             
   'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=OriginalID,            
   'Document Reference'=dbo.sp_acc_GetFlexibleNumber(@DocRef,@DocType),      
   'Value'=DocumentValue,'Adjusted Amount'=AdjustedAmount,             
   Null,'Doc Ref'=case when documentType=4 then cast(CollectionDetail.DocumentID as nVarchar)  
   when documentType=12 then cast(CollectionDetail.DocumentID as nVarchar) else OriginalID end,            
   'Doc Type'=case when documenttype=4 then @Invoice when documenttype=12 then @SERVICE_INVOICE else DocumentType end,            
   'Narration'=Case When DocumentType=4 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@ARV)) When DocumentType=3 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@COLLECTIONS)) When DocumentType=7 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@PAYMENTS)) When DocumentType=6 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@APV)) When DocumentType=8 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) When DocumentType=9 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) end,            
   case when documentType=4 then 13 when documentType=12 then 98 else @SPECIALCASE2 end from             
   CollectionDetail where CollectionID=@DocRef            
  End            
  Else If @PaymentMode=3
   Begin            
    select 'Document Date'=dbo.stripdatefromtime(CollectionDetail.DocumentDate),      
    'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=CollectionDetail.OriginalID, 
    'Document Reference'=dbo.sp_acc_GetFlexibleNumber(@DocRef,@DocType),      
    'Value'=DocumentValue,'Adjusted Amount'=AdjustedAmount,Null,            
    'Doc Ref'=Case when documenttype=4 then cast(CollectionDetail.DocumentID as nvarChar)  
    when documentType=12 then cast(CollectionDetail.DocumentID as nVarchar) else CollectionDetail.OriginalID end,            
    'Doc Type'=case when documentType=4 then @Invoice when documenttype=12 then @SERVICE_INVOICE else DocumentType end,            
    'Bank Account'=(Select BankName from BankMaster Where BankMaster.BankCode=Bank.BankCode) + N' - ' + Cast(Bank.Account_Number as nVarChar),
    'CreditCard Number'=IsNull(Collections.CreditCardNumber,N''),            
    'Narration'=Case When DocumentType=4 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@ARV))
    When DocumentType=3 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@COLLECTIONS))
    When DocumentType=7 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@PAYMENTS))
    When DocumentType=6 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@APV))
    When DocumentType=8 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE))
    When DocumentType=9 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) end,            
    case when documentType=4 then 13 when documentType=12 then 98 else @SPECIALCASE2 end from            
    CollectionDetail,Collections,Bank where CollectionID=@DocRef and Collections.DocumentID=CollectionDetail.CollectionID
    And Collections.BankID = Bank.BankID
   End   
  Else If @PaymentMode=4
   Begin            
    select 'Document Date'=dbo.stripdatefromtime(CollectionDetail.DocumentDate),            
    'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=CollectionDetail.OriginalID,            
    'Document Reference'=dbo.sp_acc_GetFlexibleNumber(@DocRef,@DocType),      
    'Value'=DocumentValue,'Adjusted Amount'=AdjustedAmount,Null,            
    'Doc Ref'=Case when documenttype=4 then cast(CollectionDetail.DocumentID as nvarChar)  
    when documentType=12 then cast(CollectionDetail.DocumentID as nVarchar) else CollectionDetail.OriginalID end,            
    'Doc Type'=case when documentType=4 then @Invoice when documenttype=12 then @SERVICE_INVOICE else DocumentType end,            
    'Account No'=Account_Number,'Bank Transaction Code'=IsNULL(Memo,N''),
    'Narration'=Case When DocumentType=4 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@ARV)) 
    When DocumentType=3 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@COLLECTIONS)) 
    When DocumentType=7 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@PAYMENTS)) 
    When DocumentType=6 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@APV)) 
    When DocumentType=8 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) 
    When DocumentType=9 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) end,            
    case when documentType=4 then 13 when documentType=12 then 98 else @SPECIALCASE2 end from            
    CollectionDetail,Collections,Bank where CollectionID=@DocRef and Collections.DocumentID=CollectionDetail.CollectionID            
    And Collections.BankID = Bank.BankID
   End    
  Else If @PaymentMode=5
   Begin            
    select 'Document Date'=dbo.stripdatefromtime(CollectionDetail.DocumentDate),      
    'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=OriginalID,            
    'Document Reference'=dbo.sp_acc_GetFlexibleNumber(@DocRef,@DocType),      
    'Value'=DocumentValue,'Adjusted Amount'=AdjustedAmount,Null,            
    'Doc Ref'=Case when documenttype=4 then cast(CollectionDetail.DocumentID as nvarChar)  
    when documentType=12 then cast(CollectionDetail.DocumentID as nVarchar) else OriginalID end,            
    'Doc Type'=case when documentType=4 then @Invoice when documenttype=12 then @SERVICE_INVOICE else DocumentType end,            
    'Coupon Name'=(Select Value from PaymentMode Where Mode=PaymentModeID),
    'Provider Account'=(Select AccountName from AccountsMaster Where AccountID=BankID),
    'Narration'=Case When DocumentType=4 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@ARV))
    When DocumentType=3 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@COLLECTIONS))
    When DocumentType=7 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@PAYMENTS))
    When DocumentType=6 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@APV))
    When DocumentType=8 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE))
    When DocumentType=9 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) end,            
    case when documentType=4 then 13 when documentType=12 then 98 else @SPECIALCASE2 end from            
    CollectionDetail,Collections where CollectionID=@DocRef and Collections.DocumentID=CollectionDetail.CollectionID
   End   
  Else            
   Begin            
    select 'Document Date'=dbo.stripdatefromtime(CollectionDetail.DocumentDate),      
    'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=OriginalID,            
    'Document Reference'=dbo.sp_acc_GetFlexibleNumber(@DocRef,@DocType),      
    'Value'=DocumentValue,'Adjusted Amount'=AdjustedAmount,Null,            
    'Doc Ref'=Case when documenttype=4 then cast(CollectionDetail.DocumentID as nvarChar)  
    when documentType=12 then cast(CollectionDetail.DocumentID as nVarchar) else OriginalID end,            
    'Doc Type'=case when documentType=4 then @Invoice when documenttype=12 then @SERVICE_INVOICE else DocumentType end,            
    'Cheque Date'=dbo.stripdatefromtime(Collections.ChequeDate),            
    'Cheque Number'=Collections.ChequeNumber,        
    'Narration'=Case When DocumentType=4 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@ARV)) When DocumentType=3 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@COLLECTIONS)) When DocumentType=7 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@PAYMENTS)) When DocumentType=6 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@APV)) When DocumentType=8 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) When DocumentType=9 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) end,            
    case when documentType=4 then 13 when documentType=12 then 98 else @SPECIALCASE2 end from            
    CollectionDetail,Collections where CollectionID=@DocRef and Collections.DocumentID=CollectionDetail.CollectionID            
   End            
 End            
 Else            
 Begin            
  If @PaymentMode=0            
  Begin            
   select 'Document Date'=dbo.stripdatefromtime(CollectionDetail.DocumentDate),             
   'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=OriginalID,            
   'Document Reference'=dbo.sp_acc_GetFlexibleNumber(@DocRef,@DocType),      
   'Value'=DocumentValue,'Adjusted Amount'=AdjustedAmount,             
   Null,'Doc Ref'=case when documentType=4 then cast(CollectionDetail.DocumentID as nVarchar) else OriginalID end,            
   'Doc Type'=case when documenttype=4 then @ARV else DocumentType end,          
   'Narration'=Case When DocumentType=4 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@ARV)) When DocumentType=3 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@COLLECTIONS)) When DocumentType=7 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@PAYMENTS)) When DocumentType=6 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@APV)) When DocumentType=8 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) When DocumentType=9 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) end,            
   case when documentType=4 then 28 else @SPECIALCASE2 end from             
   CollectionDetail where CollectionID=@DocRef            
  End            
  Else If @PaymentMode=3
   Begin            
    select 'Document Date'=dbo.stripdatefromtime(CollectionDetail.DocumentDate),            
    'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=CollectionDetail.OriginalID,            
    'Document Reference'=dbo.sp_acc_GetFlexibleNumber(@DocRef,@DocType),      
    'Value'=DocumentValue,'Adjusted Amount'=AdjustedAmount,Null,            
    'Doc Ref'=Case when documenttype=4 then cast(CollectionDetail.DocumentID as nvarChar) else CollectionDetail.OriginalID end,            
    'Doc Type'=case when documentType=4 then @ARV else DocumentType end,            
    'Bank Account'=(Select BankName from BankMaster Where BankMaster.BankCode=Bank.BankCode) + N' - ' + Cast(Bank.Account_Number as nVarChar),
    'CreditCard Number'=IsNull(Collections.CreditCardNumber,N''),            
    'Narration'=Case When DocumentType=4 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@ARV)) 
    When DocumentType=3 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@COLLECTIONS)) 
    When DocumentType=7 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@PAYMENTS)) 
    When DocumentType=6 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@APV)) 
    When DocumentType=8 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) 
    When DocumentType=9 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) end,            
    case when documentType=4 then 28 else @SPECIALCASE2 end from            
    CollectionDetail,Collections,Bank where CollectionID=@DocRef and Collections.DocumentID=CollectionDetail.CollectionID
    And Collections.BankID = Bank.BankID
   End            
  Else If @PaymentMode=4
   Begin            
    select 'Document Date'=dbo.stripdatefromtime(CollectionDetail.DocumentDate),            
    'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=CollectionDetail.OriginalID,            
    'Document Reference'=dbo.sp_acc_GetFlexibleNumber(@DocRef,@DocType),      
    'Value'=DocumentValue,'Adjusted Amount'=AdjustedAmount,Null,            
    'Doc Ref'=Case when documenttype=4 then cast(CollectionDetail.DocumentID as nvarChar) else CollectionDetail.OriginalID end,            
    'Doc Type'=case when documentType=4 then @ARV else DocumentType end,            
    'Account No'=Account_Number,'Bank Transaction Code'=IsNULL(Memo,N''),
    'Narration'=Case When DocumentType=4 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@ARV)) 
    When DocumentType=3 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@COLLECTIONS)) 
    When DocumentType=7 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@PAYMENTS)) 
    When DocumentType=6 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@APV)) 
    When DocumentType=8 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) 
    When DocumentType=9 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) end,            
    case when documentType=4 then 28 else @SPECIALCASE2 end from            
    CollectionDetail,Collections,Bank where CollectionID=@DocRef and Collections.DocumentID=CollectionDetail.CollectionID            
    And Collections.BankID = Bank.BankID
   End    
  Else If @PaymentMode=5
   Begin            
    select 'Document Date'=dbo.stripdatefromtime(CollectionDetail.DocumentDate),            
    'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=OriginalID,            
    'Document Reference'=dbo.sp_acc_GetFlexibleNumber(@DocRef,@DocType),      
    'Value'=DocumentValue,'Adjusted Amount'=AdjustedAmount,Null,            
    'Doc Ref'=Case when documenttype=4 then cast(CollectionDetail.DocumentID as nvarChar) else OriginalID end,            
    'Doc Type'=case when documentType=4 then @ARV else DocumentType end,            
    'Coupon Name'=(Select Value from PaymentMode Where Mode=PaymentModeID),
    'Provider Account'=(Select AccountName from AccountsMaster Where AccountID=BankID),
    'Narration'=Case When DocumentType=4 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@ARV)) 
    When DocumentType=3 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@COLLECTIONS)) 
    When DocumentType=7 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@PAYMENTS)) 
    When DocumentType=6 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@APV)) 
    When DocumentType=8 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) 
    When DocumentType=9 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) end,            
    case when documentType=4 then 28 else @SPECIALCASE2 end from            
    CollectionDetail,Collections where CollectionID=@DocRef and Collections.DocumentID=CollectionDetail.CollectionID            
   End            
  Else            
   Begin            
    select 'Document Date'=dbo.stripdatefromtime(CollectionDetail.DocumentDate),            
    'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=OriginalID,            
    'Document Reference'=dbo.sp_acc_GetFlexibleNumber(@DocRef,@DocType),      
    'Value'=DocumentValue,'Adjusted Amount'=AdjustedAmount,Null,            
    'Doc Ref'=Case when documenttype=4 then cast(CollectionDetail.DocumentID as nvarChar) else OriginalID end,            
    'Doc Type'=case when documentType=4 then @ARV else DocumentType end,            
    'Cheque Date'=dbo.stripdatefromtime(Collections.ChequeDate),            
    'Cheque Number'=Collections.ChequeNumber,          
    'Narration'=Case When DocumentType=4 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@ARV)) When DocumentType=3 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@COLLECTIONS)) When DocumentType=7 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@PAYMENTS)) When DocumentType=6 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@APV)) When DocumentType=8 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) When DocumentType=9 then (dbo.sp_acc_GetNarration(CollectionDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) end,            
    case when documentType=4 then 28 else @SPECIALCASE2 end from            
    CollectionDetail,Collections where CollectionID=@DocRef and Collections.DocumentID=CollectionDetail.CollectionID            
   End            
 End            
End            
Else If @DocType=@DEPOSITS Or @DocType=@DEPOSITS_CANCELLATION Or @DocType=@REPOFBOUNCECHEQUE            
Begin            
  select 'Document Date'=dbo.stripdatefromtime(DocumentDate), 'Document ID'=FullDocID,'Description'=dbo.getdescription(DocumentID,@COLLECTIONS),            
  'Document Reference'=dbo.sp_acc_GetFlexibleNumber(@DocRef,@DocType),'Particular'=case when CustomerID is not null then (Select Company_Name from Customer where Customer.CustomerID=Collections.CustomerID)             
  else (Case when isnull(Others,0) <>0 then dbo.getaccountname(Collections.Others) else dbo.getaccountname(Collections.ExpenseAccount) end) end,            
  'Value'=Value,Null,'DocRef'=DocumentID,'DocType'=@COLLECTIONS, 'Cheque Date'=dbo.stripdatefromtime(Collections.ChequeDate),            
  'Cheque Number'=Collections.ChequeNumber, 'Deposit date'=dbo.stripdatefromtime(Collections.DepositDate),            
  'Expense'=Case when (Collections.CustomerID is Null and isnull(Others,0) <> 0 and isnull(ExpenseAccount,0) <> 0)             
  then dbo.getaccountname(ExpenseAccount) else '' end, 20            
  from Collections where DepositID=@DocRef            
/*            
  select 'Document Date'=dbo.stripdatefromtime(CollectionDetail.DocumentDate),            
  'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=OriginalID,            
  'Value'=DocumentValue, 'Adjusted Amount'=AdjustedAmount,Null,            
  'Doc Ref'=case when documentType=4 then cast((Select InvoiceID from InvoiceAbstract where DocumentID=dbo.gettrueval(OriginalID)) as nVarChar) else OriginalID end,  'Doc Type'=Case when DocumentType=4 then @Invoice else DocumentType end,            
  'Cheque Date'=dbo.stripdatefromtime(Collections.ChequeDate),            
  'Cheque Number'=Collections.ChequeNumber,            
  'Deposit date'=dbo.stripdatefromtime(Collections.DepositDate),             
  Case when DocumentType=4 then 13 else @SPECIALCASE2 end             
  from CollectionDetail,Collections where CollectionID=@DocRef and             
  Collections.DocumentID=CollectionDetail.CollectionID             
*/            
End            
Else If @DocType=@BOUNCECHEQUE Or @DocType=@BOUNCECHEQUE_CANCEL           
Begin            
 Set @CustomerID=(Select CustomerID from Collections where DocumentID=@DocRef)            
 If @CustomerID is not null            
 Begin            
  select 'Document Date'=dbo.stripdatefromtime(CollectionDetail.DocumentDate),            
  'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=OriginalID,            
  'Document Reference'=dbo.sp_acc_GetFlexibleNumber(@DocRef,@DocType), 'Value'=DocumentValue, 'Adjusted Amount'=AdjustedAmount,            
  Null,'Doc Ref'=case when DocumentType=4 then cast(CollectionDetail.DocumentID as nVarChar)  
  when documentType=12 then cast(CollectionDetail.DocumentID as nVarchar) else OriginalID end,            
  'Doc Type'=Case when DocumentType=4 then @Invoice when documenttype=12 then @SERVICE_INVOICE else DocumentType end,             
  'Cheque Date'=dbo.stripdatefromtime(Collections.ChequeDate),            
  'Cheque Number'=Collections.ChequeNumber,'Deposit Date'=dbo.stripdatefromtime(Collections.DepositDate),            
  'Realisation Date'=dbo.stripdatefromtime(Collections.RealisationDate),'Bank Charges'=Collections.BankCharges,             
  Case when DocumentType=4 then 13 when DocumentType=12 then 98 else @SPECIALCASE2 end from CollectionDetail,Collections where             
  CollectionID=@DocRef and Collections.DocumentID=CollectionDetail.CollectionID             
 End            
 Else            
 Begin            
  select 'Document Date'=dbo.stripdatefromtime(CollectionDetail.DocumentDate),            
  'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=OriginalID,            
  'Document Reference'=dbo.sp_acc_GetFlexibleNumber(@DocRef,@DocType), 'Value'=DocumentValue, 'Adjusted Amount'=AdjustedAmount,            
  Null,'Doc Ref'=case when DocumentType=4 then cast(CollectionDetail.DocumentID as nVarChar) else OriginalID end,            
  'Doc Type'=Case when DocumentType=4 then @ARV else DocumentType end,             
  'Cheque Date'=dbo.stripdatefromtime(Collections.ChequeDate),            
  'Cheque Number'=Collections.ChequeNumber,'Deposit Date'=dbo.stripdatefromtime(Collections.DepositDate),            
  'Realisation Date'=dbo.stripdatefromtime(Collections.RealisationDate),'Bank Charges'=Collections.BankCharges,             
  Case when DocumentType=4 then 28 else @SPECIALCASE2 end from CollectionDetail,Collections where             
  CollectionID=@DocRef and Collections.DocumentID=CollectionDetail.CollectionID             
 End            
End            
            
Else If @DocType=@PAYMENTS or @DocType=@AUTOENTRY or @DocType=@PAYMENTCANCELLATION            
 OR @DocType=@MANUALJOURNALPAYMENTS OR @DocType=@MANUALJOURNALOTHERPAYMENTS            
 or @DocType=@PAYMENT_AMENDMENT            
Begin            
 Set @PaymentMode=(Select PaymentMode from Payments where DocumentID=@DocRef)            
 Set @VendorID=(Select VendorID from Payments where DocumentID=@DocRef)            
 If @VendorID is not Null            
 Begin            
  If @PaymentMode=0            
  Begin            
   select 'Document Date'=dbo.stripdatefromtime(DocumentDate),             
   'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),            
   'Document ID'=OriginalID,'Document Reference'=dbo.sp_acc_GetFlexibleNumber(@DocRef,@DocType),'Value'=DocumentValue,'Adjusted Amount'=AdjustedAmount,             
   Null,'Doc Ref'=case when DocumentType=4 then cast(PaymentDetail.DocumentID as nVarchar) else OriginalID End,            
   'Doc Type'=Case when DocumentType=4 then @Bill else DocumentType end,        
   'Narration'=Case When DocumentType=4 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@APV)) When DocumentType=9 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) When DocumentType=8 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) When DocumentType=6 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@ARV)) When DocumentType=3 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@PAYMENTS)) When DocumentType=7 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@COLLECTIONS)) end,            
   Case when DocumentType=4 then 14 else @SPECIALCASE2 end from PaymentDetail where PaymentID=@DocRef            
  End            
  Else If @PaymentMode=4
  Begin            
   select 'Document Date'=dbo.stripdatefromtime(PaymentDetail.DocumentDate),            
   'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=PaymentDetail.OriginalID,            
   'Document Reference'=dbo.sp_acc_GetFlexibleNumber(@DocRef,@DocType),'Value'=DocumentValue,'Adjusted Amount'=AdjustedAmount,Null,            
   'Doc Ref'=case when DocumentType=4 then cast(PaymentDetail.DocumentID as nVarChar) else PaymentDetail.OriginalID end,            
   'Doc Type'=Case when DocumentType=4 then @Bill else DocumentType end,
   'Account No'=Account_Number,'Bank Transaction Code'=IsNULL(Memo,N''),
   'Narration'=Case When DocumentType=4 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@APV)) 
   When DocumentType=9 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) 
   When DocumentType=8 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) 
   When DocumentType=6 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@ARV)) 
   When DocumentType=3 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@PAYMENTS)) 
   When DocumentType=7 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@COLLECTIONS)) end,            
   Case when DocumentType=4 then 14 else @SPECIALCASE2 end             
   from PaymentDetail,Payments,Bank where PaymentID=@DocRef and payments.DocumentID=PaymentDetail.PaymentID And Bank.BankID=Payments.BankID
  End           
  Else            
  Begin            
   select 'Document Date'=dbo.stripdatefromtime(PaymentDetail.DocumentDate),            
   'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=OriginalID,            
   'Document Reference'=dbo.sp_acc_GetFlexibleNumber(@DocRef,@DocType),'Value'=DocumentValue,'Adjusted Amount'=AdjustedAmount,Null,            
   'Doc Ref'=case when DocumentType=4 then cast(PaymentDetail.DocumentID as nVarChar) else OriginalID end,            
   'Doc Type'=Case when DocumentType=4 then @Bill else DocumentType end,            
   'Cheque Date'=dbo.stripdatefromtime(Payments.Cheque_Date),            
   'Cheque Number'=case when @PaymentMode=1 then dbo.GetChequeNumber(Payments.Cheque_ID,Payments.Cheque_Number)            
   else cast(Cheque_Number as varchar(30)) end,         
   'Narration'=Case When DocumentType=4 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@APV)) When DocumentType=9 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) When DocumentType=8 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) When DocumentType=6 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@ARV)) When DocumentType=3 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@PAYMENTS)) When DocumentType=7 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@COLLECTIONS)) end,            
   Case when DocumentType=4 then 14 else @SPECIALCASE2 end             
   from PaymentDetail,Payments where PaymentID=@DocRef and payments.DocumentID=PaymentDetail.PaymentID            
  End            
 End            
 Else            
 Begin            
  If @PaymentMode=0            
  Begin            
   select 'Document Date'=dbo.stripdatefromtime(DocumentDate),             
   'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),            
   'Document ID'=OriginalID,'Document Reference'=dbo.sp_acc_GetFlexibleNumber(@DocRef,@DocType),'Value'=DocumentValue,'Adjusted Amount'=AdjustedAmount,             
   Null,'Doc Ref'=case when DocumentType=4 then cast(PaymentDetail.DocumentID as nVarchar) else OriginalID End,            
   'Doc Type'=Case when DocumentType=4 then @APV else DocumentType end,          
   'Narration'=Case When DocumentType=4 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@APV)) When DocumentType=9 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) When DocumentType=8 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) When DocumentType=6 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@ARV)) When DocumentType=3 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@PAYMENTS)) When DocumentType=7 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@COLLECTIONS)) end,            
   Case when DocumentType=4 then 28 else @SPECIALCASE2 end from             
   PaymentDetail where PaymentID=@DocRef        
  End            
  Else If @PaymentMode=4            
  Begin            
   select 'Document Date'=dbo.stripdatefromtime(PaymentDetail.DocumentDate),            
   'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=PaymentDetail.OriginalID,            
   'Document Reference'=dbo.sp_acc_GetFlexibleNumber(@DocRef,@DocType),'Value'=DocumentValue,'Adjusted Amount'=AdjustedAmount,Null,            
   'Doc Ref'=case when DocumentType=4 then cast(PaymentDetail.DocumentID as nVarChar) else PaymentDetail.OriginalID end,            
   'Doc Type'=Case when DocumentType=4 then @APV else DocumentType end,
   'Account No'=Account_Number,'Bank Transaction Code'=IsNULL(Memo,N''),
   'Narration'=Case When DocumentType=4 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@APV)) 
   When DocumentType=9 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) 
   When DocumentType=8 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) 
   When DocumentType=6 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@ARV)) 
   When DocumentType=3 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@PAYMENTS)) 
   When DocumentType=7 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@COLLECTIONS)) end,            
   Case when DocumentType=4 then 28 else @SPECIALCASE2 end            
   from PaymentDetail,Payments,Bank where PaymentID=@DocRef            
   and payments.DocumentID=PaymentDetail.PaymentID And Payments.BankID=Bank.BankID
  End            
  Else            
  Begin            
   select 'Document Date'=dbo.stripdatefromtime(PaymentDetail.DocumentDate),            
   'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),'Document ID'=OriginalID,            
   'Document Reference'=dbo.sp_acc_GetFlexibleNumber(@DocRef,@DocType),'Value'=DocumentValue,'Adjusted Amount'=AdjustedAmount,Null,            
   'Doc Ref'=case when DocumentType=4 then cast(PaymentDetail.DocumentID as nVarChar) else OriginalID end,            
   'Doc Type'=Case when DocumentType=4 then @APV else DocumentType end,            
   'Cheque Date'=dbo.stripdatefromtime(Payments.Cheque_Date),            
   'Cheque Number'=case when @PaymentMode=1 then dbo.GetChequeNumber(Payments.Cheque_ID,Payments.Cheque_Number)             
   else cast(Cheque_Number as varchar(30)) end,          
   'Narration'=Case When DocumentType=4 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@APV)) When DocumentType=9 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) When DocumentType=8 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@MANUALJOURNAL_NEWREFERENCE)) When DocumentType=6 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@ARV)) When DocumentType=3 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@PAYMENTS)) When DocumentType=7 then (dbo.sp_acc_GetNarration(PaymentDetail.DocumentID,@COLLECTIONS)) end,            
   Case when DocumentType=4 then 28 else @SPECIALCASE2 end            
   from PaymentDetail,Payments where PaymentID=@DocRef            
   and payments.DocumentID=PaymentDetail.PaymentID            
  End            
 End            
End            
Else if @DocType=@CLAIMSTOVENDOR OR @DocType=@CLAIMSSETTLEMENT OR @DocType=@CLAIMSCANCELLATION or @DocType=@MANUALJOURNAL_CLAIMS            
Begin            
 Execute sp_acc_rpt_ClaimsDetail @DocRef            
End            
Else if @DocType=@MANUALJOURNALOLDREF            
Begin            
 Select 'Document Date'=dbo.stripdatefromtime(TransactionDate),            
 'Document ID'=dbo.GetOriginalID(DocumentReference,DocumentType),            
 'Description'=dbo.GetDescription(DocumentReference,DocumentType),'Document Reference'=dbo.sp_acc_GetFlexibleNumber(DocumentReference,DocumentType),'','Debit'=Debit,'Credit'=Credit,            
 'DocRef'=Documentreference,            
 'DocType'=DocumentType,'AccountID'=GeneralJournal.AccountID,'Narration'=Remarks,'High Light'=dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference)             
 from GeneralJournal,AccountsMaster where             
 GeneralJournal.AccountID=AccountsMaster.AccountID and             
 TransactionID=@DocRef and DocumentType not in (36,37) --36 is diplay entry in manual journal form            
End            
Else IF @DocType=@ARV OR @DocType=@ARVCANCELLATION OR @DocType=@MANUALJOURNALARV Or @Doctype=@ARV_AMENDMENT            
Begin            
 select 'Type'=Case when Type=0 then dbo.LookupDictionaryItem('Asset',Default) else (Case when Type=1 then dbo.LookupDictionaryItem('Others',Default) else (Case When Type=3 then dbo.LookupDictionaryItem('Credit Card',Default) else dbo.LookupDictionaryItem('Coupon',Default) end) end ) end,'Account Name'=dbo.getaccountName(AccountID),'Amount'=Amount,            
-- Particular,AccountID,Type,'Doc Ref'=@DocRef,'Doc Type'=@ARVDETAIL,'Info'=cast(Type as varchar) + char(3) + Particular,            
 'Document Reference'=dbo.sp_acc_GetFlexibleNumber(@DocRef,@DocType),Particular,AccountID,'Doc Ref'=@DocRef,Type,'Doc Type'=@ARVDETAIL,Particular,            
 'High Light'=Case when Type=0 then 26 else (Case when Type=1 then 27 else (Case When Type=3 then 48 else 49 end) end ) end from ARVDetail where DocumentID=@DocRef            
End            
Else IF @DocType=@APV OR @DocType=@APVCANCELLATION OR @DocType=@MANUALJOURNALAPV Or @DocType=@APV_AMENDMENT          
Begin            
 select 'Type'=Case when Type=0 then dbo.LookupDictionaryItem('Items',Default) else (case when Type=1 then dbo.LookupDictionaryItem('others',Default) else dbo.LookupDictionaryItem('Asset',Default) end) end,'Account Name'=dbo.getaccountName(AccountID),'Amount'=Amount,            
-- Particular,AccountID,Type,'Doc Ref'=@DocRef,'Doc Type'=@ARVDETAIL,Cast(Type as Varchar) + char(3) + Particular,            
 'Document Reference'=dbo.sp_acc_GetFlexibleNumber(@DocRef,@DocType),Particular,AccountID,'Doc Ref'=@DocRef,Type,'Doc Type'=@APVDETAIL,Particular,            
 'High Light'=Case when Type=0 then 25 else (case when Type=1 then 26 else 27 end) end from APVDetail where DocumentID=@DocRef            
End            
Else IF @DocType=@ARVDETAIL            
Begin            
 Execute sp_acc_rpt_arvsubdetail @DocRef,@Info --here @DocRef contains Type             
End            
Else IF @DocType=@APVDETAIL            
Begin            
 Execute sp_acc_rpt_apvsubdetail @DocRef,@Info            
End            
Else if @DocType=@STOCKTRANSFERIN  or @DocType= @STOCKTRANSFERINAMENDMENT or @DocType= @STOCKTRANSFERINCANCELLATION     
Begin            
 Execute sp_acc_rpt_stocktransferindetail @DocRef            
End     
Else if @DocType=@STOCKTRANSFEROUT or @DocType=@STOCKTRANSFEROUTAMENDMENT   or @DocType=@STOCKTRANSFEROUTCELLATION       
Begin            
 Execute sp_acc_rpt_stocktransferoutdetail @DocRef            
End            
Else if @DocType=@DISPATCH OR @DocType=@DISPATCHAMENDMENT OR @DocType=@DISPATCHCANCELLATION            
 --OR @DocType=@MANUALJOURNALBILL            
Begin            
 Execute sp_acc_rpt_dispatchdetail @DocRef            
End            
Else if @DocType=@GRN OR @DocType=@GRNAMENDMENT OR @DocType=@GRNCANCELLATION            
Begin            
 Execute sp_acc_rpt_grnitems @DocRef            
End            
Else if @DocType=@INTERNALCONTRA OR @DocType=@INTERNALCONTRACANCELLATION            
Begin            
 select 'From Account'=dbo.getaccountname(max(FromAccountID)),            
 'To Account'=dbo.getaccountname(ToAccountID),'Amount Transfer'=Max(AmountTransfer),            
 0,0,0,@DocRef,@INTERNALCONTRADETAIL,'FromAccountID'=Max(FromAccountID),'ToAccountID'=Max(ToAccountID),            
 dbo.GetSetting(Max(PaymentType))            
 from ContraAbstract,ContraDetail      
 where ContraAbstract.ContraID=@DocRef and            
 ContraAbstract.ContraID=ContraDetail.ContraID            
 Group by FromAccountID,ToAccountID,PaymentType            
End          
Else if @DocType=@INTERNALCONTRADETAIL            
Begin             
 select @PaymentType=PaymentType from ContraDetail where ContraID=@DocRef            
 and FromAccountID=@Info             
 If @PaymentType=2            
 Begin            
  select 'InvoiceID'=OriginalID,'Invoice Date'=dbo.getinvoicedate(isnull(DocumentReference,0)),            
  'Amount'=AdditionalInfo_Amount,'Document Reference'=dbo.sp_acc_GetFlexibleNumber(DocumentReference,@RETAILINVOICE),'Cheque Number'=AdditionalInfo_Number,'Cheque Date'=AdditionalInfo_Date,            
  'Bank'=dbo.getbank(isnull(AdditionalInfo_BankCode,0)),'DocumentReference'=isnull(DocumentReference,0),            
  @RETAILINVOICE, 'Branch'=dbo.getbranch(isnull(AdditionalInfo_BranchCode,0)),            
  'DocumentType'=isnull(DocumentType,0),13            
  from ContraDetail Where ContraID=@DocRef and FromAccountID=@Info            
  and PaymentType=@PaymentType              
 End            
 Else If @PaymentType=3            
 Begin            
  select 'InvoiceID'=OriginalID,'Invoice Date'=dbo.getinvoicedate(isnull(DocumentReference,0)),            
  'Amount'=AdditionalInfo_Amount,'Document Reference'=dbo.sp_acc_GetFlexibleNumber(DocumentReference,@RETAILINVOICE),'Card No'=AdditionalInfo_Number,            
  'Card Type'=isnull(AdditionalInfo_Type,0),'Party'=dbo.getaccountname(isnull(AdditionalInfo_Party,0)),            
  'DocumentReference'=isnull(DocumentReference,0),@RETAILINVOICE,'DocumentType'=isnull(DocumentType,0),13            
  from ContraDetail Where ContraID=@DocRef and FromAccountID=@Info            
  and PaymentType=@PaymentType              
 End            
 Else If @PaymentType=4            
 Begin            
  Select 'Coupon Name'=AdditionalInfo_Number,'From SerialNo'=isnull(AdditionalInfo_FromSerialNo,0),            
  'To SerialNo'=isnull(AdditionalInfo_ToSerialNo,0),'Qty'=isnull(AdditionalInfo_Qty,0),            
  'Value'=isnull(AdditionalInfo_Value,0),'Amount'=AdditionalInfo_Amount,            
  'Party'=dbo.getaccountname(isnull(AdditionalInfo_Party,0)),5            
  from ContraDetail Where ContraID=@DocRef and FromAccountID=@Info            
  and PaymentType=@PaymentType              
 End            
 Else If @PaymentType=5            
 Begin            
  Select 'Remarks'=Denominations,'Amount'=AdditionalInfo_Amount,5            
  from ContraDetail Where ContraID=@DocRef and FromAccountID=@Info            
  and PaymentType=@PaymentType              
 End            
End            
Else if @DocType=@INTERNALCONTRADETAIL            
Begin            
 select 'Document Date'=dbo.stripdatefromtime(DocumentDate),             
 'Adjustment Dated'=dbo.stripdatefromtime(Paymentdate),            
 'Document ID'=OriginalID,'Value'=DocumentValue,'Adjusted Amount'=AdjustedAmount,             
 Null,'Doc Ref'=case when DocumentType=4 then cast(PaymentDetail.DocumentID as nVarchar) else OriginalID End,            
 'Doc Type'=Case when DocumentType=4 then @Bill else DocumentType end,Case when DocumentType=4 then 14 else @SPECIALCASE2 end from PaymentDetail where PaymentID=@DocRef            
End     
Else If @DocType=@ISSUE_SPARES or @DocType=@ISSUE_SPARES_CANCEL or @DocType=@ISSUE_SPARES_RETURN
 Begin    
  Execute sp_acc_rpt_ser_IssueDetail @DocRef,@DocType
 End    
Else If @DocType=@SERVICE_INVOICE or @DocType=@SERVICE_INVOICE_CANCEL    
 Begin    
  Declare @ParamSep nVarChar(10)    
  Declare @TableSQL nVarChar(4000)    
  Declare @ItemSpec nVarChar(50)    
    
  Set @ParamSep = Char(2)    
  Select @ItemSpec=ServiceCaption from ServiceSetting Where ServiceCode=dbo.LookupDictionaryItem('Itemspec1',Default)    
  ------------------------------Create a Dynamic Table-----------------------------------------    
  CREATE table #TempServiceInvoiceDetail([Item Code] nVarChar(50),[Item Name] nVarChar(255))         
  Set @TableSQL=N'Alter table #TempServiceInvoiceDetail Add [' + @ItemSpec + N'] nVarChar(50) NULL,    
  [Color] nVarChar(50) NULL,[Type] nVarChar(50) NULL,[Amount] Decimal(18,6) NULL,    
  [Net Value] Decimal(18,6) NULL,[DocRef] INT,[DocType] INT,[Info] nVarChar(4000),HighLight INT'    
  Exec sp_executesql @TableSQL          
  ---------------------------------------------------------------------------------------------    
  Insert into #TempServiceInvoiceDetail        
  Select [Item Code],[Item Name],Spec,Color,Type,Sum(Amount) as [Amount],    
  Sum(NetValue) as [Net Value],DocRef,DocType,Info,Highlight From     
  (Select 'Item Code'=SID.Product_Code,'Item Name'=Items.ProductName,    
  SID.Product_Specification1 Spec,'Color'=(Select GM.[Description] From 
  GeneralMaster GM,ServiceInvoiceDetail SID,ItemInformation_Transactions IIT
  Where IIT.Color=GM.Code And IIT.DocumentID=SID.SerialNo And IIT.DocumentType=3
  And SID.ServiceInvoiceID=@DocRef And SID.Type=0),'Type'=Case When SID.Type=2     
  And IsNULL(SpareCode,N'')=N'' Then 'Task' When IsNULL(SpareCode,N'')<>N'' Then dbo.LookupDictionaryItem('Spare',Default) End,    
  'Amount'=Sum(IsNULL(Amount,0)),'NetValue'=Sum(IsNULL(NetValue,0)),SID.ServiceInvoiceID DocRef,    
  'DocType'=@SERVICE_INVOICE_SUBDETAIL,'Info'=Cast(SID.Product_code As nVarChar(50)) + @ParamSep +     
  SID.Product_Specification1 + @ParamSep + Cast((Case When SID.Type=2 And IsNULL(SpareCode,N'')=N''     
  Then 2 When IsNULL(SpareCode,N'')<>N'' Then 3 End) As nVarChar(15)),'HighLight'=(Case     
  When SID.Type=2 And IsNULL(SpareCode,N'')=N'' Then 96 When IsNULL(SpareCode,N'')<>N'' Then 97 End)    
  from ServiceInvoiceDetail SID,Items Where SID.Type In (2,3) 
  And SID.Product_code=Items.Product_Code And SID.ServiceInvoiceID=@DocRef    
  Group By SID.ServiceInvoiceID,SID.Product_Code,SID.Product_Specification1,    
  SID.Type,SID.SpareCode,Items.ProductName) S    
  Group by [Item Code],[Item Name],Spec,Type,Color,DocRef,DocType,HighLight,Info    
    
  Select * from #TempServiceInvoiceDetail    
  Drop Table #TempServiceInvoiceDetail    
 End    
Else If @DocType=@SERVICE_INVOICE_SUBDETAIL    
 Begin    
  Execute sp_acc_rpt_ser_ServiceInvoiceSubDetail @DocRef,@Info            
 End

