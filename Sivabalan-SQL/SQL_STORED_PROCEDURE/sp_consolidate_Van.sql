
create procedure sp_consolidate_Van (@Van nvarchar(255), @Van_Number nvarchar(255), @Active int)
as
If not exists(Select Van_Number From Van Where Van = @Van)
  Insert into Van (Van,Van_Number,Active) Values (@Van, @Van_Number, @Active)
Else
  Update Van Set Van_Number = @Van_Number, Active = @Active Where Van = @Van

