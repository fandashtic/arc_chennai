CREATE procedure sp_ser_loadinvoiceitemdetails(@InvoiceID int)
as 
Select 
ServiceInvoiceDetail.SerialNo, ServiceInvoiceDetail.Product_Code, 
ProductName,
'Product_Specification1' = ServiceInvoiceDetail.Product_Specification1, 
'Color' = IsNUll(GeneralMaster.[Description],''),  
'Product_Specification2' = Isnull(i.Product_Specification2, ''), 
'Product_Specification3' = Isnull(i.Product_Specification3, ''),  
'Product_Specification4' = Isnull(i.Product_Specification4, ''),  
'Product_Specification5' = Isnull(i.Product_Specification5, '') 
from ServiceInvoiceDetail 
Inner Join Items On ServiceInvoiceDetail.Product_Code = Items.Product_Code
Left outer Join ItemInformation_Transactions i on i.DocumentID = ServiceInvoiceDetail.SerialNo and i.DocumentType = 3  
Left Outer Join GeneralMaster On i.Color = GeneralMaster.Code 
Where ServiceInvoiceId = @InvoiceID and 
IsNull(ServiceInvoiceDetail.TaskId,'') = '' and 
IsNull(ServiceInvoiceDetail.SpareCode,'') = '' and ServiceInvoiceDetail.Type = 0
Order by ServiceInvoiceDetail.SerialNo 


-- Inner Join Item_Information On 
-- 	--ServiceInvoiceDetail.Product_Code = Item_Information.Product_Code and 
-- 	ServiceInvoiceDetail.Product_Specification1 = Item_Information.Product_Specification1 

