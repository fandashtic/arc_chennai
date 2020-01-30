
create procedure merp_SP_storeSurveyErrorlog (@SurveyID int,@Errormessage nvarchar(4000))
AS 
BEGIN
	insert into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate) values ('Survey',@ErrorMessage,@SurveyID,getdate())
END

