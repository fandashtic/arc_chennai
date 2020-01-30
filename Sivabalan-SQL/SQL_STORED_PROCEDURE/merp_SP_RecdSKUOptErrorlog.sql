Create procedure merp_SP_RecdSKUOptErrorlog(@Type int, @KeyVal nVarchar(510), @Errormessage nvarchar(4000))   
AS   
BEGIN   
	Declare @TranType nvarchar(100)  
	Set @TranType = Case @Type When 1 then 'PORTFOLIO' when 2 then 'SKULIST' End  
	insert into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)   
	values (@TranType,@ErrorMessage,@KeyVal,getdate())   
END    
