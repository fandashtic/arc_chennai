create PROCEDURE [sp_save_Redemption_MUOM]    
 (@DocSerial int,@Type int, @FromPoint int,    
  @ToPoint int,@Value decimal(18,6),@ProductCode nvarchar(15),    
  @Active  int,@FreeUOM int = 0)    
AS INSERT INTO Redemption     
  ([DocSerial],  [Type],  [FromPoint],    
  [ToPoint],  [Value],  [ProductCode],    
  [Active],FreeUOM)     
VALUES     
 (@DocSerial, @Type, @FromPoint, @ToPoint, @Value,    
  @ProductCode, @Active,@FreeUOM) 

