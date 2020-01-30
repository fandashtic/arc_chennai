CREATE PROCEDURE spr_list_bill_items(@BILLID int)
AS
SELECT  BillDetail.Product_Code, "Item Code" = BillDetail.Product_Code, 
	"Item Name" = Items.ProductName, "Batch" = BillDetail.Batch,
	"Expiry" = BillDetail.Expiry, "Quantity" = BillDetail.Quantity, 
	"Net PTS" = BillDetail.PurchasePrice , 
	"Original PTS" = IsNull(BillDetail.OrgPTS,0),
	"PTR" = BillDetail.PTR,
	"MRP" = BillDetail.ECP,
	"Goods Value" = BillDetail.Quantity * BillDetail.PurchasePrice,
	"Gross Amount" = BillDetail.Amount,
	"Discount" = BillDetail.Discount,
	"Discount Per Unit" =  IsNull(BillDetail.DiscPerUnit / (Case When BillDetail.UOM = Items.UOM1 Then (Case when IsNull(Items.UOM1_Conversion,0) = 0 Then 1 Else Items.UOM1_Conversion End) When BillDetail.UOM = Items.UOM2 Then (Case when IsNull(Items.UOM2_Conversion,0) = 0 Then 1 Else Items.UOM2_Conversion End) Else 1 End),0) ,
	"Tax Suffered" = BillDetail.TaxSuffered, 
	"Tax Amount" = BillDetail.TaxAmount,
	"Total" = BillDetail.Amount + BillDetail.TaxAmount
FROM BillDetail
Left Outer Join  Items On BillDetail.Product_Code = Items.Product_Code
WHERE   BillDetail.BillID = @BILLID 
