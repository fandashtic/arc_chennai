Create Procedure sp_display_AdjustmentReason (@AdjReasonID Int)
As
Select AdjReasonID, Reason, Description, Claimed, Active From AdjustmentReason
Where AdjReasonID = @AdjReasonID
