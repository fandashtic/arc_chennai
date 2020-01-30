Create Procedure SP_get_DandDPopupDetails @Mode int,@TaskIDFrom nvarchar(255),@TaskIDTo nvarchar(255),@FromDate Datetime,@ToDate Datetime
AS
BEGIN
	Set Dateformat DMY
	Declare @Prefix nvarchar (10)
	SELECT @Prefix=Prefix FROM VoucherPrefix WHERE TranID = 'CLAIMS NOTE'  
	/* IF mode is 1 then we will consider only Task IDs*/
	If @Mode =1
	BEGIN
		Select Distinct DocumentID,Convert(Nvarchar(10),ClaimDate,103) as ClaimDate,Remarks,Case ClaimStatus When 1 Then 'Open' When 2 Then 'Open' When 3 Then 'Destroyed' When 192 Then 'Cancelled' end as [Status],ID
		From DandDAbstract where 
		cast(Replace(DocumentID,@Prefix,'') as int) between cast(Replace(@TaskIDFrom,@Prefix,'') as int) and cast(Replace(@TaskIDTo,@Prefix,'') as int)
	END
	ELSE IF @Mode=2
	BEGIN
		Select Distinct DocumentID,Convert(Nvarchar(10),ClaimDate,103) as ClaimDate,Remarks,Case ClaimStatus When 1 Then 'Open' When 2 Then 'Open' When 3 Then 'Destroyed' When 192 Then 'Cancelled' end as [Status],ID
		From DandDAbstract where 
		dbo.striptimefromdate(claimdate) between dbo.striptimefromdate(@fromdate) and dbo.striptimefromdate(@todate)
		--Convert(Nvarchar(10),ClaimDate,103) between Convert(Nvarchar(10),@FromDate,103) and Convert(Nvarchar(10),@ToDate,103)
	END
END
