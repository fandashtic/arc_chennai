CREATE Function GetLedgerDynamicSetting(@DocType INT,@DocRef INT =0)        
Returns  int        
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
Declare @ARV_AMENDMENT INT        
Declare @APV_AMENDMENT INT        
        
Declare @MANUALJOURNALINVOICE INT        
Declare @MANUALJOURNALSALESRETURN INT        
Declare @MANUALJOURNALBILL INT        
Declare @MANUALJOURNALPURCHASERETURN INT        
Declare @MANUALJOURNALCOLLECTIONS INT        
Declare @MANUALJOURNALPAYMENTS INT        
Declare @MANUALJOURNALDEBITNOTE INT        
Declare @MANUALJOURNALCREDITNOTE INT        
Declare @MANUALJOURNALOLDREF INT        
Declare @CONTRAENTRYCANCELLATION INT        
        
Declare @MANUALJOURNALAPV INT        
Declare @MANUALJOURNALARV INT        
Declare @MANUALJOURNALOTHERPAYMENTS INT        
Declare @MANUALJOURNALOTHERRECEIPTS INT        
        
Declare @ARV INT        
Declare @ARVCANCELLATION INT        
Declare @APV INT        
Declare @APVCANCELLATION INT        
        
Declare @DISPATCH INT        
Declare @DISPATCHAMENDMENT INT        
Declare @DISPATCHCANCELLATION INT        
        
Declare @GRN INT        
Declare @GRNAMENDMENT INT        
Declare @GRNCANCELLATION INT        
        
Declare @INTERNALCONTRA INT        
Declare @INTERNALCONTRACANCELLATION INT        
Declare @COLLECTIONAMENDMENT INT        
Declare @PAYMENT_AMENDMENT INT        
        
Declare @MANUALJOURNALOTHERDEBITNOTE INT        
Declare @MANUALJOURNALOTHERCREDITNOTE INT        
Declare @MANUALJOURNAL_NEWREFERENCE INT        
Declare @MANUALJOURNAL_CLAIMS INT        
Declare @PURCHASERETURN_AMENDMENT INT        
      
Declare @CREDITNOTE_AMENDMENT INT       
Declare @DEBITNOTE_AMENDMENT INT       
Declare @STOCKTRANSFERIN INT    
Declare @STOCKTRANSFERINAMENDMENT int        
Declare @STOCKTRANSFERINCANCELLATION int        
    
Declare @STOCKTRANSFEROUT INT    
Declare @STOCKTRANSFEROUTAMENDMENT int        
Declare @STOCKTRANSFEROUTCANCELLATION int        
    
Declare @ISSUE_SPARES INT            
Declare @ISSUE_SPARES_CANCEL INT            
Declare @ISSUE_SPARES_RETURN INT            
Declare @SERVICE_INVOICE INT            
Declare @SERVICE_INVOICE_CANCEL INT            
    
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
        
set @MANUALJOURNALINVOICE =28        
Set @MANUALJOURNALSALESRETURN =29        
Set @MANUALJOURNALBILL =30        
Set @MANUALJOURNALPURCHASERETURN =31        
Set @MANUALJOURNALCOLLECTIONS =32        
Set @MANUALJOURNALPAYMENTS =33        
Set @MANUALJOURNALDEBITNOTE =34        
Set @MANUALJOURNALCREDITNOTE =35        
SET @MANUALJOURNALOLDREF =37        
SET @CONTRAENTRYCANCELLATION=38        
        
Set @APV =46        
Set @APVCANCELLATION =47        
Set @ARV = 48        
Set @ARVCANCELLATION =48        
        
Set @MANUALJOURNALAPV = 60        
Set @MANUALJOURNALARV = 61        
Set @MANUALJOURNALOTHERPAYMENTS =62        
Set @MANUALJOURNALOTHERRECEIPTS =63        
        
Set @DISPATCH = 44        
Set @DISPATCHAMENDMENT = 71        
Set @DISPATCHCANCELLATION =45        
        
Set @GRN = 41        
Set @GRNAMENDMENT = 66       
Set @GRNCANCELLATION = 42        
        
Set @INTERNALCONTRA = 74        
Set @INTERNALCONTRACANCELLATION = 75        
Set @COLLECTIONAMENDMENT=77        
Set @PAYMENT_AMENDMENT = 78        
        
