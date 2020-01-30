CREATE procedure sp_ser_rpt_ServiceRevenueDetail(@ServiceFromDate datetime)  
As              
                                            
Declare @Prefix nvarchar(15)                      
Declare @Prefix1 nvarchar(15)                      
Declare @Prefix2 nvarchar(15)                      
Declare @ParamSep nVarchar(10)                              
Set @ParamSep = Char(2)                                
Declare @ItemSpec1  nvarchar(50)                                                 
  
Declare @ToDatePair datetime                      
Set @ToDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @ServiceFromDate))            
  
                
select @Prefix = Prefix from VoucherPrefix where TranID = 'SERVICEINVOICE'                                      
select @Prefix1 = Prefix from VoucherPrefix where TranID = 'JOBCARD'                                      
              
Select [ID],[ServiceInvoiceID],[ServiceInvoice Date],[Doc Ref],  
Sum([Tasksum])As [Task GrossValue],Sum([Sparesum ])As [Spare GrossValue],                  
Sum([Tasksumnet])As [Task Net Value],Sum([Sparesumnet])As [Spare Net Value ],                                  
[JobCardID],[JobCard Date]  
FROM                                          
(SELECT 'ID' = ServiceInvoiceabstract.ServiceinvoiceID,                  
'ServiceInvoiceID' =  @Prefix + cast(ServiceInvoiceabstract.DocumentID as nvarchar(15)),                                            
'ServiceInvoice Date' = serviceinvoiceDate,                                            
'Doc Ref' = DocReference,                                
'Tasksum '=                       
 case when Isnull(Taskid,'')  <> '' and Isnull(sparecode,'') = '' then Cast(sum(ServiceInvoiceDetail.Amount) as Decimal(18,6)) else 0 end,                           
'Sparesum ' = case when Isnull(sparecode,'')  <> ''  then Cast(sum(ServiceInvoiceDetail.Amount) as Decimal(18,6)) else 0 end,                                        
'TasksumNet'=                       
 case when Isnull(Taskid,'') <> '' and Isnull(sparecode,'') = '' then Cast(sum(ServiceInvoiceDetail.Netvalue) as Decimal(18,6)) else 0 end,                           
'SparesumNet' = case when  Isnull(sparecode,'')  <> ''  then Cast(sum(ServiceInvoiceDetail.Netvalue) as Decimal(18,6)) else 0 end,                                        
'JobCardID' =  @Prefix1 + cast(jobcardabstract.DocumentID as nvarchar(15)),                                            
'JobCard Date' = jobcardabstract.jobcarddate                  
from serviceinvoiceabstract,serviceinvoicedetail,jobcardabstract  
where serviceinvoiceabstract.serviceinvoiceid = serviceinvoicedetail.serviceinvoiceid                  
and(serviceinvoiceabstract.serviceinvoicedate) between @ServiceFromDate and @ToDatePair  
and  serviceinvoiceabstract.serviceinvoiceid = jobcardabstract.serviceinvoiceid                  
and  serviceinvoiceabstract.jobcardid = jobcardabstract.jobcardid                  
and (IsNull(serviceinvoiceabstract.Status,0) & 192) = 0                                              
group by serviceinvoiceabstract.serviceinvoiceid,                  
serviceinvoiceabstract.documentid,--serviceinvoicedetail.Product_Specification1,  
serviceinvoicedate,ServiceInvoiceDate,                  
serviceinvoiceabstract.DocReference,  
serviceinvoicedetail.SpareCode,                  
serviceinvoicedetail.TaskID,  
serviceinvoiceabstract.NetValue,                  
jobcardabstract.Documentid,jobcardabstract.jobcarddate) as grt                  
group by [ID],[ServiceInvoiceID],[ServiceInvoice Date],[doc Ref],  
[JobCardID],[JobCard Date]  

