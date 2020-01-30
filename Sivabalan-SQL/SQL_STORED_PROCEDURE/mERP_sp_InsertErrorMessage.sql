Create Procedure mERP_sp_InsertErrorMessage( @custType nVarchar(255), @ErrorMessage nVarchar(255), @custID nVarchar(255))
As
Insert Into tbl_mERP_RecdErrMessages ( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values( @custType, @ErrorMessage, @custID, Getdate())
