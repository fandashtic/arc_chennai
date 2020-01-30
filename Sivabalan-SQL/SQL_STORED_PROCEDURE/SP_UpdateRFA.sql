Create Procedure SP_UpdateRFA @ActivityCode nvarchar(255)
AS
BEGIN
	update CLOCrNote set IsRFAClaimed=1 where ActivityCode=@ActivityCode
END
