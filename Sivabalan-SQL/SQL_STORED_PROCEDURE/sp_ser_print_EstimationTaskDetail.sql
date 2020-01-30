CREATE PROCEDURE sp_ser_print_EstimationTaskDetail(@EstID INT)      
AS   
Select "Item Code" = Items.Product_Code, "Item name" = Items.ProductName, 
	"Item Spec1" = IsNull(EDetail.Product_Specification1, ''), 
	"Item Spec2" = IsNull(IInfo.Spec2, ''), 
	"Item Spec3" = IsNull(IInfo.Spec3, ''), 
	"Item Spec4" = IsNull(IInfo.Spec4, ''), 
	"Item Spec5" = IsNull(IInfo.Spec5, ''), 
	"Type" = Case When Isnull(EDetail.JobID, '') <> '' then 'Job' else 'Task' end,
	"JobName" = isnull(JobMaster.JobName, ''),
	"Task Description" = TaskMaster.[Description],
	"Rate" = IsNull(EDetail.Price, 0),
	"Tax%" = IsNull(EDetail.ServiceTax_Percentage, 0),
	"Tax Value" = IsNull(EDetail.ServiceTax, 0),
	"Amount" = IsNull(EDetail.Amount, 0),
	"Net Value" = Netvalue
from EstimationDetail EDetail 
Left Outer Join (Select ie.EstimationID EID, ie.Product_Code, ie.Product_Specification1 Spec1, 
	i.Product_Specification2 Spec2, i.Product_Specification3 Spec3, 
	i.Product_Specification4 Spec4, i.Product_Specification5 Spec5, 
	i.Color, i.DateofSale, i.SoldBy
	From EstimationDetail ie
	Left Outer Join ItemInformation_Transactions i On  
		i.DocumentID = ie.SerialNo and i.DocumentType = 1
	Where 
	ie.SerialNo in (Select Min(g.Serialno) From EstimationDetail g 
		Where g.EstimationID = @EstID Group by g.Product_Specification1)) IInfo 
	On IInfo.EID = EDetail.EstimationID and IInfo.Product_Code = EDetail.Product_Code 
	and IInfo.Spec1 = EDetail.Product_Specification1
Inner Join Items On EDetail.Product_Code = Items.Product_Code
Inner Join TaskMaster On TaskMaster.TaskID = EDetail.TaskID
left Join JobMaster On JobMaster.JobID = EDetail.JobID 
Where EDetail.EstimationID = @EstID
	and EDetail.Type in (1,2) 
	and IsNull(EDetail.SpareCode, '') = ''
	and IsNull(EDetail.TaskID, '') <> ''
Order by EDetail.SerialNo



