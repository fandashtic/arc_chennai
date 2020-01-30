Create Procedure SP_Post_TLCAchievementData
AS
BEGIN
	Set Dateformat DMY
	Declare @FromDate DateTime
	Declare @Todate Datetime
	Declare @PMMonth nvarchar(13)
	Declare @DayCloseFromDate DateTime
	Declare @DayCloseToDate DateTime

	Create Table #CustomerList(CustomerID nvarchar(25) Collate SQL_Latin1_General_CP1_CI_AS)

	Create Table #OLAchievement(InvoiceID int,InvoiceDate Datetime,CustomerID nvarchar(25) Collate SQL_Latin1_General_CP1_CI_AS,
								DSID int, DStypeID int, GroupID int, ItemCode nvarchar(25) Collate SQL_Latin1_General_CP1_CI_AS)


--	Select @DayCloseFromDate = Min(dbo.StripDateFromTime(DayCloseDate)) From DayCloseTracker Where isnull(Status,0) = 0 and Module = 'TLCAchievement'
--	Select @DayCloseToDate = Max(dbo.StripDateFromTime(DayCloseDate)) From DayCloseTracker Where isnull(Status,0) = 0 and Module = 'TLCAchievement'

	Select @FromDate = Convert(DateTime, '01' +  right(convert(varchar(11), dbo.Striptimefromdate(GetDate()), 103), 8))
	--Select @FromDate = dbo.StripTimeFromDate(Dateadd(day,1,Dayclosedate)) From DayCloseModules Where Module = 'Total Lines Cut'
	If (Select isNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') = 1 
		Select @Todate = dbo.StripTimeFromDate(LastInventoryUpload) From Setup  

	SELECT @PMMonth = REPLACE(RIGHT(CONVERT(VARCHAR(11), dbo.StripDateFromTime(GetDate()), 106), 8), ' ', '-')

	Insert into #CustomerList(CustomerID) select Distinct OutletID from PMOutletAchieve where PMID in (select Distinct PMID from tbl_merp_PMMaster 
	where Period = @PMMonth and isnull(active,0)=1)
	
	/* To post data in Temp Table from Invoice */
	Insert into #OLAchievement (InvoiceID,InvoiceDate,CustomerID,DSID, DStypeID, GroupID,ItemCode)
	Select distinct ID.InvoiceID,IA.InvoiceDate,IA.CustomerID,IA.SalesmanID,IA.DStypeID,ID.GroupID,ID.Product_code From InvoiceAbstract IA,InvoiceDetail ID
	Where IA.InvoiceID=ID.Invoiceid
	And IA.InvoiceType Not in (4,5) 
	And isnull(IA.Status,0) & 192 = 0
	And dbo.StripDateFromTime(IA.Invoicedate) between @FromDate and @Todate
	And IA.CustomerID in (select CustomerID from #CustomerList)
	Group by ID.InvoiceID,IA.InvoiceDate,IA.CustomerID,IA.SalesmanID,IA.DStypeID,ID.GroupID,ID.Product_code
	

	/* Start: For generating View */
	Delete From TLCAchievement

	Create Table #TmpDS(PMID int, PMDSTypeID int, ParamID int, DSID int, 
					DSType nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, DSTypeID int,
					PMProductName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
					PMCatGrp nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
					CustomerID nVarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS)

	Create Table #TmpItems(GroupID int, GroupName nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
						Division nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
						SubCategory nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
						MarketSKU nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
						ProductCode nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS) 

	Create Table #TmpSales(DSID int, DStypeID int, CustomerID nVarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
						PMProductName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
						PMCatGrp nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
						ItemCount int, PMID int)

	Create Table #TmpOutput(DSID int, DStypeID int, CustomerID nVarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
							PMProductName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
							PMCatGrp nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
							Target int, Achievement int, PMID int)

	/* To get DS wise and customer wise data from performance metrics */
	Insert Into #TmpDS(PMID, PMDSTypeID, ParamID, DSID, DSType, DSTypeID, PMProductName, PMCatGrp, CustomerID)
	Select Distinct PMMast.PMID, PMDS.DSTypeID, PMparam.ParamID, SM.SalesManID, PMDS.DSType, DSM.DSTypeID, 
		PMFocus.PMProductName, PMMast.CGGroups, C.CustomerID
	From tbl_mERP_PMMaster PMMast, tbl_merp_pmdstype PMDS, 
		tbl_merp_pmparam PMParam, tbl_merp_pmparamfocus PMFocus,
		DSTYpe_Master DSM, Salesman SM, DSType_Details DSTDet, Beat_Salesman BS, Beat B, Customer C
	Where PMMast.PMID = PMDS.PMID
		And PMDS.DSTypeID = PMParam.DSTypeID
		And DSM.DSTypeValue = PMDS.DSType
		And DSM.DSTypeCtlPos = 1
		And DSM.DSTypeID = DSTDet.DSTypeID
		And DSM.DSTypeCtlPos = DSTDet.DSTypeCtlPos
		And SM.SalesmanID = DSTDet.SalesmanID
		And PMparam.ParamID = PMFocus.ParamID
		And PMparam.ParameterType = 6	
		And PMMast.Period = @PMMonth 
		And isnull(PMMast.Active, 0) = 1
		And SM.Salesmanid = BS.SalesmanID	
		And BS.BeatID = B.BeatID
		And BS.CustomerID = C.CustomerID
		

	/* To get Target value from PMOutletAchieve */
	Insert Into #TmpOutput (DSID, CustomerID, PMProductName, PMCatGrp, Target, PMID, DSTypeID)
	Select Tmp.DSID, Tmp.CustomerID, Tmp.PMProductName, Tmp.PMCatGrp, Sum(IsNull(cast(PMO.Target as int), 0)) as Target, Tmp.PMID, Tmp.DSTypeID
	From #TmpDS Tmp, PMOutletAchieve PMO
	Where Tmp.CustomerID = PMO.OutletID
		And Tmp.PMID = PMO.PMID 
		And Tmp.PMDSTYPEID = PMO.DSTypeID 
		And Tmp.ParamID = PMO.ParamID
		And PMO.ParamType='TLC'
	Group By Tmp.DSID, Tmp.CustomerID, Tmp.PMProductName, Tmp.PMCatGrp, Tmp.PMID, Tmp.DSTypeID


	/* To get Division, SubCategory, MarketSKU, ProductCode for CG and OCG */
	Declare @OCG int
	Select @OCG=isnull(Flag,0) From Tbl_merp_Configabstract Where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup'

	IF @OCG = 1
	Begin
		Insert Into #TmpItems(GroupID, GroupName, Division, SubCategory, MarketSKU, ProductCode) 
		Select Distinct P.GroupID,O.GroupName, O.Division, O.SubCategory, MarketSKU, SystemSKU  
		From OCGItemMaster O, ProductCategoryGroupAbstract P
		Where P.GroupName = O.GroupName And
		Isnull(OCGType,0) = 1 And 
		Isnull(Active,0) = 1	

	End
	Else
	Begin	  
		Insert Into #TmpItems(GroupID, GroupName, Division, SubCategory, MarketSKU, ProductCode) 
		Select  
			Distinct PCGA.GroupID, PCGA.GroupName, IC1.Category_Name,  
			IC2.Category_Name, IC3.Category_Name, I.Product_Code    
		From  
			ItemCategories IC1, ItemCategories IC2, ItemCategories IC3, Items I  ,tblCGDivMapping CGDIV, ProductCategoryGroupAbstract PCGA
		Where  
			IC1.CategoryID = IC2.ParentID  
			And IC2.CategoryID = IC3.ParentID   
			And IC1.Level = 2  
			--And I.Active = 1
			And I.CategoryID = IC3.CategoryID  
			And CGDIV.Division = IC1.Category_Name
			And CGDIV.CategoryGroup = PCGA.GroupName
		Order By  
			I.Product_Code, IC1.Category_Name, IC2.Category_Name, IC3.Category_Name 

	End

	/* To get ProductName and ProductLevel from tbl_mERP_PMParamFocus for each ParameterID */
	Declare @TempFocusItems as Table (ProductLevel Int,
									ProductName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, ParamID int,
									CategoryID Int,	PMProductName Nvarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS, 
									GroupID int, PMCatGrp nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, DSTypeID int, PMID int)


	Declare @ProductLevel As Int
	Declare @PMProductName As Nvarchar(500)
	Declare @PGCatGrp  as nVarchar(50)
	Declare @ParamID as Int
	Declare @DSTypeID as Int
	Declare @PMID  as Int

	Insert Into @TempFocusItems (ProductLevel, ProductName, ParamID, PMProductName, PMCatGrp, DSTypeID, PMID)
	Select ProdCat_Level, ProdCat_Code, T.ParamID, PMProductName, T.PMCatGrp, T.DSTypeID, PMID
		From tbl_mERP_PMParamFocus Focus, (Select Distinct ParamID, PMCatGrp, DSTypeID, PMID From #TmpDS) T 
		Where Focus.ParamID = T.ParamID


	Update TC Set TC.CategoryID = IC.CategoryID From @TempFocusItems TC, ItemCategories IC 
	Where TC.ProductLevel = IC.Level and TC.ProductName = IC.Category_Name And IC.Active = 1 and TC.ProductLevel <> 0

	Update @TempFocusItems Set CategoryID = 1 Where ProductLevel = 0

	
	Declare @tmpPMCG as Table(CatGrpID int, CatGrp nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)

	Declare AllProd Cursor for Select Distinct PMProductName, ParamID, PMCatGrp, DSTypeID, PMID  From @TempFocusItems
	Open AllProd
	Fetch from  AllProd into @PMProductName, @ParamID, @PGCatGrp, @DSTypeID, @PMID
	While @@fetch_status=0
	Begin
		/* To get GroupID based on PMCategoryGroup for CG and OCG */
		Insert into @tmpPMCG (CatGrp)
		Select LTRIM(RTRIM(ItemValue)) From dbo.sp_SplitIn2Rows(@PGCatGrp,'|')
		If @OCG=0
		Begin
			Update t Set CatGrpID = M.GroupID  From @tmpPMCG t, ProductCategoryGroupAbstract M 
			Where t.CatGrp = M.GroupName And Isnull(M.Active, 0) = 1 
		End
		Else
		Begin
			Insert Into @tmpPMCG (CatGrp) Select GroupName From ProductCategoryGroupAbstract M, @tmpPMCG t
					Where Substring(M.GroupName, 1, 3) = t.CatGrp  And Isnull(M.Active, 0) = 1  and isnull(M.OCGType,0) = 1
			Update t Set CatGrpID = M.GroupID  From @tmpPMCG t, ProductCategoryGroupAbstract M 
			Where t.CatGrp = M.GroupName And Isnull(M.Active, 0) = 1  and isnull(M.OCGType,0) = 1
		End
		Delete From @tmpPMCG Where CatGrpID is Null
		
		/* To get Salevalue based on each ProductLevel */		
		Select Top 1 @ProductLevel = ProductLevel From @TempFocusItems
		Where PMProductName = @PMProductName
			
		If @ProductLevel = 0
		Begin
			Insert Into #TmpSales(DSTypeID, DSID, CustomerID, PMProductName, PMCatGrp, PMID, ItemCount)
			Select OLA.DSTypeID, OLA.DSID, OLA.CustomerID, @PMProductName, @PGCatGrp, @PMID, count(distinct ItemCode)
			From #OLAchievement OLA, #TmpItems T
			Where dbo.StripDateFromTime(OLA.InvoiceDate) Between @FromDate AND @ToDate
				And OLA.ItemCode = T.ProductCode
				And OLA.GroupID in(Select CatGrpID From @tmpPMCG)
				And OLA.DSTypeID = @DSTypeID
			Group By OLA.DSTypeID, DSID, CustomerID,OLA.InvoiceID
		End				

		If @ProductLevel = 2
		Begin
			Insert Into #TmpSales(DSTypeID, DSID, CustomerID, PMProductName, PMCatGrp, PMID, ItemCount)
			Select OLA.DSTypeID, OLA.DSID, OLA.CustomerID, @PMProductName, @PGCatGrp, @PMID, count(distinct ItemCode)
			From #OLAchievement OLA, #TmpItems T
			Where dbo.StripDateFromTime(OLA.InvoiceDate) Between @FromDate AND @ToDate
				And OLA.ItemCode = T.ProductCode
				And OLA.GroupID in(Select CatGrpID From @tmpPMCG)
				And OLA.DSTypeID = @DSTypeID
				And T.Division in(Select ProductName from  @TempFocusItems where PMProductName = @PMProductName and ParamID = @ParamID)
			Group By OLA.DSTypeID, DSID, CustomerID,OLA.InvoiceID
		End				

		If @ProductLevel = 3
		Begin
			Insert Into #TmpSales(DSTypeID, DSID, CustomerID, PMProductName, PMCatGrp, PMID, ItemCount)
			Select OLA.DSTypeID, OLA.DSID, OLA.CustomerID, @PMProductName, @PGCatGrp, @PMID, count(distinct ItemCode)
			From #OLAchievement OLA, #TmpItems T
			Where dbo.StripDateFromTime(OLA.InvoiceDate) Between @FromDate AND @ToDate
				And OLA.ItemCode = T.ProductCode
				And OLA.GroupID in(Select CatGrpID From @tmpPMCG)
				And OLA.DSTypeID = @DSTypeID
				And T.SubCategory in(Select ProductName from  @TempFocusItems where PMProductName = @PMProductName and ParamID = @ParamID)
			Group By OLA.DSTypeID, DSID, CustomerID,OLA.InvoiceID
		End				

		If @ProductLevel = 4
		Begin
			Insert Into #TmpSales(DSTypeID, DSID, CustomerID, PMProductName, PMCatGrp, PMID, ItemCount)
			Select OLA.DSTypeID, OLA.DSID, OLA.CustomerID, @PMProductName, @PGCatGrp, @PMID,count(distinct ItemCode)
			From #OLAchievement OLA, #TmpItems T
			Where dbo.StripDateFromTime(OLA.InvoiceDate) Between @FromDate AND @ToDate
				And OLA.ItemCode = T.ProductCode
				And OLA.GroupID in(Select CatGrpID From @tmpPMCG)
				And OLA.DSTypeID = @DSTypeID
				And T.MarketSKU in(Select ProductName from  @TempFocusItems where PMProductName = @PMProductName and ParamID = @ParamID)
			Group By OLA.DSTypeID, DSID, CustomerID,OLA.InvoiceID
		End				

		If @ProductLevel = 5
		Begin
			Insert Into #TmpSales(DSTypeID, DSID, CustomerID, PMProductName, PMCatGrp, PMID, ItemCount)
			Select OLA.DSTypeID, OLA.DSID, OLA.CustomerID, @PMProductName, @PGCatGrp, @PMID,count(distinct ItemCode)
			From #OLAchievement OLA, #TmpItems T
			Where dbo.StripDateFromTime(OLA.InvoiceDate) Between @FromDate AND @ToDate
				And OLA.ItemCode = T.ProductCode
				And OLA.GroupID in(Select CatGrpID From @tmpPMCG)
				And OLA.DSTypeID = @DSTypeID
				And T.ProductCode in(Select ProductName from  @TempFocusItems where PMProductName = @PMProductName and ParamID = @ParamID)
			Group By OLA.DSTypeID, DSID, CustomerID,OLA.InvoiceID
		End					
		
		Delete From @tmpPMCG		
		Fetch next from AllProd into @PMProductName, @ParamID, @PGCatGrp, @DSTypeID, @PMID
	End
	Close allProd
	Deallocate allProd	

	/* Updating Achievement Value in Output table */
	Update T Set Achievement = Sa.ItemCount
	From #TmpOutput T, (Select DSID, DSTypeID, CustomerID, PMProductName, PMCatGrp, PMID, Sum(ItemCount) as ItemCount From #TmpSales 
						Group By DSID, DSTypeID, CustomerID, PMProductName, PMCatGrp, PMID) Sa
	Where 
		T.DSID = Sa.DSID
		and T.DSTypeID = Sa.DSTypeID
		and T.CustomerID = Sa.CustomerID
		and T. PMProductName = Sa.PMProductName
		and T.PMCatGrp = Sa.PMCatGrp
		and T.PMID = Sa.PMID
	
	Insert Into TLCAchievement(DSTypeID, DSID, CustomerID, PMProductName, PMCatGrp, Target, Achievement, PMID)
	Select DSTypeID, DSID, CustomerID, PMProductName, PMCatGrp, Sum(isnull(Target, 0)) as Target, Sum(isnull(Achievement, 0)) as Achievement, PMID 
	From #TmpOutput
	Group By DSTypeID, DSID, CustomerID, PMProductName, PMCatGrp, PMID
	Order By DSID, CustomerID, PMCatGrp, PMProductName

	Drop Table #TmpDS
	Drop Table #TmpItems
	Drop Table #TmpSales
	Drop Table #TmpOutput
	/* End: For generating View */


	/* For Reprocessing: If PMOutletAchieve alone is received and PM is not received for a month then Dataposting should not happen */
--	If (select count(*) From #CustomerList)>0
--	BEGIN
--		Update DayCloseTracker Set Status = 1 Where dbo.StripDateFromTime(DayCloseDate) Between @DayCloseFromDate and @DayCloseToDate and Module = 'TLCAchievement'
--	END

	update  DayCloseModules set DayCloseDate = @Todate Where Module = 'Total Lines Cut'
	Drop Table #CustomerList
	Drop Table #OLAchievement

END
