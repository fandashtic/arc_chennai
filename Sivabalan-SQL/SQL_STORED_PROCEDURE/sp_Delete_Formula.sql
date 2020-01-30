CREATE procedure sp_Delete_Formula(@ReportID Int ,@Formulatype Int ,@FormulaName nvarchar(50))
as
Delete From ReportFormula Where ReportID = @ReportID and Formulatype=@Formulatype and ColumnName=@FormulaName


