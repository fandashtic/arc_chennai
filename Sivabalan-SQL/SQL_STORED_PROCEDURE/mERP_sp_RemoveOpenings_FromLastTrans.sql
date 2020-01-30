Create Procedure mERP_sp_RemoveOpenings_FromLastTrans
AS
Declare @LastTranDate DateTime
Select @LastTranDate = TransactionDate From Setup
Delete From OpeningDetails Where Opening_Date > @LastTranDate
Delete From AccountOpeningBalance Where OpeningDate > @LastTranDate
