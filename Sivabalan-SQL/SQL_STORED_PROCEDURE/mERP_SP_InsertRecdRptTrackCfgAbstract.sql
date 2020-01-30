Create Procedure mERP_SP_InsertRecdRptTrackCfgAbstract (@DocumentID nVarchar(100), @ReceivedDate DateTime, @FromCompanyID nVarchar(255))
As
Insert Into tbl_merp_RecdRptTrackerConfigAbs (DocumentID, RecdDateTime, CompanyID)
Values (@DocumentID, @ReceivedDate, @FromCompanyID)
Select @@IDENTITY
