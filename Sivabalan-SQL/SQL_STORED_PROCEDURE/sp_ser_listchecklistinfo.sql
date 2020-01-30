CREATE PROCEDURE [dbo].[sp_ser_listchecklistinfo]  (@CheckListID nvarchar(50))
AS

Select i.CheckListID, i.CheckListItemID, t.CheckListItemName, i.FieldType, c.Active from 
InspectionCheckListItems i
Inner Join CheckListItems t on t.CheckListItemID = i.CheckListItemID
Inner Join CheckListMaster c On c.CheckListID = i.CheckListID
Where i.CheckListID = @CheckListId 
Order by t.CheckListItemName

