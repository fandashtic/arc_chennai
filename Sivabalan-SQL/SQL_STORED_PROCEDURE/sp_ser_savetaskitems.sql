CREATE procedure sp_ser_savetaskitems (@TaskID nvarchar(50),@Product_Code nvarchar(15),
@Rate Decimal(18,6),@TaskDuration nvarchar(50))
as

If Exists(Select TaskID from Task_Items where TaskID = @TaskID and Product_Code = @Product_Code)
Begin
	Update Task_Items
	Set Rate = @Rate,
	TaskDuration = @TaskDuration,
	LastModifiedDate = Getdate()
	Where TaskID = @TaskID
	and Product_Code = @Product_Code
End
Else
Begin
	Insert Task_Items(TaskID,Product_Code,Rate,TaskDuration,CreationDate,LastModifiedDate)
	Values (@TaskID,@Product_Code,@Rate,@TaskDuration,Getdate(),Getdate())
End


