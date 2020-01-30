Create Function mERP_FN_PointsforGGDR_View()
Returns  
@Output table (DSID int,ConvertedOutlets decimal(18,6),Points decimal(18,6),Parameter Nvarchar(255))
Begin
	Declare @CatGroup nVarchar(1000)
	Declare @DStype nVarchar(4000)
	Declare @SalesName nVarchar(4000)
	Declare @ReportType nVarchar(50)
	Declare @DateOrMonth as nVarchar(25)
	Declare @GGRRMonth as datetime
	Declare @UptoWeek nVarchar(50)
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
	Declare @Delimeter as nVarchar(1)
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
	Declare @ToTalSalesPercentage Decimal(18,6),@Target  as Decimal(18,6),@MaxPoints Decimal(18,6),@DayClosed Int
	Declare @WDCode NVarchar(255)  
	Declare @WDDest NVarchar(255)  
	Declare @CompaniesToUploadCode NVarchar(255)  
	Set @Delimeter = Char(15)

	Declare @tmpHHSM Table (Salesmanname nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

	Insert into @tmpHHSM
	Select S.salesman_Name From DSType_Details dd, DSType_Master dm,Salesman S 
	Where dd.DSTypeID = dm.DSTypeID And dm.DSTypeName = 'Handheld DS' And dm.DSTypeValue = 'Yes' 
	And DD.SalesmanID=S.SalesmanID
	And isnull(S.Active,0)=1
	And isnull(Dm.Active,0)=1

	Declare @Salesman Nvarchar(255) 
	Declare @F_Salesman Nvarchar(255)

    Declare Cur Cursor For
    Select SalesManName from @tmpHHSM
    Open Cur
    Fetch next from Cur Into @Salesman
    While @@Fetch_Status = 0
	Begin		
		If Isnull(@F_Salesman,'') <> ''
		Begin
			Set @F_Salesman = Isnull(@F_Salesman,'') + cast(@Delimeter as Nvarchar) + Isnull(@Salesman,'')
		End
		Else
		Begin
			Set @F_Salesman = Isnull(@Salesman,'')
		End
	Fetch next from Cur into @Salesman
	End
	Close Cur
    Deallocate Cur

	Set @F_Salesman = Isnull(@F_Salesman,'%')

	Set @CatGroup = '%'
	Set @DStype = '%'
	Set @SalesName = @F_Salesman
	Set @ReportType = 'Monthly'
	Set @DateOrMonth=Substring(DateName(mm, Getdate()), 1, 3) + '-' + DateName(YYYY, Getdate())	
	Set @UptoWeek = 'Week4'
	select @GGRRMonth = dbo.striptimefromdate(getdate())
	  
	Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload    
	Select Top 1 @WDCode = RegisteredOwner From Setup      
	    
	If @CompaniesToUploadCode='ITC001'    
	 Set @WDDest= @WDCode    
	Else    
	Begin    
	 Set @WDDest= @WDCode    
	 Set @WDCode= @CompaniesToUploadCode    
	End   
	
	Declare @GRNTOTAL nVarchar(50)    
	Declare @MAXPOINT_TOTAL nVarchar(50)    
	
--	Set @GRNTOTAL = dbo.LookupDictionaryItem(N'Total:', Default)    
--	Set @MAXPOINT_TOTAL = dbo.LookupDictionaryItem(N'Max Points Total:', Default)    
	Set @GRNTOTAL = 'Total:'
	Set @MAXPOINT_TOTAL = 'Max Points Total:'    


	Declare @tmpCatGroup Table (GroupName nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Declare @tmpDStype Table (DSType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Declare @tmpSalesman Table (Salesman nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)

	Declare @TempVal Table (
	ParamID Int,
	[WDCode] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[WDDest] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
	DSName nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[DS Type] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Performance Metrics Code] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Description nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Category Group] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[From Date] Datetime,
	[To Date] Datetime,
	Parameter nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Overall or Focus] nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Frequency nVarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Target Decimal(18,6),
	[Average Till Date] Decimal(18,6),
	[Till date Actual] Decimal(18,6),
	[Max Points] Decimal(18,6),
	[Till Date Points Earned] Decimal(18,6),
	[Todays Actual] Decimal(18,6),
	[Points Earned Today] Decimal(18,6),
	[Generation Date] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Last Transaction Date] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ParameterTypeID Int,
	FrequencyID Int)

	Declare @tmpPM Table (RowID Int Identity(1,1),PMID Int,SalesmanID Int,
	Salesman_Name nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,DSTypeID Int,
	DSTypeCode Int,DSType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	PMCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	PMDescription nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CGGroups nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ParameterType Int,Frequency Int,ParamID Int,Prod_Level Int,
	isFocusParam nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
	FocusID Int,DS_MaxPoints Decimal(18,6),Param_MaxPoints  Decimal(18,6),
	TillDateActual Decimal(18,6),NoOfDaysInvoiced Int,AverageTillDate Decimal(18,6),
	Target Decimal(18,6),MaxPoints Decimal(18,6),TillDatePointsEarned Decimal(18,6),
	ToDaysActual Decimal(18,6),PointsEarnedToday Decimal(18,6),GenerationDate Datetime,LastTranDate Datetime)

	Declare @tmpPM1 Table (RowID Int Identity(1,1),PMID Int,SalesmanID Int,
	Salesman_Name nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,DSTypeID Int,
	DSTypeCode Int,DSType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	PMCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	PMDescription nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CGGroups nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ParameterType Int,Frequency Int,ParamID Int,Prod_Level Int,
	isFocusParam nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
	FocusID Int,DS_MaxPoints Decimal(18,6),Param_MaxPoints  Decimal(18,6),
	TillDateActual Decimal(18,6),NoOfDaysInvoiced Int,AverageTillDate Decimal(18,6),
	Target Decimal(18,6),MaxPoints Decimal(18,6),TillDatePointsEarned Decimal(18,6),
	ToDaysActual Decimal(18,6),PointsEarnedToday Decimal(18,6),GenerationDate Datetime,LastTranDate Datetime)

	Declare @tmpInvoice Table (InvoiceID Int,InvoiceDate Datetime,
	SalesmanID nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Product_Code nVarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
	MarketSKU nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
	SubCategory nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Division nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Company nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CategoryGroup nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Amount Decimal(18,6) ,InvoiceType Int,InvoiceDateWithTime Datetime,DSTypeID Int,Quantity Decimal(18,6),UOM1Qty Decimal(18,6),UOM2Qty Decimal(18,6) )

	Declare @tmpOutput Table ([ID] Int Identity(1,1),ParamID Int,[WDCode] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[WDDest] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
	DSID Int,
	DSName nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[DS Type] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Performance Metrics Code] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Description nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Category Group] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[From Date] Datetime,[To Date] Datetime,Parameter nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Overall or Focus] nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,Frequency nVarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Target Decimal(18,6),[Average Till Date] Decimal(18,6),
	[Till date Actual] Decimal(18,6),[Max Points] Decimal(18,6),
	[Till Date Points Earned] Decimal(18,6),
	[Todays Actual] Decimal(18,6),[Points Earned Today] Decimal(18,6),
	[Generation Date] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Last Transaction Date] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)

	Declare @tmpOutputBA Table ([ID] Int Identity(1,1),[WDCode] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[WDDest] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
	DSID Int,
	DSName nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[DS Type] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Performance Metrics Code] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Description nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Category Group] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[From Date] Datetime,[To Date] Datetime,Parameter nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Overall or Focus] nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,Frequency nVarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Target Decimal(18,6),[Average Till Date] Decimal(18,6),
	[Till date Actual] Decimal(18,6),[Max Points] Decimal(18,6),
	[Till Date Points Earned] Decimal(18,6),
	[Todays Actual] Decimal(18,6),[Points Earned Today] Decimal(18,6),
	[Generation Date] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Last Transaction Date] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)	

	Declare @tmpInvDateWise Table (InvoiceDate Datetime,LinesOrBillsOrBA Decimal(18,6),InvoiceDateWithTime Datetime,
								SalesPercentage Decimal(18,6),SlabID Int,Slab_Every Int,Slab_Value Decimal(18,6),
								PointsEarned Decimal(18,6))
	
	Declare @tmpDistinctPMDS Table (RowID Int Identity(1,1),PMID Int,DSTypeID Int,SalesmanName nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Declare @TmpFocusItems  Table (Product Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, ProLevel Int,Min_Qty Decimal(18,6),UOM Int)
	Declare @tmpMinQtyInvItems Table (Division nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
			Sub_Category nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
			MarketSKU nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS, 
			Product_Code nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS)

	Declare @InvalidID int

	If @CatGroup = N'%' Or @CatGroup = N''
	Begin
		Insert Into @tmpCatGroup(GroupName) Values ('GR1,GR3')
		Insert Into @tmpCatGroup(GroupName) Values ('GR1')
		Insert Into @tmpCatGroup(GroupName) Values ('GR2')
		Insert Into @tmpCatGroup(GroupName) Values ('GR3')
	End

	If @DSType = N'' Or @DSType = N'%'
	Begin
		Insert into @tmpDStype
		Select Distinct DSTypeValue From DSType_Master Where DSTypeCtlPos = 1
	End


	If @SalesName = N'%' Or @SalesName = N''
	Begin
		Insert into @tmpSalesman
		Select Salesman_Name From Salesman
	End

	Select @TillDate = GetDate()
	Select @RptGenerationDate = @TillDate


	Declare @OCG int
	Select @OCG=isnull(Flag,0) From Tbl_merp_Configabstract Where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup'

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

		Set @DtMonth = cast(Cast('01' + '/' +  @Month as nVarchar(15)) as datetime)
		Set @FromDate = 	Convert(nVarchar(10), @DtMonth, 103)
		If @UptoWeek = N'Week 1' 
			Begin
					Set @ToDate =  (Select DATEADD(s,-1,(DateAdd(DD, 7,  @FromDate))))
			End
		Else If @UptoWeek =  N'Week 2' 
			Begin
					Set @ToDate =  (Select DATEADD(s,-1,(DateAdd(dd, 14,  @FromDate))))
			End
		Else If @UptoWeek =  N'Week 3' 
			Begin
					Set @ToDate =  (Select DATEADD(s,-1,(DateAdd(dd, 21,  @FromDate))))
			End
		Else If @UptoWeek =  N'Week 4' or @UptoWeek = N'' Or @UptoWeek = N'%' 
			Begin
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
--	If @OCG=0 
--	Begin
	
	/* Added by Soumya */
		Select @MonthFirstDate = dbo.StripTimeFromDate(@MonthFirstDate)
		Select @TillDate= dateadd(s,86399,dbo.StripTimeFromDate(@TillDate))
	/* End of Addition */


/* Removed by Soumya 
	Insert Into @tmpInvoice
	Select   IA.InvoiceID,IA.InvoiceDate,SM.SalesmanID,Ide.Product_Code,IC.Category_Name, IC1.Category_Name,
			 IC2.Category_Name,IC3.Category_Name,CGDiv.CategoryGroup,isNull(Ide.Amount,0),IA.InvoiceType,
			 IA.InvoiceDate,isNull(IA.DSTypeID,0),Isnull(Ide.Quantity,0),
			 Cast((Isnull(Ide.Quantity,0)/Isnull(I.Uom1_Conversion,1)) as Decimal(18,6)),
			 Cast((Isnull(Ide.Quantity,0)/Isnull(I.Uom2_Conversion,1)) as Decimal(18,6))
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
*/

/* Added by Soumya */

	Insert Into @tmpInvoice
	Select   IA.InvoiceID,IA.InvoiceDate,SM.SalesmanID,Ide.Product_Code,IC.Category_Name, IC1.Category_Name,
			 IC2.Category_Name,IC3.Category_Name,CGDiv.CategoryGroup,isNull(Ide.Amount,0),IA.InvoiceType,
			 IA.InvoiceDate,isNull(IA.DSTypeID,0),Isnull(Ide.Quantity,0),
			 Cast((Isnull(Ide.Quantity,0)/Isnull(I.Uom1_Conversion,1)) as Decimal(18,6)),
			 Cast((Isnull(Ide.Quantity,0)/Isnull(I.Uom2_Conversion,1)) as Decimal(18,6))
	From     
		InvoiceAbstract IA,InvoiceDetail Ide,Items I    
		,ItemCategories IC,ItemCategories IC1,
		ItemCategories IC2,ItemCategories IC3,
		tblcgdivmapping CGDiv,Salesman SM
	Where     
		( IsNull(IA.Status,0) & 128 = 0)
		And IA.InvoiceDate Between @MonthFirstDate And @TillDate 
		And IA.InvoiceType in(1,3,4)
		And IA.InvoiceID = Ide.InvoiceID
		And Ide.Product_Code = I.Product_Code
		And I.CategoryID = IC.CategoryID
		And IC.ParentID = IC1.CategoryID
		And IC1.ParentID = IC2.CategoryID
		And IC2.ParentID = IC3.CategoryID
		And IC2.Category_Name = CGDiv.Division
		And IA.SalesmanID = SM.SalesmanID

/* End of Addition*/


	
	if @OCG=1
	update @tmpInvoice set CategoryGroup = CGDiv.CategoryGroup From @tmpInvoice I, tblCGDivMapping CGDiv where I.Division = CGDiv.Division

	-- Removed by Soumya -- Update @tmpInvoice Set Invoicedate = dbo.StripTimeFromDate(Invoicedate)


	Declare @DSPMSalesman table (SalesManid Int ,Salesman_Name Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,PMID Int,DSTypeValue Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CurrentdsType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,TargetStatus int, SalesStatus Int)
	Insert into @DSPMSalesman (SalesManid,Salesman_Name,PMID,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
	select Distinct PMM.SAlesmanid,SAlesman_name,PMM.PMID,DST.DSType,Null,0,0 from tbl_merp_PMetric_TargetDefn PMM, tbl_mERP_PMDSType DST,Salesman S
	where PMM.PMID in (select PMID from tbl_mERP_PMMaster Where Period =@Period )
	And PMM.Active = 1 and PMM.PMDSTypeid = DST.DSTypeid
	And PMM.Salesmanid = S.Salesmanid  

	If @OCG=1
	BEGIN
		Insert into @DSPMSalesman (SalesManid,Salesman_Name,PMID,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
		select Distinct S.SalesManid,S.Salesman_Name,T.PMID,DT.DSTypeValue,Null,0,0 --into @DSPMSalesman 
		from DSType_Details D,DSType_Master DT, Salesman S, tbl_mERP_PMDSType PMDS, tbl_merp_PMetric_TargetDefn TDF,
		(select PMID from tbl_mERP_PMMaster Where Period =@Period ) T Where
			 T.PMID = PMDS.PMID 
		And  PMDS.DsType = DT.DSTypeValue 
		And DT.DSTYPEID = D.DSTYPEID
		And S.SalesManid = D.SalesManid  and DT.DSTypectlpos =1
		And TDF.PMID = T.PMID
		And TDF.Target > 0
		ANd TDF.Active = 1
		--AND isnull(DT.Active,0)=1
		--AND isnull(DT.OCGType,0)=1
	END
	ELSE
	BEGIN	
		Insert into @DSPMSalesman (SalesManid,Salesman_Name,PMID,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
		select Distinct S.SalesManid,S.Salesman_Name,T.PMID,DT.DSTypeValue,Null,0,0 --into @DSPMSalesman 
		from DSType_Details D,DSType_Master DT, Salesman S, tbl_mERP_PMDSType PMDS, tbl_merp_PMetric_TargetDefn TDF,
		(select PMID from tbl_mERP_PMMaster Where Period =@Period ) T Where
			 T.PMID = PMDS.PMID 
		And  PMDS.DsType = DT.DSTypeValue 
		And DT.DSTYPEID = D.DSTYPEID
		And S.SalesManid = D.SalesManid  and DT.DSTypectlpos =1
		And TDF.PMID = T.PMID
		And TDF.Target > 0
		ANd TDF.Active = 1
	END
	
	If @OCG=1
	BEGIN
		Insert into @DSPMSalesman (SalesManid,Salesman_Name,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus) 
		Select Distinct I.SalesManid,S.Salesman_Name,DT.DSTypeValue,Null,0,0 from @tmpInvoice I, DSType_Master DT, Salesman S
		Where I.SalesManid not in (select Distinct SalesManid from @DSPMSalesman) And Amount > 0
		And DT.DSTYPEID = I.DSTYPEID
		And I.SalesManid = S.SalesManid
		and DT.DSTypectlpos =1
	END
	ELSE
	Begin
		Insert into @DSPMSalesman (SalesManid,Salesman_Name,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus) 
		Select Distinct I.SalesManid,S.Salesman_Name,DT.DSTypeValue,Null,0,0 from @tmpInvoice I, DSType_Master DT, Salesman S
		Where I.SalesManid not in (select Distinct SalesManid from @DSPMSalesman) And Amount > 0
		And DT.DSTYPEID = I.DSTYPEID
		And I.SalesManid = S.SalesManid
		and DT.DSTypectlpos =1
	END

	/* For OCG*/
	If @OCG=0
	Begin
		Update T1 set T1.CurrentdsType = T.CNT From @DSPMSalesman T1, (select Distinct Salesmanid, DSTypeValue CNT From DSType_Master TM,DSType_Details DD Where DD.DSTypeID = TM.DSTypeid And DD.DSTypectlpos =1 ) T
		Where T1.Salesmanid = T.Salesmanid  
	End
	Else
	Begin
		Update T1 set T1.CurrentdsType = T.CNT From @DSPMSalesman T1, (select Distinct Salesmanid, DSTypeValue CNT From DSType_Master TM,DSType_Details DD Where DD.DSTypeID = TM.DSTypeid And DD.DSTypectlpos =1 ) T
		Where T1.Salesmanid = T.Salesmanid  		
	End	

	update @DSPMSalesman set TargetStatus = 1 where Salesmanid in (select Distinct Salesmanid from tbl_merp_PMetric_TargetDefn where Target > 0 and Active = 1 
	and PMId in (select Distinct PMID from tbl_mERP_PMMaster Where Period =@Period))
	update @DSPMSalesman set SalesStatus = 1 where Salesmanid in (select Distinct Salesmanid from @tmpInvoice Where Salesmanid not in (select Salesmanid from @DSPMSalesman Where TargetStatus = 1))
	Update @DSPMSalesman set DSTypeValue = CurrentdsType
	Update @DSPMSalesman set SalesStatus = 1 Where DSTypeValue = CurrentdsType and TargetStatus = 1

	IF @OCG=0
	Begin
		/* Filter the PM based on the report parameter selected */
		Insert Into @tmpPM(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
		ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,--FocusID,
		DS_MaxPoints,Param_MaxPoints)
		Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
		Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
		Param.ParamID,ProdCat_Level,Case When (ParamFocus.PMProductName) = 'ALL' then 'OverAll' else (ParamFocus.PMProductName) end 'isFocusParam',
		isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
		From 
			tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,@tmpDSType DS,
			Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
			,tbl_mERP_PMParamFocus ParamFocus
			,(Select Distinct SalesmanID,DSTypeID From @tmpInvoice) DSDet
		Where 
			Master.Period = @Period 
			And Master.Active = 1
			And Master.PMID = DSType.PMID
			And DStype.DSType = DS.DStype 
			And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From @tmpCatGroup)
			And DSMast.DSTypeValue = DStype.DSType
			And DSMast.DSTypeCtlPos = 1
			And DSDet.DSTypeID = DSMast.DSTypeID
			And SM.SalesmanID = DSDet.SalesmanID
			And SM.Salesman_Name In(Select Salesman From @tmpSalesman) 
			And Param.DSTypeID = DSType.DSTypeID
			And Param.ParamID  = ParamFocus.ParamID
	End
	ELSE
	BEGIN
		/* Filter the PM based on the report parameter selected */
		Insert Into @tmpPM(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
		ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
		DS_MaxPoints,Param_MaxPoints)
		Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
		Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
		Param.ParamID,ProdCat_Level,Case When (ParamFocus.PMProductName) = 'ALL' then 'OverAll' else (ParamFocus.PMProductName) end 'isFocusParam',
		isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
		From 
			tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,@tmpDSType DS,
			Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
			,tbl_mERP_PMParamFocus ParamFocus
			,(Select Distinct SalesmanID,DSTypeID From @tmpInvoice) DSDet
		Where 
			Master.Period = @Period 
			And Master.Active = 1
			And Master.PMID = DSType.PMID
			And DStype.DSType = DS.DStype 
			And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From @tmpCatGroup)
			And DSMast.DSTypeValue = DStype.DSType
			And DSMast.DSTypeCtlPos = 1
			And DSDet.DSTypeID = DSMast.DSTypeID
			And SM.SalesmanID = DSDet.SalesmanID
			And SM.Salesman_Name In(Select Salesman From @tmpSalesman) 
			And Param.DSTypeID = DSType.DSTypeID
			And Param.ParamID  = ParamFocus.ParamID
	END
	/*If there is no sales for a salesman, then if that salesman alone is selected then, report is generating blank
	but if all salesman is selected then that salesman is coming with blank row. So we addressed that issue by creating empty row when that 
	particular salesman is selected*/
	If @OCG=0
	Begin
		Insert Into @tmpPM(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
		ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
		DS_MaxPoints,Param_MaxPoints)
		Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
		Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
		Param.ParamID,ProdCat_Level,(ParamFocus.PMProductName) 'isFocusParam',
		isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
		From 
			tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,@tmpDSType DS,
			Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param,tbl_merp_PMetric_TargetDefn PMTar,
			tbl_mERP_PMParamFocus ParamFocus
			,(select Distinct PMID,Salesmanid,DSTypeValue from @DSPMSalesman) TMPDS
		Where 
			Master.Period = @Period 
			And Master.Active = 1
			And Master.PMID = DSType.PMID
			And DStype.DSType = DS.DStype 
			And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From @tmpCatGroup)
			And DSMast.DSTypeValue = DStype.DSType
			And DSMast.DSTypeCtlPos = 1
			And SM.SalesmanID = PMTar.SalesmanID		
			And Param.DSTypeID = DSType.DSTypeID
			And Param.ParamID  = ParamFocus.ParamID
			And PMTar.Target > 0
			And PMTar.PMID = Master.PMID
			And TMPDS.Salesmanid = PMTar.Salesmanid
			And TMPDS.DSTypeValue = DSMast.DSTypeValue
			and TMPDS.Salesmanid not in (select distinct salesmanid from @tmpPm)
	END
	ELSE
	BEGIN
		Insert Into @tmpPM(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
		ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
		DS_MaxPoints,Param_MaxPoints)
		Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
		Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
		Param.ParamID,ProdCat_Level,(ParamFocus.PMProductName) 'isFocusParam',
		isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
		From 
			tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,@tmpDSType DS,
			Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param,tbl_merp_PMetric_TargetDefn PMTar,
			tbl_mERP_PMParamFocus ParamFocus
			,(select Distinct PMID,Salesmanid,DSTypeValue from @DSPMSalesman) TMPDS
		Where 
			Master.Period = @Period 
			And Master.Active = 1
			And Master.PMID = DSType.PMID
			And DStype.DSType = DS.DStype 
			And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From @tmpCatGroup)
			And DSMast.DSTypeValue = DStype.DSType
			And DSMast.DSTypeCtlPos = 1
			And SM.SalesmanID = PMTar.SalesmanID		
			And Param.DSTypeID = DSType.DSTypeID
			And Param.ParamID  = ParamFocus.ParamID
			And PMTar.Target > 0
			And PMTar.PMID = Master.PMID
			And TMPDS.Salesmanid = PMTar.Salesmanid
			And TMPDS.DSTypeValue = DSMast.DSTypeValue
			and TMPDS.Salesmanid not in (select distinct salesmanid from @tmpPm)
	END
	If @OCG=0
	Begin
		Insert Into @tmpPM1(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
		ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
		DS_MaxPoints,Param_MaxPoints)
		Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
		Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
		Param.ParamID,ProdCat_Level,(ParamFocus.PMProductName) 'isFocusParam',
		isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints' 
		From 
			tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,@tmpDSType DS,
			Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
			,tbl_mERP_PMParamFocus ParamFocus
			,(Select Distinct SalesmanID,DSTypeID From @tmpInvoice) DSDet
			,(select Distinct PMID,Salesmanid,Salesman_Name,DSTypeValue from @DSPMSalesman Where SalesStatus = 1) TMPDS
		Where 
			Master.Period = @Period 
			And Master.Active = 1
			And Master.PMID = DSType.PMID
			And DStype.DSType = DS.DStype 
			And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From @tmpCatGroup)
			And DSMast.DSTypeValue = DStype.DSType
			And DSMast.DSTypeCtlPos = 1
			And SM.Salesman_Name  = TMPDS.Salesman_Name
			And Param.DSTypeID = DSType.DSTypeID
			And Param.ParamID  = ParamFocus.ParamID
			And TMPDS.DSTypeValue = DSMast.DSTypeValue
			And SM.Salesmanid in ( select Distinct Salesmanid from @DSPMSalesman)
	END
	ELSE
	BEGIN
		Insert Into @tmpPM1(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
		ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
		DS_MaxPoints,Param_MaxPoints)
		Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
		Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
		Param.ParamID,ProdCat_Level,(ParamFocus.PMProductName) 'isFocusParam',
		isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints' 
		From 
			tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,@tmpDSType DS,
			Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
			,tbl_mERP_PMParamFocus ParamFocus
			,(Select Distinct SalesmanID,DSTypeID From @tmpInvoice) DSDet
			,(select Distinct PMID,Salesmanid,Salesman_Name,DSTypeValue from @DSPMSalesman Where SalesStatus = 1) TMPDS
		Where 
			Master.Period = @Period 
			And Master.Active = 1
			And Master.PMID = DSType.PMID
			And DStype.DSType = DS.DStype 
			And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From @tmpCatGroup)
			And DSMast.DSTypeValue = DStype.DSType
			And DSMast.DSTypeCtlPos = 1
			And SM.Salesman_Name  = TMPDS.Salesman_Name
			And Param.DSTypeID = DSType.DSTypeID
			And Param.ParamID  = ParamFocus.ParamID
			And TMPDS.DSTypeValue = DSMast.DSTypeValue
			And SM.Salesmanid in ( select Distinct Salesmanid from @DSPMSalesman)
	END

	Declare @tmpPMID int, @tmpDSID int, @DSTYPEValue Nvarchar(255)
    Declare Cur_PM1 Cursor For
    Select PMID,SalesManID,DSType from @tmpPM1
    Open Cur_PM1
    Fetch next from Cur_PM1 Into @tmpPMID,@tmpDSID,@DSTYPEValue 
    While @@Fetch_Status = 0
	Begin		
			If not exists (select * from @tmpPM where PMID=@tmpPMID and Salesmanid = @tmpDSID And DSType = @DSTYPEValue)
				Begin
				insert into @tmpPM(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,FocusID,DS_MaxPoints,Param_MaxPoints) 
				select Distinct PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,FocusID,DS_MaxPoints,Param_MaxPoints from @tmpPM1 where PMID=@tmpPMID and Salesmanid = @tmpDSID And DSTYPE = @DSTYPEValue
				end
			Fetch next from Cur_PM1 into @tmpPMID,@tmpDSID ,@DSTYPEValue
	End
	Close Cur_PM1
    Deallocate Cur_PM1


    /*To Insert DSType and Param info from PMetric_TargetDefn table for Salesman having Target with nil Invoices*/
    Declare @tDSTgtZeroInv Table (TGT_PMID Int, TGT_DSTYPEID Int, TGT_PARAMID Int, TGT_SMID int, TGT_TARGETVAL Decimal(18,6), TGT_MAXPOINT Decimal(18,6), 
                                 TGT_FREQUENCY Int, TGT_ISFOCUSPARAM nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS, TGT_PARAMMAX Decimal(18,6), TGT_PARAMTYPE Int)
    Declare @TGTPMID Int, @TGTDSTYPEID Int, @TGTPARAMID Int
    Declare Cur_TgtPMLst Cursor For
    Select Distinct PMID, PMDSTYPEID, PARAMID from tbl_merp_PMetric_TargetDefn where Active = 1 And PMID in (Select Distinct PMID from @tmpPM) 
    Open Cur_TgtPMLst 
    Fetch next from Cur_TgtPMLst into @TGTPMID, @TGTDSTYPEID, @TGTPARAMID 
    While @@Fetch_Status = 0
    Begin
      Insert into @tDSTgtZeroInv(TGT_PMID, TGT_DSTYPEID, TGT_PARAMID, TGT_SMID, TGT_TARGETVAL, TGT_MAXPOINT, TGT_FREQUENCY, TGT_ISFOCUSPARAM, TGT_PARAMTYPE, TGT_PARAMMAX) 
      Select Tdf.PMID, Tdf.PMDSTYPEID, Tdf.PARAMID, Tdf.SALESMANID, Tdf.TARGET, Tdf.MAXPOINTS, PMP.FREQUENCY,
     (PMFocus.PMProductName),PMP.ParameterType, PMP.MaxPoints 
      From tbl_merp_PMetric_TargetDefn Tdf, tbl_mERP_PMParam PMP, tbl_mERP_PMParamFocus PMFocus 
      Where Tdf.ACTIVE= 1 And Tdf.PMID = @TGTPMID And Tdf.PMDSTYPEID = @TGTDSTYPEID And Tdf.PARAMID = @TGTPARAMID 
        And Tdf.SALESMANID not in (Select Distinct SalesmanID from @tmpPM Where PMID = @TGTPMID And DSTypeID = @TGTDSTYPEID And PARAMID = @TGTPARAMID And isNull(AverageTillDate,0) <> 0)
        And PMP.ParamID = Tdf.ParamID
        And PMP.ParamID = PMFocus.ParamID 
		and Tdf.SALESMANID in (select salesmanid from salesman where salesman_name in(select Salesman from @tmpSalesman))
      Fetch next from Cur_TgtPMLst into @TGTPMID, @TGTDSTYPEID, @TGTPARAMID
    End
    Close Cur_TgtPMLst 
    Deallocate Cur_TgtPMLst
   
	Update @tmpPM Set GenerationDate = @RptGenerationDate,LastTranDate = @LastInvoiceDate

	Insert Into @tmpDistinctPMDS(PMID,DSTypeID,SalesmanName)
	Select Distinct PMID,DSTypeID,Salesman_Name From @tmpPM
    Union 

    Select Distinct TGT_PMID,TGT_DSTYPEID, SM.Salesman_Name From @tDSTgtZeroInv tDST, Salesman SM,
	tbl_mERP_PMDSType PMDST
    Where SM.SalesManID = tDST.TGT_SMID  
	AND PMDST.PMID = tDST.TGT_PMID
	AND PMDST.DSTypeID=tDST.TGT_DSTYPEID
	AND PMDST.DSType in (Select DStype from @tmpDStype)
	

	Update @tmpPM Set GenerationDate = @RptGenerationDate

	/* To Add Subtotal and GrandTotal Row Begins */
	Select @PMMaxCount = 0
    Declare Cur_Counter2 Cursor For
    Select Rowid from @tmpDistinctPMDS order by PMID,SalesmanName
    Open Cur_Counter2
    Fetch next from Cur_Counter2 Into @Counter 
    While @@Fetch_Status = 0
	Begin
		
		Select @PMID = 0,@PMDSTypeID = 0,@MaxPoints=0,@TillDatePointsEarned=0,@ToDaysPointsEarned=0,@SalesmanName=''
		Select @PMID = PMID ,@PMDSTypeID = DSTypeID,@SalesmanName=SalesmanName From @tmpDistinctPMDS Where RowID = @Counter
		
		Select @MaxPoints = Cast(Max(DS_Maxpoints) as Decimal(18,6)) ,@TillDatePointsEarned = Sum(isNull(TillDatePointsEarned,0)) ,
		@ToDaysPointsEarned = Sum(isNull(PointsEarnedToday,0))
		From @tmpPM Where PMID = @PMID And DSTypeID = @PMDSTypeID And Salesman_Name = @SalesmanName
		   
		Insert Into @TempVal   
		Select Distinct ParamID,@WDCode as 'WDCode' ,@WDDest as 'WDDest',Salesman_Name as 'DSName',DSType  as 'DS Type',PMCode as 'Performance Metrics Code',PMDescription as 'Description',Replace(CGGroups,',','|') [Category Group],@FromDate [From Date],Convert(nVarchar(10), @ToDate, 103) [To Date],
		  (Case ParameterType When 1 Then N'Lines Cut' When 2 Then N'Bills Cut' When 3 Then N'Business Achievement' When 4 then 'Go Green OBJ' When 5 Then 'Reduce Red OBJ' End) 'Parameter',
		  isFocusParam 'Overall or Focus',(Case Frequency When 1 Then N'Daily' When 2 Then N'Monthly' End) 'Frequency',
		  (Case ParameterType When 3 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then Cast(isNull(Target,0)/25. as decimal(18,6)) Else Cast(isNull(Target,0) as Decimal(18,6)) End) Else NULL End) Target,
		  AverageTillDate [Average Till Date],TillDateActual [Till date Actual],(Case ParameterType When 3 Then Cast(isNull(MaxPoints,0) as Decimal(18,6)) Else NULL End) [Max Points],
		  (Case ParameterType When 3 Then
							(Case @DayClosed When 0 Then NULL When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then NULL Else Cast(isNull(TillDatePointsEarned,0) as decimal(18,6)) End) End)
							Else Cast(isNull(TillDatePointsEarned,0) as Decimal(18,6)) End)[Till Date Points Earned],
	      ToDaysActual [Todays Actual],
		  (Case ParameterType When 3 Then
							(Case @DayClosed When 0 Then NULL When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then NULL Else Cast(isNull(PointsEarnedToday,0) as Decimal(18,6)) End) End)
							Else (Case When (Frequency = 2 And @ReportType = 'Daily') Then NULL Else Cast(isNull(PointsEarnedToday,0) as Decimal(18,6)) End) End) [Points Earned Today],
		  GenerationDate [Generation Date],
		  LastTrandate [Last Transaction Date],
