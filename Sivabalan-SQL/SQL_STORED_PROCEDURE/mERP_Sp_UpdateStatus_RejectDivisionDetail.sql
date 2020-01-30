Create Procedure mERP_Sp_UpdateStatus_RejectDivisionDetail ( @ID int)
As
Begin
declare  @Errmessage nVarchar(255)
select @Errmessage=Message from ErrorMessages where ErrorID=149
Update tbl_mERP_RecdCatDetail Set status=Status | 64 where ID = @ID and (division=' ' or Division is null)
or (categorygroup=' ' or categorygroup is null)
Insert Into tbl_mERP_RecdErrMessages ( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values( 'CGD001', @Errmessage, Null, GetDate())
End
SET QUOTED_IDENTIFIER OFF
