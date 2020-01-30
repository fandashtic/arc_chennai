Create Procedure mERP_sp_InsertRecdSchOutletScope
(
@SchemeID int,
@Channel nVarchar(4000),
@OutletClass nVarchar(4000),
@Outlets nVarchar(4000),
@Qps int,
@group int,
@Loyaltylist nVarchar(4000),
@SubGroupID int
)
As

If (IsNull(@Channel,'') = '')
 Set @Channel = 'ALL'

If (IsNull(@OutletClass,'')= '')
	Set @OutletClass ='ALL'

If (IsNull(@Outlets,'')= '')
	Set @Outlets ='ALL'

If (IsNull(@Loyaltylist,'')= '')
	Set @Loyaltylist ='ALL'


Insert Into tbl_mERP_RecdSchOutlet
(CS_SchemeID,CS_Group, CS_OutletID, CS_QPS, CS_SubGroupID)
Values(@SchemeID, @Group, @Outlets, @Qps, @SubGroupID )

If (IsNull(@Channel,'') <> '')
begin
Insert Into tbl_mERP_RecdSchChannel(CS_SchemeID, CS_Channel, CS_Group, CS_SubGroupID)
values(@SchemeID, @Channel, @Group, @SubGroupID)
End

If (IsNull(@OutletClass,'') <> '')
begin
Insert Into tbl_mERP_RecdSchOutletClass(CS_SchemeID, CS_OutletClass, CS_Group, CS_SubGroupID)
values(@SchemeID, @OutletClass, @Group, @SubGroupID)
End

If (IsNull(@Loyaltylist,'') <> '')
begin
Insert Into tbl_mERP_RecdSchLoyaltyList(CS_SchemeID, CS_LoyaltyList, CS_Group, CS_SubGroupID)
values(@SchemeID, @Loyaltylist, @Group, @SubGroupID)
End
