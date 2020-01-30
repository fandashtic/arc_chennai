
CREATE proc spr_get_cust_wise_sales_detail  (@Customerid nvarchar (15), @Fromdate datetime, @Todate datetime)
as
SELECT  1, "Item Code" = InvoiceDetail.Product_Code, 
	"Item Name" = Items.ProductName, 
	"Net Value (%c)" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Amount ELSE InvoiceDetail.Amount END)
From InvoiceAbstract, InvoiceDetail, Items, Customer  

WHERE   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and (InvoiceAbstract.Status & 128) = 0 
	and InvoiceAbstract.InvoiceDate Between @Fromdate and @Todate 
	And InvoiceAbstract.CustomerID = Customer.CustomerID 
	And InvoiceDetail.Product_Code = Items.Product_Code 
	and invoiceabstract.customerid = @customerid
	and invoiceabstract.invoicetype in (1,3,4)
Group By InvoiceAbstract.CustomerID, Customer.Company_Name, 
	InvoiceDetail.Product_Code, Items.ProductName, 
	Items.UOM, Items.ConversionUnit, Items.ReportingUOM

