CREATE PROCEDURE SP_Get_Pending_StockOut          
(          
 @Product_Code nvarchar(15)          
)          
AS          
BEGIN          
 SELECT ISNULL(SUM(Quantity),0) as StockOutQty         
 FROM StockOutAbstract INNER JOIN StockOutDetail           
   ON StockOutAbstract.StockOutID = StockOutDetail.StockOutID          
 WHERE ProductCode=@Product_Code AND DocumentDate >           
  (SELECT ISNULL(MAX(CreationDate),CAST( '01/01/1800' as datetime))    
   FROM Batch_Products      
   WHERE Product_Code=@Product_Code AND QuantityReceived > 0   
   AND (GRN_ID IS NOT NULL OR StockTransferID IS NOT NULL))          
END