--		  Convert(nVarchar(10),GenerationDate,103) + N' ' + Convert(nVarchar(8),GenerationDate,108) [Generation Date],
--		  Convert(nVarchar(10),LastTrandate,103) + N' ' + Convert(nVarchar(8),LastTrandate,108) [Last Transaction Date],
		  (Case ParameterType When 1 Then 2 When 2 Then 1 When 3 Then 3 When 4 Then 4 When 5 Then 5 End) 'ParameterTypeID',Frequency 'FrequencyID'
		
		From @tmpPM ,tbl_mERP_PMParamType ParamType
		Where PMID = @PMID And DSTypeID = @PMDSTypeID And Salesman_Name = @SalesmanName
		  And ParamType.ID = ParameterType

        Insert Into @tmpOutput(ParamID,[WDCode],[WDDest],DSName,[DS Type],[Performance Metrics Code],Description,[Category Group],
          [From Date],[To Date],Parameter,[Overall or Focus],Frequency,Target,[Average Till Date],[Till date Actual],
		  [Max Points],[Till Date Points Earned],[Todays Actual],[Points Earned Today],[Generation Date],
		  [Last Transaction Date]) 
		Select ParamID,[WDCode],[WDDest],DSName,[DS Type],[Performance Metrics Code],Description,[Category Group],
          [From Date],[To Date],Parameter,[Overall or Focus],Frequency,Target,[Average Till Date],[Till date Actual],
		  [Max Points],[Till Date Points Earned],[Todays Actual],[Points Earned Today],[Generation Date],
		  [Last Transaction Date]
		From @TempVal Order by [Performance Metrics Code],[DS Type],DSName,ParameterTypeID,FrequencyID Asc

		Delete From @TempVal

    Fetch next from Cur_Counter2 Into @Counter 
	End
    Close Cur_Counter2 
    Deallocate Cur_Counter2

	Update T1  Set T1.DSID = T2.Cnt  from @tmpOutput T1,(Select SalesMan_Name, SalesManId as Cnt  from Salesman) T2 Where T1.DSName = T2.SalesMan_Name
	Update 	@tmpOutput set Target = 0 Where isnull(Target,0) = 0 and Parameter = 'Business Achievement'

