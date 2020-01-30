CREATE  procedure sp_ser_rpt_CancelJobCarddetail (@JobCardID int)                                
as                                
Declare @ParamSep nVarchar(10)                              
Set @ParamSep = Char(2)                              
Declare @Itemspec1 nvarchar(50)                                 
Declare @Itemspec2 nvarchar(50)                                
Declare @Itemspec3 nvarchar(50)                                
Declare @Itemspec4 nvarchar(50)                                
Declare @Itemspec5 nvarchar(50)                                
Declare @ItemInfo nvarchar(4000)                                
Declare @ItemInfo1 nvarchar(4000)
                                 
select @Itemspec1 = servicecaption from servicesetting where servicecode = 'Itemspec1'                                
select @Itemspec2 = servicecaption from servicesetting where servicecode = 'Itemspec2'                                
select @Itemspec3 = servicecaption from servicesetting where servicecode = 'Itemspec3'                                
select @Itemspec4 = servicecaption from servicesetting where servicecode = 'Itemspec4'                                
select @Itemspec5=  servicecaption from servicesetting where servicecode = 'Itemspec5'                                
      
Create table #CancelJobcardDetail_Temp([_JobcardID] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,[_Delivery Date] datetime null)        
                                
set @Iteminfo =  'Alter table #CancelJobcardDetail_Temp Add 
[_Item Code] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[_Item Name] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,                                
[' + @Itemspec1 + '] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null, 
[' + @ItemSpec2 + '] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,                                
[' + @ItemSpec3 + '] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,
[' + @ItemSpec4 + '] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,                                 
[' + @ItemSpec5 + '] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,                         
[_Color] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS null,                          
[_Inspected By] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS null,                  
[_Customer Complaints] text,        
[_Personnel Comments] text,        
[_Sold By] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS null,                        
[_Job Type] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,                        
[_Door Delivery] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,                        
[_Time in] nvarchar(5) COLLATE SQL_Latin1_General_CP1_CI_AS null,                                                        
[_Delivery Time] nvarchar(5) COLLATE SQL_Latin1_General_CP1_CI_AS null'                                  

Exec sp_executesql @Iteminfo                                

Insert into #CancelJobcardDetail_Temp                                    
                        
select 'EID' = cast(JobDet.jobcardID as nvarchar(20)) + @paramsep + JobDet.product_code + @Paramsep + JobDet.product_specification1,                                 
JobDet.Deliverydate, 
JobDet.product_code,I.productname,                                
JobDet.product_specification1,                                
IIT.product_specification2,                                
IIT.product_specification3,                                
IIT.product_specification4,                                
IIT.product_specification5,                                
GM.[Description],                        
PM.PersonnelName,                        
JobDet.CustomerComplaints,            
JobDet.PersonnelComments,                                    
IIT.soldby,                        
(case Isnull(JobDet.jobtype,'') when 0 then 'Major' when 1 then 'Minor'else '' end) as 'JobType',                             
(case isnull(JobDet.DoorDelivery,'') when 1 then 'Yes' when 0 then 'No' else '' end) as 'Door Delivery',                            
'Timein' = isnull(dbo.sp_ser_StripTimeFromDate(JobDet.Timein),''),                
'DeliveryTime' = isnull(dbo.sp_ser_StripTimeFromDate(JobDet.DeliveryTime),'')                
from JobcardAbstract JobAbs
Inner Join JobcardDetail JobDet on JobAbs.Jobcardid = Jobdet.Jobcardid
Inner Join Items I on JobDet.Product_code = I.Product_code
Inner Join PersonnelMaster PM on JobDet.InspectedBy = PM.PersonnelId
Left Outer Join ItemInformation_transactions IIT on IIT.DocumentId = JobDet.Serialno and IIT.DocumentType = 2
Left Outer Join GeneralMaster GM on IIT.Color = GM.Code
where JobAbs.JobcardID = @JobcardID                                 
and JobDet.Type = 0        

Set @Iteminfo1 = 'Select 
[_JobcardID] as "JobcardID",
[_Item Code] as "Item Code",
[_Item Name] as "Item Name",
[' + @Itemspec1 + '],[' + @ItemSpec2 + '],[' + @ItemSpec3 + '],
[' + @ItemSpec4 + '],[' + @ItemSpec5 + '],
[_Color] as "Color",
[_Inspected By] as "Inspected By",
[_Customer Complaints] as "Customer Complaints",
[_Personnel Comments] as "Personnel Comments",
[_Sold By] as "Sold By",
[_Job Type] as "Job Type",
[_Door Delivery] as "Door Delivery",
[_Time in] as "Time In",
[_Delivery Date] as "Delivery Date",
[_Delivery Time] as "Delivery Time"
from #CancelJobcardDetail_Temp'

Exec sp_executesql @Iteminfo1

Drop Table #CancelJobcardDetail_Temp      

