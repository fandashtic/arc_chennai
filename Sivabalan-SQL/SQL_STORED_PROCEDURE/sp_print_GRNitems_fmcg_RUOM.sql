CREATE procedure [dbo].[sp_print_GRNitems_fmcg_RUOM](@GRNID int)
AS

Declare @FREE As NVarchar(50)

Set @FREE = dbo.LookupDictionaryItem(N'Free', Default)

SELECT  "Item Code" = GRNDetail.Product_Code, "Item Name" = Items.ProductName,
	"Quantity" = Sum(GRNDetail.UOMQty), 
	"UOM" = UOM.Description, 
	"Rejected" = Sum(GRNDetail.UOMRejection),
	"Sale Price" = (Case When ItemCategories.Price_Option = 0 And Items.Track_Batches = 0 THEN Sum(Items.Sale_Price) ELSE NULL END), 
    "Purchase Price" = (Case When ItemCategories.Price_Option = 0 And Items.Track_Batches = 0 THEN Sum(Items.Purchase_Price) ELSE NULL END), 
    "Batch" = NULL, "Expiry" = NULL, "Free" = Cast(Sum(FreeQty) As Varchar), GRNDetail.Serial , NULL
FROM GRNDetail, Items, UOM, ItemCategories
WHERE   GRNID = @GRNID AND GRNDetail.Product_Code = Items.Product_Code
	AND GRNDetail.UOM *= UOM.UOM And ItemCategories.CategoryID = Items.CategoryID
GROUP BY GRNDetail.Serial, GRNDetail.Product_Code, Items.ProductName, GRNDetail.UOM, UOM.Description,
        ItemCategories.Price_Option, Items.Track_Batches
UNION ALL
SELECT  Batch_Products.Product_Code, Items.ProductName, 
	Batch_Products.UOMQty, 
	UOM.Description, 
	NULL, Batch_Products.SalePrice,
    Batch_Products.PurchasePrice,
	Batch_Products.Batch_Number, Batch_Products.Expiry, Null, GRNDetail.Serial , "Tax Suffered" = Batch_Products.TaxSuffered
FROM	Batch_Products, Items, ItemCategories, UOM, GRNDetail 
WHERE	Batch_Products.GRN_ID = @GRNID AND Batch_Products.Product_Code = Items.Product_Code
	AND ItemCategories.CategoryID = Items.CategoryID 
	AND (Items.Track_Batches = 1 OR ItemCategories.Price_Option = 1) 
	AND Batch_Products.Free = 0 And Batch_Products.UOMQty >0
	AND Batch_Products.UOM *= UOM.UOM
 	AND GRNDetail.GRNID = Batch_Products.GRN_ID
 	AND GRNDetail.Product_Code = Items.Product_Code 
UNION ALL
SELECT  Batch_Products.Product_Code, Items.ProductName, 
	Batch_Products.UOMQty, 
	UOM.Description, 
	NULL, Batch_Products.SalePrice,
    Batch_Products.PurchasePrice,
	Batch_Products.Batch_Number, Batch_Products.Expiry, @FREE, GRNDetail.Serial , "Tax Suffered" = Batch_Products.TaxSuffered
FROM	Batch_Products, Items, ItemCategories, UOM, GRNDetail
WHERE	Batch_Products.GRN_ID = @GRNID AND Batch_Products.Product_Code = Items.Product_Code
	AND ItemCategories.CategoryID = Items.CategoryID 
	AND (Items.Track_Batches = 1 OR ItemCategories.Price_Option = 1) 
	AND Batch_Products.Free = 1
	AND Batch_Products.UOM *= UOM.UOM
	AND GRNDetail.GRNID = Batch_Products.GRN_ID
	AND GRNDetail.Product_Code = Items.Product_Code 
ORDER BY GRNDetail.Serial, Items.ProductName, Batch
