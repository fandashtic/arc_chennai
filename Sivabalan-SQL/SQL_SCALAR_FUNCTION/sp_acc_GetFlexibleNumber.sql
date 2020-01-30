CREATE Function sp_acc_GetFlexibleNumber(@DocRef INT,@DocType INT)
Returns nVarChar(255)
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
Declare @ISSUE_SPARES INT
Declare @ISSUE_SPARES_CANCEL INT
Declare @ISSUE_SPARES_RETURN INT
Declare @SERVICE_INVOICE INT
Declare @SERVICE_INVOICE_CANCEL INT
Declare @SERVICE_INWARD Int
Declare @SERVICE_OUTWARD Int
Declare @SERVICE_INWARD_CANCEL Int
Declare @SERVICE_OUTWARD_CANCEL Int
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
Set @ISSUE_SPARES = 85
Set @ISSUE_SPARES_CANCEL = 86
Set @ISSUE_SPARES_RETURN = 87
Set @SERVICE_INVOICE = 88
Set @SERVICE_INVOICE_CANCEL = 89

Set @SERVICE_INWARD = 151
Set @SERVICE_OUTWARD = 153
Set @SERVICE_INWARD_CANCEL  = 152
Set @SERVICE_OUTWARD_CANCEL  = 154
Set @DAMAGE_INVOICE = 155
---------------------------------------------------------------------------------------------
Declare @FlexibleNumber nVarChar(255)
Declare @CustomerID nVarChar(50)
Declare @VendorID nVarChar(50)

If @DocType=@DISPATCH Or @DocType=@DISPATCHCANCELLATION Or @DocType=@DISPATCHAMENDMENT
Begin
Select @FlexibleNumber = DocRef from DispatchAbstract Where DispatchID = @DocRef
End
Else If @DocType=@RETAILINVOICE Or @DocType=@RETAILINVOICEAMENDMENT Or @DocType=@RETAILINVOICECANCELLATION Or @DocType=@INVOICE Or @DocType=@INVOICEAMENDMENT Or @DocType=@INVOICECANCELLATION Or @DocType=@SALESRETURNCANCELLATION Or @DocType=@SALESRETURN Or
@DocType=@SALESRETURNAMENDMENT
Begin
Select @FlexibleNumber = DocReference from InvoiceAbstract where InvoiceID=@DocRef
End
Else if @DocType=@GRN Or @DocType=@GRNCANCELLATION Or @DocType=@GRNAMENDMENT
Begin
Select @FlexibleNumber = DocumentReference from GRNAbstract where GRNID=@DocRef
End
Else If @DocType=@BILL Or @DocType=@BILLAMENDMENT Or @DocType=@BILLCANCELLATION
Begin
Select @FlexibleNumber = DocIDReference from BillAbstract where BillID=@DocRef
End
Else if @DocType=@PURCHASERETURN Or @DocType=@PURCHASERETURNCANCELLATION Or @DocType=@PURCHASERETURNAMENDMENT
Begin
Select @FlexibleNumber = Reference from AdjustmentReturnAbstract where AdjustmentID = @DocRef
End
Else if @DocType=@COLLECTIONAMENDMENT Or @DocType=@COLLECTIONS Or @DocType=@COLLECTIONCANCELLATION
Begin
Select @CustomerID = CustomerID from Collections Where DocumentID = @DocRef
If @CustomerID Is NULL
Select @FlexibleNumber = DocReference from Collections where DocumentID = @DocRef
Else
Select @FlexibleNumber = DocumentReference from Collections where DocumentID = @DocRef
End
Else if @DocType=@PAYMENTS Or @DocType=@PAYMENTCANCELLATION Or @DocType=@PAYMENTAMENDMENT
Begin
Select @VendorID = VendorID from Payments Where DocumentID = @DocRef
If @VendorID Is NULL
Select @FlexibleNumber = DocRef from Payments where DocumentID = @DocRef
Else
Select @FlexibleNumber = DocumentReference from Payments where DocumentID = @DocRef
End
Else If @DocType=@APVCANCELLATION Or @DocType=@APV Or @DocType=@APV_AMENDMENT
Begin
Select @FlexibleNumber = DocumentReference from APVAbstract where DocumentID=@DocRef
End
Else If @DocType=@ARVCANCELLATION Or @DocType=@ARV Or @DocType=@ARV_AMENDMENT
Begin
Select @FlexibleNumber = DocRef from ARVAbstract where DocumentID=@DocRef
End
Else If @DocType=@DEBITNOTECANCELLATION Or @DocType=@DEBITNOTE Or @DocType=@DEBITNOTEAMENDMENT
Begin
Select @FlexibleNumber = DocumentReference from DebitNote where DebitID=@DocRef
End
Else If @DocType=@CREDITNOTECANCELLATION Or @DocType=@CREDITNOTE Or @DocType=@CREDITNOTEAMENDMENT
Begin
Select @FlexibleNumber = DocumentReference from CreditNote where CreditID=@DocRef
End
Else If @DocType=@ISSUE_SPARES Or @DocType=@ISSUE_SPARES_CANCEL
Begin
Select @FlexibleNumber = DocRef from IssueAbstract where IssueID=@DocRef
End
Else If @DocType=@ISSUE_SPARES_RETURN
Begin
Select @FlexibleNumber = Max(DocRef) from IssueAbstract,IssueDetail,SparesReturnInfo
Where IssueAbstract.IssueID=IssueDetail.IssueID
And IssueDetail.SerialNo=SparesReturnInfo.SerialNo
And SparesReturnInfo.TransactionID = @DocRef
End
Else If @DocType=@SERVICE_INVOICE Or @DocType=@SERVICE_INVOICE_CANCEL
Begin
Select @FlexibleNumber = DocReference from ServiceInvoiceAbstract where ServiceInvoiceID=@DocRef
End
Else If @DocType=@SERVICE_INWARD Or @DocType=@SERVICE_INWARD_CANCEL
Begin
Select @FlexibleNumber = DocumentRef from ServiceAbstract where InvoiceID=@DocRef and ServiceType = 'Inward'
End
Else If @DocType=@SERVICE_OUTWARD Or @DocType=@SERVICE_OUTWARD_CANCEL
Begin
Select @FlexibleNumber = DocumentRef from ServiceAbstract where InvoiceID=@DocRef and ServiceType = 'Outward'
End
Else If @DocType = @DAMAGE_INVOICE
Begin
Select @FlexibleNumber = ActivityCode From DandDInvAbstract Where DandDInvID = @DocRef
End
Return IsNull(@FlexibleNumber,'')
End

