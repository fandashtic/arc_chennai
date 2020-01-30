Create Procedure mERP_sp_save_CSDisplay_PayoutPeriodwiseBudget(@SchemeID INT , @PayoutPeriodID INT)
As
Begin
  Declare @Count Int
  Set @Count = 0
  Declare @PayoutPrdID Int
  Declare DelPayout Cursor For
  Select ID from tbl_mERP_SchemePayoutPeriod Where 
  Active = 1 And 
  SchemeID = @SchemeID And 
  ID > @PayoutPeriodID And (Status & 128) = 0  And 
  ID Not In (Select PayoutPeriodID From tbl_mERP_DispSchBudgetPayout
  Where SchemeID = @SchemeID And 
  PayoutPeriodID > @PayoutPeriodID And
  CrNoteRaised = 1)
  Order by 1
  OPen DelPayout
  Fetch Next from DelPayout Into @PayoutPrdID
  While @@Fetch_Status = 0 
  Begin
    Set @Count = @Count + 1 
    Insert into tbl_mERP_DispSchBudgetPayout(SchemeID,CapPerOutletID,PayoutPeriodID, OutletCode,AllocatedAmount, PendingAmount)
	Select SchemeID,CapPerOutletID, @PayoutPrdID, OutletCode,AllocatedAmount,AllocatedAmount
    From tbl_mERP_DispSchBudgetPayout Where PayoutPeriodID = @PayoutPeriodID
	Fetch Next from DelPayout Into @PayoutPrdID
  End 
  Close DelPayout
  Deallocate DelPayout
  If @Count = 0
    Select 1
  Else
    Select Count(*) from tbl_mERP_DispSchBudgetPayout Where PayoutPeriodID > @PayoutPeriodID And SchemeID = @SchemeID
End
