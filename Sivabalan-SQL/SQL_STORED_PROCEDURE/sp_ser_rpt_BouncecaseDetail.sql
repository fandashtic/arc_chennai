CREATE Procedure sp_ser_rpt_BouncecaseDetail
(@PersonnelID nvarchar(50),@Fromdate datetime,@ToDate datetime)
as                                
Declare @ParamSep nVarchar(10)                              
Set @ParamSep = Char(2)                              
Declare @Iteminfo nvarchar(4000)       
Declare @ItemSpec1 nvarchar(50)                                 
Declare @Prefix nvarchar(15)                                      
Declare @Iteminfo1 nvarchar(4000)       

Select  @ItemSpec1 = servicecaption From serviceSetting Where servicecode = 'Itemspec1'                              
Select @Prefix = Prefix From VoucherPrefix Where TranID = 'JOBCARD'                            

Create table #BounceCase_Temp([_Item Code] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,[_JobCard Date] datetime null,[_JobCard Date Bounce] datetime null)                

Set @Iteminfo ='Alter Table #BounceCase_Temp Add 
[_Item Name] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,  
[' + @ItemSpec1 + '] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,  
[_Description] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,                      
[_JobCard ID] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,                      
[_JobCard ID Bounce] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,                   
[_BounceCase Reason] nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS null'
    
Exec sp_executesql @Iteminfo                              

Insert into #BounceCase_Temp                        
Select  jd.Product_Code, j.JobCardDate 'JobCard Date',
jb.JobCardDate 'Jobcard Date Bounce',
i.ProductName, jd.Product_Specification1, 
t.Description 'Task Name',  
IsNull(@Prefix + Cast(j.DocumentID as varchar(15)),'') 'JobCardId',
IsNull(@Prefix + Cast(jb.DocumentID as varchar(15)),'') 'JobCardId Bounce',
IsNull(jd.BounceReason,'') 'BounceCase Reason'
From JobCardAbstract j 
Inner Join JobCardTaskAllocation jt On j.JobCardId = jt.JobCardId 
And jt.Type = 2 
And IsNull(jt.TaskStatus, 0) = 2  
And (IsNull(jt.TaskType,0) = 1) 
Inner Join 
(Select d.SerialNo, d.JobCardId, d.Product_Code, d.Product_Specification1, 
IsNull(d.TaskId,'') TaskID, IsNull(d.JobCardId_Bounced, 0) BounceJCID,
IsNull(d.BounceCase_Reason,'') BounceReason
From JobCardDetail d 
Where d.Type = 2 
And IsNull(d.SpareCode, '') = '' 
And (IsNull(d.TaskType,0) = 1)) jd On j.JobCardId = jd.JobCardId 
And jt.Product_Code = jd.Product_Code 
And jt.Product_Specification1 = jd.Product_Specification1 
And jt.TaskID = jd.TaskID
Inner Join 
(Select jtb.JobCardId, jtb.Product_Specification1, 
jtb.PersonnelID, jtb.Product_Code, jtb.TaskID 
From JobCardTaskAllocation jtb 
Where jtb.Type = 2 
And IsNull(jtb.TaskStatus, 0) = 2 
And jtb.PersonnelID like @PersonnelID) b On b.JobCardId = jd.BounceJCID 
And b.Product_Code = jd.Product_Code 
And b.Product_Specification1 = jd.Product_Specification1 
And b.TaskID = jd.TaskID
Inner Join Items i On jd.Product_Code = i.Product_Code 
Inner Join TaskMaster t On t.TaskID = jd.TaskID 
Inner Join JobCardAbstract jb On jb.JobCardId = b.JobCardId 
Where (IsNull(j.Status, 0) & 192 <> 192) 
And (j.JobCardDate between  @FromDate And @ToDate) 
Order by jd.SerialNo

Set  @Iteminfo1 = 'Select  [_Item Code] as "Item Code",
[_Item Name] as "Item Name",
[' + @ItemSpec1 + '],
[_Description] as "Description",
[_JobCard ID] as "JobCard ID",
[_JobCard Date] as "JobCard Date",
[_JobCard ID Bounce] as "JobCard ID Bounce",
[_JobCard Date Bounce] as "JobCard Date Bounce",
[_BounceCase Reason] as "BounceCase Reason"
From #BounceCase_Temp'

exec sp_executesql @Iteminfo1

Drop Table #BounceCase_Temp   

