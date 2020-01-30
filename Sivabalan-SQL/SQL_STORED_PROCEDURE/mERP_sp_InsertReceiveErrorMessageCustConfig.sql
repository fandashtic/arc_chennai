Create Procedure mERP_sp_InsertReceiveErrorMessageCustConfig( @ScreenName nVarchar(255) )
As
Declare @flgMess int
Declare @ErrMessage nVarchar(255)
Declare @scrmsg nVarchar(255)
Declare @ErrMessageflg nVarchar(255)
Declare @ErrFlag nVarchar(255)

If Not Exists ( select ScreenName from tbl_mERP_ConfigAbstract where ScreenName = @ScreenName)
Begin 
select @ErrMessage = message from  ErrorMessages where ErrorID = 129
Select @scrmsg = @ErrMessage + ' ' + '-' + convert(nVarchar, @ScreenName)
Insert Into tbl_mERP_RecdErrMessages ( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values( 'CustomerConfig', @scrmsg, null , Getdate())
Insert into tbl_mERP_RecConfigAbstract (Menuname, sTATUS) Values (@scrmsg,  64)
End
