CREATE procedure sp_ser_loadissuedetail(@IssueID int)  
as  
Declare @JCPrefix nvarchar(15)  
Declare @ISSPrefix nvarchar(15)  
Select @JCPrefix = Prefix from VoucherPrefix Where TranID = 'JOBCARD'  
Select @ISSPrefix = Prefix from VoucherPrefix Where TranID = 'ISSUESPARES'  
  
Select JobCardDetail.SerialNo, JobCardDetail.Product_Code,   
'ProductName' = dbo.sp_ser_getitemname(JobCardDetail.Product_Code),   
'Product_Specification1'= JobCardDetail.Product_Specification1,   
IsNull(i.DateofSale, '') DateofSale, 'Color'= IsNUll(GeneralMaster.[Description],''),   
IsNull(i.SoldBy, '') SoldBy,  
TimeIn, JobType, InspectedBy, PersonnelName, JobcardAbstract.CustomerID, Company_Name,   
Jobcardabstract.JobCardDate, Issueabstract.IssueDate,   
JobcardAbstract.DocumentID 'JCDocID', IssueAbstract.DocumentID 'ISSDocID',   
'JCPrefixID' = @JCPrefix + cast(JobcardAbstract.DocumentID as nvarchar(15)),   
'ISSPrefixID' = @ISSPrefix + cast(Issueabstract.DocumentID as nvarchar(15)),  
IsNull(IssueAbstract.DocRef, '') 'DocRef' ,Isnull(Issueabstract.DocSerialType,'') 'DocSerialType'  
from JobCardDetail  
Inner Join JobcardAbstract On JobcardAbstract.JobCardID = JobCardDetail.JobCardID  
Left outer Join ItemInformation_Transactions i on i.DocumentID = JobCardDetail.SerialNo and i.DocumentType = 2 
Inner Join Customer on JobcardAbstract.CustomerID = Customer.CustomerID  
Inner Join PersonnelMaster on PersonnelID = InspectedBy   
Inner Join (Select Distinct Issuedetail.IssueID, Issuedetail.Product_Code,   
 Issuedetail.Product_Specification1 from Issuedetail   
 where Issuedetail.issueid = @IssueID) Issuedet   
 On Issuedet.Product_Code = JobCardDetail.Product_Code   
 and Issuedet.Product_Specification1 = JobCardDetail.Product_Specification1   
Inner Join Issueabstract on Issueabstract.JobcardID = JobCardabstract.JobcardId  
Left Outer Join GeneralMaster On i.Color = GeneralMaster.Code  
Where Issueabstract.IssueID = @IssueID   
 and IsNUll(JobCardDetail.JobId, '') = '' and IsNull(JobCardDetail.TaskId, '') = ''   
 and IsNull(JobCardDetail.SpareCode, '') = '' and JobCardDetail.Type = 0  
Order by JobCardDetail.SerialNo  
  

-- Inner Join Item_Information On JobCardDetail.Product_Code = Item_Information.Product_Code   
--  and JobCardDetail.Product_Specification1 = Item_Information.Product_Specification1  


