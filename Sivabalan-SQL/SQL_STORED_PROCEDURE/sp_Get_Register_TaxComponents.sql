Create Procedure sp_Get_Register_TaxComponents (@TaxID int,@TaxType Int,@RegisteredFlag int)
As
Begin
Select * From TaxComponents TC
Where Tax_Code = @TaxID And CSTaxType = @TaxType
and (isnull(RegisterStatus,0) =  0 or isnull(RegisterStatus,0) = isnull(@RegisteredFlag,0))
Order By CompLevel
End
