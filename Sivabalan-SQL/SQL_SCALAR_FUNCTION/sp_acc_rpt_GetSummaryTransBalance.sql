CREATE Function sp_acc_rpt_GetSummaryTransBalance
(
 @AccID INT,
 @DocRef INT,
 @DocTyp INT,
 @AmdFlag INT
)
Returns Decimal(18,6)
AS
Begin
Declare @Balance Decimal(18,6),@DrBalance Decimal(18,6),@CrBalance Decimal(18,6)

Declare @INVOICE INT
Declare @INVOICEAMENDMENT INT
Declare @INVOICECANCELLATION INT
Declare @BILL INT
Declare @BILLAMENDMENT INT
Declare @BILLCANCELLATION INT
Declare @DEBITNOTE INT
Declare @DEBITNOTE_AMENDMENT INT
Declare @DEBITNOTECANCELLATION INT
Declare @CREDITNOTE INT
Declare @CREDITNOTE_AMENDMENT INT
Declare @CREDITNOTECANCELLATION INT
 
Set @INVOICE = 4
Set @INVOICEAMENDMENT = 5
Set @INVOICECANCELLATION = 6
Set @BILL = 8
Set @BILLAMENDMENT = 9
Set @BILLCANCELLATION = 10
Set @DEBITNOTE = 20
Set @DEBITNOTE_AMENDMENT = 91
Set @DEBITNOTECANCELLATION = 64
Set @CREDITNOTE = 21
Set @CREDITNOTE_AMENDMENT = 90
Set @CREDITNOTECANCELLATION = 65

If @DocTyp=@INVOICE Or (@DocTyp=@INVOICEAMENDMENT And @AmdFlag = 1)
 Begin
  Select @DrBalance = Sum(Debit-Credit) From GeneralJournal
  Where AccountID = @AccID And DocumentType = @DEBITNOTE
  And DocumentReference In (Select ReferenceID from AdjustmentReference 
  Where InvoiceID = @DocRef And TransactionType = 0 And DocumentType = 5)

  Select @CrBalance = Sum(Debit-Credit) From GeneralJournal
  Where AccountID = @AccID And DocumentType = @CREDITNOTE
  And DocumentReference In (Select ReferenceID from AdjustmentReference 
  Where InvoiceID = @DocRef And TransactionType = 0 And DocumentType = 2)

  Set @Balance = IsNULL(@DrBalance,0)+IsNULL(@CrBalance,0)
 End
Else If @DocTyp=@INVOICECANCELLATION Or (@DocTyp=@INVOICEAMENDMENT And @AmdFlag = 2)
 Begin
  Select @DrBalance = Sum(Debit-Credit) From GeneralJournal
  Where AccountID = @AccID And DocumentType = @DEBITNOTECANCELLATION
  And DocumentReference In (Select ReferenceID from AdjustmentReference 
  Where InvoiceID = @DocRef And TransactionType = 0 And DocumentType = 5)

  Select @CrBalance = Sum(Debit-Credit) From GeneralJournal
  Where AccountID = @AccID And DocumentType = @CREDITNOTECANCELLATION
  And DocumentReference In (Select ReferenceID from AdjustmentReference 
  Where InvoiceID = @DocRef And TransactionType = 0 And DocumentType = 2)

  Set @Balance = IsNULL(@DrBalance,0)+IsNULL(@CrBalance,0)
 End
Else If @DocTyp=@BILL Or (@DocTyp=@BILLAMENDMENT And @AmdFlag = 2)
 Begin
  Select @DrBalance = Sum(Debit-Credit) From GeneralJournal
  Where AccountID = @AccID And DocumentType = @DEBITNOTE
  And DocumentReference In (Select ReferenceID from AdjustmentReference 
  Where InvoiceID = @DocRef And TransactionType = 1 And DocumentType = 2)

  Select @CrBalance = Sum(Debit-Credit) From GeneralJournal
  Where AccountID = @AccID And DocumentType = @CREDITNOTE
  And DocumentReference In (Select ReferenceID from AdjustmentReference 
  Where InvoiceID = @DocRef And TransactionType = 1 And DocumentType = 5)

  Set @Balance = IsNULL(@DrBalance,0)+IsNULL(@CrBalance,0)
 End
Else If @DocTyp=@BILLCANCELLATION Or (@DocTyp=@BILLAMENDMENT And @AmdFlag = 1)
 Begin
  Select @DrBalance = Sum(Debit-Credit) From GeneralJournal
  Where AccountID = @AccID And DocumentType = @DEBITNOTECANCELLATION
  And DocumentReference In (Select ReferenceID from AdjustmentReference 
  Where InvoiceID = @DocRef And TransactionType = 1 And DocumentType = 2)

  Select @CrBalance = Sum(Debit-Credit) From GeneralJournal
  Where AccountID = @AccID And DocumentType = @CREDITNOTECANCELLATION
  And DocumentReference In (Select ReferenceID from AdjustmentReference 
  Where InvoiceID = @DocRef And TransactionType = 1 And DocumentType = 5)

  Set @Balance = IsNULL(@DrBalance,0)+IsNULL(@CrBalance,0)
 End

Return IsNULL(@Balance,0)
End

