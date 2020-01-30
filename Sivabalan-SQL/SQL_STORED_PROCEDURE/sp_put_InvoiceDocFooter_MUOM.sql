CREATE ProcEDURE [sp_put_InvoiceDocFooter_MUOM](    
  @ForumCode [nvarchar](15),          
  @Quantity  Decimal(18,6),          
  @SalePrice  Decimal(18,6),          
  @TaxCode  [float],          
  @DiscountPercentage  Decimal(18,6),          
  @DiscountValue  Decimal(18,6),          
  @Amount  Decimal(18,6),          
  @PTR Decimal(18, 6),          
  @MRP Decimal(18, 6),          
  @Batch_Number nvarchar(100),          
  @PKD DateTime,          
  @Expiry DateTime,          
  @PTS Decimal(18, 6),           
  @FreePTS Decimal(18,6),          
  @FreePTR Decimal(18,6),          
  @FreeMRP Decimal(18,6),          
  @UOMName nvarchar(255),        
  @UOMQty Decimal(18,6),        
  @UOMPrice Decimal(18,6),        
  @InvoiceID  [int],    
  @TaxApplicableOn int = 0,      
  @TaxPartOff  Decimal(18,6) = 0,      
  @TaxSuffApplicableOn int = 0,      
  @TaxSuffPartOff  Decimal(18,6) = 0,      
  @ItemMRP Decimal(18,6) = 0,      
  @Company_Price Decimal(18,6) = 0,  
  @ExciseDutyPerc Decimal(18,6) = 0,      
  @ExciseAmount Decimal(18,6) = 0,
  @DiscAmtPerUnit Decimal(18,6) = 0, 
  @INV_Discount Decimal(18,6) = 0,
  @INV_DisAmtPerUnit Decimal(18,6) = 0,
  @INV_DiscountAmount Decimal(18,6) = 0,
  @Other_Discount Decimal(18,6) = 0,
  @Other_DisAmtPerUnit Decimal(18,6) = 0,
  @Other_DiscountAmount Decimal(18,6) = 0,
  @NetPTS Decimal(18,6) = 0,
  @PTS_Margin Decimal(18,6) = 0,
  @Base_PTS_SP Decimal(18,6) = 0,
  @DISCTYPE int = 0,
  @MRPPerPack decimal(18,6)=0,
  @TOQ int = 0,
  @CS_TaxCode int = 0,
  @HSNNumber nvarchar(15) = ''         
 )          
AS           
Declare @Product_Code nvarchar(20)          
Declare @UOM int        
Declare @ConvFact Decimal(18,6)        
Set @UOM = 0        
if @UOMQty > 0 Set @ConvFact = @Quantity / @UOMQty        
        
/*  The Field "UOM" in "Invoice Detail Received" is taken From        
   Conversion Factor of Received invoice         
   if it is 1 Then it is Basic UOM of the Item        
   Else if the Conversion Factor is Found with either         
   UOM1 or UOM2 of the Item, Respective Code is Taken        
   if Conversion Factor Fits no where then UOM is left Zero */        
        
     Select @Product_Code = Product_Code, @UOM = (Case         
     When @ConvFact = 1 then UOM        
     When UOM1_Conversion = @ConvFact Then UOM1        
     When UOM2_Conversion = @ConvFact Then UOM2         
     Else 0 End)        
     From Items Where Alias = @ForumCode          
        
        
SET @UOM = ISNULL(@UOM,0)        
        
INSERT INTO [InvoiceDetailReceived]           
  (     
  ForumCode,          
  Product_Code,        
  [Quantity],          
  [SalePrice],          
  [TaxCode],          
  [DiscountPercentage],          
  [DiscountValue],          
  [Amount],          
  PTR,          
  MRP,          
  Batch_Number,          
  PKD,          
  Expiry,          
  PTS,          
  [InvoiceID],          
  FreePTS,          
  FreePTR,          
  FreeMRP,        
  UOMDescription,        
  UOM,        
  UOMQty,        
  UOMPrice,          
  TaxApplicableOn,      
  TaxPartOff,      
  TaxSuffApplicableOn,      
  TaxSuffPartOff,      
  ItemMRP,      
  Company_Price,  
  ExciseDuty,  
  ExcisePercentage,
  DiscPerUnit,
  InvDiscPerc,
  InvDiscAmtPerUnit,
  InvDiscAmount,
  OtherDiscPerc,
  OtherDiscAmtPerUnit,
  OtherDiscAmount,
  NetPTS,
  PTS_Margin,
  Base_PTS_SP,
  DISCTYPE,
  Pending,
  MRPPerPack,
  TOQ,
  CS_TaxCode,
  HSNNumber
 )           
           
VALUES           
 (        
  @ForumCode,          
  @Product_Code,        
  @Quantity,          
  @SalePrice,          
  @TaxCode,          
  @DiscountPercentage,          
  @DiscountValue,          
  @Amount,          
  @PTR,          
  @MRP,          
  @Batch_Number,          
  @PKD,          
  @Expiry,          
  @PTS,          
  @InvoiceID,          
  @FreePTS,          
  @FreePTR,          
  @FreeMRP,        
  @UOMName,        
  @UOM,        
  @UOMQty,        
  @UOMPrice,    
  @TaxApplicableOn,      
  @TaxPartOff,      
  @TaxSuffApplicableOn,      
  @TaxSuffPartOff,      
  @ItemMRP,      
  @Company_Price,      
  @ExciseAmount,  
  @ExciseDutyPerc,
  @DiscAmtPerUnit,
  @INV_Discount,
  @INV_DisAmtPerUnit,
  @INV_DiscountAmount,
  @Other_Discount,
  @Other_DisAmtPerUnit,
  @Other_DiscountAmount,
  @NetPTS,
  @PTS_Margin,
  @Base_PTS_SP,
  @DISCTYPE,
  @Quantity,
  @MRPPerPack,
  @TOQ,
  @CS_TaxCode ,
  @HSNNumber 
)          

