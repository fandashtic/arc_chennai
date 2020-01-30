Create Procedure [dbo].[sp_Insert_RecdMerchandise] (@MerchandiseName nvarchar(50),
@Active Int,@DocumentTrackerID Int)
As
Insert Into tbl_merp_RecdMerchandise (MerchandiseName,Active,CreationDate,Status,DocumentTrackerID,RecFlag)
Values (@MerchandiseName, @Active,Getdate(),0,@DocumentTrackerID,0)
Select @@Identity
