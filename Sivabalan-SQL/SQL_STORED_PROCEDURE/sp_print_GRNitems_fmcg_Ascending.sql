CREATE PROCEDURE sp_print_GRNitems_fmcg_Ascending(@GRNID int)
AS

Declare @FREE As NVarchar(50)

Set @FREE = dbo.LookupDictionaryItem(N'Free', Default)

SELECT  "Item Code" = GRNDetail.Product_Code, "Item Name" = Items.ProductName,
	"Received" = Sum(GRNDetail.QuantityReceived), 
	"Rejected" = Sum(GRNDetail.QuantityRejected),
	"Sale Price" = (Case When ItemCategories.Price_Option = 0 And Items.Track_Batches = 0 THEN Sum(Items.Sale_Price) ELSE NULL END), 
	"Batch" = NULL, "Expiry" = NULL, "Free" = Cast(Sum(FreeQty)as nvarchar), NULL
FROM GRNDetail, Items, ItemCategories
WHERE   GRNID = @GRNID AND GRNDetail.Product_Code = Items.Product_Code And
 	ItemCategories.CategoryID = Items.CategoryID
GROUP BY  GRNDetail.Product_Code, Items.ProductName, ItemCategories.Price_Option, Items.Track_Batches 
UNION ALL
SELECT  Batch_Products.Product_Code, Items.ProductName, 
	Batch_Products.QuantityReceived, NULL, Batch_Products.SalePrice,
	Batch_Products.Batch_Number, Batch_Products.Expiry, Null, "Tax Suffered" = Batch_Products.TaxSuffered
FROM	Batch_Products, Items, ItemCategories, GRNDetail
WHERE	Batch_Products.GRN_ID = @GRNID AND Batch_Products.Product_Code = Items.Product_Code
	AND ItemCategories.CategoryID = Items.CategoryID 
	AND (Items.Track_Batches = 1 OR ItemCategories.Price_Option = 1) 
	AND Batch_Products.Free = 0 And Batch_Products.QuantityReceived >0
	AND GRNDetail.GRNID = Batch_Products.GRN_ID
	AND GRNDetail.Product_Code = Items.Product_Code
UNION ALL
SELECT  Batch_Products.Product_Code, Items.ProductName, 
	Batch_Products.QuantityReceived, NULL, Batch_Products.SalePrice,
	Batch_Products.Batch_Number, Batch_Products.Expiry, @FREE,  "Tax Suffered" = Batch_Products.TaxSuffered
FROM	Batch_Products, Items, ItemCategories, GRNDetail
WHERE	Batch_Products.GRN_ID = @GRNID AND Batch_Products.Product_Code = Items.Product_Code
	AND ItemCategories.CategoryID = Items.CategoryID 
	AND (Items.Track_Batches = 1 OR ItemCategories.Price_Option = 1) 
	AND Batch_Products.Free = 1
	AND GRNDetail.GRNID = Batch_Products.GRN_ID
	AND GRNDetail.Product_Code = Items.Product_Code
ORDER BY "Item Code",Items.ProductName, Batch








