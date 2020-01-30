Create Procedure mERP_sp_InsertSchemeSlab
(
@SchemeID int,
@Group Int,
@SlabType int,
@UOM  int,
@slabStart  Decimal(18,6),
@SlabEnd  Decimal(18,6),
@Onward  Decimal(18,6),
@Value Decimal(18,6),
@FreeUOM int,
@Volume Decimal(18,6),
@SKUCode nVarchar(4000),
@Unitrate Decimal(18,6)
)
As
Insert into tbl_mERP_RecdSchSlabDetail( CS_SchemeID, CS_Group,  CS_SlabType, CS_UOM, CS_SlabStart, CS_SlabEnd, 
CS_Onward, CS_Value, CS_FreeUOM, CS_Volume, CS_SKUCode, CS_UnitRate )
Values (@SchemeID, @Group,  @SlabType, @UOM, @slabStart, @SlabEnd, @Onward, @Value, @FreeUOM, @Volume, @SKUCode,
@Unitrate)
