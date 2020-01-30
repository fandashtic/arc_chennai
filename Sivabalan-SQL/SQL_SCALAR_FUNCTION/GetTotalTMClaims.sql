CREATE FUNCTION GetTotalTMClaims(@ITEMCODE nvarchar(15), @FROMDATE datetime, @TODATE datetime)
RETURNS decimal(18,6)
AS
BEGIN
	RETURN IsNull((Select Sum(Quantity) From ClaimsNote, ClaimsDetail
		Where ClaimsNote.ClaimID = ClaimsDetail.ClaimID And
		ClaimsNote.ClaimDate Between @FROMDATE And @TODATE And
		Product_Code = @ITEMCODE And ClaimType = 4 And (IsNull(ClaimsNote.Status, 0) & 64) = 0), 0)
END
