Create Procedure SP_get_TaxCompSplitup(@TaxCode int, @TaxType int, @RegisterStatus int = 0)
AS
BEGIN
If (Select IsNull(CS_TaxCode,0) From Tax Where Tax_Code = @TaxCode) > 0
Select TC.TaxComponent_code, TCD.TaxComponent_desc,
Case When TC.ComponentType = 1 Then 'Percentage' Else 'Amount' End As 'ComponentType',
TC.Tax_percentage,
--		Case When isnull(TC.ApplicableonComp,0)  = 0 Then 'Price'
--			Else (Select TAC.TaxComponent_desc From TaxComponentDetail TAC
--					Where TAC.TaxComponent_desc = TC.ApplicableOn) End As 'ApplicableOnComp',
TC.ApplicableOn As 'ApplicableOnComp',
TAO.ApplicableOnDesc,
Case When isnull(TC.ApplicableUOM,0) =1 Then 'Base UOM'
When isnull(TC.ApplicableUOM,0) = 2 Then 'UOM1'
When isnull(TC.ApplicableUOM,0) = 3 Then 'UOM2'
When isnull(TC.ApplicableUOM,0) = 0 Then ''
End As 'ApplicableUOM',
--Case When TC.TaxType = 1 Then 'Intra State' Else 'Inter State' End As 'TaxType',
Case isnull(T.GSTFlag,0) When 0 Then (Case @TaxType When 2 then 'Outstation' ELSE 'Local' End)
Else (Case @TaxType When 2 Then 'Inter State' ELSE 'Intra State' End) End 'TaxType',
GC.GSTComponentDesc As 'GSTComponentDesc',
Case When isnull(TC.FirstPoint,0) = 1 Then 'Yes' Else 'No' End as FirstPoint
, Case When isnull(TC.RegisterStatus,0) = 1 Then 'Registered Only' When isnull(TC.RegisterStatus,0) = 2 Then 'UnRegistered Only' Else 'All' End As 'RegisterStatus'
From Tax T Join TaxComponents TC on T.Tax_Code = TC.Tax_Code
Join TaxComponentDetail TCD on TC.TaxComponent_code  = TCD.TaxComponent_code
Left Join TaxApplicableOn TAO on TAO.ApplicableOnCode = TC.ApplicableOnCode
Left Join GSTComponent GC on GC.GSTComponentCode = TC.GSTComponentCode
Where TC.Tax_Code =	@TaxCode and TC.CSTaxType = @TaxType
and (isnull(TC.RegisterStatus,0) =  0 or isnull(TC.RegisterStatus,0) = isnull(@RegisterStatus,0))
Order By TC.CS_ComponentCode --TC.CompLevel
Else
Select TC.TaxComponent_code, TCD.TaxComponent_desc,
Case When TC.ComponentType = 1 Then 'Percentage' Else 'Amount' End As 'ComponentType',
TC.Tax_percentage,
--		Case When isnull(TC.ApplicableonComp,0)  = 0 Then 'Price'
--			Else (Select TAC.TaxComponent_desc From TaxComponentDetail TAC
--					Where TAC.TaxComponent_desc = TC.ApplicableOn) End As 'ApplicableOnComp',
TC.ApplicableOn As 'ApplicableOnComp',
TAO.ApplicableOnDesc,
Case When isnull(TC.ApplicableUOM,0) =1 Then 'Base UOM'
When isnull(TC.ApplicableUOM,0) = 2 Then 'UOM1'
When isnull(TC.ApplicableUOM,0) = 3 Then 'UOM2'
When isnull(TC.ApplicableUOM,0) = 0 Then ''
End As 'ApplicableUOM',
--Case When TC.TaxType = 1 Then 'Intra State' Else 'Inter State' End As 'TaxType',
Case isnull(T.GSTFlag,0) When 0 Then (Case @TaxType When 2 then 'Outstation' ELSE 'Local' End)
Else (Case @TaxType When 2 Then 'Inter State' ELSE 'Intra State' End) End 'TaxType',
GC.GSTComponentDesc As 'GSTComponentDesc',
Case When isnull(TC.FirstPoint,0) = 1 Then 'Yes' Else 'No' End as FirstPoint
, Case When isnull(TC.RegisterStatus,0) = 1 Then 'Registered Only' When isnull(TC.RegisterStatus,0) = 2 Then 'UnRegistered Only' Else 'All' End As 'RegisterStatus'
From Tax T Join TaxComponents TC on T.Tax_Code = TC.Tax_Code
Join TaxComponentDetail TCD on TC.TaxComponent_code  = TCD.TaxComponent_code
Left Join TaxApplicableOn TAO on TAO.ApplicableOnCode = TC.ApplicableOnCode
Left Join GSTComponent GC on GC.GSTComponentCode = TC.GSTComponentCode
Where TC.Tax_Code =	@TaxCode and IsNull(TC.LST_Flag,0) = Case When @TaxType = 1 Then 1 Else 0 End
and (isnull(TC.RegisterStatus,0) =  0 or isnull(TC.RegisterStatus,0) = isnull(@RegisterStatus,0))
Order By TC.CS_ComponentCode  --TC.CompLevel
END
