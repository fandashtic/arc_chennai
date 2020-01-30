CREATE Procedure [dbo].[mERP_sp_InsertRecCustChannlDetail]    
 (@DocSerialID Int, @ChannelCode [nvarchar] (50), @Active  Int, @ChannelName nvarchar(100)= '')    
AS    
  Insert Into tbl_mERP_RecdChannlDetail (ID, ChannelCode, Active,ChannelName,Status)    
  Values (@DocSerialID, @ChannelCode, @Active,@ChannelName,0)      

