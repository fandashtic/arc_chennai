
CREATE procedure sp_insert_collectiondetail
(
	@CollectionID integer,    
	@DocumentID integer,		
	@DocumentType integer,    
	@DocumentDate datetime,    
	@PaymentDate datetime,    
	@AdjustedAmount Decimal(18,6),     
	@OriginalID nvarchar(255),    
	@DocumentValue Decimal(18,6),    
	@ExtraAmount Decimal(18,6),    
	@FullyAdjust int = 0,    
	@Adjustment Decimal(18,6) = 0,    
	@DocRef nvarchar(125) = N'',    
	@Discount Decimal(18,6) = 0,
	@Flag integer = 0,
	@InvoiceID int = 0
) 
As
Begin
	Declare @Bal Decimal(18,6), @TmpChqCollDebitBal Decimal(18,6), @ChqCollDebitID Int
	Declare @ChqCollDebitVal Decimal(18,6), @ChqCollDebitBal Decimal(18,6)
	Declare @DebitOrigRef nvarchar(128), @DebitDocRef nvarchar(125)
	Declare @OriginalDocID nvarchar(128)

	Declare @tempdocid int

	-- The Cash invoice Docreference value updated in collectiondetail
	-- while creation of implicit collection 
	If (@DocumentType = 1 or @DocumentType = 4) And @DocRef = ''
	Begin
		Select @DocRef = IsNull(DocReference,'') from InvoiceAbstract Where InvoiceID = @DocumentID
	End
	
	Set @Bal = 0
	If @DocumentType = 4
	Begin
		Select @Bal=IsNull(Balance,0) From InvoiceAbstract Where InvoiceID = @DocumentID 
		select @OriginalDocID =  Case IsNULL(GSTFlag ,0) When 0 then (vp.Prefix+convert(Nvarchar,DocumentID)) Else IsNULL(GSTFullDocID,'') End 
		from InvoiceAbstract,VoucherPrefix vp,VoucherPrefix ivp Where vp.TranID='INVOICE' And ivp.TranID='INVOICE AMENDMENT' And InvoiceID = @DocumentID   
	End
	Else If @DocumentType = 5
		Select @Bal=IsNull(Balance,0) From DebitNote Where DebitID = @DocumentID  

	If (@DocumentType = 4 or @DocumentType = 5) And (@Bal < (@AdjustedAmount + @Adjustment))
	Begin
		Select @ChqCollDebitBal=IsNull(Sum(dn.Balance),0) 
		From Collections cl, ChequeCollDetails ccd, DebitNote dn 
		Where ccd.DocumentID = @DocumentID And ccd.DocumentType = @DocumentType And ccd.CollectionID = cl.DocumentID 
		And IsNull(cl.Status, 0) & 192 = 0 And IsNull(ccd.DebitID, 0) = dn.DebitID

		If @ChqCollDebitBal > 0
		Begin
			If @ChqCollDebitBal < ((@AdjustedAmount + @Adjustment)-@Bal)
			Begin
				Select 0
				Goto ZeroBal  
			End
			Else
			Begin
				Set @ChqCollDebitBal = 0
				Set @TmpChqCollDebitBal = ((@AdjustedAmount + @Adjustment)-@Bal)

				While @TmpChqCollDebitBal > 0
				Begin
					Select Top 1 @ChqCollDebitID = dn.DebitID, @ChqCollDebitVal = IsNull(dn.NoteValue, 0), 
					@ChqCollDebitBal=IsNull(dn.Balance,0) 
					From Collections cl, ChequeCollDetails ccd, DebitNote dn 
					Where ccd.DocumentID = @DocumentID And ccd.DocumentType = @DocumentType And ccd.CollectionID = cl.DocumentID 
					And IsNull(cl.Status, 0) & 192 = 0 And IsNull(ccd.DebitID, 0) = dn.DebitID And dn.Balance > 0

					If @ChqCollDebitBal > @TmpChqCollDebitBal
						Set @ChqCollDebitBal = @TmpChqCollDebitBal

					If @Flag=1
						Select @DebitOrigRef=(dvp.Prefix+convert(Nvarchar,DocumentID)), @DebitDocRef=case IsNull(DocSerialType,'') when '' then DocumentReference else DocSerialType+'-'+DocumentReference end     
						From DebitNote, VoucherPrefix dvp where DebitID=@ChqCollDebitID And dvp.TranID='DEBIT NOTE'    

					Insert InTo CollectionDetail(CollectionID, DocumentID, DocumentType, DocumentDate, PaymentDate, 
					AdjustedAmount, OriginalID, DocumentValue, ExtraCollection, Adjustment, DocRef, Discount)    
					values (@CollectionID, @ChqCollDebitID, 5, @DocumentDate, @PaymentDate, @ChqCollDebitBal, 
					@DebitOrigRef, @ChqCollDebitVal, 0, 0, @DebitDocRef, 0)

					Update DebitNote Set Balance = Balance - @ChqCollDebitBal where DebitID = @ChqCollDebitID and Balance - @ChqCollDebitBal >= 0 
					Set @TmpChqCollDebitBal = @TmpChqCollDebitBal - @ChqCollDebitBal
					Set @ChqCollDebitVal = 0
					Set @ChqCollDebitBal = 0
					Set @DebitOrigRef = ''
					Set @DebitDocRef = ''
				End
				Set @AdjustedAmount = (@Bal - @Adjustment)
			End
		End
		Else
		Begin
			Select 0
			Goto ZeroBal  
		End
	End  

	If IsNull(@DocumentType,0) = 10
	Begin
		If (@AdjustedAmount + @Adjustment) > 0
		Begin
			Insert InTo CollectionDetail(     
				CollectionID,    
				DocumentID,    
				DocumentType,    
				DocumentDate,    
				PaymentDate,    
				AdjustedAmount,    
				OriginalID,    
				DocumentValue,    
				ExtraCollection,    
				Adjustment,    
				DocRef,    
				Discount, InvoiceID)
			values    
				(@CollectionID,    
				@DocumentID,    
				@DocumentType,    
				@DocumentDate,    
				@PaymentDate,    
				@AdjustedAmount,    
				@OriginalID,    
				@DocumentValue,    
				@ExtraAmount,    
				@Adjustment,    
				@DocRef,    
				@Discount
				, @InvoiceID) 
		End
	End
	Else If IsNull(@DocumentType,0) = 4
	Begin
		If (@AdjustedAmount + @Adjustment) > 0
		Begin
			Insert InTo CollectionDetail(     
				CollectionID,    
				DocumentID,    
				DocumentType,    
				DocumentDate,    
				PaymentDate,    
				AdjustedAmount,    
				OriginalID,    
				DocumentValue,    
				ExtraCollection,    
				Adjustment,    
				DocRef,    
				Discount, InvoiceID)
			values    
				(@CollectionID,    
				@DocumentID,    
				@DocumentType,    
				@DocumentDate,    
				@PaymentDate,    
				@AdjustedAmount,    
				--@OriginalID,    
				@OriginalDocID,
				@DocumentValue,    
				@ExtraAmount,    
				@Adjustment,    
				@DocRef,    
				@Discount
				, @InvoiceID) 
		End
	End
	Else
		If (@AdjustedAmount + @Adjustment) > 0
		Begin
			Insert InTo CollectionDetail(     
				CollectionID,    
				DocumentID,    
				DocumentType,    
				DocumentDate,    
				PaymentDate,    
				AdjustedAmount,    
				OriginalID,    
				DocumentValue,    
				ExtraCollection,    
				Adjustment,    
				DocRef,    
				Discount)
			values    
				(@CollectionID,    
				@DocumentID,    
				@DocumentType,    
				@DocumentDate,    
				@PaymentDate,    
				@AdjustedAmount,    
				@OriginalID,    
				@DocumentValue,    
				@ExtraAmount,    
				@Adjustment,    
				@DocRef,    
				@Discount) 
		End

	If (Select PaymentMode From Collections Where DocumentID = @CollectionID) = 1
	--BEGIN
