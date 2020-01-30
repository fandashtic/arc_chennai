CREATE PROCEDURE spr_DSwiseBeatwiseOutstanding           
(@DS NVARCHAR(2500),              
@BEAT NVARCHAR(2500))                
AS           
Declare @Others NVarchar(50)          
Declare @Delimeter as Char(1)              
Set @Delimeter=Char(15)            
Create Table #FinalTable (type nvarchar(2500)COLLATE SQL_Latin1_General_CP1_CI_AS,           
Custid nvarchar(2500)COLLATE SQL_Latin1_General_CP1_CI_AS, 
SalesmanID Int,         
BeatID Int,
DsName nvarchar(2500)COLLATE SQL_Latin1_General_CP1_CI_AS,           
BeatName nvarchar(2500)COLLATE SQL_Latin1_General_CP1_CI_AS,             
CustName nvarchar(2500)COLLATE SQL_Latin1_General_CP1_CI_AS,            
NoOfInvoice integer,          
InvoiceValue decimal(18,5),          
OutValue decimal(18,5))          

Set @Others = dbo.LookupDictionaryItem(N'Others', Default)          

create table #TmpSalesman(SalesmanID int,Smanname nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)           
create table #Beat(BeatID int,Beatname nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)          
         
if @DS='%'     
 Begin          
 Insert into #TmpSalesman select SalesmanID, Salesman_name from salesman where SalesmanID in 
									(select distinct SalesmanID from Beat_Salesman)   
 Insert into #TmpSalesman Values (0,@Others)        
 End 
Else              
 Insert into #TmpSalesman select SalesmanID, Salesman_name from salesman where Salesman_name in
                  (select * from dbo.sp_SplitIn2Rows(@DS,@Delimeter))           

if @BEAT='%'     
 Begin          
 insert into #Beat select BeatID,[Description] from beat where 
									 BeatID in (select distinct beatid from Beat_Salesman)
 Insert into #Beat Values (0,@Others)          
 End 
Else              
 Insert into #Beat select BeatID,[Description] from Beat where 
									 [Description] in (select * from dbo.sp_SplitIn2Rows(@BEAT,@Delimeter))

insert into #FinalTable (Custid,SalesmanID,BeatID,DsName,BeatName ,CustName,NoOfInvoice,InvoiceValue,OutValue)         
select cs.customerid,
--inva.SalesmanID, 
--inva.beatID,
Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
Where dsos.InvoiceDocumentID = inva.DocumentID), '')
When '' Then ISNULL(inva.SalesmanID, 0) Else 
IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
Where dsos.InvoiceDocumentID = inva.DocumentID), '') End ,

Case IsNull((Select Top 1 MappedBeatID From tbl_merp_dsostransfer dsos 
Where dsos.InvoiceDocumentID = inva.DocumentID), '')
When '' Then ISNULL(inva.BeatId, 0) Else 
IsNull((Select Top 1 MappedBeatID From tbl_merp_dsostransfer dsos 
Where dsos.InvoiceDocumentID = inva.DocumentID), '') End ,

#TmpSalesman.Smanname, #Beat.[Beatname],cs.company_name,          
count(inva.invoiceid),      
sum(case inva.InvoiceType when 4 then 0 - inva.NetValue else inva.NetValue end),                    
sum(case inva.InvoiceType when 4 then 0 - inva.Balance else inva.Balance end)        
from customer cs,invoiceabstract inva, #TmpSalesman, #Beat           
where InvoiceType in (1,3,4)   
and ISNULL(STATUS,0) & 128 = 0 and             
inva.balance >0 and      
inva.customerID = cs.customerID and   
--inva.SalesmanID = #TmpSalesman.SalesmanID and 
--inva.BeatID = #Beat.BeatID  
Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
Where dsos.InvoiceDocumentID = inva.DocumentID), '')
When '' Then ISNULL(inva.SalesmanID, 0) Else 
IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
Where dsos.InvoiceDocumentID = inva.DocumentID), '') End = #TmpSalesman.SalesmanID and 

