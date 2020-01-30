CREATE procedure [dbo].[sp_ser_rpt_ItemHistorySparesTaskList](@Item nvarchar(255))                                  
as                                  
                                  
Declare @ParamSep nVarchar(10)                                      
Declare @EID int                                  
Declare @jobcardID int                                      
Declare @ItemCode nvarchar(255)                                  
Declare @Productcode int                                  
Declare @Itemspec1 nvarchar(255)                                    
Declare @Type nvarchar(50)                                      
Declare @JobID nvarchar(255)                                    
Declare @serviceid nvarchar(255)                                  
Declare @tempString nVarchar(510)                                  
Declare @ParamSepcounter int                                  
Declare @TID nvarchar(4000)                                  
Set @tempString = @Item                                  
Set @ParamSep = Char(2)                                      
                                  
Set @ParamSepcounter = CHARINDEX(@ParamSep,@tempString,1)                                      
set @jobcardID = substring(@tempString, 1, @ParamSepcounter-1)                                   
                                
                                  
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))                                   
Set @ParamSepcounter = CHARINDEX(@ParamSep, @tempString, 1)                                  
set @ItemCode = substring(@tempString, 1, @ParamSepcounter-1)                                   
                                  
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))                                   
Set @ParamSepcounter = CHARINDEX(@ParamSep, @tempString, 1)                                  
set @Itemspec1 = substring(@tempString, 1, @ParamSepcounter-1)                                   
                                
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))                                   
set @Type =  @tempString                                  
                             
                        
if  @Type = '1'                                  
begin                                  
	select 'TaskID' = jobcardtaskallocation.Taskid,'TaskID'= jobcardtaskallocation.Taskid,                        
	'Description' = Taskmaster.[Description],                
	'Personnel Name' = Isnull(personnelname,''),                                    	    
	(case
	when Isnull(TaskStatus,0) = 2 then 'Closed'                                    
	when Isnull(TaskStatus,0) = 5 and Isnull(jobcardtaskallocation.PersonnelID,'') <> '' and isnull(RefSerialNo,0) = 0 then 'Rework'          
	when Isnull(TaskStatus,0) = 5 and Isnull(jobcardtaskallocation.PersonnelID,'') <> '' and isnull(RefSerialNo,0) > 0 then 'ReworkClosed'                                     
	when Isnull(TaskStatus,0) = 1 and Isnull(jobcardtaskallocation.PersonnelID,'') <> '' and isnull(RefSerialNo,0) > 0 then 'Assigned'                                     
	when Isnull(TaskStatus,0) = 4 and Isnull(jobcardtaskallocation.PersonnelID,'') <> '' and isnull(RefSerialNo,0) = 0 then 'ReAssigned'                                     
	when Isnull(TaskStatus,0) = 4 and Isnull(jobcardtaskallocation.PersonnelID,'') <> '' and isnull(RefSerialNo,0) > 0 then 'ReAssigned'                                     
	when Isnull(TaskStatus,0) = 1 then 'Assigned'                                   
	when Isnull(TaskStatus,0) = 0 and isnull(jobcardtaskallocation.PersonnelID,'') =  '' and isnull(RefSerialNo,0) > 0  then 'Open'                                     
	when Isnull(TaskStatus,0) = 0 then  'Open'                                   
	else '' end) as 'Status',        
	'Remarks' = Isnull(Remarks,''), 'ColumnKey' = 2
	from jobcardtaskallocation, Taskmaster, personnelmaster                                   
	where  jobcardtaskallocation.Taskid = Taskmaster.Taskid                                  
	and jobcardtaskallocation.product_Code = @Itemcode                                  
	and jobcardtaskallocation.personnelID *= personnelmaster.personnelid                        
	and jobcardtaskallocation.jobcardid = @jobcardID                                  
	and Product_specification1 = @Itemspec1                                  
	and Isnull(TaskStatus,0) not in (3)
	order by Taskid                               
End                       
        
if  @Type = '2'                                  
Begin                                  
	select Issueabstract.IssueID,'IssueID' = Issueabstract.IssueID,                 
	'Issue Date' = Issueabstract.Issuedate,                
	'Spare Code' = Issuedetail.SpareCode,                
	'Spare Name ' = productname,                                  
	'Batch' = Isnull(Batch_Number,''),                
	'UOM'= UOM.[Description],                                 
	'Issued Qty' = Isnull(IssuedQty,0),                
	'Returned Qty' = Isnull(ReturnedQty,0),                        
	'Net Qty' = (ISnull(IssuedQty,0) - Isnull(ReturnedQty,0)), 'ColumnKey' = 3
	from Issueabstract,Issuedetail,items,UOM                
	where (IsNull(issueabstract.Status,0) & 192) = 0
	and Issueabstract.jobcardid = @Jobcardid                
	and Issuedetail.product_Code = @Itemcode                        
	and Issuedetail.Product_specification1 = @ItemSpec1                
	and Issuedetail.spareCode = items.product_Code                
	and Issueabstract.issueid = Issuedetail.issueid
	and Issuedetail.UOM = UOM.UOM                                
End
