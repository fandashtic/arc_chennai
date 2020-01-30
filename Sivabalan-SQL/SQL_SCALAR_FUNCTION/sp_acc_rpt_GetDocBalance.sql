CREATE Function sp_acc_rpt_GetDocBalance(@DocRef INT,@DocType INT,@CollectionID INT)
Returns nVarChar(50)
As
Begin
------------------------ Constant Declarations And Their Values ------------------------------
Declare @DISPATCH INT
Declare @DISPATCHCANCELLATION INT
Declare @DISPATCHAMENDMENT INT
Declare @RETAILINVOICE INT
Declare @RETAILINVOICEAMENDMENT INT
Declare @RETAILINVOICECANCELLATION INT
Declare @INVOICE INT
Declare @INVOICEAMENDMENT INT
Declare @INVOICECANCELLATION INT
Declare @SALESRETURN INT
Declare @SALESRETURNCANCELLATION INT
Declare @SALESRETURNAMENDMENT INT
Declare @GRN INT
Declare @GRNCANCELLATION INT
Declare @GRNAMENDMENT INT
Declare @BILL INT
Declare @BILLAMENDMENT INT
Declare @BILLCANCELLATION INT
Declare @PURCHASERETURN INT
Declare @PURCHASERETURNCANCELLATION INT
Declare @PURCHASERETURNAMENDMENT INT
Declare @COLLECTIONS INT
Declare @COLLECTIONCANCELLATION INT
Declare @COLLECTIONAMENDMENT INT
Declare @PAYMENTS INT
Declare @PAYMENTCANCELLATION INT
Declare @PAYMENTAMENDMENT INT
Declare @STOCKTRANSFERIN INT
Declare @STOCKTRANSFERINCANCELLATION INT
Declare @STOCKTRANSFERINAMENDMENT INT
Declare @STOCKTRANSFEROUT INT
Declare @STOCKTRANSFEROUTCANCELLATION INT
Declare @STOCKTRANSFEROUTAMENDMENT INT
Declare @CLAIMSCANCELLATION INT
Declare @CLAIMS INT
Declare @CONTRAENTRYCANCELLATION INT
Declare @CONTRAENTRY INT
Declare @APVCANCELLATION INT
Declare @APV INT
Declare @ARVCANCELLATION INT
Declare @ARV INT
Declare @PETTYCASHCANCELLATION INT
Declare @PETTYCASH INT
Declare @DEBITNOTE INT
Declare @DEBITNOTECANCELLATION INT
Declare @DEBITNOTEAMENDMENT INT
Declare @CREDITNOTE INT
Declare @CREDITNOTECANCELLATION INT
Declare @CREDITNOTEAMENDMENT INT
Declare @INTERNALCONTRACANCELLATION INT
Declare @INTERNALCONTRA INT
Declare @ARV_AMENDMENT INT
Declare @APV_AMENDMENT INT
Declare @DEPOSITS INT
Declare @BOUNCECHEQUE INT
Declare @MANUALJOURNAL INT

Declare @SERVICE_INWARD Int
Declare @SERVICE_OUTWARD Int
Declare @DAMAGE_INVOICE Int

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
Set @DEBITNOTEAMENDMENT = 91
Set @DEBITNOTE = 20
Set @CREDITNOTECANCELLATION = 65
Set @CREDITNOTEAMENDMENT = 90
Set @CREDITNOTE = 21
Set @INTERNALCONTRACANCELLATION = 75
Set @INTERNALCONTRA = 74
Set @ARV_AMENDMENT = 83
Set @APV_AMENDMENT = 84
Set @DEPOSITS = 14
Set @BOUNCECHEQUE = 15
Set @MANUALJOURNAL = 26

Set @SERVICE_INWARD = 151
Set @SERVICE_OUTWARD = 153
Set @DAMAGE_INVOICE = 155

DECLARE @CHEQUE_DEPOSIT INT
SET @CHEQUE_DEPOSIT = 5
SET @CollectionID = IsNull(@CollectionID,0)
---------------------------------------------------------------------------------------------
Declare @Balance Decimal(18,6)
Declare @ReturnValue nVarChar(50)
Declare @CustomerID nVarChar(50)
Declare @VendorID nVarChar(50)
Declare @TransactionType INT

