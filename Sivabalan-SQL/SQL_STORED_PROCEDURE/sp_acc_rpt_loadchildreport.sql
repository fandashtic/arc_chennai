




CREATE Procedure sp_acc_rpt_loadchildreport(@parentid INT)
As
select * from FAReportData where [ParentID]=@parentid and [Display]=0






