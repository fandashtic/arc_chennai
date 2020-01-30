CREATE procedure [dbo].[spr_customer_Category_wise_sales](      
        @FromDate datetime,      
        @ToDate datetime)      
as      
Declare @OTHERS NVarchar(50)
Set @OTHERS=dbo.LookupDictionaryItem(N'Others', Default)
select 
"Category ID" = isnull(customer.CustomerCategory, 0 ) ,
"Customer Category"  = case isnull(customer.CustomerCategory, 0 ) when 0 then @OTHERS  else CustomerCategory.CategoryName end ,     
"Total Sales (Rs)" = isnull(sum(case invoicetype when 4 then 0 - (NetValue-IsNull(freight,0)) else NetValue- IsNull(freight,0) end),0)
from InvoiceAbstract
Right Outer Join customer On  invoiceabstract.CustomerID = Customer.CustomerID 
Left Outer Join customerCategory On Customer.CustomerCategory = CustomerCategory.Categoryid 
WHERE InvoiceDate BETWEEN @fromDate AND @toDate AND  InvoiceType in (1, 3,4) AND (Status & 128) = 0 
group by isnull(customer.CustomerCategory, 0 ) , CustomerCategory.CategoryName


