CREATE Function IsClosedDocument(@DocRef Int,@DocType INT)          
Returns  int          
As          
Begin          
-- All Variable Declarations And Their Values        
Declare @DISPATCH int          
Declare @DISPATCHCANCELLATION int          
Declare @DISPATCHAMENDMENT int          
Declare @RETAILINVOICE INT          
Declare @RETAILINVOICEAMENDMENT INT          
Declare @RETAILINVOICECANCELLATION INT          
Declare @INVOICE INT          
Declare @INVOICEAMENDMENT INT          
Declare @INVOICECANCELLATION INT          
Declare @SALESRETURN INT          
Declare @SALESRETURNCANCELLATION int          
Declare @SALESRETURNAMENDMENT INT          
Declare @GRN int          
Declare @GRNCANCELLATION int          
Declare @GRNAMENDMENT int        
Declare @BILL INT          
Declare @BILLAMENDMENT INT          
Declare @BILLCANCELLATION INT          
Declare @PURCHASERETURN INT          
Declare @PURCHASERETURNCANCELLATION INT          
Declare @PURCHASERETURNAMENDMENT int          
Declare @COLLECTIONS INT          
Declare @COLLECTIONCANCELLATION INT          
Declare @COLLECTIONAMENDMENT INT          
Declare @PAYMENTS INT          
Declare @PAYMENTCANCELLATION INT          
Declare @PAYMENTAMENDMENT INT          
Declare @PAYMENTAUTOENTRY INT  
Declare @STOCKTRANSFERIN int          
Declare @STOCKTRANSFERINCANCELLATION int          
Declare @STOCKTRANSFERINAMENDMENT int          
Declare @STOCKTRANSFEROUT int          
Declare @STOCKTRANSFEROUTCANCELLATION int          
Declare @STOCKTRANSFEROUTAMENDMENT int          
Declare @CLAIMSCANCELLATION INT          
Declare @CLAIMS INT        
Declare @CONTRAENTRYCANCELLATION int          
Declare @CONTRAENTRY INT          
Declare @APVCANCELLATION int          
Declare @APV INT        
Declare @ARVCANCELLATION int          
Declare @ARV INT        
Declare @PETTYCASHCANCELLATION int          
Declare @PETTYCASH INT        
Declare @DEBITNOTE INT        
Declare @DEBITNOTECANCELLATION INT          
Declare @CREDITNOTE INT        
Declare @CREDITNOTECANCELLATION INT          
Declare @INTERNALCONTRACANCELLATION int          
Declare @INTERNALCONTRA INT        
Declare @ARV_AMENDMENT Int        
Declare @APV_AMENDMENT Int        
Declare @CREDITNOTE_AMENDMENT Int    
Declare @DEBITNOTE_AMENDMENT Int    
Declare @ISSUE_SPARES INT        
Declare @ISSUE_SPARES_CANCEL INT        
Declare @ISSUE_SPARES_RETURN INT        
Declare @SERVICE_INVOICE INT        
Declare @SERVICE_INVOICE_CANCEL INT        
Declare @DEPOSITS INT  
Declare @DEPOSITS_CANCELLATION INT  
Declare @BOUNCECHEQUE INT
Declare @BOUNCECHEQUE_CANCEL INT
--        
Set @DISPATCH = 44          
Set @DISPATCHCANCELLATION = 45          
Set @DISPATCHAMENDMENT = 71          
Set @RETAILINVOICE = 1          
Set @RETAILINVOICEAMENDMENT = 2          
Set @RETAILINVOICECANCELLATION =3          
Set @INVOICE =4          
Set @INVOICEAMENDMENT = 5          
Set @INVOICECANCELLATION = 6          
Set @SALESRETURN = 7          
Set @SALESRETURNCANCELLATION = 40          
Set @SALESRETURNAMENDMENT =72          
Set @GRN =41          
Set @GRNCANCELLATION =42          
Set @GRNAMENDMENT = 66          
Set @BILL = 8          
Set @BILLAMENDMENT = 9          
Set @BILLCANCELLATION = 10          
Set @PURCHASERETURN = 11          
Set @PURCHASERETURNCANCELLATION = 12          
Set @PURCHASERETURNAMENDMENT =73          
Set @COLLECTIONS = 13          
Set @COLLECTIONCANCELLATION = 25          
Set @COLLECTIONAMENDMENT=77          
Set @PAYMENTS = 17          
Set @PAYMENTCANCELLATION = 18          
Set @PAYMENTAUTOENTRY = 19  
Set @PAYMENTAMENDMENT =  78          
Set @STOCKTRANSFERIN = 54          
Set @STOCKTRANSFERINCANCELLATION =67          
Set @STOCKTRANSFERINAMENDMENT =69          
Set @STOCKTRANSFEROUT = 55          
Set @STOCKTRANSFEROUTCANCELLATION =68          
Set @STOCKTRANSFEROUTAMENDMENT =70          
Set @CLAIMSCANCELLATION = 24          
Set @CLAIMS = 22         
Set @CONTRAENTRYCANCELLATION=38          
Set @CONTRAENTRY = 14        
set @APVCANCELLATION = 47          
Set @APV = 46        
Set @ARVCANCELLATION = 49          
Set @ARV = 48        
Set @PETTYCASHCANCELLATION =53        
Set @PETTYCASH = 52        
Set @DEBITNOTECANCELLATION = 64          
Set @DEBITNOTE = 20        
Set @CREDITNOTECANCELLATION = 65          
Set @CREDITNOTE = 21        
Set @INTERNALCONTRACANCELLATION = 75          
Set @INTERNALCONTRA = 74        
Set @ARV_AMENDMENT = 83        
Set @APV_AMENDMENT = 84          
Set @ISSUE_SPARES = 85        
Set @ISSUE_SPARES_CANCEL = 86        
Set @ISSUE_SPARES_RETURN = 87        
Set @SERVICE_INVOICE = 88        
Set @SERVICE_INVOICE_CANCEL = 89        
Set @CREDITNOTE_AMENDMENT = 90    
Set @DEBITNOTE_AMENDMENT = 91    
Set @DEPOSITS_CANCELLATION = 92  
Set @DEPOSITS = 14  
Set @BOUNCECHEQUE_CANCEL = 93
Set @BOUNCECHEQUE = 15
    
