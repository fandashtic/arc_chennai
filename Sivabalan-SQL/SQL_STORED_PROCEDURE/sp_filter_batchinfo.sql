CREATE Procedure sp_filter_batchinfo (@ItemCode nvarchar(15), @Batch_Number nVarchar(128))        
As        
SELECT A.* FROM (
SELECT Batch_Number, Expiry, SUM(Quantity) [Quantity],
PTR,  
PKD,  
IsNull(Free, 0) [FREE], Min(Batch_Code) [Batch_Code], MRPPerPack
FROM Batch_Products        
WHERE  Batch_Products.Product_Code = @ItemCode And         
Quantity > 0 And ISNULL(Damage, 0) = 0        
GROUP BY isnull(Free, 0),Batch_Number, Expiry, PTR, PKD, MRPPerPack    
HAVING SUM(Quantity) > 0        
Union
SELECT Batch_Number, Expiry, SUM(Quantity)[Quantity],         
PTR,  
PKD,  
IsNull(Free, 0) [FREE], Min(Batch_Code)[Batch_Code], MRPPerPack
FROM Batch_Products        
WHERE  Batch_Products.Product_Code = @ItemCode And  Quantity > 0        
And ISNULL(Damage, 0) = 0        
And Batch_Number in (Select  Distinct Batch_Number From VanStatementDetail)
And Batch_Number = @Batch_Number
GROUP BY isnull(Free, 0),Batch_Number, Expiry, PTR, PKD, MRPPerPack) A 
Order By IsNull(Free, 0), IsNull(Expiry,'9999'), PKD, Batch_Code
