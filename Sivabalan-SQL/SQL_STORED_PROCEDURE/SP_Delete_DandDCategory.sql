
Create Procedure SP_Delete_DandDCategory(@ID int)
AS

Begin

Delete From DandDCategory
Where 
	ID = @ID

End

