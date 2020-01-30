
CREATE Procedure sp_insert_ColorSettings
                (@ITEMS NVARCHAR (50),
                 @BACKCOLOR INTEGER,
                 @FORECOLOR INTEGER)
AS
Insert into ColorSettings
            (Items,
             BackColor,
             ForeColor)
Values 
      (@ITEMS,
       @BACKCOLOR,
       @FORECOLOR)



