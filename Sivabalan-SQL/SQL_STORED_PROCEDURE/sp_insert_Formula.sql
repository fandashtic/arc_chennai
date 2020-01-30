CREATE procedure sp_insert_Formula(@ReportID Int, @FormulaName nvarchar(50), @Formula nvarchar(2000),@Serial Int,@FormulaType Int)
as
Insert Into ReportFormula ( ReportID,ColumnName,Formula,Serial,FormulaType) Values (@ReportID,@FormulaName,@Formula,@Serial,@FormulaType)


