CREATE procedure sp_ser_loadjobcarddetail(@JobCardID int)  
as  
Declare @Prefix nvarchar(15)  
Select @Prefix = Prefix  
from VoucherPrefix Where TranID = 'JOBCARD'  
  
Select JobCardDetail.SerialNo, JobCardDetail.Product_Code,   
'ProductName' = dbo.sp_ser_getitemname(JobCardDetail.Product_Code),  
'Product_Specification1' = JobCardDetail.Product_Specification1,  
'Product_Specification2' = Isnull(i.Product_Specification2, ''), 
'Product_Specification3' = Isnull(i.Product_Specification3, ''), 
'Product_Specification4' = Isnull(i.Product_Specification4, ''),  
'Product_Specification5' = Isnull(i.Product_Specification5, ''),  
i.DateofSale, 'Color'= IsNUll(GeneralMaster.[Description],''), 
IsNull(SoldBy, '') 'SoldBy', DeliveryDate, DeliveryTime, TimeIn, JobType, DoorDelivery, 
IsNull(InspectedBy,'') 'InspectedBy', PersonnelName, IsNull(CustomerComplaints,'') 'CustomerComplaints', 
IsNull(PersonnelComments,'') 'PersonnelComments', JobcardAbstract.CustomerID, Company_Name,  
JobCardDate, 'PrefixID' = @Prefix + cast(JobcardAbstract.DocumentID as nvarchar(15)), JobcardAbstract.DocumentID, 
IsNull(JobcardAbstract.DocRef,'') 'DocRef', IsNull(Remarks, '') 'Remark',Isnull(DocSerialType,'') 'DocSerialType'  
from JobCardDetail  
Inner Join JobcardAbstract On JobcardAbstract.JobCardID = JobCardDetail.JobCardID  
Left outer Join ItemInformation_Transactions i on i.DocumentID = JobCardDetail.SerialNo and i.DocumentType = 2 
Inner Join Customer on JobcardAbstract.CustomerID = Customer.CustomerID  
Inner Join PersonnelMaster on PersonnelID = InspectedBy   
Left Outer Join GeneralMaster On i.Color = GeneralMaster.Code    
Where JobcardAbstract.JobCardID = @JobCardID   
 and Isnull(JobCardDetail.JobId, '') = '' and IsNull(JobCardDetail.TaskId, '') = ''   
 and IsNull(JobCardDetail.SpareCode, '') = '' and JobCardDetail.Type = 0  
Order by JobCardDetail.SerialNo 




