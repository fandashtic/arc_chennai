Create Procedure mERP_sp_Recd_InsertPMParamSlab
(
@ParamID Int,
@SlabUom nVarchar(50),
@SlabStart Decimal(18,6),
@SlabEnd Decimal(18,6),
@SlabOnward Decimal(18,6),
@GivenAs nVarchar(50),
@SlabValue Decimal(18,6),
@AbsoluteTarget Decimal(18,6)
)
As
Begin
	Insert Into tbl_mERP_Recd_PMParamSlab(REC_ParamID,SLAB_UOM,SLAB_START,SLAB_END,SLAB_EVERY_QTY,SLAB_GIVEN_AS,SLAB_VALUE,AbsoluteTarget)
	Values(@ParamID,@SlabUom,@SlabStart,@SlabEnd,@SlabOnward,@GivenAs,@SlabValue,@AbsoluteTarget)
End
