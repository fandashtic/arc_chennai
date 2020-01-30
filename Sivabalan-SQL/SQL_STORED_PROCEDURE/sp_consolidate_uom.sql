
CREATE PROCEDURE sp_consolidate_uom(@UOM nvarchar(50),
				    @ACTIVE int)
AS
IF NOT EXISTS (SELECT UOM FROM UOM WHERE Description = @UOM)
BEGIN
Insert UOM(Description, Active)
VALUES(@UOM, @ACTIVE)
END


