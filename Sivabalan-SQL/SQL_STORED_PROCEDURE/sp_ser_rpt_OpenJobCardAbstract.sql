CREATE procedure sp_ser_rpt_OpenJobCardAbstract(@Fromdate datetime,@Todate datetime)                          
As                          
Declare @Prefix nvarchar(15)                                    
Declare @Prefix1 nvarchar(15)                                                
select @Prefix = Prefix from VoucherPrefix where TranID = 'JOBCARD'                    
select @Prefix1 = Prefix from VoucherPrefix where TranID = 'JOBESTIMATION'                    
SELECT 'ID' = jobcardabstract.JobcardID,                    
 'JobCardID' =  @Prefix + cast(jobcardabstract.DocumentID as nvarchar(15)),                          
'JObCard Date' = jobcardDate,                          
'Customer Name' = company_Name,              
'Doc Ref' = Isnull(jobcardabstract.DocRef,''),              
'Remarks' = Isnull(jobcardabstract.Remarks,''),            
'EstimationID' = @Prefix1 + cast(estimationabstract.documentID as nvarchar(15))                           
from jobcardabstract,Customer,estimationabstract                          
where jobcardabstract.customerID = customer.customerID                          
and jobcardabstract.Estimationid = estimationabstract.Estimationid          
and (jobcarddate) between @FromDate and @ToDate                  
and (IsNull(jobcardabstract.Status,0)) = 0                   



