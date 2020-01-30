




CREATE procedure sp_acc_rpt_savereportcolumns(@reportid integer,@columnwidth nvarchar(500))
as
update FAReportData set [ColumnWidth]=@columnwidth where [ReportID]=@reportid





