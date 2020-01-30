
CREATE PROCEDURE spr_price_variance(@FROMDATE datetime,
				    @TODATE datetime)
AS
select  PODetail.Product_Code, "Item Code" = podetail.product_code, 
	"Item Name" = Items.ProductName,
	"PO Price" = podetail.purchaseprice, 
	"Bill Price" = BillDetail.PurchasePrice, 
	"PONumber" = 
	POPrefix.Prefix + CAST(POAbstract.DocumentID AS nvarchar),
	"BillID" = 
	BillPrefix.Prefix + CAST(GRNAbstract.NewBillID AS nvarchar)
FROM POAbstract, GRNAbstract, PODetail, BillAbstract, BillDetail, Items,
	VoucherPrefix BillPrefix, VoucherPrefix POPrefix
WHERE   POAbstract.GRNID = GRNAbstract.GRNID AND 
	POAbstract.PONumber = PODetail.PONumber	AND 
	BillAbstract.BillID = GRNAbstract.BillID AND 
	BillDetail.BillID = BillAbstract.BillID	AND 
	PODetail.Product_Code = Items.Product_Code AND
	PODetail.Product_Code = BillDetail.Product_Code AND 
	PODetail.PurchasePrice <> BillDetail.PurchasePrice AND 
	BillAbstract.BillDate BETWEEN @FROMDATE AND @TODATE AND
	BillPrefix.TranID = 'BILL' AND
	POPrefix.TranID = 'PURCHASE ORDER'
ORDER BY podetail.product_code


