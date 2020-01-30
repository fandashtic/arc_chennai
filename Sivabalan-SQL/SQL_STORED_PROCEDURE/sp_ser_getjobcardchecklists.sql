CREATE Procedure sp_ser_getjobcardchecklists (@SerialNo int)
As
Select j.CheckListID, "CheckListName" = IsNull(CheckListMaster.CheckListName,'')
,"CheckListItemID" = IsNull(j.CheckListItemID,'')
,"CheckListItemName" =  IsNull(CheckListItems.CheckListItemName,'')
--Restrict to load field type when there is no checklist item
,Case when isNull(j.CheckListItemID,'') <> ''
 then (case j.FieldType
  when 0 then 'Text'
  when 1 then 'Yes/No' end)
else '' end 'FieldType'
,j.FieldValue       
from JobCardCheckList j       
Left Outer Join CheckListMaster on CheckListMaster.CheckListID = j.CheckListID      
Left Outer Join CheckListItems on CheckListItems.CheckListItemID = j.CheckListItemID      
Where j.SerialNo = @SerialNo      
Order by CheckListItemName  