/* GGDR Process Start :*/
	If @ReportType = 'Monthly'
	Begin
		Declare @TmpGGDRDSData Table(
				DSID Int,
				DSName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
				DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
				CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

		Declare @TmpGGDRAbstract Table(
			[DS ID] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[CustomerID] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			ProdDenfID Int,
			CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,
			[Status] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[Current Status] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

		Declare @RedOBJData as Table (DSID Int,
				CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
				CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

		Declare @GreenOBJData as Table (DSID Int,
				CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
				CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

		Declare @TmpGGDRDSPointsData Table(
				Paramid Int,
				DSID Int,
				DSName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
				DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
				Parameter Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
				TillDateActual Decimal(18,6),
				SlabFrom Decimal(18,6),
				SlabTo Decimal(18,6),
				ForEvery Decimal(18,6),
				PointValue Decimal(18,6))

		Delete From @TmpGGDRAbstract
		Insert Into @TmpGGDRAbstract 
		Select * from dbo.mERP_FN_TargetsforGGDR_View()

		Delete From @TmpGGDRAbstract Where [Status] = [Current Status]

		Insert Into @RedOBJData
		Select Distinct [DS ID],CategoryGroup,[CustomerID] From @TmpGGDRAbstract Where [Status] = 'Red'

		Insert Into @GreenOBJData
		Select Distinct [DS ID],CategoryGroup,[CustomerID] From @TmpGGDRAbstract Where [Status] = 'Eligible for Green'

		Update Red set Red.CategoryGroup = (Case When Isnull(@OCG,0) = 1 Then Left(Red.CategoryGroup,3) Else Red.CategoryGroup End) from @RedOBJData Red
		Update Red set Red.CategoryGroup = Case When Red.CategoryGroup = 'GR3' Then 'GR1' Else Red.CategoryGroup End from @RedOBJData Red

		Update T Set T.[Till date Actual] = T1.Cnt 
		From @tmpOutput T, (select Distinct DSID,CategoryGroup,Count(Distinct CustomerID) Cnt from @RedOBJData Group By DSID,CategoryGroup) T1
		Where T.DSID = T1.DSID
		And Replace(T.[Category Group],'|',',')  like  '%' +  T1.CategoryGroup + '%' 
		And T.Parameter = 'Reduce Red OBJ'

		Update Green set Green.CategoryGroup = Case When Isnull(@OCG,0) = 1 Then Left(Green.CategoryGroup,3) Else Green.CategoryGroup End from @GreenOBJData Green
		update Green set Green.CategoryGroup = Case When Green.CategoryGroup = 'GR3' Then 'GR1' Else Green.CategoryGroup End from @GreenOBJData Green

		Update T Set T.[Till date Actual] = T1.Cnt 
		From @tmpOutput T, (select Distinct DSID,CategoryGroup,Count(Distinct CustomerID) Cnt from @GreenOBJData Group By DSID,CategoryGroup) T1
		Where T.DSID = T1.DSID
		And Replace(T.[Category Group],'|',',')  like  '%' +  T1.CategoryGroup + '%' 
		And T.Parameter = 'Go Green OBJ'

	/* Points Calculation Start: */
--		If (Select dbo.StripTimeFromDate(LastInventoryUpload) From Setup) >= dbo.StripTimeFromDate(DateAdd(d,-1,DateAdd(m,1,Cast(('01/' + cast(@DateOrMonth as nvarchar)) as dateTime))))
		Begin
			Insert Into @TmpGGDRDSPointsData (ParamID,DSID,DSname,DSType,Parameter,TilldateActual)
			Select ParamID,DSID,DSname,[DS Type],Parameter,[Till date Actual] From @tmpOutput Where Parameter In ('Go Green OBJ','Reduce Red OBJ') And Isnull([Till date Actual] ,0) > 0

			Declare @GGDRParamID as Int
			Declare @GGDRTilldateActual as Decimal(18,6)

			Declare Cur_GGDRPoints Cursor for
			Select ParamID,TilldateActual From @TmpGGDRDSPointsData
			Open Cur_GGDRPoints
			Fetch from Cur_GGDRPoints into @GGDRParamID,@GGDRTilldateActual
			While @@fetch_status =0
				Begin
					Update T Set T.SlabFrom = T1.Slab_Start,
								 T.SlabTo = T1.Slab_End,
								 T.ForEvery = T1.Slab_Every_Qty,
								 T.PointValue = T1.Slab_Value From @TmpGGDRDSPointsData T,
					(select ParamID,Slab_Start,Slab_End,Slab_Every_Qty,Slab_Value From tbl_mERP_PMParamSlab Where ParamID = @GGDRParamID and @GGDRTilldateActual Between Slab_Start and Slab_End) T1
					Where T.paramID = T1.ParamID

					Fetch Next from Cur_GGDRPoints into @GGDRParamID,@GGDRTilldateActual
				End
			Close Cur_GGDRPoints
			Deallocate Cur_GGDRPoints

			Update T Set T.[Till Date Points Earned] = T1.NetPoints from @tmpOutput T,
			(select ParamID,DSID,DSname,DSType,Parameter,TilldateActual,
			((Cast(TilldateActual/ 
				(Case 
					When isnull(ForEvery,0) = 0 Then 1 
					Else isnull(ForEvery,0) 
					End) as Int)) * PointValue 
				) NetPoints
			From @TmpGGDRDSPointsData) T1
			Where T.ParamID = T1.ParamID
			And T.DSID = T1.DSID
			And T.DSName = T1.DSName
			And T.[DS Type] = T1.DSType
			And T.Parameter = T1.Parameter
			And T.[Till date Actual] = T1.TilldateActual
		End
	/* Points Calculation End. */
	
		Declare @OCGFlag as int
		Declare @TmpGGDRCust as Table (DSID Int,DSType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
				CustomerID nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
				CategoryGroup nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
				status nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS
				, CatGrp_Green nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
		set @OCGFlag = (Select Top 1 isnull(Flag,0) from tbl_merp_Configabstract Where ScreenCode = 'OCGDS')

		Insert Into @TmpGGDRCust
		Select Distinct T.DSID,T.[DS Type],B.CustomerId,G.PMCatGroup ,G.OutletStatus
		, Case When Isnull(@OCGFlag,0) = 0 Then CatGrouP Else OCG End
		From Beat_salesman B,@tmpOutput T,GGDROutlet G
		Where B.SalesmanId = T.DSID And T.Parameter In ('Go Green OBJ','Reduce Red OBJ')
		And isnull(B.CustomerId,'') <> ''
		And B.CustomerId = G.OutletID
		And Isnull(G.Active,0) = 1
		And @GGRRMonth Between G.ReportFromdate and G.ReportTodate
		--And cast(('01-' + @DateOrMonth) as DateTime) Between cast(('01-' + G.Fromdate) as DateTime) and cast(('01-' + G.Todate) as DateTime)

		Declare @GreenTarget as Table(DSID Int,	DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
				CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Cnt int,
				CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
				PMCatGrp Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

		Declare @FinalTarget as Table(DSID Int,	DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
				CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Cnt int,
				CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
				PMCatGrp Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
		
		Insert into @GreenTarget(DSID, DSType, CustomerID, CategoryGroup, PMCatGrp)
		Select DSID,DSType, CustomerId, CatGrp_Green, CategoryGroup From @TmpGGDRCust
				Where Status = 'EG'
				Group By DSID,DSType,CustomerId, CatGrp_Green, CategoryGroup

		Declare @tmpDSCG as Table(DSID Int, CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)		
		
		Insert into @tmpDSCG(DSID, CategoryGroup)
		Select SalesmanID,GroupName from dbo.fn_CG_View_PM()

		Insert into @FinalTarget(DSID, DSType, CustomerID, CategoryGroup, PMCatGrp)
		Select a.DSID, a.DSType, a.CustomerID, a.CategoryGroup, a.PMCatGrp From @GreenTarget a, @tmpDSCG b
		Where a.DSID = b.DSID and a.CategoryGroup = b.CategoryGroup

		Declare @Tar_DSID as Int
		Declare @Tar_DSType as Nvarchar(255)
		Declare @Tar_CatGroup as Nvarchar(255)

		Declare Cur_GGDRtarget Cursor for
		Select DSId,[DS Type],[Category Group] From @tmpOutput Where Parameter In ('Go Green OBJ','Reduce Red OBJ')
		Open Cur_GGDRtarget
		Fetch from Cur_GGDRtarget into @Tar_DSID,@Tar_DSType,@Tar_CatGroup
		While @@fetch_status =0
			Begin

				Update T Set T.Target = T1.Cnt From @tmpOutput T, 
				(Select DSID,DSType,Count(Distinct CustomerId) Cnt From @TmpGGDRCust
				Where Status = 'R' and DSId = @Tar_DSID And DStype = @Tar_DSType And CategoryGroup = @Tar_CatGroup
				Group By DSID,DSType)T1
				Where T.DSID = T1.DSID
				And T.[DS Type] = T1.DSType
				And T.DSID = @Tar_DSID
				And T.[DS Type] = @Tar_DSType
				And T.[Category Group] = @Tar_CatGroup
				And T.Parameter In ('Reduce Red OBJ')

--				Update T Set T.Target = T1.Cnt From @tmpOutput T, 
--				(Select DSID,DSType,Count(Distinct CustomerId) Cnt From @TmpGGDRCust
--				Where Status = 'EG' and DSId = @Tar_DSID And DStype = @Tar_DSType And CategoryGroup = @Tar_CatGroup
--				Group By DSID,DSType)T1
--				Where T.DSID = T1.DSID
--				And T.[DS Type] = T1.DSType
--				And T.DSID = @Tar_DSID
--				And T.[DS Type] = @Tar_DSType
--				And T.[Category Group] = @Tar_CatGroup
--				And T.Parameter In ('Go Green OBJ')


				Update T Set T.Target = T1.Cnt From @tmpOutput T, 
				(Select DSID,DSType,Count(Distinct CustomerId) Cnt From @FinalTarget
				Where DSId = @Tar_DSID And DStype = @Tar_DSType And PMCatGrp = @Tar_CatGroup
				Group By DSID,DSType)T1
				Where T.DSID = T1.DSID
				And T.[DS Type] = T1.DSType
				And T.DSID = @Tar_DSID
				And T.[DS Type] = @Tar_DSType
				And T.[Category Group] = @Tar_CatGroup
				And T.Parameter In ('Go Green OBJ')

				Fetch Next from Cur_GGDRtarget into @Tar_DSID,@Tar_DSType,@Tar_CatGroup
			End
		Close Cur_GGDRtarget
		Deallocate Cur_GGDRtarget
	
		Delete From @TmpGGDRDSData
		Delete From @TmpGGDRAbstract
		Delete From @TmpGGDRDSPointsData
		Delete From @GreenTarget
		Delete From @tmpDSCG
		Delete From @FinalTarget		
	End	
/* GGDR Process End.*/

	Delete From @tmpOutput Where Isnull([Performance Metrics Code],'') = ''
	Delete From @tmpOutput Where Parameter Not In ('Go Green OBJ','Reduce Red OBJ')

	Insert Into @Output
	Select Distinct DSID,Sum(Isnull([Till date Actual],0)),Sum(Isnull([Till Date Points Earned],0)),
	(Case When Parameter = 'Go Green OBJ' Then 'Green' When Parameter = 'Reduce Red OBJ' Then 'Red' End )
	From @tmpOutput T,(select Distinct S.SalesmanID from dstype_details DD,dstype_master DM,Salesman S where DD.dstypectlpos = 2 
	And DM.DSTypeValue = 'Yes'
	And DM.Active = 1
	And DM.DStypeID = DD.DStypeID 
	And S.Active = 1
	And S.SalesmanID = DD.SalesmanID) S
	Where T.DSID = S.SalesmanID
	Group By DSID,Parameter

	Return
END
