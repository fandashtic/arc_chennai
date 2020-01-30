create procedure sp_ser_updatechecklist(@CheckListID nvarchar(50),@Active Int)
as
Update CheckListMaster
Set Active = @Active,
LastModifiedDate = GetDate()
Where CheckListID = @CheckListID




