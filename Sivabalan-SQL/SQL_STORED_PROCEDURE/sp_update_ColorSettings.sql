
CREATE Procedure sp_update_ColorSettings
                (@ITEMS NVARCHAR (50),
                 @BACKCOLOR INTEGER,
                 @FORECOLOR INTEGER)
AS
Update ColorSettings Set BackColor = @BACKCOLOR,ForeColor=@FORECOLOR where Items=@ITEMS




