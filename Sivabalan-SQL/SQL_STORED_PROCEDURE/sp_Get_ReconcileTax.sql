Create Procedure sp_Get_ReconcileTax (@TaxRate Decimal(18,6))      
As      
Begin
	Select Max(Tax_Code) Tax_Code From Tax Where isnull(Percentage,0) = @TaxRate and isnull(GSTFlag,0) = 0
End
