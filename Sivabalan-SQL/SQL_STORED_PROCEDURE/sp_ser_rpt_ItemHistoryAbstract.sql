
CREATE procedure sp_ser_rpt_ItemHistoryAbstract(@FromDate datetime, @ToDate datetime,@Itemspec nvarchar(255))                          
as                          
Declare @ParamSep nVarchar(10)                        
Set @ParamSep = Char(2)                        
Declare @Itemspec1 nvarchar(50)                           
Declare @Itemspec2 nvarchar(50)                          
Declare @Itemspec3 nvarchar(50)                          
Declare @Itemspec4 nvarchar(50)                          
Declare @Itemspec5 nvarchar(50)                          
Declare @ItemInfo nvarchar(4000)        
Declare @Prefix nvarchar(15)                                
                          
select @Itemspec1 = servicecaption from servicesetting where servicecode = 'Itemspec1'                          
select @Itemspec2 = servicecaption from servicesetting where servicecode = 'Itemspec2'                          
select @Itemspec3 = servicecaption from servicesetting where servicecode = 'Itemspec3'                          
select @Itemspec4 = servicecaption from servicesetting where servicecode = 'Itemspec4'                          
select @Itemspec5=  servicecaption from servicesetting where servicecode = 'Itemspec5'                          
select @Prefix = Prefix from VoucherPrefix where TranID = 'JOBCARD'                        
            
Create table #ItemHistory_Temp([_EstimationID] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,[_Date of Sale] datetime null,[_JobCard Date] datetime null,[_Delivery Date] datetime null)            
            
set @Iteminfo ='Alter Table #ItemHistory_Temp Add
[_Item Code] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS ,
[_Item Name] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,                          
[' + @ItemSpec1 + '] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  null,
[' + @ItemSpec2 + '] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  null,                          
[' + @ItemSpec3 + '] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  null,
[' + @ItemSpec4 + '] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  null,                           
[' + @ItemSpec5 + '] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  null,                   
[_Color] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  null,                                              
[_JobCardID] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  null,                                    
[_Doc Ref] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  null,                  
[_Remarks] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  null,                  
[_Inspected By] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  null,                  
[_Time in] nvarchar(5) COLLATE SQL_Latin1_General_CP1_CI_AS  null,                  
[_Job Type] nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS  null,                  
[_Door Delivery] nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS  null,                                             
[_Delivery Time] nvarchar(5) COLLATE SQL_Latin1_General_CP1_CI_AS  null'                  
                  
Exec sp_executesql @Iteminfo                          
                          
Insert into #ItemHistory_Temp            
select 'EID' = cast(JobAbs.jobcardID as nvarchar(20)) + @paramsep + JobDet.product_code + @Paramsep +  JobDet.product_specification1,                           
IIT.DateofSale,JobAbs.JobCarddate,JobDet.Deliverydate,
JobDet.product_code,I.productname,                          
JobDet.product_specification1,                          
IIT.product_specification2,                          
IIT.product_specification3,                          
IIT.product_specification4,                          
IIT.product_specification5,                          
GM.[Description],                   
'Jobcard ID' = @Prefix + cast(JobAbs.DocumentID as nvarchar(15)),                                  
JobAbs.docRef,                  
JobAbs.Remarks,                  
PM.PersonnelName,              
'Timein' = isnull(dbo.sp_ser_StripTimeFromDate(JobDet.Timein),''),                        
(case Isnull(JobDet.jobtype,'') when 0 then 'Major' when 1 then 'Minor'else '' end) as 'JobType',                           
(case isnull(JobDet.DoorDelivery,'') when 1 then 'Yes' when 0 then 'No' else '' end) as 'Door Delivery',                                        
'Delivery Time' = isnull(dbo.sp_ser_StripTimeFromDate(JobDet.DeliveryTime),'')                        
from Jobcardabstract JobAbs
Inner Join JobcardDetail JobDet on JobAbs.JobcardId = JobDet.Jobcardid
Inner Join  Items I on JobDet.Product_code = I.Product_Code
Inner Join PersonnelMaster PM on JobDet.InspectedBy = PM.PersonnelId
Left Outer Join ItemInformation_Transactions IIT on IIT.DocumentId = JobDet.SerialNo and IIT.DocumentType = 2
Left Outer Join GeneralMaster GM on IIT.Color = GM.Code               
where (IsNull(JobAbs.Status, 0) & 32) <> 0 and 
JobDet.product_specification1 like @Itemspec      
and JobDet.type = 0             
and (JobAbs.jobcarddate) between @FromDate and @ToDate                            

Set @Iteminfo = 'Select [_EstimationID] as "EstimationID",
[_Item Code] as "Item Code",[_Item Name] as  "Item Name",
[' + @ItemSpec1 + '],[' + @ItemSpec2 + '],[' + @ItemSpec3 + '],
[' + @ItemSpec4 + '],[' + @ItemSpec5 + '], 
[_Color]  as "Color",
[_Date of Sale]  as "Date of Sale",
[_JobCardID]  as "JobCard ID",
[_JobCard Date]  as "JobCard Date",
[_Doc Ref] as "Doc Ref",
[_Remarks] as "Remarks",
[_Inspected By] as "Inspected By",
[_Time in] as "Time In",
[_Job Type] as "Job Type",
[_Door Delivery]  as "Door Delivery",
[_Delivery Date] as "Delivery Date",
[_Delivery Time] as "Delivery Time"  
from #ItemHistory_Temp'            

Exec Sp_executeSql @Iteminfo 

Drop Table #ItemHistory_Temp            

