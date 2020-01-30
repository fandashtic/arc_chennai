CREATE Function Dbo.fn_CalculateTax(    
@ItemCode nvarchar(30),    
@Amt decimal(18,6),    
@Qty decimal(18,6),    
@TaxType int,    
@TaxID int,    
@BatchCode int)    
--This function will return the tax value for a given batch    
    
Returns Decimal(18,6)    
As    
Begin    
Declare @nStockist decimal(18,6)    
Declare @nRetailer decimal(18,6)    
Declare @nConsumer decimal(18,6)    
Declare @nInstitution decimal(18,6)    
Declare @nMRP decimal(18,6)    
Declare @nApplicable int    
declare @nTax decimal(18,6)    
declare @nTaxAmount decimal(18,6)    
declare @nTaxableAmt decimal(18,6)    
    
    
if @Qty = 0     
 Return 0    
    
Declare @PriceOption int      
Select @PriceOption = Price_Option from Items, ItemCategories Where      
Product_Code = @ItemCode And Items.CategoryID = ItemCategories.CategoryID      
      
If @PriceOption = 1      
 Begin      
 declare cPrice cursor for Select Top 1 Batch_Products.PTS,       
  Batch_Products.PTR,       
  Batch_Products.ECP,       
  Batch_Products.Company_Price,       
  Items.MRP       
  From Items, Batch_Products      
  Where Items.Product_Code = Batch_Products.Product_Code       
  And Items.Product_Code = @ItemCode      
  And Batch_Products.Batch_Code = @BatchCode      
  And IsNull(Batch_Products.Free, 0) = 0      
  And IsNull(Batch_Products.Damage, 0) = 0      
 End      
Else      
 Begin      
  declare cPrice cursor for Select PTS, PTR, ECP, Company_Price, MRP       
  From Items       
  Where Product_Code = @ItemCode      
 End      
    
Open cPrice        
Fetch From cPrice Into @nStockist, @nRetailer, @nConsumer, @nInstitution, @nMRP         
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
     else if @nApplicable = 2    
         select @nTaxableAmt = @nStockist    
     else if @nApplicable = 3    
         select @nTaxableAmt = @nRetailer    
     else if @nApplicable = 4    
         select @nTaxableAmt = @nConsumer    
     else if @nApplicable = 5    
         select @nTaxableAmt = @nInstitution    
     else if @nApplicable = 6    
         select @nTaxableAmt = @nMRP    
         
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
    
  


