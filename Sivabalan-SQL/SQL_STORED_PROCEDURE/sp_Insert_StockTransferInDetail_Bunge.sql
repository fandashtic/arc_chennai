CREATE Procedure sp_Insert_StockTransferInDetail_Bunge(@DocSerial int,                          
  @Product_Code nvarchar(20),                          
  @BatchNumber nvarchar(255),                          
  @PTS Decimal(18,6),                          
  @PTR Decimal(18,6),                          
  @ECP Decimal(18,6),                          
  @SpecialPrice Decimal(18,6),                          
  @Rate Decimal(18,6),                          
  @Quantity Decimal(18,6),                          
  @Amount Decimal(18,6),                          
  @Expiry datetime,                          
  @PKD datetime,                          
  @Free Decimal(18,6) = 0,                          
  @TaxSuffered Decimal(18,6),                          
  @TaxAmount Decimal(18,6),                          
  @TotalAmount Decimal(18,6),@Promotion int = 0,                      
  @OpeningDate datetime = Null,                      
  @BackDatedTransaction int = 0,                
  @TaxID Int=0,        
  @Serial int =0,      
  @DocQty Decimal(18,6)=0,      
  @DocFree Decimal(18,6)=0,      
  @RecQty Decimal(18,6)=0,      
  @RejQty Decimal(18,6)=0        
)                
As                          
Declare @BatchCode int                          
Declare @TaxOnMrp Int                  
Declare @FreeTaxAmt Decimal(18,6) , @FreeTaxSuff Decimal(18,6), @FreeEcp Decimal(18,6)                
DECLARE @GRNAPPLICABLEON int                    
Declare @GRNPARTOFF Decimal(18,6)                    
Declare @VAT Int                  
Declare @PriceOption as Int      
                
SELECT @GRNAPPLICABLEON = LstApplicableOn, @GRNPARTOFF = LstPartOff from Tax where Tax_Code= @TaxId                    
SELECT @VAT = Vat from Items where Product_Code= @Product_Code                    
Select @PriceOption =Price_Option from ItemCategories where Categoryid =(select CategoryId from Items where Product_code=@Product_code)                    
SET @BatchNumber = Replace(@BatchNumber, CHAR(9), ',')                          
                          
Exec sp_update_openingdetails_firsttime @PRODUCT_CODE                          
-- If @PriceOption = 0       
--  select @PTS=PTS,@PTR =PTR,@ECP =ECP ,@SpecialPrice =Company_Price from ITems where Product_code=@Product_code      
      
Insert into Batch_Products (Batch_Number, Product_Code, StockTransferID, Expiry, Quantity,                          
PurchasePrice, SalePrice, PTS, PTR, ECP, QuantityReceived, Company_Price, PKD, Free,                           
TaxSuffered,GRNTaxID, GRNApplicableOn, GRNPartOff,ApplicableOn, PartOfPercentage,Vat_Locality,      
Serial)                                           
Values  (@BatchNumber, @Product_Code, @DocSerial, @Expiry, @Quantity, @Rate, @ECP, @PTS,                           
@PTR, @ECP, @Quantity, @SpecialPrice, @PKD, 0, @TaxSuffered,@TaxID,@GRNAPPLICABLEON, @GRNPARTOFF,@GRNAPPLICABLEON, @GRNPARTOFF,1,      
@Serial)                          
Select @BatchCode = @@Identity                          
              
--Set @TaxOnMrp = 0                    
--Select @TaxOnMrp = TaxOnMrp From StockTransferInAbstract Where DocSerial = @DocSerial                    
                    
Set @FreeTaxAmt = 0                    
Set @FreeTaxSuff = 0                    
Set @FreeEcp = 0                    
                    
--if @Promotion = 1 and TaxOnMrp = 1 and @Free > 0                    
if @Promotion = 1 and @Free > 0                    
Begin                    
 Set @FreeTaxAmt = (@TaxAmount / (@Quantity + @Free)) * @Free                    
 Set @TaxAmount = @TaxAmount - @FreeTaxAmt                    
 Set @FreeEcp = @ECP                     
 Set @FreeTaxSuff = @TaxSuffered                    
End                    
                       
Insert into StockTransferInDetail( DocSerial,                          
  Product_Code,                          
  Batch_Code,            
  Batch_Number,                          
  PTS,                          
  PTR,                           
  ECP,          
  SpecialPrice,                          
  Rate,                          
  Quantity,                          
  Amount,                          
  Expiry,                          
  PKD,                          
  TaxSuffered,                          
  TaxAmount,                          
  TotalAmount,                
  TaxCode,        
  VAT,        
  Serial,QuantityReceived,QuantityRejected,DocumentQuantity,DocumentFreeQty)                          
