CREATE procedure spr_list_Beat_OutStanding1( @BeatName nvarchar(255),  
      @FromDate datetime,  
      @ToDate datetime)  
as  
create table #temp  
(BeatID int,  
 CustomerID nvarchar(15),  
 InvCount int null,  
 Value Decimal(18,6) null)  
Insert #temp(BeatID, CustomerID, InvCount, Value)  
Select InvoiceAbstract.BeatID, InvoiceAbstract.CustomerID, count(InvoiceID),   
sum(InvoiceAbstract.Balance)   
from InvoiceAbstract, Beat  
where InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and  
InvoiceAbstract.Balance > 0 and   
InvoiceAbstract.InvoiceType in (1, 3) and  
InvoiceAbstract.Status & 128 = 0 and  
Beat.Description like @BeatName and  
Invoiceabstract.Status & 64 = 0 and
InvoiceAbstract.BeatID = Beat.BeatID  
group by InvoiceAbstract.BeatID, InvoiceAbstract.CustomerID  
  
Insert #temp(BeatID, CustomerID, InvCount, Value)  
select InvoiceAbstract.BeatID, InvoiceAbstract.CustomerID, count(InvoiceID),   
0 - sum(InvoiceAbstract.Balance)   
from InvoiceAbstract, Beat  
where InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and  
InvoiceAbstract.Balance > 0 and   
InvoiceAbstract.InvoiceType in (4) and  
InvoiceAbstract.Status & 128 = 0 and  
InvoiceAbstract.Status & 64 = 0 and
Beat.Description like @BeatName and  
InvoiceAbstract.BeatID = Beat.BeatID  
group by InvoiceAbstract.BeatID, InvoiceAbstract.CustomerID  

insert #temp(BeatID,Customerid, InvCount, Value )  
select Beat_Salesman.BeatID, Creditnote.CustomerID, count(CreditID), sum(Creditnote.Balance)
from Creditnote, Beat, Beat_Salesman
where Creditnote.Customerid = Beat_Salesman.Customerid and
Beat_Salesman.Beatid = Beat.Beatid and
Creditnote.DocumentDate between @FromDate and @ToDate and  
Beat.Description like @BeatName and 
Creditnote.Balance > 0 
group by Creditnote.CustomerID  , Beat_Salesman.Beatid

insert #temp(BeatID, CustomerID,InvCount , Value)  
select Beat_Salesman.Beatid,Debitnote.Customerid, count(DebitId), 0 - sum(Debitnote.Balance)
from Debitnote, Beat, Beat_Salesman
where 
Debitnote.Customerid = Beat_Salesman.Customerid and
Beat_Salesman.Beatid = Beat.Beatid and
Debitnote.DocumentDate between @FromDate and @ToDate and  
Beat.Description like @BeatName and
Debitnote.Balance > 0 
group by Debitnote.CustomerID  , Beat_Salesman.Beatid

select  #temp.CustomerID, #temp.CustomerID, "Customer" = Customer.Company_Name, "No of Invoices" = sum(InvCount),  
"Outstanding Value (Rs.)" = Sum(Value), Beat.Description  
From #temp, Customer, Beat  
where #temp.CustomerID = Customer.CustomerID  collate SQL_Latin1_General_Cp1_CI_AS
group by #temp.CustomerID, Customer.Company_Name, Beat.Description  
drop table #temp

