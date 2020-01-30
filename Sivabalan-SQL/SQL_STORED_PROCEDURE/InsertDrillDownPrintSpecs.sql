Create Procedure InsertDrillDownPrintSpecs(@ReportID Int, @ColIndex Int, 
@Width Int,@Alignment Int, @LabelName nVarchar(100))
As
Insert Into DrillDownPrintSpecs 
(ID,ColIndex, Width,Alignment, LabelName)
Values
(@ReportID, @ColIndex, @Width,@Alignment, @LabelName)

