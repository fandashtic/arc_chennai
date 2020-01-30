CREATE procedure sp_ser_rpt_jobwisedetail(@jobName nvarchar(255),@Fromdate datetime,@Todate datetime)              
as              
Declare @Prefix nvarchar(15)                                            
Declare @Prefix1 nvarchar(15)                
Declare @Prefix2 nvarchar(15)            
Declare @jobid nvarchar(15)                      
Declare @Itemspec1 nvarchar(50)                                                     
Declare @Iteminfo nvarchar(4000)                                                    
          
Set @jobid  = NULL                      
select @jobid  = jobid from jobmaster          
where jobname = @jobname          
          
select @Itemspec1 = servicecaption from servicesetting where servicecode = 'Itemspec1'                                                    
          
select @Prefix = Prefix from VoucherPrefix where TranID = 'JOBCARD'                            
select @Prefix1 = Prefix from VoucherPrefix where TranID = 'JOBESTIMATION'                            
select @Prefix2 = Prefix from VoucherPrefix where TranID = 'SERVICEINVOICE'                            
          
          
          
Create table #JObwiseDetail_Temp([EID] nvarchar(255))                                                    
                                    
set @Iteminfo = 'Alter Table #JObwiseDetail_Temp Add [JobCardID] nvarchar(50),           
[JobCard Date] datetime  null,                        
[Customer Name] nvarchar(50) null,         
[Item Code] nvarchar(50) null,          
[' + @ItemSpec1 + '] nvarchar(50) null,                                       
[Doc Ref] nvarchar(50) null,                        
[Remarks] nvarchar(255) null,                        
[EstimationID] nvarchar(255) null,          
[ServiceInvoiceID] nvarchar(255) null,          
[ServiceInvoice Date] datetime  null'                                                    
          
Exec sp_executesql @Iteminfo                                                    
insert into #JObwiseDetail_Temp          
SELECT           
'EId' =  jobcardabstract.jobcardid,                                  
'Jobcard ID' =  @Prefix + cast(jobcardabstract.DocumentID as nvarchar(15)),                                  
'Jobcard Date' = jobcardDate,                                  
'Customer Name' = company_Name,                      
'Item Code' = jobcardtaskallocation.product_code,          
 jobcardtaskallocation.product_specification1,          
'Doc Ref' = jobcardabstract.DocRef,                      
'Remarks' = jobcardabstract.Remarks,                    
'EstimationID' = @Prefix1 + cast(estimationabstract.documentID as nvarchar(15)),                                   
'ServiceInvoiceID' = @Prefix2 + cast(serviceinvoiceabstract.documentID as nvarchar(15)),                                   
'ServiceInvoiceDate' = ServiceInvoiceDate              
from jobcardabstract,jobcardtaskallocation,jobcarddetail,Customer,estimationabstract,serviceinvoiceabstract                                  
where jobcardabstract.customerID = customer.customerID          
and(IsNull(jobcardabstract.Status, 0) & 32) <> 0         
and (jobcarddate) between @FromDate and @ToDate                
and taskstatus = 2                     
and jobcardabstract.Estimationid = estimationabstract.Estimationid               
and jobcardabstract.serviceinvoiceid = serviceinvoiceabstract.serviceinvoiceid              
and jobcardtaskallocation.jobcardid = jobcardabstract.jobcardid              
and jobcardabstract.jobcardid in (Select jobcarddetail.jobcardid  From             
JobCardDetail Where jobcardtaskallocation.jobid = @Jobid)              
group by jobcardabstract.JobcardId,jobcardabstract.DocumentID,          
jobcardabstract.JobCardDate,Customer.Company_Name,jobcardtaskallocation.product_Code,          
jobcardtaskallocation.product_specification1,jobcardabstract.DocRef,jobcardabstract.Remarks,          
estimationabstract.DocumentID,serviceinvoiceabstract.DocumentID,serviceinvoiceabstract.ServiceInvoiceDate          
          
Select * from #JObwiseDetail_Temp          
Drop Table #JObwiseDetail_Temp             
  


