Create Procedure sp_acc_rpt_ResetColumns(@ReportID Int)
As
Update FAReportData Set ColumnWidth=DefaultColumnWidth  Where ReportID=@ReportID


