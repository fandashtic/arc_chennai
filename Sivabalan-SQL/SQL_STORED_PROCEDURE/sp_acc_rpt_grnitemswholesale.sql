CREATE PROCEDURE sp_acc_rpt_grnitemswholesale(@GRNID int)
AS
Declare @SPECIALCASE Int
Set @SPECIALCASE = 5
SELECT  "Item Code" =Batch_Products.Product_Code, "Item Name" =Items.ProductName, 
	"Received" =Sum(Batch_Products.QuantityReceived), 
	"Rejected"=NULL, "Reason" = NULL,
	"Batch"=Batch_Products.Batch_Number,"Expiry" = Batch_Products.Expiry,
	"PKD"=Batch_Products.PKD,
	"PTS" = case when dbo.getcategoryoption(max(Items.CategoryID)) = 1 then
	isnull(Batch_Products.PTS, 0)else isnull(max(Items.PTS), 0) end, 
	"PTR" =case when dbo.getcategoryoption(Items.CategoryID) = 1 then
	ISNULL(Batch_Products.PTR, 0) else ISNULL(max(Items.PTR), 0) end, 
	"ECP" = case when dbo.getcategoryoption(max(Items.CategoryID)) = 1 then
	ISNULL(Batch_Products.ECP, 0) else ISNULL(max(Items.ECP), 0) end,
	"Special Price" = case when dbo.getcategoryoption(max(Items.CategoryID)) = 1 then
	ISNULL(Batch_Products.Company_Price, 0) else ISNULL(max(Items.Company_Price), 0) end,
	@SPECIALCASE
FROM	Batch_Products, Items, ItemCategories
WHERE	Batch_Products.GRN_ID = @GRNID AND Batch_Products.Product_Code = Items.Product_Code
	AND ItemCategories.CategoryID = Items.CategoryID 
	--AND (Items.Track_Batches = 1 OR ItemCategories.Price_Option = 1)
	AND Batch_Products.QuantityReceived > 0
GROUP BY Batch_Products.Product_Code, Items.ProductName,Items.CategoryID,
	Batch_Products.Batch_Number, Batch_Products.Expiry, Batch_Products.PKD,
	Batch_Products.PTS, Batch_Products.PTR, Batch_Products.ECP,
	Batch_Products.Company_Price
ORDER 	BY Items.ProductName, Batch
