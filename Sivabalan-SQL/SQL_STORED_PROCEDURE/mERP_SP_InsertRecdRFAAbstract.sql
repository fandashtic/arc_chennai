Create Procedure mERP_SP_InsertRecdRFAAbstract  (@DocumentID nVarchar(100), @ReceivedDate nVarchar(255), @FromCompanyID nVarchar(255))
As
Insert Into tbl_mERP_RecdRFAckAbstract ( DocumentID, ReceivedDate, CompanyID)
Values (@DocumentID, @ReceivedDate, @FromCompanyID)
Select @@IDENTITY
