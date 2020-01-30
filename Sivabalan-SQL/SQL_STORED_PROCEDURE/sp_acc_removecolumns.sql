create procedure sp_acc_removecolumns(@ReportID Int)
as
Delete FAPrintSetting 
Where ReportID = @ReportID


