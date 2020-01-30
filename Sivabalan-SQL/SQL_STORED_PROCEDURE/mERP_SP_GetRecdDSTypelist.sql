Create Procedure mERP_SP_GetRecdDSTypelist
AS
Select ID from tbl_mERP_RecdDSTypeCGAbstract where IsNull(Status,0) = 0