Set @MANUALJOURNALOTHERDEBITNOTE = 79        
Set @MANUALJOURNALOTHERCREDITNOTE = 80        
Set @MANUALJOURNAL_NEWREFERENCE = 81        
Set @MANUALJOURNAL_CLAIMS = 82        
Set @PURCHASERETURN_AMENDMENT = 73        
Set @ARV_AMENDMENT = 83        
Set @APV_AMENDMENT = 84      
Set @ISSUE_SPARES = 85            
Set @ISSUE_SPARES_CANCEL = 86            
Set @ISSUE_SPARES_RETURN = 87            
Set @SERVICE_INVOICE = 88            
Set @SERVICE_INVOICE_CANCEL = 89            
Set @CREDITNOTE_AMENDMENT = 90      
set @DEBITNOTE_AMENDMENT = 91      
Set @DEPOSITS_CANCELLATION = 92      
Set @BOUNCECHEQUE_CANCELLATION = 93    
Set @STOCKTRANSFERIN = 54    
Set @STOCKTRANSFERINAMENDMENT = 69    
Set @STOCKTRANSFERINCANCELLATION = 67    
    
Set @STOCKTRANSFEROUT = 55    
Set @STOCKTRANSFEROUTAMENDMENT = 70    
Set @STOCKTRANSFEROUTCANCELLATION = 68        
    
Declare @Description Int, @PaymentMode Int,@CustomerID nVarchar(50),@VendorID nVarchar(50)        
Declare @TransactionType Int, @CHEQUEDEPOSIT Int        
Set @CHEQUEDEPOSIT=5        
        
Declare @Version Int        
Set @Version=dbo.sp_acc_getversion()        
        
--Return @RETAILINVOICECANCELLATION        
If @DocType=@RETAILINVOICE or @DocType=@RETAILINVOICEAMENDMENT or @DocType=@RETAILINVOICECANCELLATION        
or @DocType=@Invoice or @DocType=@INVOICEAMENDMENT or @DocType=@INVOICECANCELLATION or @DocType=@SALESRETURN        
Begin        
 If @Version=5 or @Version=8 or @Version= 18 or @Version=19 or @Version=11 --Multiple UOM versions        
 Begin        
  Set @DESCRIPTION = 53        
 End        
 Else If @Version=9 or @Version=10 --Serial Version    
 Begin        
  Set @DESCRIPTION = 69    
 End        
 Else        
 Begin        
  Set @DESCRIPTION = 13        
 End        
End        
        
Else If @DocType=@BILL or @DocType=@BILLAMENDMENT or @DocType=@BILLCANCELLATION        
Begin        
 If @Version = 5 or @Version = 8  or @Version= 18 or @Version=19 or @Version=11
 Begin        
  Set @DESCRIPTION = 56        
 End        
 If @Version = 9 or @Version = 10    
 Begin        
  Set @DESCRIPTION = 70    
 End        
 Else        
 Begin        
  Set @DESCRIPTION = 14        
 End        
End        
Else if @DocType=@PURCHASERETURN or @DocType=@PURCHASERETURNCANCELLATION or @DocType = @PURCHASERETURN_AMENDMENT        
Begin        
 If @Version = 5 or @Version = 8  or @Version= 18 or @Version=19 or @Version=11
 Begin        
  Set @DESCRIPTION = 58        
 End        
 Else        
 Begin        
  Set @DESCRIPTION = 15        
 End        
End        
Else if @DocType=@COLLECTIONS or @DocType=@COLLECTIONCANCELLATION or @DocType=@COLLECTIONAMENDMENT        
Begin        
 Set @PaymentMode=(Select PaymentMode from Collections where DocumentID=@DocRef)        
 Set @CustomerID=(Select CustomerID from Collections where DocumentID=@DocRef)        
 If @PaymentMode=0        
 begin        
          
  /*if @CustomerID is null        
  Begin        
   Set @DESCRIPTION = 5        
  End        
  Else        
  Begin        
   Set @DESCRIPTION = 12        
  End        
  */        
  Set @DESCRIPTION = 12        
 end        
 Else        
 Begin        
        
  /*if @CustomerID is null      
  Begin        
   Set @DESCRIPTION = 5        
  End        
  Else        
  Begin        
   Set @DESCRIPTION = 20        
  End        
  */        
  Set @DESCRIPTION = 20        
 End        
