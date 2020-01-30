CREATE procedure [dbo].[sp_ser_loadtaskitems](@TaskID nvarchar(50))  
as  
Select 'TaskID' = TaskMaster.TaskID,'Description' = TaskMaster.[Description],  
'Active' = IsNull(TaskMaster.Active,0),'Product Code' = Task_Items.Product_Code,  
'ProductName' = dbo.sp_ser_getitemname(Product_Code),Rate,TaskDuration,  
ServiceTax,'Tax_Description' = dbo.sp_ser_gettax(IsNull(ServiceTax,0)),  
'WarrantyDays' = WarrantyDays  
from TaskMaster,Task_Items Where TaskMaster.TaskID = @TaskID   
and TaskMaster.TaskID *= Task_Items.TaskID
