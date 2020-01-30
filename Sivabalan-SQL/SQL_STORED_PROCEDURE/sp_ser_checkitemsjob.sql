CREATE Procedure sp_ser_checkitemsjob(@JobID as nvarchar(50), @ProductID as nvarchar(50))
As
If (Exists (Select i.TaskID from Task_Items i 
	Inner join Job_Tasks j on j.TaskID = i.TaskID 
	where j.JobID = @JobID and i.Product_Code = @ProductID))
	Select'JobID'= @JobId,'Product_Code'= @ProductID
	
/*
This join only help to check the existance of item related task for the given jobid
*/



