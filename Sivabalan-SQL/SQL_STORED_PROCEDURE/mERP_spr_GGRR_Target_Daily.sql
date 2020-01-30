Create Procedure mERP_spr_GGRR_Target_Daily(@GGDRMonth datetime)
As
Begin
	Set DateFormat DMY
	declare @monthYear varchar(10)
	set @monthYear = CAST(DATENAME(Month,@GGDRMonth) as nvarchar(3)) + '-' + Right(Year(@GGDRMonth),4)
	
	
	Declare @OCGFlag as Int
	Declare @Delimeter as nVarchar	

	Set @OCGFlag = (Select Top 1 isnull(Flag,0) from tbl_merp_Configabstract Where ScreenCode = 'OCGDS')	
	Set @Delimeter = Char(15)

	Declare @WDCode NVarchar(255)  
	Declare @WDDest NVarchar(255)  
	Declare @CompaniesToUploadCode NVarchar(255) 

	Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload    
	Select Top 1 @WDCode = RegisteredOwner From Setup      
		    
	If @CompaniesToUploadCode='ITC001'    
		Set @WDDest= @WDCode    
	Else    
	Begin    
		Set @WDDest= @WDCode    
		Set @WDCode= @CompaniesToUploadCode    
	End 

	Create Table #TmpCustomer (CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, SalesmanID Int,
				Beat Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
	Create Table #T_Customer (CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,SalesmanID Int)
	Create Table #TmpDS (SalesmanID Int)
	Create Table #TmpBeat (Beat Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
	Create Table #TmpDSType (DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

	

    Select * Into #TmpGGRRFinalData From GGRRFinalData Where Cast('01-' + [Month] as Datetime) = cast('01-'+ @monthYear as Datetime)
    
    Insert Into #TmpDS Select SalesmanID From Salesman
    Insert Into #TmpBeat Select Description From Beat
    Insert Into #TmpDSType Select Distinct DSTypevalue From DSType_Master


	Select * Into #tmpInvalidCust From (Select Distinct CustomerID From #TmpGGRRFinalData 
	Where Cast('01-' + [Month] as Datetime) = Cast('01-'+ @monthYear as Datetime)) T

	Insert Into #T_Customer(CustomerID,SalesmanID)
	Select Distinct CustomerID,DSID From #TmpGGRRFinalData 
	Where Cast('01-' + [Month] as Datetime) = Cast('01-'+ @monthYear as Datetime)
	Union
	Select Distinct G.OutletID as CustomerID,BS.SalesManID as DSID From GGDROutlet G, Beat_salesMan BS
	Where G.OutletID = BS.CustomerID and Cast('01-'+ @monthYear as Datetime) Between G.ReportFromDate and G.ReportToDate
		and G.OutletID not in (Select Distinct CustomerID From #tmpInvalidCust)

	Insert Into #T_Customer(CustomerID,SalesmanID)
	Select Distinct CustomerID,SalesmanID From Beat_Salesman Where CustomerID in (Select Distinct CustomerID From #T_Customer)
	
	Declare @CustomerID as Nvarchar(255)
	Declare @SalesmanID as Int

	Insert Into #TmpCustomer
	Select Distinct T.CustomerID,T.SalesmanID,Beat=isnull((SELECT B.Description FROM Beat B WHERE B.BeatID = Bs.BeatID ),'')
	From #T_Customer T
	Left Join Beat_Salesman BS ON T.CustomerID = BS.CustomerID and T.SalesmanID = BS.SalesmanID


	If Exists (Select 'x' From #TmpCustomer Where Isnull(Beat,'') = '')
	Begin
		Insert Into #TmpBeat Values ('')
	End


	Select Distinct ProdDefnID, DetailID,@GGDRMonth [Months],GGRRFinalData.CustomerID [CustomerID],
		CustomerName [CustomerName],DSID [DSID],S.Salesman_Name [DSName],DSType [DSType],LastDayCloseDate [LastDayCloseDate]--,GGRRFinalData.Points,GGRRFinalData.Flag
		--B.Beat [Beat],Status,Target,TargetUOM,CatGRP [CatGRP],OCG,Actual,CurrentStatus [CurrentStatus]
	Into #TmpAbstract
	From #TmpGGRRFinalData GGRRFinalData, #TmpCustomer B, SalesMan S	
	Where B.CustomerID = GGRRFinalData.CustomerID
		And B.SalesmanID = GGRRFinalData.DSID
		And Cast('01-' + [Month] as dateTime) = cast('01-'+ @monthYear as DateTime)
		And DSType in (Select Distinct DSType From #TmpDSType)
		And DSID in (Select Distinct SalesmanID From #TmpDS)
		And B.Beat in (Select Distinct Beat From #TmpBeat)
		And S.SalesmanID = GGRRFinalData.DSID
		
		 --get abstract data start 
   
   
    Set dateformat dmy
	Declare @LDCDate Datetime
	Declare @OIUDate Datetime
	Declare @Date Datetime
	Declare @OCGGlag As Int
	Declare @IsReceivedPost Int
   
   


	Select Top 1 @LDCDate=isnull(LastinventoryUpload,getdate()) from Setup
	Select Top 1 @OIUDate=isnull(OldinventoryUploadDate,getdate()) from Setup
	Set @OCGGlag = (Select Top 1 isnull(Flag,0) from tbl_merp_Configabstract Where ScreenCode = 'OCGDS')

	
	declare @fromdate datetime
	set @fromdate= dbo.StripTimeFromDate(@GGDRMonth) 
	
	
	--/* Temp InvoiceAbstract Table*/
	
	
	
	Select * into #tmpInvAbstract From Invoiceabstract where 
	customerID in (Select Distinct CustomerID from #TmpAbstract) 
	And	Convert(Nvarchar(10),Invoicedate,103) between @fromdate and @fromdate
	And Isnull(InvoiceType,0) in (1,3,4)
	And Isnull(Status,0) & 128 = 0
	
	
	

	
    IF OBJECT_ID('tempdb..#InvDetail') IS NULL
	select * into #InvDetail from  InvoiceDetail Where Invoiceid in (select Invoiceid from #tmpInvAbstract)
   
	
	update #tmpInvAbstract set invoicedate = convert(nvarchar(10),InvoiceDate,103)
	

	IF OBJECT_ID('tempdb..#TmpGGDRSKUDetails') IS NULL
	Select * into #TmpGGDRSKUDetails from TmpGGDRSKUDetails T
	Where T.ProdDefnID In (select Distinct ProdDefnID From #TmpAbstract) 
	And T.Product_Code In (Select Distinct ID.Product_Code From #InvDetail ID)
	

	
    create table #TmpGGDRData(InvoiceDate datetime
     ,RetailerCode nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
     DSID int ,
     DSType nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
     CategoryGroup nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
     SystemSKU nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
     SalesVolume decimal(18,6),
     SalesValue decimal(18,6),
     ProdDefnId int,
     CreationDate datetime)
     
     
   

	IF IsNull(@OCGGlag,0) = 1
		Insert Into  #TmpGGDRData(InvoiceDate,RetailerCode,DSID,DSType,CategoryGroup,SystemSKU,SalesVolume,SalesValue,ProdDefnId,CreationDate)
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
		Join (select distinct ProdDefnID,CustomerID from   #TmpAbstract )  GGRR On GGRR.[CustomerID] = IA.CustomerID 
		Join #TmpGGDRSKUDetails TSKU On TSKU.ProdDefnID = GGRR.ProdDefnID And TSKU.Product_Code = ID.Product_code 		
		Join OCGItemMaster OCGI On OCGI.SystemSKU = ID.Product_code  
		Join DSType_Master DS On Ds.DSTypeId = IA.DSTypeID ) T
		Group By T.Date,T.RetailerCode,T.DSID,T.DSType ,T.CategoryGroup ,T.SystemSKU,T.ProdDefnID		
	Else
		Insert Into #TmpGGDRData (InvoiceDate,RetailerCode,DSID,DSType,CategoryGroup,SystemSKU,SalesVolume,SalesValue,ProdDefnId,CreationDate)
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
		Join (select distinct ProdDefnID,CustomerID from   #TmpAbstract ) GGRR On GGRR.CustomerID = IA.CustomerID --And IA.InvoiceDate Between GGRR.Reportfromdate and GGRR.ReportToDate 
		Join #TmpGGDRSKUDetails TSKU On TSKU.ProdDefnID = GGRR.ProdDefnID And TSKU.Product_Code = ID.Product_code 	
		Join Items I On I.Product_Code = ID.Product_code 
		Join ItemCategories MSKU On MSKU.CategoryID = I.CategoryID 
		Join ItemCategories Subcat On Subcat.CategoryID = MSKU.ParentID 
		Join ItemCategories Div On Div.CategoryID = Subcat.ParentID 
		Join tblCGDivMapping GR On GR.Division = Div.Category_Name --And GR.Categorygroup = GGRR.CategoryGroup  
		Join DSType_Master DS On Ds.DSTypeId = IA.DSTypeID ) T
		Group By T.Date,T.RetailerCode,T.DSID,T.DSType ,T.CategoryGroup ,T.SystemSKU, T.ProdDefnID			
   
   
   --get abstract detail end
		
    
      create table #TmpGGDRDatatemp(
     RetailerCode nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
     DSID int ,
     DSType nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
     ProdDefnId int)
   
     
     insert into #TmpGGDRDatatemp(RetailerCode ,DSID ,DSType,ProdDefnId )
     select distinct  RetailerCode,DSID ,DSType,ProdDefnId from #TmpGGDRData
   
		

	Declare @DetailID nvarchar(500)
	Declare @ProdDefnID int
	Declare @Months nvarchar(30)
	Declare @CustomerID1 nvarchar(30)
	Declare @CustomerName nvarchar(250)
	Declare @DSID int
	Declare @DSName nvarchar(250)
	Declare @DSType nvarchar(250)
	Declare @LastDayCloseDate Datetime
	Declare @GGDRFromDate Datetime
	Declare @GGDRToDate Datetime
	Declare @Points decimal(18,6)
	Declare @Flag nvarchar(200)



	CREATE TABLE #TmpActual(		
		[ProductCode] Nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ProductDescription] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ProductLevel] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Target] Decimal(18, 6) NULL Default 0,
		[TargetUOM] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsExcluded] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Actual] Decimal(18, 6) NULL Default 0,
		FromDate dateTime Null,
		Todate dateTime Null, ProdDefnID int)

	Create Table #TmpOutput(DetailID nvarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
		Months nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, CustomerID nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
		CustomerName nvarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS, CatGRP nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
		DSID int, DSName nvarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS, 
		DSType nvarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS, LastDayCloseDate Datetime, ProdDefnID int,
		ProductCode nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, ProdCatLevel int,
		ProductDescription nvarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS, Target Decimal(18,6),
		TargetUOM nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS, IsExcluded int, Actual Decimal(18,6),Points nvarchar(20),Flag nvarchar(10))


	--Select * Into #TmpGGDRData From GGDRData Where InvoiceDate Between @GGDRFromDate and @GGDRToDate
	Select * Into #TmpTmpGGDRSKUDetails From TmpGGDRSKUDetails Where ProdDefnID in(Select Distinct ProdDefnID From #TmpAbstract)
	Select * Into #TmpGGDRProduct From GGDRProduct Where ProdDefnID in(Select Distinct ProdDefnID From #TmpAbstract)
    
    
	Declare Cur Cursor For
	Select t.DetailID, t.ProdDefnID, t.Months, t.CustomerID, t.CustomerName, t.DSID, t.DSName, t.DSType, Convert(Datetime, t.LastDayCloseDate, 103)--,Points,Flag  
	From #TmpAbstract t inner join #TmpGGDRDatatemp tg on tg.ProdDefnId=t.ProdDefnID 
	where  t.DSID=tg.DSID and  t.DSType=tg.DSType  and  t.CustomerID=tg.RetailerCode
	Open Cur
	Fetch From Cur Into @DetailID, @ProdDefnID, @Months, @CustomerID1, @CustomerName, @DSID, @DSName, @DSType, @LastDayCloseDate--,@Points,@Flag
	While @@Fetch_Status =0
	Begin
		Insert Into #TmpActual(ProductCode, ProductDescription, ProductLevel, Target, TargetUOM, IsExcluded, Actual, ProdDefnID)
		Exec sp_Get_GGRR_TargetvsActual_Daily @DetailID,@fromdate

		Insert Into #TmpOutput(DetailID, Months, CustomerID, CustomerName, DSID, DSName, DSType, LastDayCloseDate, ProductCode, Target, TargetUOM, Actual,Points,Flag,ProdDefnID)
		Select @DetailID, @Months, @CustomerID1, @CustomerName, @DSID, @DSName, @DSType, @LastDayCloseDate, ProductCode, Target, TargetUOM, Actual,@Points,@Flag,@ProdDefnID From #TmpActual

		Delete From #TmpActual

		Fetch Next from Cur Into @DetailID, @ProdDefnID, @Months, @CustomerID1, @CustomerName, @DSID, @DSName, @DSType, @LastDayCloseDate--,@Points,@Flag
	End
	Close Cur
	Deallocate Cur
	
	update #TmpOutput set #TmpOutput.Points = #TmpGGRRFinalData.Points,#TmpOutput.Flag = #TmpGGRRFinalData.Flag
	From #TmpGGRRFinalData where #TmpOutput.CustomerID = #TmpGGRRFinalData.CustomerID and #TmpOutput.DSID = #TmpGGRRFinalData.DSID and #TmpOutput.DSType = #TmpGGRRFinalData.DSType and #TmpOutput.ProdDefnID = #TmpGGRRFinalData.ProdDefnID
	and #TmpOutput.ProductCode = #TmpGGRRFinalData.D_ProductCode

	--Select DetailID, @WDDest [WD Dest Code],@monthYear [Month],@fromdate [From Date],@fromdate [To Date], CustomerID [Customer ID]], CustomerName [Customer Name], DSID [DS ID],
	--	DSName [DS Name], DSType [DS Type], LastDayCloseDate [Last Day Close Date], ProductCode [Product Code], Target,
	--	TargetUOM [Target UOM], Actual,Points,Flag [WinnerSKU Flag] From #TmpOutput where ISNULL(Actual,0)<>0 --Months [Month]
	
	
	Select DetailID, @WDDest [WD Dest Code],@monthYear [Month],@fromdate [From Date],@fromdate [To Date], CustomerID [Customer ID], CustomerName [Customer Name], DSID [DS ID],
		DSName [DS Name], DSType [DS Type], LastDayCloseDate [Last Day Close Date], ProductCode [Product Code], Target,
		TargetUOM [Target UOM], Actual,Points,Flag [WinnerSKU Flag] From #TmpOutput where ISNULL(Actual,0)<>0
	

	Drop Table #TmpDS
	Drop Table #TmpBeat
	Drop Table #TmpDSType
	Drop Table #TmpCustomer
	Drop Table #T_Customer
	Drop Table #tmpInvalidCust
	Drop Table #TmpAbstract
	Drop Table #TmpGGRRFinalData
	Drop Table #TmpGGDRSKUDetails
	Drop Table #TmpGGDRData
	Drop Table #InvDetail
	Drop Table #tmpInvAbstract
	Drop Table #TmpOutput
	Drop Table #TmpActual
	Drop Table #TmpTmpGGDRSKUDetails
	Drop Table #TmpGGDRProduct
	drop table #TmpGGDRDatatemp
	
	
	
End
