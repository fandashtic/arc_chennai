CREATE PROCEDURE sp_get_DrillDownprintspec(@REPORT_ID INT)  
AS  
SELECT ColIndex, Width, Alignment, LabelName FROM DrillDownPrintSpecs   
WHERE ID = @REPORT_ID ORDER BY ColIndex  


