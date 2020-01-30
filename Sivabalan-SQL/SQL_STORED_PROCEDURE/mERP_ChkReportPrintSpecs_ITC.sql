CREATE PROCEDURE mERP_ChkReportPrintSpecs_ITC 
(  
@nReportID int
)
As
Begin
If Exists (Select Top 1 [Active] = IsNull([Active],0) from PrintSpecs_Exception Where Active = 1 and ReportID = @nReportID)
	Select 1
Else
	Select 0
End
