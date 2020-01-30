




CREATE procedure sp_acc_rpt_loadreportcolumns(@reportid integer) 
as
select isnull([ColumnWidth],0) from FAReportData where [ReportID]=@reportid






