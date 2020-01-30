CREATE Procedure SP_Save_TODetailReceived_MUOM  
(@DocSerial int ,     
@Product_Code nvarchar(15),     
@Batch_Number nvarchar (128),     
@PTS decimal(18,6) ,     
@PTR decimal(18,6),     
@ECP decimal(18,6),     
@SpecialPrice decimal(18,6),      
@Rate decimal(18,6),     
@Quantity Decimal(18,6),     
@Amount Decimal(18,6),     
@ForumCode nvarchar(20) ,     
@Expiry datetime,     
@PKD Datetime,     
@Free Decimal(18,6),    
@TaxSuffered Decimal(18,6),    
@TaxAmount Decimal(18,6),    
@TotalAmount Decimal(18,6),    
@Applicableon int = 0,    
@partoff decimal(18,6) = 100,    
@Serial Integer=0,  
@UOMDescription nvarchar(255),            
@UOMQty Decimal(18,6),            
@UOMPrice Decimal(18,6)            
)    
AS
Begin    
Declare @Item_Code nvarchar(20)  
Declare @UOM int            
Declare @ConvFact Decimal(18,6)            

Set @UOM = 0            

If @UOMQty > 0 Set @ConvFact = @Quantity / @UOMQty            
Select @Item_Code = Product_Code, @UOM = (Case             
     When @ConvFact = 1 then UOM            
     When UOM1_Conversion = @ConvFact Then UOM1            
     When UOM2_Conversion = @ConvFact Then UOM2             
     Else UOM End)            
     From Items Where Alias = @ForumCode              
  
Insert Into StockTransferOutDetailReceived(
DocSerial,
Product_Code,
Batch_Number,
PTS,
PTR,
ECP,
SpecialPrice,
Rate,
Quantity,
Amount,
ForumCode,
Expiry,
PKD,
CreationDate,
Free,
TaxSuffered,
TaxAmount,
TotalAmount,
Applicableon,
Partoff,
Serial,
UOM,
UOMQuantity,
UOMPrice,
UOMDesc
)
Values
(
@DOCSERIAL,
@Product_Code,      
@Batch_Number,
@PTS,
@PTR,
@ECP,
@SpecialPrice,
@Rate,
@Quantity,     
@Amount,
@ForumCode,
@Expiry,
@PKD,
getdate(),
@Free,
@TaxSuffered,     
@TaxAmount,
@TotalAmount,
@Applicableon,
@partoff,
@Serial,
@UOM,
@UOMQty,
@UOMPrice,
@UOMDescription
)
End
