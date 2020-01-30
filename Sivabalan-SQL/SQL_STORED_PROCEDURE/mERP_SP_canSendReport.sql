Create Procedure mERP_SP_canSendReport @ReportID int
AS
BEGIN
/* Frequency for Daily reports is 1. If it returns 1 then don't allow to upload*/
/* Stock Reciept Report 1306 should not upload*/
	If ((Select isnull(Frequency,0) from reports_to_upload where reportdataID=@ReportID and ReportName ='Closing PipeLine')=1 or (@ReportID=1306 ))
	
	BEGIN
	
		Select 1

	END
	Else If (Select isnull(Frequency,0) from reports_to_upload where reportdataID =@ReportID  ) = 0
	Begin
		Select 1
	End
	Else If @ReportID=1517  --/* Vajra Service Log Report 1517 should not upload*/
	Begin
		Select 1
	End
	Else If @ReportID=1519  --/* Periodic Scheme Expense Report 1517 should not upload*/
	Begin
		Select 1
	End

	ELSE
	BEGIN

		Select 0

	END

END

