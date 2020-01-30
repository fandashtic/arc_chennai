CREATE PROCEDURE [dbo].[sp_acc_rpt_stocktransferindetailUOM](@DocSerial int)    
AS    
DECLARE @SPECIALCASE2 INT    
SET @SPECIALCASE2=5    
SELECT  
	"Item Code" = stocktransferindetail.Product_Code, 
	"Item Name" = Items.ProductName, 
	"UOM Description" = UOM.[Description],   
	"UOM Qty" = stocktransferindetail.UOMQty, 
	"UOM Price" = stocktransferindetail.UOMPrice,    
	"Gross Amount" = stocktransferindetail.Amount,
	"Tax Suffered" = stocktransferindetail.TaxSuffered, "Tax Amount" = stocktransferindetail.TaxAmount,
	"Total" = stocktransferindetail.TotalAmount,@SPECIALCASE2
FROM stocktransferindetail
Left Outer Join Items on stocktransferindetail.Product_Code = Items.Product_Code
Left Outer Join UOM on stocktransferindetail.UOM = UOM.UOM
WHERE   stocktransferindetail.DocSerial = @DocSerial 
	--AND	stocktransferindetail.Product_Code *= Items.Product_Code
	--And stocktransferindetail.UOM *= UOM.UOM

