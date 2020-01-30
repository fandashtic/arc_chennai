
Create Procedure sp_update_VoucherPrefix
                 (@TRANID  NVARCHAR (50),
                  @PREFIX NVARCHAR (10)) 
As
update VoucherPrefix Set Prefix = @PREFIX where TranID=@TRANID

