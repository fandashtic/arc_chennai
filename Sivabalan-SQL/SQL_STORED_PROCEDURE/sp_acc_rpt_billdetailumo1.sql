create PROCEDURE [dbo].[sp_acc_rpt_billdetailumo1](@BILLID int)
AS
DECLARE @SPECIALCASE2 INT
SET @SPECIALCASE2=5
SELECT  "Item Code" = BillDetail.Product_Code, 
	"Item Name" = Items.ProductName, "Description" = UOM.[Description], 
	'','','','','','','',
	"UOM Qty" = BillDetail.UOMQty,"UOM Price" = BillDetail.UOMPrice,
	"Rate" = BillDetail.PurchasePrice, "Gross Amount" = BillDetail.Amount,
	"Tax Suffered" = BillDetail.TaxSuffered, "Tax Amount" = BillDetail.TaxAmount,
	"Total" = BillDetail.Amount + BillDetail.TaxAmount,@SPECIALCASE2
FROM BillDetail
Left Join Items on BillDetail.Product_Code = Items.Product_Code
Left Join UOM on BillDetail.UOM = UOM.UOM
WHERE   BillDetail.BillID = @BILLID 
	--AND BillDetail.Product_Code *= Items.Product_Code
	--and BillDetail.UOM *= UOM.UOM


