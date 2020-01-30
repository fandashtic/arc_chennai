CREATE procedure sp_ser_loadissuedjcdetail(@JobCardID int)
as
Declare @JCPrefix nvarchar(15)
Declare @ISSUEPrefix nvarchar(15)
Select @JCPrefix = Prefix
from VoucherPrefix Where TranID = 'JOBCARD'
Select @ISSUEPrefix = Prefix
from VoucherPrefix Where TranID = 'ISSUESPARES'

Select JobCardDetail.SerialNo, JobCardDetail.Product_Code, 
'ProductName' = dbo.sp_ser_getitemname(JobCardDetail.Product_Code), 
'Product_Specification1'= JobCardDetail.Product_Specification1, 
i.DateofSale, 'Color'= IsNUll(GeneralMaster.[Description],''), Isnull(SoldBy, '') 'SoldBy',
TimeIn, JobType, InspectedBy, PersonnelName, 
JobcardAbstract.CustomerID, Company_Name, JobCardAbstract.DocumentID 'JCDocumentID', 
JobCardDate, 'JCPrefixID' = @JCPrefix + cast(JobcardAbstract.DocumentID as nvarchar(15)), 
IssueAbstract.DocumentID 'ISSUEDocumentID', 
Issuedate, 'ISSUEPrefixID' = @ISSUEPrefix + cast(IssueAbstract.DocumentID as nvarchar(15)), 
IssueID 

from JobCardDetail
Inner Join JobcardAbstract On JobcardAbstract.JobCardID = JobCardDetail.JobCardID
Inner Join IssueAbstract On IssueAbstract.JobCardID = JobCardAbstract.JobCardID and 
	(IsNull(IssueAbstract.Status,0) & 192) = 0 
Left outer Join ItemInformation_Transactions i on i.DocumentID = JobCardDetail.SerialNo and i.DocumentType = 2 
Inner Join Customer on JobcardAbstract.CustomerID = Customer.CustomerID
Inner Join PersonnelMaster on PersonnelID = InspectedBy 
Left Outer Join GeneralMaster On i.Color = GeneralMaster.Code

Where JobcardAbstract.JobCardID = @JobcardID 
	and IsNull(JobCardDetail.JobId,'') = '' and IsNull(JobCardDetail.TaskId, '') = '' 
	and IsNull(JobCardDetail.SpareCode, '') = '' and JobCardDetail.Type = 0
Order by IssueID, JobCardDetail.SerialNo

-- Inner Join Item_Information On JobCardDetail.Product_Code = Item_Information.Product_Code 
-- 	and JobCardDetail.Product_Specification1 = Item_Information.Product_Specification1

