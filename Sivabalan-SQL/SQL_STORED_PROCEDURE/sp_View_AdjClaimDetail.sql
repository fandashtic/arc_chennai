Create Procedure sp_View_AdjClaimDetail (@ClaimID Int)
As
Select ClaimsDetail.AdjReasonID, AdjustmentReason.Reason,
ClaimsDetail.AdjustedAmount From ClaimsDetail, AdjustmentReason
Where ClaimsDetail.ClaimID = @ClaimID And
ClaimsDetail.AdjReasonID = AdjustmentReason.AdjReasonID
