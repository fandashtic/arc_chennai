CREATE procedure sp_List_Formula(@ReportID Int,@FormulaType Int)
as
Select ColumnName,Formula From ReportFormula Where ReportID = @ReportID and FormulaType=@FormulaType  Order by Serial


