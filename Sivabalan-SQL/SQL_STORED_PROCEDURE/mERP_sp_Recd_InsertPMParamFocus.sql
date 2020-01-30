Create Procedure mERP_sp_Recd_InsertPMParamFocus
(
@ParamID Int,
@ProdCode nVarchar(100),
@ProdLevel nVarchar(50),
@PMProductName nVarchar(500),
@Min_Qty decimal(18,6),
@UOM int,
@TargetThreshold decimal(18,6)
)
As
Begin
	Insert Into tbl_mERP_Recd_PMParamFocus(REC_ParamID,CPM_Product_Level,CPM_Product_Code,PMProductName,Min_Qty,UOM,TargetThreshold)
	Values(@ParamID,@ProdLevel,@ProdCode,@PMProductName,@Min_Qty,@UOM,@TargetThreshold)
End
