Create Procedure mERP_sp_save_CSDisplay_CrNotePayoutDefn(@SchemeID Int, @PayoutPeriodID Int, @CustomerID nVarchar(50), @PayoutAmt Decimal(18,6), @GenCrNote Int =0)
As
Begin
  If @GenCrNote =1
  Begin
	  If (Select PendingAmount - @PayoutAmt from tbl_mERP_DispSchBudgetPayout Where SchemeID = @SchemeID And   
		PayoutPeriodID = @PayoutPeriodID And     
		OutletCode = @CustomerID ) < 0 
		RAISERROR('Allocation exceeds the limit', 16, 1) 
  End
  Update tbl_mERP_DispSchBudgetPayout Set PayoutAmount = Case @GenCrNote When 1 Then 0 Else (@PayoutAmt) End,  
    PendingAmount = Case @GenCrNote When 1 then (PendingAmount - @PayoutAmt) Else PendingAmount End
  Where SchemeID = @SchemeID And 
    PayoutPeriodID = @PayoutPeriodID And   
    OutletCode = @CustomerID
  Select @@ROWCOUNT 
End 
