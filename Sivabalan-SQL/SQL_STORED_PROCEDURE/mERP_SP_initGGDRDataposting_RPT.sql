Create Procedure mERP_SP_initGGDRDataposting_RPT @DaycloseFromDate datetime=NULL,@DaycloseToDate datetime=NULL
AS
BEGIN
	Set dateformat dmy
	Declare @LDCDate Datetime
	Declare @OIUDate Datetime
	Declare @FromDate Datetime
	Declare @ToDate datetime
	Declare @Date Datetime
	Declare @OCGGlag As Int
	/* If below table contains any row then we will consider data posting is done and show alert to user*/
	Declare @Output Table (Result int)


	Select Top 1 @LDCDate=Convert(Nvarchar(10),getdate(),103)
	Select Top 1 @OIUDate=isnull(OldinventoryUploadDate,getdate()) from Setup
	Set @OCGGlag = (Select Top 1 isnull(Flag,0) from tbl_merp_Configabstract Where ScreenCode = 'OCGDS')

	Update GGDROutlet Set lastProcessedDate = dateAdd(d,-1,cast(('01-' + FromDate) as dateTime)) Where Isnull(lastProcessedDate,'') = ''
	
	Create Table #tmpGGDR(FromDate nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,ToDate nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,OutletID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,LastProcessedDate datetime,[ProdDefnID] int,CategoryGroup nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Reportfromdate datetime,ReportToDate datetime)

	CREATE TABLE #tmp(
		[Month] nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Date] datetime NULL,
		[RetailerCode] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DSID] [int] NULL,
		[DSTypeID] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CategoryGroup] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SystemSKU] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SalesVolume] decimal(18, 6) NULL,
		[SalesValue] decimal(18, 6) NULL,
		[ProdDefnID] int)	

	/* If invoked from Alerts screen */	
	If @DaycloseFromDate IS NULL and @DaycloseToDate IS NULL
	Begin
		insert into #tmpGGDR(FromDate,ToDate,OutletID,LastProcessedDate,[ProdDefnID],CategoryGroup,ReportFromDate,ReportToDate)
		Select FromDate,ToDate,OutletID,LastProcessedDate,[ProdDefnID],Case When @OCGGlag=1 Then isnull(OCG,'') else isnull(CatGroup,'') End,ReportFromDate,ReportToDate  from GGDROutlet where 
		isnull(IsReceived,0)=1
	End
	Else
	/* If invoked from Day Close */	
	Begin
		/* Get the list where Last Day of [ToDate] is not yet closed*/
		insert into #tmpGGDR(FromDate,ToDate,OutletID,LastProcessedDate,[ProdDefnID],CategoryGroup,ReportFromDate,ReportToDate)
		Select FromDate,ToDate,OutletID,LastProcessedDate,[ProdDefnID],Case When @OCGGlag=1 Then isnull(OCG,'') else isnull(CatGroup,'') End,ReportFromDate,ReportToDate from GGDROutlet where 
		LastProcessedDate <> dateadd(d,-1,dateadd(m,1,dbo.fn_ReturnDateforPeriod(ToDate)))
	End
	/* Get the data from minimum FromDate*/
	If @DaycloseFromDate IS NULL and @DaycloseToDate IS NULL
	Begin
		Select @FromDate = min(dbo.fn_ReturnDateforPeriod(FromDate)) from #tmpGGDR
	End
	Else
	Begin
		/* To get InvoiceDetails greater than LastProcessedDate*/
		Select @FromDate = dateadd(d,1,min(LastProcessedDate)) from #tmpGGDR
	End
	

	If @DaycloseFromDate IS NULL and @DaycloseToDate IS NULL
	Begin
			Select @ToDate=max(dateadd(d,-1,dateadd(m,1,dbo.fn_ReturnDateforPeriod(ToDate)))) from #tmpGGDR
			/* *If ToDate > Last Close Day Date Then Update ToDate as Last Day Close Date*/
			If @ToDate > @LDCDate
				Set @ToDate =@LDCDate
	End
	Else
	Begin
		Select @ToDate=@DaycloseToDate
	End

	/* Temp InvoiceAbstract Table*/
	Select * into #tmpInvAbstract From Invoiceabstract where 
	customerID in (Select OutletID from #tmpGGDR) 
	And	Convert(Nvarchar(10),Invoicedate,103) between @FromDate and @ToDate
	And Isnull(InvoiceType,0) in (1,3,4)
	And Isnull(Status,0) & 128 = 0
	
	update #tmpInvAbstract set invoicedate = convert(nvarchar(10),InvoiceDate,103)

	Create Table #tmpInvDetail (Invoiceid int,Product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Quantity decimal(18,6),SalePrice decimal(18,6),Amount decimal(18,6))
	/* Temp InvoiceDetail Table*/
	
	Declare @OutletID nvarchar(15)
	Declare @ProdDefnID int
	Declare @CatGroup nvarchar(255)
	Declare @TmpFromDate nvarchar(15)
	Declare @TmpToDate nvarchar(15)
	Declare @ReportFromDate datetime
	Declare @ReportToDate datetime 

	If @DaycloseFromDate IS NULL and @DaycloseToDate IS NULL
	Begin
		Truncate Table PendingGGRRFinalDataPost
		Insert Into PendingGGRRFinalDataPost(FromDateMonth,TodateMonth,CustomerID,Fromdate,ToDate)
		Select Distinct FromDate,ToDate,OutletID,ReportFromDate,ReportToDate From #tmpGGDR
	End

	Declare DPGGDR Cursor For Select distinct FromDate,ToDate,OutletID,ProdDefnID,CategoryGroup,ReportFromDate,ReportToDate from #tmpGGDR order by ReportFromDate
	Open DPGGDR
	Fetch from DPGGDR into @TmpFromDate,@TmpToDate,@OutletID,@ProdDefnID,@CatGroup,@ReportFromDate,@ReportToDate
	While @@fetch_status=0
	Begin
		
		Truncate Table #tmpInvDetail

		Insert into #tmpInvDetail(Invoiceid,Product_code,Quantity,SalePrice,Amount)
		Select Invoiceid,Product_code,Quantity,SalePrice,Amount From InvoiceDetail where 
		InvoiceID in (Select invoiceid from #tmpInvAbstract where CustomerID=@OutletID and invoicedate between @ReportFromDate and @ReportToDate ) And isnull(Saleprice,0) >0
		And Product_code in 
		(Select distinct T. Product_code from TmpGGDRSKUDetails T,#tmpGGDR Tmp where Tmp.FromDate =@TmpFromDate and Tmp.ToDate= @TmpToDate And T.ProdDefnID=Tmp.ProdDefnID And T.ProdDefnID=@ProdDefnID)


		Truncate Table #tmp
		Insert Into #tmp([Month],[Date],[RetailerCode],[DSID],[DSTypeID],[CategoryGroup],[SystemSKU],[SalesVolume],[SalesValue],ProdDefnID)
		Select 
		cast((Left((datename(m,IA.Invoicedate)),3))as Nvarchar) + '-' + cast(Year(IA.Invoicedate) as Nvarchar),
		Convert(Nvarchar(10),IA.Invoicedate,103),
		IA.CustomerID,
		IA.SalesmanID,
		IA.DSTypeID,
		(Case 
		When (Select Top 1 isnull(Flag,0) from tbl_merp_Configabstract Where ScreenCode = 'OCGDS') = 0 Then
		(Select Distinct GR.Categorygroup from items I ,tblCGDivMapping GR,ItemCategories IC4,ItemCategories IC3,ItemCategories IC2 
			where IC4.categoryid = i.categoryid 
			And IC4.ParentId = IC3.categoryid 
			And IC3.ParentId = IC2.categoryid 
			And IC2.Category_Name = GR.Division 
			And I.Product_code = ID.Product_Code)
		Else 
			(select Distinct GroupName from OCGItemMaster Where isnull(Exclusion,0) = 0 And SystemSKU = ID.Product_Code) 
		End) Categorygroup,
		ID.Product_Code,
		(Case When Isnull(InvoiceType,0) = 4 Then (-1 * ID.Quantity) Else ID.Quantity End) Quantity,
		(Case When Isnull(InvoiceType,0) = 4 Then (-1 * ID.Amount) Else ID.Amount End) Amount,@ProdDefnID
		from #tmpInvAbstract IA, #tmpInvDetail ID
		Where IA.InvoiceID = ID.InvoiceID
		AND IA.CustomerID=@OutletID

		Insert Into GGDRDataRPT (InvoiceDate,RetailerCode,DSID,DSType,CategoryGroup,SystemSKU,SalesVolume,SalesValue,ProdDefnId,CreationDate)
		select T.Date,T.RetailerCode,T.DSID,DS.DSTypeValue,T.CategoryGroup ,T.SystemSKU,Sum(T.SalesVolume),Sum(T.SalesValue),@ProdDefnId,Getdate() 
		From #tmp T,DSType_Master DS Where T.DSTypeID = DS.DSTypeID and T.CategoryGroup=@CatGroup
		Group By T.Date,T.RetailerCode,T.DSID,DS.DSTypeValue,T.CategoryGroup ,T.SystemSKU

		Fetch Next from DPGGDR into @TmpFromDate,@TmpToDate,@OutletID,@ProdDefnID,@CatGroup,@ReportFromDate,@ReportToDate
	End
	Close DPGGDR
	Deallocate DPGGDR

	--To Update Category Details
	Update G Set G.MarketSKU=T.MarketSKU,G.SubCategory=T.SubCategory,G.Division=T.Division From GGDRDataRPT G,TmpGGDRSKUDetails T
	Where T.Product_code=G.SystemSKU


	Drop Table #tmpGGDR
	Drop Table #tmpInvAbstract
	Drop Table #tmpInvDetail
	Drop Table #tmp
END
