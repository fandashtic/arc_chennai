Create Procedure sp_updateDandDClaimData @ID int
AS
BEGIN
Declare @ClaimID int
Declare @RFAValue Decimal(18,6)
Declare @ClaimDate Datetime

Select @ClaimID = ClaimID, @ClaimDate = ClaimDate From DandDAbstract Where ID = @ID
Select @RFAValue = isnull(ClaimValue,0) From DandDAbstract Where ID = @ID
Update ClaimsNote Set ClaimValue=@RFAValue, Balance = @RFAValue, ClaimDate = @ClaimDate Where ClaimID = @ClaimID

/* If Destroyed */
IF (Select isnull(ClaimStatus,0) From DandDAbstract Where ID = @ID) = 3
BEGIN
Update ClaimsNote Set Status = 1 Where ClaimID = @ClaimID
END
Select 1
END
