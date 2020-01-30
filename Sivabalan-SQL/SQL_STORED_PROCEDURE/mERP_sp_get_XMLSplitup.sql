CREATE Procedure mERP_sp_get_XMLSplitup (@ReportID int)
AS
IF Exists (Select ReportName from XMLSplitup Where ReportDataID = @ReportID)
  Select 1,Splitup From XMLSplitup Where ReportDataID = @ReportID
Else
  Select 0,0
