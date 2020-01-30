
Create Procedure SP_Delete_DandDDetail(@ID int)
AS
Begin
	Delete From DandDDetail Where ID = @ID

	Delete From DandDTaxComponents Where DandDID = @ID
End
