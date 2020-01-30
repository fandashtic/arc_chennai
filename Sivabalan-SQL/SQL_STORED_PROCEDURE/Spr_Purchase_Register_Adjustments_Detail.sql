Create Procedure Spr_Purchase_Register_Adjustments_Detail (@BillID As Int)
As
Select AdjRefID, "Adjustment Reason" = Reason, "Account" = am.AccountName, "Amount" = aref.Amount
From AdjustmentReason ar, AdjustmentReference aref, AccountsMaster am Where 
ar.AdjReasonID = aref.AdjustmentReasonID And ar.AccountID = am.AccountID
And aref.InvoiceID = @BillID And aref.TransactionType = 1


