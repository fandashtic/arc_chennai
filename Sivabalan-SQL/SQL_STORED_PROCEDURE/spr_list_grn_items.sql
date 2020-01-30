Create PROCEDURE spr_list_grn_items(@GRNID int)
AS
Begin
SELECT  1, "Item Code" = GRNDetail.Product_Code, "Item Name" = Items.ProductName,
	"Received" = (Sum(GRNDetail.QuantityReceived) + Sum(IsNull(FreeQty, 0))), 
	"Rejected" = Sum(GRNDetail.QuantityRejected),
	"Reason" = RejectionReason.Message, "Batch" = NULL, "Expiry" = NULL,
	"PKD" = NULL,
	"PFM" = NULL,
	"Net PTS" = NULL,
	"Original PTS" = NULL,
	"PTR" = NULL,
	"ECP" = NULL,
	"MRPPerPack" = NULL,
	"Special Price" = NULL
FROM GRNDetail
Inner Join Items On GRNDetail.Product_Code = Items.Product_Code
Left Outer Join  RejectionReason On GRNDetail.ReasonRejected = RejectionReason.MessageID
WHERE   GRNID = @GRNID 
GROUP BY GRNDetail.Product_Code, Items.ProductName, RejectionReason.Message
UNION ALL
SELECT  2, Batch_Products.Product_Code, Items.ProductName, 
	Sum(Batch_Products.QuantityReceived), 
	NULL, "Reason" = NULL,
	Batch_Products.Batch_Number, Batch_Products.Expiry,
	Batch_Products.PKD,
	Isnull(Batch_Products.PFM, 0),
	Isnull(Batch_Products.PFM, 0),
	isnull(Batch_Products.OrgPTS, 0),
	ISNULL(Batch_Products.PTR, 0), 
	ISNULL(Batch_Products.ECP, 0),
	ISNULL(Batch_Products.MRPPerPack, 0),
	ISNULL(Batch_Products.Company_Price, 0)
FROM	Batch_Products, Items, ItemCategories
WHERE	Batch_Products.GRN_ID = @GRNID AND Batch_Products.Product_Code = Items.Product_Code
	AND ItemCategories.CategoryID = Items.CategoryID 
	AND (Items.Track_Batches = 1 OR ItemCategories.Price_Option = 1)
	AND Batch_Products.QuantityReceived > 0
GROUP BY Batch_Products.Product_Code, Items.ProductName,
	Batch_Products.Batch_Number, Batch_Products.Expiry, Batch_Products.PKD,Batch_Products.PFM,
	Batch_Products.PTS,Batch_Products.OrgPTS, Batch_Products.PTR, Batch_Products.ECP,
	Batch_Products.MRPPerPack,Batch_Products.Company_Price
ORDER 	BY Items.ProductName, Batch
End
