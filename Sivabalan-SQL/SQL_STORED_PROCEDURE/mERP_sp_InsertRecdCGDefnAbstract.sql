Create Procedure mERP_sp_InsertRecdCGDefnAbstract (@DocumentID nVarchar(100), @ReceivedDate nVarchar(255), @FromCompanyID nVarchar(255))
As
Insert Into tbl_mERP_RecdCGDefnAbstract ( DocumentID, ReceivedDate, CompanyID)
Values (@DocumentID, @ReceivedDate, @FromCompanyID)
Select @@IDENTITY
