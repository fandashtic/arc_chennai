
CREATE PROCEDURE spr_list_grnitems(@GRNID int)
AS
SELECT * FROM GRNDetail WHERE GRNID = @GRNID


