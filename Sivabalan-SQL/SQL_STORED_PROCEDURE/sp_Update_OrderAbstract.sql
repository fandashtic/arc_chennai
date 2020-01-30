CREATE Procedure sp_Update_OrderAbstract (@DocSerial Int, @Description nvarchar(255), 
	@Active Int, @ModifiedDate DateTime)
As

Update OrderAbstract Set [Description] = @Description, Active = @Active, 
	ModifiedDate = @ModifiedDate Where DocSerial = @DocSerial

Delete from OrderDetail Where DocSerial = @DocSerial

Select @DocSerial

