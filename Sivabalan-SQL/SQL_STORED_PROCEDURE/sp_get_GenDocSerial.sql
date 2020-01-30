CREATE procedure sp_get_GenDocSerial(@TranType int,@DocType nvarchar(100))
As
Select dbo.fn_GetTransactionSerial(@TranType,@DocType,-1)

