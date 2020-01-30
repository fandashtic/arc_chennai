

CREATE PROCEDURE sp_Update_soRefNumber(@SONumber int,@dispatchID int)
AS
UPDATE SOAbstract SET RefNumber = Refnumber +  ',' + @dispatchID,status=status | 4 WHERE SONumber = @SONumber




