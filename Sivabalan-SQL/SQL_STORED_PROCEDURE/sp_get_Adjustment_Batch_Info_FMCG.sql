CREATE PROCEDURE sp_get_Adjustment_Batch_Info_FMCG(@ITEMCODE NVARCHAR(15), @TYPE int = 1)            
AS            
IF @TYPE = 0            
	SELECT Batch_Number, Expiry, SUM(Quantity), PurchasePrice, 0, 0, isnull(Free, 0), PKD, IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0)           
	FROM Batch_Products            
	WHERE  Batch_Products.Product_Code = @ITEMCODE AND ISNULL(Damage, 0) = 0            
	GROUP BY Batch_Number, Expiry, PurchasePrice, isnull(Free, 0), PKD,        
  	         IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0)
	Order By Isnull(Free, 0), isnull(Expiry,'9999'), PKD, MIN(Batch_Code) 
ELSE IF @TYPE = 2  
	SELECT Batch_Number, Expiry, SUM(Quantity), PurchasePrice, 0, ISNULL(Damage, 0),  
	isnull(Free, 0), PKD, IsNull(TaxSuffered, 0), Isnull(ApplicableOn,0), Isnull(Partofpercentage,0) 
 	FROM Batch_Products  
	WHERE  Batch_Products.Product_Code = @ITEMCODE  and Isnull(GRN_ID, 0) = 0 and Isnull(StockTransferID, 0) = 0           
	GROUP BY isnull(Free, 0),Batch_Number, Expiry, PurchasePrice, ISNULL(Damage, 0), PKD,           
		       IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0)
	Order By Isnull(Free, 0), isnull(Expiry,'9999'), PKD, MIN(Batch_Code) 
ELSE            
	SELECT Batch_Number, Expiry, SUM(Quantity), PurchasePrice, 0, ISNULL(Damage, 0),             
	isnull(Free, 0), PKD, IsNull(TaxSuffered, 0), Isnull(ApplicableOn,0), Isnull(Partofpercentage,0) 
 	FROM Batch_Products            
	WHERE  Batch_Products.Product_Code = @ITEMCODE            
	GROUP BY isnull(Free, 0),Batch_Number, Expiry, PurchasePrice, ISNULL(Damage, 0), PKD,        
		       IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0)
	Order By Isnull(Free, 0), isnull(Expiry,'9999'), PKD, MIN(Batch_Code) 
  
  


