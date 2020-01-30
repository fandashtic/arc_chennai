CREATE Procedure sp_acc_retrivegroups(@PARENT as integer)
as
Select * from AccountGroup where ParentGroup = @PARENT and GroupID <> 500

