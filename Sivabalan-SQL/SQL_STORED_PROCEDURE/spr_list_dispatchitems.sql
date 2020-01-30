
CREATE PROCEDURE spr_list_dispatchitems(@DISPATCHID int)
AS
SELECT * FROM DispatchDetail WHERE DispatchID = @DISPATCHID

