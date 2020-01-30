
CREATE procedure sp_acc_gethiddencols(@reportid int)
as
select isnull(HiddenColumns,0) from FaReportData 
where ReportID = @reportid




