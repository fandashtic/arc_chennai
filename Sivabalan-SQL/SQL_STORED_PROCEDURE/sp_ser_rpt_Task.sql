CREATE procedure [dbo].[sp_ser_rpt_Task]    
AS    
Select TaskID,'TaskID' = TaskID,'Description' = TaskMaster.[Description],    
'Warranty Days' = IsNull(WarrantyDays,0),    
'Service Tax' = isnull(ServiceTaxmaster.[Description],''),      
(case TaskMaster.Active when 1 then 'Active' when 0 then 'Inactive'     
else '' end) as 'Active'     
from TaskMaster,servicetaxmaster    
where TaskMaster.servicetax *= servicetaxmaster.ServiceTaxCode
