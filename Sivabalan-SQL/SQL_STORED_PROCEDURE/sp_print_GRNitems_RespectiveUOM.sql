CREATE procedure [dbo].[sp_print_GRNitems_RespectiveUOM](@GRNID int)      
AS  

Declare @FREE As NVarchar(50)

Set @FREE = dbo.LookupDictionaryItem(N'Free', Default)

SELECT  "Product Code" = GRNDetail.Product_Code, "Product Name" = Items.ProductName,  
 "Quantity" = Sum(GrnDetail.QuantityReceived), "Rejected" = Sum(GRNDetail.UOMRejection),
 "UOM" = '',  
 "Sale Price" = (Case When ItemCategories.Price_Option = 0 And Items.Track_Batches = 0 THEN Sum(Items.SALE_PRICE) ELSE NULL END), 
 "Batch Number" = NULL, "Expiry" = NULL,  
 "PTS" = (Case When ItemCategories.Price_Option = 0 And Items.Track_Batches = 0 THEN Sum(Items.PTS) ELSE NULL END), 
 "PTR" = (Case When ItemCategories.Price_Option = 0 And Items.Track_Batches = 0 THEN Sum(Items.PTR) ELSE NULL END), 
 "ECP" = (Case When ItemCategories.Price_Option = 0 And Items.Track_Batches = 0 THEN Sum(Items.ECP) ELSE NULL END), 
 "Company Price" = (Case When ItemCategories.Price_Option = 0 And Items.Track_Batches = 0 THEN Sum(Items.Company_Price) ELSE NULL END),   
 "Free" = Case  when Sum(FreeQty) >0 then Cast(Sum(FreeQty) As nVarchar) else '' End
FROM GRNDetail, Items, ItemCategories, UOM  
WHERE   GRNID = @GRNID AND GRNDetail.Product_Code = Items.Product_Code And
ItemCategories.CategoryID = Items.CategoryID And Items.UOM *= UOM.UOM And
ItemCategories.Price_Option = 0 And Items.Track_Batches = 0
GROUP BY GRNDetail.Product_Code, Items.ProductName, Items.CategoryID, 
ItemCategories.Price_Option, Items.Track_Batches, UOM.Description
UNION ALL
SELECT "Product Code" = Batch_Products.Product_Code,"Product Name" = Items.ProductName,       
"Quantity" = Batch_Products.UOMQty, "Rejected" =  NULL,"UOM" = UOM.Description, 
"Sale Price" = Batch_Products.UOMPrice,      
"Batch Number" = Batch_Products.Batch_Number,"Expiry" = Batch_Products.Expiry,      
"PTS" = isnull(Batch_Products.PTS, 0), "PTR" = ISNULL(Batch_Products.PTR, 0),       
"ECP" = ISNULL(Batch_Products.ECP, 0),       
"Company Price" = ISNULL(Batch_Products.Company_Price, 0),       
"Free" = Case IsNull(Batch_Products.Free, 0) When 1 Then @FREE Else N'' End
FROM Batch_Products, Items, ItemCategories, UOM      
WHERE Batch_Products.GRN_ID = @GRNID AND Batch_Products.Product_Code = Items.Product_Code      
 AND ItemCategories.CategoryID = Items.CategoryID       
 AND Batch_Products.UOM *= UOM.UOM  
 AND (Items.Track_Batches = 1 OR ItemCategories.Price_Option = 1)       
 AND Batch_Products.Free = 0 and Batch_Products.UOMQty > 0     
UNION ALL      
SELECT  "Product Code" =  Batch_Products.Product_Code, "Product Name" = Items.ProductName,       
Batch_Products.UOMQty,NULL,UOM.Description, Batch_Products.UOMPrice,      
Batch_Products.Batch_Number, Batch_Products.Expiry,      
isnull(Batch_Products.PTS, 0), ISNULL(Batch_Products.PTR, 0),       
ISNULL(Batch_Products.ECP, 0),       
ISNULL(Batch_Products.Company_Price, 0),       
Case IsNull(Batch_Products.Free, 0) When 1 Then @FREE Else N'' End
FROM Batch_Products, Items, ItemCategories, UOM   
WHERE Batch_Products.GRN_ID = @GRNID AND Batch_Products.Product_Code = Items.Product_Code      
 AND ItemCategories.CategoryID = Items.CategoryID      
 AND Batch_Products.UOM *= UOM.UOM   
 AND (Items.Track_Batches = 1 OR ItemCategories.Price_Option = 1)       
 AND Batch_Products.Free = 1      
ORDER  BY Items.ProductName
