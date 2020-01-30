Create Procedure sp_Get_CalculateTax_TaxInfo_Taxtype (@TaxType Int, @TaxID int)
As
Select Case @TaxType 
When 2 Then (CST_Percentage * CSTPartOff) / 100  
Else (Percentage * LSTPartOff) / 100  End,
Case @TaxType 
When 2 Then CSTApplicableOn 
Else LSTApplicableOn End
From Tax Where Tax_Code = @TaxID
