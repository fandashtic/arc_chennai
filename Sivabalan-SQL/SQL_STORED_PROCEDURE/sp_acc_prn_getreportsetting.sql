CREATE procedure sp_acc_prn_getreportsetting(@reportid int,@Columns  as varchar(5000) = null)
as
if @Columns is null 
Begin
	select ReportHeader,HiddenColumns,Header,Footer,
	TopLineBreak,BottomLineBreak,PageLength,
	TopMargin,BottomMargin,PrintWidth,PrintType,
	FAPrintSetting.ColumnIndex,FAPrintSetting.ColumnWidth,
	FAPrintSetting.ColumnAlignment,FAPrintSetting.LabelName,
	'YesNo'=isnull(FAPrintSetting.YesNo,0),ColumnName
	from FAReportData,FAPrintSetting
	where FAReportData.ReportID = @reportid 
	and FAReportData.ReportID = FAPrintSetting.ReportID
	order by FAPrintSetting.ReportID,ColumnIndex 
End
Else
Begin
	create table #temptable (fields varchar(5000) COLLATE SQL_Latin1_General_CP1_CI_AS)
	insert into #temptable
	exec dbo.Sp_acc_SQLSplit @Columns,'|'

	select ReportHeader,HiddenColumns,Header,Footer,
	TopLineBreak,BottomLineBreak,PageLength,
	TopMargin,BottomMargin,PrintWidth,PrintType,
	FAPrintSetting.ColumnIndex,FAPrintSetting.ColumnWidth,
	FAPrintSetting.ColumnAlignment,FAPrintSetting.LabelName,
	'YesNo'=isnull(FAPrintSetting.YesNo,0),ColumnName
	from FAReportData,FAPrintSetting
	where FAReportData.ReportID = @reportid 
	and FAReportData.ReportID = FAPrintSetting.ReportID
	and columnname in (select fields from #temptable )
	order by FAPrintSetting.ReportID,ColumnIndex 

	drop table #temptable
End




