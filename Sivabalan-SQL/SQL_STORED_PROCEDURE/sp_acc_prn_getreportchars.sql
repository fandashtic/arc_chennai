

create procedure sp_acc_prn_getreportchars(@reportid integer)
as 
select Header,Footer,TopLineBreak,BottomLineBreak,PageLength,TopMargin,BottomMargin,PrintWidth,PrintType from FAReportData where ReportID = @reportid 



