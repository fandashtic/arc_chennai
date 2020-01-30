CREATE procedure sp_ser_GenDocSerial(@TranType int, @DocType Varchar(100), @LastCount int = -1)
As
Select dbo.fn_ser_GetTransactionSerial(@TranType, @DocType, @LastCount)

