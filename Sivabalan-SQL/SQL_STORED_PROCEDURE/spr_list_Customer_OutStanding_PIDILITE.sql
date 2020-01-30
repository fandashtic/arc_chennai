CREATE procedure spr_list_Customer_OutStanding_PIDILITE(@Beat nVarchar(2550), 
 @Customer nvarchar(2550), @GraceDays int)  
as 

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  

create table #tmpCust(customerid nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create table #tmpBeat(BeatID Int)      

if @Customer = N'%'
   insert into #tmpCust select customerid from customer
else
   insert into #tmpCust select * from dbo.sp_SplitIn2Rows(@customer,@Delimeter)

if @Beat = N'%'      
   Insert into #tmpBeat select BeatID from Beat Union Select 0
Else      
   Insert into #tmpBeat select BeatID from Beat Where Description in (select * from dbo.sp_SplitIn2Rows(@Beat,@Delimeter))

create table #temp
(CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,  
NoteCount int null,  
Value Decimal(18,6) null)

insert #temp(CustomerID, NoteCount, Value)
select InvoiceAbstract.CustomerID, count(InvoiceID), sum(InvoiceAbstract.Balance)
from InvoiceAbstract
where Invoiceabstract.Customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust) and
IsNull(InvoiceAbstract.BeatID, 0) In (Select BeatID From #tmpBeat) And
InvoiceAbstract.InvoiceDate <= getdate() and dateadd(d,@GraceDays,paymentdate)<=getdate() and  
InvoiceAbstract.Balance > 0 and   
InvoiceAbstract.InvoiceType in (1, 3) and  
InvoiceAbstract.Status & 128 = 0  
group by InvoiceAbstract.CustomerID  

insert #temp(CustomerID, NoteCount, Value)
select InvoiceAbstract.CustomerID, count(InvoiceID), 0-sum(InvoiceAbstract.Balance)
from InvoiceAbstract
where Invoiceabstract.Customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust) and
IsNull(InvoiceAbstract.BeatID, 0) In (Select BeatID From #tmpBeat) And
InvoiceAbstract.InvoiceDate <= getdate() and dateadd(d,@GraceDays,paymentdate)<=getdate() and  
InvoiceAbstract.Balance > 0 and   
InvoiceAbstract.InvoiceType=4 and  
InvoiceAbstract.Status & 128 = 0  
group by InvoiceAbstract.CustomerID  

insert #temp(CustomerID, NoteCount, Value)
select Creditnote.CustomerID, count(CreditID), 0 - sum(Creditnote.Balance)
from Creditnote
where Creditnote.Customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust) and
Creditnote.DocumentDate <=getdate() and  
Creditnote.Balance > 0 
group by Creditnote.CustomerID  

insert #temp(CustomerID, NoteCount, Value)
select Debitnote.CustomerID, count(DebitId), sum(Debitnote.Balance)
from debitnote
where Debitnote.Customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust) and
Debitnote.DocumentDate <=getdate() and  
Debitnote.Balance > 0 
group by Debitnote.CustomerID  

insert #temp(CustomerID, NoteCount, Value)
Select Collections.CustomerID, Count(DocumentID), 0 - Sum(Collections.Balance)
From Collections
Where Collections.CustomerID in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust) And
IsNull(Collections.BeatID, 0) In (Select BeatID From #tmpBeat) And
Collections.DocumentDate <=getdate() And
Collections.Balance > 0 And
IsNull(Collections.Status, 0) & 128 = 0
Group By Collections.CustomerID

select  #temp.CustomerID, "CustomerID" = #temp.CustomerID, 
"Customer" = Customer.Company_Name,"Beat Name"=dbo.fn_GetBeatDescForCus(#temp.CustomerID),
"No of Docs" = sum(Notecount),  
"Outstanding Value (%c)" = Sum(Value)

From #temp, Customer  
where #temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS = Customer.CustomerID
group by #temp.CustomerID, Customer.Company_Name 

drop table #temp
drop table #tmpCust






