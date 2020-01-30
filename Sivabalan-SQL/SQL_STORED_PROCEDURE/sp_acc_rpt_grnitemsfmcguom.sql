CREATE PROCEDURE sp_acc_rpt_grnitemsfmcguom(@GRNID int)
as
Declare @SPECIALCASE Int
Set @SPECIALCASE = 5
SELECT  "Item Code" =Batch_Products.Product_Code, "Item Name" =Items.ProductName, 
	"Description"= Max(UOM.[Description]),
	"UOM Quantity" = Max(UOMQty),
	"Batch"=Batch_Products.Batch_Number,"Expiry" = Batch_Products.Expiry,
	"PKD"=Batch_Products.PKD,
	"UOM Price" = Max(UOMPrice),
	"Purchase Price" = ISNULL(Batch_Products.PurchasePrice, 0),
	"Sale Price" = ISNULL(Batch_Products.SalePrice,0),@SPECIALCASE
FROM	Batch_Products, Items, ItemCategories,UOM
WHERE	Batch_Products.GRN_ID = @GRNID AND Batch_Products.Product_Code = Items.Product_Code
	AND ItemCategories.CategoryID = Items.CategoryID 
	and UOM.UOM = Batch_Products.UOM
	--AND (Items.Track_Batches = 1 OR ItemCategories.Price_Option = 1)
	AND Batch_Products.QuantityReceived > 0
GROUP BY Batch_Products.Product_Code, Items.ProductName,
	Batch_Products.Batch_Number, Batch_Products.Expiry, Batch_Products.PKD,
	Batch_Products.PurchasePrice, Batch_Products.PurchaseTax,
	Batch_Products.SalePrice,Batch_Products.TaxSuffered,
	UOM.UOM
ORDER 	BY Items.ProductName, Batch


