create function fn_GetTaxCode (  
 @nTaxPer Decimal(18,6),   
 @nApplicableOn Int,   
 @nPartOff decimal(18,6)) 
returns integer
as   
 begin  
  declare @nTaxCode int  
  Select @nTaxCode = tax_code from tax where percentage = @nTaxPer   
  and lstapplicableon =  @nApplicableOn and lstpartoff =  @nPartOff  
      
     If @nTaxCode = 0  
  BEGIN  
      Select @nTaxCode = tax_code from tax where cst_percentage = @nTaxPer   
   and cstapplicableon = @nApplicableOn and cstpartoff =  @nPartOff  
  END  
  return (isnull(@ntaxcode,0))
 end  
