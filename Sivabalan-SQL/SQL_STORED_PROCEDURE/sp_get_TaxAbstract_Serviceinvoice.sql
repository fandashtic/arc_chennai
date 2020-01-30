CREATE Procedure sp_get_TaxAbstract_Serviceinvoice(@TaxID int, @TaxType int)
As
Begin
Select Tax_Description,

Case @TaxType When 0 Then  Cast(ISNULL(Tax.CST_Percentage, 0) as decimal(18,2))  Else Cast(ISNULL(Tax.Percentage, 0) as decimal(18,2)) End 'TaxRate' ,
--        Case isnull(Tax.GSTFlag,0) When 0 Then (Case @TaxType When 2 then 'Outstation' ELSE 'Local' End)
Case @TaxType When 1 Then 'Intra State' ELSE 'Inter State' End 'TaxType'
--		isnull(EffectiveFrom,'') as EffectiveFrom
From Tax Where Tax_Code = @TaxID
End
