CREATE procedure [dbo].[spr_list_bill_items_pidilite](@BILLID int)
AS
SELECT  BillDetail.Product_Code, "Item Code" = BillDetail.Product_Code, 
	"Item Name" = Items.ProductName, "Batch" = BillDetail.Batch,
	"Expiry" = BillDetail.Expiry, "Quantity" = BillDetail.Quantity, 
	"Reporting UOM" = BillDetail.Quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 1) End,  
	"Conversion Factor" = BillDetail.Quantity * IsNull(ConversionFactor, 0),  
	"Rate" = BillDetail.PurchasePrice, "PTR" = BillDetail.PTR,
	"MRP" = BillDetail.ECP,
	"Goods Value" = BillDetail.Quantity * BillDetail.PurchasePrice,
	"Gross Amount" = BillDetail.Amount,
	"Discount" = BillDetail.Discount,
	"Tax Suffered" = BillDetail.TaxSuffered, 
	"Tax Amount" = BillDetail.TaxAmount,
	"Total" = BillDetail.Amount + BillDetail.TaxAmount
FROM BillDetail, Items
WHERE   BillDetail.BillID = @BILLID AND
	BillDetail.Product_Code *= Items.Product_Code
