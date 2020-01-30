CREATE PROCEDURE sp_insert_UOM (@Description nvarchar(255))
AS 
Declare @ID Int
If Not Exists (Select * From UOM Where [Description]=@Description)
Begin
	INSERT INTO [UOM] (Description) VALUES (@Description) 
	SELECT @@IDENTITY
End
Else
Begin
	SELECT @ID=UOM From UOM Where [Description]=@Description
	SELECT @ID
End
