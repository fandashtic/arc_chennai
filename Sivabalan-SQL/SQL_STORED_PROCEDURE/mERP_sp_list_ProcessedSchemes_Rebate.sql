Create procedure mERP_sp_list_ProcessedSchemes_Rebate
(@SchemeCode nVarChar(50),
 @FromDate DateTime,
 @ToDate DateTime,
 @FILTER INT = 0,
 @SchemeType Int = 5 )
As

	Select CSAbstract.SchemeID,
	CSAbstract.CS_RecSchID,
	CSAbstract.ActivityCode,
	CSAbstract.Description,
	CSType.SchemeType,
	CSAbstract.ActiveFrom,
	CSAbstract.ActiveTo,
	Case 
		When (Select Transactiondate From Setup) Between ActiveFrom And ActiveTo then 'Active'
		Else 'Inactive' End 'Status',
	Case CSAbstract.SchemeStatus when 2 Then 'Drop' when 1 then 'CR' else 'New' End "SchemeStatus" 
	From 
		tbl_mERP_SchemeAbstract CSAbstract, 
		tbl_mERP_SchemeType CSType
	Where
		--CSAbstract.ActiveFrom Between @FromDate And @ToDate And 
		CSType.ID = @SchemeType and CSType.ID  = CSAbstract.SchemeType And
		CSAbstract.CS_RecSchID = Case @SchemeCode When N'%' Then CSAbstract.CS_RecSchID Else @SchemeCode End 
--And
--	CSAbstract.ViewDate Between @FromDate And @ToDate
And		((@FromDate Between CSAbstract.ViewDate And CSAbstract.SchemeTo)  Or 
          (@ToDate Between CSAbstract.ViewDate And CSAbstract.SchemeTo) or --) 
		  (CSAbstract.ViewDate Between @FromDate And @ToDate) Or
          (CSAbstract.SchemeTo Between @FromDate And @ToDate))
And
		-- dbo.StripTimeFromDate(CSAbstract.ActiveFrom) <= (Select Top 1 dbo.StripTimeFromDate(Transactiondate) From Setup) And
		dbo.StripTimeFromDate(CSAbstract.ViewDate) <= (Select Top 1 dbo.StripTimeFromDate(Transactiondate) From Setup) And
		CSAbstract.Active = Case @FILTER WHEN 0 THEN CSAbstract.Active WHEN 1 THEN 1 WHEN 2 THEN 0 END
	Order by
		CSAbstract.CS_RecSchID

