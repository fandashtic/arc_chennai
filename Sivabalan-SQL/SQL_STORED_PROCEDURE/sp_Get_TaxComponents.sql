Create Procedure sp_Get_TaxComponents (@TaxID int,@TaxType Int)
As
Begin
Select * From TaxComponents TC
Where Tax_Code = @TaxID And CSTaxType = @TaxType
Order By CompLevel
End
