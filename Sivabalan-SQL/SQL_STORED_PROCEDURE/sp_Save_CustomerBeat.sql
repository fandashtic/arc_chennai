
CREATE PROCEDURE sp_Save_CustomerBeat
        (@BeatID 	INT,
	 @CustomerID 	[nvarchar](15))
AS
IF EXISTS (SELECT TOP 1 CustomerID FROM Beat_Salesman WHERE CustomerID = @CustomerID)
	BEGIN
	EXEC sp_update_CustomerBeat @BeatID,@CustomerID
	END
ELSE
	BEGIN
	EXEC sp_insert_CustomerBeat @BeatID,@CustomerID
	END



