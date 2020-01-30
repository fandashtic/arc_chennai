
CREATE PROCEDURE sp_consolidate_state(@STATE nvarchar(50),
				    @ACTIVE int)
AS
IF NOT EXISTS (SELECT StateID FROM State WHERE State = @STATE)
BEGIN
Insert State(State, Active)
VALUES(@STATE, @ACTIVE)
END