End        
Else if  @DocType=@PAYMENTS or @DocType=@PAYMENTCANCELLATION or @DocType=@AUTOENTRY         
or @DocType = @PAYMENT_AMENDMENT        
Begin        
 Set @PaymentMode=(Select PaymentMode from Payments where DocumentID=@DocRef)        
 Set @VendorID=(Select VendorID from Payments where DocumentID=@DocRef)        
 If @PaymentMode=0        
 begin        
          
  /*if @VendorID is null        
  Begin        
   Set @DESCRIPTION = 5        
  End        
  Else        
  Begin        
   Set @DESCRIPTION = 12        
  End        
  */        
  Set @DESCRIPTION = 12        
 end        
 Else        
 Begin        
          
  /*if @VendorID is null        
  Begin        
   Set @DESCRIPTION = 5        
  End        
  Else        
  Begin        
   Set @DESCRIPTION = 20        
  End        
  */        
  Set @DESCRIPTION = 20        
 End        
End        
Else if @DocType=@DEPOSITS or @DocType=@REPOFBOUNCECHEQUE or @DocType=@CONTRAENTRYCANCELLATION Or @DocType=@DEPOSITS_CANCELLATION      
Begin        
 Select @TransactionType=TransactionType from Deposits where DepositID=@DocRef        
 If @TransactionType<>@CHEQUEDEPOSIT        
 Begin        
  Set @DESCRIPTION=5        
 End        
 Else        
 Begin        
  Set @DESCRIPTION=21        
 End        
        
-- Set @DESCRIPTION=24        
End        
Else If @DocType=@BOUNCECHEQUE Or @DocType=@BOUNCECHEQUE_CANCELLATION     
Begin      
 Set @DESCRIPTION=22        
End        
Else if @DocType=@DEBITNOTE or @DocType=@CREDITNOTE   or @DocType = @CREDITNOTE_AMENDMENT or @DocType = @DEBITNOTE_AMENDMENT      
Begin      
 Set @DESCRIPTION = 5        
End        
Else if @DocType=@CLAIMSTOVENDOR or @DocType=@CLAIMSSETTLEMENT or @DocType=@CLAIMSCANCELLATION or @DocType = @MANUALJOURNAL_CLAIMS        
Begin        
 If @Version = 9 or @Version = 10    
 Begin    
  Set @DESCRIPTION = 78    
 End    
 Else    
 Begin    
  Set @DESCRIPTION = 16        
 End    
End        
Else if @DocType=@MANUALJOURNAL        
Begin        
 Set @DESCRIPTION = 5        
End        
Else If @DocType=@MANUALJOURNALINVOICE or @DocType=@MANUALJOURNALSALESRETURN        
Begin        
 Set @DESCRIPTION = 13        
End        
        
Else If @DocType=@MANUALJOURNALBILL        
Begin        
 Set @DESCRIPTION = 14        
End        
Else if @DocType=@MANUALJOURNALPURCHASERETURN        
Begin        
 Set @DESCRIPTION = 15        
End        
Else if @DocType=@MANUALJOURNALCOLLECTIONS or  @DocType=@MANUALJOURNALOTHERRECEIPTS        
Begin        
 Set @PaymentMode=(Select PaymentMode from Collections where DocumentID=@DocRef)        
 Set @CustomerID=(Select CustomerID from Collections where DocumentID=@DocRef)        
 If @PaymentMode=0        
 begin        
          
  /*if @CustomerID is null        
  Begin        
   Set @DESCRIPTION = 5        
  End        
  Else        
  Begin        
   Set @DESCRIPTION = 12        
  End        
  */        
  Set @DESCRIPTION = 12        
 end        
 Else        
 Begin        
        
  /*if @CustomerID is null        
  Begin        
   Set @DESCRIPTION = 5        
  End        
  Else        
  Begin        
   Set @DESCRIPTION = 20        
  End        
  */        
  Set @DESCRIPTION = 20        
 End        
End        
Else if  @DocType=@MANUALJOURNALPAYMENTS or @DocType=@MANUALJOURNALOTHERPAYMENTS         
Begin        
 Set @PaymentMode=(Select PaymentMode from Payments where DocumentID=@DocRef)        
 Set @VendorID=(Select VendorID from Payments where DocumentID=@DocRef)        
 If @PaymentMode=0        
 begin        
          
  /*if @VendorID is null        
  Begin        
   Set @DESCRIPTION = 5        
  End        
  Else        
  Begin        
   Set @DESCRIPTION = 12        
  End        
  */        
  Set @DESCRIPTION = 12        
 end        
 Else        
 Begin        
          
  /*if @VendorID is null        
  Begin        
   Set @DESCRIPTION = 5        
  End        
  Else        
  Begin        
   Set @DESCRIPTION = 20        
  End        
  */        
  Set @DESCRIPTION = 20        
 End        
