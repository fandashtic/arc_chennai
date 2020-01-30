CREATE procedure sp_Get_Received_Tax  
(  
 @TaxPercentage as Decimal(18,6),  
 @TaxApplicableOn as Int,   
 @TaxPartOff as Decimal(18,6),  
 @TaxLocality as Int  
)  
As  
IF @TaxLocality = 1   
 Select Tax_Code From Tax   
 Where Percentage = @TaxPercentage And  
 LstApplicableOn = @TaxApplicableOn And  
 LstPartOff = @TaxPartOff  
Else  
 Select Tax_Code From Tax   
 Where Percentage = @TaxPercentage And  
 CstApplicableOn = @TaxApplicableOn And  
 CstPartOff = @TaxPartOff  


