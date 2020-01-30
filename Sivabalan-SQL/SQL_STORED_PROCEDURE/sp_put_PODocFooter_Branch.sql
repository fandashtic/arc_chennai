Create PROCEDURE sp_put_PODocFooter_Branch 
 (@Product_Code  [nvarchar](15),    
  @Quantity  Decimal(18,6),    
  @PurchasePrice  Decimal(18,6),  
  @PONumber  [int],
  @Serial int=0
  )
AS     
 BEGIN    
 INSERT INTO [PODetailReceived]     
  ( [PONumber],    
  [Product_Code],    
  [Quantity],    
  [PurchasePrice],
  [Serial])   
 VALUES     
 (@PONumber,    
  @Product_Code,    
  @Quantity,    
  @PurchasePrice,
  @Serial)
 END    



