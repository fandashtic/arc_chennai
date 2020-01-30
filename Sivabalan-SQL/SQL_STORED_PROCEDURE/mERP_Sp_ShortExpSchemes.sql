Create Procedure mERP_Sp_ShortExpSchemes
AS
Declare @TranDate Datetime
Declare @LastTranDate Datetime
Select TOP 1 @TranDate = TransactionDate FROM Setup  
Set @LastTranDate = dbo.stripTimeFromDate(@TranDate)
Set @TranDate = DateAdd(DD, 3, @TranDate)
Select Count(*) from tbl_mERP_SchemeAbstract where ActiveTo between @LastTranDate and  @TranDate
and Active = 1
