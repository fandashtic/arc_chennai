
CREATE procedure sp_save_ColorSettings
                (@ITEMS NVARCHAR (50),
                 @BACKCOLOR INTEGER,
                 @FORECOLOR INTEGER)
AS
IF EXISTS (SELECT TOP 1 BackColor from ColorSettings where Items=@ITEMS)
    BEGIN
        EXEC sp_update_ColorSettings @ITEMS,@BACKCOLOR,@FORECOLOR
    END
ELSE
    BEGIN
        EXEC sp_insert_ColorSettings @ITEMS,@BACKCOLOR,@FORECOLOR
    END


