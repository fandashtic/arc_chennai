CREATE procedure [dbo].[sp_ser_list_JobAllocation](@FromDate Datetime,@ToDate Datetime,@Mode int,@CUSTOMER NVARCHAR(15) = '' )                      
as                  
Declare @Prefix nvarchar(15)                  
declare @status nvarchar(100)
select @Prefix = Prefix from VoucherPrefix                  
where TranID = 'JOBCARD'                   
-- Fully open
IF @Mode = 0
Begin

	Select jobcardabstract.Jobcardid,'DocumentID' = @Prefix + cast(DocumentID as nvarchar(15)),jobcarddate,    
	company_name,'DocRef' = Isnull(DocRef,''),
        "Status" = dbo.sp_ser_jobstatus(jobcardabstract.Jobcardid) into #StatusTemp1
	from jobcardabstract,customer,jobcardtaskallocation                   
	where jobcardabstract.customerid = customer.customerid                  
	and jobcardabstract.jobcardid = jobcardtaskallocation.jobcardid
	and JobCardAbstract.CustomerID LIKE @CUSTOMER
	and  dbo.stripdatefromtime(jobcardDate) between @Fromdate and @Todate
	and (IsNull(Status,0) & 192) = 0              
	and (IsNull(Status,0) & 32) = 0 
	and isnull(jobcardtaskallocation.personnelID,'') = '' 
	and isnull(Taskstatus,0) = 0            
        group by jobcardabstract.Jobcardid,DocumentID,jobcardabstract.JobCardDate,company_name,docref  
	order by company_name,documentid          
        select * from #StatusTemp1 where #StatusTemp1.Status = 'Fully Open'
        drop table #StatusTemp1
End
-- Fully assign
Else if @Mode = 1
Begin
	Select jobcardabstract.Jobcardid,'DocumentID' = @Prefix + cast(DocumentID as nvarchar(15)),jobcarddate,    
	company_name,'DocRef' = Isnull(DocRef,''),
        "Status" = dbo.sp_ser_jobstatus(jobcardabstract.Jobcardid) into #StatusTemp2   
	from jobcardabstract,customer,jobcardtaskallocation                   
	where jobcardabstract.customerid = customer.customerid                  
	and JobCardAbstract.CustomerID LIKE @Customer
	and jobcardabstract.jobcardid = jobcardtaskallocation.jobcardid    
	and  dbo.stripdatefromtime(jobcardDate) between @Fromdate and @Todate
	and (IsNull(Status,0) & 192) = 0              
	and (IsNull(Status,0) & 32) = 0              
	and isnull(Taskstatus,0) in (1,2)             
	and isnull(jobcardtaskallocation.personnelID,'') <> ''
        group by jobcardabstract.Jobcardid,DocumentID,jobcardabstract.JobCardDate,company_name,docref 
	order by company_name,documentid          
        select * from #statusTemp2 where #statusTemp2.status = 'Fully Assigned'
        drop table #statusTemp2
End
-- Closed
IF @Mode = 2
Begin
 
	Select jobcardabstract.Jobcardid,'DocumentID' = @Prefix + cast(DocumentID as nvarchar(15)),jobcarddate,    
	company_name,'DocRef' = Isnull(DocRef,''),
        "Status" = dbo.sp_ser_jobstatus(jobcardabstract.Jobcardid) into #StatusTemp3   
	from jobcardabstract,customer,jobcardtaskallocation                   
	where jobcardabstract.customerid = customer.customerid                  
	and jobcardabstract.jobcardid = jobcardtaskallocation.jobcardid
	and JobCardAbstract.CustomerID LIKE  @CUSTOMER
	and  dbo.stripdatefromtime(jobcardDate) between @Fromdate and @Todate
	and (IsNull(Status,0) & 192) = 0              
	and (IsNull(Status,0) & 32) = 0 
	and isnull(Taskstatus,0) = 2            
	group by jobcardabstract.Jobcardid,DocumentID,jobcardabstract.JobCardDate,company_name,docref 
	order by company_name,documentid          
        select * from #statusTemp3 where #statusTemp3.status = 'Fully Closed '
        drop table #statusTemp3
        