If @DocType=@RETAILINVOICE Or @DocType=@RETAILINVOICEAMENDMENT Or @DocType=@RETAILINVOICECANCELLATION Or @DocType=@INVOICE Or @DocType=@INVOICEAMENDMENT Or @DocType=@INVOICECANCELLATION Or @DocType=@SALESRETURNCANCELLATION Or @DocType=@SALESRETURN Or @DocType=@SALESRETURNAMENDMENT
Begin
Select @Balance = Balance from InvoiceAbstract where InvoiceID=@DocRef
End
Else If @DocType=@BILL Or @DocType=@BILLAMENDMENT Or @DocType=@BILLCANCELLATION
Begin
Select @Balance = Balance from BillAbstract where BillID=@DocRef
End
Else if @DocType=@PURCHASERETURN Or @DocType=@PURCHASERETURNCANCELLATION Or @DocType=@PURCHASERETURNAMENDMENT
Begin
Select @Balance = Balance from AdjustmentReturnAbstract where AdjustmentID = @DocRef
End
Else if @DocType=@COLLECTIONAMENDMENT Or @DocType=@COLLECTIONS Or @DocType=@COLLECTIONCANCELLATION
Begin
Select @Balance = Balance from Collections Where DocumentID = @DocRef
End
Else if @DocType=@PAYMENTS Or @DocType=@PAYMENTCANCELLATION Or @DocType=@PAYMENTAMENDMENT
Begin
Select @Balance = Balance from Payments Where DocumentID = @DocRef
End
Else If @DocType=@APVCANCELLATION Or @DocType=@APV Or @DocType=@APV_AMENDMENT
Begin
Select @Balance = Balance from APVAbstract where DocumentID=@DocRef
End
Else If @DocType=@ARVCANCELLATION Or @DocType=@ARV Or @DocType=@ARV_AMENDMENT
Begin
Select @Balance = Balance from ARVAbstract where DocumentID=@DocRef
End
Else If @DocType=@DEBITNOTECANCELLATION Or @DocType=@DEBITNOTE Or @DocType=@DEBITNOTEAMENDMENT
Begin
Select @Balance = Balance from DebitNote where DocumentID=@DocRef
End
Else If @DocType=@CREDITNOTECANCELLATION Or @DocType=@CREDITNOTE Or @DocType=@CREDITNOTEAMENDMENT
Begin
Select @Balance = Balance from CreditNote where CreditID=@DocRef
End
Else if @DocType=@CLAIMSCANCELLATION Or @DocType = @CLAIMS
Begin
Select @Balance = Balance from ClaimsNote where DocumentID=@DocRef
End
Else If @DocType=@DEPOSITS
Begin
Select @TransactionType = TransactionType from Deposits Where DepositID = @DocRef
If @TransactionType = @CHEQUE_DEPOSIT
Select @Balance = Balance from Collections Where DocumentID = @CollectionID
End
Else If @DocType=@BOUNCECHEQUE
Begin
Select @Balance = Balance from Collections Where DocumentID = @DocRef
End
Else If @DocType=@MANUALJOURNAL
Begin
Select @Balance = Balance from ManualJournal Where TransactionID = @DocRef
End
Else If @DocType=@SERVICE_INWARD
Begin
Select @Balance = Balance from ServiceAbstract Where InvoiceID = @DocRef and ServiceType = 'Inward'
End
Else If @DocType=@SERVICE_OUTWARD
Begin
Select @Balance = Balance from ServiceAbstract Where InvoiceID = @DocRef and ServiceType = 'Outward'
End
Else If @DocType = @DAMAGE_INVOICE
Begin
Select @Balance = Balance From DandDInvAbstract Where DandDInvID = @DocRef
End
/*IF @BALANCE = 0 THEN RETURN NULLSTRING VALUE ELSE RETURN @BALANCE*/
If IsNull(@Balance,0) = 0
Set @ReturnValue = ''
Else
Set @ReturnValue = @Balance

Return @ReturnValue
End

