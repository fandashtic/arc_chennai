Create Procedure mERP_sp_Update_TaxDesc(@TaxCode int,@TaxDesc nVarchar(255))
As
Begin
Update Tax Set Tax_Description = @TaxDesc Where Tax_Code = @TaxCode
End
