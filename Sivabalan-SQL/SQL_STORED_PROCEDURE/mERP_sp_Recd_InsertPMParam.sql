Create Procedure mERP_sp_Recd_InsertPMParam
(
@DSID Int,
@XMLDSID Int,
@Frequency nVarchar(10),
@MaxPoints Decimal(18,6),
@ParamType nVarchar(50),
@FocusParam nVarchar(10),
@GrowthPercentage Decimal(18,6),
@CMP_ParamID Int,
@Cutoff_Percentage Decimal(18,6),
@Dependent_CPM_ParamID int,
@Dependent_Cutoff Decimal(18,6),
@TargetParameterType int,
@ComparisonType int
)
As
Begin
Insert Into tbl_mERP_Recd_PMParam(REC_DSID,CPM_DSID,CPM_Frequency,CPM_MaxPoints,CPM_ParameterType,CPM_isFocusParameter,
GrowthPercentage,CPM_ParamID,Cutoff_Percentage,Dependent_CPM_ParamID,Dependent_Cutoff,TargetParameterType,ComparisonType)
Values(@DSID,@XMLDSID ,@Frequency,@MaxPoints,@ParamType,@FocusParam,@GrowthPercentage,@CMP_ParamID,@Cutoff_Percentage,
@Dependent_CPM_ParamID,@Dependent_Cutoff,@TargetParameterType,@ComparisonType)
Select @@Identity
End
