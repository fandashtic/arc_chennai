CREATE Procedure sp_update_ManufacturerName (@ID nvarchar(10),@NewName nvarchar(128), @Code nvarchar(40))
As  
Update Manufacturer Set manufacturer_Name = @NewName, ManufacturerCode = @code
Where ManufacturerID = @ID  




