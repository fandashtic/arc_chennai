Create Procedure mERP_sp_InsertRecdRptProcessCfg (@RecdID int=0, @ReportName nVarchar(2000)= NULL, @ArchiveCnt int, @Active int)
As
Insert into tbl_merp_RecdRptTrackerConfigDet ( RecdID, ReportName, ArchiveCount, Active) 
Values (@RecdID, @ReportName, @ArchiveCnt, @Active)
