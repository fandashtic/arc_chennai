CREATE PROCEDURE sp_list_expiredItems(@VendorID nVarchar(50), @DATE datetime)
AS
SELECT Batch_Products.Product_Code, Items.ProductName, Batch_Products.Batch_Number,  
Batch_Products.Expiry, Batch_Products.PurchasePrice, SUM(Batch_Products.Quantity - ISNULL(ClaimedAlready, 0)),
Max(Batch_Products.TaxSuffered)
FROM Batch_Products, Items  
WHERE Batch_Products.Product_Code = Items.Product_Code AND  
Batch_Products.Expiry IS NOT NULL AND  
Batch_Products.Expiry <= @DATE AND  
(ISNULL(Batch_Products.Damage,0) = 0) AND  
(ISNULL(Batch_Products.Flags, 0) & 1) = 0 And  
Batch_Products.Quantity - ISNULL(ClaimedAlready, 0) > 0 AND   
(Isnull((Select Count(*) From GrnAbstract Where GrnAbstract.GrnID = Batch_Products.GRN_ID AND    
GrnAbstract.VendorID = @VendorID),0) > 0 Or Isnull(Batch_Products.GRN_ID,0) = 0)  
GROUP BY Batch_Products.Product_Code, Items.ProductName, Batch_Products.Batch_Number, Batch_Products.Expiry,  
Batch_Products.PurchasePrice  
