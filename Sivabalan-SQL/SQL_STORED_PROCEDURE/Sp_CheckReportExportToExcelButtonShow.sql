Create Procedure dbo.Sp_CheckReportExportToExcelButtonShow(@ReportID int = 0)
As
Begin
	Declare @FlagValue as Int
	IF Exists (Select * from ReportData where ID = @ReportID)
	Begin
		If Isnull(@ReportID,0) = 1280 /* GGRR Report */
		Set @FlagValue = 1
	End
	Select Isnull(@FlagValue,0) Flag
End
