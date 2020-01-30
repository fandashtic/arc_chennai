CREATE Procedure sp_ser_update_servicenamechange(@ItemCode as nVarchar(50),
				@NewName as nVarchar(50),@DocumentType  as int) 
as  
if @DocumentType = 1
Update PersonnelMaster set PersonnelName = @NewName where PersonnelID = @ItemCode
else if @DocumentType = 2
Update TaskMaster set [Description] = @NewName where TaskID = @ItemCode
else if @DocumentType = 3
Update JobMaster set JobName = @NewName where JobID = @ItemCode
else if @DocumentType = 4
Update CheckListMaster set CheckListName = @NewName where CheckListID = @ItemCode

