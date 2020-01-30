CREATE procedure sp_ser_rpt_ItemwiseCancelEstimation(@ITEM nvarchar(255))              
AS              
Declare @ParamSep nVarchar(10)                  
Declare @EstimationID int                  
Declare @ItemCode nvarchar(255)              
Declare @Itemspec1 nvarchar(255)                
Declare @tempString nVarchar(510)              
Declare @ParamSepcounter int              
declare @Iteminfo as nvarchar(4000)            
declare @TaskAmount decimal(18,6)      
declare @SpareAmount decimal(18,6)      
            
              
Set @tempString = @Item              
Set @ParamSep = Char(2)                  
            
/* EstimationID */            
Set @ParamSepcounter = CHARINDEX(@ParamSep,@tempString,1)                  
set @EstimationID = substring(@tempString, 1, @ParamSepcounter-1)               
            
/*productCode*/            
              
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))               
Set @ParamSepcounter = CHARINDEX(@ParamSep, @tempString, 1)              
set @ItemCode = substring(@tempString, 1, @ParamSepcounter-1)               
            
/*Itemspecification */            
            
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))               
set @Itemspec1 = @tempString            
            
/* Task sum and Spare sum function call */          
            
Select  'Iteminfo' = cast(cast(EstimationID as nvarchar(10))+ @paramsep + '1' + @paramsep +           
@ItemCode +@paramsep + @Itemspec1  + @paramsep + EstimationDetail.JobId as nvarchar(4000)),          
(case Type when 1 then 'Job' when 2 then 'Task' when 3 then 'Spare' else '' end) as 'Type',          
--EstimationDetail.JobId 'Type',         
jobname 'Description',            
'Task Amount' = IsNull(dbo.sp_ser_rpt_getTaskAmount            
(EstimationID, @Itemspec1, Type,EstimationDetail.JobId, 1), 0),            
      
'Spare Amount' = IsNull(dbo.sp_ser_rpt_getTaskAmount            
(EstimationID, @Itemspec1, Type,EstimationDetail.JobId, 2), 0),             
      
'Total' = IsNUll(Sum(Netvalue),0), 'ColumnKey' = 1
      
from Estimationdetail             
Inner Join jobmaster On EstimationDetail.JobID = JobMaster.JobID            
where EstimationDetail.product_code = @Itemcode              
and EstimationDetail.EstimationID = @EstimationID              
and EstimationDetail.product_specification1 = @Itemspec1            
and EstimationDetail.JobId <> '' and Type = 1             
Group by EstimationID,Type,product_specification1, EstimationDetail.JobId, jobname             
Union             
Select  'Iteminfo' = cast(cast(EstimationID as nvarchar(10))+ @paramsep + '2' + @paramsep +           
@ItemCode +@paramsep + @Itemspec1  + @paramsep + EstimationDetail.Taskid as nvarchar(4000)),          
(case Type when 1 then 'Job' when 2 then 'Task' when 3 then 'Spare' else '' end) as 'Type',          
--EstimationDetail.Taskid 'Type',         
[description] 'Description',            
'Task Amount' = IsNull(dbo.sp_ser_rpt_getTaskSparesAmount                  
(EstimationID, @Itemspec1, Type,EstimationDetail.Taskid,1 ),0),      
'Spare Amount' = IsNull(dbo.sp_ser_rpt_getTaskSparesAmount                
(EstimationID, @Itemspec1, Type ,EstimationDetail.TaskId,2),0),     
'Total' = sum((NetValue) + IsNull(dbo.sp_ser_rpt_getTaskSparesAmount        
(EstimationID, @Itemspec1, Type,EstimationDetail.TaskId,2), 0)),
'ColumnKey' = 1
      
from Estimationdetail             
Inner Join taskmaster On EstimationDetail.TaskID = TaskMaster.TaskID            
where EstimationDetail.product_code = @Itemcode              
and EstimationDetail.EstimationID = @EstimationID              
and EstimationDetail.product_specification1 = @Itemspec1             
and IsNUll(JobId,'') = '' and IsNUll(SpareCode,'') = ''             
and IsNull(EstimationDetail.TaskId,'') <> '' and Type = 2 
Group by EstimationID, Type,product_specification1, EstimationDetail.TaskId,[description]            
Union             
Select  'Iteminfo' = cast(cast(EstimationID as nvarchar(10))+ @paramsep + '3' +@paramsep +           
@ItemCode +@paramsep + @Itemspec1  + @paramsep  +sparecode as nvarchar(4000)),        
(case Type when 1 then 'Job' when 2 then 'Task' when 3 then 'Spare' else '' end) as 'Type',          
--sparecode 'Type',          
productname 'Description',             
'Task Amount' = 0, 'Spare Amount' = IsNUll(Sum(Netvalue),0),             
'Total' = IsNUll(Sum(Netvalue),0), 1
from Estimationdetail             
inner join items on EstimationDetail.sparecode = Items.product_code               
where EstimationDetail.product_code = @Itemcode              
and EstimationDetail.EstimationID = @EstimationID              
and EstimationDetail.product_specification1 = @Itemspec1             
and IsNUll(JobId,'') = '' and IsNUll(SpareCode,'') <> '' and IsNull(TaskId,'') = ''         
and Type = 3             
Group by EstimationID,product_specification1,Type, Sparecode, productname            





