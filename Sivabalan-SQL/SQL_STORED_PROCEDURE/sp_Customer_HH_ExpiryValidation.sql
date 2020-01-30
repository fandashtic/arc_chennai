Create PROCEDURE sp_Customer_HH_ExpiryValidation
AS
Begin
set dateformat DMY
Declare @ServerDate DateTime
Declare @ExpiryDate DateTime

Set @ServerDate = Getdate()
SELECT @ExpiryDate = dbo.mERP_fn_getToDate(right(convert(varchar(10),dateadd(m,-3,@ServerDate),105),7))

Update HH Set HH.[Confirmation Status] = 3 ,HH.[Confirmation Date] = GETDATE()
from HHCustomer HH where HHCreationDate <= @ExpiryDate
And Isnull([Confirmation Status],0) = 0
End
