CREATE Function GetDescription(@DocRef Int,@DocType INT)
Returns  nvarchar(50)
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
Declare @MANUALJOURNALOLDREF INT
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
Declare @CONTRAENTRYCANCELLATION int

Declare @MANUALJOURNALAPV int
Declare @MANUALJOURNALARV int
Declare @MANUALJOURNALOTHERPAYMENTS int
Declare @MANUALJOURNALOTHERRECEIPTS int
Declare @MANUALJOURNALOTHERDEBITNOTE int
Declare @MANUALJOURNALOTHERCREDITNOTE int

Declare @SALESRETURNCANCELLATION int
Declare @DISPATCH int
Declare @DISPATCHCANCELLATION int
Declare @APV int
Declare @APVCANCELLATION int
Declare @ARV int
Declare @ARVCANCELLATION int
Declare @PETTYCASH int
Declare @PETTYCASHCANCELLATION int
Declare @PETTYCASHAMENDMENT int
Declare @STOCKTRANSFERIN int
Declare @STOCKTRANSFEROUT int
Declare @GRN int
Declare @GRNCANCELLATION int
Declare @DEBITNOTECANCELLATION INT
Declare @CREDITNOTECANCELLATION INT
Declare @STOCKTRANSFERINCANCELLATION int
Declare @STOCKTRANSFEROUTCANCELLATION int
Declare @STOCKTRANSFERINAMENDMENT int
Declare @STOCKTRANSFEROUTAMENDMENT int
Declare @DISPATCHAMENDMENT int
Declare @SALESRETURNAMENDMENT INT
Declare @GRNAMENDMENT int
Declare @PURCHASERETURNAMENDMENT int
Declare @INTERNALCONTRA int
Declare @INTERNALCONTRACANCELLATION int
Declare @COLLECTIONAMENDMENT INT
Declare @PAYMENT_AMENDMENT INT
Declare @YEAREND INT

Declare @MANUALJOURNAL_NEWREFERENCE Int
Declare @MANUALJOURNAL_CLAIMS Int

Declare @CREDITNOTE_AMENDMENT Int
Declare @DEBITNOTE_AMENDMENT Int
Declare @CreditNoteReference int
Declare @DebitNoteReference int

Declare @ISSUE_SPARES INT
Declare @ISSUE_SPARES_CANCEL INT
Declare @ISSUE_SPARES_RETURN INT
Declare @SERVICE_INVOICE INT
Declare @SERVICE_INVOICE_CANCEL INT
Declare @CUSTOMERID nvarchar(50)

Declare @SERVICE_INWARD Int
Declare @SERVICE_OUTWARD Int
Declare @SERVICE_INWARD_CANCEL Int
Declare @SERVICE_OUTWARD_CANCEL Int
Declare @DAMAGE_INVOICE Int


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
Set @MANUALJOURNALOLDREF =37
Set @CONTRAENTRYCANCELLATION=38

set @MANUALJOURNALINVOICE =28
Set @MANUALJOURNALSALESRETURN =29
Set @MANUALJOURNALBILL =30
Set @MANUALJOURNALPURCHASERETURN =31
Set @MANUALJOURNALCOLLECTIONS =32
Set @MANUALJOURNALPAYMENTS =33
Set @MANUALJOURNALDEBITNOTE =34
Set @MANUALJOURNALCREDITNOTE =35

Set @SALESRETURNCANCELLATION = 40
Set @DISPATCH = 44
Set @DISPATCHCANCELLATION = 45
set @APV = 46
set @APVCANCELLATION = 47
Set @ARV = 48
Set @ARVCANCELLATION = 49
Set @STOCKTRANSFERIN = 54
Set @STOCKTRANSFEROUT = 55
Set @PETTYCASH =52
Set @PETTYCASHCANCELLATION =53
Set @PETTYCASHAMENDMENT = 94
Set @GRN =41
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
Set @DISPATCHAMENDMENT = 71
Set @SALESRETURNAMENDMENT =72
Set @PURCHASERETURNAMENDMENT =73
Set @INTERNALCONTRA = 74
Set @INTERNALCONTRACANCELLATION = 75
Set @COLLECTIONAMENDMENT=77
Set @PAYMENT_AMENDMENT =  78
Set @MANUALJOURNALOTHERDEBITNOTE = 79
Set @MANUALJOURNALOTHERCREDITNOTE = 80
Set @YEAREND = 27
Set @MANUALJOURNAL_NEWREFERENCE = 81
Set @MANUALJOURNAL_CLAIMS = 82
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

