Create Procedure mERP_SP_InsertRecdOLClassAbstract  (@DocumentID nVarchar(100), @ReceivedDate nVarchar(255), @FromCompanyID nVarchar(255))
As
Insert Into tbl_mERP_RecdOLClassAbstract ( DocumentID, ReceivedDate, CompanyID)
Values (@DocumentID, @ReceivedDate, @FromCompanyID)
Select @@IDENTITY
