CREATE Procedure [dbo].[mERP_sp_InsertRecMstChanges]
AS
Insert Into  tbl_mERP_RecdMstChangeAbstract (RecDate, Status) Values (GetDate(), 0)
Select @@IDENTITY
