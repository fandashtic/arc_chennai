Create Procedure mERP_sp_Get_DSPMetric_SalesmanTargetID(@Salesman nVarchar(255), @ParamId Int)
As
Begin
  Select PMTar.TargetDefnID 
  From tbl_mERP_PMetric_TargetDefn PMTar, Salesman SM, tbl_mERP_PMDSType PMDS, tbl_mERP_PMParamFocus PMFocus, tbl_mERP_PMParam PMparam
  Where SM.Salesman_Name = @Salesman
  And SM.SalesmanID = PMTar.SalesmanID 
  And PMDS.DSTypeID = PMTar.PMDSTypeID
  And PMFocus.FocusID = PMTar.FocusID
  And PMparam.ParamID = PMTar.ParamID
  And PMtar.ParamID = @ParamId
  And PMtar.Active = 1 
End
