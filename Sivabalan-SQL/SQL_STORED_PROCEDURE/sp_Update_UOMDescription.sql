Create procedure sp_Update_UOMDescription(@UOMID int, @NewName nvarchar(128))
as
--This procedure is used in Master Name Change form
update UOM set description=@NewName where UOM=@UOMID
