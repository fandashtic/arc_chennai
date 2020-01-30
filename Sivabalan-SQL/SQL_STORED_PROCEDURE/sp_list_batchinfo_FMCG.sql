CREATE procedure sp_list_batchinfo_FMCG(@ItemCode nvarchar(15))        
as         
SELECT Batch_Number, Expiry, SUM(Quantity),         
PurchasePrice,PKD, IsNull(Free, 0),        
SalePrice, IsNull(TaxSuffered, 0),IsNull(ApplicableOn,0),IsNull(PartOfPercentage,0)              
FROM Batch_Products        
WHERE  Batch_Products.Product_Code = @ITEMCODE And Quantity > 0 And ISNULL(Damage, 0) = 0        
GROUP BY Batch_Number, Expiry, PurchasePrice, SalePrice, PKD, IsNull(Free, 0),         
IsNull(TaxSuffered, 0),IsNull(ApplicableOn,0),IsNull(PartOfPercentage,0)      
HAVING SUM(Quantity) > 0        
Order By IsNull(Free, 0), IsNull(Expiry,'9999'), PKD, MIN(Batch_Code)     




