CREATE procedure [dbo].[spr_SalesMan_Wise_Sales_detail](@SALES_CUST NVARCHAR(100),       
      @FROMDATE DATETIME ,       
      @TODATE DATETIME )      
AS      
DECLARE @SALE int
DECLARE @CUST NVARCHAR(50)    
DECLARE @LENSTR INT    
SET @LENSTR = (CHARINDEX(',', @SALES_CUST) )     
SELECT @SALE = cast (SUBSTRING(@SALES_CUST,  1 , (@lENSTR - 1 ))   as int)
SELECT @CUST = SUBSTRING(@SALES_CUST, (@lENSTR + 1) , LEN(@SALES_CUST) - @lENSTR )    
SELECT 	InvoiceDetail.Product_Code, 
	"Item Name" = Items.ProductName,       
 	"Quantity" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - isnull(InvoiceDetail.Quantity,0) ELSE isnull(InvoiceDetail.Quantity,0) END),      
	"Net Value (%c)" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - isnull(InvoiceDetail.Amount,0) ELSE isnull(InvoiceDetail.Amount,0) END)      
	FROM InvoiceAbstract, InvoiceDetail, Items, Salesman  , Customer    
	WHERE InvoiceDetail.Product_Code = Items.Product_Code      
	AND  InvoiceAbstract.Invoiceid = InvoiceDetail.Invoiceid      
	AND  InvoiceAbstract.InvoiceDate between @FROMDATE and @TODATE      
	And  InvoiceAbstract.SalesmanID *= Salesman.SalesmanID      
	AND isnull(invoiceabstract.Salesmanid, 0)  =  @SALE    
	AND (InvoiceAbstract.Status & 128 ) = 0      
	AND  InvoiceAbstract.InvoiceType in (1,3,4)      
	and invoiceabstract.customerid = customer.customerid    
	and invoiceabstract.customerid like @CUST    
GROUP BY InvoiceDetail.Product_Code, Items.ProductName
