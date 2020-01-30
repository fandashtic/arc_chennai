CREATE Procedure sp_ser_rpt_TaskItem(@TaskID nvarchar(50))
AS 
Declare @ParamSep nVarchar(10)
Set @ParamSep = Char(2)
select 'Item' = task_items.TaskID + @ParamSep + task_items.Product_Code,
'Item Code' = task_items.Product_Code ,'Item Name' = Items.ProductName,
'Rate' = Rate,
'Task Duration' = TaskDuration
from task_items,Items
where task_items.TaskID = @TaskID  
and task_items.Product_code = Items.Product_code

