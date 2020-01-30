CREATE procedure mERP_Sp_Get_RecdMasterChanges_ITC
AS
Select C.ID,R.controlname,R.Active From tbl_mERP_RecdMstChangeDetail R,
tbl_mERP_RecdMstChangeAbstract C        
Where R.ID = C.ID And        
isnull(C.Status,0) = 0 and isnull(R.Status,0) = 0 
