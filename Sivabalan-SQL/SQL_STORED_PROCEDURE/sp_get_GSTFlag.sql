CREATE Procedure sp_get_GSTFlag(@TaxID int)  
As
Begin

	SELECT IsNull(CS_TaxCode, 0) CSTaxCode, isnull(GSTFlag,0) GSTFlag FROM Tax WHERE Tax_Code = @TaxID

End
