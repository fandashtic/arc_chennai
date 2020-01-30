Create Procedure mERP_Sp_UpdateStatus_RejectMasChangeDetail ( @ID int)
As
Begin 
 declare  @Errmessage nVarchar(255)
 select @Errmessage=Message from ErrorMessages where ErrorID=150
 Update tbl_mERP_RecdMstChangeDetail Set status=64 where ID = @ID and (controlname=' ' or controlname is null)
 Insert Into tbl_mERP_RecdErrMessages ( TransactionType, ErrMessage, KeyValue, ProcessDate)
 Values( 'MNC001', @Errmessage, Null, GetDate())
end
SET QUOTED_IDENTIFIER OFF
