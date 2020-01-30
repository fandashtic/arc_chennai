CREATE PROCEDURE spr_list_items_in_invoice_Category_pidilite (@INVOICEID int,
						     @CATEGORY nvarchar(50))
AS
DECLARE @ADDNDIS AS Decimal(18,6)
DECLARE @TRADEDIS AS Decimal(18,6)

SELECT @ADDNDIS = AdditionalDiscount, @TRADEDIS = DiscountPercentage FROM InvoiceAbstract
WHERE InvoiceID = @INVOICEID

SELECT  InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code, 
	"Item Name" = Items.ProductName, 
	"Batch" = InvoiceDetail.Batch_Number,
	"Quantity" = SUM(InvoiceDetail.Quantity), 
	"Reporting UOM" = SUM(InvoiceDetail.Quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 1) End),  
	"Conversion Factor" = SUM(InvoiceDetail.Quantity * IsNull(ConversionFactor, 0)),  
	"Sale Price" = ISNULL(InvoiceDetail.SalePrice, 0), 
	"Sale Tax" = CAST(Round(MAX(InvoiceDetail.TaxCode+InvoiceDetail.TaxCode2), 2) AS nvarchar) + '%',
	"Tax Suffered" = CAST(ISNULL(MAX(InvoiceDetail.TaxSuffered), 0) AS nvarchar) + '%',
	"Discount" = CAST(SUM(DiscountPercentage) AS nvarchar) + '%',
	"STCredit" = Round(IsNull(Sum(InvoiceDetail.STCredit),0),2),      
-- 	Round((SUM(InvoiceDetail.TaxCode) / 100) *
-- 	((((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) - 
-- 	((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) * (SUM(DiscountPercentage) / 100))) *
-- 	(@ADDNDIS / 100)) +
-- 	(((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) - 
-- 	((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) * (SUM(DiscountPercentage) / 100))) *
-- 	(@TRADEDIS / 100))), 2),
	"Total" = Round(SUM(Amount),2)
FROM InvoiceDetail, Items, ItemCategories
WHERE   InvoiceDetail.InvoiceID = @INVOICEID AND
	InvoiceDetail.Product_Code = Items.Product_Code AND
	Items.CategoryID = ItemCategories.CategoryID AND
	ItemCategories.Category_Name like @CATEGORY
GROUP BY InvoiceDetail.Product_Code, Items.ProductName, InvoiceDetail.Batch_Number, 
	InvoiceDetail.SalePrice

