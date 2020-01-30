Create Procedure mERP_sp_Get_CSDisplayPayoutPeriod_Points(@SchemeID Int)
As
Begin
  Select ID, PayoutPeriodFrom, PayoutPeriodTo from tbl_mERP_SchemePAyoutPeriod
  Where SchemeID = @SchemeID And Active = 1 
  Order By PayoutPeriodFrom
End
