CREATE PROCEDURE [dbo].[spr_customer_ledger](@customerid nvarchar(2550),@from datetime,@to datetime)    
AS    

Declare @Delimeter as Char(1)    
Set @Delimeter=Char(15)    
  
create table #tmpCust(customerid nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
if @customerid='%'  
   insert into #tmpCust select customerid from customer  
else  
   insert into #tmpCust select * from dbo.sp_SplitIn2Rows(@customerid,@Delimeter)  
  
create table #tmpLedger(CustomerId nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,CustomerName nvarchar(120) COLLATE SQL_Latin1_General_CP1_CI_AS,Invoice       
decimal(18,6),salesret decimal(18,6),Credit decimal(18,6),debit decimal(18,6),Balanace decimal(18,6))      
--numeric(18,3),salesret numeric(18,3),Credit numeric(18,3),debit numeric(18,3),Balanace numeric(18,3))      
      
insert #tmpledger (customerid,customername,Invoice)      
select Invoiceabstract.customerid,company_name,sum(NETVALUE+isnull(roundoffamount,0)) from invoiceabstract,customer       
where InvoiceType in (1,2,3) and (IsNull(status,0) & 128)=0 and Invoiceabstract.customerid in (select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)   
and Invoicedate between @from and @to and Invoiceabstract.customerid=customer.customerid group by       
Invoiceabstract.customerid,company_name       
      
insert #tmpledger (customerid,customername,salesret)      
select t1.customerid,t2.company_name,sum(netvalue+isnull(roundoffamount,0)) from invoiceabstract t1,customer t2       
where t1.customerid=t2.customerid and InvoiceType in (4,5,6) and (IsNull(status,0) & 128) =0 and t1.customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)  and Invoicedate       
between @from and @to group by t1.customerid,company_name      
      
insert #tmpledger (customerid,customername,credit)  
select t1.CustomerId,Company_name,IsNull(sum(Notevalue),0) as Credit       
from creditnote t1,customer t2   
where (t1.customerid=t2.customerid)   
and t1.customerId in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)    
and documentdate between @from and @to    
and (IsNull(status,0) & 192) =0   
And DocumentDate >= (Select top 1 OpeningDate from Setup)  
group by t1.customerid,company_name          
  
  
insert #tmpledger (customerid,customername,credit)  
select t1.CustomerId,Company_name,IsNull(sum(Balance),0) as Credit       
from creditnote t1,customer t2   
where (t1.customerid=t2.customerid)   
and t1.customerId in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)    
and documentdate between @from and @to    
and (IsNull(status,0) & 192) =0   
And DocumentDate < (Select top 1 OpeningDate from Setup)  
group by t1.customerid,company_name          
  
  
insert #tmpledger (customerid,customername,Credit)   
Select T1.CustomerID , T2.Company_name, IsNull(Sum(CD.AdjustedAmount),0) + IsNull(Sum(CD.Adjustment),0) as Credit  
From Collections T1, CollectionDetail CD, Customer T2  
Where T1.customerId = T2.CustomerID  
And T1.CustomerID in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)  
And CD.DocumentType = 2  
And T1.DocumentID = CD.CollectionID  
And (IsNull(T1.status,0)=0 or IsNull(T1.status,0)=1 or IsNull(T1.status,0)=2)       
--And (IsNull(T1.status,0)=0 or IsNull(T1.status,0)=1)       
And CD.DocumentID in (  
Select CreditID from CreditNote where DocumentDate between @from and @to  
And (IsNull(status,0) & 192) =0   
And CustomerId in (select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)  
And DocumentDate < (Select top 1 OpeningDate from Setup) )  
group by t1.customerid,company_name  
  
   
insert #tmpledger (customerid,customername,debit)   
select t1.CustomerId,Company_name,IsNull(sum(NoteValue),0) as Debit       
from debitnote t1,customer t2   
where (t1.customerid=t2.customerid)   
and t1.customerId in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)    
and documentdate between @from and @to   
and (IsNull(status,0) & 192) =0   
And DocumentDate >= (Select top 1 OpeningDate from Setup)  
group by t1.customerid,company_name      
  
  
  
