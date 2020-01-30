
CREATE PROCEDURE sp_consolidate_area(@AREA nvarchar(50),
				    @ACTIVE int)
AS
IF NOT EXISTS (SELECT AreaID FROM Areas WHERE Area = @AREA)
BEGIN
Insert Areas(Area, Active)
VALUES(@AREA, @ACTIVE)
END

