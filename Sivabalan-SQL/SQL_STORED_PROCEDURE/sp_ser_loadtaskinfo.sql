CREATE procedure sp_ser_loadtaskinfo
(@TaskID nvarchar(50),@ProductCode nvarchar(15))
as

Select Rate, 'ServiceTaxPercentage' = IsNull(dbo.sp_ser_gettaxpercenatge(1,Servicetax,1),0), 
ServiceTax from TaskMaster 
Inner Join Task_Items On TaskMaster.TaskID = Task_Items.TaskID 
where TaskMaster.TaskID = @TaskID and Product_Code = @ProductCode


