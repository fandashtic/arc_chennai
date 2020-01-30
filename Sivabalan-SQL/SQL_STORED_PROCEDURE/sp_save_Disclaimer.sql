
CREATE procedure sp_save_Disclaimer
                 (@TRANID NVARCHAR (50),
                  @DISCLAIMERTEXT NVARCHAR (4000))
AS
IF EXISTS (SELECT TOP 1 DisclaimerText from Disclaimer where TranID=@TRANID)
    BEGIN
        EXEC sp_update_Disclaimer @TRANID,@DISCLAIMERTEXT
    END
ELSE
    BEGIN
        EXEC sp_insert_Disclaimer @TRANID,@DISCLAIMERTEXT
    END