Values (                          
  @DocSerial,                          
  @Product_Code,                          
  @BatchCode,                          
  @BatchNumber,                          
  @PTS,                          
  @PTR,                           
  @ECP,                          
  @SpecialPrice,                          
  @Rate,                          
  @Quantity,                          
  @Amount,                          
@Expiry,                  
  @PKD,                          
  @TaxSuffered,                          
  @TaxAmount,                          
  @TotalAmount,                
  @TaxID,        
  @VAT,        
  @Serial,@RecQty,@RejQty,@DocQty,@DocFree)                          
        
If @BackDatedTransaction = 1                    
Begin                     
 exec sp_update_opening_stock @Product_Code, @OpeningDate, @Quantity, 0, @Rate            
--Insert TaxSuffered in Opening Details        
 Exec Sp_Update_Opening_TaxSuffered_Percentage @OpeningDate , @Product_Code , @BatchCode ,0                  
End                    
                  
If @Free > 0                           
Begin                          
Insert into Batch_Products (Batch_Number, Product_Code, StockTransferID, Expiry, Quantity,                          
PurchasePrice, SalePrice, PTS, PTR, ECP, QuantityReceived, Company_Price, PKD, Free,                           
TaxSuffered, BatchReference,GRNTaxID, GRNApplicableOn, GRNPartOff,ApplicableOn,PartOfPercentage,Vat_Locality, Promotion,      
Serial)                          
Values  (@BatchNumber, @Product_Code, @DocSerial, @Expiry, @Free, 0, 0, 0,                           
0, @FreeECP, @Free, 0, @PKD, 1, @FreeTaxSuff, @BatchCode,@TaxID,@GRNAPPLICABLEON, @GRNPARTOFF,@GRNAPPLICABLEON, @GRNPARTOFF,1,@Promotion,      
@Serial)                                    
Select @BatchCode = @@Identity                          
                          
Insert into StockTransferInDetail( DocSerial,                    
  Product_Code,                          
  Batch_Code,                          
  Batch_Number,                          
  PTS,                          
  PTR,                           
  ECP,                          
  SpecialPrice,                          
  Rate,                          
  Quantity,                          
  Amount,                          
  Expiry,                          
  PKD,                          
  TaxSuffered,                          
  TaxAmount,                          
  TotalAmount,        
  Promotion,        
  TaxCode,        
  VAT,        
  Serial,QuantityReceived,QuantityRejected,DocumentQuantity,DocumentFreeQty)                           
Values (                          
  @DocSerial,                          
  @Product_Code,                          
  @BatchCode,                          
  @BatchNumber,                          
  0,                          
  0,                           
  @FreeEcp,                          
  0,                          
  0,                        
  @Free,                          
  0,                          
  @Expiry,                          
  @PKD,                          
  @FreeTaxSuff,                          
  @FreeTaxAmt,                          
 0,        
  @Promotion,        
  @TaxID,        
  @VAT,        
  @serial,0,0,0,0)                          
                  
 If @BackDatedTransaction = 1                    
 Begin                     
  exec sp_update_opening_stock @Product_Code, @OpeningDate, @Free, 1, 0               
--Insert TaxSuffered in Opening Details        
  Exec Sp_Update_Opening_TaxSuffered_Percentage @OpeningDate , @Product_Code , @BatchCode ,0               
 End                    
End      
declare @track_csp int, @purchased_at int      
select @track_csp = itemcategories.price_option,@purchased_at = items.purchased_at      
from itemcategories, items  where itemcategories.categoryid = items.categoryid      
and items.product_code = @product_Code      

--For Bunge in STI csreen the changed value in the PTSS column given in the batch products is updated in the 
--Item table irrespective of the csp true or false item
      
--if @track_csp = 1       
--begin      
 IF @PURCHASED_AT = 1       
 BEGIN     
  update items set sale_price = @PTS, purchase_price = @rate,      
        PTS=@PTS,PTR=@PTR,ECP=@ECP,company_price = @SpecialPrice                          
        where items.product_code = @product_Code      
 END      
 ELSE      
 BEGIN      
  update items set sale_price = @PTR, purchase_price = @rate,      
        PTS=@PTS,PTR=@PTR,ECP=@ECP,company_price = @SpecialPrice                          
        where items.product_code = @product_Code      
 END      
--end      
      
Select 1                          
      
