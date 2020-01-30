CREATE procedure sp_ser_savechecklistitems(@CheckListID nvarchar(50),      
@CheckListItem nvarchar(255),@FieldType Int)      
as      
Declare @CheckListItemID Int      
      
If Not Exists(Select * from CheckListItems where CheckListItemName = @CheckListItem)      
Begin      
Insert CheckListItems(CheckListItemName,LastModifiedDate)      
 Values(@CheckListItem,Getdate())      
        if @@rowcount > 0       
        Begin           
  Select @CheckListItemID = @@Identity      
  End      
 If Not Exists(Select * from InspectionCheckListItems Where CheckListID = @CheckListID and      
        CheckListItemID = @CheckListItemID)       
 Begin      
 Insert InspectionCheckListItems(CheckListID,CheckListItemID,FieldType)      
  Values(@CheckListID,@CheckListItemID,@FieldType)       
 End      
 Else      
 Begin      
  Select @CheckListItemID = CheckListItemID from CheckListItems      
  Where CheckListItemName = @CheckListItem      
      
  Update InspectionCheckListItems      
  Set FieldType = @FieldType      
  Where CheckListID = @CheckListID      
  and CheckListItemID = @CheckListItemID      
 End      
End      
Else      
Begin      
 Update CheckListItems      
 Set LastModifiedDate = GetDate()      
 Where CheckListItemName = @CheckListItem        
       
 Select  @CheckListItemID = CheckListItemID       
 from CheckListItems Where CheckListItemName = @CheckListItem        
       
 If Not Exists(Select * from InspectionCheckListItems Where CheckListID = @CheckListID and      
        CheckListItemID = @CheckListItemID)       
 Begin      
  Insert InspectionCheckListItems(CheckListID,CheckListItemID,FieldType)      
  Values(@CheckListID,@CheckListItemID,@FieldType)       
 End      
 Else      
 Begin      
  Select @CheckListItemID = CheckListItemID from CheckListItems      
  Where CheckListItemName = @CheckListItem      
      
  Update InspectionCheckListItems      
  Set FieldType = @FieldType      
  Where CheckListID = @CheckListID      
  and CheckListItemID = @CheckListItemID      
 End      
      
End      
Select @CheckListItemID    

