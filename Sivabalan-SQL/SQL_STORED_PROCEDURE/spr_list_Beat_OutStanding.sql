CREATE procedure spr_list_Beat_OutStanding(@BeatName nvarchar(2550))    
--      @FromDate datetime,      
--      @ToDate datetime)      
as    
  
Declare @OTHERS NVarchar(50)  
Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)  
      
Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)      
    
Create table #tmpBeat([Description] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
    
if @BeatName ='%'       
   Insert into #tmpBeat select [Description] from Beat      
Else      
   Insert into #tmpBeat select * from dbo.sp_SplitIn2Rows(@BeatName, @Delimeter)      
    
    
create table #temp      
(     
 BeatID int,      
 CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,      
 InvCount int null,      
 Value Decimal(18,6) null      
)      
create table #tempcustomer    
(    
 CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 BeatID int,    
 Beat_Description nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS    
)    

insert into #tempcustomer    
Select  Customer.CustomerID, IsNull(Beat_Salesman.BeatID,0),     
 IsNull((Select Beat.Description From Beat Where BeatID = Beat_Salesman.BeatID), @OTHERS)    
From Customer
Left Outer Join Beat_Salesman On Customer.CustomerID = Beat_Salesman.CustomerID       
    
If @BeatName = '%'     
Begin    
 insert #temp(BeatID, CustomerID, InvCount, Value)      
 select InvoiceAbstract.BeatID, InvoiceAbstract.CustomerID, count(InvoiceID),       
 isnull(sum(InvoiceAbstract.Balance), 0)    
 from InvoiceAbstract
 Left Outer Join beat On  IsNull(InvoiceAbstract.BeatID,0) = Beat.BeatID 
 where   
-- InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and      
 InvoiceAbstract.Balance > 0 and       
 InvoiceAbstract.InvoiceType in (1, 3) and      
 InvoiceAbstract.Status & 128 = 0 and      
 beat.Description like @BeatName and      
 Invoiceabstract.Status & 64 = 0    
 group by InvoiceAbstract.BeatID, InvoiceAbstract.CustomerID      
       
 insert #temp(BeatID, CustomerID, InvCount, Value)      
 select InvoiceAbstract.BeatID, InvoiceAbstract.CustomerID, count(InvoiceID),       
 0 - isnull(sum(InvoiceAbstract.Balance), 0)    
 from InvoiceAbstract
 Left Outer Join beat On IsNull(InvoiceAbstract.BeatID,0) = beat.BeatID 
 where      
-- InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and      
 InvoiceAbstract.Balance > 0 and       
 InvoiceAbstract.InvoiceType in (4) and      
 InvoiceAbstract.Status & 128 = 0 and      
 InvoiceAbstract.Status & 64 = 0 and    
 beat.Description like @BeatName    
 group by InvoiceAbstract.BeatID, InvoiceAbstract.CustomerID      
End    
Else    
Begin    
 insert #temp(BeatID, CustomerID, InvCount, Value)      
 select InvoiceAbstract.BeatID, InvoiceAbstract.CustomerID, count(InvoiceID),       
 isnull(sum(InvoiceAbstract.Balance), 0)    
 from InvoiceAbstract, beat    
 where       
-- InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and      
 InvoiceAbstract.Balance > 0 and       
 InvoiceAbstract.InvoiceType in (1, 3) and      
 InvoiceAbstract.Status & 128 = 0 and      
 IsNull(InvoiceAbstract.BeatID,0) = Beat.BeatID And    
 beat.Description In (Select [Description] COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) and      
 Invoiceabstract.Status & 64 = 0    
 group by InvoiceAbstract.BeatID, InvoiceAbstract.CustomerID      
       
 insert #temp(BeatID, CustomerID, InvCount, Value)      
 select InvoiceAbstract.BeatID, InvoiceAbstract.CustomerID, count(InvoiceID),       
 0 - isnull(sum(InvoiceAbstract.Balance), 0)    
 from InvoiceAbstract, beat    
 where      
-- InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and      
 InvoiceAbstract.Balance > 0 and       
 InvoiceAbstract.InvoiceType in (4) and      
 InvoiceAbstract.Status & 128 = 0 and      
 InvoiceAbstract.Status & 64 = 0 and    
 IsNull(InvoiceAbstract.BeatID,0) = beat.BeatID And    
 beat.Description In (Select [Description] COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat)    
 group by InvoiceAbstract.BeatID, InvoiceAbstract.CustomerID      
End    

insert #temp(BeatID,Customerid, InvCount, Value )      
select customer.DefaultBeatID, Creditnote.CustomerID, count(CreditID),     
isnull(0 - sum(Creditnote.Balance),0)    
from Creditnote, Customer, Beat    
where  --Creditnote.DocumentDate between @FromDate and @ToDate and      
 Creditnote.CustomerID = Customer.CustomerID collate SQL_Latin1_General_Cp1_CI_AS And 
 Customer.DefaultBeatID = Beat.BeatID and
 Beat.[Description] in (Select [Description] from #tmpBeat) and     
 Creditnote.Balance > 0     
group by Creditnote.CustomerID, customer.DefaultBeatID   
    
insert #temp(BeatID, CustomerID,InvCount , Value)    
select customer.DefaultBeatID, Debitnote.Customerid, count(DebitId),     
isnull(sum(Debitnote.Balance),0)    
from Debitnote, customer, Beat    
where --Debitnote.DocumentDate between @FromDate and @ToDate and      
 Debitnote.CustomerID = customer.CustomerID collate SQL_Latin1_General_Cp1_CI_AS And 
 Customer.DefaultBeatID = Beat.BeatID and
 Beat.[Description] in (Select [Description] from #tmpBeat) and    
Debitnote.Balance > 0    
And IsNull(Debitnote.Status, 0) & 192 = 0 
group by Debitnote.CustomerID, customer.DefaultBeatID    
    
If @BeatName = '%'    
Begin    
 insert #temp(BeatID, CustomerID, InvCount, Value)    
 Select IsNull(Collections.BeatID,0), Collections.CustomerID, Count(DocumentID),    
 0 - Sum(Balance)    
 From Collections
 Left Outer Join beat On IsNull(Collections.BeatID,0) = beat.BeatID 
 Where --Collections.DocumentDate Between @FromDate And @ToDate And    
 Collections.Balance > 0 And    
 IsNull(Collections.Status, 0) & 128 = 0 And    
 beat.Description like @BeatName    
 Group By Collections.CustomerID, IsNull(Collections.BeatID,0)    
End    
Else    
Begin    
 insert #temp(BeatID, CustomerID, InvCount, Value)    
 Select IsNull(Collections.BeatID,0), Collections.CustomerID, Count(DocumentID),    
 0 - Sum(Balance)    
 From Collections, beat    
 Where --Collections.DocumentDate Between @FromDate And @ToDate And    
 Collections.Balance > 0 And    
 IsNull(Collections.Status, 0) & 128 = 0 And    
 IsNull(Collections.BeatID,0) = beat.BeatID And    
 beat.Description In (Select [Description] COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat)    
 Group By Collections.CustomerID, IsNull(Collections.BeatID,0)    
End    
select #temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS + ';'     
+ Cast(IsNull(#temp.BeatID,0) as nVarchar), "Beat" = IsNull(Beat.Description,@OTHERS),     
"Customer ID" = #temp.CustomerID, "Customer" = Customer.Company_Name,     
"No of Invoices" = sum(InvCount),      
"Outstanding Value (Rs.)" = Sum(Value)    
From #temp
Inner Join Customer On #temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS = Customer.CustomerID  
Left Outer Join Beat   On #temp.BeatID = Beat.BeatID 
where 
IsNull(Beat.Description, @OTHERS) In (Select [Description] COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat)    
group by #temp.CustomerID, Customer.Company_Name, Beat.Description, #temp.BeatID      
Order By IsNull(Beat.Description,@OTHERS)    

drop table #temp     
drop table #tempcustomer       
Drop Table #tmpBeat    
  


