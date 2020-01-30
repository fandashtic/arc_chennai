CREATE procedure spr_list_Customer_OutStanding1 (@Customer nvarchar(15),  
      @FromDate datetime,  
      @ToDate datetime)  
as  
create table #temp  
(  
 CustomerID nvarchar(15),  
 NoteCount int null,  
 Value Decimal(18,6) null,
)  
insert #temp(CustomerID, NoteCount, Value)  
select InvoiceAbstract.CustomerID, count(InvoiceID), sum(InvoiceAbstract.Balance)
from InvoiceAbstract, Customer  
where Customer.Customerid = Invoiceabstract.Customerid and
Customer.Company_Name like @Customer and  
InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and  
InvoiceAbstract.Balance > 0 and   
InvoiceAbstract.InvoiceType in (1, 3) and  
InvoiceAbstract.Status & 128 = 0  
group by InvoiceAbstract.CustomerID  

insert #temp(CustomerID, NoteCount, Value)  
select InvoiceAbstract.CustomerID, count(InvoiceID), 0 - sum(InvoiceAbstract.Balance)   
from InvoiceAbstract, Customer  
where Customer.CustomerID = InvoiceAbstract.CustomerID and  
Customer.Company_Name like @Customer and  
InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and  
InvoiceAbstract.Balance > 0 and   
InvoiceAbstract.InvoiceType in (4) and  
InvoiceAbstract.Status & 128 = 0  
group by InvoiceAbstract.CustomerID  

insert #temp(CustomerID, NoteCount, Value )  
select Creditnote.CustomerID, count(CreditID), sum(Creditnote.Balance)
from Creditnote, Customer  
where Customer.CustomerID = Creditnote.Customerid and
Customer.Company_Name like @Customer and
Creditnote.DocumentDate between @FromDate and @ToDate and  
Creditnote.Balance > 0 
group by Creditnote.CustomerID  

insert #temp(CustomerID,Notecount , Value)  
select Debitnote.CustomerID, count(DebitId), 0 - sum(Debitnote.Balance)
from debitnote, Customer  
where Customer.CustomerID = Debitnote.Customerid and
Customer.Company_name like @Customer and
Debitnote.DocumentDate between @FromDate and @ToDate and  
Debitnote.Balance > 0 
group by Debitnote.CustomerID  
  
select  #temp.CustomerID, #temp.CustomerID, "Customer" = Customer.Company_Name, "No of Docs" = sum(Notecount),  
 "Outstanding Value (Rs.)" = Sum(Value)  
From #temp, Customer  
where #temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS = Customer.CustomerID  
group by #temp.CustomerID, Customer.Company_Name  
drop table #temp

