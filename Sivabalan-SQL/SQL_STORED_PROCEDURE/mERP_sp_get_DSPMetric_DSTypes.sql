Create Procedure mERP_sp_get_DSPMetric_DSTypes(@PMetricID int)
As
Begin
  Select PMDS.DsType, PMDS.MaxPoints, IsNull(DSM.DsTypeCode,N'') DsTypeCode, PMDS.DsTypeID 
  From tbl_mERP_PMDSType PMDS
  Left Outer Join DsType_Master DSM On PMDS.DsType = DSM.DSTypeValue 
  Where PMDS.PMID = @PMetricID And DSM.DSTypeCtlPos = 1 
  Order by PMDS.DsTypeID
End
