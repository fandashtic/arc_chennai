CREATE procedure sp_ser_loadchecklistitems(@CheckListItemID Int)
as
Select CheckListItems.CheckListItemID,CheckListItemName
from CheckListItems Where CheckListItems.CheckListItemID = @CheckListItemID



