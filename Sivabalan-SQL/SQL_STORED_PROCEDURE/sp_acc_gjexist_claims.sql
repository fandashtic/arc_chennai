
CREATE procedure sp_acc_gjexist_claims
As
DECLARE @ClaimID Int
Declare @Status Int

DECLARE ScanClaimTransaction CURSOR KEYSET FOR
Select ClaimID, status from ClaimsNote

Open ScanClaimTransaction
FETCH FROM ScanClaimTransaction INTO @ClaimId, @Status
WHILE @@FETCH_STATUS = 0
BEGIN

	If (@Status & 64)=0  --not cancelled
	Begin
		Execute sp_acc_gj_Claims @ClaimID
	End
	Else
	Begin
		Execute sp_acc_gj_Claims @ClaimID --Dispatch entry before cancellation
		Execute sp_acc_gj_CloseClaims @ClaimID --Cancellation entry
	End
	FETCH NEXT FROM ScanClaimTransaction INTO @ClaimId,@Status
END
CLOSE ScanClaimTransaction
DEALLOCATE ScanClaimTransaction




