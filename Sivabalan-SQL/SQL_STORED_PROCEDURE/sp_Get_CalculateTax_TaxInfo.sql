Create Procedure sp_Get_CalculateTax_TaxInfo (@TaxType Int, @TaxID int)
As
Select Case @TaxType 
When 1 Then (Percentage * LSTPartOff) / 100 
Else (CST_Percentage * CSTPartOff) / 100 End,
Case @TaxType 
When 1 Then LSTApplicableOn
Else CSTApplicableOn End
From Tax Where Tax_Code = @TaxID


