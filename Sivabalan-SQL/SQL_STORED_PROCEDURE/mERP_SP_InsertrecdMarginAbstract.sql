Create Procedure mERP_SP_InsertrecdMarginAbstract  (@DocumentID nVarchar(100), @ReceivedDate nVarchar(255), @FromCompanyID nVarchar(255))
As
Insert Into tbl_mERP_RecdMarginAbstract ( DocumentID, ReceivedDate, CompanyID)
Values (@DocumentID, @ReceivedDate, @FromCompanyID)
Select @@IDENTITY
