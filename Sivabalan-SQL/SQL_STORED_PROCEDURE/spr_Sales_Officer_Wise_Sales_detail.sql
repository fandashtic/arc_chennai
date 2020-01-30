CREATE PROC spr_Sales_Officer_Wise_Sales_detail(       @SALES_CUST NVARCHAR(250),   
						      @FROMDATE DATETIME ,   
						      @TODATE DATETIME )  
AS  
DECLARE @SALE NVARCHAR(50)
DECLARE @CUST NVARCHAR(50)
DECLARE @LENSTR INT
SET @LENSTR = (CHARINDEX(',', @SALES_CUST) ) 
SELECT @CUST = SUBSTRING(@SALES_CUST,  1 , @lENSTR - 1 )
SELECT @SALE = SUBSTRING(@SALES_CUST, (@lENSTR + 1) , LEN(@SALES_CUST) - @lENSTR )

SELECT 	InvoiceDetail.Product_Code, 
	"Item Nme" = Items.ProductName,   
	"Quantity" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - isnull(InvoiceDetail.Quantity,0) ELSE isnull(InvoiceDetail.Quantity,0) END),  
	"Net Value (%c)" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - isnull(InvoiceDetail.Amount,0) ELSE isnull(InvoiceDetail.Amount,0) END)  

FROM InvoiceAbstract, InvoiceDetail, Items, Customer  , Salesman2
WHERE  	InvoiceDetail.Product_Code = Items.Product_Code  
	AND  InvoiceAbstract.Invoiceid = InvoiceDetail.Invoiceid  
	AND  InvoiceAbstract.InvoiceDate between @FROMDATE and @TODATE  
	AND  InvoiceAbstract.Customerid = Customer.Customerid 
	AND  Customer.Customerid like  @CUST
	AND  Salesman2.SalesmanName  like @SALE
	AND  (InvoiceAbstract.Status & 128 ) = 0  
	AND  InvoiceAbstract.InvoiceType in (1,3,4)  
	AND InvoiceAbstract.Salesman2 = salesman2.salesmanid
GROUP BY  InvoiceDetail.Product_Code, Items.ProductName 
