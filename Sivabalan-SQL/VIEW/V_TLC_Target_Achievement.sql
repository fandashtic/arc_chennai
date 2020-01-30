CREATE VIEW [dbo].[V_TLC_Target_Achievement]  
AS  
Select T.DSID, T.CustomerID, T.PMProductName, sum(isnull(T.Target,0)) as Target, 
	sum(isnull(OL.Achievement,0)) as Achievement, T.PMCatGrp 
	From (Select Tmp.DSID, Tmp.CustomerID, Tmp.PMProductName, Tmp.PMCatGrp, sum(IsNull(PMO.Target, 0)) as Target, Tmp.PMID
	From 
		(Select distinct PMMast.PMID, PMDS.DSTypeID as PMDSTYPEID, PMparam.ParamID, SM.SalesManID as DSID, 
		PMDS.DSType, DSM.DSTypeID as DSMDSTypeID, PMFocus.PMProductName,
		PMMast.CGGroups as PMCatGrp, C.CustomerID
	From tbl_mERP_PMMaster PMMast, tbl_merp_pmdstype PMDS, 
		tbl_merp_pmparam PMParam, tbl_merp_pmparamfocus PMFocus,
		DSTYpe_Master DSM, SalesMan SM, DSType_Details DSTDet, Beat_salesman BS, Beat B, Customer C
	Where PMMast.PMID = PMDS.PMID
		And PMDS.DSTypeID = PMParam.DSTypeID
		And DSM.DSTypeValue = PMDS.DSType
		And DSM.DSTypeCtlPos = 1
		And DSM.DSTypeID = DSTDet.DSTypeID
		And DSM.DSTypeCtlPos = DSTDet.DSTypeCtlPos
		And SM.SalesmanID = DSTDet.SalesmanID
		And IsNull(SM.Active, 0) = 1
		And PMparam.ParamID = PMFocus.ParamID
		And PMparam.ParameterType = 6	
		And PMMast.Period = REPLACE(RIGHT(CONVERT(VARCHAR(11), dbo.StripDateFromTime(GetDate()), 106), 8), ' ', '-') 
		And isnull(PMMast.Active,0) = 1
		And SM.Salesmanid = BS.SalesmanID	
		And BS.BeatID = B.BeatID
		And BS.CustomerID = C.CustomerID
		And isnull(B.Active, 0) = 1
		And isnull(C.Active, 0) = 1
		And isnull(DSM.Active, 0) = 1
		And SM.SalesmanID in(Select Distinct SalesmanID From DSType_Master a, DSType_Details b 
							Where a.DSTypeID = b.DSTypeID and a.DSTypeCtlPos = 2 and a.DSTypeValue = 'Yes')) Tmp, PMOutletAchieve PMO
	Where Tmp.CustomerID = PMO.OutletID
		And Tmp.PMID = PMO.PMID 
		And Tmp.PMDSTYPEID = PMO.DSTypeID 
		And Tmp.ParamID = PMO.ParamID
		And PMO.ParamType='TLC'
	Group By Tmp.DSID, Tmp.CustomerID, Tmp.PMProductName, Tmp.PMCatGrp, Tmp.PMID
	) T
	Left Join TLCAchievement OL  on T.DSID = OL.DSID And T.CustomerID = OL.CustomerID And T.PMProductName = OL.PMProductName  And T.PMCatGrp = OL.PMCatGrp and T.PMID = OL.PMID
	
	--, TLCAchievement OL

	--Where T.DSID *= OL.DSID
		--and T.CustomerID *= OL.CustomerID
		--and T.PMProductName *= OL.PMProductName
		--and T.PMCatGrp *= OL.PMCatGrp
		--and T.PMID *= OL.PMID
	Group By T.DSID, T.CustomerID, T.PMProductName, T.PMCatGrp
