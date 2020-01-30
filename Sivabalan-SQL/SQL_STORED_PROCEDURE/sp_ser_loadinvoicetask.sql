CREATE Procedure sp_ser_loadinvoicetask
(@InvoiceID as int, @Product_Code as nvarchar(15), @Product_Specification1 as nvarchar(50))
as 

Select  TaskMaster.TaskID, 
	TaskMaster.Description, 
	EstimatedPrice, 
	Price, 
	IsNull(ServiceInvoiceDetail.ServiceTax_Percentage,0) Percentage, 
	IsNull(ServiceInvoiceDetail.ServiceTax,0) TaxCode, Isnull(TaskType, 0) TaskType, 
	IsNull(JobFree,'') JobFree, IsNUll(JobMaster.JobName, '') 'JobName' 
from ServiceInvoiceDetail 
Inner Join TaskMaster On TaskMaster.TaskID = ServiceInvoiceDetail.TaskID 
Inner Join Task_Items On TaskMaster.TaskID = Task_Items.TaskID and 
	ServiceInvoiceDetail.Product_Code = Task_Items.Product_Code
Left Join JobMaster On JobMaster.JobID = ServiceInvoiceDetail.JobID  
where  ServiceInvoiceDetail.ServiceInvoiceID = @InvoiceID and IsNull(SpareCode, '') = '' and 
ServiceInvoiceDetail.Type = 2 and IsNull(ServiceInvoiceDetail.TaskID,'') <> '' and 
ServiceInvoiceDetail.Product_Code = @Product_Code and Product_Specification1 = @Product_Specification1 
Order by SerialNo


