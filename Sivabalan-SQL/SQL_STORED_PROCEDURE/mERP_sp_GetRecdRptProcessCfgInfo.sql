Create Procedure mERP_sp_GetRecdRptProcessCfgInfo
AS
Select IsNull(RecdID,0) from tbl_merp_RecdRptTrackerConfigAbs where IsNull(Status,0) = 0 
