CREATE FUNCTION sp_compute_gv_mfr(@MANUFACTURERID int, @Fromdate datetime, @ToDate datetime)  
RETURNS Decimal(18,6)  
AS  
Begin  
declare @temp table(gv Decimal(18,6))  
declare @total Decimal(18,6)  
insert into @temp  
Select Case InvoiceType  
 When 4 then  
 0 - 0 --(Sum(Amount) - (Sum(SalePrice * Quantity) * Max(InvoiceDetail.TaxSuffered) / 100) - SUM(ABS((STPayable + CSTPayable))))  
 Else  
 Sum(Amount) - (Sum(SalePrice * Quantity) * Max(InvoiceDetail.TaxSuffered) / 100) - SUM((STPayable + CSTPayable))  
 End From InvoiceAbstract, InvoiceDetail, Items  
 Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And  
 InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And  
 IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And  
 InvoiceDetail.Product_Code = Items.Product_Code And  
 Items.ManufacturerID = @MANUFACTURERID  
Group By Invoicedetail.InvoiceID, InvoiceType, InvoiceDetail.Product_Code  
select @total = sum(gv) from @temp  
RETURN @total  
End  
  


