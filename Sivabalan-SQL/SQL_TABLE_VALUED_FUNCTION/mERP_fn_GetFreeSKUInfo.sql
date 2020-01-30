Create Function mERP_fn_GetFreeSKUInfo(@InvoiceId Int ,@SchemeID Int,@Serial Int, @SchType Int,@TaxConfigFlag Int)
Returns @SchInfo Table (FreeSKUSerial Int,FreeUOM nVarchar(255), FreeQty Decimal(18, 6), FreeValue Decimal(18, 6),FreeValue_Tax Decimal(18,6))

Begin

	Declare @FreeSerial nVarchar(255)
	Declare @Amount Decimal(18,6)
	Declare @Amount_Tax Decimal(18,6)
	Declare @SKUCode nVarchar(255)
	Declare @Qty Decimal(18,6)
	Declare @FreeUOM nVarchar(255)
	Declare @SchemeDetail nVarchar(255) 
	Declare @SerialTable Table (SerialNo Int)
	Declare @IsExists Int
	Declare @FreeSKUSerial Int
	Declare @SPFreeSerial nVarchar(255)
	

	

		Declare SerialCur Cursor For
			Select Serial, Case @SchType 
							When 1 Then FreeSerial
							Else SplCatSerial End, 
				dbo.mERP_fn_GetMarginPTR(Product_Code,InvoiceID, @SchemeID)  , Product_Code, Sum(Quantity), MultipleSchemeDetails ,
				Case When isnull(InvoiceDetail.TaxOnQty,0) = 0 Then
					dbo.mERP_fn_GetMarginPTR(Product_Code,InvoiceID, @SchemeID) + (dbo.mERP_fn_GetMarginPTR(Product_Code,InvoiceID, @SchemeID)* (TaxCode/100))
				else
					(dbo.mERP_fn_GetMarginPTR(Product_Code,InvoiceID, @SchemeID) + TaxCode)
				End
				From InvoiceDetail 
				Where InvoiceID = @InvoiceId And FlagWord = 1
				Group By Serial, Product_Code, MultipleSchemeDetails, FreeSerial, SplCatSerial, PTR, TaxCode,InvoiceID,TaxOnQty
		Open SerialCur
		Fetch Next From SerialCur Into @FreeSKUSerial, @FreeSerial, @Amount, @SKUCode, @Qty, @SchemeDetail,@Amount_Tax 
		While (@@Fetch_Status = 0)
		Begin
			Insert into @SerialTable Select ItemValue From dbo.sp_splitin2rows(@FreeSerial, ',')

			/*Check Primary serial no. exists in Free item's Free serial*/
			If Exists (Select * From @SerialTable Where SerialNo = @Serial) 
			Begin
				
				/*Check for particular SchemeID*/
				If Exists( Select * From dbo.mERP_fn_GetInvSchemeDetail(@InvoiceID, @SchemeDetail, 1, 0, 0) Where SchemeID = @SchemeID)	
				Begin
					Select @FreeUOM = UOM.Description 
						From UOM, Items 
						Where Product_Code = @SKUCode 
						And Items.UOM = UOM.UOM
					Insert Into @SchInfo Values(@FreeSKUSerial, @FreeUOM, @Qty, @Amount,@Amount_Tax)
				End
				Else
				Begin
					If @SchType = 2
					Begin
						Select @FreeUOM = UOM.Description 
							From UOM, Items 
							Where Product_Code = @SKUCode 
							And Items.UOM = UOM.UOM
						Insert Into @SchInfo Values(@FreeSKUSerial, @FreeUOM, @Qty, @Amount,@Amount_Tax)
					End
				End

			End
			Delete From @SerialTable
			Fetch Next From SerialCur Into @FreeSKUSerial, @FreeSerial, @Amount, @SKUCode, @Qty, @SchemeDetail,@Amount_Tax
		End
		Close SerialCur
		Deallocate SerialCur 	

		If ((Select Count(*) From @SchInfo) = 0 )
			Insert Into @SchInfo Values (0, Null, 0, 0,0) 
		Return
End

