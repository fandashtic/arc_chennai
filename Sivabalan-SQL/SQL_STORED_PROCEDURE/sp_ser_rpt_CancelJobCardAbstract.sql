CREATE procedure sp_ser_rpt_CancelJobCardAbstract(@Fromdate datetime,@Todate datetime)                          
As                          
Declare @Prefix nvarchar(15)                                    
Declare @Prefix1 nvarchar(15)                                                
select @Prefix = Prefix from VoucherPrefix where TranID = 'JOBCARD'                    
select @Prefix1 = Prefix from VoucherPrefix where TranID = 'ACKNOWLEDGEMENT'                    
SELECT 'ID' = JobcardAbstract.JobcardID,                    
'JobCardID' =  @Prefix + cast(JobcardAbstract.DocumentID as nvarchar(15)),                          
'JobCard Date' = JobcardDate,                          
'Customer Name' = company_Name,              
'Doc Ref' = JobcardAbstract.DocRef,              
'Remarks' = JobcardAbstract.Remarks,            
'AcknowledgementID' = @Prefix1 + cast(JCAcknowledgementAbstract.documentID as nvarchar(15))                           
from JobcardAbstract,Customer,JCAcknowledgementAbstract                          
where JobcardAbstract.CustomerID = Customer.CustomerID                          
and JobcardAbstract.AcKnowledgementID = JCAcknowledgementAbstract.AcKnowledgementID
and (jobcardDate) between @FromDate and @ToDate                  
and (IsNull(JobcardAbstract.Status, 0) & 192) <> 0            
