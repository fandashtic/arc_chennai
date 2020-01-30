CREATE function fn_Get_TaxOnMRP (@TaxRate decimal(18,6))    
returns decimal(18,6)    
begin    
declare @Value decimal(18,6)    
 if (100.000000 - @TaxRate) <= 0     
 begin     
  set @Value = 0    
 end    
 else    
 begin     
  set @Value = (@TaxRate / (100.000000 - @TaxRate)) * 100    
 end    
 return @Value    
end    
