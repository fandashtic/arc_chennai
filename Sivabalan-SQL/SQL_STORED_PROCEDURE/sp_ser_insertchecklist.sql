create procedure sp_ser_insertchecklist(@CheckListID nvarchar(50),
@CheckListName nvarchar(255))
as
Insert CheckListMaster(CheckListID,CheckListName,LastModifiedDate,Active)
Values(@CheckListID,@CheckListName,getdate(),1)

