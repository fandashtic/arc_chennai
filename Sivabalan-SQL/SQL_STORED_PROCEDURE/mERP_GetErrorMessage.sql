Create Procedure mERP_GetErrorMessage(@ErrorID Int)
As
Begin
	Select Message From ErrorMessages Where ErrorID = @ErrorID
End

