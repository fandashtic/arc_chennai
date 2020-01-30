CREATE PROCEDURE sp_put_SRDocFooter    
(      
 @SRNumber  int,      
 @Product_Code  nVarchar(15),      
 @Quantity  Decimal(18,6),      
 @PurchasePrice  Decimal(18,6),    
 @ForumCode  nVarchar(15),      
 @ExcessQty  Decimal(18,6),      
 @UOMQty  Decimal(18,6),      
 @UOMPrice  Decimal(18,6),  
 @UOMDesc nVarchar(255),
 @Serial Int    
)     
AS       
Declare @UOMID Int    
--Declare @UOMDesc nVarchar(255)    
Declare @ConvFactor Decimal(18,6)    
    
If @UOMQty > 0     
 Set @ConvFactor = @Quantity / @UOMQty    
    
Select @UOMID = (Case     
 When @ConvFactor = IsNull(UOM2_Conversion,0) Then UOM2    
 When @ConvFactor = IsNull(UOM1_Conversion,0) Then UOM1    
 Else UOM End)    
 From Items Where Product_Code = @Product_Code     
    
--Select @UOMDesc = Description from UOM where UOM=@UOMID      
    
INSERT INTO Stock_Request_Detail_Received       
(    
STK_REQ_Number,      
Product_Code,      
Quantity,      
PurchasePrice,    
ForumCode,    
Pending,    
ExcessQuantity,    
UOM,    
UOMQty,    
UOMPrice,    
UOMDesc,  
Serial    
)         
VALUES       
(     
@SRNumber,    
@Product_Code,    
@Quantity,    
@PurchasePrice,    
@ForumCode,    
@Quantity, -- Pending    
@ExcessQty,    
@UOMID,    
@UOMQty,    
@UOMPrice,    
@UOMDesc,  
@Serial    
)    
      
    
  




