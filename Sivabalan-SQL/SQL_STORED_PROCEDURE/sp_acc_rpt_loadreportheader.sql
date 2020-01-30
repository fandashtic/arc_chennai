CREATE Procedure sp_acc_rpt_loadreportheader(@parentid INT)
As
Select * from FAReportData where [ParentID]=@parentid and [Display]=1
and ReportID Not In (112,114,116) order by ReportOrder,ReportID
