Create Procedure SP_save_DandDCategory @ID int,@BrandID int
AS
BEGIN
	Insert into DandDCategory(ID,CategoryID)
	Select @ID,@BrandID
	
END