insert #tmpledger (customerid,customername,Debit)   
select t1.CustomerId,Company_name,IsNull(sum(Balance),0) as Debit       
from debitnote t1,customer t2   
where (t1.customerid=t2.customerid)   
and t1.customerId in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)    
and documentdate between @from and @to   
and (IsNull(status,0) & 192) =0   
And DocumentDate < (Select top 1 OpeningDate from Setup)  
group by t1.customerid,company_name  
  
  
  
insert #tmpledger (customerid,customername,debit)   
Select T1.CustomerID , T2.Company_name, IsNull(Sum(CD.AdjustedAmount),0)+ IsNull(Sum(CD.Adjustment),0)  as Debit  
From Collections T1, CollectionDetail CD, Customer T2  
Where T1.customerId = T2.CustomerID  
And T1.CustomerID in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)  
And CD.DocumentType = 5   
And T1.DocumentID = CD.CollectionID  
And (IsNull(T1.status,0)=0 or IsNull(T1.status,0)=1)       
And CD.DocumentID in (  
Select DebitID from DebitNote where DocumentDate between @from and @to  
And (IsNull(status,0) & 192) =0   
And CustomerId in (select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)  
And DocumentDate < (Select top 1 OpeningDate from Setup) )  
group by t1.customerid,company_name  
  
insert #tmpledger (customerid,customername,Debit)       
select t1.CustomerId,t2.company_name,IsNull(Sum(ExtraCollection),0 ) as Debit       
from Collections t1,customer t2,  CollectionDetail t3 where   
t1.DocumentID = t3.CollectionID And  
(t1.customerid=t2.customerid) and       
t1.customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust) and       
t1.documentdate between @from and @to  and       
(IsNull(status,0)=0 or IsNull(status,0)=1 or IsNull(status,0)=2)       
--(IsNull(status,0)=0 or IsNull(status,0)=1)       
group by t1.customerid,company_name      
  
     
insert #tmpledger (customerid,customername,credit)       
select t1.CustomerId,t2.company_name,IsNull(value,0 ) - IsNull(Balance,0)  as Collection       
from Collections t1,customer t2 where   
(t1.customerid=t2.customerid) and       
t1.customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust) and       
t1.documentdate between @from and @to  and       
--(IsNull(status,0)=0 or IsNull(status,0)=1)       
(IsNull(status,0)=0 or IsNull(status,0)=1 or IsNull(status,0)=2)       
--group by t1.customerid,company_name, Value, Balance      
  
insert #tmpledger (customerid,customername,credit)       
select t1.CustomerId,t2.company_name, IsNull(Sum(Adjustment),0) as Collection       
from Collections t1,customer t2,  CollectionDetail t3 where   
t1.DocumentID = t3.CollectionID And  
(t1.customerid=t2.customerid) and       
t1.customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust) and       
t1.documentdate between @from and @to  and       
--(IsNull(status,0)=0 or IsNull(status,0)=1)       
(IsNull(status,0)=0 or IsNull(status,0)=1 or IsNull(status,0)=2)       
group by t1.customerid,company_name  
  
insert #tmpledger (customerid,customername,Credit)       
select t1.CustomerId,t2.company_name,IsNull(Balance,0 )  as AdvanceCollection      
from Collections t1,customer t2 where   
(t1.customerid=t2.customerid) and       
t1.customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust) and       
t1.documentdate between @from and @to  and       
t1.Balance > 0 And  
IsNull(status,0) & 192 = 0  
--group by t1.customerid,company_name      
     
select customerid, customerid as CustomerId, customername as CustomerName,       
IsNull(sum(Invoice),0)+ IsNull(sum(debit),0) as Debit,       
IsNull(sum(credit),0) + IsNull(sum(Salesret),0) as Credit,       
((IsNull(sum(Invoice),0)+ IsNull(sum(debit),0))-(IsNull(sum(credit),0)+ IsNull(sum(Salesret),0)) ) as Balance       
from #tmpledger group by customerid,customername      
  
drop table #tmpledger  
drop table #tmpCust  


