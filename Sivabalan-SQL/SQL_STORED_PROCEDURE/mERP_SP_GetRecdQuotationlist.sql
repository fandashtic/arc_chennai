Create Procedure mERP_SP_GetRecdQuotationlist
AS
Select Isnull(ID,0) from tbl_mERP_RecdQuotationAbstract where isNull(Status,0) = 0
