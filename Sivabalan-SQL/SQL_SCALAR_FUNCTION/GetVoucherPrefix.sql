


CREATE Function GetVoucherPrefix(@DESCRIPTION nvarchar(50))
Returns nvarchar(15)
As
Begin
Return (select Prefix from VoucherPrefix where TranID = @DESCRIPTION)
End




