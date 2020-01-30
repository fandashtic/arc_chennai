Create Procedure sp_Cancel_SC_For_Amendment (@SoNumber integer)
As
Update SOAbstract Set Status= (Status | 320) where SoNumber=@SoNumber


