Create Procedure mERP_sp_Get_CSTTaxDetail(@TaxCode Int)
As
Begin
	Select isNull(CST_Percentage,0) From Tax Where Tax_Code = @TaxCode
End
