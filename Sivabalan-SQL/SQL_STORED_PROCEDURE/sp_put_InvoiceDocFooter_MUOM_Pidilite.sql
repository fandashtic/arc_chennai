CREATE ProcEDURE sp_put_InvoiceDocFooter_MUOM_Pidilite(              
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
  @OctroiPerc Decimal(18,6) = 0,                   
  @OctroiAmount Decimal(18,6) = 0,                   
  @Freight Decimal(18,6) = 0                   
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
  OctroiPercentage,  
  OctroiAmount,  
  Freight        
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
  @OctroiPerc,  
  @OctroiAmount,  
  @Freight        
)              
 
Select @@IDENTITY    
  


