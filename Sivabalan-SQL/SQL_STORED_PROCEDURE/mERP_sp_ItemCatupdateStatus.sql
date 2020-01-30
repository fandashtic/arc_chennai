Create Procedure  mERP_sp_ItemCatupdateStatus (@ID int, @catname nVarchar(255), @CustID nVarchar(255))
As
declare  @Errmessage nVarchar(255)
select @Errmessage=Message from ErrorMessages where ErrorID=151
Update tbl_mERP_RecdCatHandDetail Set status=64 where ID = @ID and
CustomerID =  @CustID and CategoryName = @catname
Insert Into tbl_mERP_RecdErrMessages ( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values( 'CHC001', @Errmessage, Null, GetDate())
