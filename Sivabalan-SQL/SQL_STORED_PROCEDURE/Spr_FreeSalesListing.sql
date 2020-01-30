CREATE PROCEDURE Spr_FreeSalesListing ( @FROMDATE DATETIME, @TODATE DATETIME)  
AS  
BEGIN

SELECT INVOICEDETAIL.product_code,INVOICEDETAIL.product_code as "Item Code",ITEMS.productname,
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


END




