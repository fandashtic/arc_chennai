CREATE procedure [dbo].[spr_list_grn_items_FMCG](@GRNID int)
AS
SELECT  1, "Item Code" = GRNDetail.Product_Code, "Item Name" = Items.ProductName,
	"Received" = (Sum(GRNDetail.QuantityReceived) + Sum(IsNull(GRNDetail.FreeQty, 0))), 
	"Rejected" = Sum(GRNDetail.QuantityRejected),
	"Reason" = RejectionReason.Message, "Batch" = NULL, "Expiry" = NULL,
	"PKD" = NULL, "Sale Price" = NULL, "Purchase Price" = NULL
FROM GRNDetail, Items, RejectionReason
WHERE   GRNID = @GRNID AND GRNDetail.Product_Code = Items.Product_Code AND
	GRNDetail.ReasonRejected *= RejectionReason.MessageID
GROUP BY GRNDetail.Product_Code, Items.ProductName, RejectionReason.Message
UNION ALL
SELECT  2, Batch_Products.Product_Code, Items.ProductName, 
	Sum(Batch_Products.QuantityReceived), 
	NULL, "Reason" = NULL,
	Batch_Products.Batch_Number, Batch_Products.Expiry,
	Batch_Products.PKD,
	ISNULL(Batch_Products.SalePrice, 0), "Purchase Price" = Batch_Products.PurchasePrice
FROM	Batch_Products, Items, ItemCategories
WHERE	Batch_Products.GRN_ID = @GRNID AND Batch_Products.Product_Code = Items.Product_Code
	AND ItemCategories.CategoryID = Items.CategoryID 
	AND (Items.Track_Batches = 1 OR ItemCategories.Price_Option = 1)
	AND Batch_Products.QuantityReceived > 0
GROUP BY Batch_Products.Product_Code, Items.ProductName, Batch_Products.Batch_Number,
	Batch_Products.Expiry, Batch_Products.PKD, Batch_Products.SalePrice, Batch_Products.PurchasePrice
ORDER 	BY Items.ProductName, Batch
