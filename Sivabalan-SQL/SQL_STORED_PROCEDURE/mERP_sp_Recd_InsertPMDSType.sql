Create Procedure mERP_sp_Recd_InsertPMDSType
(
@PMID Int,
@DStype nVarchar(100) ,
@MaxPoints Decimal(18,6),
@CMP_DSTypeID Int
)
As
Begin
	Insert Into tbl_mERP_Recd_PMDSType(REC_PMID,CPM_DSType,CPM_MaxPoints,CPM_DSTypeID)
	Values(@PMID,@DStype,@MaxPoints,@CMP_DSTypeID)
	Select @@Identity
End
