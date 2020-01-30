Create Procedure SP_get_TaxCompSplitup_Serviceinvoice(@TaxCode int, @TaxType int, @TaxableVal Decimal(18,6))
AS
BEGIN
Select TCD.TaxComponent_desc,
Convert(Decimal(18,2),TC.Tax_percentage) as TaxPercentage,
TC.ApplicableOn As 'ApplicableOnComp',
Case @TaxType When 1 Then 'Intra State' ELSE 'Inter State'  End 'TaxType'
, "CompTaxAmt" = Convert(Decimal(18,2),@TaxableVal * TC.Tax_percentage / 100)
From Tax T Join TaxComponents TC on T.Tax_Code = TC.Tax_Code
Join TaxComponentDetail TCD on TC.TaxComponent_code  = TCD.TaxComponent_code
Where TC.Tax_Code = @TaxCode --and LST_Flag=@Taxtype
And CSTaxType = Case When @Taxtype = 1 Then 1 Else 2 End
END
