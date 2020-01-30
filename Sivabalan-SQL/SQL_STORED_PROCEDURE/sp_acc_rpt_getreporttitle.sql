




create procedure sp_acc_rpt_getreporttitle(@reportid integer)
as 
select ReportHeader from FAReportData where ReportID = @reportid 





