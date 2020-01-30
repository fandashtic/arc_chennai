Create Function mERP_sp_GetDistinctTaxPercentage(@LSTCST Int)
Returns @tmpTax Table
(
Tax_Code Int
)
As
Begin
	Declare @tmpTaxCode Table(TaxCode Int,TaxPercent Decimal(18,6))

	If @LSTCST = 1 
	Begin
		Insert Into @tmpTaxCode
		Select Max(Tax_Code),Percentage From Tax
		Where Active = 1
		Group By Percentage
		Having Count(Percentage) > 1
		Union
		Select Max(Tax_Code),Percentage From Tax
		Where Active = 1
		Group By Percentage
		Having Count(Percentage) = 1
	End
	Else
	Begin
		Insert Into @tmpTaxCode
		Select Max(Tax_Code),CST_Percentage From Tax
		Where Active = 1
		Group By CST_Percentage
		Having Count(CST_Percentage) >1
		Union
		Select Max(Tax_Code),CST_Percentage From Tax
		Where Active = 1
		Group By CST_Percentage
		Having Count(CST_Percentage) = 1
	End

	Insert Into @tmpTax
	Select Distinct TaxCode From @tmpTaxCode

	return 

End
