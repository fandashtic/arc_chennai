Create Procedure sp_ser_ServiceDateValidate(@JobcardID int,@InvoiceDate DateTime)  
AS  
Select "Status" = Case when Max(MDate) < @InvoiceDate then 0 else 1
				end from (  
 select max(issuedate) MDate  
 from issueabstract, jobcardabstract where   
  issueabstract.jobcardid = @JobcardID and   
  jobcardabstract.jobcardid = issueabstract.jobcardid and   
  isnull(issueabstract.status,0) & 192 = 0 and   
  isnull(jobcardabstract.status,0) & 192 = 0  
 Union   
 select Max(EndTime) 
 from JobcardTaskAllocation where    
  JobcardTaskAllocation.JobCardId = @JobCardID and   
  JobcardTaskAllocation.Taskstatus = 2) M

