CREATE PROCEDURE spr_get_total_bookstock(@PRODUCT_CODE nvarchar(15),  
@VanDocID integer=0)  
AS  
if(@VanDocID=0)  
Begin  
 SELECT SUM(Quantity) FROM Batch_Products   
 WHERE  Product_Code = @PRODUCT_CODE AND   
 (Expiry IS NULL OR Expiry >= GetDate()) AND  
 ISNULL(Damage, 0) = 0  
End  
Else  
Begin  
 Select  SUM(VanStatementDetail.Pending)  
 From VanStatementDetail  
 where VanStatementDetail.DocSerial = @VanDocID  
 and VanStatementDetail.Product_Code= @PRODUCT_CODE AND         
 VanStatementDetail.Pending > 0      
End              
