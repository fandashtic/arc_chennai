Create Procedure SP_get_ItemTaxCompDetails(@TaxCode int )
AS
BEGIN
	
	Select TC.TaxComponent_code, TCD.TaxComponent_desc,
		Case When TC.ComponentType = 1 Then 'Percentage' Else 'Amount' End As 'ComponentType',
		TC.Tax_percentage,
		TC.ApplicableOn As 'ApplicableOnComp',
		TAO.ApplicableOnDesc,
		Case When isnull(TC.ApplicableUOM,0) =1 Then 'Base UOM'
			When isnull(TC.ApplicableUOM,0) = 2 Then 'UOM1' 
			When isnull(TC.ApplicableUOM,0) = 3 Then 'UOM2' 
			When isnull(TC.ApplicableUOM,0) = 0 Then '' 
		End As 'ApplicableUOM',
		Case When Isnull(T.GSTFlag,0) =1 Then 
			Case When TC.CSTaxType = 1 Then 'Intra State' Else 'Inter State' End 
		Else 
			Case When TC.CSTaxType = 1 Then 'LST' Else 'CST' End 
		End As 'TaxType',
		GC.GSTComponentDesc As 'GSTComponentDesc',
		Case When isnull(TC.FirstPoint,0) = 1 Then 'Yes' Else 'No' End as FirstPoint       
	From Tax T Join TaxComponents TC on T.Tax_Code = TC.Tax_Code 
	Join TaxComponentDetail TCD on TC.TaxComponent_code  = TCD.TaxComponent_code 
	Left Join TaxApplicableOn TAO on TAO.ApplicableOnCode = TC.ApplicableOnCode 
	Left Join GSTComponent GC on GC.GSTComponentCode = TC.GSTComponentCode 
	Where TC.Tax_Code =	@TaxCode 
	Order By TC.CS_ComponentCode 
	
END
