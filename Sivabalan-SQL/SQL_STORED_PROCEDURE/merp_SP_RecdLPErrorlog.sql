Create procedure merp_SP_RecdLPErrorlog(@LPType int, @LPPeriod nVarchar(10), @KeyVal nVarchar(510), @Errormessage nvarchar(4000)) 
AS 
BEGIN 
Declare @TranType nvarchar(100)
Declare @KeyData nVarchar(510)
Set @TranType = Case @LPType When 1 then 'LP_SCORE' when 2 then 'LP_ACHIEVEMENT' End
Set @KeyData = @LPPeriod + @KeyVal
	insert into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate) 
	values (@TranType,@ErrorMessage,@KeyData,getdate()) 
END  
