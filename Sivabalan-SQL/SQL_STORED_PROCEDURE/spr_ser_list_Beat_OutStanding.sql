CREATE procedure [dbo].[spr_ser_list_Beat_OutStanding](@BeatName nvarchar(2550))  
--      @FromDate datetime,    
--      @ToDate datetime)    
as  
    
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
IsNull((Select Beat.Description From Beat Where BeatID = Beat_Salesman.BeatID), 'Others')  
From Customer, Beat_Salesman  
Where Customer.CustomerID *= Beat_Salesman.CustomerID  
  

insert #temp(BeatID, CustomerID, InvCount, Value)  
select InvoiceAbstract.BeatID, InvoiceAbstract.CustomerID, count(InvoiceID),     
 isnull(sum(InvoiceAbstract.Balance), 0)  
 from InvoiceAbstract
 Left Outer Join beat  on IsNull(InvoiceAbstract.BeatID,0) = isNull(Beat.BeatID,0)
 where     
-- InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and    
 InvoiceAbstract.Balance > 0 and     
 InvoiceAbstract.InvoiceType in (1, 3) and
 InvoiceAbstract.Status & 128 = 0 and    
 ((IsNull(InvoiceAbstract.BeatID,0) = 0 
And exists (Select [Description] COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat
where Description='Others'))
or (Beat.Description in (Select [Description] COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) and @BeatName<>'%')
or (isNull(Beat.Description,'Others') like '%' and @BeatName='%'))
and Invoiceabstract.Status & 64 = 0  
group by InvoiceAbstract.BeatID, InvoiceAbstract.CustomerID

insert #temp(BeatID, CustomerID, InvCount, Value)  
select InvoiceAbstract.BeatID, InvoiceAbstract.CustomerID, count(InvoiceID),     
 0 - isnull(sum(InvoiceAbstract.Balance), 0)  
 from InvoiceAbstract
Left Outer Join beat  on IsNull(InvoiceAbstract.BeatID,0) = isNull(Beat.BeatID,0)
 where    
-- InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and    
 InvoiceAbstract.Balance > 0 and     
 InvoiceAbstract.InvoiceType in (4) and    
 InvoiceAbstract.Status & 128 = 0 and    
 InvoiceAbstract.Status & 64 = 0 and  
 ((IsNull(InvoiceAbstract.BeatID,0) = 0 
And exists (Select [Description] COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat
where Description='Others' ))
or (Beat.Description in (Select [Description] COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) and @BeatName<>'%')
or (isNull(Beat.Description,'Others') like '%' and @BeatName='%'))
group by InvoiceAbstract.BeatID, InvoiceAbstract.CustomerID    


--Begin: Service Invoice Impact
insert #temp(BeatID, CustomerID, InvCount, Value)  
Select 0,CustomerID,Count(ServiceInvoiceID),
		isNull(sum(Balance),0)
from ServiceInvoiceAbstract
where isNull(Balance,0)> 0 and ServiceInvoiceType in (1)
and isNull(Status,0) & 192 = 0 and
(@BeatName = '%' or exists (Select [Description] COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat
where Description='Others' ))
group by CustomerID
--End: Service Invoice Impact


insert #temp(BeatID,Customerid, InvCount, Value )    
select #tempcustomer.BeatID , Creditnote.CustomerID, count(CreditID),   
isnull(0 - sum(Creditnote.Balance),0)  
from Creditnote, #tempcustomer  
where  --Creditnote.DocumentDate between @FromDate and @ToDate and    
 Creditnote.CustomerID = #tempcustomer.CustomerID collate SQL_Latin1_General_Cp1_CI_AS And  
((IsNull(#tempcustomer.BeatID,0) = 0 
And exists (Select [Description] COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat
where Description='Others' ))
or ( #tempcustomer.Beat_Description collate SQL_Latin1_General_Cp1_CI_AS in (Select [Description] COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) and @BeatName<>'%')
or (isNull( #tempcustomer.Beat_Description collate SQL_Latin1_General_Cp1_CI_AS,'Others') like '%' and @BeatName='%')) and
Creditnote.Balance > 0   
group by Creditnote.CustomerID  , #tempcustomer.beatid  


insert #temp(BeatID, CustomerID,InvCount , Value)    
select #tempcustomer.beatid,Debitnote.Customerid, count(DebitId),   
isnull(sum(Debitnote.Balance),0)  
from Debitnote, #tempcustomer  
where --Debitnote.DocumentDate between @FromDate and @ToDate and    
 Debitnote.CustomerID = #tempcustomer.CustomerID collate SQL_Latin1_General_Cp1_CI_AS And  
((IsNull(#tempcustomer.BeatID,0) = 0 
And exists (Select [Description] COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat
where Description='Others' ))
or ( #tempcustomer.Beat_Description collate SQL_Latin1_General_Cp1_CI_AS in (Select [Description] COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) and @BeatName<>'%')
or (isNull( #tempcustomer.Beat_Description collate SQL_Latin1_General_Cp1_CI_AS,'Others') like '%' and @BeatName='%')) and
Debitnote.Balance > 0   
group by Debitnote.CustomerID, #tempcustomer.beatid  
  

insert #temp(BeatID, CustomerID, InvCount, Value)  
 Select IsNull(Collections.BeatID,0), Collections.CustomerID, Count(DocumentID),  
 0 - Sum(Balance)  
 From Collections 
 Left Outer Join beat  on IsNull(Collections.BeatID,0) = isNull(Beat.BeatID,0)
 Where --Collections.DocumentDate Between @FromDate And @ToDate And  
 Collections.Balance > 0 And  
 IsNull(Collections.Status, 0) & 128 = 0 And  
 ((IsNull(Collections.BeatID,0) = 0 
And exists (Select [Description] COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat
where Description='Others' ))
or (Beat.Description in (Select [Description] COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) and @BeatName<>'%')
or (isNull(Beat.Description,'Others') like '%' and @BeatName='%'))
Group By Collections.CustomerID, Collections.BeatID


select  #temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS + ';'   
+ Cast(IsNull(#temp.BeatID,0) as nVarchar), "Beat" = IsNull(Beat.Description,'Others'),   
"Customer ID" = #temp.CustomerID, "Customer" = Customer.Company_Name,   
"No of Invoices" = sum(InvCount),    
"Outstanding Value (Rs.)" = Sum(Value)  
From #temp, Customer, Beat    
where #temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS = Customer.CustomerID  
And #temp.BeatID *= Beat.BeatID And  
IsNull(Beat.Description, 'Others') In (Select [Description] COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat)  
group by #temp.CustomerID, Customer.Company_Name, Beat.Description, #temp.BeatID    
Order By IsNull(Beat.Description,'Others')  

drop table #temp   
drop table #tempcustomer  
Drop Table #tmpBeat
