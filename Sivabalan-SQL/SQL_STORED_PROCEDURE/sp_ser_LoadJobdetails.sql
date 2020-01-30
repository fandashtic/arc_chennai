CREATE Procedure sp_ser_LoadJobdetails(@JObcardId int)                
as                
Declare @Prefix nvarchar(15)                
select @Prefix = Prefix from VoucherPrefix                
where TranID = 'JOBCARD'                 
            
Select JobCardDetail.Product_Code, 
	'ProductName' = dbo.sp_ser_getitemname(JobCardDetail.Product_Code),
	'Product_Specification1' = JobCardDetail.Product_Specification1,
	jobcardAbstract.jobcardID, 'DocumentID' = @Prefix + cast(jobcardAbstract.DocumentID as nvarchar(15)),
	jobcardAbstract.CustomerID, Company_Name, Isnull(DocRef,'')as 'DocRef',
	isnull(PersonnelMaster.PersonnelName,'') as 'PersonnelName',          
	(case Isnull(Jobtype,'') when 0 then 'Major' when 1 then 'Minor' else '' end) as 'Jobtype'  ,           
	isnull(timein,'')as Timein,                
	'Color'= isnull(GeneralMaster.[Description],''), Jobcardabstract.jobcarddate                    
from JobcardDetail 
Inner Join jobcardAbstract on jobcardAbstract.jobcardID = jobcardDetail.jobcardID 
Left outer Join ItemInformation_Transactions i on i.DocumentID = JobCardDetail.SerialNo and i.DocumentType = 2 
Inner Join Customer On jobcardAbstract.CustomerID = Customer.CustomerID
Inner Join PersonnelMaster On jobcarddetail.inspectedby = personnelmaster.personnelid                    
Left outer Join GeneralMaster On i.Color = GeneralMaster.Code 
Where jobcardAbstract.jobcardID = @jobcardID                    
order by Company_Name    

-- Inner Join Item_Information On jobcardDetail.Product_Specification1 = Item_Information.Product_Specification1 

