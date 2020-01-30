Create Procedure mERP_SP_initGGDRDataposting  @DaycloseFromDate datetime=NULL,@DaycloseToDate datetime=NULL,@IsRepost Int =0
AS
BEGIN
	Set dateformat dmy
	Declare @LDCDate Datetime
	Declare @OIUDate Datetime
	Declare @FromDate Datetime
	Declare @ToDate datetime
	Declare @Date Datetime
	Declare @OCGGlag As Int
	Declare @IsReceivedPost Int

	Begin Tran

	/* If below table contains any row then we will consider data posting is done and show alert to user*/
	Declare @Output Table (Result int)

	If @DaycloseFromDate Is not Null
	Begin	
		Delete From GGDRData Where InvoiceDate > @DaycloseFromDate
	End

	Select Top 1 @LDCDate=isnull(LastinventoryUpload,getdate()) from Setup
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
		Set @IsReceivedPost = 1 
	End
	Else
	/* If invoked from Day Close */	
	Begin
		/* Get the list where Last Day of [ToDate] is not yet closed*/
		If isnull(@IsRepost,0) = 1
		Begin		
			/* To implement Reposting logic */
			Update GGDROutlet Set LastProcessedDate = dateadd(d,-1,@DaycloseFromDate) where 
			@DaycloseToDate between ReportFromDate And ReportToDate

			insert into #tmpGGDR(FromDate,ToDate,OutletID,LastProcessedDate,[ProdDefnID],CategoryGroup,ReportFromDate,ReportToDate)
			Select FromDate,ToDate,OutletID,LastProcessedDate,[ProdDefnID],Case When @OCGGlag=1 Then isnull(OCG,'') else isnull(CatGroup,'') End,ReportFromDate,ReportToDate from GGDROutlet where 
			@DaycloseToDate between ReportFromDate And ReportToDate

		End
		Else
		Begin
			insert into #tmpGGDR(FromDate,ToDate,OutletID,LastProcessedDate,[ProdDefnID],CategoryGroup,ReportFromDate,ReportToDate)
			Select FromDate,ToDate,OutletID,LastProcessedDate,[ProdDefnID],Case When @OCGGlag=1 Then isnull(OCG,'') else isnull(CatGroup,'') End,ReportFromDate,ReportToDate from GGDROutlet where 
			LastProcessedDate <> dateadd(d,-1,dateadd(m,1,dbo.fn_ReturnDateforPeriod(ToDate)))
		End
	End
	/* Get the data from minimum FromDate*/
	If @DaycloseFromDate IS NULL and @DaycloseToDate IS NULL
	Begin
		Select @FromDate = min(dbo.fn_ReturnDateforPeriod(FromDate)) from #tmpGGDR
	End
	Else
	Begin
		/* To get InvoiceDetails greater than LastProcessedDate*/
		If isnull(@IsRepost,0) = 1
		Begin
			Set @FromDate = @DaycloseFromDate
		End
		Else
		Begin
			Select @FromDate = dateadd(d,1,min(LastProcessedDate)) from #tmpGGDR
		End
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
	
    IF OBJECT_ID('tempdb..#InvDetail') IS NULL
	select * into #InvDetail from  InvoiceDetail Where Invoiceid in (select Invoiceid from #tmpInvAbstract)
	
	update #tmpInvAbstract set invoicedate = convert(nvarchar(10),InvoiceDate,103)
	
	Create Table #tmpInvDetail (Invoiceid int,Product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Quantity decimal(18,6),SalePrice decimal(18,6),Amount decimal(18,6))
	/* Temp InvoiceDetail Table*/
	
	--Declare @OutletID nvarchar(15)
	--Declare @ProdDefnID int
	--Declare @CatGroup nvarchar(255)
	--Declare @TmpFromDate nvarchar(15)
	--Declare @TmpToDate nvarchar(15)
	--Declare @ReportFromDate datetime
	--Declare @ReportToDate datetime 

	Delete from GGDRData where --RetailerCode in (Select RetailerCode from #tmp) and 
	InvoiceDate in (Select convert(nvarchar(10),InvoiceDate,103) from #tmpInvAbstract)

	
	Delete from GGRRDayCloseLog where DayCloseDate between @FromDate and @ToDate

	If @DaycloseFromDate IS NULL and @DaycloseToDate IS NULL
	Begin
		Truncate Table PendingGGRRFinalDataPost
		Insert Into PendingGGRRFinalDataPost(FromDateMonth,TodateMonth,CustomerID,Fromdate,ToDate)
		Select Distinct FromDate,ToDate,OutletID,ReportFromDate,ReportToDate From #tmpGGDR
	End

	IF OBJECT_ID('tempdb..#TmpGGDRSKUDetails') IS NULL
	Select * into #TmpGGDRSKUDetails from TmpGGDRSKUDetails T
	Where T.ProdDefnID In (select Distinct ProdDefnID From #tmpGGDR) 
	And T.Product_Code In (Select Distinct ID.Product_Code From #InvDetail ID)
	
	--IF OBJECT_ID('tempdb..#TmpGGDRSKUDetails') IS NULL
	--Select T.* into #TmpGGDRSKUDetails from TmpGGDRSKUDetails T
	--Join #tmpGGDR GG On GG.ProdDefnID = T.ProdDefnID 
	--Join #tmpInvAbstract IA On IA.CustomerID = GG.OutletID 
	--Join #InvDetail ID On IA.InvoiceID = ID.InvoiceID and id.Product_Code = t.Product_Code 	

	--Select * From #tmpGGDR
	--Select Distinct CustomerID from #tmpInvAbstract
	--Select Distinct Product_Code From #InvDetail
	--Select Distinct ProdDefnID From #TmpGGDRSKUDetails

	--Select distinct FromDate,ToDate,OutletID,ProdDefnID,CategoryGroup,ReportFromDate,ReportToDate 
	--From #tmpGGDR Order by ReportFromDate

	--Select distinct FromDate,ToDate,OutletID,ProdDefnID,CategoryGroup,ReportFromDate,ReportToDate 
	--From #tmpGGDR 
	--Where OutletID in (Select Distinct CustomerID from #tmpInvAbstract)	
	--Order by ReportFromDate

	--Select distinct FromDate,ToDate,OutletID,ProdDefnID,CategoryGroup,ReportFromDate,ReportToDate 
	--From #tmpGGDR 
	--Where OutletID in (Select Distinct CustomerID from #tmpInvAbstract)
	--And ProdDefnID in (select Distinct ProdDefnID From #TmpGGDRSKUDetails)
	--Order by ReportFromDate

--	Declare DPGGDR Cursor For Select distinct FromDate,ToDate,OutletID,ProdDefnID,CategoryGroup,ReportFromDate,ReportToDate 
--	From #tmpGGDR 
--	Where OutletID in (Select Distinct CustomerID from #tmpInvAbstract) And ProdDefnID in  (Select Distinct ProdDefnID From #TmpGGDRSKUDetails)
--	Order by ReportFromDate
--	Open DPGGDR
--	Fetch from DPGGDR into @TmpFromDate,@TmpToDate,@OutletID,@ProdDefnID,@CatGroup,@ReportFromDate,@ReportToDate
--	While @@fetch_status=0
--	Begin		
		
--		Truncate Table #tmpInvDetail

----		Insert into #tmpInvDetail(Invoiceid,Product_code,Quantity,SalePrice,Amount)
----		Select Invoiceid,Product_code,Quantity,SalePrice,Amount From InvoiceDetail where 
----		InvoiceID in (Select invoiceid from #tmpInvAbstract where CustomerID=@OutletID and invoicedate between @ReportFromDate and @ReportToDate ) And isnull(Saleprice,0) >0
----		And Product_code in 
----		(Select distinct T. Product_code from TmpGGDRSKUDetails T,#tmpGGDR Tmp where Tmp.FromDate =@TmpFromDate and Tmp.ToDate= @TmpToDate And T.ProdDefnID=Tmp.ProdDefnID And T.ProdDefnID=@ProdDefnID)


--		Insert into #tmpInvDetail(Invoiceid,Product_code,Quantity,SalePrice,Amount)  
--		Select ID.Invoiceid,ID.Product_code,Sum(ID.Quantity),Max(ID.SalePrice),Max(ID.Amount)
--		From #InvDetail ID
--		Join (Select InvoiceID=InvoiceID  from #tmpInvAbstract where CustomerID=@OutletID and invoicedate between @ReportFromDate and @ReportToDate) IA On ID.InvoiceID = IA.InvoiceID
--		Join (Select Distinct Product_code=T.Product_code  from #TmpGGDRSKUDetails T,#tmpGGDR Tmp where T.ProdDefnID=@ProdDefnID And Tmp.FromDate =@TmpFromDate and Tmp.ToDate= @TmpToDate		And T.ProdDefnID=Tmp.ProdDefnID) NewT On ID.Product_code = NewT.Product_code
--		Where isnull(ID.Saleprice,0) >0  
--		Group By ID.Invoiceid,ID.Product_code,ID.Serial

--		Truncate Table #tmp
--		Insert Into #tmp([Month],[Date],[RetailerCode],[DSID],[DSTypeID],[CategoryGroup],[SystemSKU],[SalesVolume],[SalesValue],ProdDefnID)
--		Select 
--		cast((Left((datename(m,IA.Invoicedate)),3))as Nvarchar) + '-' + cast(Year(IA.Invoicedate) as Nvarchar),
--		Convert(Nvarchar(10),IA.Invoicedate,103),
--		IA.CustomerID,
--		IA.SalesmanID,
--		IA.DSTypeID,
--		(Case 
--		When (Select Top 1 isnull(Flag,0) from tbl_merp_Configabstract Where ScreenCode = 'OCGDS') = 0 Then
--		(Select Distinct GR.Categorygroup from items I ,tblCGDivMapping GR,ItemCategories IC4,ItemCategories IC3,ItemCategories IC2 
--			where IC4.categoryid = i.categoryid 
--			And IC4.ParentId = IC3.categoryid 
--			And IC3.ParentId = IC2.categoryid 
--			And IC2.Category_Name = GR.Division 
--			And I.Product_code = ID.Product_Code)
--		Else 
--			(select Distinct GroupName from OCGItemMaster Where isnull(Exclusion,0) = 0 And SystemSKU = ID.Product_Code) 
--		End) Categorygroup,
--		ID.Product_Code,
--		(Case When Isnull(InvoiceType,0) = 4 Then (-1 * ID.Quantity) Else ID.Quantity End) Quantity,
--		(Case When Isnull(InvoiceType,0) = 4 Then (-1 * ID.Amount) Else ID.Amount End) Amount,@ProdDefnID
--		from #tmpInvAbstract IA, #tmpInvDetail ID
--		Where IA.InvoiceID = ID.InvoiceID
--		AND IA.CustomerID=@OutletID

		
--/* For IG: IF data Repost then Old data is not removed.*/
----		Delete from GGDRData Where Dbo.Stripdatefromtime(InvoiceDate) In (Select Distinct Dbo.Stripdatefromtime(Date) From #tmp)
		
--		--and ProdDefnId=@ProdDefnID
		
--		Insert Into ggdrdata (InvoiceDate,RetailerCode,DSID,DSType,CategoryGroup,SystemSKU,SalesVolume,SalesValue,ProdDefnId,CreationDate)
--		select T.Date,T.RetailerCode,T.DSID,DS.DSTypeValue,T.CategoryGroup ,T.SystemSKU,Sum(T.SalesVolume),Sum(T.SalesValue),@ProdDefnId,Getdate() 
--		From #tmp T,DSType_Master DS Where T.DSTypeID = DS.DSTypeID and T.CategoryGroup=@CatGroup
--		Group By T.Date,T.RetailerCode,T.DSID,DS.DSTypeValue,T.CategoryGroup ,T.SystemSKU
		
--		Fetch Next from DPGGDR into @TmpFromDate,@TmpToDate,@OutletID,@ProdDefnID,@CatGroup,@ReportFromDate,@ReportToDate
--	End
--	Close DPGGDR
--	Deallocate DPGGDR

	IF IsNull(@OCGGlag,0) = 1
		Insert Into GGDRData (InvoiceDate,RetailerCode,DSID,DSType,CategoryGroup,SystemSKU,SalesVolume,SalesValue,ProdDefnId,CreationDate)
		select T.Date,T.RetailerCode,T.DSID,T.DSType ,T.CategoryGroup ,T.SystemSKU,Sum(T.SalesVolume),Sum(T.SalesValue),T.ProdDefnID ,Getdate() 
		From (
		Select [Month]=Cast((Left((DateName(m,IA.Invoicedate)),3))as Nvarchar) + '-' + Cast(Year(IA.Invoicedate) as Nvarchar),
		[Date]=Convert(nVarchar(10),IA.Invoicedate,103),
		[RetailerCode]=IA.CustomerID,[DSID]= IA.SalesmanID,[DSTypeID]= IA.DSTypeID, DSType=DS.DSTypeValue,
		[CategoryGroup]=OCGI.GroupName,
		[SystemSKU]=ID.Product_Code,
		[SalesVolume]=(Case When Isnull(IA.InvoiceType,0) = 4 Then (-1 * ID.Quantity) Else ID.Quantity End),
		[SalesValue]=(Case When Isnull(IA.InvoiceType,0) = 4 Then (-1 * ID.Amount) Else ID.Amount End),
		ProdDefnID=GGRR.ProdDefnID 
		From #tmpInvAbstract IA
		Join (Select InvoiceID=ID.InvoiceID,Product_code=ID.Product_Code,Quantity=IsNull(Sum(ID.Quantity),0),SalePrice=IsNull(Max(ID.SalePrice),0),Amount=IsNull(Max(ID.Amount),0)
		From #InvDetail ID Group By ID.Invoiceid,ID.Product_code,ID.Serial ) ID On ID.InvoiceID = IA.InvoiceID And IsNull(ID.SalePrice,0) > 0
		Join #tmpGGDR GGRR On GGRR.OutletID = IA.CustomerID And IA.InvoiceDate Between GGRR.Reportfromdate and GGRR.ReportToDate 
		Join #TmpGGDRSKUDetails TSKU On TSKU.ProdDefnID = GGRR.ProdDefnID And TSKU.Product_Code = ID.Product_code 		
		Join OCGItemMaster OCGI On OCGI.SystemSKU = ID.Product_code And OCGI.GroupName = GGRR.CategoryGroup 
		Join DSType_Master DS On Ds.DSTypeId = IA.DSTypeID ) T
		Group By T.Date,T.RetailerCode,T.DSID,T.DSType ,T.CategoryGroup ,T.SystemSKU,T.ProdDefnID		
	Else
		Insert Into GGDRData (InvoiceDate,RetailerCode,DSID,DSType,CategoryGroup,SystemSKU,SalesVolume,SalesValue,ProdDefnId,CreationDate)
		select T.Date,T.RetailerCode,T.DSID,T.DSType ,T.CategoryGroup ,T.SystemSKU,Sum(T.SalesVolume),Sum(T.SalesValue),T.ProdDefnID,Getdate() 
		From (
		Select [Month]=Cast((Left((DateName(m,IA.Invoicedate)),3))as Nvarchar) + '-' + Cast(Year(IA.Invoicedate) as Nvarchar),
		[Date]=Convert(nVarchar(10),IA.Invoicedate,103),
		[RetailerCode]=IA.CustomerID,[DSID]= IA.SalesmanID,[DSTypeID]= IA.DSTypeID, DSType=DS.DSTypeValue,
		[CategoryGroup]= GR.Categorygroup,
		[SystemSKU]=ID.Product_Code,
		[SalesVolume]=(Case When Isnull(IA.InvoiceType,0) = 4 Then (-1 * ID.Quantity) Else ID.Quantity End),
		[SalesValue]=(Case When Isnull(IA.InvoiceType,0) = 4 Then (-1 * ID.Amount) Else ID.Amount End),
		ProdDefnID=GGRR.ProdDefnID 
		From #tmpInvAbstract IA
		Join (Select InvoiceID=ID.InvoiceID,Product_code=ID.Product_Code,Quantity=IsNull(Sum(ID.Quantity),0),SalePrice=IsNull(Max(ID.SalePrice),0),Amount=IsNull(Max(ID.Amount),0)
		From #InvDetail ID Group By ID.Invoiceid,ID.Product_code,ID.Serial ) ID On ID.InvoiceID = IA.InvoiceID  And IsNull(ID.SalePrice,0) > 0
		Join #tmpGGDR GGRR On GGRR.OutletID = IA.CustomerID And IA.InvoiceDate Between GGRR.Reportfromdate and GGRR.ReportToDate 
		Join #TmpGGDRSKUDetails TSKU On TSKU.ProdDefnID = GGRR.ProdDefnID And TSKU.Product_Code = ID.Product_code 	
		Join Items I On I.Product_Code = ID.Product_code 
		Join ItemCategories MSKU On MSKU.CategoryID = I.CategoryID 
		Join ItemCategories Subcat On Subcat.CategoryID = MSKU.ParentID 
		Join ItemCategories Div On Div.CategoryID = Subcat.ParentID 
		Join tblCGDivMapping GR On GR.Division = Div.Category_Name And GR.Categorygroup = GGRR.CategoryGroup  
		Join DSType_Master DS On Ds.DSTypeId = IA.DSTypeID ) T
		Group By T.Date,T.RetailerCode,T.DSID,T.DSType ,T.CategoryGroup ,T.SystemSKU, T.ProdDefnID		

	--To Update Category Details
	Exec mERP_sp_UpdateCategory_GGDRData

	If @DaycloseToDate Is NOT NULL
		Select @Date=@DaycloseToDate
	Else
		Select @Date=@LDCDate

	Declare @FDate nvarchar(10)
	Declare @TDate nvarchar(10)
	Declare @CID nvarchar(15)
	--Declare GGDR Cursor For Select distinct fromDate,ToDate,OutletID from #tmpGGDR
	--Open GGDR
	--Fetch from GGDR into @FDate,@TDate,@CID
	--While @@Fetch_status=0
	--Begin
	--	/* If ToDate is less than First of Close Day Month*/
	--	If dateadd(d,-1,dateadd(m,1,dbo.fn_ReturnDateforPeriod(@TDate))) < cast('01-' as nvarchar(3))+ cast(month(Dbo.Stripdatefromtime(@Date)) as nvarchar(3))+cast('-' as nvarchar(1))+cast(year(Dbo.Stripdatefromtime(@Date)) as nvarchar(4))
	--	Begin
	--		If (select count(*) from @Output)=0
	--		Insert into @Output Select 1
	--		Update G Set LastProcessedDate=	dateadd(d,-1,dateadd(m,1,dbo.fn_ReturnDateforPeriod(@TDate))),IsReceived=0 From GGDROutlet G,#tmpGGDR T
	--		Where G.FromDate=T.FromDate And
	--		G.ToDate=T.ToDate And
	--		G.OutletID=T.OutletID And
	--		G.LastProcessedDate=T.LastProcessedDate
	--		And G.OutletID=@CID
	--		And G.FromDate=@FDate
	--		And G.ToDate=@TDate
	--	End
	--	Else
	--	Begin
	--		If (select count(*) from @Output)=0
	--		Insert into @Output Select 1
	--		Update G Set LastProcessedDate=	@Date,IsReceived=0 From GGDROutlet G,#tmpGGDR T
	--		Where G.FromDate=T.FromDate And
	--		G.ToDate=T.ToDate And
	--		G.OutletID=T.OutletID And
	--		G.LastProcessedDate=T.LastProcessedDate
	--		And G.OutletID=@CID
	--		And G.FromDate=@FDate
	--		And G.ToDate=@TDate
	--	End
	--	Fetch Next from GGDR into @FDate,@TDate,@CID
	--End
	--Close GGDR
	--Deallocate GGDR
	
	If Exists (Select 'x' 	From GGDROutlet G,#tmpGGDR T 
	Where G.FromDate=T.FromDate And G.ToDate=T.ToDate And G.OutletID=T.OutletID And G.LastProcessedDate=T.LastProcessedDate
	And dateadd(d,-1,dateadd(m,1,dbo.fn_ReturnDateforPeriod(G.ToDate))) < 
	cast('01-' as nvarchar(3))+ cast(month(Dbo.Stripdatefromtime(@Date)) as nvarchar(3))+cast('-' as nvarchar(1))+cast(year(Dbo.Stripdatefromtime(@Date)) as nvarchar(4))
	)
	Begin
	If (select count(*) from @Output)=0
			Insert into @Output Select 1
		
		Update G Set LastProcessedDate =	dateadd(d,-1,dateadd(m,1,dbo.fn_ReturnDateforPeriod(@TDate))),IsReceived=0 
		From GGDROutlet G,#tmpGGDR T
		Where G.FromDate=T.FromDate And
		G.ToDate=T.ToDate And
		G.OutletID=T.OutletID And
		G.LastProcessedDate=T.LastProcessedDate			
	End	

	If Exists (Select 'x' 	From GGDROutlet G,#tmpGGDR T 
	Where G.FromDate=T.FromDate And G.ToDate=T.ToDate And G.OutletID=T.OutletID And G.LastProcessedDate=T.LastProcessedDate
	And dateadd(d,-1,dateadd(m,1,dbo.fn_ReturnDateforPeriod(G.ToDate))) >= 
	cast('01-' as nvarchar(3))+ cast(month(Dbo.Stripdatefromtime(@Date)) as nvarchar(3))+cast('-' as nvarchar(1))+cast(year(Dbo.Stripdatefromtime(@Date)) as nvarchar(4))
	)
	Begin	
	If (select count(*) from @Output)=0
			Insert into @Output Select 1
		
		Update G Set LastProcessedDate = @Date, IsReceived=0 
		From GGDROutlet G,#tmpGGDR T
		Where G.FromDate=T.FromDate And
		G.ToDate=T.ToDate And
		G.OutletID=T.OutletID And
		G.LastProcessedDate=T.LastProcessedDate						
	End
	
	Drop Table #tmpGGDR
	Drop Table #tmpInvAbstract
	Drop Table #tmpInvDetail
	Drop Table #tmp
/*
	/* Archeive Process*/
	Declare @Month as int
	Declare @CloseMonths int
	Declare @i as int
	Declare @TmpDate as datetime
	Set @i=1
	Select Top 1 @Month=Value from Tbl_merp_ConfigAbstract A, Tbl_merp_ConfigDetail D where D.ScreenCode='GGDR' and D.ControlName='Archieve'
    And A.ScreenCode=D.ScreenCode and A.Flag=1
	If @DaycloseFromDate is not null And @DaycloseToDate is not null
	Begin
		/* If From Date is greater than or equal to 1st of month then archieve the data*/
		If @DaycloseFromDate >= cast('01-'+ cast(month(@DaycloseFromDate) as varchar(3))+'-'+ cast(year(@DaycloseFromDate) as nvarchar(4)) as Datetime)
		Begin
			If isnull(@Month,0) <> 0
			Begin
				Delete from GGDRData where InvoiceDate < Dateadd(m,-@Month,Dateadd(d,-1,@DaycloseFromDate))
			End
		End
		/* If more than one month is closed at a stretch */	
		If datediff(m,@DaycloseFromDate,@DaycloseToDate) > 1
		Begin
			If isnull(@Month,0) <> 0
			Begin
				/* Add one month from @DaycloseFromDate initially*/
				Select @TmpDate= dateadd(m,1,cast('01-'+ cast(month(@DaycloseFromDate) as varchar(3))+'-'+ cast(year(@DaycloseFromDate) as nvarchar(4)) as Datetime))
				Select @CloseMonths = datediff(m,@DaycloseFromDate,@DaycloseToDate)
				While @i <=@CloseMonths
				Begin
					Delete from GGDRData where InvoiceDate < Dateadd(m,-@Month,Dateadd(d,-1,@TmpDate))		
					/* To store next month date*/
					Set @TmpDate= Dateadd(m,1,@TmpDate)
					Set @i=@i+1
				End
			End
		End
	End
	*/

	/* Log Part starts */
	DECLARE @DateFrom smalldatetime, @DateTo smalldatetime;
	SELECT @DateFrom=@FromDate
	Select top 1 @DateTo=@ToDate
	Delete from GGRRDayCloseLog Where DayCloseDate >= @DateFrom
	If @DateFrom <= @DateTo
	BEGIN
		Create Table #tmpDates(AllDate Datetime);
		WITH T(date)
		AS
		( 
			SELECT @DateFrom 
			UNION ALL
			SELECT DateAdd(day,1,T.date) FROM T WHERE T.date < @DateTo
		)
		insert into #tmpDates(AllDate)
		SELECT date FROM T OPTION (MAXRECURSION 32767);
		Insert into GGRRDayCloseLog(DayCloseDate,Status)
		Select AllDate,1 from #tmpDates
		Drop Table #tmpDates
	END

	/* Log Part Ends */
	
	If IsNull(@IsReceivedPost ,0) = 0
		Update DayCloseModules set DayCloseDate= @DaycloseToDate where module='GGDR'
	
	Commit Tran

/* To Show alert to the user*/
	If (select count(*) from @Output)>0
		Select 1
	Else
		Select 0
END