Set @SERVICE_INWARD = 151
Set @SERVICE_OUTWARD = 153
Set @SERVICE_INWARD_CANCEL  = 152
Set @SERVICE_OUTWARD_CANCEL  = 154
Set @DAMAGE_INVOICE = 155

Declare @CASHTOBANK Int, @BANKTOCASH Int, @CASHTOPETTYCASH Int,@PETTYCASHTOCASH Int,@ACCOUNT_TRANSFER Int
Declare @CHEQUEDEPOSIT Int
Set @CASHTOBANK =1
Set @BANKTOCASH =2
Set @CASHTOPETTYCASH =3
Set @PETTYCASHTOCASH =4
SET @CHEQUEDEPOSIT=5
SET @ACCOUNT_TRANSFER=6

Declare @ARVReference Int
Declare @APVReference Int
Declare @PaymentReference Int
Declare @Status INT,@InvoiceReference INT,@BillReference INT,@Reference INT,@OriginalReference INT
Declare @DESCRIPTION nvarchar(50), @TransactionType Int,@DepositID Int,@Realised Int,@ChqNo Int,@CollectID Int
Declare @CollectionReference Int
Declare @RetailInvoiceType INT
Declare @PettyCashReference Int
--Return @RETAILINVOICECANCELLATION
If @DocType=@RETAILINVOICE
Begin
Select @RetailInvoiceType = IsNULL(InvoiceType, 0) from InvoiceAbstract Where InvoiceID = @DocRef
If @RetailInvoiceType = 5
Set @DESCRIPTION = N'RetailInvoice SalesReturn Saleable'
Else If @RetailInvoiceType = 6
Set @DESCRIPTION = N'RetailInvoice SalesReturn Damages'
Else
Set @DESCRIPTION = N'Retail Invoice'
End
Else if @DocType=@RETAILINVOICEAMENDMENT
Begin
Select @Status=Status, @InvoiceReference=InvoiceReference from InvoiceAbstract where InvoiceID=@DocRef
if (((IsNULL(@Status,0) & 128) = 0) Or (IsNULL(@Status,0) & 64) <> 0) and (@InvoiceReference is not null)
Begin
Set @Description = N'Retail Invoice Amendment'
End
Else If (IsNULL(@Status,0) & 128) <> 0
Begin
Set @DESCRIPTION = N'Retail Invoice Amended'
End
End
Else if @DocType=@RETAILINVOICECANCELLATION
Begin
Select @RetailInvoiceType = IsNULL(InvoiceType, 0) from InvoiceAbstract Where InvoiceID = @DocRef
If @RetailInvoiceType = 5
Set @DESCRIPTION = N'RetailInvoice SalesReturn Saleable Cancellation'
Else If @RetailInvoiceType = 6
Set @DESCRIPTION = N'RetailInvoice SalesReturn Damages Cancellation'
Else
Set @DESCRIPTION = N'Retail Invoice Cancellation'
End
Else If @DocType=@INVOICE
Begin
Set @DESCRIPTION = N'Invoice'
End
Else if @DocType=@INVOICEAMENDMENT
Begin
Select @Status=Status,@InvoiceReference=InvoiceReference from InvoiceAbstract where InvoiceID=@DocRef
If (((IsNULL(@Status,0) & 128) = 0) Or (IsNULL(@Status,0) & 64) <> 0) and  (@InvoiceReference is not null)
Begin
Set @Description = N'Invoice Amendment'
End

