CREATE PROC [dbo].[sp_get_salesreturndetail]( @InvoiceID int)
as
select Product_Code, SalePrice, CAST(ISNULL(Tax.Percentage, 0) AS nvarchar) + '+' + CAST(ISNULL(CST_Percentage, 0) AS nvarchar), Batch_Code,Batch_Number, Quantity, ISNULL(TaxSuffered,0), ISNULL(TaxSuffered2, 0)
from InvoiceDetail, Tax where InvoiceID = @InvoiceID AND InvoiceDetail.TaxID *= Tax.Tax_Code
