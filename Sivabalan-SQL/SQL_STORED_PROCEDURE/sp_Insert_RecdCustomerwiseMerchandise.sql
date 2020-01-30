Create Procedure [dbo].[sp_Insert_RecdCustomerwiseMerchandise] (@CustomerID nVarchar(15),@MerchandiseName nvarchar(50),
@Active Int,@DocumentTrackerID Int)
As
Insert Into tbl_merp_RecdCustomerwiseMerchandise (CustomerID,MerchandiseName,Active,CreationDate,Status,DocumentTrackerID,RecFlag)
Values (@CustomerID,@MerchandiseName, @Active,Getdate(),0,@DocumentTrackerID,0)
Select @@Identity
