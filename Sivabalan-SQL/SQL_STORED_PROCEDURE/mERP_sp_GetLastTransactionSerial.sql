Create Procedure mERP_sp_GetLastTransactionSerial(@TranType int,@DocType nvarchar(100),@DocRef nVarchar(200))
as
Begin
	Declare @TranSerialNo nvarchar(200)
	Declare @Cnt as Int
	

	
	If @DocType <> ''
	Begin
		Select  @Cnt = Count(*) From InvoiceAbstract Where DocSerialType = @DocType And DocReference = @DocRef
		While @Cnt <> 0
		Begin
			Select @TranSerialNo = dbo.fn_GetTransactionSerial(@TranType,@DocType,-1)
			Select  @Cnt = Count(*) From InvoiceAbstract Where DocSerialType = @DocType And DocReference = @TranSerialNo
			if @Cnt <> 0
				Update TransactionDocNumber Set LastCount = LastCount + 1 Where TransactionType = @TranType And DocumentType = @DocType
		End
		Select @TranSerialNo
	End
	Else
	Begin
		Select  @Cnt = Count(*) From InvoiceAbstract Where DocSerialType = '' And DocReference = @DocRef
		While @cnt <> 0 
		Begin
			Select @TranSerialNo = dbo.mERP_fn_GetLastDocRef(@DocRef)
			Select  @Cnt = Count(*) From InvoiceAbstract Where DocSerialType = '' And DocReference = @TranSerialNo
			Set @DocRef = @TranSerialNo	
		End
		Select @TranSerialNo
	End
End

