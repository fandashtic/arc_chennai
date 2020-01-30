CREATE PROCEDURE [dbo].[sp_acc_rpt_invoicedetailUOM1](@INVOICEID int)
AS
DECLARE @ADDNDIS AS FLOAT
DECLARE @TRADEDIS AS FLOAT
DECLARE @SPECIALCASE2 INT
SET @SPECIALCASE2=5

SELECT @ADDNDIS = AdditionalDiscount, @TRADEDIS = DiscountPercentage FROM InvoiceAbstract
WHERE InvoiceID = @INVOICEID

SELECT  "Item Code" = InvoiceDetail.Product_Code, 
	"Item Name" = Items.ProductName, 
	"Batch" = InvoiceDetail.Batch_Number,
	"UOM"=IsNull(UOM.Description, N''),
	'','','','','','',
	"UOM Qty" = ISNULL(SUM(InvoiceDetail.UOMQty), 0), 
	"UOM Price" = ISNULL(InvoiceDetail.UOMPrice, 0), 
	"Sale Tax" = CAST(Round(max(InvoiceDetail.TaxCode),2) AS nvarchar) + N'%+' + CAST(ROUND(ISNULL(max(InvoiceDetail.TaxCode2), 0), 2) AS nVARCHAR) + N'%',
	"Tax Suffered" = CAST(ISNULL(max(InvoiceDetail.TaxSuffered2), 0) AS nVARCHAR) + N'%+' + CAST(ISNULL(max(InvoiceDetail.TaxSuffered) - max(InvoiceDetail.TaxSuffered2), 0) AS nVARCHAR) + N'%',
	"Discount" = CAST(SUM(DiscountPercentage) AS nvarchar) + N'%',
	"STCredit" = 
	Round((SUM(InvoiceDetail.TaxCode) / 100) *
	((((InvoiceDetail.UOMPrice * SUM(InvoiceDetail.UOMQty)) - 
	((InvoiceDetail.UOMPrice * SUM(InvoiceDetail.UOMQty)) * (SUM(DiscountPercentage) / 100))) *
	(@ADDNDIS / 100)) +
	(((InvoiceDetail.UOMPrice * SUM(InvoiceDetail.UOMQty)) - 
	((InvoiceDetail.UOMPrice * SUM(InvoiceDetail.UOMQty)) * (SUM(DiscountPercentage) / 100))) *
	(@TRADEDIS / 100))), 2),
	"Total" = Round(SUM(Amount),2),@SPECIALCASE2
FROM InvoiceDetail
Inner Join Items on InvoiceDetail.Product_Code = Items.Product_Code
Left Join UOM on InvoiceDetail.UOM = UOM.UOM
WHERE InvoiceDetail.InvoiceID = @INVOICEID 
	--AND InvoiceDetail.Product_Code = Items.Product_Code 
	--And InvoiceDetail.UOM *= UOM.UOM
GROUP BY InvoiceDetail.Product_Code, Items.ProductName, InvoiceDetail.Batch_Number, 
	InvoiceDetail.UOM, UOM.Description, InvoiceDetail.UOMPrice

