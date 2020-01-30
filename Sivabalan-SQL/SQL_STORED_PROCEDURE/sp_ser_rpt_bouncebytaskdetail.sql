CREATE procedure sp_ser_rpt_bouncebytaskdetail 
(@TaskID varchar(15), @FromDate datetime, @ToDate datetime)
as
Declare @vFromDate as nvarchar(60)
Declare @vToDate as nvarchar(60)

Set @vFromDate = Cast(@FromDate as varchar(60))
Set @vToDate = Cast(@ToDate as varchar(60))

Declare @JCPrefix as varchar(15)
Select @JCPrefix = Prefix From VoucherPrefix Where TranID = 'JOBCARD'

Declare @ItemSpec1 as nvarchar(50)
Select @ItemSpec1 = servicecaption From ServiceSetting Where servicecode = 'Itemspec1'  

Exec (
'Select 0, i.Product_Code [Item Code], i.ProductName [Item Name], 
d.Product_Specification1 [' + @ItemSpec1 + '],
''' + @JCPrefix  + ''' + Cast(j.DocumentID as varchar(15)) [JobCardID], 
j.JobCardDate [JobCard Date], p.PersonnelName [Personnel Name],  
IsNull( ''' + @JCPrefix + ''' + Cast(b.DocumentID as varchar(15)),'''') [JobCardID Bounce], 
b.JobCardDate [Jobcard Date Bounce], IsNull(b.PersonnelName,'''') [Personnel Bounce],
IsNull(d.BounceCase_Reason,'''') [BounceCase Reason]
From JobCardAbstract j 
Inner Join JobCardTaskAllocation jt On j.JobCardID = jt.JobCardID 
And jt.Type = 2 
And IsNull(jt.TaskStatus, 0) = 2  
And (IsNull(jt.TaskType,0) = 1) 
Inner Join JobcardDetail d On d.JobCardID = j.JobCardID 
And d.Type = 2 
And IsNull(d.SpareCode, '''') = ''''  
And (IsNull(d.TaskType,0) = 1) 
And jt.Product_Code = d.Product_Code 
And jt.Product_Specification1 = d.Product_Specification1 
And IsNull(d.TaskId,'''') like ''' +  @TaskID + ''' 
And jt.TaskID = IsNull(d.TaskId,'''')
Inner Join PersonnelMaster p On p.PersonnelID = jt.PersonnelID 
Inner Join Items i On i.Product_Code = d.Product_Code 
Left Join 
(Select jb.JobCardID, jb.JobCardDate, jb.DocumentID, jtb.Product_Specification1, 
pb.PersonnelName, jtb.Product_Code, jtb.TaskID 
From JobcardAbstract jb Inner Join JobCardTaskAllocation jtb On jb.JobCardID = jtb.JobCardID 
And jtb.Type = 2 
And IsNull(jtb.TaskStatus, 0) = 2 
And IsNull(jtb.TaskId,'''') like ''' +  @TaskID + '''
Inner Join PersonnelMaster pb On pb.PersonnelID = jtb.PersonnelID  ) b
On b.JobCardID = d.JobCardID_Bounced 
And b.Product_Code = d.Product_Code 
And b.Product_Specification1 = d.Product_Specification1 
And b.TaskID = IsNull(d.TaskID, '''')
Where (IsNull(j.Status, 0) & 192 <> 192) 
And (j.JobcardDate between ''' + @vFromDate + ''' And ''' + @vToDate + ''') 
Order by jt.SerialNo' 
)