Declare @Status INT        
Declare @DocumentStatus INT          
Set @DocumentStatus = 1 -- Default Value to Avoid Null Values        
        
If @DocType=@DISPATCH Or @DocType=@DISPATCHCANCELLATION Or @DocType=@DISPATCHAMENDMENT        
 Begin          
  Select @Status=status from DispatchAbstract where DispatchID=@DocRef          
  If (((isnull(@Status,0) & 64) <> 0) Or (isnull(@Status,0) & 128) <> 0)        
   Begin          
    Set @DocumentStatus = 0        
   End          
 End          
Else If @DocType=@RETAILINVOICE Or @DocType=@RETAILINVOICEAMENDMENT Or @DocType=@RETAILINVOICECANCELLATION Or @DocType=@INVOICE Or @DocType=@INVOICEAMENDMENT Or @DocType=@INVOICECANCELLATION Or @DocType=@SALESRETURNCANCELLATION Or @DocType=@SALESRETURN Or @DocType=@SALESRETURNAMENDMENT        
 Begin        
  Select @Status=status from InvoiceAbstract where InvoiceID=@DocRef          
  If (((isnull(@Status,0) & 128) <> 0) Or (IsNull(@Status,0) & 64) <> 0)          
   Begin          
    Set @DocumentStatus = 0        
   End          
 End          
Else if @DocType=@GRN Or @DocType=@GRNCANCELLATION Or @DocType=@GRNAMENDMENT        
 Begin          
  Select @Status=GRNStatus from GRNAbstract where GRNID=@DocRef          
  If ((((IsNull(@status,0) & 32) <> 0) Or (IsNull(@Status,0) & 64) <> 0) Or (IsNull(@Status,0) & 128) <> 0)        
   Begin        
    Set @DocumentStatus = 0        
   End        
 End          
