
create proc sp_modify_Area(@AREAID INT,@ACTIVE INT)
AS
update Areas  set Active = @ACTIVE where AreaID = @AREAID


