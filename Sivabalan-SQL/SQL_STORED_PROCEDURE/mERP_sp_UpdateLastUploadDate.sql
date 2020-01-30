Create Procedure mERP_sp_UpdateLastUploadDate(@LastUplDate DateTime, @RepID Int)
AS
	Set dateformat dmy
	if (Select isnull(reportname,'') from Reports_To_Upload where ReportID = @RepID)='Sales Position Report'
	BEGIN
		/* As per ITC request, below condiion is validated for SPR report
			If Current System Date is greater than Grace Date, then only update the LastUploadDate field 
		*/
		if (Select dbo.stripdatefromtime(getdate())) >(select dbo.stripdatefromtime(dateadd(d,graceperiod,@LastUplDate)) from Reports_To_Upload Where ReportID = @RepID)
		Begin
			Update Reports_To_Upload Set GUD = @LastUplDate Where ReportID = @RepID		
		End
			
	END
	/* If current upload date is greater than last upload date then alone update the Last upload date 
	because we introduced the report resending logic*/
	Update Reports_To_Upload Set LastUploadDate = case When @LastUplDate > LastUploadDate then @LastUplDate else LastUploadDate end Where ReportID = @RepID
