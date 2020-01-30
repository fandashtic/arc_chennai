CREATE procedure sp_ser_rpt_IssueAbstract(@Fromdate datetime,@Todate datetime)                                
As                                
Declare @Prefix nvarchar(15)                                          
Declare @Prefix1 nvarchar(15)                                                          
select @Prefix = Prefix from VoucherPrefix where TranID = 'ISSUESPARES'                          
select @Prefix1 = Prefix from VoucherPrefix where TranID = 'JOBCARD'                          
SELECT 'ID' = Issueabstract.IssueID,              
'IssueID' =  @Prefix + cast(issueabstract.DocumentID as nvarchar(15)),                                
'Issue Date' = IssueDate,                                
'Customer Name' = company_Name,                    
'Doc Ref' = issueabstract.DocRef,                    
'JobCardID' = @Prefix1 + cast(jobcardabstract.Documentid as nvarchar(15)),              
'JobCard Date' = jobcardabstract.jobcarddate                  
from Issueabstract,jobcardabstract,Customer                                
where jobcardabstract.customerID = customer.customerID                                
and issueabstract.JobcardID = jobcardabstract.jobcardid                  
and (issuedate) between @FromDate and @ToDate                 
and (IsNull(issueabstract.Status,0) & 192) = 0                                
      

