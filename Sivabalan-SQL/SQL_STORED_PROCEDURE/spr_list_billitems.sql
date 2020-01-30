

CREATE PROCEDURE spr_list_billitems(@BILLID int)
AS
SELECT * FROM BillDetail WHERE BillID = @BILLID


