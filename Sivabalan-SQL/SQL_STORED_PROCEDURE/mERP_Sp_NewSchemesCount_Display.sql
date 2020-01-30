Create Procedure mERP_Sp_NewSchemesCount_Display
AS
Declare @TranDate Datetime
Select TOP 1 @TranDate = TransactionDate FROM Setup  
Set @TranDate = dbo.stripTimeFromDate(@TranDate)

Select Count(*) from tbl_mERP_SchemeAbstract where ViewDate = @TranDate 
and Active = 1 and SchemeType = 3 
