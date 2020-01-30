Create Function mERP_fn_CheckPrimarySKU(@InvoiceId Int , @SchemeID Int, @Serial Int)
Returns Int
Begin
	Declare @FreeSerial nVarchar(255)
	Declare @SchemeDetails nVarchar(255)
	Declare @SerialTable Table (SerialNo Int)
	Declare @SlabID Int
	Declare @ItemGroup Int
	

	Select @ItemGroup = ItemGroup From tbl_mERP_SchemeAbstract Where SchemeID = @SchemeID

	Declare SerialCur Cursor For
		Select  Case @ItemGroup 
					When 1 Then FreeSerial
					When 2 Then SplCatSerial
					End, 
				Case @ItemGroup 
					When 1 Then MultipleSchemeDetails 
					When 2 Then MultipleSplCategorySchDetail 
					End
			From InvoiceDetail 
			Where InvoiceID = 	@InvoiceId 
			And FlagWord = 1
	Open SerialCur
	Fetch Next From SerialCur Into @FreeSerial, @SchemeDetails
	While (@@Fetch_Status = 0)
	Begin
		
		Select @SlabID = SlabID From dbo.mERP_fn_GetInvSchemeDetail(@InvoiceId, @SchemeDetails, 1,0,0) Where SchemeID = @SchemeID
		If @SlabID > 0
		Begin
			Insert into @SerialTable Select ItemValue From dbo.sp_splitin2rows(@FreeSerial, ',')
			If Not Exists (Select * From @SerialTable Where SerialNo = @Serial) 
				Set @SlabID = 0
		End
		Fetch Next From SerialCur Into @FreeSerial, @SchemeDetails
	End
	Close SerialCur
	Deallocate SerialCur 	

	Return @SlabID

End
