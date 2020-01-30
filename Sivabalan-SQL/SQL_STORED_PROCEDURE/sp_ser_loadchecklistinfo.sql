CREATE procedure sp_ser_loadchecklistinfo(@CheckListID nvarchar(50))    
as    
Select 'CheckListID' = CheckListMaster.CheckListID,CheckListName,'Active' = IsNull(Active,0),    
'CheckListItemID' = CheckListItems.CheckListItemID,CheckListItemName,FieldType    
From CheckListMaster,CheckListItems,InspectionCheckListItems    
Where CheckListMaster.CheckListID = @CheckListID    
and CheckListMaster.CheckListID = InspectionCheckListItems.CheckListID    
and CheckListItems.CheckListItemID = InspectionCheckListItems.CheckListItemID     



