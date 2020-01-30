CREATE Procedure sp_ser_rpt_ItemHistorydetail(@ITEM nvarchar(255))                                  
AS                                  
Declare @Product_code nvarchar(50)                    
Declare @Product_specification1 nvarchar(50)                    
Declare @sparecode nvarchar(50)                    
Declare @ParamSep nVarchar(10)                                      
Declare @JobcardID int                                      
Declare @ItemCode nvarchar(255)                                  
Declare @Itemspec1 nvarchar(255)                                    
Declare @tempString nVarchar(510)                                  
Declare @ParamSepcounter int                                  
declare @Iteminfo as nvarchar(4000)                                
declare @S as nvarchar(50)                      
declare @T as nvarchar(50)                         
declare @SparesStatus as nvarchar(50)                      
declare @prestatus as nvarchar(50)                         
declare @TaskStatus as nvarchar(50)                    
Declare @PrevState As Integer          
Declare @SparesPrevState As Integer                                  
declare @Count Integer      
declare @TaskCount Integer      
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
set @Count = 0                    
    
Declare C1Status CURSOR for 
Select JS.jobcardid, JS.product_code, JS.product_specification1,                        
	(case 
	when Isnull(JS.pendingqty,0) = 0 then 'Issued'                       
	when Isnull(JS.pendingqty,0) > 0 then 'Pending'               
	else '' end) as 'SparesStatus'                    
from Jobcardspares JS where JS.jobcardid = @jobcardid                    
and JS.product_code = @Itemcode                    
and JS.product_specification1 = @Itemspec1                    
and Isnull(JS.sparestatus,0) <> 2  

set @SparesPrevState = 0          
          
open C1Status                    
Fetch from C1Status into @jobcardid,@product_code,@product_specification1, @SparesStatus                     
while @@Fetch_status = 0                        
Begin      
 Set @Count = @Count + 1          
 if @SparesStatus = 'Pending' or @SparesStatus = 'Pending'                    
 Begin          
  set @S = 'Pending'          
  set @SparesPrevState = 1          
 End          
 Else if @SparesStatus = 'Issued' and @SparesPrevState = 0          
  set @S = 'Issued'          
 Else          
  set @S = 'Pending'     
                  
 Fetch from C1Status into @jobcardid,@product_code,@product_specification1, @SparesStatus         
End                    
Close C1Status                        
Deallocate C1Status                     
set @TaskCount = 0       
Declare C2Status CURSOR for 
Select JT.Jobcardid, JT.product_code, JT.product_specification1,                    
(case                   
	when Isnull(JT.TaskStatus,0) = 0 then 'Open'                     
	when Isnull(JT.TaskStatus,0) = 1 then 'Assigned'     
	when Isnull(JT.TaskStatus,0) = 2 then 'Closed'                      
	when Isnull(JT.TaskStatus,0) = 5 and ISnull(JT.PersonnelID,'') <> '' and 
		isnull(JT.RefSerialNo,0) > 0 then 'ReworkAssigned'            
	else '' end) as 'Status'                                  
from Jobcardtaskallocation JT where JT.jobcardid = @JobcardID                 
and JT.product_code = @ItemCode          
and JT.product_specification1 = @ItemSpec1          
and Isnull(JT.TaskStatus,0) not in (3, 5)
          
set @PrevState = 0           
open C2Status                    
    
Fetch from C2Status into @jobcardid,@product_code,@product_specification1, @TaskStatus                    
while @@Fetch_status = 0                        
Begin                    
	set @TaskCount = @TaskCount + 1          
	if @TaskStatus = 'Open' or @TaskStatus = 'Assigned'           
	Begin          
		set @T = 'Pending'          
Set @PrevState = 1          
End          
Else if @TaskStatus = 'Closed' and  @PrevState = 0                 
set @T = 'Closed'          
Else          
set @T = 'Pending'          
                 
Fetch from C2Status into @jobcardid,@product_code,@product_specification1, @TaskStatus                    
End                    
Close C2Status                        
Deallocate C2Status                     
    
Create table #ItemHistoryTemp ([ID] nvarchar(255), Type nvarchar(10), Status nvarchar(50))                    
insert into #ItemHistoryTemp                     
select 'ID' = cast(@jobcardID as nvarchar(10)) + @paramsep + @product_code + @Paramsep +                     
@product_specification1 +@Paramsep + '2' , 'Spare',@S                       
insert into #ItemHistoryTemp                       
select 'ID' = cast(@jobcardID as nvarchar(10)) + @paramsep + @product_code + @Paramsep +                     
@product_specification1 + @paramsep + '1', 'Task',@T                         
      
If @Count = 0      
Begin      
 Update #ItemHistoryTemp Set Status = 'No Spares is Selected in this JobCard '      
 Where Type = 'Spare'      
End      
if @TaskCount  = 0      
Begin      
 Update #ItemHistoryTemp Set Status = 'No Task is Selected in this JobCard'      
 Where Type = 'Task'      
End
select * from #ItemHistoryTemp   
drop table #ItemHistoryTemp    




