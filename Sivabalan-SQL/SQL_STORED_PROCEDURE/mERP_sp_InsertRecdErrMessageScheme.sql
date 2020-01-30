Create Procedure mERP_sp_InsertRecdErrMessageScheme (@TranType nVarchar(100), @ErrMessage nVarchar(255), @KeyValue nVarchar(255))  
As  
Insert Into tbl_mERP_RecdErrMessages (TransactionType, ErrMessage, KeyValue, ProcessDate)    
Values(@TranType, @ErrMessage, @KeyValue, getdate())  
