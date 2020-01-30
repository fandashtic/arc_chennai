CREATE Procedure sp_get_TaxAbstract(@TaxID int, @TaxType int)  
As
Begin
	Select Tax_Description, 
		CS_TaxCode,
		Case @TaxType When 2 Then  ISNULL(Tax.CST_Percentage, 0) Else ISNULL(Tax.Percentage, 0) End 'TaxRate',
        Case isnull(Tax.GSTFlag,0) When 0 Then (Case @TaxType When 2 then 'Outstation' ELSE 'Local' End)
			Else (Case @TaxType When 2 Then 'Inter State' ELSE 'Intra State' End) End 'TaxType',
		--isnull(EffectiveFrom,'') as EffectiveFrom
		EffectiveFrom
	From Tax Where Tax_Code = @TaxID
End
