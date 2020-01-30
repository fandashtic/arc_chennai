
/*sp_helptext spr_list_SalesItems
sp_helptext spr_list_invoice_sales
spr_list_invoice_sales1 'OMERTA', '2/21/2002' , '2/22/2002'
*/

CREATE procedure spr_list_invoice_sales1(@ITEMCODE nvarchar(15), 
					    @FROMDATE DATETIME,
					    @TODATE DATETIME)
AS

DECLARE @INV AS nvarchar(50)
DECLARE @INVAMND AS nvarchar(50)

SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = 'INVOICE'
SELECT @INVAMND = Prefix FROM VoucherPrefix WHERE TranID = 'INVOICE AMENDMENT'

create table #temp(invoiceid int, invoicenumber nvarchar(10) , invoicedate datetime , quantity float , saleprice float)

insert into #temp(invoiceid , invoicenumber , invoicedate  , quantity , saleprice)

SELECT InvoiceDetail.InvoiceID, "Invoice No" = CASE InvoiceAbstract.InvoiceType WHEN 1 THEN @INV 
ELSE @INVAMND END + CAST(InvoiceAbstract.DocumentID AS nvarchar), InvoiceAbstract.InvoiceDate, 
Sum(InvoiceDetail.Quantity) as "Quantity", "SalePrice" = ISNULL(InvoiceDetail.SalePrice,0)
FROM InvoiceAbstract, InvoiceDetail WHERE InvoiceDetail.Product_Code = @ITEMCODE 

AND InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID
AND (InvoiceAbstract.InvoiceType = 1 OR InvoiceAbstract.InvoiceType = 3) 
AND InvoiceAbstract.Status & 128 = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
GROUP BY InvoiceDetail.InvoiceID, InvoiceAbstract.DocumentID, InvoiceType, InvoiceAbstract.InvoiceDate,
InvoiceDetail.SalePrice
select  * from #temp

