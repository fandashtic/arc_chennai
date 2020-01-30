Create Procedure mERP_SP_InsertDetailCustomerConfig (@ID int, @Flag int, @FieldName nVarchar(100), @ScreenCode nVarchar(255)) -- @Field=doubt
As

Declare @LastUploadDate as datetime
declare @ExistFlag as int
select @LastUploadDate =  Dateadd(month, Datediff(month, 0, Getdate()), 0)-1

If @ScreenCode = 'DFRFLAG' And @Fieldname = 'UPLOAD'
Begin
    select @ExistFlag = isnull(Flag,0) from  tbl_mERP_ConfigDetail where ScreenCode ='DFRFLAG' and XMLAttribute='UPLOAD'
    if @ExistFlag = 0 and @Flag = 1
    begin
	  Update Reports_To_Upload  Set LastUploadDate  = @LastUploadDate Where ReportDataID=1421
    end
End

If @ScreenCode = 'WLVFLAG' And @Fieldname = 'UPLOAD'
Begin
    select @ExistFlag = isnull(Flag,0) from  tbl_mERP_ConfigDetail where ScreenCode ='WLVFLAG' and XMLAttribute='UPLOAD'
    if @ExistFlag = 0 and @Flag = 1
    begin
	  Update Reports_To_Upload  Set LastUploadDate  = @LastUploadDate Where ReportDataID=1420
    end
End

Update CD Set Flag = @Flag
from tbl_mERP_ConfigDetail CD Inner join tbl_mERP_RecConfigDetail RCD
On CD.XMLAttribute = RCD.FieldName
Where RCD.ID = @ID
and  CD.Screencode = @ScreenCode
and  CD.XMLAttribute = @Fieldname

Update tbl_mERP_RecConfigDetail set Status = Status | 32 Where ID = @ID and Fieldname = @FieldName

If @ScreenCode = 'CST05' And @Fieldname = 'Field2'
Begin
	Update tbl_mERP_ConfigDetail Set Flag = @Flag Where Screencode = 'CST03' And ControlName = 'Zone'
End

If @ScreenCode = 'CST06' And @Fieldname = 'Field2'
Begin
	Update tbl_mERP_ConfigDetail Set Flag = @Flag Where Screencode = 'CST04' And ControlName = 'Zone'
End

