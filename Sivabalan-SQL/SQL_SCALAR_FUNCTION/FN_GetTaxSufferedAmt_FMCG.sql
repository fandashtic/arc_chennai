CREATE Function Dbo.FN_GetTaxSufferedAmt_FMCG(      
@PurchasePrice decimal(18,6),      
@MRP decimal(18,6),
@Qty decimal(18,6),      
@TaxPercentage decimal(18,6),      
@TaxApplicableOn int,
@TaxPartOff decimal(18,6),
@Batch_Code Int=0)
--This function will return the tax value for a given batch      
Returns Decimal(18,6)      
As      
Begin      
declare @nTax decimal(18,6)      
declare @nTaxAmount decimal(18,6)      
declare @nTaxableAmt decimal(18,6)      

if @Qty = 0       
 Return 0      

Select @nTax = (@TaxPercentage * @TaxPartOff) / 100
if @TaxApplicableOn = 1      
	Select @ntaxamount = (@PurchasePrice * @Qty * (@nTax / 100))      
else if @TaxApplicableOn = 6      
	Select @ntaxamount = (@MRP * @Qty * (@nTax / 100))      
else
	select @ntaxamount = 0   

Return @ntaxamount      
End       
      
    
  
  


