CREATE Procedure sp_get_GSTTaxDetails(@ItemCode nvarchar(30), @InvoiceDate Datetime, @TaxType int)  
As
Begin
	Declare @TaxCode int
	Declare @GSTEnable Int

	Select @GSTEnable = Isnull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'GSTaxEnabled' 

--	Select T.Tax_Code as TaxCode, 
--	Case @TaxType When 1 then  ISNULL(T.Percentage, 0) Else ISNULL(T.CST_Percentage, 0) End 'TaxRate',       
--	Case @TaxType When 1 then  ISNULL(T.LSTApplicableOn, 0) Else ISNULL(T.CSTApplicableOn, 0) End 'TaxApplicableOn',      
--	Case @TaxType When 1 then  ISNULL(T.LSTPartOff, 0) Else ISNULL(T.CSTPartOff, 0) End 'TaxPartOff'      
--	From Items I
--	Inner Join Tax T ON I.Sale_Tax = T.Tax_Code
--	Where I.Product_Code = @ItemCode

	Set DateFormat DMY
	If @GSTEnable = 1
		Select Top 1 @TaxCode = STaxCode From ItemsSTaxMap 
		Where Product_Code = @ItemCode and dbo.Striptimefromdate(@InvoiceDate) 
			Between dbo.Striptimefromdate(SEffectiveFrom) and dbo.Striptimefromdate(isnull(SEffectiveTo,GetDate()))
	Else	
		Select Top 1 @TaxCode = IsNull(Sale_Tax,0) From Items Where Product_Code = @ItemCode 
	
	Select T.Tax_Code as TaxCode, 
		Case @TaxType When 1 then  ISNULL(T.Percentage, 0) Else ISNULL(T.CST_Percentage, 0) End 'TaxRate',       
		Case @TaxType When 1 then  ISNULL(T.LSTApplicableOn, 0) Else ISNULL(T.CSTApplicableOn, 0) End 'TaxApplicableOn',      
		Case @TaxType When 1 then  ISNULL(T.LSTPartOff, 0) Else ISNULL(T.CSTPartOff, 0) End 'TaxPartOff'      	
	From Tax T
	Where Tax_Code = @TaxCode

End
