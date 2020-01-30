Create Procedure mERP_sp_GetTax(@ProdCode nVarchar(500))
As
Begin

	Select  isNull(Tax.Tax_Code,0),isNull(Tax.Percentage,0),
	isNull(Tax.CST_Percentage,0) From   Items
	 Left Outer Join  Tax On Items.Sale_Tax = Tax.Tax_Code WHERE   Product_Code = @ProdCode And  Tax.Active = 1
End
SET QUOTED_IDENTIFIER OFF 
