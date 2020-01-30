CREATE procedure sp_acc_prn_saveheaderabstract(@reportid int,@colindex int,  
@columnwidth int,@columnalignment int,@labelname nvarchar(255),  
@yesno int,@TextFormat Int)  
as  
Insert Into FAHeaderPrintSetting(ReportID,ColumnIndex,ColumnWidth,ColumnAlignment,LabelName,YesNo,Textformat)  
values(@reportid,@colindex,@columnwidth,@columnalignment,@labelname,@yesno,@Textformat)  


