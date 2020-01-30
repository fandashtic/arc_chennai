Create Procedure mERP_SP_GetRecdDSTlist
AS
Select IsNull(ID,0) from tbl_mERP_RecdDSTrainingAbstract where IsNull(Status,0) = 0 
