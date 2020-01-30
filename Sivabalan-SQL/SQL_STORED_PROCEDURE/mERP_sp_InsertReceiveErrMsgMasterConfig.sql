
Create Procedure mERP_sp_InsertReceiveErrMsgMasterConfig( @ScreenName nVarchar(255) )
As
Declare @flgMess int
Declare @ErrMessage nVarchar(255)
Declare @scrmsg nVarchar(255)
Declare @ErrMessageflg nVarchar(255)
Declare @ErrFlag nVarchar(255)
select @ErrMessage = message from  ErrorMessages where ErrorID = 136
Select @scrmsg = @ErrMessage + ' ' + '-' + convert(nVarchar, @ScreenName)
Insert Into tbl_mERP_RecdErrMessages ( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values( 'MastersConfig', @scrmsg, null , Getdate())

