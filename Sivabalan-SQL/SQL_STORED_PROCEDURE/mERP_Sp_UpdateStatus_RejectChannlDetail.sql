Create Procedure mERP_Sp_UpdateStatus_RejectChannlDetail ( @ID int)
As
Begin
declare  @Errmessage nVarchar(255)
select @Errmessage=Message from ErrorMessages where ErrorID=148
Update tbl_mERP_RecdChannlDetail Set status=Status | 64  where ID =  @ID and (Channelcode=' ' or Channelcode is null)
or (Channelname=' ' or Channelname is null)
Insert Into tbl_mERP_RecdErrMessages ( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values( 'CHL001', @Errmessage, Null, GetDate())
End

SET QUOTED_IDENTIFIER OFF
