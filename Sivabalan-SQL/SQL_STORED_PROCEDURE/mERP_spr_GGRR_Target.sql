Create Procedure mERP_spr_GGRR_Target(@GGDRMonth nvarchar(10),@RecdDSType Nvarchar(4000),@DS Nvarchar(4000),@Beat Nvarchar(4000))
As
Begin
	Set DateFormat DMY
	
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
		Insert Into #TmpBeat Select Description From Beat
	End
	Else
	Begin
		Insert Into #TmpBeat    
		Select Description From Beat Where Description In (Select * From dbo.sp_splitin2Rows(@Beat,@Delimeter))    
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

	Select * Into #TmpGGRRFinalData From GGRRFinalData Where Cast('01-' + [Month] as Datetime) = cast('01-'+ @GGDRMonth as Datetime)

	Select * Into #tmpInvalidCust From (Select Distinct CustomerID From #TmpGGRRFinalData 
	Where Cast('01-' + [Month] as Datetime) = Cast('01-'+ @GGDRMonth as Datetime)) T

	Insert Into #T_Customer(CustomerID,SalesmanID)
	Select Distinct CustomerID,DSID From #TmpGGRRFinalData 
	Where Cast('01-' + [Month] as Datetime) = Cast('01-'+ @GGDRMonth as Datetime)
	Union
	Select Distinct G.OutletID as CustomerID,BS.SalesManID as DSID From GGDROutlet G, Beat_salesMan BS
	Where G.OutletID = BS.CustomerID and Cast('01-'+ @GGDRMonth as Datetime) Between G.ReportFromDate and G.ReportToDate
		and G.OutletID not in (Select Distinct CustomerID From #tmpInvalidCust)

	Insert Into #T_Customer(CustomerID,SalesmanID)
	Select Distinct CustomerID,SalesmanID From Beat_Salesman Where CustomerID in (Select Distinct CustomerID From #T_Customer)
	
	Declare @CustomerID as Nvarchar(255)
	Declare @SalesmanID as Int

	Insert Into #TmpCustomer
	Select Distinct T.CustomerID,T.SalesmanID,Beat=isnull((SELECT B.Description FROM Beat B WHERE B.BeatID = Bs.BeatID ),'')
	From #T_Customer T
	Left Join Beat_Salesman BS ON T.CustomerID = BS.CustomerID and T.SalesmanID = BS.SalesmanID

--	Declare Cur Cursor for
--	select Distinct CustomerID,SalesmanID from #T_Customer
--	Open Cur
--	Fetch from Cur into @CustomerID,@SalesmanID
--	While @@fetch_status =0
--		Begin
--
--			IF Exists(Select 'X' From Beat_Salesman	Where CustomerID = @CustomerID And SalesmanID = @SalesmanID)
--			Begin
--				Insert Into #TmpCustomer				
--				Select Distinct CustomerID,SalesmanID,B.Description From Beat_Salesman,Beat B
--				Where B.BeatID = Beat_Salesman.BeatID And
--				CustomerID = @CustomerID And SalesmanID = @SalesmanID
--			End
--			Else
--			Begin 
--				Insert Into #TmpCustomer				
--				Select @CustomerID,@SalesmanID,''
--			End
-- 
--			Fetch Next from Cur into @CustomerID,@SalesmanID
--		End
--	Close Cur
--	Deallocate Cur

	If Exists (Select 'x' From #TmpCustomer Where Isnull(Beat,'') = '')
	Begin
		Insert Into #TmpBeat Values ('')
	End

	Delete From #TmpCustomer Where SalesmanID Not in (Select Distinct SalesmanID From #TmpDS)
	Delete From #TmpCustomer Where Beat Not in (Select Distinct Beat From #TmpBeat)

	Select @GGDRMonth = CAST(DATENAME(Month,Cast('01-'+ @GGDRMonth as Datetime)) as nvarchar(3)) + '-' + Right(Year(Cast('01-'+ @GGDRMonth as Datetime)),4)

	Select Distinct ProdDefnID, DetailID,@GGDRMonth [Months],GGRRFinalData.CustomerID [CustomerID],
		CustomerName [CustomerName],DSID [DSID],S.Salesman_Name [DSName],DSType [DSType],LastDayCloseDate [LastDayCloseDate]--,GGRRFinalData.Points,GGRRFinalData.Flag
		--B.Beat [Beat],Status,Target,TargetUOM,CatGRP [CatGRP],OCG,Actual,CurrentStatus [CurrentStatus]
	Into #TmpAbstract
	From #TmpGGRRFinalData GGRRFinalData, #TmpCustomer B, SalesMan S	
	Where B.CustomerID = GGRRFinalData.CustomerID
		And B.SalesmanID = GGRRFinalData.DSID
		And Cast('01-' + [Month] as dateTime) = cast('01-'+ @GGDRMonth as DateTime)
		And DSType in (Select Distinct DSType From #TmpDSType)
		And DSID in (Select Distinct SalesmanID From #TmpDS)
		And B.Beat in (Select Distinct Beat From #TmpBeat)
		And S.SalesmanID = GGRRFinalData.DSID

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

	Select @GGDRFromDate = dbo.mERP_fn_getFromDate (@GGDRMonth)
	Select @GGDRToDate = dbo.mERP_fn_getToDate (@GGDRMonth)	

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


	Select * Into #TmpGGDRData From GGDRData Where InvoiceDate Between @GGDRFromDate and @GGDRToDate
	Select * Into #TmpTmpGGDRSKUDetails From TmpGGDRSKUDetails Where ProdDefnID in(Select Distinct ProdDefnID From #TmpAbstract)
	Select * Into #TmpGGDRProduct From GGDRProduct Where ProdDefnID in(Select Distinct ProdDefnID From #TmpAbstract)

	Declare Cur Cursor For
	Select DetailID, ProdDefnID, Months, CustomerID, CustomerName, DSID, DSName, DSType, Convert(Datetime, LastDayCloseDate, 103)--,Points,Flag  
	From #TmpAbstract
	Open Cur
	Fetch From Cur Into @DetailID, @ProdDefnID, @Months, @CustomerID1, @CustomerName, @DSID, @DSName, @DSType, @LastDayCloseDate--,@Points,@Flag
	While @@Fetch_Status =0
	Begin
		Insert Into #TmpActual(ProductCode, ProductDescription, ProductLevel, Target, TargetUOM, IsExcluded, Actual, ProdDefnID)
		Exec sp_Get_GGRR_TargetvsActual @DetailID

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

	Select DetailID, @WDDest [WD Dest Code], Months [Month], CustomerID [Customer ID], CustomerName [Customer Name], DSID [DS ID],
		DSName [DS Name], DSType [DS Type], LastDayCloseDate [Last Day Close Date], ProductCode [Product Code], Target,
		TargetUOM [Target UOM], Actual,Points,Flag [WinnerSKU Flag] From #TmpOutput

	Drop Table #TmpDS
	Drop Table #TmpBeat
	Drop Table #TmpDSType
	Drop Table #TmpCustomer
	Drop Table #T_Customer
	Drop Table #tmpInvalidCust
	Drop Table #TmpAbstract
	Drop Table #TmpOutput
	Drop Table #TmpActual
	Drop Table #TmpGGDRData
	Drop Table #TmpTmpGGDRSKUDetails
	Drop Table #TmpGGDRProduct
	Drop Table #TmpGGRRFinalData
End
