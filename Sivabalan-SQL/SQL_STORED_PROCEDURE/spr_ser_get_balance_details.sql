CREATE PROCEDURE spr_ser_get_balance_details(@beatid integer)    
--      @fromdate datetime,      
--      @todate datetime)      
as      
create table #temp (    
customerid nvarchar(255),     
customername nvarchar(255),    
total Decimal(18,6))    
    
insert #temp (customerid, customername, total)    
select invoiceabstract.customerid,     
customer.company_name,    
isnull(sum(case invoicetype when 4 then 0 - invoiceabstract.Balance else invoiceabstract.Balance end),0)      
from invoiceabstract,customer       
where invoiceabstract.invoicetype in (1,3,4) and    
invoiceabstract.customerid=customer.customerid  and    
(invoiceabstract.status&128)=0 and       
IsNull(invoiceabstract.beatid,0)=IsNull(@beatid,0) and      
invoiceabstract.customerid=customer.customerid      
--and invoiceabstract.invoicedate between @FROMDATE AND @TODATE     
aND cUSTOMER.CUSTOMERCATEGORY NOT IN (4,5)    
group by invoiceabstract.customerid, customer.Company_name    
    
insert #temp (customerid, customername, total)    
select creditnote.customerid, customer.company_name,    
isnull(0 - sum(Balance),0) From Creditnote, Customer where       
Creditnote.Customerid = Customer.Customerid and    
IsNull((Select Top 1 Beatid From Beat_Salesman Where CustomerID = CreditNote.CustomerID),0) = IsNull(@Beatid,0)     
--and Creditnote.Documentdate between @FROMDATE AND @TODATE    
aND CUSTOMER.CUSTOMERCATEGORY NOT IN (4,5)    
group by creditnote.customerid , customer.company_name    

--Begin: Service Invoice Impact
insert #temp (customerid, customername, total)    
select SI.customerid,     
CUST.company_name,    
isnull(sum(SI.Balance),0)      
from serviceinvoiceabstract SI,customer CUST      
where SI.serviceinvoicetype in (1)   and    
SI.customerid=CUST.customerid  and    
(isNull(SI.status,0) & 192) = 0 and       
IsNull(@beatid,0) = 0
and CUST.CustomerCategory NOT IN (5)    
group by SI.customerid, CUST.Company_name    
--End: Service Invoice Impact

    
insert #temp (customerid, customername, total)     
select debitnote.customerid, customer.company_name,     
isnull(sum(Balance),0) From Debitnote, Customer where      
Debitnote.Customerid = Customer.Customerid and    
IsNull((Select Top 1 Beatid From Beat_Salesman Where CustomerID = DebitNote.CustomerID), 0) = IsNull(@beatid,0)     
aND CUSTOMER.CUSTOMERCATEGORY NOT IN (4,5)    
--and Debitnote.Documentdate between @FROMDATE AND @TODATE    
group by debitnote.customerid, customer.company_name    
    
Insert #temp(CustomerID, CustomerName, Total)    
Select Collections.CustomerID, Customer.Company_Name, 0 - Sum(Balance)     
From Collections, Customer    
Where IsNull(Collections.BeatID,0) = IsNull(@BeatID,0) And    
--Collections.DocumentDate Between @FromDate And @ToDate And    
Collections.Balance > 0 And    
IsNull(Collections.Status, 0) & 128 = 0 And    
Collections.CustomerID = Customer.CustomerID    
aND CUSTOMER.CUSTOMERCATEGORY NOT IN (4,5)    
Group By Collections.CustomerID, Customer.Company_Name    

select #temp.customerid, "Customer" = #temp.customername,     
       "Total Outstanding" = Sum(Total) from #temp    
Group by #temp.CustomerID, #temp.CustomerName    
drop table #temp     

