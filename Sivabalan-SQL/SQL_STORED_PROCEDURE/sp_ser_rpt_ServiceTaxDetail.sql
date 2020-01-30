CREATE Procedure sp_ser_rpt_ServiceTaxDetail(@ServiceInvoiceID int)
As

Select serviceinvoicedetail.TaskID,
'Task ID' = serviceinvoicedetail.TaskID,
'Task Description' = [Description],
'ServiceTax(%)' = servicetax_percentage,
'ServiceTax Amount'=                     
case when Isnull(serviceinvoicedetail.Taskid,'')  <> '' and Isnull(sparecode,'') = '' then 
Cast(ServiceInvoiceDetail.ServiceTax as Decimal(18,6)) else 0 end                         
from ServiceinvoiceDetail,TaskMaster
where serviceinvoicedetail.serviceinvoiceid = @Serviceinvoiceid
and serviceinvoicedetail.TaskId = TaskMaster.TaskID
and Isnull(serviceinvoicedetail.Taskid,'')  <> '' and Isnull(sparecode,'') = ''
group by serviceinvoicedetail.TaskID,TaskMaster.[Description],
ServiceinvoiceDetail.ServiceTax_Percentage,
ServiceinvoiceDetail.ServiceTax,serviceinvoicedetail.sparecode





