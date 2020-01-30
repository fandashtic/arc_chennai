
CREATE PROCEDURE sp_insert_categoryproperties(@CATEGORYID int,
					      @PROPERTY nvarchar(255))
AS
DECLARE @PropertyID int
IF (SELECT Count(*) FROM Properties WHERE Property_Name = @PROPERTY) > 0
	BEGIN
	SELECT @PropertyID = PropertyID FROM Properties WHERE Property_Name = @PROPERTY
	END
ELSE
	BEGIN
	INSERT INTO Properties(Property_Name) VALUES(@PROPERTY)
	SELECT @PropertyID = @@IDENTITY
	END
INSERT INTO Category_Properties VALUES(@CATEGORYID, @PropertyID)

