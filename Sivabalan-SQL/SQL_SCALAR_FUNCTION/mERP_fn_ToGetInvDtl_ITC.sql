CREATE Function mERP_fn_ToGetInvDtl_ITC(
	@DocumentID nVarchar(50), 
	@Type Int 
	)    
Returns nVarchar(Max)
As    
Begin 
	Declare @RetVal nVarchar(Max) 
	Declare @PCR As nVarchar(5)   
	Declare @DocID nVarchar(50)
	Declare @DocRef nVarchar(50)
	Declare @InvDate nVarchar(50)
	Declare @CDocID nVarchar(Max)
	Declare @CDocRef nVarchar(Max)
	Declare @CInvDate nVarchar(Max)	
	Declare @Counter Int

	Set @CDocID = ''
	Set @CDocRef = ''
	Set @CInvDate = ''
	Set @Counter = 1 

	Select @PCR = Prefix From VoucherPrefix
	Where TranID = 'INVOICE' 

	Declare InvDtl Cursor For 
		Select @PCR + Cast(DocumentID As nVarchar), DocReference, Convert(nVarchar, InvoiceDate, 103) 
		From InvoiceAbstract Where (AdjRef Like '%' + @DocumentID + '' Or AdjRef Like '%' + @DocumentID + ',%' ) And IsNull(Status, 0) & 192 = 0 
	Open InvDtl
	Fetch From InvDtl InTo @DocID, @DocRef, @InvDate 
	While @@Fetch_Status = 0        
	Begin        
		If @Counter = 1
		Begin
			Set @CDocID = @DocID
			Set @CDocRef = @DocRef
			Set @CInvDate = @InvDate 
		End
		Else
		Begin
			Set @CDocID = @CDocID + ', ' + @DocID
			Set @CDocRef = @CDocRef + ', ' + @DocRef
			Set @CInvDate = @CInvDate + ', ' + @InvDate
		End
		
		Set @Counter = 0 

		Fetch Next From InvDtl InTo @DocID, @DocRef, @InvDate 
	End 

	If @Type = 1
		Set @RetVal = @CDocID 
	If @Type = 2
		Set @RetVal = @CDocRef 
	If @Type = 3 
		Set @RetVal = @CInvDate 

	Return @RetVal 
End
