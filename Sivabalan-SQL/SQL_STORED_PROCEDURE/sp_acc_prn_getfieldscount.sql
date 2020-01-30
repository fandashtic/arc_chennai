create procedure sp_acc_prn_getfieldscount(@ReportID Int)
as
Select Count(*) from FAPrintSetting
Where ReportID = @ReportID

