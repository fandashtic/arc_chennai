Create Procedure mERP_sp_get_ReceivedSchemes
AS
Select CS_SchemeID From tbl_mERP_RecdSchAbstract Where IsNull(CS_Flag,0) & 96 = 0
Order by CS_RecSchID
