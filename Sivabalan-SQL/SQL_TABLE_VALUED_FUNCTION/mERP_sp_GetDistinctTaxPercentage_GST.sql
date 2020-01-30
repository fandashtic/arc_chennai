Create Function mERP_sp_GetDistinctTaxPercentage_GST(@LSTCST Int,@GSTFlag Int)  
Returns @tmpTax Table  
(  
Tax_Code Int  
)  
As  
Begin  
	Declare @tmpTaxCode Table(TaxCode Int,TaxPercent Decimal(18,6))  

	Insert Into @tmpTaxCode  
	Select Tax_Code,Percentage From Tax  
	Where Active = 1  And IsNull(GSTFlag,0) = @GSTFlag	

	Insert Into @tmpTax  
	Select Distinct TaxCode From @tmpTaxCode  
	  
	Return     
End 
