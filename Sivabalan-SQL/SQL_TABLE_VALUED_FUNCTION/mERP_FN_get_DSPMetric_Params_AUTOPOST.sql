Create Function mERP_FN_get_DSPMetric_Params_AUTOPOST(@DSTypeID Int)  
Returns  @Result Table(ParamType nvarchar(50),PMProductName nvarchar(500),
MaxPoints nvarchar(50),ParamID int,ParamFocusLevel int,ParameterType int,DSTypeid int,OrderBy int)
As
Begin
insert into @Result
  Select Distinct ParamMas.ParamType, 
  ParamFocus.PMProductName As ParamFocus,
  Case ParamMas.ID When 3 Then Cast(ParamDet.MaxPoints as nVarchar(50)) Else '' End MaxPoints,
  ParamDet.ParamID, --ParamFocus.FocusID,
  Case IsNull(isFocusParameter,0) When 0 Then 0 Else ParamFocus.ProdCat_Level End ParamFocusLevel, Paramdet.ParameterType,ParamDet.DSTypeid,ParamMas.OrderBy 
  From  tbl_mERP_PMParamType ParamMas, tbl_mERP_PMParam ParamDet, tbl_mERP_PMParamFocus ParamFocus 
  Where ParamMas.ID = ParamDet.ParameterType
  And ParamDet.ParamID = ParamFocus.ParamID   
  And ParamDet.DSTypeID = @DSTypeID
  Order by ParamMas.OrderBy --, Case IsNull(isFocusParameter,0) When 0 Then 0 Else ParamFocus.FocusID End
Return
End
