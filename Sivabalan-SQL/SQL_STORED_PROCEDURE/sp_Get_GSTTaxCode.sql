Create Procedure sp_Get_GSTTaxCode(@CSTaxCode int, @TaxType int)
As
Begin
	IF @TaxType = 1
		Select Tax_Code, Percentage From Tax Where CS_TaxCode = @CSTaxCode and isnull(Active,0) = 1
	Else
		Select Tax_Code, CST_Percentage From Tax Where CS_TaxCode = @CSTaxCode and isnull(Active,0) = 1
End