Else If @DocType=@BILL Or @DocType=@BILLAMENDMENT Or @DocType=@BILLCANCELLATION        
 Begin          
  Select @Status=status from BillAbstract where BillID=@DocRef          
  If (((isnull(@Status,0) & 128) <> 0) Or (IsNull(@Status,0) & 64) <> 0)          
   Begin          
    Set @DocumentStatus = 0          
   End          
 End          
Else if @DocType=@PURCHASERETURN Or @DocType=@PURCHASERETURNCANCELLATION Or @DocType=@PURCHASERETURNAMENDMENT        
 Begin          
  Select @Status= Status from AdjustmentReturnAbstract where AdjustmentID = @DocRef          
    If (((isnull(@Status,0) & 128) <> 0) Or (IsNull(@Status,0) & 64) <> 0)        
   Begin          
    Set @DocumentStatus = 0         
   End        
 End        
Else if @DocType=@COLLECTIONAMENDMENT Or @DocType=@COLLECTIONS Or @DocType=@COLLECTIONCANCELLATION        
 Begin          
  Select @Status=IsNull(status,0) from Collections where DocumentID=@DocRef          
  If (((isnull(@Status,0) & 128) <> 0) Or (IsNull(@Status,0) & 64) <> 0)        
   Begin          
    Set @DocumentStatus = 0        
   End          
 End          
Else if @DocType=@PAYMENTS Or @DocType=@PAYMENTCANCELLATION Or @DocType=@PAYMENTAMENDMENT Or @DocType=@PAYMENTAUTOENTRY  
 Begin        
  Select @Status=status from Payments where DocumentID=@DocRef        
  If (((isnull(@Status,0) & 128) <> 0) Or (IsNull(@Status,0) & 64) <> 0)        
   Begin          
    Set @DocumentStatus = 0        
   End         
 End        
Else if @DocType=@STOCKTRANSFERIN Or @DocType=@STOCKTRANSFERINAMENDMENT Or @DocType=@STOCKTRANSFERINCANCELLATION        
 Begin       
  Select @Status=status from StockTransferInAbstract where DocSerial=@DocRef        
  If (((isnull(@Status,0) & 64) <> 0) Or (isnull(@Status,0) & 128) <> 0)        
   Begin          
    Set @DocumentStatus = 0        
   End            
 End          
Else if @DocType=@STOCKTRANSFEROUT Or @DocType=@STOCKTRANSFEROUTAMENDMENT Or @DocType=@STOCKTRANSFEROUTCANCELLATION        
 Begin          
  Select @Status=status from StockTransferOutAbstract where DocSerial=@DocRef        
  If (((isnull(@Status,0) & 64) <> 0) Or (isnull(@Status,0) & 128) <> 0)        
   Begin     
    Set @DocumentStatus = 0        
   End          
 End          
Else if @DocType=@CLAIMSCANCELLATION Or @DocType = @CLAIMS        
 Begin          
  Select @Status=(IsNull(Status,0)) from ClaimsNote where ClaimID=@DocRef        
  If ((IsNull(@Status,0) & 64) <> 0)        
   Begin        
    Set @DocumentStatus = 0        
   End        
 End          
Else if @DocType=@CONTRAENTRYCANCELLATION or @DocType = @CONTRAENTRY        
 Begin        
  Select @Status=(IsNull(Status,0)) from Deposits where DepositID=@DocRef        
  If (((IsNull(@Status,0) & 128) <> 0) Or (IsNull(@Status,0) & 64) <> 0)        
   Begin        
    Set @DocumentStatus = 0        
   End        
 End        
Else If @DocType = @INTERNALCONTRACANCELLATION Or @DocType = @INTERNALCONTRA        
 Begin        
  Select @Status=(IsNull(Status,0)) from ContraAbstract where ContraID=@DocRef        
  If (((IsNull(@Status,0) & 128) <> 0) Or (IsNull(@Status,0) & 64) <> 0)        
   Begin        
    Set @DocumentStatus = 0     
   End        
 End        