Else If (IsNULL(@Status,0) & 128) <> 0
Begin
Set @DESCRIPTION = N'Invoice Amended'
End
End
Else if @DocType=@INVOICECANCELLATION
Begin
Set @DESCRIPTION = N'Invoice Cancellation'
End
Else if @DocType=@SALESRETURN
Begin
Select @Status = Status from InvoiceAbstract where InvoiceID=@DocRef
If (IsNULL(@Status,0) & 32)<>0
Set @DESCRIPTION = N'Sales Return - Damage'
Else
Set @DESCRIPTION = N'Sales Return - Saleable'
End
Else If @DocType=@BILL
Begin
Set @DESCRIPTION = N'Bill'
End
Else if @DocType=@BILLAMENDMENT
Begin
Select @Status=Status,@BillReference=BillReference from BillAbstract where BillID=@DocRef
If (((IsNULL(@Status,0) & 128) = 0) Or (IsNULL(@Status,0) & 64) <> 0) and (@BillReference is not null)
Begin
Set @Description = N'Bill Amendment'
End
Else If (IsNULL(@Status,0) & 128) <> 0
Begin
Set @DESCRIPTION = N'Bill Amended'
End
End
Else if @DocType=@BILLCANCELLATION
Begin
Set @DESCRIPTION = N'Bill Cancellation'
End
Else if @DocType=@PURCHASERETURN
Begin
Set @DESCRIPTION = N'Purchase Return'
End
Else if @DocType=@PURCHASERETURNCANCELLATION
Begin
Set @DESCRIPTION = N'Purchase Return Cancellation'
End
Else if @DocType=@COLLECTIONS
Begin
Select @Status=IsNULL(Status,0),@CUSTOMERID =IsNULL(CustomerID,N''),@DepositID=IsNULL(DepositID,0),@ChqNo=ChequeNumber,@Realised=Realised from collections where DocumentID=@DocRef
If @DepositID = 0
Begin
If @CUSTOMERID = N'GIFT VOUCHER'
Set @DESCRIPTION = N'Issue Gift Voucher'
Else
Set @DESCRIPTION = N'Collections'
End
Else
Begin
If @Realised = 3
Begin
Set @DESCRIPTION = N'Collections(Represented)'
End
Else If @Realised = 1
Begin
Set @DESCRIPTION = N'Collections(Realised)'
End
Else If @Realised = 2
Begin
Set @DESCRIPTION = N'Collections(Bounced)'
End
Else
Begin
If @DepositID <> 0 And @Status = 2
Begin
Set @DESCRIPTION = N'Collections'
End
Else
Begin
Set @DESCRIPTION = N'Collections(Deposited)'
End
End
End
End
Else if @DocType=@DEPOSITS
Begin
Select @TransactionType=TransactionType from Deposits where DepositID=@DocRef
If @TransactionType=@CASHTOBANK
Begin
Set @DESCRIPTION = N'Cash Deposited in Bank'
End
Else If @TransactionType= @BANKTOCASH
Begin
Set @DESCRIPTION = N'Cash Withdrawn from Bank'
End
Else If @TransactionType=@CASHTOPETTYCASH
Begin
Set @DESCRIPTION = N'Cash Paid to Petty Cash'
End
Else If @TransactionType= @PETTYCASHTOCASH
Begin
Set @DESCRIPTION = N'Cash Received from Petty Cash'
End
Else If @TransactionType= @CHEQUEDEPOSIT
Begin
--   Select Top 1 @CollectID=DocumentID,@ChqNo=ChequeNumber from collections where DepositID=@DocRef
--   Select @Realised=Realised from Collections where ChequeNumber=@ChqNo and DocumentID = @CollectID
--   If @Realised=3
--   Begin
--    Set @DESCRIPTION = N'Cheque Deposit-Representation'
--   End
--   Else If @Realised=1
--   Begin
--    Set @DESCRIPTION = N'Cheque Deposit-Realisation'
--   End
--   Else
--   Begin
--    Set @DESCRIPTION = N'Cheque Deposit'
--   End
Set @DESCRIPTION = N'Cheque Deposit'
End
Else If @TransactionType = @ACCOUNT_TRANSFER
Begin
Set @DESCRIPTION = N'Internal Bank Transfer'
End
End
Else if @DocType=@DEPOSITS_CANCELLATION
Begin
Set @DESCRIPTION = N'Cheque Deposit Cancellation'
End
Else if @DocType=@BOUNCECHEQUE
Begin
Select @Realised=Realised from collections where DocumentID=@DocRef
If @Realised=3
Begin
Set @DESCRIPTION = N'Bounce Cheque(Represented)'
End
Else If @Realised=1
Begin
Set @DESCRIPTION = N'Bounce Cheque(Realised)'
End
Else
Begin
Set @DESCRIPTION = N'Bounce Cheque'
End
End
Else If @DocType=@BOUNCECHEQUE_CANCELLATION
Begin
Set @DESCRIPTION = N'Bounce Cheque - Cancellation'
End
Else if @DocType=@REPOFBOUNCECHEQUE
Begin
Set @DESCRIPTION = N'Rep of Bounce Cheque'
End

