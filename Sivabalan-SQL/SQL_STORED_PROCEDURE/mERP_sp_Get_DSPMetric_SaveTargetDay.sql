Create Procedure mERP_sp_Get_DSPMetric_SaveTargetDay
As
Begin
  Select IsNull(CfgDet.Value,0) 
  From tbl_merp_configAbstract CfgAbs, tbl_merp_configDetail CfgDet
  Where CfgDet.ScreenCode = 'PMSTDT01'
  And CfgAbs.ScreenCode = CfgDet.ScreenCode 
  And CfgDet.Flag = 1
  And CfgAbs.Flag = 1
End
