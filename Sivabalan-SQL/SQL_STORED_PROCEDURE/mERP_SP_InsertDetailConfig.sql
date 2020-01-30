Create Procedure mERP_SP_InsertDetailConfig (@ID int, @Flag int, @FieldName nVarchar(100), @ScreenCode nVarchar(255)) 
As
Update CD Set Flag = @Flag
from tbl_mERP_ConfigDetail CD Inner join tbl_mERP_RecConfigDetail RCD
On CD.XMLAttribute = RCD.FieldName
Where RCD.ID = @ID
and  CD.Screencode = @ScreenCode
and  CD.XMLAttribute = @Fieldname

Update tbl_mERP_RecConfigDetail set Status = Status | 32 Where ID = @ID and Fieldname = @FieldName
