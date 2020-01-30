CREATE Procedure sp_acc_prn_getdrillCount(@DocRef Int, @DocType INT,@Info nvarchar(4000) = Null)
As

Declare @COLLECTIONS INT
Declare @DEPOSITS INT
Declare @BOUNCECHEQUE INT
Declare @REPOFBOUNCECHEQUE INT
Declare @PAYMENTS INT
Declare @PAYMENTCANCELLATION INT
Declare @AUTOENTRY INT
Declare @COLLECTIONCANCELLATION INT
Declare @MANUALJOURNAL INT

Declare @MANUALJOURNALCOLLECTIONS int
Declare @MANUALJOURNALPAYMENTS int
Declare @MANUALJOURNALOLDREF int

Declare @ARV INT
Declare @ARVCANCELLATION INT
Declare @APV INT
Declare @APVCANCELLATION INT
Declare @Count INT
Declare @ARV_AMENDMENT INT
Declare @APV_AMENDMENT INT
Declare @PAYMENT_AMENDMENT INT
Declare @COLLECTIONAMENDMENT INT

Set @COLLECTIONS = 13
Set @DEPOSITS =14
Set @BOUNCECHEQUE = 15
Set @REPOFBOUNCECHEQUE = 16
Set @PAYMENTS = 17
Set @PAYMENTCANCELLATION = 18
Set @AUTOENTRY = 19
Set @COLLECTIONCANCELLATION = 25
Set @MANUALJOURNAL = 26

Set @MANUALJOURNALCOLLECTIONS =32
Set @MANUALJOURNALPAYMENTS =33
Set @MANUALJOURNALOLDREF =37

Set @APV =46
Set @APVCANCELLATION =47
Set @ARV = 48
Set @ARVCANCELLATION =49
Set @Count=0

Set @ARV_AMENDMENT = 83    
Set @APV_AMENDMENT = 84    

Set @PAYMENT_AMENDMENT =  78    
Set @COLLECTIONAMENDMENT = 77    

set dateformat dmy

If @DocType= @COLLECTIONS OR @DocType=@COLLECTIONCANCELLATION OR @DocType= @MANUALJOURNALCOLLECTIONS or @Doctype = @COLLECTIONAMENDMENT
Begin
	select @Count=Count(*) from CollectionDetail where CollectionID=@DocRef
End
Else If @DocType= @DEPOSITS or @DocType=@REPOFBOUNCECHEQUE
Begin
	select @Count=count(*) from Collections where DepositID=@DocRef
End
Else If @DocType= @BOUNCECHEQUE
Begin
		select @Count=count(*) from CollectionDetail,Collections where 
		CollectionID=@DocRef and Collections.DocumentID=CollectionDetail.CollectionID 
End

Else If @DocType= @PAYMENTS or @DocType= @AUTOENTRY or @DocType= @PAYMENTCANCELLATION
	OR @DocType= @MANUALJOURNALPAYMENTS or @DocType= @PAYMENT_AMENDMENT
Begin
	select @Count=Count(*) from PaymentDetail where PaymentID=@DocRef
End
Else if @DocType = @MANUALJOURNALOLDREF
Begin

	Select @Count=Count(*) from GeneralJournal where TransactionID=@DocRef and DocumentType not in (36,37) --36 is diplay entry in manual journal form
End
Else IF @DocType = @ARV OR @DocType = @ARVCANCELLATION or @DocType = @ARV_AMENDMENT
Begin
	select @Count=Count(*) from ARVDetail where DocumentID=@DocRef

End
Else IF @DocType = @APV OR @DocType = @APVCANCELLATION or @DocType = @APV_AMENDMENT
Begin
	select @Count=Count(*) from APVDetail where DocumentID=@DocRef
End
Select @Count







































