create procedure sp_acc_prn_getdrillRecordsPrintSetting (@Display Integer)
as

select ReportHeader,HiddenColumns,Header,Footer,
TopLineBreak,BottomLineBreak,PageLength,
TopMargin,BottomMargin,PrintWidth,PrintType,
FAPrintSetting.ColumnIndex,FAPrintSetting.ColumnWidth,
FAPrintSetting.ColumnAlignment,FAPrintSetting.LabelName,
'YesNo'=isnull(FAPrintSetting.YesNo,0),ColumnName
from FAReportData,FAPrintSetting
where FAReportData.Display = @Display
and FAReportData.ReportID = FAPrintSetting.ReportID
order by FAPrintSetting.ReportID,ColumnIndex 

