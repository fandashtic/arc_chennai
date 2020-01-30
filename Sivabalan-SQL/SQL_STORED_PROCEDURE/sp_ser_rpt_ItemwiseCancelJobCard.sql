CREATE procedure sp_ser_rpt_ItemwiseCancelJobCard(@ITEM nvarchar(255))            
AS            
Declare @ParamSep nVarchar(10)                
Declare @JobcardID int                
Declare @ItemCode nvarchar(255)            
Declare @Itemspec1 nvarchar(255)              
Declare @tempString nVarchar(510)            
Declare @ParamSepcounter int            
declare @Iteminfo as nvarchar(4000)          
                      
Set @tempString = @Item            
Set @ParamSep = Char(2)                
          
/* jobcardID */          
Set @ParamSepcounter = CHARINDEX(@ParamSep,@tempString,1)                
set @JobcardID = substring(@tempString, 1, @ParamSepcounter-1)             
          
/*productCode*/          
            
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))             
Set @ParamSepcounter = CHARINDEX(@ParamSep, @tempString, 1)            
set @ItemCode = substring(@tempString, 1, @ParamSepcounter-1)             
          
/*Itemspecification */          
          
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))             
set @Itemspec1 = @tempString          
          
/* Task sum and Spare sum function call */        
          
Select  'Iteminfo' = cast(cast(JobCardID as nvarchar(10))+ @paramsep + '1' + @paramsep +         
@ItemCode +@paramsep + @Itemspec1  + @paramsep + JobcardDetail.JobId as nvarchar(4000)),        
(case Type when 1 then 'Job' when 2 then 'Task' when 3 then 'Spare' else '' end) as 'Type',      
--JobcardDetail.JobId 'Type',    
 jobname 'Description', 'ColumnKey' = 1          
from Jobcarddetail           
Inner Join jobmaster On JobcardDetail.JobID = JobMaster.JobID          
where JobcardDetail.product_code = @Itemcode            
and JobcardDetail.JobcardID = @JobcardID            
and jobcardDetail.product_specification1 = @Itemspec1          
and Isnull(jobcardDetail.JobId,'') <> '' and Type = 1           
Group by JobcardID,Type,product_specification1, jobcardDetail.JobId, jobname           
Union           
Select  'Iteminfo' = cast(cast(JobCardID as nvarchar(10))+ @paramsep + '2' + @paramsep +         
@ItemCode +@paramsep + @Itemspec1  + @paramsep + JobcardDetail.Taskid as nvarchar(4000)),        
(case Type when 1 then 'Job' when 2 then 'Task' when 3 then 'Spare' else '' end) as 'Type',      
--JobcardDetail.Taskid 'Type',    
[description] 'Description', 1
from Jobcarddetail      
Inner Join taskmaster On jobcardDetail.TaskID = TaskMaster.TaskID          
where jobcardDetail.product_code = @Itemcode            
and jobcardDetail.jobcardID = @jobcardID            
and jobcardDetail.product_specification1 = @Itemspec1           
and IsNUll(JobId,'') = '' and IsNUll(SpareCode,'') = ''           
and IsNull(jobcardDetail.TaskId,'') <> '' and Type = 2           
Group by jobcardID, Type,product_specification1, jobcardDetail.TaskId,[description]          
Union           
Select  'Iteminfo' = cast(cast(jobcardID as nvarchar(10))+ @paramsep + '3' +@paramsep +         
@ItemCode +@paramsep + @Itemspec1  + @paramsep  +sparecode as nvarchar(4000)),    
(case Type when 1 then 'Job' when 2 then 'Task' when 3 then 'Spare' else '' end) as 'Type',      
--sparecode 'Type',        
productname 'Description', 1
from jobcarddetail           
inner join items on jobcardDetail.sparecode = Items.product_code             
where jobcardDetail.product_code = @Itemcode            
and jobcardDetail.jobcardID = @jobcardID            
and jobcardDetail.product_specification1 = @Itemspec1           
and IsNUll(JobId,'') = '' and IsNUll(SpareCode,'') <> '' and IsNull(TaskId,'') = ''           
and Type = 3           
Group by jobcardID,product_specification1,Type, Sparecode, productname          


