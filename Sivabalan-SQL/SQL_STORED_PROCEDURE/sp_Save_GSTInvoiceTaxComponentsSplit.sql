CREATE Procedure sp_Save_GSTInvoiceTaxComponentsSplit(@InvoiceID Int)  
As
Begin

	Insert Into InvoiceTaxComponents(InvoiceID,Product_Code,TaxType,Tax_Code,Tax_Component_Code,Tax_Percentage,Tax_Value)
	Select GST.InvoiceID,GST.Product_Code,GST.TaxType,GST.Tax_Code,GST.Tax_Component_Code,GST.Tax_Percentage,Sum(isnull(GST.NetTaxAmount,0))
	From GSTInvoiceTaxComponents GST Inner Join InvoiceAbstract IA
		On GST.InvoiceID = IA.InvoiceID
	Where GST.InvoiceID = @InvoiceID
	Group By GST.InvoiceID,GST.Product_Code,GST.TaxType,GST.Tax_Code,GST.Tax_Component_Code,GST.Tax_Percentage


	/* Start - Primary Item Serial Update in Free Item for SplCat (to correct RFA Datapost) */
	Declare @DProduct_Code nVarchar(30)
	Declare @DBatch_Code Int
	Declare @Dserial Int
	Declare @tmp nVarchar(Max)
	Declare @CorrectSplSerialNo nVarchar(Max)

	Set DateFormat DMY

	Declare DCInvoiceWiseSplSerial Cursor For
	Select Product_Code,Batch_Code, Serial From InvoiceDetail 
	Where		
		Invoiceid = @InvoiceiD And Isnull(FlagWord,0) = 1
	Order By Serial
	Open DCInvoiceWiseSplSerial
	Fetch Next From DCInvoiceWiseSplSerial Into @DProduct_Code,@DBatch_Code,@Dserial
	While (@@Fetch_Status = 0)
	Begin			
		Set @tmp = ''
		Select @tmp = @tmp + Cast(Serial As nVarchar(Max)) + ',' From InvoiceDetail Where InvoiceID = @InvoiceID 
			And (SPLCatserial = Cast(@Dserial As nVarchar(100)) or CHARINDEX(','+Cast(@Dserial As nVarchar(100)),ISNULL(SPLCatserial,'')) > 0   or CHARINDEX(Cast(@Dserial As nVarchar(100)) + ',',ISNULL(SPLCatserial,'')) > 0) 
			And FlagWord = 0 and Isnull(SPLCATSerial,'') <> '' And Isnull(UOMQty,0) > 0

		Select @CorrectSplSerialNo = SUBSTRING(@tmp, 0, LEN(@tmp))

		IF Isnull(@CorrectSplSerialNo,'') <> ''
		Begin
			Update InvoiceDetail Set SplCatSerial = @CorrectSplSerialNo Where InvoiceID = @InvoiceID 
			And Product_Code = @DProduct_Code
			And Batch_Code = @DBatch_Code
			And Serial = @Dserial
		End
		
		Fetch Next From DCInvoiceWiseSplSerial Into @DProduct_Code,@DBatch_Code,@Dserial
	End
	Close DCInvoiceWiseSplSerial
	Deallocate DCInvoiceWiseSplSerial
	/* End  */

End
