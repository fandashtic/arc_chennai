CREATE Procedure sp_list_InvAdjustments
As
Select AdjustmentReference.AdjustmentReasonID, dbo.lookupdictionaryItem( AdjustmentReason.Reason,default) as Reason,
Sum(Case AdjustmentReference.DocumentType
When 5 Then
0 - Balance
Else
Balance
End) From AdjustmentReference, AdjustmentReason
Where AdjustmentReference.AdjustmentReasonID = AdjustmentReason.AdjReasonID And
IsNull(AdjustmentReference.Status, 0) & 128 = 0 And
IsNull(AdjustmentReference.Balance, 0) <> 0 And
AdjustmentReason.Claimed = 1 And
AdjustmentReason.Active = 1
Group By AdjustmentReference.AdjustmentReasonID, AdjustmentReason.Reason

