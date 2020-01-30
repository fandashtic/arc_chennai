CREATE Function Dbo.fn_CalculateTax_FMCG(        
@ItemCode nvarchar(30),        
@Amt decimal(18,6),        
@Qty decimal(18,6),        
@TaxType int,        
@TaxID int)        
--This function will return the tax value for a given batch        
        
Returns Decimal(18,6)        
As        
Begin        
Declare @nPurchasePrice decimal(18,6)        
Declare @nMRP decimal(18,6)        
Declare @nApplicable int        
declare @nTax decimal(18,6)        
declare @nTaxAmount decimal(18,6)        
declare @nTaxableAmt decimal(18,6)        
        
        
if @Qty = 0         
 Return 0        
        
       
Declare cPrice cursor for Select MRP           
From Items           
Where Product_Code = @ItemCode          
        
Open cPrice            
Fetch From cPrice Into @nMRP             
if @@Fetch_Status = 0            
Begin            
 declare cTax cursor for         
 Select Case @TaxType           
 When 1 Then (Percentage * LSTPartOff) / 100           
 Else (CST_Percentage * CSTPartOff) / 100 End,          
 Case @TaxType           
 When 1 Then LSTApplicableOn          
 Else CSTApplicableOn End          
 From Tax Where Tax_Code = @TaxID          
         
 open cTax        
 Fetch from cTax Into @nTax, @nApplicable        
 if @@fetch_status = 0        
 Begin        
     if @nApplicable = 1        
         select @nTaxableAmt = @Amt / @Qty        
     else if @nApplicable = 6        
         select @nTaxableAmt = @nMRP        
     else    
         select @nTaxableAmt = 0        
             
     select @ntaxamount = (@nTaxableAmt * @Qty * (@nTax / 100))        
 End        
 else        
 begin         
     select @ntaxamount = 0        
 end        
 close cTax        
 Deallocate cTax        
End        
Else        
Begin        
     select @ntaxamount = 0        
End        
        
close cPrice        
Deallocate cPrice        
        
Return @ntaxamount        
End         
        
      
    
  


