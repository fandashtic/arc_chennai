Create Procedure mERP_SP_GetRecdMarginlist
AS
Select Isnull(ID,0) from tbl_mERP_RecdMarginAbstract where isNull(Status,0) = 0 order by id