Else If @DocType=@APVCANCELLATION Or @DocType=@APV Or @DocType=@APV_AMENDMENT    
 Begin        
  Select @Status=(IsNull(Status,0)) from APVAbstract where DocumentID=@DocRef        
  If (((IsNull(@Status,0) & 128) <> 0) Or (IsNull(@Status,0) & 64) <> 0)        
   Begin        
    Set @DocumentStatus = 0        
   End        
 End        
Else If @DocType=@ARVCANCELLATION Or @DocType=@ARV Or @DocType=@ARV_AMENDMENT    
 Begin        
  Select @Status=(IsNull(Status,0)) from ARVAbstract where DocumentID=@DocRef        
  If (((IsNull(@Status,0) & 128) <> 0) Or (IsNull(@Status,0) & 64) <> 0)        
   Begin        
    Set @DocumentStatus = 0        
   End        
 End        
Else If @DocType=@PETTYCASHCANCELLATION Or @DocType=@PETTYCASH        
 Begin        
  Select @Status=(IsNull(Status,0)) from Payments where DocumentID=@DocRef        
  If (((IsNull(@Status,0) & 128) <> 0) Or (IsNull(@Status,0) & 64) <> 0)        
   Begin        
    Set @DocumentStatus = 0        
   End        
 End        
Else If @DocType=@DEBITNOTECANCELLATION Or @DocType=@DEBITNOTE Or @DocType=@DEBITNOTE_AMENDMENT      
 Begin        
  Select @Status=(IsNull(Status,0)) from DebitNote where DebitID=@DocRef        
  If (((IsNull(@Status,0) & 128) <> 0) Or (IsNull(@Status,0) & 64) <> 0)        
   Begin        
    Set @DocumentStatus = 0        
   End        
 End        
Else If @DocType=@CREDITNOTECANCELLATION Or @DocType=@CREDITNOTE Or @DocType=@CREDITNOTE_AMENDMENT    
 Begin        
  Select @Status=(IsNull(Status,0)) from CreditNote where CreditID=@DocRef        
  If (((IsNull(@Status,0) & 128) <> 0) Or (IsNull(@Status,0) & 64) <> 0)        
   Begin        
    Set @DocumentStatus = 0        
   End        
 End        
Else if @DocType=@ISSUE_SPARES Or @DocType=@ISSUE_SPARES_CANCEL Or @DocType=@ISSUE_SPARES_RETURN        
 Begin          
  Select @Status=(IsNULL(Status,0)) from IssueAbstract where IssueID=@DocRef          
  If (((IsNull(@Status,0) & 128) <> 0) Or (IsNull(@Status,0) & 64) <> 0)        
   Begin        
    Set @DocumentStatus = 0        
   End        
 End          
Else if @DocType=@SERVICE_INVOICE Or @DocType=@SERVICE_INVOICE_CANCEL    
 Begin          
  Select @Status=(IsNULL(Status,0)) from ServiceInvoiceAbstract where ServiceInvoiceID=@DocRef          
  If (((IsNull(@Status,0) & 128) <> 0) Or (IsNull(@Status,0) & 64) <> 0)        
   Begin        
    Set @DocumentStatus = 0        
   End        
 End          
If @DocType=@DEPOSITS Or @DocType=@DEPOSITS_CANCELLATION  
 Begin          
  Select @Status=status from Deposits where DepositID=@DocRef          
  If (((isnull(@Status,0) & 64) <> 0) Or (isnull(@Status,0) & 128) <> 0)        
   Begin          
    Set @DocumentStatus = 0        
   End          
 End          
If @DocType=@BOUNCECHEQUE_CANCEL Or @DocType=@BOUNCECHEQUE
 Begin          
  Select @Status=IsNULL(Realised,0) from Collections where DocumentID=@DocRef          
  If @Status = 4 Or @Status = 5
   Begin          
    Set @DocumentStatus = 0        
   End          
 End          
Return @DocumentStatus          
End 
