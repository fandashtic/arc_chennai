Create Procedure mERP_SP_GetRecdAElist
AS
Select Isnull(RecdID,0) from tbl_mERP_RecdAELoginAbstract where isNull(Status,0) = 0
