
CREATE procedure sp_acc_prn_saveabstract(@reportid int,@colindex int,
@columnwidth int,@columnalignment int,@labelname nvarchar(255),
@yesno int,@columnname nvarchar(255))
as
If not exists(Select Top 1 ColumnIndex from FAPrintSetting
where ReportID=@reportid and ColumnIndex =  @colindex)
Begin
	Insert Into FAPrintSetting(ReportID,ColumnIndex,ColumnWidth,ColumnAlignment,LabelName,YesNo,ColumnName)
	values(@reportid,@colindex,@columnwidth,@columnalignment,@labelname,@yesno,@columnname)
End
else
begin
	Update FAPrintSetting
	Set ReportID = @reportid,
	ColumnIndex = @colindex,
	ColumnWidth = @columnwidth,
	ColumnAlignment = @columnalignment,
	LabelName = @labelname,
	YesNo = @yesno,
	ColumnName = @columnname
	where ReportID = @reportid
	and ColumnIndex =@colindex
 end
 





