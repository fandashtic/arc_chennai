CREATE PROCEDURE SP_Save_StockOutDetail  
(  
 @StockOutID Int,  
 @ProductCode nvarchar(15),  
 @Quantity Decimal(18,6),  
 @TotalStock Decimal(18,6)
)  
As        
BEGIN  
  
 INSERT INTO StockOutDetail   
 ( StockOutID,  
   ProductCode,   
   Quantity,
   TotalStock  
 )VALUES  
 (  
   @StockOutID,  
   @ProductCode,   
   @Quantity,
   @TotalStock  
 )  
END       

