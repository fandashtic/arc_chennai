CREATE PROCEDURE sp_acc_prn_grnitemsfmcgUOM_count(@GRNID int)
as
SELECT  count(1)
FROM	Batch_Products, Items, ItemCategories,UOM
WHERE	Batch_Products.GRN_ID = @GRNID AND Batch_Products.Product_Code = Items.Product_Code
	AND ItemCategories.CategoryID = Items.CategoryID 
	and UOM.UOM = Batch_Products.UOM
	AND Batch_Products.QuantityReceived > 0

