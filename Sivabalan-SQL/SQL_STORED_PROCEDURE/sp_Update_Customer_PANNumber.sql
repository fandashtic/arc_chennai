Create Procedure sp_Update_Customer_PANNumber(@PANNumber nvarchar(100))
AS
BEGIN

Update Customer Set PANNumber = @PANNumber

END
