
CREATE PROCEDURE sp_consolidate_beat(@BEAT nvarchar(50),
				    @ACTIVE int)
AS
IF NOT EXISTS (SELECT BeatID FROM Beat WHERE Description = @BEAT)
BEGIN
Insert Beat(Description, Active)
VALUES(@BEAT, @ACTIVE)
END

