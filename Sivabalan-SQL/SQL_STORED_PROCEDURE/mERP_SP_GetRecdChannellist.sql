Create Procedure mERP_SP_GetRecdChannellist
As
Select ID from tbl_mERP_RecdOLClassAbstract where IsNull(Status,0) = 0
