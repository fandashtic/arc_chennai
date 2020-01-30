Create Procedure sp_GSTValidation(@ItemCode nvarchar(30), @InvoiceDate Datetime)
As
Begin
	Declare @HSN int
	Declare @Cat int
	Declare @TaxCode int
	Declare @GSTFlag as int

	Set DateFormat DMY
	Set @HSN = 0
	Set @Cat = 0

	

	IF (Select isnull(Flag,0) From tbl_merp_ConfigAbstract Where ScreenCode = 'GSTaxEnabled') = 1
	Begin
		Select Top 1 @TaxCode = STaxCode From ItemsSTaxMap Where Product_Code = @ItemCode and 
		dbo.Striptimefromdate(@InvoiceDate) Between dbo.Striptimefromdate(SEffectiveFrom) and  dbo.Striptimefromdate(isnull(SEffectiveTo,GetDate()))

		Select @GSTFlag = isnull(GSTFlag,0) From Tax Where Tax_Code = @TaxCode

		IF @GSTFlag = 1
		Begin
			IF Exists(Select * From Items Where Product_Code = @ItemCode and isnull(HSNNumber,'') = '')
			--IF Exists(Select 'x' From Items I Inner Join Tax T On I.Sale_Tax = T.Tax_Code
			--	Where I.Product_Code = @ItemCode and isnull(T.GSTFlag,0) = 1 and isnull(I.HSNNumber,'') = '') 

				Select @HSN = 1

			IF Exists(Select * From Items Where Product_Code = @ItemCode and isnull(CategorizationID,0) = 0)
			--IF Exists(Select 'x' From Items I Inner Join Tax T On I.Sale_Tax = T.Tax_Code
			--	Where I.Product_Code = @ItemCode and isnull(T.GSTFlag,0) = 1 and isnull(CategorizationID,0) = 0) 

				Select @Cat = 1
		End
	End
	Else
		Select Top 1 @TaxCode = Sale_Tax From Items Where Product_Code = @ItemCode	
	
	Select @HSN as HSN, @Cat as Cat, @TaxCode as TaxCode
End
