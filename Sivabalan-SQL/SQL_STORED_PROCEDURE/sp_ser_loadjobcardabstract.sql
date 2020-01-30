CREATE procedure sp_ser_loadjobcardabstract(@FromDate Datetime,@ToDate Datetime,      
@Mode Int,@CUSTOMER NVARCHAR(15) = '',@IssueStatus Int=-1)--(-1) for execute the Query in Previous Version(1.4) ( with out issue filter)      
as    
--[@Mode:  1 - Cancel, 2 - View, 3 - Amend]    
--[Status for JobCard: 0 - From Acknowledgement, 1 - Implcit, 8 - Direct, 16 - Amendment  
--,  32 - Invoiced, 64 Cancelled, 128 - Amendment]  
  
Declare @Prefix nvarchar(15)      
select @Prefix = Prefix from VoucherPrefix      
where TranID = 'JOBCARD'      
      
If @IssueStatus=-1      
begin      
      
 If @Mode = 1      
 Begin      
  select JobCardID,'DocumentID' = @Prefix + cast(DocumentID as nvarchar(15)),JobCardDate,      
  Company_Name,'Status'=IsNull(Status,0), IsNull(DocRef,'') DocRef       
   ,'ApprovedStatus' = IsNull(ApprovedStatus,0)
  from JobCardAbstract,Customer      
  Where dbo.stripdatefromtime(JobCardDate) between @FromDate and @ToDate      
  and (IsNull(Status, 0) & 192) = 0 and (IsNull(Status, 0) & 32) = 0       
  and isnull(JobCardAbstract.ApprovedStatus, 0)=0
  and JobCardAbstract.CustomerID = Customer.CustomerID      
  and JobCardAbstract.CustomerID LIKE @CUSTOMER      
  order by Company_Name, JobCardID      
 End      
 Else If @Mode = 2 or @Mode = 3
 Begin      
  select JobCardID,'DocumentID' = @Prefix + cast(DocumentID as nvarchar(15)),JobCardDate,      
  Company_Name,'Status'=IsNull(Status,0), IsNull(DocRef, '') DocRef
  ,'ApprovedStatus' = IsNull(ApprovedStatus,0)
  from JobCardAbstract,Customer      
  Where dbo.stripdatefromtime(JobCardDate) between @FromDate and @ToDate      
  and JobCardAbstract.CustomerID = Customer.CustomerID      
        and JobCardAbstract.CustomerID LIKE @CUSTOMER         
  order by Company_Name, JobCardID      
 End      
End      
else if @IssueStatus = -2      
begin      
 select JCA.JobCardID,'DocumentID' = @Prefix + cast(JCA.DocumentID as nvarchar(15)),JCA.JobCardDate,      
 CUST.Company_Name,'Status'=IsNull(JCA.Status,0), IsNull(JCA.DocRef,'') DocRef,      
  "JobCardStatus" =  (Case Resultset.Status      
     when 1 then 'Completed'      
     when 2 then 'Pending'      
     end)      
 from JobCardAbstract JCA      
 Inner Join Customer CUST on JCA.CustomerID = CUST.CustomerID      
 Inner Join       
 (Select JobCardID, "Status"=(Case (isNull(      
  (select Count(JCS.JobCardID)from JobCardSpares JCS       
  where isNull(JCS.PendingQty,0)>0 and Isnull(JCS.SpareStatus, 0) <> 2 and       
  JobCardAbstract.JobCardID=JCS.JobCardID ),0)      
 + isNull(      
  (select Count(JCT.JobCardID)from JobCardTaskAllocation JCT       
  where isNull(JCT.TaskStatus,0) in (0,1) and JCT.JobCardID = JobCardAbstract.JobCardID)      
 ,0)) when 0 then 1      
 else 2      
 end) from JobCardAbstract       
 where (IsNull(Status, 0) & 192) = 0 and (IsNull(Status, 0) & 32) = 0      
 and dbo.stripdatefromtime(JobCardDate) between @FromDate and @ToDate) as ResultSet      
 on ResultSet.JobCardID = JCA.JobCardID      
 Where dbo.stripdatefromtime(JCA.JobCardDate) between @FromDate and @ToDate      
 and (IsNull(JCA.Status, 0) & 192) = 0 and (IsNull(JCA.Status, 0) & 32) = 0       
 and JCA.CustomerID LIKE @CUSTOMER         
 and (ResultSet.Status = @Mode or @Mode = 3)      
    order by CUST.Company_Name, JCA.JobCardID      
end      
else      
begin      
        
 Select jobCardAbstract.JobCardID,'DocumentID' = @Prefix + cast(DocumentID as nvarchar(15)),JobCardDate,      
 Company_Name,'Status'=IsNull(Status,0), IsNull(DocRef,'') DocRef,      
 "IssueStatus"=(Case ResultSet.IssueStatus      
  when 0 then 'Fully Assigned'      
  when 1 then 'Partially Assigned'      
  when 2 then 'Fully Pending'      
  when 5 then 'No spare selected for this job card'      
 end)      
 from JobCardAbstract       
 Inner Join Customer on  JobCardAbstract.CustomerID = Customer.CustomerID      
 Inner Join (select JCA.jobCardid, "IssueStatus" = (Case isNull(sum(Qty-PendingQty),-1)      
   when -1 then 5      
   when 0 then 2      
   when sum(Qty) then 0      
   else 1      
   end)      
 from JobCardSpares JCS      
 Right Outer join JobCardAbstract JCA      
 on JCS.JobCardID=JCA.JobCardID       
 where isNull(JCS.SpareStatus,0)<>2       
 group by JCA.jobCardID) as ResultSet      
      
 on  JobCardAbstract.JobCardID = ResultSet.JobCardID         
 Where dbo.stripdatefromtime(JobCardDate) between @FromDate and @ToDate      
 and (IsNull(Status, 0) & 192) = 0 and (IsNull(Status, 0) & 32) = 0       
    and JobCardAbstract.CustomerID LIKE @CUSTOMER         
 and ((@issueStatus <> 3 and isNull(ResultSet.IssueStatus,5) = @issuestatus) or @issueStatus=3)      
 order by Company_Name, jobCardAbstract.JobCardID      
end      
