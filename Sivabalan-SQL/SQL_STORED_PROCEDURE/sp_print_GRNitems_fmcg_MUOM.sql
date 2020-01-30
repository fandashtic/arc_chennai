CREATE PROCEDURE sp_print_GRNitems_fmcg_MUOM(@GRNID int)  
AS  
SELECT  "Item Code" = GRNDetail.Product_Code, "Item Name" = Items.ProductName,    
"UOM2Quantity Received" = dbo.GetFirstLevelUOMQty(GRNDetail.Product_Code, Sum(GRNDetail.QuantityReceived)),    
"UOM2Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  GRNDetail.Product_Code )),    
"UOM1Quantity Received" = dbo.GetSecondLevelUOMQty(GRNDetail.Product_Code, Sum(GRNDetail.QuantityReceived)),    
"UOM1Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  GRNDetail.Product_Code )),    
"UOMQuantity Received" = dbo.GetLastLevelUOMQty(GRNDetail.Product_Code, Sum(GRNDetail.QuantityReceived)),    
"UOMDescription" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  GRNDetail.Product_Code )),      
"Rejected" = Sum(GRNDetail.QuantityRejected),  
"Sale Price" = (Case When ItemCategories.Price_Option = 0 And Items.Track_Batches = 0 THEN Sum(Items.Sale_Price) ELSE NULL END), 
"Purchase Price" = (Case When ItemCategories.Price_Option = 0 And Items.Track_Batches = 0 THEN Sum(Items.Purchase_Price) ELSE NULL END), 
"Batch" = NULL, "Expiry" = NULL, "Free" = Cast(Sum(FreeQty) As Varchar), GRNDetail.Serial , Null
FROM GRNDetail, Items, ItemCategories  
WHERE   GRNID = @GRNID AND GRNDetail.Product_Code = Items.Product_Code And ItemCategories.CategoryID = Items.CategoryID  
GROUP BY GRNDetail.Serial, GRNDetail.Product_Code, Items.ProductName, ItemCategories.Price_Option, Items.Track_Batches    
UNION ALL  
SELECT  Batch_Products.Product_Code, Items.ProductName,   
 dbo.GetFirstLevelUOMQty(Batch_Products.Product_Code, Batch_Products.QuantityReceived),    
 (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  Batch_Products.Product_Code )),    
 dbo.GetSecondLevelUOMQty(Batch_Products.Product_Code, Batch_Products.QuantityReceived),    
 (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  Batch_Products.Product_Code )),    
 dbo.GetLastLevelUOMQty(Batch_Products.Product_Code, Batch_Products.QuantityReceived),    
 (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  Batch_Products.Product_Code )),      
 NULL, Batch_Products.SalePrice,
 Batch_Products.PurchasePrice,  
 Batch_Products.Batch_Number, Batch_Products.Expiry, Null, GRNDetail.Serial , "Tax Suffered" = Batch_Products.TaxSuffered
FROM Batch_Products, Items, ItemCategories, GRNDetail  
WHERE Batch_Products.GRN_ID = @GRNID AND Batch_Products.Product_Code = Items.Product_Code  
 AND ItemCategories.CategoryID = Items.CategoryID   
 AND (Items.Track_Batches = 1 OR ItemCategories.Price_Option = 1)   
 AND Batch_Products.Free = 0  
 AND GRNDetail.GRNID = Batch_Products.GRN_ID
 AND GRNDetail.Product_Code = Items.Product_Code 
UNION ALL  
SELECT  Batch_Products.Product_Code, Items.ProductName,   
 dbo.GetFirstLevelUOMQty(Batch_Products.Product_Code, Batch_Products.QuantityReceived),    
(Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  Batch_Products.Product_Code )),    
 dbo.GetSecondLevelUOMQty(Batch_Products.Product_Code, Batch_Products.QuantityReceived),    
 (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  Batch_Products.Product_Code )),    
 dbo.GetLastLevelUOMQty(Batch_Products.Product_Code, Batch_Products.QuantityReceived),    
 (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  Batch_Products.Product_Code )),      
 NULL, Batch_Products.SalePrice,
 Batch_Products.PurchasePrice,  
 Batch_Products.Batch_Number, Batch_Products.Expiry, 'Free', GRNDetail.Serial , "Tax Suffered" = Batch_Products.TaxSuffered
FROM Batch_Products, Items, ItemCategories, GRNDetail  
WHERE Batch_Products.GRN_ID = @GRNID AND Batch_Products.Product_Code = Items.Product_Code  
 AND ItemCategories.CategoryID = Items.CategoryID   
 AND (Items.Track_Batches = 1 OR ItemCategories.Price_Option = 1)   
 AND Batch_Products.Free = 1  
 AND GRNDetail.GRNID = Batch_Products.GRN_ID
 AND GRNDetail.Product_Code = Items.Product_Code 
ORDER  BY GRNDetail.Serial, Items.ProductName, Batch  
