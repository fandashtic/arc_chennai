
create proc sp_modify_Beat(@BEATID INT,@ACTIVE INT)
AS
update Beat  set Active = @ACTIVE where BeatID = @BEATID


