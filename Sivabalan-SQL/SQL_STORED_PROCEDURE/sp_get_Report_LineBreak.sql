CREATE Procedure sp_get_Report_LineBreak (@ID int)
As
Select IsNull(TopLineBreak, 0), IsNull(BottomLineBreak, 0), 
IsNull(TopMargin, 3), IsNull(BottomMargin, 3), IsNull(PageLength, 58) 
From ReportData Where ID = @ID
