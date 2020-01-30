CREATE PROCEDURE sp_acc_rpt_grnitemsfmcg(@GRNID int)
as
Declare @SPECIALCASE Int
Set @SPECIALCASE = 5
SELECT  "Item Code" =Batch_Products.Product_Code, "Item Name" =Items.ProductName, 
	"Received" =Sum(Batch_Products.QuantityReceived), 
	"Rejected"=NULL, "Reason" = NULL,
	"Batch"=Batch_Products.Batch_Number,"Expiry" = Batch_Products.Expiry,
	"PKD"=Batch_Products.PKD,
	"Purchase Price" = ISNULL(Batch_Products.PurchasePrice, 0),
	"Sale Price" = ISNULL(Batch_Products.SalePrice,0),@SPECIALCASE
FROM	Batch_Products, Items, ItemCategories
WHERE	Batch_Products.GRN_ID = @GRNID AND Batch_Products.Product_Code = Items.Product_Code
	AND ItemCategories.CategoryID = Items.CategoryID 
	--AND (Items.Track_Batches = 1 OR ItemCategories.Price_Option = 1)
	AND Batch_Products.QuantityReceived > 0
GROUP BY Batch_Products.Product_Code, Items.ProductName,
	Batch_Products.Batch_Number, Batch_Products.Expiry, Batch_Products.PKD,
	Batch_Products.PurchasePrice, Batch_Products.PurchaseTax,
	Batch_Products.SalePrice,Batch_Products.TaxSuffered
ORDER 	BY Items.ProductName, Batch







