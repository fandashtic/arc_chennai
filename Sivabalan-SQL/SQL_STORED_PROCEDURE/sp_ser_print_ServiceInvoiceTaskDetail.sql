CREATE PROCEDURE sp_ser_print_ServiceInvoiceTaskDetail(@InvoiceId INT)      
AS   
Declare @AddDiscount decimal(18, 6)
Declare @TrdDiscount decimal(18, 6)
Select 
	@AddDiscount = IsNull(AdditionalDiscountPercentage, 0),
	@TrdDiscount = IsNull(TradeDiscountPercentage, 0) 
from ServiceInvoiceAbstract Where ServiceInvoiceID = @InvoiceId

Select "Item Code" = Items.Product_Code, "Item name" = Items.ProductName, 
"Item Spec1" = IsNull(SDetail.Product_Specification1, ''), 
"Item Spec2" = IsNull(IInfo.Product_Specification2, ''), 
"Item Spec3" = IsNull(IInfo.Product_Specification3, ''), 
"Item Spec4" = IsNull(IInfo.Product_Specification4, ''), 
"Item Spec5" = IsNull(IInfo.Product_Specification5, ''), 
"JobName" = isnull(JobMaster.JobName, ''),
"Task Description" = TaskMaster.[Description],
"Task Type" = (case Isnull(SDetail.TaskType, 0) when 1 then 'Bounce Case' else 'New' end),
"Job Type" = (case IsNull(SDetail.JobFree, 0) when 1 then 'Free Job' else 'Paid Job' end), 
"Tax%" = IsNull(SDetail.ServiceTax_Percentage, 0),
"Tax Value" = IsNull(SDetail.ServiceTax, 0),
"Rate" = IsNull(SDetail.Price, 0),
"Amount" = IsNull(SDetail.Amount, 0),
"AdditionalDiscount%" = IsNull(@AddDiscount, 0),
"AdditionalDiscountValue" = (IsNull(SDetail.Price, 0) * IsNull(@AddDiscount, 0)) / 100,
"TradeDiscount%" = IsNull(@TrdDiscount, 0),
"TradeDiscountValue" = (IsNull(SDetail.Price, 0) * IsNull(@TrdDiscount, 0)) / 100,
"Net Value" = Netvalue
from ServiceInvoiceDetail SDetail 
Left Outer Join (Select si.ServiceInvoiceID, si.Product_Code, si.Product_Specification1, 
	i.Product_Specification2, i.Product_Specification3, 
	i.Product_Specification4, i.Product_Specification5, i.Color 
	from ServiceInvoiceDetail si 
	Left Outer Join ItemInformation_Transactions i On 
		i.DocumentID = si.SerialNo and i.DocumentType = 3
	where si.ServiceInvoiceID = @InvoiceId and si.Type = 0) IInfo 
On IInfo.ServiceInvoiceID = SDetail.ServiceInvoiceID and IInfo.Product_Code = SDetail.Product_Code 
	and IInfo.Product_Specification1 = SDetail.Product_Specification1

Inner Join Items On SDetail.Product_Code = Items.Product_Code
left Join JobMaster On JobMaster.JobID = SDetail.JobID 
Inner Join TaskMaster On TaskMaster.TaskID = SDetail.TaskID		
Where SDetail.ServiceInvoiceID = @InvoiceId
	and SDetail.Type in (1,2) 
	and IsNull(SDetail.SpareCode, '') = ''
	and IsNull(SDetail.TaskID, '') <> ''
Order by SDetail.SerialNo







