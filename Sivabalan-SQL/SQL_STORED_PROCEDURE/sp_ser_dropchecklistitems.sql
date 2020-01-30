CREATE procedure sp_ser_dropchecklistitems(@CheckListID nvarchar(50),
@CheckListItemID nvarchar(4000),@Mode Int)
as

If @Mode =1 
Begin
	Create Table #TempCheckListItems (CheckListItemID Int Not Null)

	Insert #TempCheckListItems
	exec sp_ser_SqlSplit @CheckListItemID,','

	Delete InspectionCheckListItems
	Where CheckListID = @CheckListID
	and CheckListItemID not in (Select CheckListItemID from #TempCheckListItems)

	Drop Table #TempCheckListItems
End
Else If @Mode =2 
Begin
	Delete InspectionCheckListItems
	Where CheckListID = @CheckListID
End




