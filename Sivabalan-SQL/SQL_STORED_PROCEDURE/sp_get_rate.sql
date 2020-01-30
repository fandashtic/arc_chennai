
Create proc sp_get_rate
            (@BILLID INT)
AS
Select rate from billDetails where billdetalls.billID=@billID


