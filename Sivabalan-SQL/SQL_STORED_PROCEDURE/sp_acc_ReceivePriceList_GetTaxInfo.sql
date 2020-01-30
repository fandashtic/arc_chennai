CREATE Procedure sp_acc_ReceivePriceList_GetTaxInfo(@TaxDesc nVarChar(50), @CST Decimal(18,6),
@ApplOnCST Int, @PartOfCST Decimal(18,2), @LST Decimal(18,6), @ApplOnLST Int, @PartOfLST Decimal(18,2))
As
Declare @TaxCode Int
Declare @Tax_Desc nVarchar(50)
/*Update Tax Master*/
Update Tax Set LSTApplicableOn = 1 Where IsNULL(LSTApplicableOn, 0)= 0
Update Tax Set CSTApplicableOn = 1 Where IsNULL(CSTApplicableOn, 0)= 0
Update Tax Set LSTPartOff = 100 Where IsNULL(LSTPartOff, 0)= 0
Update Tax Set CSTPartOff = 100 Where IsNULL(CSTPartOff, 0)= 0

/*Check Whether the combination is avialable in some other Tax_Code & Description,
If available then return that Tax_Code & Description Else Return description alone*/
Select @TaxCode = Tax_Code, @Tax_Desc = Tax_Description From Tax 
Where Percentage = @LST And CST_Percentage = @CST
And LSTApplicableOn = @ApplOnLST And LSTPartOff = @PartOfLST
And CSTApplicableOn = @ApplOnCST And CSTPartOff = @PartOfCST

If @TaxCode <> 0
	Set @TaxDesc = @Tax_Desc

Select @TaxDesc, IsNull(@TaxCode, 0)

