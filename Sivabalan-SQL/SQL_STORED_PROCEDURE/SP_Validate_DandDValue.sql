Create Procedure SP_Validate_DandDValue @ID int, @RFAValue Decimal(18,6)
AS
BEGIN
Declare @DandDAbs_RFAValue Decimal(18,6)
Declare @DandDDet_RFAValue Decimal(18,6)

Select @DandDAbs_RFAValue = isnull(ClaimValue,0) From DandDAbstract Where ID=@ID
Select @DandDDet_RFAValue = Sum(isnull(BatchRFAValue,0)) From DandDDetail Where ID=@ID

IF (Floor(@RFAValue) = Floor(@DandDAbs_RFAValue))
And (Floor(@RFAValue) = Floor(@DandDDet_RFAValue))
Select 0
Else
Select 1

END
