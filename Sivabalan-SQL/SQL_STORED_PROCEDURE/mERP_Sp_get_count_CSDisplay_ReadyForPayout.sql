Create Procedure mERP_Sp_get_count_CSDisplay_ReadyForPayout
As
Begin
Declare @TranDate DateTime
Select Top 1 @TranDate = TransactionDate from SetUp
Select "Ready for Payout" = Count(PP.ID)
from tbl_mERP_SchemePayoutPeriod pp, tbl_mERP_SchemeAbstract SA
Where SA.SchemeType = 3 And SA.Active = 1
And SA.SchemeID = PP.SchemeID
And PP.Active = 1 And PP.Status & 128 = 0
And DATEDIFF(Day, PP.PayoutPeriodTo,@TranDate) > 0 And DATEDIFF(Day, PP.PayoutPeriodTo,@TranDate) <= 3
End
