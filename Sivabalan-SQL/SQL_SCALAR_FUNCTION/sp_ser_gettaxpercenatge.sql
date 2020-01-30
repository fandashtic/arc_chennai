CREATE function sp_ser_gettaxpercenatge(@Locality Int,@Tax_Code Int,@Mode Int = 0)  
returns Decimal(18,6)  
as  
Begin  
Declare @TaxPercentage Decimal(18,6)  
Set @TaxPercentage = 0
If @Mode = 1   
Begin  
 Select @TaxPercentage = Percentage   
 From ServiceTaxMaster where ServiceTaxCode = @Tax_Code  
End  
Else  
Begin  
 If @Locality = 1   
 Begin  
  Select @TaxPercentage = Percentage  
  From Tax where Tax_Code = @Tax_Code  
 End  
 Else If @Locality = 2  
 Begin  
  Select @TaxPercentage = CST_Percentage  
  From Tax where Tax_Code = @Tax_Code  
 End  
End  
return @TaxPercentage  
End  

