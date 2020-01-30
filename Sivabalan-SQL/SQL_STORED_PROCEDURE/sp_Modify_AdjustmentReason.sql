Create Procedure sp_Modify_AdjustmentReason (@ReasonID Int,
					     @Description nvarchar(255),
					     @Claimed Int,
					     @Active Int)
As
Update AdjustmentReason Set Description = @Description,
Claimed = @Claimed, Active = @Active Where AdjReasonID = @ReasonID
