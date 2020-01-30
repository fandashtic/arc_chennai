Create Procedure sp_Open_VanStatement (@DocSerial int)
As
If Exists(Select * From VanStatementDetail Where DocSerial = @DocSerial And Pending > 0) 
	Update VanStatementAbstract Set Status = 0 Where DocSerial = @DocSerial
