CREATE PROCEDURE [dbo].[sp_acc_rpt_stocktransferOutdetailUOM](@DocSerial int)    
AS    
DECLARE @SPECIALCASE2 INT    
SET @SPECIALCASE2=5    
SELECT  
	"Item Code" = stocktransferoutdetail.Product_Code, 
	"Item Name" = Items.ProductName, 
	"UOM Description" = UOM.[Description],   
	"UOM Qty" = stocktransferoutdetail.Quantity, 
	"UOM Price" = stocktransferoutdetail.UOMPrice,    
	"Gross Amount" = stocktransferoutdetail.Amount,
	"Tax Suffered" = stocktransferoutdetail.TaxSuffered, "Tax Amount" = stocktransferoutdetail.TaxAmount,
	"Total" = stocktransferoutdetail.TotalAmount,@SPECIALCASE2
FROM stocktransferoutdetail
Left Outer Join Items on stocktransferoutdetail.Product_Code = Items.Product_Code
Left Outer Join UOM on stocktransferOutdetail.UOM = UOM.UOM
WHERE   stocktransferoutdetail.DocSerial = @DocSerial 
	--AND
	--stocktransferoutdetail.Product_Code *= Items.Product_Code
	--And stocktransferOutdetail.UOM *= UOM.UOM

