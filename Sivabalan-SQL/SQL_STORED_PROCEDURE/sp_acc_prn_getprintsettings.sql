
CREATE PROCEDURE sp_acc_prn_getprintsettings(@REPORTID INT)
AS
SELECT ColumnIndex, ColumnWidth, ColumnAlignment,LabelName FROM FAPrintSetting
WHERE ReportID = @REPORTID and YesNo=1 ORDER BY ColumnIndex


