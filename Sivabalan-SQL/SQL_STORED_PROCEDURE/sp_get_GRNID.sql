
Create proc sp_get_GRNID
            (@BILLID INT)
AS
Select GRNID from billAbstract where billAbstract.billID=@billID