--		If @DocumentType = 5 
--		BEGIN
--			If (Select count(*) from ChequeCollDetails Where DebitID = @DocumentID and Documenttype=4) >= 1
--			BEGIN
--						Select @tempdocid = DocumentID from ChequeCollDetails Where DebitID = @DocumentID and Documenttype=4
--						Insert Into ChequeCollDetails (CollectionID, DocumentID, DocumentType, CreationDate, 
--						ModifiedDate) Values (@CollectionID, @tempdocid, 4, GetDate(), GetDate())
--						
--			END
--		END
--		ELSE
		BEGIN
		Insert Into ChequeCollDetails (CollectionID, DocumentID, DocumentType, CreationDate, 
		ModifiedDate) Values (@CollectionID, @DocumentID, @DocumentType, GetDate(), GetDate())
		END
	--END
	/* Start Comment */  
	/* 1. If @Adjustment<0 We have to subtract sum of adjusted and additional adjustemnt amount  
	from invoices and debit note.    
	   2. @Adjustment is set nehative only for Invoices and Debit Note  
	   3. If @Adjustment<0 then @ExtraAmount is Zero always.    
	*/  
	If @Adjustment<0 And @ExtraAmount=0  
		Set @AdjustedAmount=@AdjustedAmount+Abs(@Adjustment)  
	/* End of Comment */  

	/*for invoicewise collections*/
	If @Flag=1
		Set @AdjustedAmount=@AdjustedAmount+Abs(@Adjustment)

	If @DocumentType = 1 or @DocumentType = 4    
	Begin    
		If @FullyAdjust = 1     
		Begin    
			Update InvoiceAbstract Set Balance = 0 Where InvoiceID = @DocumentID And    
			Balance - @AdjustedAmount >= 0    
		End    
		Else    
		Begin
			Update InvoiceAbstract set Balance = Balance - @AdjustedAmount 
			Where InvoiceID = @DocumentID And Balance - @AdjustedAmount >= 0    
		End    
	End
	Else If @DocumentType = 2    
	Begin    
		If @FullyAdjust = 1    
		Begin    
			Update CreditNote Set Balance = 0 Where CreditID = @DocumentID And    
			Balance - @AdjustedAmount >= 0    
		End    
		Else    
		Begin    
			Update CreditNote set Balance = Balance - @AdjustedAmount    
			where CreditID = @DocumentID and Balance - @AdjustedAmount >= 0    
		End    
	End  
	Else If @DocumentType = 10    
	Begin    
		If @FullyAdjust = 1    
		Begin    
			Update CreditNote Set Balance = 0 Where CreditID = @DocumentID And    
			Balance - @AdjustedAmount >= 0    
		End    
		Else    
		Begin    
			Update CreditNote set Balance = Balance - @AdjustedAmount    
			where CreditID = @DocumentID and Balance - @AdjustedAmount >= 0    
		End    
	End    
	Else If @DocumentType = 3    
	Begin    
		If @FullyAdjust = 1    
		Begin    
			Update Collections Set Balance = 0 Where DocumentID = @DocumentID And    
			Balance - @AdjustedAmount >= 0    
		End    
		Else    
		Begin    
			Update Collections set Balance = Balance - @AdjustedAmount    
			where DocumentID = @DocumentID and Balance - @AdjustedAmount >= 0    
		End    
	End    
	Else If @DocumentType = 5    
	Begin    
		If @FullyAdjust = 1    
		Begin    
			Update DebitNote Set Balance = 0 Where DebitID = @DocumentID And    
			Balance - @AdjustedAmount >= 0    
		End    
		Else    
		Begin    
			Update DebitNote set Balance = Balance - @AdjustedAmount    
			where DebitID = @DocumentID and Balance - @AdjustedAmount >= 0    
		End    
	End    
	Else If @DocumentType = 6    
	Begin    
		If @FullyAdjust = 1     
		Begin    
			Update InvoiceAbstract Set Balance = 0 Where InvoiceID = @DocumentID And    
			Balance - @AdjustedAmount >= 0    
		End    
		Else    
		Begin    
			Update InvoiceAbstract set Balance = Balance - @AdjustedAmount    
			where InvoiceID = @DocumentID and Balance - @AdjustedAmount >= 0    
		End    
	End    
	Else If @DocumentType = 7    
	Begin    
		If @FullyAdjust = 1     
		Begin   
			Update InvoiceAbstract Set Balance = 0 Where InvoiceID = @DocumentID And    
			Balance - @AdjustedAmount >= 0    
		End    
		Else    
		Begin    
			Update InvoiceAbstract set Balance = Balance - @AdjustedAmount    
			where InvoiceID = @DocumentID and Balance - @AdjustedAmount >= 0    
		End    
	End
	  
	Select @@RowCount
ZeroBal:
End
