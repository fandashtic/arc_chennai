CREATE procedure sp_ser_checklistexists(@ChecklistID varchar(30))
as
Select CheckListName from CheckListMaster Where CheckListID = @ChecklistID

