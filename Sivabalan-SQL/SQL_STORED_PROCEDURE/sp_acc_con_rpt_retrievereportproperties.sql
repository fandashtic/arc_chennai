
CREATE procedure sp_acc_con_rpt_retrievereportproperties(@mode integer)
as
Declare @BALANCESHEET int
Declare @PROFITANDLOSS int
set @BALANCESHEET =1
set @PROFITANDLOSS =2 
if @mode = @BALANCESHEET
begin
	select * from FAReportData where (Display in (30,31) or ReportID=114)
	and (ReportID Not in (1,64,65))
	order by ReportID desc
end
else if @mode = @PROFITANDLOSS
begin
	select * from FAReportData where (Display in (33,34) or ReportID=116) 
	and (ReportID Not in (69,70))
	order by ReportID desc
end