Else if @DocType=@PAYMENTS
Begin
Set @DESCRIPTION = N'Payments'
End
Else if @DocType=@PAYMENTCANCELLATION
Begin
Set @DESCRIPTION = N'Payment Cancellation'
End
Else if @DocType=@AUTOENTRY
Begin
Set @DESCRIPTION = N'Auto Entry'
End
Else if @DocType=@DEBITNOTE
Begin
Set @DESCRIPTION = N'Debit Note'
End
Else if @DocType=@CREDITNOTE
Begin
Set @DESCRIPTION = N'Credit Note'
End
Else if @DocType=@CLAIMSTOVENDOR
Begin
Set @DESCRIPTION = N'Claims to Vendor'
End
Else if @DocType=@CLAIMSSETTLEMENT
Begin
Set @DESCRIPTION = N'Claims Settlement'
End
Else if @DocType=@CLAIMSCANCELLATION
Begin
Set @DESCRIPTION = N'Claims Cancellation'
End
Else if @DocType=@COLLECTIONCANCELLATION
Begin
Select @CUSTOMERID =IsNULL(CustomerID,N'')  from collections where DocumentID=@DocRef
If @CUSTOMERID = N'GIFT VOUCHER'
Set @DESCRIPTION = N'Gift Voucher Cancellation'
Else
Set @DESCRIPTION = N'Collection Cancellation'
End
Else if @DocType=@MANUALJOURNAL
Begin
Set @DESCRIPTION = N'Manual Journal'
End
Else if @DocType=@MANUALJOURNALOLDREF
Begin
If @DocRef  = 2
Begin
Set @DESCRIPTION = N'Manual Journal- Old Reference'
End
Else
Begin
Set @DESCRIPTION = N'Manual Journal'
End
End
Else if @DocType=@MANUALJOURNALINVOICE
Begin
Set @DESCRIPTION = N'Invoice'
End
Else if @DocType=@MANUALJOURNALSALESRETURN
Begin
Set @DESCRIPTION = N'Sales Return'
End
Else if @DocType=@MANUALJOURNALBILL
Begin
Set @DESCRIPTION = N'Bill'
End
Else if @DocType=@MANUALJOURNALPURCHASERETURN
Begin
Set @DESCRIPTION = N'Purchase Return'
End
Else if @DocType=@MANUALJOURNALCOLLECTIONS
Begin
Set @DESCRIPTION = N'Collections'
End
Else if @DocType=@MANUALJOURNALPAYMENTS
Begin
Set @DESCRIPTION = N'Payments'
End
Else if @DocType=@MANUALJOURNALDEBITNOTE or @DocType = @MANUALJOURNALOTHERDEBITNOTE
Begin
Set @DESCRIPTION = N'Debit Note'
End
Else if @DocType=@MANUALJOURNALCREDITNOTE or @DocType = @MANUALJOURNALOTHERCREDITNOTE
Begin
Set @DESCRIPTION = N'Credit Note'
End
Else if @DocType=@CONTRAENTRYCANCELLATION
Begin
Select @TransactionType=TransactionType from Deposits where DepositID=@DocRef
If @TransactionType=@CASHTOBANK
Begin
Set @DESCRIPTION = N'Cash Deposited in Bank-Cancelled'
End
Else If @TransactionType= @BANKTOCASH
Begin
Set @DESCRIPTION = N'Cash Withdrawn from Bank-Cancelled'
End
Else If @TransactionType=@CASHTOPETTYCASH
Begin
Set @DESCRIPTION = N'Cash Paid to Petty Cash-Cancelled'
End
Else If @TransactionType= @PETTYCASHTOCASH
Begin
Set @DESCRIPTION = N'Cash Received from Petty Cash-Cancelled'
End
Else If @TransactionType= @CHEQUEDEPOSIT
Begin
Set @DESCRIPTION = N'Cheque Deposit-Cancelled'
End
Else If @TransactionType = @ACCOUNT_TRANSFER
Begin
Set @DESCRIPTION = N'Internal Bank Transfer-Cancelled'
End
End
Else if @DocType=@SALESRETURNCANCELLATION
Begin
Select @Status = Status from InvoiceAbstract where InvoiceID=@DocRef
If (IsNULL(@Status,0) & 32)<>0
Set @DESCRIPTION = N'Sales Return - Damage Cancellation'
Else
Set @DESCRIPTION = N'Sales Return - Saleable Cancellation'
End
Else if @DocType=@DISPATCH
Begin
Set @DESCRIPTION = N'Dispatch'
End
Else if @DocType=@DISPATCHCANCELLATION
Begin
Select @Status=Status from DispatchAbstract where DispatchID=@DocRef
If (IsNULL(@Status,0) & 64) <> 0
Begin
Set @DESCRIPTION = N'Dispatch Cancellation'
End
Else
Begin
Set @Description = N'Dispatch Closed'
End
End
Else if @DocType=@APV
Begin
Set @DESCRIPTION = N'APV'
End
Else if @DocType=@APVCANCELLATION
Begin
Set @DESCRIPTION = N'APV Cancellation'
End
Else if @DocType=@ARV
Begin
Set @DESCRIPTION = N'ARV'
End
Else if @DocType=@ARVCANCELLATION
Begin
Set @DESCRIPTION = N'ARV Cancellation'
End
Else if @DocType=@STOCKTRANSFERIN
Begin
Set @DESCRIPTION = N'Stock Transfer In'
End
Else if @DocType=@STOCKTRANSFEROUT
Begin
Set @DESCRIPTION = N'Stock Transfer Out'
End
Else if @DocType=@PETTYCASH
Begin
Set @DESCRIPTION = N'Petty Cash Payment'
End
Else if @DocType=@PETTYCASHCANCELLATION
Begin
Set @DESCRIPTION = N'Petty Cash Payment Cancelled'
End
Else if @DocType=@PETTYCASHAMENDMENT
Begin
Select @Status= IsNULL(Status,0), @PettyCashReference=RefDocID from
Payments where DocumentID=@DocRef
if ((IsNULL(@Status,0) & 64)= 0 or (IsNULL(@Status,0) & 64) <> 0)  and (@PettyCashReference is not null)
Begin
Set @Description = N'Petty Cash Payment Amendment'
End
else If (IsNULL(@Status,0) & 128)  <> 0
Begin
Set @DESCRIPTION = N'Petty Cash Payment Amended'
End
End
Else if @DocType=@GRN
Begin
Set @DESCRIPTION = N'GRN'
End
Else if @DocType=@GRNCANCELLATION
Begin
Set @DESCRIPTION = N'GRN Cancellation'
End
Else if @DocType = @MANUALJOURNALAPV
Begin
Set @DESCRIPTION = N'APV'
End
Else if @DocType = @MANUALJOURNALARV
Begin
Set @DESCRIPTION = N'ARV'
End
Else if @DocType = @MANUALJOURNALOTHERPAYMENTS
Begin
Set @DESCRIPTION = N'Payments'
End
Else if @DocType = @MANUALJOURNALOTHERRECEIPTS
Begin
Set @DESCRIPTION = N'Collections'
End
Else if @DocType=@DEBITNOTECANCELLATION
Begin
Set @DESCRIPTION = N'Debit Note Cancellation'
End
Else if @DocType=@CREDITNOTECANCELLATION
Begin
Set @DESCRIPTION = N'Credit Note Cancellation'
End
Else if @DocType=@STOCKTRANSFERINCANCELLATION
Begin
Set @DESCRIPTION = N'Stock Transfer In Cancellation'
End
Else if @DocType=@STOCKTRANSFEROUTCANCELLATION
Begin
Set @DESCRIPTION = N'Stock Transfer Out Cancellation'
End
Else if @DocType=@STOCKTRANSFERINAMENDMENT
Begin
Select @Status=Status,@Reference=Reference from StockTransferInAbstract where DocSerial=@DocRef
If (IsNULL(@Status,0) & 128) <> 0
Begin
Set @DESCRIPTION = N'Stock Transfer In Amended'
End
Else if ((IsNULL(@Status,0) & 128) = 0 ) and (@Reference is not null)
Begin
Set @Description = N'Stock Transfer In Amendment'
End
End
Else if @DocType=@STOCKTRANSFEROUTAMENDMENT
Begin
Select @Status=Status,@Reference=STOIDRef from StockTransferOutAbstract where DocSerial=@DocRef
If (IsNULL(@Status,0) & 128) <> 0
Begin
Set @DESCRIPTION = N'Stock Transfer Out Amended'
End
Else if ((IsNULL(@Status,0) & 128) = 0 ) and (@Reference is not null)
Begin
Set @Description = N'Stock Transfer Out Amendment'
End
End
Else if @DocType=@DISPATCHAMENDMENT
Begin
Select @Status=Status,@OriginalReference=Original_Reference from DispatchAbstract where DispatchID=@DocRef
If (IsNULL(@Status,0) & 128) <> 0
Begin
Set @DESCRIPTION = N'Dispatch Amended'
End
Else if ((IsNULL(@Status,0) & 128) = 0 ) and (@OriginalReference is not null)
Begin
Set @Description = N'Dispatch Amendment'
End
End
Else if @DocType=@SALESRETURNAMENDMENT
Begin
Select @Status=Status,@InvoiceReference=InvoiceReference from InvoiceAbstract where InvoiceID=@DocRef
If (IsNULL(@Status,0) & 32) <> 0
Begin
If (IsNULL(@Status,0) & 128) <> 0
Begin
Set @DESCRIPTION = N'Sales Return - Damage Amended'
End
Else If ((IsNULL(@Status,0) & 128) = 0 ) and (@InvoiceReference is not Null)
Begin
Set @DESCRIPTION = N'Sales Return - Damage Amendment'
End
End
Else if (IsNULL(@Status,0) & 32)=0
Begin
If (IsNULL(@Status,0) & 128) <> 0
Begin
Set @DESCRIPTION = N'Sales Return - Saleable Amended'
End
Else If ((IsNULL(@Status,0) & 128) = 0 ) and (@InvoiceReference is not Null)
Begin
Set @DESCRIPTION = N'Sales Return - Saleable Amendment'
End
End
End
Else if @DocType=@GRNAMENDMENT
Begin
Declare @grnreference int
Select @Status= GRNStatus,@grnreference = IsNULL(GRNIDRef,0) from GRNAbstract where GRNID=@DocRef
--If (IsNULL(@Status,0) & 128) <> 0
If (IsNULL(@Status,0)) & 32 <> 0
Begin
Set @DESCRIPTION = N'GRN Amended'
End
-- Else if ((IsNULL(@Status,0) & 128) = 0 ) and (@grnreference is not null)
Else If (IsNULL(@Status,0)) & 16 <> 0
Begin
Set @Description = N'GRN Amendment'
End
End
Else if @DocType=@PURCHASERETURNAMENDMENT
Begin
Declare @purchasereturnreference int
Select @Status= Status,@purchasereturnreference = IsNULL(DocReference,0)
from AdjustmentReturnAbstract where AdjustmentID = @DocRef

