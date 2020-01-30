CREATE Procedure sp_get_AsOnDatePurTax(@ItemCode nvarchar(30), @BillDate Datetime)  
As
Begin
	Set DateFormat DMY
	Declare @TaxID Int
	Select Top 1  @TaxID=PTaxCode From ItemsPTaxMap 
	Where Product_Code = @ItemCode and dbo.Striptimefromdate(@BillDate) 
		Between dbo.Striptimefromdate(PEffectiveFrom) and dbo.Striptimefromdate(isnull(PEffectiveTo,GetDate()))

	Select PTaxCode=Tax_Code,Percentage, CST_Percentage, LSTApplicableOn, LSTPartOff, CSTApplicableOn, CSTPartOff, CS_TaxCode, GSTFlag From Tax Where Tax_Code = @TaxID

End
