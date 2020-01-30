CREATE procedure [dbo].[sp_print_GRNItems_Ascending](@GRNID int)  
AS  

Declare @FREE As NVarchar(50)

Set @FREE = dbo.LookupDictionaryItem(N'Free', Default)

SELECT  "Item Code" = GRNDetail.Product_Code, "Item Name" = Items.ProductName,  
 "Received" = Sum(GRNDetail.QuantityReceived), "Rejected" = Sum(GRNDetail.QuantityRejected),
 "Sale Price" = (Case When ItemCategories.Price_Option = 0 And Items.Track_Batches = 0 THEN Sum(Items.SALE_PRICE) ELSE NULL END), 
 "Batch" = NULL, 
 "Expiry" = NULL,  
 "PTS" = (Case When ItemCategories.Price_Option = 0 And Items.Track_Batches = 0 THEN Sum(Items.PTS) ELSE NULL END), 
 "PTR" = (Case When ItemCategories.Price_Option = 0 And Items.Track_Batches = 0 THEN Sum(Items.PTR) ELSE NULL END), 
 "ECP" = (Case When ItemCategories.Price_Option = 0 And Items.Track_Batches = 0 THEN Sum(Items.ECP) ELSE NULL END), 
 "Special Price" = (Case When ItemCategories.Price_Option = 0 And Items.Track_Batches = 0 THEN Sum(Items.Company_Price) ELSE NULL END),   
 "Free" = cast(Sum(FreeQty)as nvarchar),  NULL
FROM GRNDetail, Items, ItemCategories, UOM
WHERE   GRNID = @GRNID AND GRNDetail.Product_Code = Items.Product_Code And
ItemCategories.CategoryID = Items.CategoryID And Items.UOM *= UOM.UOM
AND (Items.Track_Batches = 0 AND ItemCategories.Price_Option = 0)  
GROUP BY GRNDetail.Product_Code, Items.ProductName, Items.CategoryID, 
ItemCategories.Price_Option, Items.Track_Batches, UOM.Description

UNION ALL  
SELECT  "Item Code" = Batch_Products.Product_Code, "Item Name" =Items.ProductName,   
Batch_Products.QuantityReceived, NULL, Batch_Products.SalePrice,  
Batch_Products.Batch_Number, Batch_Products.Expiry,  
isnull(Batch_Products.PTS, 0), ISNULL(Batch_Products.PTR, 0),   
ISNULL(Batch_Products.ECP, 0),   
ISNULL(Batch_Products.Company_Price, 0),   
NULL,  "Tax Suffered" = Batch_Products.TaxSuffered
FROM Batch_Products, Items, ItemCategories, GRNDetail  
WHERE Batch_Products.GRN_ID = @GRNID AND Batch_Products.Product_Code = Items.Product_Code  
AND ItemCategories.CategoryID = Items.CategoryID   
AND (Items.Track_Batches = 1 OR ItemCategories.Price_Option = 1)   
AND Batch_Products.Free = 0  And Batch_Products.QuantityReceived >0
AND GRNDetail.GRNID = Batch_Products.GRN_ID
AND GRNDetail.Product_Code = Items.Product_Code 
UNION ALL  
SELECT  "Item Code" = Batch_Products.Product_Code, "Item Name" = Items.ProductName,   
Batch_Products.QuantityReceived, NULL, Batch_Products.SalePrice,  
Batch_Products.Batch_Number, Batch_Products.Expiry,  
isnull(Batch_Products.PTS, 0), ISNULL(Batch_Products.PTR, 0),   
ISNULL(Batch_Products.ECP, 0),   
ISNULL(Batch_Products.Company_Price, 0),   
@FREE,"Tax Suffered" = Batch_Products.TaxSuffered
FROM Batch_Products, Items, ItemCategories, GRNDetail  
WHERE Batch_Products.GRN_ID = @GRNID AND Batch_Products.Product_Code = Items.Product_Code  
AND ItemCategories.CategoryID = Items.CategoryID   
AND (Items.Track_Batches = 1 OR ItemCategories.Price_Option = 1)   
AND Batch_Products.Free = 1
AND GRNDetail.GRNID = Batch_Products.GRN_ID
AND GRNDetail.Product_Code = Items.Product_Code   
ORDER  BY "Item Code",Items.ProductName, Batch