End        
Else if @DocType=@MANUALJOURNALDEBITNOTE or @DocType=@MANUALJOURNALCREDITNOTE        
Begin        
 Set @DESCRIPTION = 5        
End        
        
Else if @DocType=@MANUALJOURNALOLDREF        
Begin        
 Set @DESCRIPTION = 24        
End        
Else if @DocType=@ARV or @DocType=@ARVCANCELLATION or @DocType=@APV or @DocType=@APVCANCELLATION        
or @DocType= @MANUALJOURNALAPV or @DocType= @MANUALJOURNALARV Or @DocType = @ARV_AMENDMENT Or @DocType = @APV_AMENDMENT        
Begin        
 Set @DESCRIPTION = 28        
End        
Else If @DocType=@DISPATCH or @DocType=@DISPATCHAMENDMENT or @DocType=@DISPATCHCANCELLATION        
Begin        
 If @Version=5 or @Version=8  or @Version= 18 or @Version=19 or @Version=11 --Multiple UOM versions        
 Begin        
  Set @DESCRIPTION = 55        
 End        
 Else If @Version=9 or @Version= 10 --Serial Versions    
 Begin        
  Set @DESCRIPTION = 75    
 End        
 Else        
 Begin        
  Set @DESCRIPTION = 38        
 End        
End        
Else If @DocType=@GRN or @DocType=@GRNAMENDMENT or @DocType=@GRNCANCELLATION        
Begin        
 If @Version = 5  or @Version= 18 or @Version=11
 Begin        
  Set @DESCRIPTION = 62        
 End        
 Else If @Version = 8  or @Version=19
 Begin        
  Set @DESCRIPTION = 61        
 End        
 Else If @Version = 1 or @Version = 4 or @Version = 7
 Begin        
  Set @DESCRIPTION = 60        
 End        
 Else If @Version = 9    
 Begin        
  Set @DESCRIPTION = 76    
 End        
 Else If @Version = 10    
 Begin        
  Set @DESCRIPTION = 77    
 End        
 Else       
 Begin        
  Set @DESCRIPTION = 39        
 End        
End        
Else If @DocType=@INTERNALCONTRA or @DocType=@INTERNALCONTRACANCELLATION        
Begin        
 Set @DESCRIPTION = 40        
End        
Else If @DocType=@MANUALJOURNALOTHERDEBITNOTE or @DocType=@MANUALJOURNALOTHERCREDITNOTE        
Begin        
 Set @DESCRIPTION = 5        
End        
Else If @DocType=@MANUALJOURNAL_NEWREFERENCE        
Begin        
 Set @DESCRIPTION = 5        
End        
Else If @DocType= @STOCKTRANSFERIN or @DocType=  @STOCKTRANSFERINAMENDMENT or @DocType=  @STOCKTRANSFERINCANCELLATION     
Begin        
 If @Version = 5 or @Version = 8  or @Version= 18 or @Version=19  or @Version = 11 -- UOM Version    
 Begin    
  Set @DESCRIPTION = 89    
 End    
  Else If @Version=9 or @Version=10 --Serial Version    
  Begin        
   Set @DESCRIPTION = 72    
 End    
 Else    
 Begin    
   Set @DESCRIPTION = 71    
 End    
End        
Else If @DocType= @STOCKTRANSFEROUT or @DocType= @STOCKTRANSFEROUTAMENDMENT or @DocType= @STOCKTRANSFEROUTCANCELLATION    
Begin        
 If @Version = 5 or @Version = 8 or @Version= 18 or @Version=19  or @Version = 11 -- UOM Version    
 Begin    
  Set @DESCRIPTION = 91    
 End    
  Else If @Version=9 or @Version=10 --Serial Version    
  Begin        
   Set @DESCRIPTION = 74    
 End    
 Else    
 Begin    
   Set @DESCRIPTION = 73    
 End    
End        
Else If @DocType= @ISSUE_SPARES or @DocType= @ISSUE_SPARES_CANCEL or @DocType= @ISSUE_SPARES_RETURN    
 Begin    
   Set @DESCRIPTION = 94    
 End    
Else If @DocType= @SERVICE_INVOICE or @DocType= @SERVICE_INVOICE_CANCEL    
 Begin    
   Set @DESCRIPTION = 98    
 End    
Else        
Begin        
 Set @DESCRIPTION = 5        
End        
return @DESCRIPTION        
End

