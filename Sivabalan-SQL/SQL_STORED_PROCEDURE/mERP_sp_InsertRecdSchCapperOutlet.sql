Create Procedure mERP_sp_InsertRecdSchCapperOutlet
( @SchemeID nVarchar(4000)=NULL,   
 @CapChannel nVarchar(4000)=NULL,   
 @CapOutlettype  nVarchar(4000)=NULL,   
 @CapsuboutletType  nVarchar(4000)=NULL,   
 @Capperoutlet Decimal(18,6)
)
As
Insert Into tbl_mERP_RecdDispSchCapPerOutlet (CS_SchemeID, CS_Channel, CS_OutletType, CS_SubOutletType, CS_CapPerOutlet)	
Values (@SchemeID, @CapChannel, @CapOutlettype, @CapsuboutletType, @Capperoutlet)