If (IsNULL(@Status,0) & 128) <> 0
Begin
Set @DESCRIPTION = N'Purchase Return Amended'
End
Else if ((IsNULL(@Status,0) & 128) = 0 ) and (@purchasereturnreference is not null)
Begin
Set @Description = N'Purchase Return Amendment'
End
End
Else if @DocType = @INTERNALCONTRA
Begin
set @Description = N'Internal Contra'
End
Else if @DocType = @INTERNALCONTRACANCELLATION
Begin
Set @Description = N'Internal Contra Cancellation'
End
Else if @DocType=@COLLECTIONAMENDMENT
Begin
Select @CUSTOMERID=IsNULL(CustomerID,N''),@Status=Status,@CollectionReference=RefDocID from Collections where DocumentID=@DocRef
If (IsNULL(@Status,0) & 128) <> 0
Begin
If @CUSTOMERID = N'GIFT VOUCHER'
Set @DESCRIPTION = N'Gift Voucher Amended'
Else
Set @DESCRIPTION = N'Collection Amended'
End
Else if ((IsNULL(@Status,0) & 128) = 0) and (@CollectionReference is not null)
Begin
Select @CUSTOMERID =IsNULL(CustomerID,N''),@DepositID=IsNULL(DepositID,0),@ChqNo=ChequeNumber,@Realised=Realised from collections where DocumentID=@DocRef
If @DepositID=0
Begin
If @CUSTOMERID = N'GIFT VOUCHER'
Set @DESCRIPTION = N'Gift Voucher Amendment'
Else
Set @DESCRIPTION = N'Collection Amendment'
End
Else
Begin
If @Realised = 3
Begin
Set @DESCRIPTION = N'Collection Amendment(Represented)'
End
Else If @Realised = 1
Begin
Set @DESCRIPTION = N'Collection Amendment(Realised)'
End
Else If @Realised = 2
Begin
Set @DESCRIPTION = N'Collection Amendment(Bounced)'
End
Else
Begin
Set @DESCRIPTION = N'Collection Amendment(Deposited)'
End
End
End
End
Else if @DocType=@PAYMENT_AMENDMENT
Begin
Select @Status= IsNULL(Status,0), @PaymentReference=RefDocID from
Payments where DocumentID=@DocRef

