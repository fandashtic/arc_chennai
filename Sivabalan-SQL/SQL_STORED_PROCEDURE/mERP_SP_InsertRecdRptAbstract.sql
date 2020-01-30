Create Procedure mERP_SP_InsertRecdRptAbstract(@DocumentID nVarchar(100), @ReceivedDate nVarchar(255), @FromCompanyID nVarchar(255))
As
Begin
	Insert Into tbl_mERP_RecdRptAckAbstract ( DocumentID, ReceivedDate, CompanyID)
	Values (@DocumentID, @ReceivedDate, @FromCompanyID)
	Select @@IDENTITY
End
