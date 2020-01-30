CREATE PROCEDURE Spr_ser_FreeSalesListing ( @FROMDATE DATETIME, @TODATE DATETIME)  
AS  
BEGIN

CREATE TABLE #InvoiceFreeTemp(code  nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,[Item Code] nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
ItemName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Quantity Decimal(18,6))

Insert into #InvoiceFreeTemp

SELECT INVOICEDETAIL.product_code,INVOICEDETAIL.product_code as "Item Code",
ITEMS.productname,
	"Quantity" = SUM(Case 
		when InvoiceAbstract.InvoiceType >=4 and InvoiceAbstract.InvoiceType <=6 then 
		   0 - Invoicedetail.Quantity 
		else
		   Invoicedetail.Quantity 
                end )
	FROM ITEMS,INVOICEABSTRACT,INVOICEDETAIL 
	WHERE ITEMS.PRODUCT_CODE = INVOICEDETAIL.PRODUCT_CODE 
	AND INVOICEABSTRACT.INVOICEID = INVOICEDETAIL.INVOICEID 
	AND INVOICEABSTRACT.Invoicetype in (1,2,3,4,5,6) AND INVOICEDETAIL.Saleprice = 0 
	AND (status & 128) = 0 
	AND INVOICEABSTRACT.invoicedate BETWEEN @FROMDATE AND @TODATE
	group by INVOICEDETAIL.product_code,ITEMS.PRODUCTNAME

Insert into #InvoiceFreeTemp

SELECT SERVICEINVOICEDETAIL.Sparecode,SERVICEINVOICEDETAIL.Sparecode as "Item Code",
ITEMS.productname,
	"Quantity" = SUM(Isnull(ServiceInvoiceDetail.Quantity,0))
	FROM ITEMS,SERVICEINVOICEABSTRACT,SERVICEINVOICEDETAIL 
	WHERE ITEMS.PRODUCT_CODE = SERVICEINVOICEDETAIL.SPARECODE 
	AND SERVICEINVOICEABSTRACT.SERVICEINVOICEID = SERVICEINVOICEDETAIL.SERVICEINVOICEID 
	AND SERVICEINVOICEABSTRACT.ServiceInvoicetype in (1) 
	AND ISNULL(SERVICEINVOICEDETAIL.price,0) = 0 
	AND ISNULL(SERVICEINVOICEABSTRACT.status,0) & 192 = 0 
	AND SERVICEINVOICEABSTRACT.Serviceinvoicedate BETWEEN @FROMDATE AND @TODATE
	group by SERVICEINVOICEDETAIL.Sparecode,ITEMS.PRODUCTNAME

END

Select  
"Code" = Code , "Item Code" = [Item Code], "Item Name" = ItemName,
"Quantity" = Sum(Quantity) from #InvoiceFreeTemp group by code,[Item Code],[ItemName]

Drop Table #InvoiceFreeTemp