if ((IsNULL(@Status,0) & 64)= 0 or (IsNULL(@Status,0) & 64) <> 0)  and (@PaymentReference is not null)
Begin
Set @Description = N'Payment Amendment'
End
else If (IsNULL(@Status,0) & 128)  <> 0
Begin
Set @DESCRIPTION = N'Payment Amended'
End
end
Else if @DocType=@YEAREND
Begin
Set @Description = N'Year End Entries'
End
Else if @DocType=@MANUALJOURNAL_NEWREFERENCE
Begin
Set @Description = N'Manual Journal New Reference'
End
Else if @DocType=@MANUALJOURNAL_CLAIMS
Begin
Set @Description = N'Claims Note'
End
Else if @DocType=@ARV_AMENDMENT
Begin
Select @Status= IsNULL(Status,0), @ARVReference=RefDocID from
ARVAbstract where DocumentID=@DocRef
if ((IsNULL(@Status,0) & 64)= 0 or (IsNULL(@Status,0) & 64) <> 0)  and (@ARVReference is not null)
Begin
Set @Description = N'ARV Amendment'
End
else If (IsNULL(@Status,0) & 128)  <> 0
Begin
Set @DESCRIPTION = N'ARV Amended'
End
End
Else if @DocType=@APV_AMENDMENT
Begin
Select @Status= IsNULL(Status,0), @APVReference=RefDocID from
APVAbstract where DocumentID=@DocRef
if ((IsNULL(@Status,0) & 64)= 0 or (IsNULL(@Status,0) & 64) <> 0)  and (@APVReference is not null)
Begin
Set @Description = N'APV Amendment'
End
else If (IsNULL(@Status,0) & 128)  <> 0
Begin
Set @DESCRIPTION = N'APV Amended'
End
End
Else if @DocType=@CREDITNOTE_AMENDMENT
Begin
Select @Status= IsNULL(Status,0), @CreditNoteReference=RefDocID from
Creditnote where creditid=@Docref
if ((IsNULL(@Status,0) & 64)= 0 or (IsNULL(@Status,0) & 64) <> 0)  and (@CreditNoteReference is not null)
Begin
Set @Description = N'Credit Note Amendment'
End
else If (IsNULL(@Status,0) & 128)  <> 0
Begin
Set @DESCRIPTION = N'Credit Note Amended'
End
End
Else if @DocType=@DEBITNOTE_AMENDMENT
Begin
Select @Status= IsNULL(Status,0), @DebitNoteReference=RefDocID from
DebitNote where DebitId=@Docref
if ((IsNULL(@Status,0) & 64)= 0 or (IsNULL(@Status,0) & 64) <> 0)  and (@DebitNoteReference is not null)
Begin
Set @Description = N'Debit Note Amendment'
End
else If (IsNULL(@Status,0) & 128)  <> 0
Begin
Set @DESCRIPTION = N'Debit Note Amended'
End
End
Else if @DocType = @ISSUE_SPARES
Begin
set @Description = N'Issue Spares'
End
Else if @DocType = @ISSUE_SPARES_CANCEL
Begin
Set @Description = N'Issue Spares Cancellation'
End
Else if @DocType = @ISSUE_SPARES_RETURN
Begin
Set @Description = N'Issue Spares Return'
End
Else if @DocType = @SERVICE_INVOICE
Begin
set @Description = N'Service Invoice'
End
Else if @DocType = @SERVICE_INVOICE_CANCEL
Begin
Set @Description = N'Service Invoice Cancellation'
End
Else if @DocType = @SERVICE_INWARD
Begin
Set @Description = N'Service Inward'
End
Else if @DocType = @SERVICE_INWARD_CANCEL
Begin
Set @Description = N'Service Inward Cancellation'
End
Else if @DocType = @SERVICE_OUTWARD
Begin
Set @Description = N'Service Outward'
End
Else if @DocType = @SERVICE_OUTWARD_CANCEL
Begin
Set @Description = N'Service Outward Cancellation'
End
Else If @DocType = @DAMAGE_INVOICE
Begin
Set @Description = N'Damage Invoice'
End
return dbo.LookupDictionaryItem(@DESCRIPTION,Default)
End

