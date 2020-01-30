CREATE PROCEDURE sp_ser_print_JobCardCheckListDetail(@JobCardID INT)    
AS    
SELECT 
  "Item Code" = JCD.Product_Code
, "Item Name" = ITMS.ProductName
, "Item Spec1" = IsNull(JCD.Product_Specification1, '')
, "Item Spec2" = IsNull(ITINF.Product_Specification2, '')
, "Item Spec3" = IsNull(ITINF.Product_Specification3, '')
, "Item Spec4" = IsNull(ITINF.Product_Specification4, '')
, "Item Spec5" = IsNull(ITINF.Product_Specification5, '')
, "CheckList ID" = JCCL.CheckListID
, "CheckList Name" = CHLM.CheckListName
, "CheckListItem Name" = CHLI.CheckListItemName
, "Value" = IsNull(JCCL.FieldValue,'')
from JobCardDetail JCD
Inner Join Items ITMS On ITMS.product_code  = JCD.Product_code and JCD.Type = 0
Inner Join JobCardCheckList JCCL On JCCL.SerialNo = JCD.SerialNO
Left Outer Join CheckListMaster CHLM On CHLM.CheckListID = JCCL.CheckListID
Left Outer Join CheckListItems CHLI On CHLI.CheckListItemID = JCCL.CheckListItemID
Left outer Join ItemInformation_Transactions ITINF On ITINF.DocumentID = JCD.SerialNO
Where JCD.JobCardID = @JobCardID and IsNull(JCCL.CheckListID,'') <> ''
Order by JCD.SerialNo
