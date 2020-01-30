CREATE PROCEDURE sp_acc_rpt_invoicedetail1(@INVOICEID int)
AS
DECLARE @ADDNDIS AS FLOAT
DECLARE @TRADEDIS AS FLOAT
DECLARE @SPECIALCASE2 INT
SET @SPECIALCASE2=5

Declare @Version Int
Set @Version= dbo.sp_acc_getversion()

If @Version = 5 or @Version = 8 or @Version= 18 or @Version=19  or @Version=11--Multiple UOM versions
Begin
	Exec sp_acc_rpt_invoicedetailUOM1 @INVOICEID
End
Else If @Version = 9 or @Version = 10 --Serial versions
Begin
	Exec sp_acc_rpt_invoicedetailSerial1 @InvoiceID
End
Else
Begin
	SELECT @ADDNDIS = AdditionalDiscount, @TRADEDIS = DiscountPercentage FROM InvoiceAbstract
	WHERE InvoiceID = @INVOICEID
	
	SELECT  "Item Code" = InvoiceDetail.Product_Code, 
		"Item Name" = Items.ProductName, 
		"Batch" = InvoiceDetail.Batch_Number,
--		"SaleType"=Case When IsNull(Max(InvoiceDetail.SaleID),0)=1 then 'First Sale' else 'Second Sale' end,
		'','','','','','','',
		"Quantity" = SUM(InvoiceDetail.Quantity), 
		"Sale Price" = ISNULL(InvoiceDetail.SalePrice, 0), 
		"Sale Tax" = CAST(Round(max(InvoiceDetail.TaxCode),2) AS nvarchar) + N'%+' + CAST(ROUND(ISNULL(max(InvoiceDetail.TaxCode2), 0), 2) AS nVARCHAR) + N'%',
		"Tax Suffered" = CAST(ISNULL(max(InvoiceDetail.TaxSuffered2), 0) AS nVARCHAR) + N'%+' + CAST(ISNULL(max(InvoiceDetail.TaxSuffered) - max(InvoiceDetail.TaxSuffered2), 0) AS nVARCHAR) + N'%',
		"Discount" = CAST(SUM(DiscountPercentage) AS nvarchar) + N'%',
		"STCredit" = 
		Round((SUM(InvoiceDetail.TaxCode) / 100) *
		((((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) - 
		((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) * (SUM(DiscountPercentage) / 100))) *
		(@ADDNDIS / 100)) +
		(((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) - 
		((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) * (SUM(DiscountPercentage) / 100))) *
		(@TRADEDIS / 100))), 2),
		"Total" = Round(SUM(Amount),2),@SPECIALCASE2
	FROM InvoiceDetail, Items
	WHERE   InvoiceDetail.InvoiceID = @INVOICEID AND
		InvoiceDetail.Product_Code = Items.Product_Code
	GROUP BY InvoiceDetail.Product_Code, Items.ProductName, InvoiceDetail.Batch_Number, 
		InvoiceDetail.SalePrice
End



