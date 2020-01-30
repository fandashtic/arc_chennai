Create Procedure mERP_spr_DandDRFAAbstract(@FromDate Datetime,@ToDate Datetime,
@RFAStatus nVarchar(50))
As
Begin
If @RFAStatus = N'' or (@RFAStatus <> N'%' and @RFAStatus <> N'Open' and @RFAStatus <> N'Destroyed')
Set @RFAStatus = N'%'
if @RFAStatus = '%'
BEGIN
	Select ID,DandDAbstract.DocumentID + N'/' + replace(convert(nvarchar(10),ClaimDate,103),N'/',N'') as [Activity Code],
	--N'Damage' + N' - ' + Remarks + N' ' + FromMonth + N'-' + ToMonth as Description,
	N'Damage' + N' - ' + RemarksDescription as Description,
	convert(nvarchar(10),ClaimDate,103) + '-' + convert(nvarchar(10),ClaimDate,103) as [RFA Period],
	ClaimValue as [RFA Value],
--Replace(convert(nVarchar(10),Isnull(SubMissionDate,''),103),'01/01/1900','')
	Replace(convert(nVarchar(10),(select top 1 Isnull(SubMissionDate,'') from tbl_merp_rfaabstract where docreference=claimid),103),'01/01/1900','') as [Submission Date],
	Case ClaimStatus When 1 Then 'Open' When 2 Then 'Open' When 3 Then 'Destroyed' End as Status
	, Case When OptSelection = 2 Then 'Month Selection' Else 'Day Close Date' End as [Damage Option]
	from DandDAbstract--, tbl_merp_RFAAbstract
	where isnull(DandDAbstract.Status,0) & 192 = 0 
	and ClaimStatus in (1,2,3) --like Case @RFAStatus When N'%' Then N'%' When N'Open' Then N'2' When N'Destroyed' Then N'3' End
	and ClaimDate between @FromDate and @ToDate
--	and ClaimID *= tbl_merp_RFAAbstract.DocReference
	Order by ID 
END
ELSE if @RFAStatus = 'Open'
BEGIN
	Select ID,DandDAbstract.DocumentID + N'/' + replace(convert(nvarchar(10),ClaimDate,103),N'/',N'') as [Activity Code],
	--N'Damage' + N' - ' + Remarks + N' ' + FromMonth + N'-' + ToMonth as Description,
	N'Damage' + N' - ' + RemarksDescription as Description,
	convert(nvarchar(10),ClaimDate,103) + '-' + convert(nvarchar(10),ClaimDate,103) as [RFA Period],
	ClaimValue as [RFA Value],
--Replace(convert(nVarchar(10),Isnull(SubMissionDate,''),103),'01/01/1900','')
	Replace(convert(nVarchar(10),(select top 1 Isnull(SubMissionDate,'') from tbl_merp_rfaabstract where docreference=claimid),103),'01/01/1900','') as [Submission Date],
	Case ClaimStatus When 1 Then 'Open' When 2 Then 'Open' When 3 Then 'Destroyed' End as Status
	, Case When OptSelection = 2 Then 'Month Selection' Else 'Day Close Date' End as [Damage Option]
	from DandDAbstract--, tbl_merp_RFAAbstract
	where isnull(DandDAbstract.Status,0) & 192 = 0 
	and ClaimStatus in (1,2) --like Case @RFAStatus When N'%' Then N'%' When N'Open' Then N'2' When N'Destroyed' Then N'3' End
	and ClaimDate between @FromDate and @ToDate
--	and ClaimID *= tbl_merp_RFAAbstract.DocReference
	Order by ID 
END
ELSE if @RFAStatus = 'Destroyed'
BEGIN
	Select ID,DandDAbstract.DocumentID + N'/' + replace(convert(nvarchar(10),ClaimDate,103),N'/',N'') as [Activity Code],
	--N'Damage' + N' - ' + Remarks + N' ' + FromMonth + N'-' + ToMonth as Description,
	N'Damage' + N' - ' + RemarksDescription as Description,
	convert(nvarchar(10),ClaimDate,103) + '-' + convert(nvarchar(10),ClaimDate,103) as [RFA Period],
	ClaimValue as [RFA Value],
--Replace(convert(nVarchar(10),Isnull(SubMissionDate,''),103),'01/01/1900','')
	Replace(convert(nVarchar(10),(select top 1 Isnull(SubMissionDate,'') from tbl_merp_rfaabstract where docreference=claimid),103),'01/01/1900','') as [Submission Date],
	Case ClaimStatus When 1 Then 'Open' When 2 Then 'Open' When 3 Then 'Destroyed' End as Status
	, Case When OptSelection = 2 Then 'Month Selection' Else 'Day Close Date' End as [Damage Option]
	from DandDAbstract--, tbl_merp_RFAAbstract
	where isnull(DandDAbstract.Status,0) & 192 = 0 
	and ClaimStatus in (3) --like Case @RFAStatus When N'%' Then N'%' When N'Open' Then N'2' When N'Destroyed' Then N'3' End
	and ClaimDate between @FromDate and @ToDate
--	and ClaimID *= tbl_merp_RFAAbstract.DocReference
	Order by ID 
END
End
