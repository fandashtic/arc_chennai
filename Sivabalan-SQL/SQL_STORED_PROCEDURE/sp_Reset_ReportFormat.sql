Create Procedure sp_Reset_ReportFormat (@ReportID int)
As
Update ReportData Set ColumnWidth = Null Where Id = @ReportID

