Create Procedure mERP_sp_get_DSPMetric_ParamSlab(@ParamID as Int)
As
Begin
Select PMFrq.Frequency, Case PMPrm.ParameterType When 3 Then N'Percentage' When 6 Then N'Percentage' When 8 Then N'Percentage' Else N'Points' End as UOM,
PMSlab.Slab_Start, PMSlab.Slab_End, PMSlab.Slab_Every_Qty, Case PMPrm.ParameterType When 3 Then N'Percentage' When 6 Then N'Percentage' When 8 Then N'Percentage'  Else N'Points' End as GivenAS,
PMSlab.Slab_Value,
IsNull(PMSlab.AbsoluteTarget,0) As AbsoluteTarget, PMPrm.ParameterType, Isnull(PMPrm.TargetParameterType,0) As TargetParameterType,
Case PMPrm.ParameterType When 10 Then Cast(PMPrm.Cutoff_Percentage as nVarchar(50)) Else '' End 'GrowthPercentage',
Isnull(PMPrm.ComparisonType,0) As ComparisonType
From tbl_mERP_PMFrequency PMFrq, tbl_mERP_PMGivenAs PMGAs, tbl_mERP_PMParamSlab PMSlab, tbl_mERP_PMParam PMPrm
Where PMSlab.Slab_Given_AS = PMGAs.ID
And PMPrm.ParamID = PMSlab.ParamID
And PMSlab.ParamID = @ParamID
And PmPrm.Frequency = PMFrq.ID
Order by 3
End
