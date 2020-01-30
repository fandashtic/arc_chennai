CREATE procedure sp_ser_checkitemstask (@TaskId as nvarchar(50), @ProductID as nvarchar(50))
As 
If (Exists (Select i.TaskID from Task_Items i 
            where i.TaskID = @TaskId and i.Product_Code = @ProductID)) 
	Select @TaskId 'TaskID', @ProductID 'Product_Code'

/*
This join only help to check the existance of item related task for the given taskid
*/


