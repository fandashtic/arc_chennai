Create procedure mERP_SP_rpt_DSPointsreport_abstract (@Rptmonth nvarchar(50),@DSType nvarchar(4000))
AS
BEGIN
	SET Dateformat DMY
	Declare @FromDate_Rpt datetime
	Declare @Todate_Rpt datetime
	Declare @Delimeter Char(1)   
	Declare @DayCloseFlag int

	Create table #tmpDSType_Rpt (DSType nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Create table #tmpoutputRpt (DSType nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS, Total_DS int, Variablepoints decimal (18,6), 
	FixedPoints nvarchar(1) COLLATE SQL_Latin1_General_CP1_CI_AS,Mobility nvarchar(1) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Create Table #tmpDSCount (DSTypeID int,DSID int)
	Create Table #final(DSId int,DSType nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS,[Category group]  nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,[Till Date Points Earned] decimal(18,6))
	

	select @FromDate_Rpt = convert(datetime, ('01/' + @Rptmonth), 103)  
	select @ToDate_Rpt = convert(datetime, dateadd(d, -1, dateadd(m, 1, @FromDate_Rpt )), 103)
	
	set @Delimeter = Char(15) 

	If @DSType = N'%'        
		Insert into #tmpDSType_Rpt Select dstypevalue From DSType_Master where isnull(ReportFlag,0) = 1  and DSTypeCtlPos = 1 
	else        
		Insert into #tmpDSType_Rpt Select * From Dbo.sp_SplitIn2Rows(@DSType, @Delimeter)     

	/* Getting the current DSType Details*/
	insert into #tmpDSCount(DSTypeID,DSID) 
	select distinct DM.DSTypeID,DD.SalesmanID from DSType_Details DD,DSType_Master DM
	Where DD.DSTypeID = DM.DSTypeID
	And DM.DSTypeValue in (select DSType from #tmpDSType_Rpt)
	And DD.Salesmanid in (select salesmanid from salesman)
	And DD.Salesmanid in (select IA.SalesmanID from InvoiceAbstract IA where dbo.stripdatefromtime(invoicedate) between @FromDate_Rpt and @ToDate_Rpt
	And isnull(IA.status,0) & 128 = 0 and invoicetype in (1,3)And DM.DSTypeID = IA.DStypeID)
	/*Should not consider GR4 */
	And DD.DSTypeID not in (Select DSTypeID from tbl_mERP_DSTypeCGMapping where GroupID in (Select GroupID from ProductCategoryGroupAbstract where GroupName='GR4'))

	/*For history Records*/
	union
	Select distinct IA.DSTypeID,IA.SalesmanID from InvoiceAbstract IA where dbo.stripdatefromtime(invoicedate) between @FromDate_Rpt and @ToDate_Rpt
	and isnull(IA.status,0) & 128 = 0 and invoicetype in (1,3) And 
	DSTypeID in (select DSTypeID from DSType_Master DM where DM.DSTypeValue in (select DSType from #tmpDSType_Rpt))
	And 'GR1|GR3' = dbo.mERP_FN_get_CategoryGroupDesc(IA.InvoiceID,'GR1|GR3')
	--And IA.SalesmanID in (Select SalesmanID from DSType_Details where DSTypeID in 
	--(Select DSTypeID from DSType_Master where DSTypeValue in(Select DSType from #tmpDSType_Rpt) and Active = 1))
	union
	Select distinct IA.DSTypeID,IA.SalesmanID from InvoiceAbstract IA where dbo.stripdatefromtime(invoicedate) between @FromDate_Rpt and @ToDate_Rpt
	and isnull(IA.status,0) & 128 = 0 and invoicetype in (1,3) And 
	DSTypeID in (select DSTypeID from DSType_Master DM where DM.DSTypeValue in (select DSType from #tmpDSType_Rpt))
	And 'GR2' = dbo.mERP_FN_get_CategoryGroupDesc(IA.InvoiceID,'GR2')
	--And IA.SalesmanID in (Select SalesmanID from DSType_Details where DSTypeID in 
	--(Select DSTypeID from DSType_Master where DSTypeValue in(Select DSType from #tmpDSType_Rpt) and Active = 1))
	
	--For listng all the configured DSTypes - FITC-3530
	insert into #tmpDSCount(DSTypeID) 
	Select  DM.DSTypeID	from DSType_Master DM
	where DM.DSTypeValue in (select DSType from #tmpDSType_Rpt)
	And DSTypeID not in (Select DSTypeID from #tmpDSCount) 

	insert into #tmpoutputRpt (DSType,Total_DS)
	select distinct DM.DSTypeValue,count(DSID) from	DSType_Details DD
	right outer join #tmpDSCount tmpDS on DD.Salesmanid = tmpDS.DSID
	inner join DSType_Master DM on DM.DSTypeID = DD.DSTypeID and  DM.DSTypeID = tmpDS.DSTypeID
	Where   
	/*Should not consider GR4 */
	  DD.DSTypeID not in (Select DSTypeID from tbl_mERP_DSTypeCGMapping where GroupID in (Select GroupID from ProductCategoryGroupAbstract where GroupName='GR4'))
	group by DSTypeValue

	/* To Find Whether Day isclosed for the current month Last Day */
	Set @DayCloseFlag = 0
	If (Select isNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') = 1
	Begin
		If ((Select dbo.StripTimeFromDate(LastInventoryUpload) From Setup) >= dateadd(m,1,dbo.StripTimeFromDate(@FromDate_Rpt))-1)
			Select @DayCloseFlag = 1
	End	
	
	/* If last day of the previous month is not closed then variable points column should be shown blank - Clairfied with ITC*/
	if @DayCloseFlag = 0
	BEGIN
		select * into #tmpGTotal_DayClose from
		(select 1 as 'DS', T.DSType,max(Total_DS) as [Total No. of DS],'' as 'Variable Points','' as [Fixed],'' as Mobility from #tmpoutputRpt T
		group by T.DSType) T

		insert into #tmpGTotal_DayClose ([DS],[DSType],[Total No. of DS],[Variable Points],[Fixed],Mobility) 
		select -1 as 'DS','Total' as 'DSType',sum(isnull([Total No. of DS],0)) as [Total No. of DS],'' as 'Variable Points','' as [Fixed],'' as Mobility from #tmpGTotal_DayClose 
		
		select [DSType] as DST,[DSType],[Total No. of DS],[Variable Points],[Fixed],Mobility from #tmpGTotal_DayClose order by [DS] desc
		Drop Table #tmpGTotal_DayClose
	END
	ELSE
	BEGIN
		/* Performance Report Start */

		Declare @CatGroup nVarchar(1000)
		Declare @SalesName nVarchar(4000)
		Declare @ReportType nVarchar(50)
		Declare @DateOrMonth as nVarchar(25)
		Declare @UptoWeek nVarchar(50)

		set @CatGroup = '%'
		set @DStype ='%'
		set @SalesName ='%'
		set @ReportType ='Monthly'
		set @DateOrMonth = @Rptmonth
		set @UptoWeek='%'

		set @ReportType='Monthly'

		Declare @Period as nVarchar(8)
		Declare @FromDate as DateTime
		Declare @ToDate as Datetime
		Declare @dtMonth Datetime
		Declare @MonthLastDate Datetime
		Declare @MonthFirstDate Datetime
		Declare @TillDate as Datetime
		Declare @RptGenerationDate as Datetime
		Declare @Counter as Int
		Declare @PMMaxCount as Int
		Declare @Month nVarchar(25)
		Declare @RptDate Datetime
		Declare @PMID Int,@PMDSTypeID Int
		Declare @LastInvoiceDate Datetime

		Declare @ParamType Int,@Frequency Int,@isFocusParam nVarchar(255)
		Declare @CGGroups as nVarchar(100)
		Declare @SalesmanID as Int,@Level Int
		Declare @TillDateActual Int
		Declare @TillDatePointsEarned Decimal(18,6)
		Declare @TodaysActual Int
		Declare @TillDateActualSales Decimal(18,6)
		Declare @TodaysActualSales Decimal(18,6)
		Declare @ToDaysPointsEarned Decimal(18,6)
		Declare @NoOfDaysInvoiced Int,@ParamID Int 
		Declare @SlabID Int,@FocusID Int
		Declare @SLAB_EVERY Int,@DSGroups nVarchar(50)
		Declare @SLAB_Value Decimal(18,6),@DSTypeID Int
		Declare @SalesmanName nVarchar(100)
		
		/* Business Achievement*/
		Declare @ToTalSalesPercentage Decimal(18,6),@Target  as Decimal(18,6),@MaxPoints Decimal(18,6),@DayClosed Int 
		
		Declare @GRNTOTAL nVarchar(50)    
		Declare @MAXPOINT_TOTAL nVarchar(50)    
		
		Set @GRNTOTAL = dbo.LookupDictionaryItem(N'Total:', Default)    
		Set @MAXPOINT_TOTAL = dbo.LookupDictionaryItem(N'Max Points Total:', Default)    

		Create Table #tmpCatGroup(GroupName nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
		Create Table #tmpDStype(DSType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
		Create Table #tmpSalesman(Salesman nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)

		Create Table #tmpPM(RowID Int Identity(1,1),PMID Int,SalesmanID Int,
		Salesman_Name nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,DSTypeID Int,
		DSTypeCode Int,DSType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
		PMCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		PMDescription nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
		CGGroups nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		--CGGroups_Display nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		ParameterType Int,Frequency Int,ParamID Int,Prod_Level Int,
		isFocusParam nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
		FocusID Int,DS_MaxPoints Decimal(18,6),Param_MaxPoints  Decimal(18,6),
		TillDateActual Decimal(18,6),NoOfDaysInvoiced Int,AverageTillDate Decimal(18,6),
		Target Decimal(18,6),MaxPoints Decimal(18,6),TillDatePointsEarned Decimal(18,6),
		ToDaysActual Decimal(18,6),PointsEarnedToday Decimal(18,6),GenerationDate Datetime,LastTranDate Datetime)

		Create Table #tmpPM1(RowID Int Identity(1,1),PMID Int,SalesmanID Int,
		Salesman_Name nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,DSTypeID Int,
		DSTypeCode Int,DSType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
		PMCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		PMDescription nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
		CGGroups nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		--CGGroups_Display nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		ParameterType Int,Frequency Int,ParamID Int,Prod_Level Int,
		isFocusParam nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
		FocusID Int,DS_MaxPoints Decimal(18,6),Param_MaxPoints  Decimal(18,6),
		TillDateActual Decimal(18,6),NoOfDaysInvoiced Int,AverageTillDate Decimal(18,6),
		Target Decimal(18,6),MaxPoints Decimal(18,6),TillDatePointsEarned Decimal(18,6),
		ToDaysActual Decimal(18,6),PointsEarnedToday Decimal(18,6),GenerationDate Datetime,LastTranDate Datetime)

		Create Table #tmpInvoice(InvoiceID Int,InvoiceDate Datetime,
		SalesmanID nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
		Product_Code nVarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
		MarketSKU nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
		SubCategory nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
		Division nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
		Company nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
		CategoryGroup nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		Amount Decimal(18,6) ,InvoiceType Int,InvoiceDateWithTime Datetime,DSTypeID Int)

		Create Table #tmpOutput([ID] Int Identity(1,1),
		DSID Int,
		DSName nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
		[DS Type] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
		[Performance Metrics Code] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		Description nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
		[Category Group] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		[From Date] Datetime,[To Date] Datetime,Parameter nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		[Overall or Focus] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,Frequency nVarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,
		Target Decimal(18,6),[Average Till Date] Decimal(18,6),
		[Till date Actual] Decimal(18,6),[Max Points] Decimal(18,6),
		[Till Date Points Earned] Decimal(18,6),
		[Todays Actual] Decimal(18,6),[Points Earned Today] Decimal(18,6),
		[Generation Date] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
		[Last Transaction Date] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)

		Create Table #tmpOutputBA([ID] Int Identity(1,1),[WDCode] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
		[WDDest] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
		DSID Int,
		DSName nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
		[DS Type] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
		[Performance Metrics Code] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		Description nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
		[Category Group] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		[From Date] Datetime,[To Date] Datetime,Parameter nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		[Overall or Focus] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,Frequency nVarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,
		Target Decimal(18,6),[Average Till Date] Decimal(18,6),
		[Till date Actual] Decimal(18,6),[Max Points] Decimal(18,6),
		[Till Date Points Earned] Decimal(18,6),
		[Todays Actual] Decimal(18,6),[Points Earned Today] Decimal(18,6),
		[Generation Date] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
		[Last Transaction Date] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)	

		Create Table #tmpInvDateWise(InvoiceDate Datetime,LinesOrBillsOrBA Decimal(18,6),InvoiceDateWithTime Datetime,
									SalesPercentage Decimal(18,6),SlabID Int,Slab_Every Int,Slab_Value Decimal(18,6),
									PointsEarned Decimal(18,6))
		
		Create Table #tmpDistinctPMDS(RowID Int Identity(1,1),PMID Int,DSTypeID Int,SalesmanName nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
		
		If @CatGroup = N'%' Or @CatGroup = N''
		Begin
			Insert Into #tmpCatGroup(GroupName) Values ('GR1,GR3')
			Insert Into #tmpCatGroup(GroupName) Values ('GR1')
			Insert Into #tmpCatGroup(GroupName) Values ('GR2')
			Insert Into #tmpCatGroup(GroupName) Values ('GR3')
		End
		Else
		Begin
			/* When GR1&GR3 selected then Metrics with CategoryGroup GR1, or GR2 or GR3 OR GR1|GR3 should be selected */
			Insert Into #tmpCatGroup
			Select * From dbo.sp_SplitIn2rows(@CatGroup,@Delimeter)
			
			Update #tmpCatGroup Set GroupName = Replace(GroupName,'|',',')

			If (Select Count(GroupName) From #tmpCatGroup Where GroupName = ('GR1,GR3')) > =1
			Begin
				Insert Into #tmpCatGroup(GroupName) Values ('GR1')
				Insert Into #tmpCatGroup(GroupName) Values ('GR3')
			End
		End

		Insert into #tmpDStype
		Select Distinct DSType From #tmpDSType_Rpt

		If @SalesName = N'%' Or @SalesName = N''
		Begin
			Insert into #tmpSalesman
			Select Salesman_Name From Salesman
		End
		Begin
			Insert into #tmpSalesman
			Select * From dbo.sp_SplitIn2rows(@SalesName,@Delimeter)
		End

		Select @TillDate = GetDate()
		Select @RptGenerationDate = @TillDate

		Set @ReportType = Ltrim(Rtrim(@ReportType))
		If @ReportType = '%' Or @ReportType =  N''
		Begin
			Set @ReportType = 'Daily'
			Set @DateOrMonth = @TillDate
		End

		If @ReportType = N'Monthly'
		Begin
			/* Will be given in MM/YYYY Format */
			If @DateOrMonth = '' Or @DateOrMonth = '%'
				Set @Month = Right((Convert(nVarchar(10), @TillDate, 103)),7)
			Else if  Len(@DateOrMonth) > 7
				Set @Month = Right((Convert(nVarchar(10), @TillDate, 103)),7)
			Else if isDate(Cast(('01' + '/' + @DateOrMonth) as nVarchar(15))) = 0
				Set @Month = Right((Convert(nVarchar(10), @TillDate, 103)),7)
			Else
				Set @Month = Cast(@DateOrMonth as nVarchar(7))
				
			Set @DtMonth = cast(Cast('01' + '/' +  @Month as nVarchar(15)) as datetime)
			Select @Period = REPLACE(RIGHT(CONVERT(VARCHAR(11), @DtMonth, 106), 8), ' ', '-')

			set dateformat dmy
			Set @DtMonth = cast(Cast('01' + '/' +  @Month as nVarchar(15)) as datetime)
			Set @FromDate = 	Convert(nVarchar(10), @DtMonth, 103)
			If @UptoWeek = N'Week 1' 
				Begin
	--					Set @FromDate = (Select Convert(nVarchar(10), @DtMonth, 103) ) 
						Set @ToDate =  (Select DATEADD(s,-1,(DateAdd(DD, 7,  @FromDate))))
				End
			Else If @UptoWeek =  N'Week 2' 
				Begin
	--					Set @FromDate = (Select (DateAdd(DD, 7,  @FromDate)))
						Set @ToDate =  (Select DATEADD(s,-1,(DateAdd(dd, 14,  @FromDate))))
				End
			Else If @UptoWeek =  N'Week 3' 
				Begin
	--					Set @FromDate = (Select (DateAdd(DD, 14,  @FromDate)))
						Set @ToDate =  (Select DATEADD(s,-1,(DateAdd(dd, 21,  @FromDate))))
				End
			Else If @UptoWeek =  N'Week 4' or @UptoWeek = N'' Or @UptoWeek = N'%' 
				Begin
	--					Set @FromDate = (Select (DateAdd(DD, 21,  @FromDate)))
						Set @ToDate =  (Select DATEADD(s,-1,(DateAdd(MM, +1,  @DtMonth))))
				End
			If @ToDate > Convert(nVarchar(10), Getdate(), 103)
				Begin 
					Set @ToDate = Convert(nVarchar(10), Getdate(), 103)
				End

			Set @MonthLastDate = @ToDate
			Select @MonthFirstDate = @FromDate
		End


		If  (@TillDate > @MonthLastDate) Or (@TillDate < @MonthFirstDate)
			Select @TillDate= @MonthLastDate

		/* To Find Whether Day isclosed for the current month Last Day */
		Select @DayClosed = 0
		If (Select isNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') = 1
		Begin
			If @ReportType = N'Monthly'
			Begin
				If ((Select dbo.StripTimeFromDate(LastInventoryUpload) From Setup) >= dbo.StripTimeFromDate(@MonthLastDate))
				Select @DayClosed = 1
			End
		End
		
		/* Last InvoiceDate taken */
		Select @LastInvoiceDate = Max(InvoiceDate) From InvoiceAbstract
		Where 	IsNull(Status,0) & 128 = 0	And InvoiceType in(1,3,4)

		/* Filter the Invoices Which comes in between MonthFromDate And ReportGenerationdate(TillDate) */
		Insert Into #tmpInvoice
		Select   IA.InvoiceID,IA.InvoiceDate,SM.SalesmanID,Ide.Product_Code,IC.Category_Name, IC1.Category_Name,
				 IC2.Category_Name,IC3.Category_Name,CGDiv.CategoryGroup,isNull(Ide.Amount,0),IA.InvoiceType,
				 IA.InvoiceDate,isNull(IA.DSTypeID,0)
		From     
			InvoiceAbstract IA,InvoiceDetail Ide,Items I    
			,ItemCategories IC,ItemCategories IC1,
			ItemCategories IC2,ItemCategories IC3,
			tblcgdivmapping CGDiv,Salesman SM
		Where     
			( IsNull(IA.Status,0) & 128 = 0)
			And dbo.StripTimeFromDate(IA.InvoiceDate) Between @MonthFirstDate And @TillDate 
			And IA.InvoiceType in(1,3,4)
			And IA.InvoiceID = Ide.InvoiceID
			And Ide.Product_Code = I.Product_Code
			And I.CategoryID = IC.CategoryID
			And IC.ParentID = IC1.CategoryID
			And IC1.ParentID = IC2.CategoryID
			And IC2.ParentID = IC3.CategoryID
			And IC2.Category_Name = CGDiv.Division
			And IA.SalesmanID = SM.SalesmanID


		Update #tmpInvoice Set Invoicedate = dbo.StripTimeFromDate(Invoicedate)

		Create table #DSPMSalesman (SalesManid Int ,Salesman_Name Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,PMID Int,DSTypeValue Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CurrentdsType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,TargetStatus int, SalesStatus Int)
		Insert into #DSPMSalesman (SalesManid,Salesman_Name,PMID,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
		select Distinct PMM.SAlesmanid,SAlesman_name,PMM.PMID,DST.DSType,Null,0,0 from tbl_merp_PMetric_TargetDefn PMM, tbl_mERP_PMDSType DST,Salesman S
		where PMM.PMID in (select PMID from tbl_mERP_PMMaster Where Period =@Period )
		And PMM.Active = 1 and PMM.PMDSTypeid = DST.DSTypeid
		And PMM.Salesmanid = S.Salesmanid  

		Insert into #DSPMSalesman (SalesManid,Salesman_Name,PMID,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
		select Distinct S.SalesManid,S.Salesman_Name,T.PMID,DT.DSTypeValue,Null,0,0 --into #DSPMSalesman 
		from DSType_Details D,DSType_Master DT, Salesman S, tbl_mERP_PMDSType PMDS, tbl_merp_PMetric_TargetDefn TDF,
		(select PMID from tbl_mERP_PMMaster Where Period =@Period ) T Where
			 T.PMID = PMDS.PMID 
		And  PMDS.DsType = DT.DSTypeValue 
		And DT.DSTYPEID = D.DSTYPEID
		And S.SalesManid = D.SalesManid  and DT.DSTypectlpos =1
		And TDF.PMID = T.PMID
		And TDF.Target > 0
		ANd TDF.Active = 1
		

		Insert into #DSPMSalesman (SalesManid,Salesman_Name,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus) 
		Select Distinct I.SalesManid,S.Salesman_Name,DT.DSTypeValue,Null,0,0 from #tmpInvoice I, DSType_Master DT, Salesman S
		Where I.SalesManid not in (select Distinct SalesManid from #DSPMSalesman) And Amount > 0
		And DT.DSTYPEID = I.DSTYPEID
		And I.SalesManid = S.SalesManid
		and DT.DSTypectlpos =1


		Update T1 set T1.CurrentdsType = T.CNT From #DSPMSalesman T1, (select Distinct Salesmanid, DSTypeValue CNT From DSType_Master TM,DSType_Details DD Where DD.DSTypeID = TM.DSTypeid And DD.DSTypectlpos =1) T
		Where T1.Salesmanid = T.Salesmanid  

		update #DSPMSalesman set TargetStatus = 1 where Salesmanid in (select Distinct Salesmanid from tbl_merp_PMetric_TargetDefn where Target > 0 and Active = 1 
		and PMId in (select Distinct PMID from tbl_mERP_PMMaster Where Period =@Period))
		update #DSPMSalesman set SalesStatus = 1 where Salesmanid in (select Distinct Salesmanid from #tmpInvoice Where Salesmanid not in (select Salesmanid from #DSPMSalesman Where TargetStatus = 1))
		Update #DSPMSalesman set DSTypeValue = CurrentdsType
		Update #DSPMSalesman set SalesStatus = 1 Where DSTypeValue = CurrentdsType and TargetStatus = 1

		
		/* Filter the PM based on the report parameter selected */
		Insert Into #tmpPM(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
		ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,FocusID,DS_MaxPoints,Param_MaxPoints)
		Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
		Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
		Param.ParamID,ProdCat_Level,(Case When isNull(Param.isFocusParameter,0) = 0 Then 'OverAll' Else ParamFocus.ProdCat_Code End) 'isFocusParam',
		ParamFocus.FocusID,isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
		From 
			tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDSType DS,
			Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
			,tbl_mERP_PMParamFocus ParamFocus --, DSType_Details DST
			,(Select Distinct SalesmanID,DSTypeID From #tmpInvoice) DSDet
		Where 
			Master.Period = @Period 
			And Master.Active = 1
			And Master.PMID = DSType.PMID
			And DStype.DSType = DS.DStype 
			And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup)
			And DSMast.DSTypeValue = DStype.DSType
			And DSMast.DSTypeCtlPos = 1
	--		And SM.SalesmanID = DST.SalesmanID
	--		And DSMast.DSTypeID = DST.DSTypeID
			And DSDet.DSTypeID = DSMast.DSTypeID
			And SM.SalesmanID = DSDet.SalesmanID
			And SM.Salesman_Name In(Select Salesman From #tmpSalesman) 
			And Param.DSTypeID = DSType.DSTypeID
			And Param.ParamID  = ParamFocus.ParamID
		


		/*If there is no sales for a salesman, then if that salesman alone is selected then, report is generating blank
		but if all salesman is selected then that salesman is coming with blank row. So we addressed that issue by creating empty row when that 
		particular salesman is selected*/

		Insert Into #tmpPM(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
		ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,FocusID,DS_MaxPoints,Param_MaxPoints)
		Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
		Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
		Param.ParamID,ProdCat_Level,(Case When isNull(Param.isFocusParameter,0) = 0 Then 'OverAll' Else ParamFocus.ProdCat_Code End) 'isFocusParam',
		ParamFocus.FocusID,isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
		From 
			tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDSType DS,
			Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param,tbl_merp_PMetric_TargetDefn PMTar,
			tbl_mERP_PMParamFocus ParamFocus
			,(select Distinct PMID,Salesmanid,DSTypeValue from #DSPMSalesman) TMPDS
		Where 
			Master.Period = @Period 
			And Master.Active = 1
			And Master.PMID = DSType.PMID
			And DStype.DSType = DS.DStype 
			And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup)
			And DSMast.DSTypeValue = DStype.DSType
			And DSMast.DSTypeCtlPos = 1
			And SM.SalesmanID = PMTar.SalesmanID		
			And Param.DSTypeID = DSType.DSTypeID
			And Param.ParamID  = ParamFocus.ParamID
			And PMTar.Target > 0
			And PMTar.PMID = Master.PMID
			And TMPDS.Salesmanid = PMTar.Salesmanid
			And TMPDS.DSTypeValue = DSMast.DSTypeValue
			and TMPDS.Salesmanid not in (select distinct salesmanid from #tmpPm)

		Insert Into #tmpPM1(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
		ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,FocusID,DS_MaxPoints,Param_MaxPoints)
		Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
		Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
		Param.ParamID,ProdCat_Level,(Case When isNull(Param.isFocusParameter,0) = 0 Then 'OverAll' Else ParamFocus.ProdCat_Code End) 'isFocusParam',
		ParamFocus.FocusID,isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints' 
		From 
			tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDSType DS,
			Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
			,tbl_mERP_PMParamFocus ParamFocus
			,(Select Distinct SalesmanID,DSTypeID From #tmpInvoice) DSDet
			,(select Distinct PMID,Salesmanid,Salesman_Name,DSTypeValue from #DSPMSalesman Where SalesStatus = 1) TMPDS
		Where 
			Master.Period = @Period 
			And Master.Active = 1
			And Master.PMID = DSType.PMID
			And DStype.DSType = DS.DStype 
			And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup)
			And DSMast.DSTypeValue = DStype.DSType
			And DSMast.DSTypeCtlPos = 1
			And SM.Salesman_Name  = TMPDS.Salesman_Name
			And Param.DSTypeID = DSType.DSTypeID
			And Param.ParamID  = ParamFocus.ParamID
	--		And TMPDS.Salesmanid = DSDet.Salesmanid
			And TMPDS.DSTypeValue = DSMast.DSTypeValue
			And SM.Salesmanid in ( select Distinct Salesmanid from #DSPMSalesman)

		Declare @tmpPMID int, @tmpDSID int, @DSTYPEValue Nvarchar(255)
		Declare Cur_PM1 Cursor For
		Select PMID,SalesManID,DSType from #tmpPM1
		Open Cur_PM1
		Fetch next from Cur_PM1 Into @tmpPMID,@tmpDSID,@DSTYPEValue 
		While @@Fetch_Status = 0
		Begin		
				If not exists (select * from #tmpPM where PMID=@tmpPMID and Salesmanid = @tmpDSID And DSType = @DSTYPEValue)
					Begin
					insert into #tmpPM(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,FocusID,DS_MaxPoints,Param_MaxPoints) 
					select Distinct PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,FocusID,DS_MaxPoints,Param_MaxPoints from #tmpPM1 where PMID=@tmpPMID and Salesmanid = @tmpDSID And DSTYPE = @DSTYPEValue
	--				and salesmanid in (select top 1 salesmanid from #tmpPm where salesmanid=@tmpdsid)
					end
				Fetch next from Cur_PM1 into @tmpPMID,@tmpDSID ,@DSTYPEValue
		End
		Close Cur_PM1
		Deallocate Cur_PM1

		Declare Cur_Counter Cursor For
		Select Rowid from #tmpPM
		Open Cur_Counter
		Fetch next from Cur_Counter Into @Counter 
		While @@Fetch_Status = 0
		Begin

				Delete From #tmpInvDateWise

				Select @TillDateActual = 0 ,@TillDatePointsEarned = 0,@NoOfDaysInvoiced=0,@SlabID=0,
				@SLAB_EVERY = 0,@SLAB_VALUE =0 ,@ToDaysPointsEarned = 0,@ToTalSalesPercentage =0,
				@Target  =0,@MaxPoints=0,@TodaysActual=0,@TillDateActualSales = 0,
				@TodaysActualSales = 0,@DSTypeID=0
				
				Select @ParamType = ParameterType,@Frequency = Frequency , @isFocusParam  = isFocusParam,
				@CGGroups = isNull(CGGroups,''),@SalesmanID = salesmanID,@Level = Prod_Level, 
				@ParamID = ParamID,@FocusID = FocusID,@DSTypeID = DSTypeCode From #tmpPM Where RowID = @Counter
				
				If @ParamType = 1 /* Lines Cut */
				Begin
					If @isFocusParam = 'OverAll'
					Begin
						Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
						Select InvoiceDate,Sum(LinesCut) ,Max(InvoiceDateWithTime) From
						(Select InvoiceID,InvoiceDate,SalesmanID ,Count(Distinct Product_Code) 'LinesCut',
						Max(InvoiceDateWithTime) 'InvoiceDateWithTime'
						From #tmpInvoice 
						Where SalesmanID = @SalesmanID
						And DSTypeID = @DSTypeID
						And CategoryGroup In(Select * from dbo.sp_splitIn2rows(@CGGroups,','))
						And InvoiceType In(1,3)
						Group By InvoiceID,InvoiceDate,SalesmanID) T
						Group By InvoiceDate
					End
					Else
					Begin /*Focus Param*/
						If @Level = 2
							Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
							Select InvoiceDate,Sum(LinesCut),Max(InvoiceDateWithTime) From
							(Select InvoiceID,InvoiceDate,SalesmanID ,Count(Distinct Product_Code) 'LinesCut',
							Max(InvoiceDateWithTime) 'InvoiceDateWithTime'
							From #tmpInvoice 
							Where SalesmanID = @SalesmanID
							And DSTypeID = @DSTypeID
							And CategoryGroup In(Select * from dbo.sp_splitIn2rows(@CGGroups,','))
							And InvoiceType In(1,3)
							And Division = @isFocusParam
							Group By InvoiceID,InvoiceDate,SalesmanID) T
							Group By InvoiceDate	
						Else If @Level = 3
							Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
							Select InvoiceDate,Sum(LinesCut),Max(InvoiceDateWithTime) From
							(Select InvoiceID,InvoiceDate,SalesmanID ,Count(Distinct Product_Code) 'LinesCut',
							Max(InvoiceDateWithTime) 'InvoiceDateWithTime'
							From #tmpInvoice 
							Where SalesmanID = @SalesmanID
							And DSTypeID = @DSTypeID
							And CategoryGroup In(Select * from dbo.sp_splitIn2rows(@CGGroups,','))
							And InvoiceType In(1,3)
							And SubCategory = @isFocusParam
							Group By InvoiceID,InvoiceDate,SalesmanID) T
							Group By InvoiceDate	
						Else If @Level = 4
							Begin
							Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
							Select InvoiceDate,Sum(LinesCut),Max(InvoiceDateWithTime) From
							(Select InvoiceID,InvoiceDate,SalesmanID ,Count(Distinct Product_Code) 'LinesCut',
							Max(InvoiceDateWithTime) 'InvoiceDateWithTime'
							From #tmpInvoice 
							Where SalesmanID = @SalesmanID
							And DSTypeID = @DSTypeID
							And CategoryGroup In(Select * from dbo.sp_splitIn2rows(@CGGroups,','))
							And InvoiceType In(1,3)
							And MarketSKU = @isFocusParam
							Group By InvoiceID,InvoiceDate,SalesmanID) T	
							Group By InvoiceDate	
						End
						Else If @Level = 5
							Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
							Select InvoiceDate,Sum(LinesCut),Max(InvoiceDateWithTime) From
							(Select InvoiceID,InvoiceDate,SalesmanID ,Count(Distinct Product_Code) 'LinesCut',
							Max(InvoiceDateWithTime) 'InvoiceDateWithTime'
							From #tmpInvoice 
							Where SalesmanID = @SalesmanID
							And DSTypeID = @DSTypeID
							And CategoryGroup In(Select * from dbo.sp_splitIn2rows(@CGGroups,','))
							And InvoiceType In(1,3)
							And Product_Code = @isFocusParam
							Group By InvoiceID,InvoiceDate,SalesmanID) T	
							Group By InvoiceDate	
					End /*End of Focus Param*/

					If (Select Count(InvoiceDate) From #tmpInvDateWise) >= 1
					Begin
						If @Frequency = 2 /* Monthly Frequency */
						Begin
							Select @TillDateActual = Sum(LinesOrBillsOrBA) From #tmpInvDateWise
							Select @TodaysActual = isNull(LinesOrBillsOrBA,0) From  #tmpInvDateWise Where dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@FromDate)
							Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise

							
							Select @SlabID = SlabID, @SLAB_EVERY = SLAB_EVERY_QTY,@SLAB_VALUE = SLAB_VALUE
							From tbl_mERP_PMParamSlab Where 
							ParamID = @ParamID And SLAB_GIVEN_AS = 1
							And @TillDateActual Between SLAB_START And SLAB_END And 
							@TillDateActual >= SLAB_EVERY_QTY
							
							Select @TillDatePointsEarned = Case isNull(@SLAB_EVERY,0)  When 0 Then   @SLAB_VALUE Else Cast((@TillDateActual/@SLAB_EVERY) as Int ) * @SLAB_VALUE End

							IF @ReportType = 'Monthly'
								UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = @TillDatePointsEarned,NoOfDaysInvoiced = @NoOfDaysInvoiced,
								AverageTillDate = Cast(@TillDateActual as Decimal(18,6))/@NoOfDaysInvoiced , Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
								LastTranDate = @LastInvoiceDate
								Where RowID = @Counter
						End /* End Of Monthly Frequency */
						Else If @Frequency = 1
						Begin

							UpDate   Inv Set Inv.SlabID = isNull(Slab.SLABID,0),
							Inv.Slab_Every = isNull(Slab.SLAB_EVERY_QTY,0),
							Inv.Slab_Value = isNull(Slab.SLAB_VALUE,0)
							From  #tmpInvDateWise Inv,tbl_mERP_PMParamSlab Slab
							Where 
							Slab.ParamID = @ParamID And Slab.SLAB_GIVEN_AS = 1
							And Inv.LinesOrBillsOrBA Between Slab.SLAB_START And Slab.SLAB_END
							And Inv.LinesOrBillsOrBA >= Slab.SLAB_EVERY_QTY

							Update #tmpInvDateWise Set 
							PointsEarned = Case isNull(Slab_Every,0) When 0 Then Slab_Value Else Cast(LinesOrBillsOrBA/Slab_Every as Int) * Slab_Value End
							Where SlabID > 0

							Update #tmpInvDateWise Set PointsEarned = 0 Where isNull(SlabID,0) = 0
							
							Select @TillDatePointsEarned = Sum(PointsEarned),@TillDateActual = Sum(LinesOrBillsOrBA) From #tmpInvDateWise
							Select @TodaysActual = isNull(LinesOrBillsOrBA,0) ,
							@TodaysPointsEarned = isNull(PointsEarned,0) From  #tmpInvDateWise Where dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@FromDate)
							Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise

							IF @ReportType = 'Monthly'
								UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = @TillDatePointsEarned,	NoOfDaysInvoiced = @NoOfDaysInvoiced,
								AverageTillDate = Cast(@TillDateActual as Decimal(18,6))/@NoOfDaysInvoiced , Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
								LastTranDate = @LastInvoiceDate
								Where RowID = @Counter
						End
					End /* End of Datewise InvoiceDetails */
				End /*End of Lines Cut */


				If @ParamType = 2 /* Bills Cut */
				Begin
					If @isFocusParam = 'OverAll'
					Begin
						Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
						Select InvoiceDate,Count(Distinct InvoiceID),Max(InvoiceDateWithTime)
						From #tmpInvoice 
						Where SalesmanID = @SalesmanID
						And DSTypeID = @DSTypeID
						And CategoryGroup In(Select * from dbo.sp_splitIn2rows(@CGGroups,','))
						And InvoiceType In(1,3)
						Group By InvoiceDate
					End
					Else
					Begin /*Focus Param*/
						If @Level = 2
							Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
							Select InvoiceDate,Count(Distinct InvoiceID),Max(InvoiceDateWithTime)
							From #tmpInvoice 
							Where SalesmanID = @SalesmanID
							And DSTypeID = @DSTypeID
							And CategoryGroup In(Select * from dbo.sp_splitIn2rows(@CGGroups,','))
							And InvoiceType In(1,3)
							And Division = @isFocusParam
							Group By InvoiceDate
						Else If @Level = 3
							Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
							Select InvoiceDate,Count(Distinct InvoiceID),Max(InvoiceDateWithTime)
							From #tmpInvoice 
							Where SalesmanID = @SalesmanID
							And DSTypeID = @DSTypeID
							And CategoryGroup In(Select * from dbo.sp_splitIn2rows(@CGGroups,','))
							And InvoiceType In(1,3)
							And SubCategory = @isFocusParam
							Group By InvoiceDate
						Else If @Level = 4
							Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
							Select InvoiceDate,Count(Distinct InvoiceID),Max(InvoiceDateWithTime)
							From #tmpInvoice 
							Where SalesmanID = @SalesmanID
							And DSTypeID = @DSTypeID
							And CategoryGroup In(Select * from dbo.sp_splitIn2rows(@CGGroups,','))
							And InvoiceType In(1,3)
							And MarketSKU = @isFocusParam
							Group By InvoiceDate
						Else If @Level = 5
							Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
							Select InvoiceDate,Count(Distinct InvoiceID),Max(InvoiceDateWithTime)
							From #tmpInvoice 
							Where SalesmanID = @SalesmanID
							And DSTypeID = @DSTypeID
							And CategoryGroup In(Select * from dbo.sp_splitIn2rows(@CGGroups,','))
							And InvoiceType In(1,3)
							And Product_Code = @isFocusParam
							Group By InvoiceDate
					End /*End of Focus Param*/
					If (Select Count(InvoiceDate) From #tmpInvDateWise) >= 1
					Begin
						If @Frequency = 2 /* Monthly Frequency */
						Begin
							Select @TillDateActual = Sum(LinesOrBillsOrBA) From #tmpInvDateWise
							Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise
							Select @TodaysActual = isNull(LinesOrBillsOrBA,0)
							From  #tmpInvDateWise Where dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@FromDate)
							
							Select @SlabID = SlabID, @SLAB_EVERY = SLAB_EVERY_QTY,@SLAB_VALUE = SLAB_VALUE
							From tbl_mERP_PMParamSlab Where 
							ParamID = @ParamID And SLAB_GIVEN_AS = 1
							And @TillDateActual Between SLAB_START And SLAB_END And 
							@TillDateActual >= SLAB_EVERY_QTY
												
							Select @TillDatePointsEarned = Case isNull(@SLAB_EVERY,0)  When 0 Then   @SLAB_VALUE Else Cast((@TillDateActual/@SLAB_EVERY) as Int ) * @SLAB_VALUE End

							IF @ReportType = 'Monthly'
								UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = @TillDatePointsEarned,NoOfDaysInvoiced = @NoOfDaysInvoiced,
								AverageTillDate = Cast(@TillDateActual as Decimal(18,6))/@NoOfDaysInvoiced , Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
								LastTranDate = @LastInvoiceDate
								Where RowID = @Counter
							
						End /* End Of Monthly Frequency */
						Else If @Frequency = 1
						Begin
							UpDate   Inv Set Inv.SlabID = isNull(Slab.SLABID,0),
							Inv.Slab_Every = isNull(Slab.SLAB_EVERY_QTY,0),
							Inv.Slab_Value = isNull(Slab.SLAB_VALUE,0)
							From  #tmpInvDateWise Inv,tbl_mERP_PMParamSlab Slab
							Where 
							Slab.ParamID = @ParamID And Slab.SLAB_GIVEN_AS = 1
							And Inv.LinesOrBillsOrBA Between Slab.SLAB_START And Slab.SLAB_END
							And Inv.LinesOrBillsOrBA >= Slab.SLAB_EVERY_QTY

							Update #tmpInvDateWise Set 
							PointsEarned = Case isNull(Slab_Every,0) When 0 Then Slab_Value Else Cast(LinesOrBillsOrBA/Slab_Every as Int) * Slab_Value End
							Where SlabID > 0
		
							Update #tmpInvDateWise Set PointsEarned = 0 Where isNull(SlabID,0) = 0
							
							Select @TillDatePointsEarned = Sum(PointsEarned),@TillDateActual = Sum(LinesOrBillsOrBA) From #tmpInvDateWise
							Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise
							Select @TodaysActual = isNull(LinesOrBillsOrBA,0) ,
							@TodaysPointsEarned = isNull(PointsEarned,0) From  #tmpInvDateWise Where dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@FromDate)

							IF @ReportType = 'Monthly'
								UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = @TillDatePointsEarned,NoOfDaysInvoiced = @NoOfDaysInvoiced,
								AverageTillDate = Cast(@TillDateActual as Decimal(18,6))/@NoOfDaysInvoiced , Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
								LastTranDate = @LastInvoiceDate
								Where RowID = @Counter
						End
					End /* End of Datewise InvoiceDetails */
				End /*End of Bills Cut */


				If @ParamType = 3 /* Business Achievement Begins*/
				Begin
	--				If (Select Count(TargetDefnID) From tbl_mERP_PMetric_TargetDefn Where ParamID = @ParamID And FocusID = @FocusID And --isNull(Target,0) > 0 And 
	--				isNull(MaxPoints,0) > 0 And Active = 1 And SalesmanID = @SalesmanID And DSTypeID = @DSTypeID) >1
					Begin /* If target defined */
						If @isFocusParam = 'OverAll'
						Begin
							Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
							Select InvoiceDate,Sum(Case InvoiceType When 1 Then Amount When 3 Then Amount When 4 Then (-1) * Amount End),
							Max(InvoiceDateWithTime)
							From #tmpInvoice 
							Where SalesmanID = @SalesmanID
							And DSTypeID = @DSTypeID
							And CategoryGroup In(Select * from dbo.sp_splitIn2rows(@CGGroups,','))
							And InvoiceType In(1,3,4)
							Group By InvoiceDate
						End
						Else
						Begin
							If @Level = 2
								Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
								Select InvoiceDate,Sum(Case InvoiceType When 1 Then Amount When 3 Then Amount When 4 Then (-1) * Amount End),
								Max(InvoiceDateWithTime)
								From #tmpInvoice 
								Where SalesmanID = @SalesmanID
								And DSTypeID = @DSTypeID
								And CategoryGroup In(Select * from dbo.sp_splitIn2rows(@CGGroups,','))
								And InvoiceType In(1,3,4)
								And Division = @isFocusParam
								Group By InvoiceDate
							Else If @Level = 3
								Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
								Select InvoiceDate,Sum(Case InvoiceType When 1 Then Amount When 3 Then Amount When 4 Then (-1) * Amount End),
								Max(InvoiceDateWithTime)
								From #tmpInvoice 
								Where SalesmanID = @SalesmanID
								And DSTypeID = @DSTypeID
								And CategoryGroup In(Select * from dbo.sp_splitIn2rows(@CGGroups,','))
								And InvoiceType In(1,3,4)
								And SubCategory = @isFocusParam
								Group By InvoiceDate
							Else If @Level = 4
								Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
								Select InvoiceDate,Sum(Case InvoiceType When 1 Then Amount When 3 Then Amount When 4 Then (-1) * Amount End),
								Max(InvoiceDateWithTime)
								From #tmpInvoice 
								Where SalesmanID = @SalesmanID
								And DSTypeID = @DSTypeID
								And CategoryGroup In(Select * from dbo.sp_splitIn2rows(@CGGroups,','))
								And InvoiceType In(1,3,4)
								And MarketSKU = @isFocusParam
								Group By InvoiceDate
							Else If @Level = 5
								Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
								Select InvoiceDate,Sum(Case InvoiceType When 1 Then Amount When 3 Then Amount When 4 Then (-1) * Amount End),
								Max(InvoiceDateWithTime)
								From #tmpInvoice 
								Where SalesmanID = @SalesmanID
								And DSTypeID = @DSTypeID
								And CategoryGroup In(Select * from dbo.sp_splitIn2rows(@CGGroups,','))
								And InvoiceType In(1,3,4)
								And Product_Code = @isFocusParam
								Group By InvoiceDate
						End /* Focus param Ends */
						If (Select Count(InvoiceDate) From #tmpInvDateWise) >= 1
						Begin
							If @Frequency = 2 /* Monthly */
							Begin
								Select @Target = isNull(Target,0), @MaxPoints = case When Target > 0 Then isNull(MaxPoints,0) Else 0 End From tbl_mERP_PMetric_TargetDefn
								Where ParamID = @ParamID And FocusID = @FocusID And Active = 1 --And Target >= 0 
								And SalesmanID =@SalesmanID
								And DSTypeID = @DSTypeID

								Select @TillDateActualSales = Sum(LinesOrBillsOrBA) From #tmpInvDateWise
								Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise
								If @NoOfDaysInvoiced = 0 Set @NoOfDaysInvoiced = 1
								Select @TodaysActualSales = isNull(LinesOrBillsOrBA,0)
								From  #tmpInvDateWise Where dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@FromDate)
							
								if Exists (select ParamID from tbl_mERP_PMetric_TargetDefn Where ParamID = @ParamID And FocusID = @FocusID And Active = 1 ANd SalesmanID =@SalesmanID And Target > 0)
									Begin
										Select @ToTalSalesPercentage  = case When isnull(@Target,0) = 0 then 0 Else (@TillDateActualSales /Cast(@Target as Decimal(18,6))*100)  end
										Select @SlabID = SlabID, @SLAB_EVERY = SLAB_EVERY_QTY,@SLAB_VALUE = SLAB_VALUE
										From tbl_mERP_PMParamSlab Where 
										ParamID = @ParamID And SLAB_GIVEN_AS = 2
										And @ToTalSalesPercentage Between SLAB_START And SLAB_END
										Select @TillDatePointsEarned = @MaxPoints * Cast(@SLAB_VALUE as Decimal(18,6))/100									
										--If @TillDatePointsEarned > @MaxPoints
										--	Select @TillDatePointsEarned = @MaxPoints
										
									End
								Else
									Begin
										Select @ToTalSalesPercentage  = @TillDateActualSales
										Select @SlabID = SlabID, @SLAB_EVERY = SLAB_EVERY_QTY,@SLAB_VALUE = SLAB_VALUE
										From tbl_mERP_PMParamSlab Where 
										ParamID = @ParamID And SLAB_GIVEN_AS = 2
										And @ToTalSalesPercentage Between SLAB_START And SLAB_END
										Select @TillDatePointsEarned = 0
										--Select @TillDatePointsEarned = @MaxPoints * Cast(@SLAB_VALUE as Decimal(18,6))/100
										--If @TillDatePointsEarned > @MaxPoints
										--	Select @TillDatePointsEarned = @MaxPoints
									End
								IF @ReportType = 'Monthly'
									UpDate #tmpPM Set TillDateActual = @TillDateActualSales,
									TillDatePointsEarned = (Case @DayClosed When 0 Then 0 Else @TillDatePointsEarned End),	
									NoOfDaysInvoiced = @NoOfDaysInvoiced,
									AverageTillDate = Cast(@TillDateActualSales as decimal(18,6))/@NoOfDaysInvoiced , Target = @Target ,
									MaxPoints = @MaxPoints,GenerationDate = @RptGenerationDate,
									LastTranDate = @LastInvoiceDate Where RowID = @Counter
							End /* End Of Monthly Frequency */
							Else If @Frequency = 1 /* Daily Frequency Begins */
							Begin
								Select @Target = isNull(Target,0), @MaxPoints = isNull(MaxPoints,0) From tbl_mERP_PMetric_TargetDefn
								Where ParamID = @ParamID And FocusID = @FocusID And Active = 1 --And Target >= 0
								And SalesmanID =@SalesmanID
								And DSTypeID = @DSTypeID

								/* Update SalesPercentage */
								if @Target > 0  
								Update #tmpInvDateWise Set SalesPercentage = LinesOrBillsOrBA/Cast(@Target as Decimal(18,6)) * 100
								ELSE
								Update #tmpInvDateWise Set SalesPercentage = LinesOrBillsOrBA							
								UpDate   Inv Set Inv.SlabID = isNull(Slab.SLABID,0),
								Inv.Slab_Every = isNull(Slab.SLAB_EVERY_QTY,0),
								Inv.Slab_Value = isNull(Slab.SLAB_VALUE,0)
								From  #tmpInvDateWise Inv,tbl_mERP_PMParamSlab Slab
								Where 
								Slab.ParamID = @ParamID And Slab.SLAB_GIVEN_AS = 2
								And SalesPercentage Between Slab.SLAB_START And Slab.SLAB_END

								Update #tmpInvDateWise Set PointsEarned = (@MaxPoints * Cast(Slab_Value as Decimal(18,6)))/100 Where SlabID > 0
			
								/* When PointsEarned is greater than the MaxPoints Then show the 
								MaxPoints as the PointsEarned */
	--							Update #tmpInvDateWise Set PointsEarned = @MaxPoints 
	--							Where isNull(PointsEarned,0) > @MaxPoints
	--							And SlabID > 0

								Update #tmpInvDateWise Set PointsEarned = 0 Where isNull(SlabID,0) = 0
								
								Select @TillDateActualSales = Sum(LinesOrBillsOrBA),@TillDatePointsEarned = Sum(PointsEarned) From #tmpInvDateWise
								Select @TodaysActualSales = isNull(LinesOrBillsOrBA,0),@TodaysPointsEarned = isNull(PointsEarned,0)
								From  #tmpInvDateWise Where dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@FromDate)
								Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise
								
								IF @ReportType = 'Monthly'
									UpDate #tmpPM Set TillDateActual = @TillDateActualSales,
									TillDatePointsEarned = (Case @DayClosed When 0 Then 0 Else @TillDatePointsEarned End),
									NoOfDaysInvoiced = @NoOfDaysInvoiced,
									AverageTillDate = Cast(@TillDateActualSales as decimal(18,6))/@NoOfDaysInvoiced , Target = @Target ,
									MaxPoints = @MaxPoints,GenerationDate = @RptGenerationDate,
									LastTranDate = @LastInvoiceDate
									Where RowID = @Counter
								
							End /* Daily Frequency Ends */
						End /* DateWise InvoiceDetails */
					End /*End Of target Defined*/
				End /* Business Achievement Ends*/
				Fetch next from Cur_Counter into @Counter
				--Set @Counter = @Counter + 1
		End /* End of While */
		Close Cur_Counter
		Deallocate Cur_Counter

		/*To Insert DSType and Param info from PMetric_TargetDefn table for Salesman having Target with nil Invoices*/
		Create table #tDSTgtZeroInv (TGT_PMID Int, TGT_DSTYPEID Int, TGT_PARAMID Int, TGT_SMID int, TGT_TARGETVAL Decimal(18,6), TGT_MAXPOINT Decimal(18,6), 
									 TGT_FREQUENCY Int, TGT_ISFOCUSPARAM nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, TGT_PARAMMAX Decimal(18,6), TGT_PARAMTYPE Int)
		Declare @TGTPMID Int, @TGTDSTYPEID Int, @TGTPARAMID Int
		Declare Cur_TgtPMLst Cursor For
		Select Distinct PMID, PMDSTYPEID, PARAMID from tbl_merp_PMetric_TargetDefn where Active = 1 And PMID in (Select Distinct PMID from #tmpPM) 
		Open Cur_TgtPMLst 
		Fetch next from Cur_TgtPMLst into @TGTPMID, @TGTDSTYPEID, @TGTPARAMID 
		While @@Fetch_Status = 0
		Begin
		  Insert into #tDSTgtZeroInv(TGT_PMID, TGT_DSTYPEID, TGT_PARAMID, TGT_SMID, TGT_TARGETVAL, TGT_MAXPOINT, TGT_FREQUENCY, TGT_ISFOCUSPARAM, TGT_PARAMTYPE, TGT_PARAMMAX) 
		  Select Tdf.PMID, Tdf.PMDSTYPEID, Tdf.PARAMID, Tdf.SALESMANID, Tdf.TARGET, Tdf.MAXPOINTS, PMP.FREQUENCY,
		 (Case When isNull(PMP.ISFOCUSPARAMETER,0) = 0 Then N'OverAll' Else PMFocus.ProdCat_Code End),PMP.ParameterType, PMP.MaxPoints 
		  From tbl_merp_PMetric_TargetDefn Tdf, tbl_mERP_PMParam PMP, tbl_mERP_PMParamFocus PMFocus 
		  Where Tdf.ACTIVE= 1 And Tdf.PMID = @TGTPMID And Tdf.PMDSTYPEID = @TGTDSTYPEID And Tdf.PARAMID = @TGTPARAMID 
			And Tdf.SALESMANID not in (Select Distinct SalesmanID from #tmpPM Where PMID = @TGTPMID And DSTypeID = @TGTDSTYPEID And PARAMID = @TGTPARAMID And isNull(AverageTillDate,0) <> 0)
			And PMP.ParamID = Tdf.ParamID
			And PMP.ParamID = PMFocus.ParamID 
			--As per ITC request, only selected salesman details should be displayed in the report
			and Tdf.SALESMANID in (select salesmanid from salesman where salesman_name in(select Salesman from #tmpSalesman))
		  Fetch next from Cur_TgtPMLst into @TGTPMID, @TGTDSTYPEID, @TGTPARAMID
		End
		Close Cur_TgtPMLst 
		Deallocate Cur_TgtPMLst

	    
		--Select * from #tDSTgtZeroInv

		Update #tmpPM Set GenerationDate = @RptGenerationDate,LastTranDate = @LastInvoiceDate

		Insert Into #tmpDistinctPMDS(PMID,DSTypeID,SalesmanName)
		Select Distinct PMID,DSTypeID,Salesman_Name From #tmpPM
		Union 
		/*Fetch Non existing PM and DS information*/ 
		--As per QC Team analysis, DS Type filter is not working in the report. It is fixed.
		Select Distinct TGT_PMID,TGT_DSTYPEID, SM.Salesman_Name From #tDSTgtZeroInv tDST, Salesman SM,
		tbl_mERP_PMDSType PMDST
		Where SM.SalesManID = tDST.TGT_SMID  
		AND PMDST.PMID = tDST.TGT_PMID
		AND PMDST.DSTypeID=tDST.TGT_DSTYPEID
		AND PMDST.DSType in (Select DStype from #tmpDStype)
		

		Update #tmpPM Set GenerationDate = @RptGenerationDate


		/* To Add Subtotal and GrandTotal Row Begins */
		Select @PMMaxCount = 0
	--	Select @PMMaxCount = Count(RowID) From #tmpDistinctPMDS 
	--	Set @Counter = 1
	--	While @Counter <= @PMMaxCount
	--	Begin
		Declare Cur_Counter2 Cursor For
		Select Rowid from #tmpDistinctPMDS order by PMID,SalesmanName
		Open Cur_Counter2
		Fetch next from Cur_Counter2 Into @Counter 
		While @@Fetch_Status = 0
		Begin
			
			Select @PMID = 0,@PMDSTypeID = 0,@MaxPoints=0,@TillDatePointsEarned=0,@ToDaysPointsEarned=0,@SalesmanName=''
			Select @PMID = PMID ,@PMDSTypeID = DSTypeID,@SalesmanName=SalesmanName From #tmpDistinctPMDS Where RowID = @Counter
			
			Select @MaxPoints = Cast(Max(DS_Maxpoints) as Decimal(18,6)) ,@TillDatePointsEarned = Sum(isNull(TillDatePointsEarned,0)) ,
			@ToDaysPointsEarned = Sum(isNull(PointsEarnedToday,0))
			From #tmpPM Where PMID = @PMID And DSTypeID = @PMDSTypeID And Salesman_Name = @SalesmanName
			   
			Insert Into #tmpOutput(DSName,[DS Type],[Performance Metrics Code],Description,[Category Group],
			  [From Date],[To Date],Parameter,[Overall or Focus],Frequency,Target,[Average Till Date],[Till date Actual],
			  [Max Points],[Till Date Points Earned],[Todays Actual],[Points Earned Today],[Generation Date],
			  [Last Transaction Date]) 
			Select Salesman_Name,DSType,PMCode,PMDescription,Replace(CGGroups,',','|'),@FromDate,Convert(nVarchar(10), @ToDate, 103),
			  (Case ParameterType When 1 Then N'Lines Cut' When 2 Then N'Bills Cut' When 3 Then N'Business Achievement' End),
			  isFocusParam,(Case Frequency When 1 Then N'Daily' When 2 Then N'Monthly' End),
			  (Case ParameterType When 3 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then Cast(isNull(Target,0)/25. as decimal(18,6)) Else Cast(isNull(Target,0) as Decimal(18,6)) End) Else NULL End),
			  AverageTillDate,TillDateActual,(Case ParameterType When 3 Then Cast(isNull(MaxPoints,0) as Decimal(18,6)) Else NULL End),
			  (Case ParameterType When 3 Then
								(Case @DayClosed When 0 Then NULL When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then NULL Else Cast(isNull(TillDatePointsEarned,0) as decimal(18,6)) End) End)
								Else Cast(isNull(TillDatePointsEarned,0) as Decimal(18,6)) End),
			  ToDaysActual,
			  (Case ParameterType When 3 Then
								(Case @DayClosed When 0 Then NULL When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then NULL Else Cast(isNull(PointsEarnedToday,0) as Decimal(18,6)) End) End)
								Else (Case When (Frequency = 2 And @ReportType = 'Daily') Then NULL Else Cast(isNull(PointsEarnedToday,0) as Decimal(18,6)) End) End),
			  Convert(nVarchar(10),GenerationDate,103) + N' ' + Convert(nVarchar(8),GenerationDate,108),
			  Convert(nVarchar(10),LastTrandate,103) + N' ' + Convert(nVarchar(8),LastTrandate,108)
			From #tmpPM ,tbl_mERP_PMParamType ParamType
			Where PMID = @PMID And DSTypeID = @PMDSTypeID And Salesman_Name = @SalesmanName
			  And ParamType.ID = ParameterType
			Order By PMCode,DSType,Salesman_Name,ParamType.OrderBy

			  /*Insert Empty data for Salesman with Nil invoices for Business Achievment Param*/
			Insert Into #tmpOutputBA(DSName,[DS Type],[Performance Metrics Code],Description,[Category Group],
			  [From Date],[To Date],Parameter,[Overall or Focus],Frequency,Target,[Average Till Date],[Till date Actual],
			  [Max Points],[Till Date Points Earned],[Todays Actual],[Points Earned Today],[Generation Date], [Last Transaction Date]) 
			Select SM.Salesman_Name,DST.DSType,PM.PMCode,PM.Description,Replace(PM.CGGroups,',','|'),
			   @FromDate,@ToDate, N'Business Achievement', tDStgt.TGT_ISFOCUSPARAM,
			  (Case tDStgt.TGT_FREQUENCY When 1 Then N'Daily' When 2 Then N'Monthly' End),
			  (Case TGT_PARAMTYPE When 3 Then (Case When (TGT_FREQUENCY = 2 And @ReportType = 'Daily') Then Cast(isNull(TGT_TARGETVAL,0)/25. as decimal(18,6)) Else Cast(isNull(TGT_TARGETVAL,0) as Decimal(18,6)) End) Else NULL End),
			  NULL,NULL,Cast(IsNull(TGT_PARAMMAX,0) as Decimal(18,6)), NULL, NULL,NULL,
			  Convert(nVarchar(10),@RptGenerationDate,103) + N' ' + Convert(nVarchar(8),@RptGenerationDate,108),
			  Convert(nVarchar(10),@LastInvoiceDate,103) + N' ' + Convert(nVarchar(8),@LastInvoiceDate,108)
			FROM #tDSTgtZeroInv tDStgt, tbl_mERP_PMMaster PM, tbl_mERP_PMDSType DST, SalesMan SM
			Where PM.PMID = tDStgt.TGT_PMID 
			  And DST.DSTypeID = tDStgt.TGT_DSTypeID 
			  And SM.SalesmanID = tDStgt.TGT_SMID
			  --As per QC Team analysis, DS Type filter is not working in the report. It is fixed.
			  And DST.DSType in (Select DSType from #tmpDSType)
			  And PM.PMID = @PMID And DST.DSTypeID = @PMDSTypeID And SM.Salesman_Name = @SalesmanName			
			Order By PM.PMCode,DST.DSType,SM.Salesman_Name

			update A set a.Target=b.target,
						A.[Average Till Date] = B.[Average Till Date],
						A.[Till date Actual] = B.[Till date Actual],
						A.[Max Points] =B.[Max Points],
						A.[Till Date Points Earned]= B.[Till Date Points Earned],
						A.[Todays Actual] = B.[Todays Actual],
						A.[Points Earned Today] = B.[Points Earned Today]
  			from #tmpOutputBA B,#tmpOutput A where a.[Performance Metrics Code]=b.[Performance Metrics Code] and a.[Overall or Focus] = B.[Overall or Focus] And
			a.Parameter = b.parameter and a.dsname=b.dsname and a.Parameter='Business Achievement'  And A. [DS Type] = B.[DS Type]
			and a.[Category Group]=b.[Category Group]
			
			--Update #tmpOutput Set [Max Points] = 0 Where isnull(Target,0) = 0 And  [WDCode] <> 'Max Points Total:'
			delete from #tmpOutPutBA


		Fetch next from Cur_Counter2 Into @Counter 
	--		Set @Counter = @Counter + 1
		End
		Close Cur_Counter2 
		Deallocate Cur_Counter2


		Update T1  Set T1.DSID = T2.Cnt  from #tmpOutput T1,(Select SalesMan_Name, SalesManId as Cnt  from Salesman) T2 Where T1.DSName = T2.SalesMan_Name
		Update 	#tmpOutput set Target = 0 Where isnull(Target,0) = 0 and Parameter = 'Business Achievement'
		
		/* UAT Point - For max points exceeding calculation Starts*/
		Declare @PC nvarchar(4000)
		Declare @ID int	
		Declare @DST nvarchar(4000)
		Declare @DSID int
		Declare @MaxMasterpoints decimal(18,6)
		Declare @Earnedpoints decimal(18,6)
		Declare AllPM cursor for select distinct [Performance Metrics Code],[DS Type],DSId from #tmpOutput 
		open AllPM
		fetch from AllPM into @PC,@DST,@DSID
		while @@fetch_status =0
		BEGIN
			select @Earnedpoints=sum(isnull([Till Date Points Earned],0)) from #tmpOutput where [Performance Metrics Code]=@PC and [DS Type]=@DST and DSId=@DSID
			select @MaxMasterpoints= maxpoints from tbl_mERP_PMDSType where PMID in (select PMID from tbl_mERP_PMMaster where PMCode=@PC) and DSType=@DST
			select @ID = min(ID) from #tmpOutput where [Performance Metrics Code]=@PC and [DS Type]=@DST and DSId=@DSID
			if @MaxMasterpoints < @Earnedpoints
			BEGIN
				update #tmpOutput set [Till Date Points Earned]= @MaxMasterpoints where [Performance Metrics Code]=@PC and [DS Type]=@DST and DSId=@DSID
				Delete from  #tmpOutput where ID > @ID and [Performance Metrics Code]=@PC and [DS Type]=@DST and DSId=@DSID
			END
			fetch next from AllPM into @PC,@DST,@DSID
		END
		close AllPM
		Deallocate AllPM
		/* UAT Point - For max points exceeding calculation Ends*/

		insert into #final(DSId,DSType,[Category group],[Till Date Points Earned])
		Select DSID, [DS Type],[Category Group],
		[Till Date Points Earned]
		From #tmpOutput

	OvernOut:
		Drop Table #tmpCatGroup
		Drop Table #tmpDStype
		Drop Table #tmpSalesman
		Drop Table #tmpInvoice
		Drop Table #tmpPM
		Drop Table #tmpInvDateWise
		Drop Table #tmpOutput
		Drop table #tmpDistinctPMDS
		Drop table #tDSTgtZeroInv

		/* Performance Report END*/
		select * into #tmpGTotal from
		(select 1 as 'DS', T.DSType,max(Total_DS) as 'Total No. of DS',sum(isnull(F.[Till Date Points Earned],0)) as 'Variable Points','' as [Fixed],'' as Mobility from #tmpoutputRpt T left outer join #final F
		on T.DSType =F.DSType
		group by T.DSType) T
		insert into #tmpGTotal ([DS],[DSType],[Total No. of DS],[Variable Points],[Fixed],Mobility) 
		select -1 as 'DS','Total' as 'DSType',sum([Total No. of DS]) as [Total No. of DS],sum([Variable Points]) as 'Variable Points','' as [Fixed],''as Mobility from #tmpGTotal 
		
		select [DSType] as DST,[DSType],[Total No. of DS],[Variable Points],[Fixed],Mobility from #tmpGTotal order by [DS] desc
		
	END
	Drop table #tmpDSCount
	Drop table #tmpoutputRpt
	Drop table #tmpDSType_Rpt
	Drop table #Final
	Drop Table #tmpGTotal
END
