CREATE Procedure sp_Ser_LoadItemDetail(@TaskID nvarchar(50),@Productcode nvarchar(50))      
as      
      
select Task_Items_Spares.sparecode,'SparesName' =dbo.sp_ser_getSparesName(Task_Items_Spares.sparecode) ,      
Task_Items_Spares.uom,Task_Items_Spares.uomqty,Task_Items_Spares.qty, UOM.Description 
from task_items_spares, UOM  
where task_items_spares.taskid = @TaskID and Task_items_spares.product_code = @ProductCode
and UOM.UOM = Task_Items_Spares.uom

