Create Procedure mERP_sp_MapCollnSalesmanBeat(
				@SalesmanID Int,
				@BeatID Int,
				@InvoiceID nVarchar(4000),
				@UserName nVarchar(200)
				)
As
Begin
	
	Declare @InvID As Int
	Declare @Error As Int
	Declare @DocumentID As Int
		
	Create Table #tmpInvID(InvID Int)

	Insert InTo #tmpInvID Select * From dbo.sp_SplitIn2Rows(@InvoiceID,N',')   

	Declare Cur_Inv Cursor For
	Select InvID From  #tmpInvID
	Open Cur_Inv
	Fetch  From Cur_Inv Into  @InvID
	While @@Fetch_Status = 0
	Begin
		Set @DocumentID = 0
		Select @DocumentID = isNull(DocumentID,0) From InvoiceAbstract Where InvoiceID = @InvID
		If Exists(Select * From  tbl_mERP_DSOSTransfer Where InvoiceDocumentID = @DocumentID)
		Begin
			Update tbl_mERP_DSOSTransfer Set InvoiceID = @InvID, MappedSalesmanID = @SalesmanID ,MappedBeatID = @BeatID,
			ModifiedDate = GetDate() ,Active = 1 ,UserName = @UserName Where 
			InvoiceDocumentID = @DocumentID
		End
		Else
		Begin
			Insert Into	tbl_mERP_DSOSTransfer(InvoiceID,InvoiceDocumentID,InvoiceSalesmanID,InvoiceBeatID,MappedSalesmanID,MappedBeatID,
							Active,	CreationDate,UserName)
			Select IA.InvoiceID,IA.DocumentID,IA.SalesmanID,IA.BeatID,@SalesmanID,@BeatID,1,GetDate(),@UserName
			From InvoiceAbstract IA Where IA.InvoiceID = @InvID
		End
		

		--To handle Error
		Select @Error =  @@Error
		If @Error > 0
			GoTo HandleErr
		
		
		Fetch Next From Cur_Inv Into  @InvID
	End

HandleErr:
	Close Cur_Inv
	Deallocate Cur_Inv
	Drop Table #tmpInvID
	If @Error > 0
		Select 0
	Else
		Select 1

		

End

