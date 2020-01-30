CREATE Procedure sp_acc_ReceivePriceList_CompareTaxPercentage(@TaxID int, @CST Decimal(18,6),
@ApplOnCST Int, @PartOfCST Decimal(18,2), @LST Decimal(18,6), @ApplOnLST Int, @PartOfLST Decimal(18,2))
As
If Exists(Select * From Tax Where Percentage = @LST And CST_Percentage = @CST 
And LSTApplicableOn = @ApplOnLST And LSTPartOff = @PartOfLST And 
CSTApplicableOn = @ApplOnCST And CSTPartOff = @PartOfCST And Tax_Code = @TaxID)
	Select 1
Else
	Select 0

