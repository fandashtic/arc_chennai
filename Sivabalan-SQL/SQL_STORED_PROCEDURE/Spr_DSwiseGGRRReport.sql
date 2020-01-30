Create Procedure dbo.Spr_DSwiseGGRRReport(@RecDS Nvarchar(4000),@RecBeat Nvarchar(4000),@GGDRmonth Nvarchar(10))
As
Begin

	Set DateFormat DMY
	Declare @Delimeter as nVarchar
	Declare @OCGFlag as Int
	Set @Delimeter = Char(15)
	Select @OCGFlag = Isnull(Flag,0) From tbl_Merp_ConfigAbstract Where ScreenCode = 'OCGDS'
	Declare @LastInventoryUpload as Nvarchar(10)
	Set @LastInventoryUpload = (Select Top 1 Convert(Nvarchar(10),LastInventoryUpload,103) from Setup)

	Create Table #TmpCustomer (CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
				SalesmanID Int,
				Beat Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
	Create Table #TmpDS (SalesmanID Int)
	Create Table #TmpBeat (Beat Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
	Create Table #TmpDSType (DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

	CREATE TABLE #TempAbstract(
		PMCategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CustomerName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		DSID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		DSName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		DSType nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Beat nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Status nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CategoryGroup nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CurrentStatus nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		LastDayCloseDate nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		ProductCode nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Target decimal(18, 6) NULL Default 0,
		TargetUOM nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Actual decimal(18, 6) NULL Default 0)

	CREATE TABLE #TempNewAbstract(
		PMCategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CustomerName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		DSID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		DSName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		DSType nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Beat nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Status nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CategoryGroup nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CurrentStatus nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		LastDayCloseDate nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		ProductCode nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Target decimal(18, 6) NULL Default 0,
		TargetUOM nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Actual decimal(18, 6) NULL Default 0)

	CREATE TABLE #TmpDetail(
		ProductCode nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Target decimal(18, 6) NULL Default 0,
		TargetUOM nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Actual decimal(18, 6) NULL Default 0)

	CREATE TABLE #TempReportAbstract(
		PMCategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Customer ID] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Customer Name] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Beat nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DS Type] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Status as Received] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Cat Grp] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

	Create Table #TmpCat(ProductCode Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
	Create Table #T_Customer (CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,SalesmanID Int)
	Create Table #TmpCategoryGroup (GroupName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

--	If @RecDS = '%'
--	Begin
--		Insert Into #TmpDS Select SalesmanID From Salesman
--	End
--	Else
--	Begin
		Insert Into #TmpDS    
		Select SalesmanID From Salesman Where Salesman_Name In (Select * From dbo.sp_splitin2Rows(@RecDS,@Delimeter))    