End
-- cancelled
Else if @Mode = 3
Begin

	Select jobcardabstract.Jobcardid,'DocumentID' = @Prefix + cast(DocumentID as nvarchar(15)),jobcarddate,    
	company_name,'DocRef' = Isnull(DocRef,''),
        "Status" = dbo.sp_ser_jobstatus(jobcardabstract.Jobcardid) into #StatusTemp4   
	from jobcardabstract,customer,jobcardtaskallocation                   
	where jobcardabstract.customerid = customer.customerid                  
	and jobcardabstract.jobcardid = jobcardtaskallocation.jobcardid    
	and JobCardAbstract.CustomerID LIKE @Customer
	and  dbo.stripdatefromtime(jobcardDate) between @Fromdate and @Todate
	and (IsNull(Status,0) & 192) = 0              
	and (IsNull(Status,0) & 32) = 0              
	and isnull(Taskstatus,0) = 3            
--	and isnull(jobcardtaskallocation.personnelID,'') <> '' 
       	group by jobcardabstract.Jobcardid,DocumentID,jobcardabstract.JobCardDate,company_name,docref 
	order by company_name,documentid          
        select * from #statusTemp4 where #statusTemp4.status = 'Fully Cancelled'
        drop table #statusTemp4

End
-- partially assign
Else if @Mode = 4 
Begin

	Select jobcardabstract.Jobcardid,'DocumentID' = @Prefix + cast(DocumentID as nvarchar(15)),jobcarddate,    
	company_name,'DocRef' = Isnull(DocRef,''),
        "Status" = dbo.sp_ser_jobstatus(jobcardabstract.Jobcardid) into #StatusTemp5   
	from jobcardabstract,customer,jobcardtaskallocation                   
	where jobcardabstract.customerid = customer.customerid                  
	and jobcardabstract.jobcardid = jobcardtaskallocation.jobcardid    
	and JobCardAbstract.CustomerID LIKE @CUSTOMER
	and  dbo.stripdatefromtime(jobcardDate) between @Fromdate and @Todate
	and (IsNull(Status,0) & 192) = 0              
	and (IsNull(Status,0) & 32) = 0              
	and isnull(Taskstatus,0) in(0,1,2,3)
--     	and isnull(jobcardtaskallocation.personnelID,'') <> '' 
        group by jobcardabstract.Jobcardid,DocumentID,jobcardabstract.JobCardDate,company_name,docref
	order by company_name,documentid 
        select * from #statusTemp5 where #statusTemp5.status = 'Partially Assigned'
        drop table #statusTemp5
End
---All
Else if @Mode = 5 
Begin
	Select jobcardabstract.Jobcardid,'DocumentID' = @Prefix + cast(DocumentID as nvarchar(15)),jobcarddate,    
	company_name,'DocRef' = Isnull(DocRef,''),
        "Status" = dbo.sp_ser_jobstatus(jobcardabstract.jobcardid) 
	from jobcardabstract,customer,jobcardtaskallocation
	where jobcardabstract.customerid = customer.customerid
        and jobcardabstract.jobcardid *= jobcardtaskallocation.jobcardid                      
	and JobCardAbstract.CustomerID LIKE @CUSTOMER
	and  dbo.stripdatefromtime(jobcardDate) between @Fromdate and @Todate
	and (IsNull(Status,0) & 192) = 0              
	and (IsNull(Status,0) & 32) = 0           
	group by jobcardabstract.Jobcardid,DocumentID,jobcardabstract.JobCardDate,company_name,docref   
	order by company_name,documentid          
  
/*Else
Select jobcardabstract.Jobcardid,'DocumentID' = @Prefix + cast(DocumentID as nvarchar(15)),    
jobcarddate,company_name,'DocRef' = Isnull(DocRef,''),                                              
"Status" = ''
from jobcardabstract,customer
where jobcardabstract.customerid = customer.customerid                        
and  dbo.stripdatefromtime(jobcardDate) between @Fromdate and @Todate
and (IsNull(Status, 0) & 192) = 0          
and (IsNull(Status,0) & 32) = 0              
order by company_name,Documentid                                             */

End
