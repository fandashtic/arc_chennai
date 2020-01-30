CREATE procedure sp_acc_GenerateDocSerial(@TranType int,@DocType nVarchar(255))  
As  
Select dbo.sp_acc_GetTransactionSerial(@TranType, @DocType, -1) 
