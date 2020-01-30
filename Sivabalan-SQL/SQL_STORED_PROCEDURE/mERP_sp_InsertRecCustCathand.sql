CREATE Procedure [dbo].[mERP_sp_InsertRecCustCathand]
AS
	Insert Into  tbl_mERP_RecdCatHandAbstract (RecDate, Status) Values (GetDate(), 0)
	Select @@IDENTITY
