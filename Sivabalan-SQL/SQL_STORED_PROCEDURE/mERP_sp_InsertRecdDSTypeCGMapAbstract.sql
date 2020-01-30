Create Procedure mERP_sp_InsertRecdDSTypeCGMapAbstract(@DocumentID nVarchar(100), @ReceivedDate nVarchar(255), @FromCompanyID nVarchar(255))
As
	Insert Into RecdDoc_DSTypeCGCategoryMap(DocumentID, ReceivedDate, CompanyID)
	Values (@DocumentID, @ReceivedDate, @FromCompanyID)
	Select @@IDENTITY
