CREATE PROCEDURE [sp_save_Redemption]  
 (@DocSerial int,@Type int, @FromPoint int,  
  @ToPoint int,@Value decimal(18,6),@ProductCode nvarchar(15),  
  @Active  int)  
AS INSERT INTO Redemption   
  ([DocSerial],  [Type],  [FromPoint],  
  [ToPoint],  [Value],  [ProductCode],  
  [Active])   
VALUES   
 (@DocSerial, @Type, @FromPoint, @ToPoint, @Value,  
  @ProductCode, @Active)  
  
  


