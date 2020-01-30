CREATE Procedure [dbo].[mERP_sp_InsertRecCustCat]
AS
Insert Into  tbl_mERP_RecdCatAbstract (RecDate, Status) Values (GetDate(), 0)
Select @@IDENTITY
