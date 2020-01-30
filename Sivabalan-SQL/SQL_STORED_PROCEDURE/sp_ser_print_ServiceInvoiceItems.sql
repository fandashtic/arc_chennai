CREATE PROCEDURE sp_ser_print_ServiceInvoiceItems(@InvoiceId INT)      
AS      
Select "Item Code" = Items.Product_Code, "Item name" = Items.ProductName, 
"Item Spec1" = IsNull(JDetail.Product_Specification1, ''), 
"Item Spec2" = IsNull(IInfo.Product_Specification2, ''), 
"Item Spec3" = IsNull(IInfo.Product_Specification3, ''), 
"Item Spec4" = IsNull(IInfo.Product_Specification4, ''), 
"Item Spec5" = IsNull(IInfo.Product_Specification5, ''), 
"Colour" = IsNull(G.[Description], ''),
"Open Time" = JDetail.TimeIn, 
"Close Time" = SAbstract.CreationTime, 
"DOCRef" = IsNull(SAbstract.DocReference, ''), 
"DateofSale" = JDetail.DateofSale, 
"DoorDelivery" = (Case isnull(JDetail.DoorDelivery, 0) when 1 then 'Yes' else 'No' End)
from ServiceinvoiceAbstract SAbstract  
Inner Join ServiceInvoiceDetail SDetail On SDetail.ServiceInvoiceID = SAbstract.ServiceInvoiceID
	and SDetail.Type = 0
Inner Join JobCardDetail JDetail On JDetail.JobCardID = SAbstract.JobCardID 
	and SDetail.Product_Code = JDetail.Product_Code 
	and SDetail.Product_Specification1 = JDetail.Product_Specification1
	and JDetail.Type = 0
Left Outer Join ItemInformation_Transactions IInfo On 
	IInfo.DocumentID = JDetail.SerialNo and IInfo.DocumentType = 2
Inner Join Items On SDetail.Product_Code = Items.Product_Code
Left Join GeneralMaster G On G.Code = IInfo.Color and IsNull(G.Type,0) = 1 
Where SAbstract.ServiceInvoiceID = @InvoiceId
Order by SDetail.SerialNo




