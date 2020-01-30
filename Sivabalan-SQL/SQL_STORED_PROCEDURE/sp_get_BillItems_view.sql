
CREATE procedure sp_get_BillItems_view(@Bill_ID int) 
as
DECLARE @GRNID int
SELECT @GRNID = GRNID FROM BillAbstract WHERE BillID = @Bill_ID

Select  Batch_Products.Product_Code as "Code", Items.ProductName as "Name",
	Batch_Products.Batch_Number, Batch_Products.Expiry, Batch_Products.PTS,
	Batch_Products.PTR, Batch_Products.ECP, Batch_Products.Company_Price,
	(select BillDetail.PurchasePrice from billdetail where billid = @bill_id and BillDetail.Product_Code = Batch_Products.Product_Code), Batch_Products.QuantityReceived, (select BillDetail.Amount from billdetail where billid = @bill_id and BillDetail.Product_Code = Batch_Products.Product_Code)
FROM	Batch_Products, Items
WHERE   Batch_Products.GRN_ID = @GRNID AND
	Batch_Products.Product_Code = Items.Product_Code

