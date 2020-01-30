
CREATE procedure sp_ser_rpt_Issuedetail(@IssueID int)                          
as                          
Declare @ParamSep nVarchar(10)                        
Set @ParamSep = Char(2)                        
Declare @Itemspec1 nvarchar(50)                           
Declare @ItemInfo nvarchar(4000)                         
Declare @Iteminfo1 nvarchar(4000)
                          
select @Itemspec1 = servicecaption from servicesetting where servicecode = 'Itemspec1'                        

Create table #Issuedetail_Temp([_IssueID] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
                         
set @Iteminfo =  'Alter table #Issuedetail_Temp Add [_Item Code] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,                  
[_Item Name] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,                          
[' + @Itemspec1 + '] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,              
[_Color] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS null,                    
[_Inspected By] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS null,                  
[_Job Type] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,                  
[_Time in] nvarchar(5) COLLATE SQL_Latin1_General_CP1_CI_AS null'                  
            
Exec sp_executesql @Iteminfo                    
Insert into #Issuedetail_Temp
    
select 'EID' = cast(IA.IssueID as nvarchar(20)) + @paramsep +         
JobDet.product_code + @Paramsep + JobDet.product_specification1,                           
JobDet.product_code,I.productname,                          
JobDet.product_specification1,                          
GM.[Description],                  
PM.PersonnelName,                  
(case Isnull(JobDet.jobtype,'') when 0 then 'Major' when 1 then 'Minor'else '' end)        
 as 'JobType',                       
'Timein' = isnull(dbo.sp_ser_StripTimeFromDate(JobDet.Timein),'')          
from 
jobcardabstract JobAbs
Inner join jobcarddetail JobDet on JobAbs.jobcardid = JobDet.jobcardid
Inner join IssueAbstract IA on IA.JobcardId = JobAbs.jobcardid 
Inner Join Personnelmaster PM on JobDet.InspectedBy = PM.PersonnelID               
Inner Join Items I on JobDet.product_code = I.product_code    
Left outer join Iteminformation_Transactions IIT on IIT.documentid = jobdet.serialno and  IIT.DocumentType = 2          
Left Outer Join Generalmaster GM on IIT.Color = GM.Code
where  IA.IssueID = @Issueid          
and     
(select Count(*) from issuedetail IssDet,     
IssueAbstract IssAbs where IssDet.IssueId = IssAbs.IssueId and    
IssDet.product_specification1 = JobDet.product_specification1 and IssAbs.JobCardId = JobCardId) > 0     

Set @Iteminfo1 = 'select [_IssueID] as IssueID,
[_Item Code] as "Item Code",
[_Item Name] as "Item Name",
[' + @Itemspec1 + '],
[_Color] as "Color",
[_Inspected By] as "Inspected By",
[_Job Type] as "Job Type",
[_Time in] as "Time In" from #Issuedetail_Temp'

Exec sp_executesql @Iteminfo1

Drop Table #Issuedetail_Temp

