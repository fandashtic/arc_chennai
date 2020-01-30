CREATE Procedure sp_ser_rpt_checklistItem(@CheckListID nvarchar(50))
AS 
select CheckListItemName,'CheckListItem' = CheckListItemName, 
(case FieldType when 1 then 'Text' when 2 then 'Yes/No' 
else '' end) as 'Field Type' 
from CheckListMaster,CheckListItems,InspectionCheckListItems
where InspectionCheckListItems.ChecklistID = @CheckListID
and InspectionCheckListItems.CheckListItemID = CheckListItems.CheckListItemID
and checklistmaster.checklistid = InspectionCheckListItems.Checklistid
group by CheckListItemName ,FieldType

