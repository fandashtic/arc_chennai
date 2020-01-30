Create Procedure mERP_sp_Delete_CSDisplay_AdjacentPayouts(@SchemeId Int, @PayoutPeriodID Int)  
As  
Begin  
  Declare @PayoutPrdID Int  
  Declare DelPayout Cursor For  
  Select PP.ID from tbl_mERP_DispSchBudgetPayout BP, tbl_mERP_SchemePayoutPeriod PP  
  Where PP.ID = BP.PayoutPeriodID And   
   PP.Active = 1 And   
   PP.SchemeID = @SchemeId And   
   BP.PayoutPeriodID >= @PayoutPeriodID And   
   IsNull(BP.CrNoteRaised,0) = 0  
  Order by 1  
  OPen DelPayout  
  Fetch Next from DelPayout Into @PayoutPrdID  
  While @@Fetch_Status = 0   
  Begin  
    Delete From tbl_mERP_DispSchBudgetPayout Where PayoutPeriodID = @PayoutPrdID And SchemeID = @SchemeId  
    Fetch Next from DelPayout Into @PayoutPrdID  
  End   
  Close DelPayout  
  Deallocate DelPayout  
End 
