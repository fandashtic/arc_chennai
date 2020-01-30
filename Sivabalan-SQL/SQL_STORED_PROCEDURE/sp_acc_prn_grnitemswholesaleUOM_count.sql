CREATE Procedure sp_acc_prn_grnitemswholesaleUOM_count(@GRNID int)
aS
SELECT  Count(1)
FROM	Batch_Products, Items, ItemCategories,UOM
WHERE	Batch_Products.GRN_ID = @GRNID AND Batch_Products.Product_Code = Items.Product_Code
	AND ItemCategories.CategoryID = Items.CategoryID and batch_Products.UOM = UOM.UOM
	AND Batch_Products.QuantityReceived > 0

