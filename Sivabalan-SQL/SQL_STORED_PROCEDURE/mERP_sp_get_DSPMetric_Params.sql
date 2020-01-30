Create Procedure mERP_sp_get_DSPMetric_Params(@DSTypeID Int)
As
Begin
Select Distinct ParamMas.ParamType,
ParamFocus.PMProductName As ParamFocus,
Case ParamMas.ID When 3 Then Cast(ParamDet.MaxPoints as nVarchar(50)) when 6 Then Cast(ParamDet.MaxPoints as nVarchar(50))
when 8 Then Cast(ParamDet.MaxPoints as nVarchar(50)) when 9 Then Cast(ParamDet.MaxPoints as nVarchar(50))
when 1 Then Cast(ParamDet.MaxPoints as nVarchar(50)) when 2 Then Cast(ParamDet.MaxPoints as nVarchar(50))
when 12 Then Cast(ParamDet.MaxPoints as nVarchar(50))
when 13 Then Cast(ParamDet.MaxPoints as nVarchar(50))
Else '' End MaxPoints,
ParamDet.ParamID, --ParamFocus.FocusID,
Case IsNull(isFocusParameter,0) When 0 Then 0 Else ParamFocus.ProdCat_Level End ParamFocusLevel,
Paramdet.ParameterType,ParamDet.DSTypeid,ParamMas.OrderBy
, Case ParamMas.ID When 3 Then Cast(ParamDet.Cutoff_Percentage as nVarchar(50)) Else '' End 'CutoffPercentage',
Case ParamMas.ParamType When 'Business Achievement' Then
Case IsNull(ParamDet.TargetParameterType,0)  When 0 Then 'Calculated'
When 1 Then 'Absolute'
Else '' End
When 'Gate-UOB' Then
Case IsNull(ParamDet.TargetParameterType,0)  When 0 Then 'Calculated'
When 1 Then 'Absolute'
When 2 Then 'Mixed-Lesser'
When 3 Then 'Mixed-Greater'
When 4 Then 'Growth'
Else '' End
Else '' End TargetType
From  tbl_mERP_PMParamType ParamMas, tbl_mERP_PMParam ParamDet, tbl_mERP_PMParamFocus ParamFocus
Where ParamMas.ID = ParamDet.ParameterType
And ParamDet.ParamID = ParamFocus.ParamID
And ParamDet.DSTypeID = @DSTypeID
Order by ParamMas.OrderBy --, Case IsNull(isFocusParameter,0) When 0 Then 0 Else ParamFocus.FocusID End
End
