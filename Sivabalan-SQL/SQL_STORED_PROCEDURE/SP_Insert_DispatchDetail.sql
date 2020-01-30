CREATE PROCEDURE SP_Insert_DispatchDetail    
 (@DispatchID  [int],      
  @Product_Code  [nvarchar](15),      
  @Quantity  Decimal(18,6),      
  @Batch_Code  [int],      
  @SalePrice  Decimal(18,6),      
  @FlagWord  [int],      
  @UOM  [decimal],      
  @UOMQty  Decimal(18,6),      
  @UOMPrice  Decimal(18,6))      
      
AS    
INSERT INTO [DispatchDetail]       
  ( [DispatchID],      
  [Product_Code],      
  [Quantity],      
  [Batch_Code],      
  [SalePrice],      
  [FlagWord],      
  [UOM],      
  [UOMQty],      
  [UOMPrice])       
       
VALUES       
 ( @DispatchID,      
  @Product_Code,      
  @Quantity,      
  @Batch_Code,      
  @SalePrice,      
  @FlagWord,      
  @UOM,      
  @UOMQty,      
  @UOMPrice)    


