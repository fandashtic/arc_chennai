Create Procedure mERP_sp_UpdateRFAStatus(@ClaimType Int, @SchemeID Int, @PayoutId Int,  @ClaimID Int)
As
Begin
If IsNull(@ClaimType,0) = 10
Begin
	Update CreditNote Set ClaimRFA = 1 Where CreditID = @SchemeID
	Update ClaimsNote Set ClaimRFA = 1 Where ClaimID = @ClaimID
End
Else
Begin
	Update tbl_mERP_SchemePayoutPeriod Set ClaimRFA = 1 Where SchemeID = @SchemeID And ID = @PayoutId
	Update ClaimsNote Set ClaimRFA = 1 Where ClaimID = @ClaimID
End
End
