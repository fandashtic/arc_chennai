Create Procedure mERP_sp_Get_DSPMetric_SlabCount(@PMetricID Int)
As
Begin
  Select Count(SlabID) From tbl_mERP_PMParamSlab PSlab, tbl_mERP_PMParam Param, tbl_mERP_PMDSType PMDS
  Where PMDS.DsTypeId = PAram.DSTypeID
    And Param.ParamID = PSlab.ParamID 
    And PMDS.PMID = 1 
End
