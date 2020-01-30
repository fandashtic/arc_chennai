Create Procedure Sp_GGRRFinalDataPost(@ToDate DateTime = Null,@Receive Int = Null,@IsRepost Int =0)
As
Begin

	Set DateFormat DMY
	Declare @GGDRmonth Nvarchar(10)
	Declare @RecdDSType Nvarchar(4000)
	Declare @DS Nvarchar(4000)
	Declare @Beat Nvarchar(4000)
	Declare @LastdaycloseDate as DateTime    
	If @IsRepost= 1
	Begin
		Select @LastdaycloseDate = Dbo.StripdateFromtime(@ToDate)
	End
	Else
	Begin
		Set @LastdaycloseDate = (select Top 1 LastInventoryUpload from SetUp)
	End
	
	Begin Tran
	
	IF OBJECT_ID('tempdb..#TmpItems') IS NULL
	Create Table #TmpItems (Product_Code Nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,Sales Decimal(18,6))
	IF OBJECT_ID('tempdb..#TmpExItems') IS NULL
	Create Table #TmpExItems (Product_Code Nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

	CREATE TABLE #D_TmpOut(
		[ProductCode] Nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Product Description] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ProductLevel] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Target] Decimal(18, 6) NULL Default 0,
		[TargetUOM] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsExcluded] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Actual] Decimal(18, 6) NULL Default 0,
		FromDate dateTime Null,
		Todate dateTime Null, Points Decimal(18,6) Null Default 0)


	CREATE TABLE #TmpOutAbstract([DetailID] nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Month]  nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CustomerID] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Customer Name] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DS ID] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DS Name] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DS Type] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Beat] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Status] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Target] [decimal](18, 6) NULL Default 0,
		[TargetUOM] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Cat GRP] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OCG] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Actual] [decimal](18, 6) NULL Default 0,
		[Current Status] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Last Day Close Date] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FromDate] DateTime NUll,
		[ToDate] DateTime NUll,
		[ProdDefnID] Int,
		MaxProdDefnID Int Null,
		CustomerCategory Nvarchar(Max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		PMCategory Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, Flag nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
	IF OBJECT_ID('tempdb..#TmpDS') IS  NULL
	Create Table #TmpDS (SalesmanID Int)
	IF OBJECT_ID('tempdb..#TmpBeat') IS  NULL
	Create Table #TmpBeat (BeatID Int)
	IF OBJECT_ID('tempdb..#TmpDSType') IS  NULL
	Create Table #TmpDSType (DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
	IF OBJECT_ID('tempdb..#TmpCustomer') IS  NULL
	Create Table #TmpCustomer (
		SalesmanID Int,
		SalesmanName  Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		DSType  Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		BeatID Int,
		CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Customername Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		FromDate DateTime,ToDate DateTime)
	IF OBJECT_ID('tempdb..#TmpOut') IS  NULL
	CREATE TABLE #TmpOut( ID Int Identity(1,1),
		[DetailID] nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Customer Name] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DS ID] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DS Name] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DS Type] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Status] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Target] [decimal](18, 6) NULL Default 0,
		[TargetUOM] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Cat GRP] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OCG] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Actual] [decimal](18, 6) NULL Default 0,
		[Current Status] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Last Day Close Date] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CustomerID] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FromDate] DateTime NUll,
		[ToDate] DateTime NUll,
		[ProdDefnID] Int,
		PMCategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, Flag nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
	IF OBJECT_ID('tempdb..#TmpCustCat') IS  NULL
	Create Table #TmpCustCat(CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,SalesmanID Int,CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,ProdDefnID Int,PMCategory Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
	
	IF OBJECT_ID('tempdb..#TmpGGDRSKUDetails') IS  NULL
	Create Table #TmpGGDRSKUDetails(
		ProdDefnID Int,
		Product_Code Nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		MarketSKU Nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		SubCategory Nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Division Nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CategoryGroup Nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
	IF OBJECT_ID('tempdb..#Items') IS NULL
	CREATE TABLE #Items(
		Product_Code nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		ProductName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		UOM1_Conversion decimal(18, 6) NULL,
		UOM2_Conversion decimal(18, 6) NULL)

	Insert Into #Items
	Select Distinct Product_Code,ProductName,UOM1_Conversion,UOM2_Conversion From Items

	Create Table #tmbGGRRMonth (Id Int Identity(1,1),MonthName Nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
	Create Table #GGRRCustomer (CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
	Create Table #PendingGGRRFinalDataPost (
		FromDateMonth Nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		TodateMonth Nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Fromdate DateTime Null,
		ToDate DateTime Null)
	Create Table #TmpCustomer1 (
		SalesmanID Int,
		SalesmanName  Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		DSType  Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		BeatID Int,
		CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Customername Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

	Create Table #DSTypeMaster (DSType nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
	Create Table #tmpCatVal (ID Int,CustID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CatGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Status Int)

	Create Table #TFinalOut (SDProductCode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Target Decimal(18,6),Actual Decimal(18,6),Netsales Decimal(18,6),Status Int)
	Create Table #PMCategory (PMCategory Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CustCat Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Create Table #Statusval (DSID Int, DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CatGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Status Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Curstatus Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Fstatus Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Actual Decimal(18,6),PMCategory Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Create Table #CatGrpp (Cat Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS Null)
	Create Table #TmpCatGroup (GroupName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
	Create Table #Tmp (Product_Code Nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

/* For If any one Product_Code Master Data is not mapped then Need to Refresh TmpGGDRSKUDetails data. issue Reported by ITC and Found in Wdside. */
	If Exists(Select Top 1 'x' From TmpGGDRSKUDetails Where (Isnull(MarketSKU,'') = '' Or Isnull(SubCategory,'') = '' Or Isnull(Division,'') = '' Or Isnull(CategoryGroup,'') = ''))
	Begin
		Exec mERP_sp_RefereshGGDRSKUList
	End

	Set @RecdDSType = '%'
	Set @DS = '%'
	Set @Beat = '%'

	If @ToDate IS NULL
	Begin
		If Isnull(@Receive,0) = 1
		Begin

			Truncate Table #PendingGGRRFinalDataPost
			Insert Into #PendingGGRRFinalDataPost (FromDateMonth,TodateMonth,CustomerID,Fromdate,ToDate)
			Select FromDateMonth,TodateMonth,CustomerID,Fromdate,ToDate From PendingGGRRFinalDataPost

			Truncate Table #tmbGGRRMonth
			Insert into #tmbGGRRMonth (MonthName)
			Select Distinct FromDateMonth from #PendingGGRRFinalDataPost
		End
		Else
		Begin	
			--Truncate Table GGRRFinalData
			Delete From GGRRFinalData Where Fromdate >= '01-04-2014'

			Truncate Table #tmbGGRRMonth
			Insert into #tmbGGRRMonth (MonthName)
			/*ITC CR: First Level data Posting Start From 01/01/2014.*/
			/* For GGRR Multi Obj, The Fromdate is changed to 01 Mar 2014 */
			/* For GGRR Multi Obj, The Fromdate is changed to 01 Apr 2014 : Request date: 04-04-2014*/
			Select Distinct Fromdate from GGDROutlet Where isnull(Active,0) = 1
			And ReportFromdate  >= '01-04-2014'
		End
	End
	Else
	Begin
		Set @GGDRmonth = (Select (Case When Month(@Todate) = 1 Then 'Jan' When Month(@Todate) = 2 Then 'Feb'
					When Month(@Todate) = 3 Then 'Mar' When Month(@Todate) = 4 Then 'Apr'
					When Month(@Todate) = 5 Then 'May' When Month(@Todate) = 6 Then 'Jun'
					When Month(@Todate) = 7 Then 'Jul' When Month(@Todate) = 8 Then 'Aug'
					When Month(@Todate) = 9 Then 'Sep' When Month(@Todate) = 10 Then 'Oct'
					When Month(@Todate) = 11 Then 'Nov' When Month(@Todate) = 12 Then 'Dec'
				End) + '-'+ Cast(Year(@Todate) as Nvarchar))

--		If Exists(Select 'X' From GGDRData Where Convert(Nvarchar(10),InvoiceDate,103) = Convert(Nvarchar(10),@ToDate,103))
--		Begin			
			If Exists(Select 'X' From GGDROUtlet Where @Todate Between ReportFromdate and ReportTodate And Active = 1 )--And OutletID in (Select Distinct RetailerCode From GGDRData Where InvoiceDate = @ToDate))
			Begin
				Truncate Table #tmbGGRRMonth
				Insert into #tmbGGRRMonth (MonthName)
				Select @GGDRmonth

				Insert Into #GGRRCustomer
				Select Distinct RetailerCode From GGDRData Where Convert(Nvarchar(10),InvoiceDate,103) = Convert(Nvarchar(10),@ToDate,103)
			End
