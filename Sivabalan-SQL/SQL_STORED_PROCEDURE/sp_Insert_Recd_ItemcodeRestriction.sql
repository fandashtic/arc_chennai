Create Procedure [dbo].[sp_Insert_Recd_ItemcodeRestriction] (@ItemCode nvarchar(30),
@Active Int,@DocumentTrackerID Int)
As
Insert Into tbl_merp_RecdItemCodeRestricted (Product_Code,Active,CreationDate,Status,DocumentTrackerID)
Values (@ItemCode, @Active,Getdate(),0,@DocumentTrackerID)
Select @@Identity
