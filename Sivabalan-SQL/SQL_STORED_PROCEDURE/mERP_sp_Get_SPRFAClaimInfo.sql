Create Procedure mERP_sp_Get_SPRFAClaimInfo(@Status Int)
As
Begin
--	Declare @Status Int
--	Set @Status = 1
	Declare @ProcessDate As DateTime
	Declare @SchemeID Int
	Declare @RecdSchID nVarchar(255)
	Declare @SchDescription nVarchar(255)
	Declare @SchemeType Int
	Declare @ActiveFrom DateTime
	Declare @ActiveTo DateTime
	Declare @ExpiryDate DateTime
	Declare @SchFrom DateTime
	Declare @SchTo DateTime
	Declare @InvoiceID Int
	Declare @SchemeDetail nVarchar(255)
	Declare @FlagWord Int
	Declare @SalePrice Decimal(18, 6)
	Declare @Quantity Int
	Declare @Serial Int
	Declare @CrNoteID Int
	Declare @AdjAmount Decimal(18, 6)
	Declare @CustomerID nVarchar(255)
	Declare @Amount Decimal(18,6)
	Declare @PayoutID Int
	Declare @PayID Int 
	Declare @InvoiceType Int
	Declare @InvPrefix nVarchar(10)
	Declare @InvRebateValue Decimal(18,6)
	Declare @SRRebateValue Decimal(18,6)
	Declare @BillRef nVarchar(255)
	Declare @RefNo nVarchar(255)		

	Create Table #tmpAbstract(InvoiceID Int, BillRef  nVarchar(255), ReferenceNumber nVarchar(255), SchemeID Int, SlabID Int, SchAmt Decimal(18,6), SchPer Decimal(18,6), Serial Int, PayoutID Int )
	Create Table #Abstract(InvoiceID Int, SchemeID Int, SlabID Int, SchAmt Decimal(18,6), SchPer Decimal(18,6), Serial Int, PayoutID Int  )

	Create Table #tmpDetail (InvoiceID Int, BillRef  nVarchar(255),ReferenceNumber nVarchar(255), InvoiceType Int, MultipleSchemeDetails nVarchar(255), FlagWord Int, 
			Quantity Decimal(18,6), SalesValue Decimal(18, 6), Serial Int, Amount Decimal(18,6), PayoutID Int)

	Create Table #tmpSchemeDetail(SchemeID Int, CSSchemeID Int, ActivityCode nVarchar(255), Description nVarchar(255),
		SchemeFrom DateTime, SchemeTo DateTime, PayoutFrom DateTime, PayoutTo DateTime, ExpiryDate Datetime, RFAValue Decimal(18, 6), PayoutID Int)
	
	If (Select IsNull(Flag, 0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') > 0
		Select @ProcessDate =  DateAdd(Day,1,LastInventoryUpload) From Setup
	Else
		Select @ProcessDate = Case IsNull(Max(InvoiceDate),'') 
			When '' Then GETDATE() 
			Else Max(InvoiceDate) End
			From InvoiceAbstract 
			Where InvoiceType In (1,3,4) 
			And (Status & 128)= 0

	Select @InvPrefix = Prefix From VoucherPrefix Where TranID = 'INVOICE'
	If @Status = 1	
	Begin
		--Select Trade Schemes detail
		Insert Into #tmpSchemeDetail Select Distinct SA.SchemeID, SA.CS_SchemeID, SA.ActivityCode, SA.Description,
			SA.SchemeFrom, SA.SchemeTo, SPP.PayoutPeriodFrom, SPP.PayoutPeriodTo, SA.ExpiryDate, 0, SPP.ID 
			From tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemeOutlet SO, tbl_mERP_SchemePayoutPeriod SPP
			Where SA.SchemeID = SO.SchemeID
			And SA.SchemeType = 1
			And SO.QPS = 0
			And SA.Active = 1
			And IsNull(SPP.ClaimRFA,0) = 0	
			And SA.RFAApplicable = 1
			And SA.SchemeID = SPP.SchemeID
			And dbo.StripTimeFromDate(SPP.PayoutPeriodTo) < dbo.StripTimeFromDate(@ProcessDate) 
			
			--And	dbo.StripTimeFromDate(ExpiryDate) < dbo.StripTimeFromDate(@ProcessDate) 

		/*Non QPS Schemes which are not claimed - Start*/
		Declare SchemeCur Cursor For 
			Select SchemeID, PayoutFrom, PayoutTo, ExpiryDate, PayoutID From  #tmpSchemeDetail
		Open SchemeCur 
		Fetch Next From SchemeCur Into @SchemeID, @ActiveFrom, @ActiveTo, @ExpiryDate, @PayoutID
		While (@@Fetch_Status=0)
		Begin
			/*Item based and Invoice based Free Qty schemes*/
			Insert Into #TmpDetail 
				Select IA.InvoiceId, @InvPrefix + Cast(IA.DocumentID as nVarchar) as BillRef, 
				IA.ReferenceNumber,IA.InvoiceType, ID.MultipleSchemeDetails, ID.FlagWord,	ID.Quantity, ID.SalePrice, ID.Serial, ID.Quantity * (ID.PTR + ID.PTR * (ID.TaxCode/100)),
				@PayoutID 
				From InvoiceAbstract IA, InvoiceDetail ID
				Where IA.InvoiceID = ID.InvoiceID
				And IA.InvoiceType In (1,3,4)        
				And (IA.Status & 128)=0          
				--And dbo.StripTimeFromDate(IA.InvoiceDate) Between dbo.StripTimeFromDate(@ActiveFrom) And  dbo.StripTimeFromDate(@ActiveTo)
				And (Case IA.InvoiceType
					When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID = 
						IA.DocumentID
						And InvoiceType = 1)
					Else dbo.StripTimeFromDate(IA.InvoiceDate)
					End) Between dbo.StripTimeFromDate(@ActiveFrom) And  dbo.StripTimeFromDate(@ActiveTo)
				And (Case IA.InvoiceType 
					When 4 Then
						@ActiveTo
					Else
						dbo.StripTimeFromDate(IA.CreationTime) 						
					End ) <= dbo.StripTimeFromDate(@ExpiryDate)
				And ID.MultipleSchemeDetails <> ''
				Order By IA.InvoiceID

			Insert Into #TmpDetail 
				Select IA.InvoiceId, @InvPrefix + Cast(IA.DocumentID as nVarchar) as BillRef, 
				IA.ReferenceNumber,IA.InvoiceType, ID.MultipleSplCategorySchDetail, ID.FlagWord,	ID.Quantity, ID.SalePrice, ID.Serial, ID.Quantity * (ID.PTR + ID.PTR * (ID.TaxCode/100)),
				@PayoutID  
				From InvoiceAbstract IA, InvoiceDetail ID
				Where IA.InvoiceID = ID.InvoiceID
				And IA.InvoiceType In (1,3,4)        
				And (IA.Status & 128)=0          
				--And dbo.StripTimeFromDate(IA.InvoiceDate) Between dbo.StripTimeFromDate(@ActiveFrom) And  dbo.StripTimeFromDate(@ActiveTo)
				And (Case IA.InvoiceType
					When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID = 
						IA.DocumentID
						And InvoiceType = 1)
					Else dbo.StripTimeFromDate(IA.InvoiceDate)
					End) Between dbo.StripTimeFromDate(@ActiveFrom) And  dbo.StripTimeFromDate(@ActiveTo)
				And (Case IA.InvoiceType 
					When 4 Then
						@ActiveTo
					Else
						dbo.StripTimeFromDate(IA.CreationTime) 						
					End ) <= dbo.StripTimeFromDate(@ExpiryDate)
				And ID.MultipleSplCategorySchDetail <> ''
				Order By IA.InvoiceID

			/*Invoice based Amt(Or)Per scheme*/							
			Insert Into #tmpDetail 
				Select IA.InvoiceId,@InvPrefix + Cast(IA.DocumentID as nVarchar) as BillRef, 
				IA.ReferenceNumber,IA.InvoiceType, IA.MultipleSchemeDetails,0,0,0,0,0, @PayoutID  
				From InvoiceAbstract IA
				Where IA.InvoiceType In (1,3,4)        
				And (IA.Status & 128)=0          
				And dbo.StripTimeFromDate(IA.InvoiceDate) Between dbo.StripTimeFromDate(@ActiveFrom) And  dbo.StripTimeFromDate(@ActiveTo)
				And (Case IA.InvoiceType 
					When 4 Then
						@ActiveTo
					Else
						dbo.StripTimeFromDate(IA.CreationTime) 						
					End ) <= dbo.StripTimeFromDate(@ExpiryDate)
				And IA.MultipleSchemeDetails <> ''
				Order By IA.InvoiceID
			Begin
				/*Get Scheme cost for the selected schemes*/
				Declare InvoiceCur Cursor For 
					Select Distinct InvoiceID, BillRef, ReferenceNumber, InvoiceType, MultipleSchemeDetails, FlagWord, SalesValue, Quantity, Serial, Amount, PayoutID From #tmpDetail
				Open InvoiceCur
				Fetch Next From InvoiceCur Into @InvoiceID, @BillRef, @RefNo, @InvoiceType, @SchemeDetail, @FlagWord, @SalePrice, @Quantity, @Serial, @Amount, @PayID
				While (@@Fetch_Status=0)
				Begin
					If @FlagWord =1
					Begin
						Insert Into #tmpAbstract Select InvoiceID, @BillRef, @RefNo, SchemeID, SlabID, 
									Case @InvoiceType
										When 4 Then (-1) * @Amount
										Else @Amount 
										End, 
									SchPer, @Serial, @PayID
						From dbo.mERP_fn_GetInvSchemeDetail(@InvoiceID, @SchemeDetail, @FlagWord, @SalePrice, @Quantity) 
						Where SchemeID = @SchemeID 
					End
					Else
						Insert Into #tmpAbstract Select InvoiceID, @BillRef, @RefNo, SchemeID, SlabID, 
									Case @InvoiceType
										When 4 Then (-1) * SchAmt
										Else SchAmt
										End, 
									SchPer, @Serial, @PayID
						From dbo.mERP_fn_GetInvSchemeDetail(@InvoiceID, @SchemeDetail, @FlagWord, @SalePrice, @Quantity) 
						Where SchemeID = @SchemeID 

					Fetch Next From InvoiceCur Into @InvoiceID,@BillRef,@RefNo, @InvoiceType, @SchemeDetail, @FlagWord, @SalePrice, @Quantity, @Serial, @Amount, @PayID
				End
				Close InvoiceCur
				Deallocate InvoiceCur
			End
			Fetch Next From SchemeCur Into @SchemeID, @ActiveFrom, @ActiveTo, @ExpiryDate, @PayoutID
		End
		Close SchemeCur
		Deallocate SchemeCur	
		/*Non QPS Schemes which are not claimed - End*/

		Declare SRCursor Cursor For
			Select Distinct InvoiceID, BillRef From #tmpAbstract --Where InvoiceType = 1 And FlagWord = 0
		Open SRCursor
		Fetch Next From SRCursor Into @InvoiceID, @BillRef
		While (@@Fetch_Status = 0)
		Begin
			Set @InvRebateValue = 0
			Set @SRRebateValue = 0

			/*Invoice Rebate value*/
			Select @InvRebateValue = Sum(SchAmt) From #tmpAbstract Where InvoiceID = @InvoiceID
			/*Sales Return Rebate value against the invoice*/
			Select @SRRebateValue = Sum(SchAmt) From #tmpAbstract Where ReferenceNumber = @BillRef

			If (@InvRebateValue + @SRRebateValue) < = 0 
			Begin

				Delete From #tmpAbstract Where InvoiceID = @InvoiceID Or ReferenceNumber = @BillRef
				--Select * From #RFAInfo Where InvoiceID = @InvoiceID Or ReferenceNumber = @BillRef
			End
			Fetch Next From SRCursor Into @InvoiceID, @BillRef
		End
		Close SRCursor	
		Deallocate SRCursor


		/*QPS Schemes for which Cr.Note generated - Start*/
		Declare @NoteValue as Decimal(18,6)
		Declare SchemeCur Cursor For 
			Select SA.SchemeID, SA.Description, SA.CS_RecSchID, SPP.PayoutPeriodFrom, SPP.PayoutPeriodTo, SA.ExpiryDate, SPP.ID
				From tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemePayoutPeriod SPP
				Where SA.Active = 1
				And SA.RFAApplicable = 1
				--And IsNull(SA.CrNoteRaised, 0) = 1
				And SA.SchemeType = 1	
				And SA.SchemeID = SPP.SchemeID
				And IsNull(SPP.ClaimRFA,0) = 0	
				And (SPP.Status & 128) = 128				

		Open SchemeCur 
		Fetch Next From SchemeCur Into @SchemeID, @SchDescription, @RecdSchID, @ActiveFrom, @ActiveTo, @ExpiryDate, @PayoutID
		While (@@Fetch_Status=0)
		Begin

			If Exists(Select CreditID From CreditNote Where  PayoutID = @PayoutID 
				And Balance = 0)
			Begin
				Select @NoteValue = Sum(NoteValue), @AdjAmount = Sum(NoteValue - Balance)
					From CreditNote 
					Where PayoutID = @PayoutID
					And Balance = 0
				Insert Into #tmpAbstract(SchemeId, SchAmt, PayoutID) Values(@SchemeID, @NoteValue, @PayoutID) 
			End
			Else /*Check if FreeQty scheme applied*/
			Begin

				If ((Select Count(*) From SchemeCustomerItems Where SchemeID = @SchemeID And IsInvoiced = 1) > 0)
				Begin

					Insert Into #tmpAbstract Select IA.InvoiceID, @SchemeID, 0, Quantity * (PTR + (PTR * TaxCode/100)), 0, ID.Serial, @PayoutID
						From InvoiceAbstract IA, InvoiceDetail ID 
						Where IA.InvoiceID = ID.InvoiceID
						And IA.InvoiceType In (1,3)        
						And (IA.Status & 128)=0 
						And dbo.StripTimeFromDate(IA.InvoiceDate) > dbo.StripTimeFromDate(@ExpiryDate)
						And ID.SchemeID = @SchemeID
						And IsNull(Flagword, 0) = 1
				End

			End
			Fetch Next From SchemeCur Into @SchemeID, @SchDescription, @RecdSchID, @ActiveFrom, @ActiveTo, @ExpiryDate, @PayoutID
		End
		Close SchemeCur
		Deallocate SchemeCur
		/*QPS Schemes for which Cr.Note generated - End*/
		
		/*This is to avoid duplicate records*/
		Insert Into #Abstract Select Distinct InvoiceID, SchemeID, SlabID, SchAmt , SchPer, Serial, PayoutID From #tmpAbstract
	End

	Select SA.SchemeID, SA.Description, SA.ActivityCode, SA.SchemeFrom, SA.SchemeTo, 
		SPP.PayoutPeriodFrom As PayoutFrom, SPP.PayoutPeriodTo As PayoutTo,Sum(A.SchAmt) As RFAValue,
		A.PayoutID 		
		From tbl_mERP_SchemeAbstract SA, #Abstract A, tbl_mERP_SchemePayoutPeriod SPP
		Where SA.SchemeID = A.SchemeID
		And A.SchemeID = SPP.SchemeID
		And A.PayoutID = SPP.ID
		Group By SA.SchemeID, SPP.ID, SA.Description, SA.ActivityCode, SA.SchemeFrom, SA.SchemeTo, SPP.PayoutPeriodFrom, SPP.PayoutPeriodTo, A.PayoutID
		Order By SA.ActivityCode, SPP.PayoutPeriodFrom, SPP.PayoutPeriodTo

	Drop Table #tmpSchemeDetail
	Drop Table #tmpAbstract
	Drop Table #Abstract
	Drop Table #tmpDetail

End
