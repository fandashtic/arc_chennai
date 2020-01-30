CREATE procedure sp_ser_loadissuejobcarddetail(@JobCardID int)
as
Declare @Prefix nvarchar(15)
Select @Prefix = Prefix
from VoucherPrefix Where TranID = 'JOBCARD'

Select JobCardDetail.SerialNo, JobCardDetail.Product_Code, 
'ProductName' = dbo.sp_ser_getitemname(JobCardDetail.Product_Code), 
'Product_Specification1'= JobCardDetail.Product_Specification1, 
i.DateofSale, 'Color'= IsNUll(GeneralMaster.[Description],''), Isnull(SoldBy, '') 'SoldBy',
TimeIn, JobType, InspectedBy, PersonnelName, 
JobcardAbstract.CustomerID, Company_Name, 
JobCardDate, 'PrefixID' = @Prefix + cast(JobcardAbstract.DocumentID as nvarchar(15)), JobcardAbstract.DocumentID, 
IsNull(BillingAddress, '') BillingAddress, IsNull(ShippingAddress,'') ShippingAddress,  
Discount, IsNull(DoorDelivery, 0) DoorDelivery, PayMent_Mode, IsNull(CreditTerm,0) CreditTerm, 
'Product_Specification2'= Isnull(i.Product_Specification2, ''),
'Product_Specification3'= Isnull(i.Product_Specification3, ''),
'Product_Specification4'= Isnull(i.Product_Specification4, ''), 
'Product_Specification5'= Isnull(i.Product_Specification5, ''),
'EstDocID' = EstimationAbstract.DocumentID
from JobCardDetail
Inner Join JobcardAbstract On JobcardAbstract.JobCardID = JobCardDetail.JobCardID
Inner Join EstimationAbstract On EstimationAbstract.EstimationID = JobCardAbstract.EstimationID
Left outer Join ItemInformation_Transactions i on i.DocumentID = JobCardDetail.SerialNo and i.DocumentType = 2  
Inner Join Customer on JobcardAbstract.CustomerID = Customer.CustomerID 
Inner Join PersonnelMaster on PersonnelID = InspectedBy 
Left Outer Join GeneralMaster On i.Color = GeneralMaster.Code 

Where JobcardAbstract.JobCardID = @JobCardID 
	and IsNull(JobCardDetail.JobId,'') = '' and IsNull(JobCardDetail.TaskId,'') = '' 
	and IsNull(JobCardDetail.SpareCode,'') = '' and JobCardDetail.Type = 0
Order by JobCardDetail.SerialNo 

-- Inner Join Item_Information On JobCardDetail.Product_Code = Item_Information.Product_Code 
-- 	and JobCardDetail.Product_Specification1 = Item_Information.Product_Specification1

