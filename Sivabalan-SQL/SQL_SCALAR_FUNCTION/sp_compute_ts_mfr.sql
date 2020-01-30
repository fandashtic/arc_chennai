CREATE FUNCTION sp_compute_ts_mfr(@MANUFACTURERID int, @Fromdate datetime, @ToDate datetime)
RETURNS Decimal(18,6)
AS
Begin
declare @temp table(ts Decimal(18,6))
declare @total Decimal(18,6)
insert into @temp
select Case InvoiceType
	When 4 then
	0 - (sum(SalePrice * Quantity) * max(InvoiceDetail.TaxSuffered) / 100)
	Else
	sum(SalePrice * Quantity) * max(InvoiceDetail.TaxSuffered) / 100
	End From InvoiceAbstract, InvoiceDetail, Items
	Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
	InvoiceAbstract.InvoiceDate Between @Fromdate And @ToDate And
	IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And
	InvoiceDetail.Product_Code = Items.Product_Code And
	Items.ManufacturerID = @MANUFACTURERID
Group by invoicetype, invoicedetail.invoiceid, invoicedetail.product_code
select @total = sum(ts) from @temp
RETURN @total
End
