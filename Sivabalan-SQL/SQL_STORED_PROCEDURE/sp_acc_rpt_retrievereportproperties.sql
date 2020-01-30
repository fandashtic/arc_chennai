CREATE procedure sp_acc_rpt_retrievereportproperties(@mode integer)
as
Declare @BALANCESHEET int
Declare @PROFITANDLOSS int

set @BALANCESHEET =1
set @PROFITANDLOSS =2 

if @mode = @BALANCESHEET
begin
	select * from FAReportData where (Display in (30,31) or ReportID=3)
	and (ReportID Not in (112,113,114,115,116,117,118,119,120,121,122,123))
	order by ReportID desc
end
else if @mode = @PROFITANDLOSS
begin
	select * from FAReportData where (Display in (33,34) or ReportID=5) 
	and (ReportID Not in (112,113,114,115,116,117,118,119,120,121,122,123))
	order by ReportID desc
end



