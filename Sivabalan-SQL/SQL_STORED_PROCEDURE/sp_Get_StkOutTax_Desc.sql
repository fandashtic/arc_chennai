Create Procedure sp_Get_StkOutTax_Desc (@TaxID int, @TaxRate Decimal(18,6))      
As      
Begin
	Declare @Tax_Code int
	
	IF isnull(@TaxID,0) = 0	
		Select @Tax_Code = Max(Tax_Code) From Tax Where isnull(Percentage,0) = @TaxRate and isnull(GSTFlag,0) = 0
	Else 
		Set @Tax_Code = @TaxID

	Select isnull(Tax_Description, '') Tax_Desc From Tax Where Tax_Code = @Tax_Code 

End
