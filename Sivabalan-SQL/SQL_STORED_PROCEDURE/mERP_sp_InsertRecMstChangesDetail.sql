CREATE Procedure [dbo].[mERP_sp_InsertRecMstChangesDetail]    
 (@DocSerialID Int, @controlname [varchar] (100), @Active  Int)    
AS    
  Insert Into tbl_mERP_RecdMstChangeDetail (ID, controlname, Active,Status)    
  Values (@DocSerialID, @controlname, @Active,0)    
