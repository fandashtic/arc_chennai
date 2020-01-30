Create Procedure mERP_sp_Update_CSDisplay_PayoutPeriodStatus(@SchemeID Int, @PayoutPeriodID Int)
As
Begin
  Update tbl_merp_SchemePayoutPeriod Set Status = Status | 128 Where SchemeID =@SchemeID And ID = @PayoutPeriodID
  Update tbl_mERP_SchemeAbstract Set PayoutStatus = PayoutStatus | 128 Where SchemeID = @SchemeID
End 
