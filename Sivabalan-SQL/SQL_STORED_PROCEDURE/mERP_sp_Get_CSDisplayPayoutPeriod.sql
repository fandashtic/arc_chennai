Create Procedure mERP_sp_Get_CSDisplayPayoutPeriod(@SchemeID Int, @Mode Int = 0)
As
Begin
IF @Mode = 2 
  Select ID, PayoutPeriodFrom, PayoutPeriodTo from tbl_mERP_SchemePAyoutPeriod
  Where SchemeID = @SchemeID And Active = 1 And 
  PayoutPeriodTo < (Select Top 1 TransactionDate from SetUp)
  Order By 1
Else IF @Mode = 1 
  Select ID, PayoutPeriodFrom, PayoutPeriodTo from tbl_mERP_SchemePAyoutPeriod
  Where SchemeID = @SchemeID And Active = 1 
  Order By 1
Else
  Select ID, PayoutPeriodFrom, PayoutPeriodTo from tbl_mERP_SchemePAyoutPeriod
  Where SchemeID = @SchemeID
  Order By 1
End
