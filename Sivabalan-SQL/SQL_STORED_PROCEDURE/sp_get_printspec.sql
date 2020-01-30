CREATE PROCEDURE sp_get_printspec(@REPORT_ID INT)
AS
SELECT ColIndex, Width, Alignment, LabelName FROM PrintSpecs 
WHERE ID = @REPORT_ID and isnull(specialfield,0)=0 ORDER BY ColIndex

