
CREATE PROCEDURE sp_consolidate_country(@COUNTRY nvarchar(50),
				    @ACTIVE int)
AS
IF NOT EXISTS (SELECT CountryID FROM Country WHERE Country = @COUNTRY)
BEGIN
Insert Country(Country, Active)
VALUES(@COUNTRY, @ACTIVE)
END

