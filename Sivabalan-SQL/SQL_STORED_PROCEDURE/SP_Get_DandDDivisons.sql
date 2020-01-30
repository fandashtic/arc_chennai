Create procedure SP_Get_DandDDivisons @ID int
AS
BEGIN
	Select Distinct CategoryID From DandDCategory where ID=@ID
END