Case IsNull((Select Top 1 MappedBeatID From tbl_merp_dsostransfer dsos 
Where dsos.InvoiceDocumentID = inva.DocumentID), '')
When '' Then ISNULL(inva.BeatId, 0) Else 
IsNull((Select Top 1 MappedBeatID From tbl_merp_dsostransfer dsos 
Where dsos.InvoiceDocumentID = inva.DocumentID), '') End = #Beat.BeatID 

group by #TmpSalesman.Smanname,inva.SalesmanID,inva.beatID,
			#Beat.[Beatname],cs.company_name,cs.customerid, inva.DocumentID 
union ALL   /*Union is replaced by Union All since if same value comes twice then only one value is considered in the report*/      
select cs.customerid,#TmpSalesman.SalesmanID,#Beat.BeatID, #TmpSalesman.Smanname,
			 #Beat.[Beatname],cs.company_name,          
			 count(Collections.DocumentID),sum(0 - Collections.Value),sum(0 - Collections.Balance)          
from customer cs,Collections, #TmpSalesman, #Beat           
where Collections.beatid= #Beat.beatid 
and Collections.CustomerID = Cs.CustomerID
and Collections.SalesmanID = #TmpSalesman.SalesmanID
and collections.balance > 0            
group by #TmpSalesman.Smanname,#Beat.[Beatname],#TmpSalesman.SalesmanID,#Beat.BeatID,
         cs.company_name,cs.customerid     
union ALL   /*Union is replaced by Union All since if same value comes twice then only one value is considered in the report*/      
select cs.customerid,#TmpSalesman.SalesmanID,#Beat.BeatID,#TmpSalesman.Smanname, 
			 #Beat.[Beatname], cs.company_name, count(Debitnote.DocumentID),
			  sum(Debitnote.Notevalue),sum(Debitnote.Balance)          
from #TmpSalesman, #Beat,customer cs, Debitnote           
where DebitNote.SalesmanID=#TmpSalesman.SalesmanID and           
cs.DefaultBeatID =#Beat.beatid and        
Debitnote.customerid = cs.customerid and    
debitnote.balance > 0  And IsNull(debitnote.Status, 0) & 192 = 0  
group by #TmpSalesman.Smanname,#Beat.[Beatname],#TmpSalesman.SalesmanID,#Beat.BeatID,
				 cs.company_name,cs.customerid
        
union ALL   /*Union is replaced by Union All since if same value comes twice then only one value is considered in the report*/         

select  cs.customerid,#TmpSalesman.SalesmanID,#Beat.BeatID,#TmpSalesman.Smanname, 
			 #Beat.[Beatname],cs.company_name,count(Creditnote.DocumentID),
			 sum(0 - Creditnote.Notevalue),sum(0 - Creditnote.Balance)         
from #TmpSalesman,#Beat,customer cs, Creditnote           
where CreditNote.SalesmanID=#TmpSalesman.SalesmanID and           
cs.Defaultbeatid=#Beat.beatid and 
cs.customerid = CreditNote.customerid and        
creditnote.balance > 0             
group by #TmpSalesman.Smanname,#Beat.[Beatname],#TmpSalesman.SalesmanID,#Beat.BeatID,
				 cs.company_name,cs.customerid      
        
select Custid collate SQL_Latin1_General_Cp1_CI_AS + ';' + Cast(SalesmanID as nVarchar)
 + ':' + Cast(BeatID as nVarchar) ,"DS Name"=DsName,"Beat Name"=BeatName,"Customer Name"=CustName,          
"No Of Invoices"=sum(NoOfInvoice),"BeatWise Invoice Value (%c)"=sum(InvoiceValue),          
"BeatWise Outstanding Value (%c)"=sum(OutValue) from #FinalTable          
group by #FinalTable.DsName,#FinalTable.BeatName,#FinalTable.CustName,#FinalTable.custid,
				 #FinalTable.SalesmanID, #FinalTable.BeatID        
drop table #FinalTable          
drop table #TmpSalesman          
drop table #Beat          