--		End
	End

	Declare  @MaxTodate as DateTime
	Declare  @MinFromdate as DateTime
	Select @MinFromdate = Min(Cast(('01-' + Fromdate) as DateTime)), @MaxTodate = DateAdd(d,-1,DateAdd(m,1,Max(Cast(('01-' + Fromdate) as DateTime)))) 
	from GGDROutlet Where isnull(Active,0) = 1	And ReportFromdate  >= '01-01-2014'

	Truncate Table #TmpGGDRSKUDetails
	Insert Into #TmpGGDRSKUDetails(ProdDefnID,Product_Code,MarketSKU,SubCategory,Division,CategoryGroup)
	Select Distinct T.ProdDefnID,T.Product_Code,T.MarketSKU,T.SubCategory,T.Division,T.CategoryGroup From TmpGGDRSKUDetails T
	Join (Select Distinct ProdDefnID From GGDRoutlet Where ReportFromdate >= @MinFromdate and ReportTodate <= @MaxTodate) Outlet On Outlet.ProdDefnID = T.ProdDefnID 	  
	--Where ProdDefnID in (Select Distinct ProdDefnID From GGDRoutlet Where ReportFromdate >= @MinFromdate and ReportTodate <= @MaxTodate)

	IF Not Exists(Select Top 1 'x' From #tmbGGRRMonth)
	Begin
		Goto OUT
	End

	Declare @i as int
	set @i = 1
	While @i <= (Select Isnull(Max(ID),0) From #tmbGGRRMonth)
	Begin

/*  Loop Start */

	Set @GGDRmonth = (Select Top 1 MonthName From #tmbGGRRMonth Where ID = @i)
	IF Isnull(@GGDRmonth,'') = ''
	Goto OUT

	Delete FD From GGRRFinalData FD Where FD.[Month] = @GGDRmonth And FD.CustomerID Not In (Select Distinct OutletID From GGDROutlet Where FromDate = @GGDRmonth)

	Declare @Delimeter as nVarchar
	Declare @T_FromDate as DateTime    
	Declare @T_ToDate as DateTime
	Declare @OCGFlag as int
	set @OCGFlag = (Select Top 1 isnull(Flag,0) from tbl_merp_Configabstract Where ScreenCode = 'OCGDS')
	Set @Delimeter = Char(15)
	Declare @MonthEnddate as DateTime
	Declare @MonthFirstdate as DateTime
	Declare @MonthTodate as DateTime
	Set @MonthEnddate = (Select DateAdd(d,-1,dateAdd(m,1,cast(('01-' + @GGDRmonth) as DateTime))))
	set @MonthFirstdate = cast(('01-' + @GGDRmonth) as DateTime)
	Set @MonthTodate = (Select Case When @LastdaycloseDate >= @MonthEnddate Then @MonthEnddate Else @LastdaycloseDate End)


	IF (@MonthFirstdate > @MonthTodate ) and @Receive = 1
	Begin
		Set @MonthTodate = @MonthEnddate
	End
	else if (@MonthFirstdate > @MonthTodate )
	Begin
/* For Re-DataPosting Process: Based on Last Dayclose Validation Checked. Consider only Month From date And Todate. */
		Set @MonthTodate = @MonthEnddate
--		Goto SkipMonth
	End

	Truncate Table #TmpCustomer
	Truncate Table #TmpDS
	Truncate Table #TmpBeat
	Truncate Table #TmpOut
	Truncate Table #TmpDSType

	If @DS = '%'
	Begin
		Insert Into #TmpDS Select SalesmanID From Salesman
	End
	Else
	Begin
		Insert Into #TmpDS    
		Select SalesmanID From Salesman Where Salesman_Name In (Select * From dbo.sp_splitin2Rows(@DS,@Delimeter))    
	End

	If @Beat = '%'
	Begin
		Insert Into #TmpBeat Select BeatID From Beat
	End
	Else
	Begin
		Insert Into #TmpBeat    
		Select BeatID From Beat Where Description In (Select * From dbo.sp_splitin2Rows(@Beat,@Delimeter))    
	End

	If @RecdDSType = '%'
	Begin
		Insert Into #TmpDSType Select Distinct DSTypevalue From DSType_Master
	End
	Else
	Begin
		Insert Into #TmpDSType    
		Select  DSTypevalue From DSType_Master Where DSTypevalue In (Select * From dbo.sp_splitin2Rows(@RecdDSType,@Delimeter))    
	End

	--IF OBJECT_ID('tempdb..#GGDRData') IS Not NULL
	--	Drop Table #GGDRData 
	
	--Select * Into #GGDRData from GGDRData GD
	--Where GD.InvoiceDate Between  @MonthFirstdate And @MonthTodate

	--IF OBJECT_ID('tempdb..#GGDROutlet') IS  Not NULL
	--	Drop Table #GGDROutlet 
	
	--Select * Into #GGDROutlet From GGDROutlet G
	--Where ISNULL(G.Active ,0) = 1 
	--And @MonthFirstdate Between G.ReportFromDate And G.ReportToDate 

	--IF OBJECT_ID('tempdb..#GGDRProduct') IS  Not NULL
	--	Drop Table #GGDRProduct

	--Select GP.* Into #GGDRProduct From GGDRProduct GP
	--Join #GGDROutlet G On G.ProdDefnID = GP.ProdDefnID  

	Insert Into #TmpCustomer (SalesManId,BeatID,CustomerID)
	Select Distinct BS.SalesManId,BS.BeatID,BS.CustomerID From Beat_SalesMan BS, #TmpDS S, #TmpBeat B,
	 (Select Distinct G.OutletId from GGDROutlet G Where Isnull(G.Active,0) = 1 And @MonthFirstdate Between G.ReportFromdate and G.ReportTodate) Outlet
	Where BS.SalesManId = S.SalesmanID
	And BS.BeatID = B.BeatID
	And Isnull(BS.CustomerID,'') <> ''
	And BS.CustomerID  = Outlet.OutletID 

	--Select Distinct BS.SalesManId,BS.BeatID,BS.CustomerID From Beat_SalesMan BS, #TmpDS S, #TmpBeat B 
	--Where BS.SalesManId = S.SalesmanID
	--And BS.BeatID = B.BeatID
	--And Isnull(BS.CustomerID,'') <> ''
	--And BS.CustomerID  in (
	--Select Distinct G.OutletId
	--from GGDROutlet G
	--Where Isnull(G.Active,0) = 1
	--And @MonthFirstdate Between G.ReportFromdate and G.ReportTodate)

	Insert Into #TmpCustomer (CustomerID,SalesManId,DSType)
	Select Distinct RetailerCode,DSID,DSType From GGDRData 
	Where InvoiceDate Between  @MonthFirstdate And @MonthTodate
	

	Update T Set T.Customername = C.Company_name From Customer C, #TmpCustomer T
	Where C.CustomerID = T.CustomerID

	Update T Set T.SalesmanName = S.Salesman_Name From SalesMan S, #TmpCustomer T
	Where S.SalesmanID = T.SalesmanID

	Insert Into #TmpCustomer1 (SalesmanID,SalesmanName,BeatId,DSType,CustomerID,Customername)
	select Distinct SalesmanID,SalesmanName,isnull(BeatId,0),DSType,CustomerID,Customername from #TmpCustomer
	Truncate Table #TmpCustomer
	Insert Into #TmpCustomer (SalesmanID,SalesmanName,BeatId,DSType,CustomerID,Customername)
	select Distinct SalesmanID,SalesmanName,isnull(BeatId,0),DSType,CustomerID,Customername from #TmpCustomer1
	Truncate Table #TmpCustomer1

	Update T Set T.DSType = T1.DSTypeValue From 
	(Select T.SalesmanID,DS.DSTypeID,DS.DSTypeValue From dstype_master DS, dstype_Details T
	Where T.DSTypeID = DS.DSTypeID
	And isnull(DS.DSTypectlpos ,0)= 1
	) T1, #TmpCustomer T
	Where T1.SalesmanID = T.SalesmanID
	And Isnull(T.DSType,'') = ''

	Insert Into #DSTypeMaster (DSType)
	Select Distinct DSTypeValue From DSType_Master Where isnull(OCGType,0) = @OCGFlag And isnull(DStypectlpos,0) = 1

	Insert Into #DSTypeMaster (DSType)
	Select Distinct DSType From #TmpCustomer Where DSType Not In (Select Distinct DSType From #DSTypeMaster)

	Update #TmpCustomer Set DSType = Null Where DSType Not In (Select Distinct DSType From #DSTypeMaster)

	If @DS <> N'%' And @Beat = N'%'
	Begin
		Delete From #TmpCustomer Where Isnull(SalesManID,0) not In (Select Distinct SalesManID From #TmpDS)
	End
	Else If @DS <> N'%' And @Beat <> N'%'
	Begin
		Delete From #TmpCustomer Where Isnull(SalesManID,0) not In (Select Distinct SalesManID From #TmpDS)
		And Isnull(BeatID,0) not In (Select Distinct BeatID From #TmpBeat)
	End 
	Else If @DS = N'%' And @Beat <> N'%'
	Begin
		Delete From #TmpCustomer Where Isnull(BeatID,0) not In (Select Distinct BeatID From #TmpBeat)
	End

	Delete From #TmpCustomer Where DSType Not In (Select Distinct DSType From #TmpDSType)

	Update T Set T.Fromdate = G.FromDate,T.Todate = G.Todate From #TmpCustomer T,
	(Select Distinct G.OutletId,
	@MonthFirstdate Fromdate,
	@MonthTodate Todate
	from GGDROutlet G
	Where Isnull(G.Active,0) = 1
	And @MonthFirstdate Between G.ReportFromdate and G.ReportTodate) G
	Where G.OutletId = T.CustomerID

	Truncate Table #TmpOut
	Insert Into #TmpOut
	Select Distinct (cast(Isnull(C.SalesmanId,0) as Nvarchar) + ',' + 
			cast(Isnull(C.DSType,'') as Nvarchar) + ',' + 
			cast(Convert(Nvarchar(10),C.Fromdate,103) as Nvarchar) + ',' + 	
			cast(Convert(Nvarchar(10),C.Todate,103) as Nvarchar) + ',' + 	
			cast((Case When @OCGFlag = 0 Then G.CatGroup Else G.OCG End) as Nvarchar) + ',' + 	
			cast(C.CustomerID as Nvarchar) + ',' + 	
			cast(G.ProdDefnID as Nvarchar)),
	C.Customername,C.SalesmanId,C.SalesmanName,C.DSType,
	(Case 
		When G.OutletStatus = 'G' Then 'Green'
		When G.OutletStatus = 'R' Then 'Red'
		When G.OutletStatus = 'EG' Then 'Eligible for Green'
		When G.OutletStatus = 'N' Then 'Neutral' End) ,

	G.Target,

	(Case 
		When Isnull(G.TargetUOM,0) = 1 Then 'Base UOM'
		When Isnull(G.TargetUOM,0) = 2 Then 'UOM1'
		When Isnull(G.TargetUOM,0) = 3 Then 'UOM2'
		When Isnull(G.TargetUOM,0) = 4 Then 'Value' End),

	G.CatGroup,G.OCG,Null,Null,Convert(Nvarchar(10),@LastdaycloseDate,103),
	C.CustomerID,
	C.Fromdate ,
	C.Todate ,
	G.ProdDefnID,
	G.PMCatGroup, G.Flag
	from GGDROutlet G, #TmpCustomer C
	Where G.OutletID = C.CustomerID
	And Isnull(G.Active,0) = 1
	And @MonthFirstdate Between G.ReportFromdate and G.ReportTodate

/* Remove Unwanted Customer For DayClose DataPosting */
	If @ToDate IS NOT NULL
	Begin
		Delete From #TmpOut Where ID in (Select Distinct Id From #TmpOut T,GGRRFinalData G Where G.[Month] = @GGDRmonth
		And G.CustomerID = T.CustomerID And G.[DSID] = T.[DS ID] And G.DStype = T.[DS Type] And T.CustomerID Not in (Select Distinct CustomerID From #GGRRCustomer))
	End

/* Remove Unwanted Customer For Receive & Process DataPosting */
	If Isnull(@Receive,0) = 1
	Begin
		Truncate Table #GGRRCustomer
		Insert Into #GGRRCustomer
		Select Distinct CustomerID From #PendingGGRRFinalDataPost Where FromDateMonth = @GGDRmonth

		Delete From #TmpOut Where CustomerID Not in (Select Distinct CustomerID From #GGRRCustomer)
	End

	If (@OCGFlag = 0)
	Begin
		Delete From #TmpOut Where isnull(OCG,'') <> ''
	End
	Else
	Begin
		Delete From #TmpOut Where isnull([Cat GRP],'') <> ''
	End

	If (@OCGFlag = 0)
	Begin
		Insert Into #tmpCatVal
		Select ID,CustomerID,[DS Type],[Cat GRP],0 From #TmpOut
	End
	Else
	Begin
		Insert Into #tmpCatVal
		Select ID,CustomerID,[DS Type],OCG,0 From #TmpOut
	End

	Declare @V_Custid as Nvarchar(255)
	Declare @V_DSType as Nvarchar(255)
	Declare @V_catGroup as Nvarchar(255)
	Declare @ID as Int
	Declare Cur_CatVal Cursor for
	Select ID,CustID,DSType,CatGroup From #tmpCatVal
	Open Cur_CatVal
	Fetch from Cur_CatVal into @ID,@V_Custid,@V_DSType,@V_catGroup
	While @@fetch_status =0
		Begin
			If Exists(select Distinct G.GroupName from tbl_mERP_DSTypeCGMapping D,ProductCategoryGroupAbstract G ,DSType_Master DS
			Where D.DSTypeId = DS.DSTypeId And D.Active = 1 And DS.DSTypeId = D.DSTypeId And Ds.DSTypeCtlPos = 1
			And D.GroupID = G.GroupID And G.OcgType = @OCGFlag --And DS.OcgType = @OCGFlag
			And DS.DSTypeValue = @V_DSType And G.GroupName = @V_catGroup)
			Begin
				Update #tmpCatVal Set Status = 1 Where ID = @ID
			End
			Fetch Next from Cur_CatVal into @ID,@V_Custid,@V_DSType,@V_catGroup
		End
	Close Cur_CatVal
	Deallocate Cur_CatVal

	If @RecdDSType <> N'%'
	Begin
		Delete From #TmpOut Where Id In(Select ID From #tmpCatVal Where isnull(Status,0) = 0) And isnull([Ds Type],'') in (Select Distinct  DSTypeValue From DSType_Master Where isnull(OcgType,0) = @OCGFlag)
	End
	Else
	Begin
		Delete From #TmpOut Where isnull([Ds Type],'') <> '' and Id In(Select ID From #tmpCatVal Where isnull(Status,0) = 0) And isnull([Ds Type],'') in (Select Distinct  DSTypeValue From DSType_Master Where isnull(OcgType,0) = @OCGFlag)
	End


/* Status Validation Start */

	Create Table #OutData (SalesManId Int,
	DSType nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ProdDefnID Int,
	CategoryGroup nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	OutletStatus nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CurrentStatus nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
	C_Actual Decimal(18,6))

	Create Table #FinalOut (SalesManId Int,
	DSType nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	C_Target Decimal(18,6),
	C_Actual Decimal(18,6),
	ProdDefnID Int,
	CategoryGroup nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	OutletStatus nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CurrentStatus nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
	PMCategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

	Create Table #output (Salesmanid int,DSType nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS, CTarget Decimal(18,6),CTargetUOM Int,CsalesValue Decimal(18,6),ProdDefnID int,SDProductCode Nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,SDProductLevel int,Target decimal(18,6),TargetUOM int,MTDSales decimal(18,6),ProductFlag Nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,CategoryGroup Nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,OutletStatus Nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,CurrentStatus Nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,PMCategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

	Declare @OCGGlag As Int

	Set @OCGGlag = (Select Top 1 isnull(Flag,0) from tbl_merp_Configabstract Where ScreenCode = 'OCGDS')
	If @IsRepost=1
	Begin
		Select @LastdaycloseDate = Dbo.Stripdatefromtime(@ToDate)
	End
	Else
	Begin
		Set @LastdaycloseDate = (select Top 1 LastInventoryUpload from SetUp)
	End
	Create Table #HHDS (SalesmanID int,CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Create Table #ProductwiseDet (Salesmanid int,DSType nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS, ProdDefnID int,SDProductCode nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,SalesValue decimal(18,6),CSalesValue decimal(18,6))

	Insert into #HHDS
	Select Distinct S.SalesmanID,C.CustomerID From 
	Beat_Salesman BS, Salesman S, Beat B,Customer C,DSType_Details dd, DSType_Master dm
	Where 
	DD.SalesmanID=S.SalesmanID And
	S.SalesmanId = BS.SalesmanId And 
	dd.DSTypeID = dm.DSTypeID And 
	C.CustomerID = BS.CustomerID And 
	B.BeatId = BS.BeatId

	Insert into #HHDS
	Select Distinct GD.DSID,G.OutletId 
	From GGDROutlet G,GGDRData GD
	Where 
	G.OutletID = GD.RetailerCode And
	G.ProdDefnID = GD.ProdDefnID And
	Isnull(G.Active,0) = 1 And @MonthFirstdate Between G.ReportFromdate and G.ReportTodate And
	GD.InvoiceDate Between  @MonthFirstdate And @MonthTodate 
	And (Cast(GD.DSID as Nvarchar)+':'+ G.OutletId) Not in (Select Distinct (Cast(SalesmanID as Nvarchar)+':'+ CustomerID) From #HHDS)


/* Remove Unwanted Customer For DayClose DataPosting */
	If @ToDate IS NOT NULL
	Begin
		Delete From #HHDS Where CustomerID Not in (Select Distinct CustomerID From #GGRRCustomer)
	End

/* Remove Unwanted Customer For Receive & Process DataPosting */
	If Isnull(@Receive,0) = 1
	Begin
		Truncate Table #GGRRCustomer
		Insert Into #GGRRCustomer
		Select Distinct CustomerID From #PendingGGRRFinalDataPost Where FromDateMonth = @GGDRmonth

		Delete From #HHDS Where CustomerID Not in (Select Distinct CustomerID From #GGRRCustomer)
	End


	Delete From #output
	Insert into #output (Salesmanid,DSType,CustomerID,CTarget,CTargetUOM,CsalesValue,ProdDefnID,SDProductCode,SDProductLevel,Target,TargetUOM,MTDSales,ProductFlag,CategoryGroup,OutletStatus,PMCategory)
	Select Distinct HS.SalesmanID,GD.DSType,G.OutletId as CustomerID,Isnull(G.Target,0),Isnull(G.TargetUOM,0),0 as CsalesValue,G.ProdDefnID,GP.Products as SDProductCode,GP.ProdCatLevel,GP.Target,GP.TargetUOM,
	0  as MTDSales,
	GP.ProductFlag,
	Isnull((Case When @OCGGlag = 0 Then G.CatGroup When @OCGGlag = 1 Then G.OCG End),'All') as CategoryGroup,G.outletStatus,G.PMCatGroup
	From GGDROutlet G,GGDRData GD,#HHDS HS,GGDRProduct GP
	Where 
	G.OutletID = GD.RetailerCode And
	G.ProdDefnID = GP.ProdDefnID And
--	GD.ProdDefnID = G.ProdDefnID And
	HS.CustomerID = G.OutletID And
	HS.SalesmanID = GD.DSID And
	Isnull(G.Active,0) = 1 And @MonthFirstdate Between G.ReportFromdate and G.ReportTodate And
	GD.InvoiceDate Between  @MonthFirstdate And @MonthTodate 

	--Division
	Insert into #ProductwiseDet (Salesmanid,DSType,CustomerID, ProdDefnID,SDProductCode,SalesValue,CsalesValue)
	Select GD.DSID as SalesmanID,GD.DSType,GD.RetailerCode as CustomerID,GD.ProdDefnId,GP.Products,
	Cast((Sum(Case 
		When GP.TargetUOM = 2 Then (GD.SalesVolume / Isnull(I.UOM1_Conversion,1))
		When GP.TargetUOM = 3 Then (GD.SalesVolume / Isnull(I.UOM2_Conversion,1))
		When GP.TargetUOM = 1 Then (GD.SalesVolume)
		When GP.TargetUOM = 4 Then (GD.Salesvalue) 
	End)) as Decimal(18,6)) MTDSales,
	Cast((Sum(Case 
		When O.CTargetUOM = 2 Then (GD.SalesVolume / Isnull(I.UOM1_Conversion,1))
		When O.CTargetUOM = 3 Then (GD.SalesVolume / Isnull(I.UOM2_Conversion,1))
		When O.CTargetUOM = 1 Then (GD.SalesVolume)
		When O.CTargetUOM = 4 Then (GD.Salesvalue) 
	End)) as Decimal(18,6)) CSalesValue
	From GGDRData GD,GGDRProduct GP, #output O,#Items I,GGDROutlet G
	Where 
    G.OutletID = GD.RetailerCode And
	G.ProdDefnID = GD.ProdDefnID And
    O.CustomerID = G.OutletID And
    G.ProdDefnID =GP.ProdDefnID And
	Isnull(G.Active,0) = 1 And
	GD.ProdDefnID = GP.ProdDefnID And 
	GD.RetailerCode = O.CustomerID And
	GD.DSID=O.SalesmanID And
	GD.DSType = O.DSType And
	GD.ProdDefnID=O.ProdDefnID And
	O.SDProductCode=GP.Products And
	GD.SystemSKU=I.Product_code And
	Gp.Products <>'ALL' And
	GP.ProdCatLevel=2 And
	Gp.Products = GD.Division and @MonthFirstdate Between G.ReportFromdate and G.ReportTodate And
	GD.InvoiceDate Between  @MonthFirstdate And @MonthTodate 
	Group by GD.DSID,GD.DSType,GD.RetailerCode,GD.ProdDefnId,GP.Products

	--SubCategory
	Insert into #ProductwiseDet (Salesmanid,DSType,CustomerID, ProdDefnID,SDProductCode,SalesValue,CsalesValue)
	Select GD.DSID as SalesmanID,GD.DSType,GD.RetailerCode as CustomerID,GD.ProdDefnId,GP.Products,
	Cast((Sum(Case 
		When GP.TargetUOM = 2 Then (GD.SalesVolume / Isnull(I.UOM1_Conversion,1))
		When GP.TargetUOM = 3 Then (GD.SalesVolume / Isnull(I.UOM2_Conversion,1))
		When GP.TargetUOM = 1 Then (GD.SalesVolume)
		When GP.TargetUOM = 4 Then (GD.Salesvalue) 
	End)) as Decimal(18,6)) MTDSales,
	Cast((Sum(Case 
		When O.CTargetUOM = 2 Then (GD.SalesVolume / Isnull(I.UOM1_Conversion,1))
		When O.CTargetUOM = 3 Then (GD.SalesVolume / Isnull(I.UOM2_Conversion,1))
		When O.CTargetUOM = 1 Then (GD.SalesVolume)
		When O.CTargetUOM = 4 Then (GD.Salesvalue) 
	End)) as Decimal(18,6)) CSalesValue
	From GGDRData GD,GGDRProduct GP, #output O,#Items I,GGDROutlet G
	Where 
    G.OutletID = GD.RetailerCode And
	G.ProdDefnID = GD.ProdDefnID And
    O.CustomerID = G.OutletID And
    G.ProdDefnID =GP.ProdDefnID And
	Isnull(G.Active,0) = 1 And
	GD.ProdDefnID = GP.ProdDefnID And 
	GD.RetailerCode = O.CustomerID And
	GD.DSID=O.SalesmanID And
	GD.DSType = O.DSType And
	GD.ProdDefnID=O.ProdDefnID And
	O.SDProductCode=GP.Products And
	GD.SystemSKU=I.Product_code And
	Gp.Products <>'ALL' And
	GP.ProdCatLevel=3 And
	Gp.Products = GD.SubCategory and @MonthFirstdate Between G.ReportFromdate and G.ReportTodate And
	GD.InvoiceDate Between  @MonthFirstdate And @MonthTodate 
	Group by GD.DSID,GD.DSType,GD.RetailerCode,GD.ProdDefnId,GP.Products

	--MarketSKU
	Insert into #ProductwiseDet (Salesmanid,DSType,CustomerID, ProdDefnID,SDProductCode,SalesValue,CsalesValue)
	Select GD.DSID as SalesmanID,GD.DSType,GD.RetailerCode as CustomerID,GD.ProdDefnId,GP.Products,
	Cast((Sum(Case 
		When GP.TargetUOM = 2 Then (GD.SalesVolume / Isnull(I.UOM1_Conversion,1))
		When GP.TargetUOM = 3 Then (GD.SalesVolume / Isnull(I.UOM2_Conversion,1))
		When GP.TargetUOM = 1 Then (GD.SalesVolume)
		When GP.TargetUOM = 4 Then (GD.Salesvalue) 
	End)) as Decimal(18,6)) MTDSales,
	Cast((Sum(Case 
		When O.CTargetUOM = 2 Then (GD.SalesVolume / Isnull(I.UOM1_Conversion,1))
		When O.CTargetUOM = 3 Then (GD.SalesVolume / Isnull(I.UOM2_Conversion,1))
		When O.CTargetUOM = 1 Then (GD.SalesVolume)
		When O.CTargetUOM = 4 Then (GD.Salesvalue) 
	End)) as Decimal(18,6)) CSalesValue
	From GGDRData GD,GGDRProduct GP, #output O,#Items I,GGDROutlet G
	Where 
	G.OutletID = GD.RetailerCode And
	G.ProdDefnID = GD.ProdDefnID And
    O.CustomerID = G.OutletID And
    G.ProdDefnID =GP.ProdDefnID And
	Isnull(G.Active,0) = 1 And
	GD.ProdDefnID = GP.ProdDefnID And 
	GD.RetailerCode = O.CustomerID And
	GD.DSID=O.SalesmanID And
	GD.DSType = O.DSType And
	GD.ProdDefnID=O.ProdDefnID And
	O.SDProductCode=GP.Products And
	GD.SystemSKU=I.Product_code And
	Gp.Products <>'ALL' And
	GP.ProdCatLevel=4 And
	Gp.Products = GD.MarketSKU and @MonthFirstdate Between G.ReportFromdate and G.ReportTodate And
	GD.InvoiceDate Between  @MonthFirstdate And @MonthTodate 
	Group by GD.DSID,GD.DSType,GD.RetailerCode,GD.ProdDefnId,GP.Products

	--SystemSKU
	Insert into #ProductwiseDet (Salesmanid,DSType,CustomerID, ProdDefnID,SDProductCode,SalesValue,CsalesValue)
	Select GD.DSID as SalesmanID,GD.DSType,GD.RetailerCode as CustomerID,GD.ProdDefnId,GP.Products,
	Cast((Sum(Case 
		When GP.TargetUOM = 2 Then (GD.SalesVolume / Isnull(I.UOM1_Conversion,1))
		When GP.TargetUOM = 3 Then (GD.SalesVolume / Isnull(I.UOM2_Conversion,1))
		When GP.TargetUOM = 1 Then (GD.SalesVolume)
		When GP.TargetUOM = 4 Then (GD.Salesvalue) 
	End)) as Decimal(18,6)) MTDSales,
	Cast((Sum(Case 
		When O.CTargetUOM = 2 Then (GD.SalesVolume / Isnull(I.UOM1_Conversion,1))
		When O.CTargetUOM = 3 Then (GD.SalesVolume / Isnull(I.UOM2_Conversion,1))
		When O.CTargetUOM = 1 Then (GD.SalesVolume)
		When O.CTargetUOM = 4 Then (GD.Salesvalue) 
	End)) as Decimal(18,6)) CSalesValue
	From GGDRData GD,GGDRProduct GP, #output O,#Items I,GGDROutlet G
	Where 
	G.OutletID = GD.RetailerCode And
	G.ProdDefnID = GD.ProdDefnID And
    O.CustomerID = G.OutletID And
    G.ProdDefnID =GP.ProdDefnID And
	Isnull(G.Active,0) = 1 And
	GD.ProdDefnID = GP.ProdDefnID And 
	GD.RetailerCode = O.CustomerID And
	GD.DSID=O.SalesmanID And
	GD.DSType = O.DSType And
	GD.ProdDefnID=O.ProdDefnID And
	O.SDProductCode=GP.Products And
	GD.SystemSKU=I.Product_code And
	Gp.Products <>'ALL' And
	GP.ProdCatLevel=5 And
	Gp.Products = GD.SystemSKU and @MonthFirstdate Between G.ReportFromdate and G.ReportTodate And
	GD.InvoiceDate Between  @MonthFirstdate And @MonthTodate 
	Group by GD.DSID,GD.DSType,GD.RetailerCode,GD.ProdDefnId,GP.Products

	
	 
	--ALL
	Insert into #ProductwiseDet (Salesmanid,DSType,CustomerID, ProdDefnID,SDProductCode,SalesValue,CsalesValue)
	Select GD.DSID as SalesmanID,GD.DSType,GD.RetailerCode as CustomerID,GD.ProdDefnId,GP.Products,
	Cast((Sum(Case 
		When GP.TargetUOM = 2 Then (GD.SalesVolume / Isnull(I.UOM1_Conversion,1))
		When GP.TargetUOM = 3 Then (GD.SalesVolume / Isnull(I.UOM2_Conversion,1))
		When GP.TargetUOM = 1 Then (GD.SalesVolume)
		When GP.TargetUOM = 4 Then (GD.Salesvalue) 
	End)) as Decimal(18,6)) MTDSales,
	Cast((Sum(Case 
		When O.CTargetUOM = 2 Then (GD.SalesVolume / Isnull(I.UOM1_Conversion,1))
		When O.CTargetUOM = 3 Then (GD.SalesVolume / Isnull(I.UOM2_Conversion,1))
		When O.CTargetUOM = 1 Then (GD.SalesVolume)
		When O.CTargetUOM = 4 Then (GD.Salesvalue) 
	End)) as Decimal(18,6)) CSalesValue
	From GGDRData GD,GGDRProduct GP, #output O,#Items I,GGDROutlet G
	Where 
	G.OutletID = GD.RetailerCode And
	G.ProdDefnID = GD.ProdDefnID And
    O.CustomerID = G.OutletID And
    G.ProdDefnID =GP.ProdDefnID And
	Isnull(G.Active,0) = 1 And
	GD.RetailerCode = O.CustomerID And 
	GD.DSID=O.SalesmanID And
	GD.CategoryGroup=O.CategoryGroup And
	GD.DSType = O.DSType And
	GD.ProdDefnID = GP.ProdDefnID And 
	GD.ProdDefnID=O.ProdDefnID And	
	O.SDProductCode=GP.Products And
	GD.SystemSKU=I.Product_code And
	Gp.Products ='ALL' and @MonthFirstdate Between G.ReportFromdate and G.ReportTodate And
	GD.InvoiceDate Between  @MonthFirstdate And @MonthTodate 
	Group by GD.DSID,GD.DSType,GD.RetailerCode,GD.ProdDefnId,GP.Products

	update O Set O.MTDSales= P.salesvalue,O.CSalesValue = P.CsalesValue from #output O,
	(Select Salesmanid,DSType,CustomerID, ProdDefnID,SDProductCode,Sum(SalesValue) SalesValue,Sum(CsalesValue)CsalesValue From #ProductwiseDet
	Group By Salesmanid,DSType,CustomerID, ProdDefnID,SDProductCode) P
	Where O.Salesmanid=P.SalesmanID And
	O.DSType = P.DSType And
	O.CustomerID = P.CustomerID And
	O.ProdDefnID=P.ProdDefnID And
	o.SDProductCode = P.SDProductCode
	
	Update T Set T.SDProductCode = V.category_ID From #output T, V_Category_Master V
	Where V.Category_Name = T.SDProductCode And V.[Level] = T.SDProductLevel And T.SDProductLevel In (2,3,4)
	And T.SDProductCode <>'ALL'

	Delete From #FinalOut
	Insert Into #FinalOut (SalesManId,DSType,CustomerID,C_Target,C_Actual,ProdDefnID,CategoryGroup,OutletStatus,PMCategory)
	Select Distinct SalesManId,DSType,CustomerID,CTarget,0,ProdDefnID,CategoryGroup,OutletStatus,PMCategory From #output
	Order By SalesManId,CustomerID

	Update T set T.C_Actual = T1.CsalesValue From #FinalOut T,
	(Select Distinct SalesManId,DSType,CustomerID,ProdDefnID,Sum(Isnull(CsalesValue,0)) CsalesValue From #output
	Group By SalesManId,DSType,CustomerID,ProdDefnID) T1
	Where T.SalesManId= T1.SalesManId
	And T.DSType = T1.DSType
	And T.CustomerID = T1.CustomerID
	And T.ProdDefnID = T1.ProdDefnID


	
	Declare @T_SalesManId As Int
	Declare @T_CustomerID As Nvarchar(255)
	Declare @T_DSType As Nvarchar(255)
	Declare @T_ProdDefnID As Int
	Declare @T_CategoryGroup As Nvarchar(255)
	Declare @T_OutletStatus As Nvarchar(255)
	Declare @ReturnStatus As int
	Declare @C_Target as Decimal(18,6)
	Declare @C_Actual as Decimal(18,6)
	Declare @T_PMCategory as Nvarchar(255)

	Declare GGDRStatus_Cur Cursor for
	Select SalesManId,DSType,CustomerID,ProdDefnID,CategoryGroup,OutletStatus,C_Target,C_Actual,PMCategory From #FinalOut --Group By SalesManId,DSType,CustomerID,ProdDefnID,CategoryGroup,OutletStatus,C_Target
	Open GGDRStatus_Cur
	Fetch from GGDRStatus_Cur into @T_SalesManId,@T_DSType,@T_CustomerID,@T_ProdDefnID,@T_CategoryGroup,@T_OutletStatus,@C_Target,@C_Actual,@T_PMCategory
	While @@fetch_status =0
		Begin
			Truncate Table #TFinalOut
			Insert Into #TFinalOut
			Select SDProductCode,Target,MTDSales,CSalesValue,0 From #output 
			Where SalesManId = @T_SalesManId And DSType = @T_DSType And CustomerID = @T_CustomerID And ProdDefnID = @T_ProdDefnID
			And CategoryGroup = @T_CategoryGroup And OutletStatus = @T_OutletStatus

			Update #TFinalOut Set Status = 1 Where Isnull(Actual,0) >= Isnull(Target ,0) And Isnull(Target ,0) <> 0

			Set @ReturnStatus = 0

			If (Select Count(*) From #TFinalOut Where isnull(Target,0) <> 0) > 0
			Begin
				If (select Count(*) from #TFinalOut Where isnull(Status,0) = 0 And isnull(Target,0) <> 0) <> 0
				Begin
					Set @ReturnStatus = 0
				End
				Else If (select Count(*) from #TFinalOut Where isnull(Status,0) = 0 And isnull(Target,0) <> 0) = 0
				Begin
					Set @ReturnStatus = 1
				End
			End
			Else If (Select Count(*) From #TFinalOut Where isnull(Target,0) <> 0) = 0
			Begin
				Set @ReturnStatus = 1
			End

			If @T_OutletStatus = 'R'
			Begin
				Truncate Table #PMCategory
					If Isnull(@OCGGlag,0) = 0
					Begin
						Insert into #PMCategory (CustCat,PMCategory)
						Select A.ItemValue ,B.CategoryGroup From (Select Distinct ItemValue From dbo.sp_splitin2Rows(@T_PMCategory,'|')) A
						Left Outer Join #FinalOut B
						On B.SalesmanID = @T_SalesManId and B.DSType = @T_DSType and B.CustomerID = @T_CustomerID And B.OutletStatus = 'R'
						And A.ItemValue = B.CategoryGroup
						And B.PMcategory = @T_PMCategory
					End
					Else
					Begin
						Insert into #PMCategory (CustCat,PMCategory)
						Select B.OCG,A.ItemValue From 
						(select Distinct OCG from #TmpOut
						Where [DS ID] = @T_SalesManId and [DS Type] = @T_DSType and CustomerID = @T_CustomerID And Status = 'Red' And PMcategory = @T_PMCategory ) B
						Left Outer join (Select Distinct ItemValue From dbo.sp_splitin2Rows(@T_PMCategory,'|')) A
						On A.ItemValue = Left(B.OCG,3)
					End
				End
				Else
			Begin
				Truncate Table #PMCategory
					If Isnull(@OCGGlag,0) = 0
					Begin
						Insert into #PMCategory (CustCat,PMCategory)
						Select A.ItemValue ,B.CategoryGroup From (Select Distinct ItemValue From dbo.sp_splitin2Rows(@T_PMCategory,'|')) A
						Left Outer Join #FinalOut B
						On B.SalesmanID = @T_SalesManId and B.DSType = @T_DSType and B.CustomerID = @T_CustomerID --And B.OutletStatus = 'R'
						And A.ItemValue = B.CategoryGroup
						And B.PMcategory = @T_PMCategory
					End
					Else
					Begin
						Insert into #PMCategory (CustCat,PMCategory)
						Select B.OCG,A.ItemValue From 
						(select Distinct OCG from #TmpOut
						Where [DS ID] = @T_SalesManId and [DS Type] = @T_DSType and CustomerID = @T_CustomerID And Status <> 'Red' And PMcategory = @T_PMCategory ) B
						Left Outer join (Select Distinct ItemValue From dbo.sp_splitin2Rows(@T_PMCategory,'|')) A
						On A.ItemValue = Left(B.OCG,3)
					End
				End

			If @T_OutletStatus = 'R'
			Begin
				Set @C_Actual = (Select Sum(Isnull(C_Actual,0)) From #FinalOut 
				Where SalesmanID = @T_SalesManId and DSType = @T_DSType and CustomerID = @T_CustomerID And OutletStatus = 'R' And PMcategory = @T_PMCategory
				And CategoryGroup In (Select Distinct CustCat From #PMCategory))

/* Red customer target Also Combined based on PMCategory */

				If @OCGFlag = 1
				Begin
					Set @C_Target = (Select Sum(Isnull(Target,0)) From #TmpOut 
					Where [DS ID] = @T_SalesManId and [DS Type] = @T_DSType and CustomerID = @T_CustomerID And Status = 'Red' And PMcategory = @T_PMCategory
					And OCG In (Select Distinct CUSTCAT From #PMCategory) And Status = 'Red')				
				End
				Else
				Begin
					Set @C_Target = (Select Sum(Isnull(Target,0)) From #TmpOut 
					Where [DS ID] = @T_SalesManId and [DS Type] = @T_DSType and CustomerID = @T_CustomerID And Status = 'Red' And PMcategory = @T_PMCategory
					And [Cat GRP] In (Select Distinct PMCategory From #PMCategory) And Status = 'Red')				
				End
			End

			If @ReturnStatus = 1
			Begin
				If isnull(@C_Actual,0) >= isnull(@C_Target,0)
				Begin
					Update #FinalOut Set CurrentStatus = 
					(Case 
						When (@T_OutletStatus = 'R') Then 'N'
						When (@T_OutletStatus = 'EG') Then 'G'
						Else  @T_OutletStatus
					End) Where SalesManId = @T_SalesManId And DSType = @T_DSType And CustomerID = @T_CustomerID And ProdDefnID = @T_ProdDefnID And PMcategory = @T_PMCategory
					And CategoryGroup = @T_CategoryGroup And OutletStatus = @T_OutletStatus
				End
			End

			Fetch Next from GGDRStatus_Cur into @T_SalesManId,@T_DSType,@T_CustomerID,@T_ProdDefnID,@T_CategoryGroup,@T_OutletStatus,@C_Target,@C_Actual,@T_PMCategory
		End
	Close GGDRStatus_Cur
	Deallocate GGDRStatus_Cur

	Update #FinalOut Set CurrentStatus = OutletStatus Where Isnull(CurrentStatus,'') = ''

	Delete From #OutData
	Insert Into #OutData
	Select Distinct SalesManId,DSType,CustomerID,ProdDefnID,CategoryGroup,OutletStatus,CurrentStatus,C_Actual From #FinalOut

	If (@OCGFlag = 0)
	Begin 
		Update T Set T.Actual = Isnull(T1.C_Actual,0),
		T.[Current Status] = (Case 
			When T1.CurrentStatus = 'G' Then 'Green'
			When T1.CurrentStatus = 'R' Then 'Red'
			When T1.CurrentStatus = 'EG' Then 'Eligible for Green'
			When T1.CurrentStatus = 'N' Then 'Neutral' End)
		From  #TmpOut T,(Select SalesManId,DSType,CustomerID,ProdDefnID,CategoryGroup,OutletStatus,CurrentStatus,Sum(C_Actual) C_Actual
		From #OutData Group By SalesManId,DSType,CustomerID,ProdDefnID,CategoryGroup,OutletStatus,CurrentStatus) T1
		Where T.[DS ID] = T1.SalesManId 
		And T.[DS Type] = T1.DSType
		And T.[Cat GRP] = T1.CategoryGroup
		And T.[CustomerID] = T1.CustomerID
		And T.ProdDefnID = T1.ProdDefnID
	End
	Else
	Begin 
		Update T Set T.Actual = Isnull(T1.C_Actual,0),
		T.[Current Status] = (Case 
			When T1.CurrentStatus = 'G' Then 'Green'
			When T1.CurrentStatus = 'R' Then 'Red'
			When T1.CurrentStatus = 'EG' Then 'Eligible for Green'
			When T1.CurrentStatus = 'N' Then 'Neutral' End)
		From  #TmpOut T,(Select SalesManId,DSType,CustomerID,ProdDefnID,CategoryGroup,OutletStatus,CurrentStatus,C_Actual From #OutData) T1
		Where T.[DS ID] = T1.SalesManId 
		And T.[DS Type] = T1.DSType
		And T.[OCG] = T1.CategoryGroup
		And T.[CustomerID] = T1.CustomerID
		
	End

	Update #TmpOut Set [Current Status] = Status Where Isnull([Current Status],'') = ''

Drop Table #OutData
Drop Table #FinalOut
Drop Table #output
Drop Table #HHDS
/* Status Validation End */

/* Transaction Based Salesman dataPosting Validation removed. */
	Delete From #TmpOut Where [DS ID] in (Select Distinct SalesManId From SalesMan 
	Where isnull(Active,0) = 0 )-- And SalesManId Not In (Select Distinct DSID From GGDRData Where InvoiceDate BetWeen @MonthFirstdate And @MonthTodate))

	Insert Into #Statusval
	Select Distinct [DS ID],[DS Type],[CustomerID],(Case When @OCGFlag = 0 Then [Cat GRP] Else Left(OCG,3) End) Cat,[Status],[Current Status],Null,Actual,PMCategory From #TmpOut

	Declare @F_DSId as Int
	Declare @F_DSType as Nvarchar(255)
	Declare @F_Customerid  as Nvarchar(255)
	Declare @F_Status  as Nvarchar(255)
	Declare @F_CStatus  as Nvarchar(255)
	Declare @F_PMCategory  as Nvarchar(255)

/* Red Customer is meet one category group into pmcategory then next one also status converted. */
	Declare @Cat as Nvarchar(255)
	Insert Into #CatGrpp Values ('GR1')
	Insert Into #CatGrpp Values ('GR3')


	Declare Cur_A Cursor for
	Select Distinct [DS Id],[DS Type],Customerid,(Case When @OCGFlag = 0 Then [Cat GRP] Else Left(OCG,3) End) Cat,[Current status] From #TmpOut Where Status = 'Red'
	Open Cur_A
	Fetch from Cur_A into @F_DSId,@F_DSType,@F_Customerid,@Cat,@F_CStatus
	While @@fetch_status =0
			Begin
				If Exists (Select Top 1 Isnull(Actual,0) From #Statusval Where DSId= @F_DSId And DSType = @F_DSType And Customerid = @F_Customerid and Curstatus = 'Neutral' And CatGroup in (Select Distinct Cat From #CatGrpp) And Isnull(Actual,0) > 0)
				Begin
					Update #TmpOut Set [Current Status] = 'Neutral' 
					Where [DS ID]= @F_DSId And [DS Type] = @F_DSType And Customerid = @F_Customerid And [Status] = 'Red' And 
					(Case When @OCGFlag = 0 Then [Cat GRP] Else Left(OCG,3) End) in (Select Distinct Cat From #CatGrpp)
				End		
			Fetch Next from Cur_A into @F_DSId,@F_DSType,@F_Customerid,@Cat,@F_CStatus
		End
	Close Cur_A
	Deallocate Cur_A
	
/* Red Customers are not validated all received category groups are converted or not. */
	Declare Cur_F Cursor for
	Select Distinct DSId,DSType,Customerid,Status,Curstatus,PMCategory From #Statusval Where Status <> 'Red'
	Open Cur_F
	Fetch from Cur_F into @F_DSId,@F_DSType,@F_Customerid,@F_Status,@F_CStatus,@F_PMCategory
	While @@fetch_status =0
			Begin
				If Exists(Select Top 1 Curstatus From #Statusval Where DSId= @F_DSId And DSType = @F_DSType And Customerid = @F_Customerid And [Status] <> 'Red' and Curstatus = @F_Status And PMCategory = @F_PMCategory)
				Begin
					Update #TmpOut Set [Current Status] = [Status] 
					Where [DS ID]= @F_DSId And [DS Type] = @F_DSType And Customerid = @F_Customerid And [Status] <> 'Red' And PMCategory = @F_PMCategory
				End		
			Fetch Next from Cur_F into @F_DSId,@F_DSType,@F_Customerid,@F_Status,@F_CStatus,@F_PMCategory
		End
	Close Cur_F
	Deallocate Cur_F


/* EG Category Changes starts */
select * into #TmpOut_dump from #TmpOut

/* To get the data for EG customer to check Catgeory wise slaes is achieved */
Create Table #EGCustomer (SalesManId Int,
DSType nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
ProdDefnID Int,
OutletStatus nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,
CurrentStatus nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,
ProductDesc nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
ProdTarget decimal(18,6),
ProdActual decimal(18,6),
PMCategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
ConvertNow int)

/* Select only Non Converted EG customers*/
Insert into #EGCustomer(SalesManId,DSType,CustomerID,ProdDefnID,OutletStatus,CurrentStatus,PMCategory,ProductDesc,ProdTarget,ProdActual)
Select EC.[DS ID] ,EC.[DS Type],EC.CustomerID,EC.ProdDefnID,EC.Status,EC.[Current Status],EC.PMCategory,P.Products,P.Target,0 from #TmpOut_dump EC,GGDRProduct P
where EC.[Current Status]='Eligible for Green'
And EC.ProdDefnID=P.ProdDefnID
And isnull(P.IsExcluded,0)=0

/*Update Product wise Actual Totals*/
update E set E.ProdActual=P.SalesValue from #EGCustomer E,#ProductwiseDet P
Where E.SalesManId=P.Salesmanid
And E.CustomerID=P.CustomerID
And E.DSType=P.DSType
And E.ProdDefnID=P.ProdDefnID
And E.ProductDesc=P.SDProductCode

/* For Checking*/
--Update #EGCustomer set ProdActual=ProdTarget

-- To get duplicate rows having same target and Current Status has Eligible For Green 
Select A.salesmanid,A.DSType,A.CustomerID,A.PMCategory,A.ProductDesc,A.ProdTarget into #tmpEG 
from #EGCustomer A
Group by A.salesmanid,A.DSType,A.CustomerID,A.PMCategory,A.ProductDesc,A.ProdTarget
having COUNT(*) >1

Declare @EGDSID int
Declare @DEGSType nvarchar(255)
Declare @EGCusId nvarchar(255)
Declare @EGPMCat nvarchar(255)
Declare @EGProdDesc nvarchar(255)
Declare @EGProdDefnID int
Declare @EGProdTarget decimal(18,6)

Declare AllEGCus Cursor For Select salesmanid,DSType,CustomerID,PMCategory,ProductDesc,ProdTarget From #tmpEG order by salesmanid,DSType,CustomerID,PMCategory
Open AllEGCus
Fetch From AllEGCus into @EGDSID,@DEGSType,@EGCusId,@EGPMCat,@EGProdDesc,@EGProdTarget
While @@FETCH_STATUS=0
BEGIN
	/*If any of the Customer and DS achieved the target in the specified Category, proceed further*/
	
	If (select SUM(isnull(ProdActual,0)) from #EGCustomer where salesmanid=@EGDSID And DSType=@DEGSType And CustomerID=@EGCusId And PMCategory=@EGPMCat and 
	ProductDesc=@EGProdDesc)>=@EGProdTarget
	BEGIN
		select distinct ProdDefnID into #tmpPD from #EGCustomer where salesmanid=@EGDSID And DSType=@DEGSType And CustomerID=@EGCusId And PMCategory=@EGPMCat 
		Declare @Pd int
		Declare @TmpActual int
		Declare @TmpAchieved int
		Declare AllPD cursor For Select ProdDefnID from #tmpPD
		Open AllPD
		Fetch from AllPD into @Pd
		While @@FETCH_STATUS=0
		BEGIN
			Set @TmpActual=0
			Set @TmpAchieved=0
			select @TmpActual= count('x') from #EGCustomer where salesmanid=@EGDSID And DSType=@DEGSType And CustomerID=@EGCusId And PMCategory=@EGPMCat and 
			ProductDesc<>@EGProdDesc and ProdDefnID=@Pd

			select @TmpAchieved= count('x') from #EGCustomer where salesmanid=@EGDSID And DSType=@DEGSType And CustomerID=@EGCusId And PMCategory=@EGPMCat and 
			ProductDesc<>@EGProdDesc and ProdDefnID=@Pd and ProdActual >=ProdTarget		
			
			If (@TmpAchieved>=@TmpActual)
			BEGIN
				update #EGCustomer set ConvertNow=1 where salesmanid=@EGDSID And DSType=@DEGSType And CustomerID=@EGCusId And PMCategory=@EGPMCat 
				and ProdDefnID=@Pd 
			END
			Fetch Next from AllPD into @Pd
		END
		Close AllPD
		Deallocate AllPD
		Drop Table #tmpPD
	END	  
	Fetch Next From AllEGCus into @EGDSID,@DEGSType,@EGCusId,@EGPMCat,@EGProdDesc,@EGProdTarget
	
END
Close AllEGCus
Deallocate AllEGCus
 
/* To get the list of Converted customers and check whether all category is converted to make the customer green */ 
Select T2.* into #FinalEG from (Select A.salesmanid,A.DSType,A.CustomerID,A.PMCategory,A.ProductDesc,A.ProdTarget
from #tmpEG A
Group by A.salesmanid,A.DSType,A.CustomerID,A.PMCategory,A.ProductDesc,A.ProdTarget) T1,
(Select A.salesmanid,A.DSType,A.CustomerID,A.PMCategory,A.ProductDesc,A.ProdTarget,A.ProdDefnID,A.ConvertNow
from #EGCustomer A
Group by A.salesmanid,A.DSType,A.CustomerID,A.PMCategory,A.ProductDesc,A.ProdTarget,A.ProdDefnID,A.ConvertNow) T2
Where T1.salesmanid=T2.SalesManId
And T1.DSType=T2.DSType
And T1.CustomerID=T2.CustomerID
And T1.PMCategory=T2.PMCategory

Declare FinalEGCustomers Cursor For Select distinct salesmanid,DSType,CustomerID,PMCategory from #FinalEG
Open FinalEGCustomers
Fetch from FinalEGCustomers into @EGDSID,@DEGSType,@EGCusId,@EGPMCat
While @@fetch_status=0
BEGIN
	if(select COUNT(*) from #FinalEG where salesmanid=@EGDSID And DSType=@DEGSType And CustomerID=@EGCusId And PMCategory=@EGPMCat and isnull(convertnow,0)=1)
	>= (select COUNT(*) from #FinalEG where salesmanid=@EGDSID And DSType=@DEGSType And CustomerID=@EGCusId And PMCategory=@EGPMCat)
	Update #TmpOut set [Current Status]='Green' where [DS ID]=@EGDSID and [DS Type]=@DEGSType and CustomerID=@EGCusId and PMCategory=@EGPMCat
	And [Current Status]='Eligible for Green'
	Fetch Next from FinalEGCustomers into @EGDSID,@DEGSType,@EGCusId,@EGPMCat
END
Close FinalEGCustomers
Deallocate FinalEGCustomers

Drop Table #ProductwiseDet
Drop Table #EGCustomer
Drop Table #TmpOut_dump
Drop Table #tmpEG
Drop Table #FinalEG
/* EG Category Changes Ends */

	Update #TmpOut Set [Current Status] = Status Where Isnull([Current Status],'') = ''

	Insert Into #TmpOutAbstract
	Select Distinct [DetailID],@GGDRmonth [Month],[CustomerID],[Customer Name],[DS ID],[DS Name],[DS Type],'' [Beat],[Status],[Target],[TargetUOM],[Cat GRP],[OCG],(Case When [Actual] <> 0 Then [Actual] Else 0 End) [Actual],[Current Status],[Last Day Close Date],[FromDate],[ToDate],[ProdDefnID],Null,'',PMCategory,Flag
	from #TmpOut Order By [DS Name],[DS Type],[CustomerID],[Customer Name] Asc

	Truncate table #TmpCustCat
	Insert Into #TmpCustCat(CustomerID,SalesmanID,CategoryGroup,ProdDefnID,PMCategory)
	Select Distinct CustomerID,[DS ID],(Case When @OCGFlag = 0 Then [Cat GRP] else OCG End),ProdDefnID,PMCategory From #TmpOutAbstract Where Status = 'Red' And [Month] = @GGDRmonth


	Declare @SalesManId as Int
	Declare @CustomerID as Nvarchar(255)
	Declare @PMCategory as Nvarchar(255)
	Declare @CatGroup as Nvarchar(4000)
	Declare @NewCatGroup as Nvarchar(4000)
	Declare @MaxProdDefnID As Int

	Declare Cur_Sal Cursor for
	Select Distinct Salesmanid ,CustomerID,PMCategory From #TmpCustCat
	Open Cur_Sal
	Fetch from Cur_Sal into @SalesManId,@CustomerID,@PMCategory
	While @@fetch_status =0
		Begin	
			Set @MaxProdDefnID = (Select Max(Isnull(ProdDefnID,0)) From #TmpCustCat Where SalesManId = @SalesManId And CustomerID = @CustomerID And PMCategory = @PMCategory Group By CustomerID,SalesManId)
			Set @NewCatGroup = ''
			Declare Cur_Join Cursor for
			Select Distinct CategoryGroup From #TmpCustCat Where SalesManId = @SalesManId And CustomerID = @CustomerID And PMCategory = @PMCategory Order By CategoryGroup Asc
			Open Cur_Join
			Fetch from Cur_Join into @CatGroup
			While @@fetch_status =0
				Begin			
					If Isnull(@NewCatGroup,'') <> ''
					Begin
						Set @NewCatGroup = @NewCatGroup + '|' + @CatGroup
					End
					Else
					Begin
						Set @NewCatGroup = @CatGroup
					End
					Fetch Next from Cur_Join into @CatGroup
				End
			Close Cur_Join
			Deallocate Cur_Join

			Update #TmpOutAbstract Set CustomerCategory = @NewCatGroup,MaxProdDefnID = @MaxProdDefnID Where [DS ID] = @SalesManId And CustomerID = @CustomerID  And [Month] = @GGDRmonth And Status = 'Red' And PMCategory = @PMCategory

			Fetch Next from Cur_Sal into @SalesManId,@CustomerID,@PMCategory
		End
	Close Cur_Sal
	Deallocate Cur_Sal

OUT:

SkipMonth:
	Truncate Table #TmpCustomer1
	Truncate Table #DSTypeMaster
	Truncate Table #tmpCatVal
	Truncate Table #TFinalOut
	Truncate Table #PMCategory
	Truncate Table #Statusval

/*  Loop End */
		If Isnull(@Receive,0) = 1
		Begin
			Delete From GGRRFinalData Where [Month] = @GGDRmonth And CustomerID in (Select Distinct CustomerID From PendingGGRRFinalDataPost Where FromDateMonth = @GGDRmonth)
			Delete From PendingGGRRFinalDataPost Where FromDateMonth = @GGDRmonth			
		End

		Set @i =(@i)+1
	End
/* Detail part Start */
	IF OBJECT_ID('tempdb..#TmpOutDetail') IS NULL
	Begin
	CREATE TABLE #TmpOutDetail(
		TProductCode nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		ProductCode nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Product Description] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		ProductLevel nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Target decimal(18, 6) NULL Default 0,
		TargetUOM nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		IsExcluded nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Actual decimal(18, 6) NULL Default 0, Points Decimal(18,6) Null Default 0)
	End
	Declare @D_DetailID As Nvarchar(4000)
	Declare @D_Month As Nvarchar(255)
	Declare @D_CustomerID As Nvarchar(255)
	Declare @D_CustomerName As Nvarchar(255)
	Declare @D_DSID As Int
	Declare @D_DSName As Nvarchar(255)
	Declare @D_DSType As Nvarchar(255)
	Declare @D_Beat As Nvarchar(255)
	Declare @D_Status As Nvarchar(255)
	Declare @D_Target As Decimal(18,6)
	Declare @D_TargetUOM As Nvarchar(255)
	Declare @D_CatGRP As Nvarchar(255)
	Declare @D_OCG As Nvarchar(255)
	Declare @D_Actual As Decimal(18,6)
	Declare @D_CurrentStatus As Nvarchar(255)
	Declare @D_LastDayCloseDate As Nvarchar(255)
	Declare @D_FromDate As DateTime
	Declare @D_ToDate As DateTime
	Declare @D_ProdDefnID As Int
	Declare @D_MaxProdDefnID as Int
	Declare @D_CustomerCategory As Nvarchar(Max)
	Declare @DSTypeId as Int
	Declare @CategoryGroup As Nvarchar(50)
	Declare @D_PMCategory As Nvarchar(255)
	Declare @D_Flag as nvarchar(100)

	Declare CUR Cursor for
	Select Distinct [DetailID],[Month],[CustomerID],[Customer Name],[DS ID],[DS Name],[DS Type],[Beat],[Status],[Target],[TargetUOM],[Cat GRP],[OCG],[Actual],[Current Status],[Last Day Close Date],[FromDate],[ToDate],[ProdDefnID],MaxProdDefnID,CustomerCategory,PMCategory,Flag From #TmpOutAbstract
	Order By [Month],[CustomerID] Asc
	Open CUR
	Fetch from CUR into @D_DetailID,@D_Month,@D_CustomerID,@D_CustomerName,@D_DSID,@D_DSName,@D_DSType,@D_Beat,@D_Status,@D_Target,@D_TargetUOM,@D_CatGRP,@D_OCG,@D_Actual,@D_CurrentStatus,@D_LastDayCloseDate,@D_FromDate,@D_ToDate,@D_ProdDefnID,@D_MaxProdDefnID,@D_CustomerCategory,@D_PMCategory,@D_Flag
	While @@fetch_status =0
		Begin
			Set DateFormat DMY
			Set @DSTypeId = 0
			Set @CategoryGroup = ''
			Set @DSTypeId = (Select Top 1 DSTypeId From DSType_Master Where DSTypeValue = @D_DSType)
			Set @CategoryGroup = (Case When @OCGFlag = 0 Then @D_CatGRP Else @D_OCG End)

			If @CategoryGroup <> 'All'
			Begin
				Truncate Table #TmpCatGroup
				Insert Into #TmpCatGroup(GroupName) 
				Select @CategoryGroup 
			End
			Else
			Begin
				If (Select Top 1 isnull(Flag,0) from tbl_merp_Configabstract Where ScreenCode = 'OCGDS') = 0
				Begin
					Truncate Table #TmpCatGroup
					Insert Into #TmpCatGroup(GroupName) 
					Select Distinct GroupName From ProductCategoryGroupAbstract Where GroupId in (
					Select Distinct GroupId from tbl_mERP_DSTypeCGMapping Where DSTypeId = @DSTypeId And isnull(Active,0) = 1)
					And Isnull(OCGType,0) = 0
				End
				Else
				Begin
					Truncate Table #TmpCatGroup
					Insert Into #TmpCatGroup(GroupName) 
					Select Distinct GroupName From ProductCategoryGroupAbstract Where GroupId in (
					Select Distinct GroupId from tbl_mERP_DSTypeCGMapping Where DSTypeId = @DSTypeId And isnull(Active,0) = 1)
					And Isnull(OCGType,0) = 1
				End
			End

			Truncate table #D_TmpOut
			Insert Into #D_TmpOut
			select Products,Null,Isnull(ProdCatLevel,0),Target,
			(Case 
				When Isnull(TargetUOM,0) = 1 Then 'Base UOM'
				When Isnull(TargetUOM,0) = 2 Then 'UOM1'
				When Isnull(TargetUOM,0) = 3 Then 'UOM2'
				When Isnull(TargetUOM,0) = 4 Then 'Value' Else Null End),
			isnull(IsExcluded,0),
			Null,
			@D_FromDate,@D_Todate, Points	
			From GGDRProduct 
			Where ProdDefnID = @D_ProdDefnID

			Update T Set T.[Product Description] = IC.Description from #D_TmpOut T,Itemcategories IC
			Where IC.Category_Name = T.ProductCode 
			And Isnull(T.ProductLevel,0) in (2,3,4)

			Update T Set T.[Product Description] = I.ProductName from #D_TmpOut T,#Items I
			Where I.Product_Code = T.ProductCode 
			And Isnull(T.ProductLevel,0) in (5)

			Update #D_TmpOut Set [Product Description] = Null Where ProductCode = 'All'
			Truncate Table #TmpExItems
			Declare @Product as Nvarchar(4000)
			Declare @Level As Int
			Declare @UOM as Nvarchar(255)
			Declare @Actual as Decimal(18,6)
			Declare @A_Fromdate as dateTime
			Declare @A_Todate as dateTime

--			If Not Exists(Select 'X' From Beat_Salesman Where CustomerId = @D_CustomerID And SalesManID = @D_DSID)
--			GoTo NextID

		/* For Inculede Items */
		
			Declare Cur_Items Cursor for
			Select  ProductCode,ProductLevel,TargetUOM,FromDate,Todate From #D_TmpOut Where Isnull(IsExcluded,0) = 0
			Open Cur_Items
			Fetch from Cur_Items into @Product,@level,@UOM,@A_Fromdate,@A_ToDate
			While @@fetch_status =0
				Begin

					If @Product = 'All'
					Begin
						Truncate table #TmpItems
						Insert Into #TmpItems(Product_Code)
						Select Product_Code From #TmpGGDRSKUDetails where ProdDefnID = @D_ProdDefnID  And CategoryGroup in (Select Distinct GroupName From #TmpCatGroup)
					End
					Else If @Product <> 'All'
					Begin
						If @level = 2
						Begin
							Truncate Table #TmpItems
							Insert Into #TmpItems(Product_Code)
							Select Product_Code From #TmpGGDRSKUDetails where ProdDefnID = @D_ProdDefnID And Division = @Product
						End
						Else If @level = 3
						Begin
							Truncate Table #TmpItems
							Insert Into #TmpItems(Product_Code)
							Select Product_Code From #TmpGGDRSKUDetails where ProdDefnID = @D_ProdDefnID And SubCategory = @Product
						End
						Else If @level = 4
						Begin
							Truncate Table #TmpItems
							Insert Into #TmpItems(Product_Code)
							Select Product_Code From #TmpGGDRSKUDetails where ProdDefnID = @D_ProdDefnID And MarketSKU = @Product
						End
						Else If @level = 5
						Begin
							Truncate Table #TmpItems
							Insert Into #TmpItems(Product_Code)
							Select Product_Code From #TmpGGDRSKUDetails where ProdDefnID = @D_ProdDefnID And Product_Code = @Product
						End
					End

					Truncate Table #Tmp					
					Insert Into #Tmp (Product_Code)
					Select Distinct Product_Code From #TmpItems
					Truncate Table #TmpItems
					Insert Into #TmpItems (Product_Code)
					Select Distinct Product_Code From #Tmp
					Truncate Table #Tmp

    				Update T Set Sales = T1.Actual From #TmpItems T,
					(Select  G.SystemSKU,
							Cast((Sum(Case 
								When @UOM = 'UOM1' Then (G.SalesVolume / Isnull(I.UOM1_Conversion,1))
								When @UOM = 'UOM2' Then (G.SalesVolume / Isnull(I.UOM2_Conversion,1))
								When @UOM = 'Base UOM' Then (G.SalesVolume)
								When @UOM = 'Value' Then (G.Salesvalue) 
							End)) as Decimal(18,6)) Actual
					from GGDRData G, #TmpItems TI,#Items I	
					Where I.Product_Code = G.SystemSKU And TI.Product_Code = I.Product_Code 
					And InvoiceDate Between @A_Fromdate And @A_ToDate
					And RetailerCode = @D_CustomerID
					And DSID = @D_DSID
					And DSType = @D_DSType
					And G.ProdDefnId=@D_ProdDefnID
					Group By G.SystemSKU) T1
					Where T.Product_Code = T1.SystemSKU
					
					Set @Actual = (select Sum(Isnull(Sales,0)) from #TmpItems)

					Update #D_TmpOut Set Actual = @Actual 
					Where ProductCode = @Product And ProductLevel = @level And Isnull(IsExcluded,0) = 0

					Set @Actual = 0

					Fetch Next from Cur_Items into @Product,@level,@UOM,@A_Fromdate,@A_ToDate
				End
			Close Cur_Items
			Deallocate Cur_Items

			Truncate Table #TmpOutDetail
			Insert Into #TmpOutDetail(TProductCode,ProductCode,[Product Description],ProductLevel,Target,TargetUOM,IsExcluded,Actual,Points)
			Select 	Distinct [ProductCode] as [TProductCode],[ProductCode],[Product Description],
				(Case
					When Isnull(ProductLevel,0) = 2 Then 'Division'
					When Isnull(ProductLevel,0) = 3 Then 'Sub Category'
					When Isnull(ProductLevel,0) = 4 Then 'MarketSKU'
					When Isnull(ProductLevel,0) = 5 Then 'SKU'
	 				When Isnull(ProductLevel,0) = 0 Then 'Overall' End ) [ProductLevel],
				[Target] ,
				[TargetUOM],
				(Case When isnull(IsExcluded,0) = 1 Then 'Yes' End)	[IsExcluded],
				isnull([Actual],0) as [Actual], Points from #D_TmpOut

			Delete From GGRRFinalData Where [Month] = @D_Month And DSID = @D_DSID and DSType = @D_DSType and [CustomerID] = @D_CustomerID And [ProdDefnID] = @D_ProdDefnID and status= @D_Status and isnull([catGRp],'') = isnull(@D_CatGRP,'') and isnull([OCG],'') = isnull(@D_OCG,'')

			Insert Into GGRRFinalData(Month,FromDate,ToDate,CustomerID,CustomerName,DSID,DSName,DSType,Status,Target,TargetUOM,CatGRP,OCG,Actual,CurrentStatus,DetailID,ProdDefnID,D_ProductCode,D_ProductDescription,D_ProductLevel,D_Target,D_TargetUOM,D_IsExcluded,D_Actual,LastDayCloseDate,CreationDate,MaxProdDefnID,CustomerCategory,PMCategory,Flag,Points)
			Select Distinct @D_Month,@D_FromDate,@D_ToDate,@D_CustomerID,@D_CustomerName,@D_DSID,@D_DSName,@D_DSType,@D_Status,@D_Target,@D_TargetUOM,@D_CatGRP,@D_OCG,@D_Actual,@D_CurrentStatus,@D_DetailID,@D_ProdDefnID,[ProductCode],[Product Description],[ProductLevel],[Target],[TargetUOM],[IsExcluded],[Actual],@D_LastDayCloseDate,Getdate(),@D_MaxProdDefnID,@D_CustomerCategory,@D_PMCategory,@D_Flag,Points From #TmpOutDetail
--NextID:
			Fetch Next from CUR into @D_DetailID,@D_Month,@D_CustomerID,@D_CustomerName,@D_DSID,@D_DSName,@D_DSType,@D_Beat,@D_Status,@D_Target,@D_TargetUOM,@D_CatGRP,@D_OCG,@D_Actual,@D_CurrentStatus,@D_LastDayCloseDate,@D_FromDate,@D_ToDate,@D_ProdDefnID,@D_MaxProdDefnID,@D_CustomerCategory,@D_PMCategory,@D_Flag
		End
	Close CUR
	Deallocate CUR

/* Detail part End */

	Update GGRRFinalData Set LastdaycloseDate = Convert(Nvarchar(10),@LastdaycloseDate,103) 

	If @ToDate IS NOT NULL
	Begin
		Update GGRRFinalData Set ToDate = @Todate Where [Month] = @GGDRmonth
	End

	If @ToDate IS NULL And (Select Isnull(Flag,0) From Tbl_Merp_ConfigAbstract Where Screencode = 'GGRRInit') = 0
	Begin
		Update Tbl_Merp_ConfigAbstract Set Flag = 1,ModifiedDate = Getdate() Where Screencode = 'GGRRInit'
	End

	If Exists(Select 'X' From Setup Where Isnull(GGRRDaycloseFlag,0) = 1)
	Begin
		Update SetUp set GGRRDaycloseFlag = 0
	End
	If @ToDate is not null
	BEGIN
		Delete from GGRRDayCloseLog Where Dbo.StripdateFromtime(DayCloseDate)=Dbo.StripdateFromtime(@ToDate)
		Insert into GGRRDayCloseLog(DayCloseDate,Status)
		Select @ToDate,2
	END
	ELSE
	BEGIN
		/* Log Part starts */
		Create Table #tmpDates(AllDate Datetime)
		DECLARE @DateFrom smalldatetime, @DateTo smalldatetime;
		SELECT @DateFrom=@MonthFirstdate
		Select top 1 @DateTo=@MonthTodate;
		WITH T(date)
		AS
		( 
		SELECT @DateFrom 
		UNION ALL
		SELECT DateAdd(day,1,T.date) FROM T WHERE T.date < @DateTo
		)
		insert into #tmpDates(AllDate)
		SELECT date FROM T OPTION (MAXRECURSION 32767);
		
		Delete from GGRRDayCloseLog Where Dbo.StripdateFromtime(DayCloseDate)in (select AllDate from #tmpDates)
		Insert into GGRRDayCloseLog(DayCloseDate,Status)
		Select AllDate,2 from #tmpDates
		Drop Table #tmpDates
		/* Log Part Ends */
	END
	Select 1 Flag

	Drop Table #TmpOutAbstract
	Drop Table #TmpOutDetail

	Drop Table #TmpCustomer
	Drop Table #TmpDS
	Drop Table #TmpBeat
	Drop Table #TmpOut
	Drop Table #TmpDSType
	Drop Table #TmpCustCat
	Drop Table #D_TmpOut
	Drop Table #TmpItems
	Drop Table #TmpExItems
	Drop Table #TmpGGDRSKUDetails
	Drop Table #Items

	Drop Table #tmbGGRRMonth 
	Drop Table #GGRRCustomer 
	Drop Table #PendingGGRRFinalDataPost 
	Drop Table #TmpCustomer1 
	Drop Table #DSTypeMaster 
	Drop Table #tmpCatVal 
	Drop Table #TFinalOut 
	Drop Table #PMCategory
	Drop Table #Statusval 
	Drop Table #CatGrpp 
	Drop Table #TmpCatGroup 
	Drop Table #Tmp 
	
	Commit Tran
	
End
