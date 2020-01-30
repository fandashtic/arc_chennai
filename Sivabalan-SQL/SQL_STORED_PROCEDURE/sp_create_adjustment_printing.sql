Create Procedure sp_create_adjustment_printing
As
Select '"' + Reason + '" = ' + 'dbo.GetAdjustmentValue(@INVNO, ' + Cast(AdjReasonID As nvarchar) + ')' 
From AdjustmentReason