--	End
	Declare @DStypeID as Int
	Declare @SalesmanID as Int

	Set @SalesmanID = (Select Top 1 SalesmanID from #TmpDS)
	Set @DStypeID = (Select Top 1 DSTypeID from DStype_Details Where Isnull(DSTypeCtlPos,0) = 1 and SalesmanID = @SalesmanID)

	Insert Into #TmpCategoryGroup (GroupName)
	Select Distinct groupName From ProductCategoryGroupAbstract Where Isnull(Active,0) = 1 and Isnull(OCGType,0) = @OCGFlag
	And GroupID in (Select Distinct GroupID From tbl_mERP_DSTypeCGMapping Where Isnull(Active,0) = 1 And DSTypeID = @DStypeID)

	If Not Exists (Select 'x' From #TmpDS)
	Begin
		Goto OUT
	End

	If @RecBeat = '%'
	Begin
		Insert Into #TmpBeat Select Description From Beat
	End
	Else
	Begin
		Insert Into #TmpBeat    
		Select Description From Beat Where Description In (Select * From dbo.sp_splitin2Rows(@RecBeat,@Delimeter))    
	End

	Insert Into #T_Customer(CustomerID,SalesmanID)
	select Distinct CustomerID,DSID from GGRRFinalData 
	Where cast('01-' + [Month] as dateTime) = cast('01-'+ @GGDRmonth as DateTime)

	Declare @A_CustomerID as Nvarchar(255)
	Declare @A_SalesmanID as Int

	Declare Cur Cursor for
	select Distinct CustomerID,SalesmanID from #T_Customer
	Open Cur
	Fetch from Cur into @A_CustomerID,@A_SalesmanID
	While @@fetch_status =0
		Begin

			IF Exists(Select 'X' From Beat_Salesman	Where CustomerID = @A_CustomerID And SalesmanID = @A_SalesmanID)
			Begin
				Insert Into #TmpCustomer				
				Select Distinct CustomerID,SalesmanID,B.Description From Beat_Salesman,Beat B
				Where B.BeatID = Beat_Salesman.BeatID And
				CustomerID = @A_CustomerID And SalesmanID = @A_SalesmanID
			End
			Else
			Begin 
				Insert Into #TmpCustomer				
				Select @A_CustomerID,@A_SalesmanID,''
			End
 
			Fetch Next from Cur into @A_CustomerID,@A_SalesmanID
		End
	Close Cur
	Deallocate Cur

	If Exists (Select 'x' From #TmpCustomer Where Isnull(Beat,'') = '')
	Begin
		Insert into #TmpBeat Values ('')
	End

	Insert Into #TempNewAbstract
	Select Distinct GGRRFinalData.PMCategory,GGRRFinalData.CustomerID CustomerID,
	CustomerName,DSID,DSName,DSType,B.Beat,
	Status,(Case When @OCGFlag = 0 Then CatGRP Else OCG End) CategoryGroup,CurrentStatus,LastDayCloseDate,
	 Ltrim(Rtrim(D_ProductCode)) ,D_Target,D_TargetUOM,D_Actual
	from GGRRFinalData,#TmpCustomer B
	Where Isnull(GGRRFinalData.D_IsExcluded,'') = '' 
	And B.CustomerID = GGRRFinalData.CustomerID
	And B.SalesmanID = GGRRFinalData.DSID
	And cast('01-' + Month as dateTime) = cast('01-'+ @GGDRmonth as DateTime)
	And DSID in (Select Distinct SalesmanID From #TmpDS)
	And B.Beat in (Select Distinct Beat From #TmpBeat)
	And Isnull(D_ProductCode,'') <> 'All'

/* SRS Point: In this column the targets and achievements for [Red] Outlets should be displayed with [/] separator and UOM.  This column should display as blank In case of [Eligible for Green] outlets.*/
/* If Red Customer and Product is All then the customer Level Target & UOM & Acheived only consider. */
	Insert Into #TempNewAbstract
	Select Distinct GGRRFinalData.PMCategory,GGRRFinalData.CustomerID CustomerID,
	CustomerName,DSID,DSName,DSType,B.Beat,
	Status,(Case When @OCGFlag = 0 Then CatGRP Else OCG End) CategoryGroup,CurrentStatus,LastDayCloseDate,
	 D_ProductCode ,Target,TargetUOM,Actual
	from GGRRFinalData,#TmpCustomer B
	Where Isnull(GGRRFinalData.D_IsExcluded,'') = '' 
	And B.CustomerID = GGRRFinalData.CustomerID
	And B.SalesmanID = GGRRFinalData.DSID
	And cast('01-' + Month as dateTime) = cast('01-'+ @GGDRmonth as DateTime)
	And DSID in (Select Distinct SalesmanID From #TmpDS)
	And B.Beat in (Select Distinct Beat From #TmpBeat)
	And Isnull(D_ProductCode,'') = 'All'
	And Isnull(Status,'') = 'Red'

/* If Green Customer and Product is All then the customer Level Target as 0 & UOM & Acheived = 0. */

	Insert Into #TempNewAbstract
	Select Distinct GGRRFinalData.PMCategory,GGRRFinalData.CustomerID CustomerID,
	CustomerName,DSID,DSName,DSType,B.Beat,
	Status,(Case When @OCGFlag = 0 Then CatGRP Else OCG End) CategoryGroup,CurrentStatus,LastDayCloseDate,
	 D_ProductCode ,0,TargetUOM,0
	from GGRRFinalData,#TmpCustomer B
	Where Isnull(GGRRFinalData.D_IsExcluded,'') = '' 
	And B.CustomerID = GGRRFinalData.CustomerID
	And B.SalesmanID = GGRRFinalData.DSID
	And cast('01-' + Month as dateTime) = cast('01-'+ @GGDRmonth as DateTime)
	And DSID in (Select Distinct SalesmanID From #TmpDS)
	And B.Beat in (Select Distinct Beat From #TmpBeat)
	And Isnull(D_ProductCode,'') = 'All'
	And Isnull(Status,'') = 'Eligible for Green'

	Delete From #TempNewAbstract Where CategoryGroup not In (Select Distinct GroupName From #TmpCategoryGroup)
	Insert Into #TempAbstract(PMCategory,CustomerID,CustomerName,DSID,DSName,DSType,Beat,Status,CategoryGroup,CurrentStatus,LastDayCloseDate,ProductCode,Target,TargetUOM,Actual)
	Select Distinct PMCategory,CustomerID,CustomerName,DSID,DSName,DSType,Beat,Status,Null,CurrentStatus,LastDayCloseDate,ProductCode,Sum(Target),TargetUOM,Sum(Actual)
	From #TempNewAbstract
	Group By PMCategory,CustomerID,CustomerName,DSID,DSName,DSType,Beat,Status,CurrentStatus,LastDayCloseDate,ProductCode,TargetUOM
	Order By CustomerID,DSID,DSType

	Update #TempAbstract Set CategoryGroup = (Dbo.Fn_MergeCatGrpWithDSType(@OCGFlag,CustomerID,@GGDRmonth,DSType,PMCategory))

	Insert Into #TempReportAbstract(PMCategory,[Customer ID],[Customer Name],Beat,[DS Type],[Status as Received],[Cat GRP])
	Select Distinct PMCategory,CustomerID,CustomerName,Beat,DSType,Status,CategoryGroup From #TempAbstract

	Declare @T_ProductCode as Nvarchar(255)
	Declare @T_SQL as Nvarchar(Max)

	Truncate Table #TmpCat
	Insert Into #TmpCat(ProductCode)
	Select Distinct ProductCode From #TempAbstract Order By ProductCode Asc

	Alter Table #TempReportAbstract ADD [Overall] Nvarchar(255)

	Declare CUR_Alter Cursor for
	Select Distinct ProductCode From #TmpCat Where Isnull(ProductCode,'') <> 'All' Order By ProductCode Asc
	Open CUR_Alter
	Fetch from CUR_Alter into @T_ProductCode
	While @@fetch_status =0
		Begin
			Set @T_SQL = ''
			Set @T_SQL = 'Alter Table #TempReportAbstract ADD [' + @T_ProductCode  + '] Nvarchar(255)'
			Exec (@T_SQL)
			Fetch Next from CUR_Alter into @T_ProductCode
		End
	Close CUR_Alter
	Deallocate CUR_Alter	

	Alter Table #TempReportAbstract ADD [Conversion] Nvarchar(255)

	Declare @CustomerID As Nvarchar(255)
	Declare @CustomerName As Nvarchar(255)
	Declare @DSID As Int
	Declare @DSName As Nvarchar(255)
	Declare @DSType As Nvarchar(255)
	Declare @Beat As Nvarchar(255)
	Declare @Status As Nvarchar(255)
	Declare @CatGRP As Nvarchar(255)
	Declare @CurrentStatus As Nvarchar(255)
	Declare @D_ProductCode As Nvarchar(255)
	Declare @D_TargetUOM As Nvarchar(255)
	Declare @D_Target As Decimal(18,6)
	Declare @D_Actual As Decimal(18,6)
	Declare @Data As Nvarchar(4000)
	Declare @D_PMCategory As Nvarchar(255)

	Declare CUR Cursor for
	Select Distinct CustomerID,DSType,Beat,Status,CategoryGroup,CurrentStatus,ProductCode,Target,TargetUOM,Actual,PMCategory From #TempAbstract
	Where ProductCode in (Select Distinct ProductCode From #TmpCat)
	Open CUR
	Fetch from CUR into @CustomerID,@DSType,@Beat,@Status,@CatGRP,@CurrentStatus,@D_ProductCode,@D_Target,@D_TargetUOM,@D_Actual,@D_PMCategory
	While @@fetch_status =0
		Begin
			If Isnull(@D_ProductCode,'') = 'All' 
			Begin
				Set @D_ProductCode = 'Overall'
			End			

			Set @D_TargetUOM = (Select Case When @D_TargetUOM = 'Value' Then 'Rs' Else @D_TargetUOM End)			
			Set @Data =''
			Set @T_SQL = ''
			
/* As Per ITC Request The OverAll column only displayed with 2 decimals. */
			If Isnull(@D_ProductCode,'') = 'Overall' 
			Begin

				Set @Data = Cast(Cast(@D_Actual as Decimal(18,2)) As Nvarchar) +
				 '/' + Cast(Cast(@D_Target as Decimal(18,2)) As Nvarchar) + ' ' + @D_TargetUOM
			End
			Else 
			Begin
				Set @Data = Cast(Cast(@D_Actual as Decimal(18,0)) As Nvarchar) +
				 '/' + Cast(Cast(@D_Target as Decimal(18,0)) As Nvarchar) + ' ' + @D_TargetUOM
			End

			Set @T_SQL = 'Update #TempReportAbstract Set [' + @D_ProductCode + '] = ''' + @Data + ''', [Conversion] = ''' + @CurrentStatus +
			''' Where [Customer ID] = ''' + @CustomerID + ''' And [DS Type] = ''' + @DSType + ''' And Beat = ''' + @Beat + ''' And [Cat GRP] = ''' + @CatGRP + ''' And PMCategory = ''' + @D_PMCategory + ''''

			Exec (@T_SQL)

			Fetch Next from CUR into @CustomerID,@DSType,@Beat,@Status,@CatGRP,@CurrentStatus,@D_ProductCode,@D_Target,@D_TargetUOM,@D_Actual,@D_PMCategory
		End
	Close CUR
	Deallocate CUR


OUT:
	Select * From #TempReportAbstract order By Beat,[Customer Name] Asc

	Drop Table #TmpCat
	Drop Table #TmpDS
	Drop Table #TmpBeat
	Drop Table #TmpCustomer
	Drop Table #T_Customer
	Drop Table #TempAbstract
	Drop Table #TmpDetail
	Drop Table #TempReportAbstract
	Drop Table #TempNewAbstract
	Drop Table #TmpCategoryGroup

End
