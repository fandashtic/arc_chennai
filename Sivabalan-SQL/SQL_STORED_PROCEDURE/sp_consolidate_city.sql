
CREATE PROCEDURE sp_consolidate_city(@CITY nvarchar(50),
				    @ACTIVE int)
AS
IF NOT EXISTS (SELECT CityID FROM City WHERE CityName = @CITY)
BEGIN
Insert City(CityName, Active)
VALUES(@CITY, @ACTIVE)
END

