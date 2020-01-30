Create Procedure sp_Save_AdjustmentReason (@Reason nvarchar(255),
					   @Description nvarchar(255),
					   @Claimed Int)
As
Insert Into AdjustmentReason (Reason, Description, Claimed, Active)
Values (@Reason, @Description, @Claimed, 1)
Select @@Identity
