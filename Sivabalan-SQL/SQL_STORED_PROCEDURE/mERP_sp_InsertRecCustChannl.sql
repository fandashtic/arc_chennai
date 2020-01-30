CREATE Procedure [dbo].[mERP_sp_InsertRecCustChannl]
AS
	Insert Into  tbl_mERP_RecdChannlAbstract (RecDate, Status) Values (GetDate(), 0)
	Select @@IDENTITY
