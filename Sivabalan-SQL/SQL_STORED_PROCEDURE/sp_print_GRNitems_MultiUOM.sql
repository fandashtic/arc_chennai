CREATE PROCEDURE sp_print_GRNitems_MultiUOM(@GRNID int)      
AS      
  
Declare @FREE As NVarchar(50)  
  
Set @FREE = dbo.LookupDictionaryItem(N'Free', Default)  
  
SELECT  "Item Code" = GRNDetail.Product_Code, "Item Name" = Items.ProductName,    
 "UOM2Quantity" = dbo.GetFirstLevelUOMQty(GRNDetail.Product_Code, Sum(GRNDetail.QuantityReceived)),    
 "UOM2Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Item Where Item.Product_Code =  GRNDetail.Product_Code)),    
 "UOM1Quantity" = dbo.GetSecondLevelUOMQty(GRNDetail.Product_Code, Sum(GRNDetail.QuantityReceived)),    
 "UOM1Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Item Where Item.Product_Code =  GRNDetail.Product_Code)),    
 "UOMQuantity" = dbo.GetLastLevelUOMQty(GRNDetail.Product_Code, Sum(GRNDetail.QuantityReceived)),    
 "UOMDescription" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Item Where Item.Product_Code =  GRNDetail.Product_Code)),      
 "Sale Price" = (Case When ItemCategories.Price_Option = 0 And Items.Track_Batches = 0 THEN Sum(Items.SALE_PRICE) ELSE NULL END),   
 "Batch Number" = NULL, "Expiry" = NULL,    
 "PTS" = (Case When ItemCategories.Price_Option = 0 And Items.Track_Batches = 0 THEN Sum(Items.PTS) ELSE NULL END),   
 "PTR" = (Case When ItemCategories.Price_Option = 0 And Items.Track_Batches = 0 THEN Sum(Items.PTR) ELSE NULL END),   
 "ECP" = (Case When ItemCategories.Price_Option = 0 And Items.Track_Batches = 0 THEN Sum(Items.ECP) ELSE NULL END),   
 "Company Price" = (Case When ItemCategories.Price_Option = 0 And Items.Track_Batches = 0 THEN Sum(Items.Company_Price) ELSE NULL END),     
 "Free" = Cast(Sum(FreeQty) As nvarchar), NULL  
FROM GRNDetail, Items, ItemCategories  
WHERE   GRNID = @GRNID AND GRNDetail.Product_Code = Items.Product_Code And  
ItemCategories.CategoryID = Items.CategoryID  
And ItemCategories.Price_Option = 0 And Items.Track_Batches = 0
GROUP BY GRNDetail.Product_Code, Items.ProductName, Items.CategoryID,   
ItemCategories.Price_Option, Items.Track_Batches  
UNION ALL  
SELECT  "Item Code"= Batch_Products.Product_Code,"Item Name"= Items.ProductName,       
"UOM2Quantity"= dbo.GetFirstLevelUOMQty(Batch_Products.Product_Code, Sum(Batch_Products.QuantityReceived)),    
"UOM2Description"= (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  Batch_Products.Product_Code )),    
"UOM1Quantity"= dbo.GetSecondLevelUOMQty(Batch_Products.Product_Code, Sum(Batch_Products.QuantityReceived)),    
"UOM1Description"= (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  Batch_Products.Product_Code )),    
"UOMQuantity"= dbo.GetLastLevelUOMQty(Batch_Products.Product_Code, Sum(Batch_Products.QuantityReceived)),    
"UOMDescription"= (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  Batch_Products.Product_Code )),      
"Sale Price"= Batch_Products.SalePrice,      
"Batch Number"= Batch_Products.Batch_Number,"Expiry"= Batch_Products.Expiry,      
"PTS"= isnull(Batch_Products.PTS, 0), "PTR"= ISNULL(Batch_Products.PTR, 0),       
"ECP"= ISNULL(Batch_Products.ECP, 0),       
"Company_Price"= ISNULL(Batch_Products.Company_Price, 0),       
"Free"= Case IsNull(Batch_Products.Free, 0) When 1 Then @FREE Else N'' End , "TaxSuffered"= Batch_Products.TaxSuffered  
FROM Batch_Products, Items, ItemCategories      
WHERE Batch_Products.GRN_ID = @GRNID AND Batch_Products.Product_Code = Items.Product_Code      
 AND ItemCategories.CategoryID = Items.CategoryID       
 AND (Items.Track_Batches = 1 OR ItemCategories.Price_Option = 1)       
 AND Batch_Products.Free = 0      
Group by Batch_Products.Product_Code, Items.ProductName,    
Batch_Products.SalePrice,  Batch_Products.Batch_Number, Batch_Products.Expiry ,    
Batch_Products.PTS,Batch_Products.PTR, Batch_Products.ECP, Batch_Products.Company_Price, Batch_Products.Free  , Batch_Products.TaxSuffered  
UNION ALL      
SELECT  "Item Code"= Batch_Products.Product_Code, "Item Name"= Items.ProductName,      
dbo.GetFirstLevelUOMQty(Batch_Products.Product_Code, Sum(Batch_Products.QuantityReceived)),    
(Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  Batch_Products.Product_Code )),    
dbo.GetSecondLevelUOMQty(Batch_Products.Product_Code, Sum(Batch_Products.QuantityReceived)),    
(Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  Batch_Products.Product_Code )),    
dbo.GetLastLevelUOMQty(Batch_Products.Product_Code, Sum(Batch_Products.QuantityReceived)),    
(Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  Batch_Products.Product_Code )),      
Batch_Products.SalePrice,      
 Batch_Products.Batch_Number, Batch_Products.Expiry,      
isnull(Batch_Products.PTS, 0), ISNULL(Batch_Products.PTR, 0),       
ISNULL(Batch_Products.ECP, 0),       
ISNULL(Batch_Products.Company_Price, 0),       
Case IsNull(Batch_Products.Free, 0) When 1 Then @FREE Else N'' End , "TaxSuffered"= Batch_Products.TaxSuffered  
FROM Batch_Products, Items, ItemCategories      
WHERE Batch_Products.GRN_ID = @GRNID AND Batch_Products.Product_Code = Items.Product_Code      
 AND ItemCategories.CategoryID = Items.CategoryID       
 AND (Items.Track_Batches = 1 OR ItemCategories.Price_Option = 1)       
 AND Batch_Products.Free = 1      
Group by Batch_Products.Product_Code, Items.ProductName,    
Batch_Products.SalePrice,  Batch_Products.Batch_Number, Batch_Products.Expiry ,    
Batch_Products.PTS,Batch_Products.PTR, Batch_Products.ECP, Batch_Products.Company_Price, Batch_Products.Free  , Batch_Products.TaxSuffered  
ORDER  BY Items.ProductName    
  
  
  


