
Create Procedure mERP_spr_CustomerwiseProductivity(
	@Channel nVarchar(4000),
	@ChannelType nVarchar(4000),
	@OutletType nVarchar(4000),
	@LoyaltyProgram nVarchar(4000),
	@Customer nVarchar(4000),
	@Category nVarchar(255),
	@CateName nVarchar(4000),
	@Sales nVarchar(50),
	@UOM nVarchar(20),
	@FromDate DateTime,
	@ToDate DateTime)
As
Begin
	Set DateFormat DMY	
	Declare @SUBTOTAL nVarchar(50)
	Declare @GRNTOTAL nVarchar(50)
	Declare @CompaniesToUploadCode as nVarchar(255)   	
	Declare @WDCode as nVarchar(255)    
	Declare @WDDestCode as nVarchar(255)
	Declare @Delimeter as Char(1)            
	Set @Delimeter=Char(15)  


	Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload        
	Select Top 1 @WDCode = RegisteredOwner From Setup          
	
	If @CompaniesToUploadCode='ITC001'        
		Set @WDDestCode= @WDCode        
	Else        
	Begin        
		Set @WDDestCode= @WDCode        
		Set @WDCode= @CompaniesToUploadCode        
	End        
	 

	If @Category = '%' 
		Select @Category = isNull(HierarchyName,'') From ItemHierarchy Where HierarchyID = 3
	If @Sales = '%'
		Set @Sales = N'Value'
	If @UOM = '%'
		Set @UOM = N'Base UOM'

	If @Sales = 'Volume' And @UOM = 'N/A'  
		Set @UOM = N'Base UOM'

	
	If @Sales = 'Value' And @UOM <> 'N/A' 
		Set @UOM = N'N/A'

	Set @SUBTOTAL = dbo.LookupDictionaryItem(N'SubTotal:', Default)
	Set @GRNTOTAL = dbo.LookupDictionaryItem(N'GrandTotal:', Default)

	Create Table #tmpCGColumn(ColID Int Identity(1,1),ColumnName NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Create Table #tmpCatColumn(ColID Int Identity(1,1),ColumnName NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)


	Create Table #tmpChannel(ChannelType nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	If (@Channel = N'%') OR  (@Channel = N'All Channels')
		Insert Into #tmpChannel Select ChannelType From Customer_Channel
	Else
		Insert Into #tmpChannel Select ChannelType 
			From Customer_Channel
			Where ChannelDesc In (Select * From dbo.sp_SplitIn2Rows(@Channel, @Delimeter))

	Create Table #tmpCustomer(CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

	If (@Customer = N'%') OR (@Customer = N'All Customers')
		Insert Into #tmpCustomer Select CustomerID From Customer 
			Where ChannelType In (Select * From #tmpChannel)
	Else
		Insert Into #tmpCustomer Select CustomerID 
			From Customer
			Where Company_Name In (Select * From dbo.sp_SplitIn2Rows(@Customer, @Delimeter))
			And ChannelType In (Select * From #tmpChannel)

	-- Channel type name changed, and new channel classifications added

	Declare @TOBEDEFINED nVarchar(50)

	Set @TOBEDEFINED=dbo.LookupDictionaryItem(N'To be defined', Default)


	Create Table #tmpChannelType (ChannelType nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	If (@ChannelType = N'%') OR  (@ChannelType = N'All Type')
		Insert Into #tmpChannelType Select Distinct Channel_Type_Desc From tbl_merp_olclass Union Select @TOBEDEFINED
	Else
		Insert Into #tmpChannelType Select Distinct Channel_Type_Desc From tbl_merp_olclass
			Where Channel_Type_Desc In (Select * From dbo.sp_SplitIn2Rows(@ChannelType, @Delimeter))

	Create Table #tmpOutletType (OutletType nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	If (@OutletType = N'%') OR  (@OutletType = N'All Type')
		Insert Into #tmpOutletType Select Distinct Outlet_Type_Desc From tbl_merp_olclass Union Select @TOBEDEFINED
	Else
		Insert Into #tmpOutletType Select Distinct Outlet_Type_Desc From tbl_merp_olclass 
			Where Outlet_Type_Desc In (Select * From dbo.sp_SplitIn2Rows(@OutletType, @Delimeter))

	Create Table #tmpLoyaltyProgram (LoyaltyProgram nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	If (@LoyaltyProgram = N'%') OR (@LoyaltyProgram = N'All Type')
		Insert Into #tmpLoyaltyProgram  Select Distinct SubOutlet_Type_Desc From tbl_merp_olclass Union Select @TOBEDEFINED
	Else
		Insert Into #tmpLoyaltyProgram Select Distinct SubOutlet_Type_Desc From tbl_merp_olclass
			Where SubOutlet_Type_Desc In (Select * From dbo.sp_SplitIn2Rows(@LoyaltyProgram , @Delimeter))


	CREATE TABLE #OLClassMapping (OLClassID Int, CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)  

	Create Table #OLClassCustLink (OLClassID Int, CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ChannelType Int, Active Int, [Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)

	Insert Into #OLClassMapping 
	Select  olcm.OLClassID, olcm.CustomerId, olc.Channel_Type_Desc, olc.Outlet_Type_Desc, 
	olc.SubOutlet_Type_Desc 
	From tbl_merp_olclass olc, tbl_merp_olclassmapping olcm
	Where olc.ID = olcm.OLClassID And
	olc.Channel_Type_Active = 1 And olc.Outlet_Type_Active = 1 And olc.SubOutlet_Type_Active = 1 And 
	olcm.Active = 1  

	Insert Into #OLClassCustLink 
	Select olcm.OLClassID, C.CustomerId, C.ChannelType , C.Active, IsNull(olcm.[Channel Type], @TOBEDEFINED), 
	IsNull(olcm.[Outlet Type], @TOBEDEFINED) , IsNull(olcm.[Loyalty Program], @TOBEDEFINED) 
	From #OLClassMapping olcm right outer join Customer C on  olcm.CustomerID = C.CustomerID
	 



	Create Table #tempCategoryList(CategoryId Int)
	If @CateName = '%'
		Insert Into #tempCategoryList Select * From dbo.mERP_fn_GetCategory(@Category)
	Else 
		Insert Into #tempCategoryList Select CategoryID From ItemCategories Where Category_Name In( 
			Select * From dbo.sp_SplitIn2Rows(@CateName, @Delimeter))

	--Get leaflevel categories of given hierarchy level
	Create table  #tempCategory (CategoryID Int, Status Int)  
	Create Table #tmpCategories(CatLevel Int, CatName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, LeafLevelCat Int)
	Declare @CatName As nVarchar(255)
	Declare @CatID As Int
	Declare Category Cursor  For  
		Select ItemCategories.Category_Name, ItemCategories.CategoryID
		From ItemCategories
		Where ItemCategories.CategoryID In (select CategoryID from #tempCategoryList)
	Open Category  
	Fetch From Category Into @CatName, @CatID  
	While @@Fetch_Status = 0  
	Begin  
		Exec GetLeafCategories @Category , @CatName
		Insert Into #tmpCategories Select @CatID, @CatName, CategoryID From #tempCategory
		Delete From #tempCategory
	Fetch From Category Into @CatName, @CatID  
	End	

	Close Category
	Deallocate Category



	Create Table #tempCatIDCG(LeafID Int,CatName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,CGName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS) 
	Insert Into #tempCatIDCG(LeafID,CatName) 
	Select Distinct LeafLevelCat,CatName
	From #tmpCategories 


	If Exists(Select * From SysObjects Where Name like 'tblCGDivMapping' And Xtype = 'u')
	Begin	
		if @Category = '%' Or @Category = 'Division'
--			Update #tempCatIDCG Set CGName = 
--			(Select CategoryGroup From tblCGDivMapping Where Division = #tempCatIDCG.CatName)

			Update T Set T.CGName = a.CategoryGroup	From #tempCatIDCG T, tblCGDivMapping a
				Where T.CatName = a.Division
		Else
			Begin
--			Update #tempCatIDCG Set CGName = 
--			(Select CategoryGroup From tblCGDivMapping Where Division = (Select Category_Name From ItemCategories
--			Where CategoryID  = (Select ParentID From ItemCategories Where  Category_Name = #tempCatIDCG.CatName)))
				CREATE Table #TmpDCG(Parent_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Category_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,GroupName nvarchar(205) COLLATE SQL_Latin1_General_CP1_CI_AS)
				insert into #TmpDCG (Parent_Name,Category_Name)
				Select distinct Category_Name,CatName From ItemCategories,#tempCatIDCG  
				Where CategoryID  = (Select distinct ParentID From ItemCategories Where  Category_Name = #tempCatIDCG.CatName)
				Update T set GroupName=D.CategoryGroup from #TmpDCG T,tblCGDivMapping D where D.Division=T.Parent_Name
				Update T Set CGName =T1.GroupName from #tempCatIDCG T,#TmpDCG T1 where T.CatName = T1.Category_Name

			End
	End
	Else
	Begin
		if @Category = '%' Or @Category = 'Division'
			Update #tempCatIDCG Set CGName = 
			(Select GroupName From ProductCategoryGroupAbstract Where GroupID =
				(Select GroupID From  ProductCategoryGroupDetail Where CategoryID  = 
					(Select CategoryID From ItemCategories Where Category_Name = #tempCatIDCG.CatName)
				)
			)
		Else
			Update #tempCatIDCG Set CGName = 
			(Select GroupName From ProductCategoryGroupAbstract Where GroupID =
				(Select GroupID From  ProductCategoryGroupDetail Where CategoryID  = 
					(Select ParentID From ItemCategories Where  Category_Name = #tempCatIDCG.CatName)
				)
			)
	End

	

	--Get Customerwise Productivity
	Create Table #tmpCustProductivity(CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	RCSID nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, CustomerName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	Address nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Channel nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	[Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,

	CatLevel nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, CatID Int, NetSales Decimal(18,6), 
	Quantity Decimal(18,6), BillCount Int, LinesCut Int,CGName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Insert Into #tmpCustProductivity
	Select  IA.CustomerID, 
		CS.RCSOutletID, 
		CS.Company_Name,
		CS.BillingAddress,
		CH.ChannelDesc,
		IsNull(olcl.[Channel Type], @TOBEDEFINED) , 
		IsNull(olcl.[Outlet Type], @TOBEDEFINED), 
		IsNull(olcl.[Loyalty Program], @TOBEDEFINED),

		tmp.CatName,--Category name for the selected Hierarchy(for div AG)
		tmp.CatLevel,--category id for the selected hierarchy			
		Sum(Case IA.InvoiceType
			When 4 Then	0 - (ID.Amount)
			Else ID.Amount		
			End) as NetSales,		
		Sum(Case @UOM
			When N'Base UOM' Then 
					(Case IA.InvoiceType 
						When 4 Then 0 - ISNULL(ID.Quantity, 0)
						Else ISNULL(ID.Quantity, 0)
					End)
			When N'UOM 1' Then 
					Case IA.InvoiceType 
						When 4 Then 0 - (IsNull(ID.Quantity,0) / 
							(Case IsNull(IT.UOM1_Conversion, 0) 
								When 0 Then 1 
								Else IsNull(IT.UOM1_Conversion,1) 
								End))
						Else IsNull(ID.Quantity,0) / 
							(Case IsNull(IT.UOM1_Conversion, 0) 
								When 0 Then 1 
								Else IsNull(IT.UOM1_Conversion,1) 
								End)
						End

			When N'UOM 2' Then 
					Case IA.InvoiceType 
						When 4 Then 0 - (IsNull(ID.Quantity,0)/ 
							(Case IsNull(IT.UOM2_Conversion, 0) 
								When 0 Then 1 
								Else IsNull(IT.UOM2_Conversion,1) 
							End))
						Else IsNull(ID.Quantity,0) / 
							(Case IsNull(IT.UOM2_Conversion, 0) 
								When 0 Then 1 
								Else IsNull(IT.UOM2_Conversion,1) 
								End) 
					End
			End) as Quantity,
		(Select '') as BillCount,
		(Select '') as LinesCut,CG.CGName
		From #tmpCategories tmp, InvoiceAbstract IA, InvoiceDetail ID, Customer CS, 
		Items IT, Customer_Channel CH, #tempCatIDCG CG, #OLClassCustLink olcl
		Where IA.InvoiceDate Between @FromDate And @ToDate
		And IA.Status & 128 = 0  
		And IA.InvoiceID = ID.InvoiceID
		And CS.CustomerID = IA.CustomerID
		And IA.CustomerID In (Select CustomerID From #tmpCustomer)
		And ID.Product_Code = IT.Product_Code
		And IT.CategoryID = tmp.LeafLevelCat
		And CS.ChannelType = CH.ChannelType
		And CH.ChannelType In (Select ChannelType From #tmpChannel)
		And IT.CategoryID = CG.LeafID
		And olcl.CustomerID = CS.CustomerID
		And olcl.[Channel Type] In (Select ChannelType From #tmpChannelType)
		And olcl.[Outlet Type] In (Select OutletType From #tmpOutletType)
		And olcl.[Loyalty Program] In (Select LoyaltyProgram From #tmpLoyaltyProgram)
		Group By IA.CustomerID, CS.RCSOutletID, CS.Company_Name, CS.BillingAddress, CH.ChannelDesc, 
		tmp.CatName, tmp.CatLevel,CG.CGName, olcl.[Channel Type] , olcl.[Outlet Type] , olcl.[Loyalty Program]


	
	--Same item billed twice in same invoice will be considered as one line
	--Invoicewise lines cut taken 
	Create Table #tmpLinesCut(CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, InvoiceID Int, LinesCut Int)
	Insert Into #tmpLinesCut Select IA.CustomerID, IA.InvoiceID, Count(Distinct(ID.Product_Code))
		From #tmpCategories tmp, InvoiceAbstract IA, InvoiceDetail ID, Customer CS, Items IT, Customer_Channel CH 
		Where IA.InvoiceID = ID.InvoiceID
		And CS.CustomerID = IA.CustomerID
		And IA.CustomerID In (Select CustomerID From #tmpCustomer)
		And ID.Product_Code = IT.Product_Code
		And IT.CategoryID = tmp.LeafLevelCat
		And IA.InvoiceDate Between @FromDate And @ToDate
		And CS.ChannelType = CH.ChannelType
		And CH.ChannelType In (Select ChannelType From #tmpChannel)
		And IA.Status & 128 = 0  
		And IA.InvoiceType In(1,3)
		Group By IA.CustomerID, IA.InvoiceID
	
	--Sum up invoicewise linescut for a customer
	Update #tmpCustProductivity Set LinesCut = (Select Sum(#tmpLinesCut.LinesCut) From #tmpLinesCut
	Where #tmpLinesCut.CustomerID = #tmpCustProductivity.CustomerID
	Group By #tmpLinesCut.CustomerID)

	

	Create Table #tmpTotalValue(CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, CatID Int, NetSales Decimal(18,6), Quantity Decimal(18,6))
	Insert Into #tmpTotalValue Select CustomerId, CatID, NetSales, Quantity From #tmpCustProductivity

	Create Table #tmpCGWiseBill(CustomerID NvARCHAR(500) COLLATE SQL_Latin1_General_CP1_CI_AS,InvoiceID Int,
	CGName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,ProdCode nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Insert Into #tmpCGWiseBill(CustomerID ,InvoiceID ,CGName ,ProdCode)
		Select IA.CustomerID, IA.InvoiceID,CG.CGName,ID.Product_Code
		From #tmpCategories tmp, InvoiceAbstract IA, InvoiceDetail ID, Customer CS, Items IT, Customer_Channel CH ,#tempCatIDCG CG 
		Where IA.InvoiceID = ID.InvoiceID
		And CS.CustomerID = IA.CustomerID
		And IA.CustomerID In (Select CustomerID From #tmpCustomer)
		And ID.Product_Code = IT.Product_Code
		And IT.CategoryID = tmp.LeafLevelCat
		And  IT.CategoryID =  CG.LeafID
		And IA.InvoiceDate Between @FromDate And @ToDate
		And CS.ChannelType = CH.ChannelType
		And CH.ChannelType In (Select ChannelType From #tmpChannel)
		And IA.Status & 128 = 0  
		And IA.InvoiceType In(1,3)
		

	Create Table #tempCGWiseLineCnt(CustomerID nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CGName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,InvoiceID Int,LineCount Int)
	Insert Into #tempCGWiseLineCnt(CustomerID ,CGName ,InvoiceID ,LineCount )
	Select CustomerID ,CGName ,InvoiceID ,Count(Distinct ProdCode)
	From  
	#tmpCGWiseBill
	Group By CustomerID ,InvoiceID ,CGName




	Update #tmpCustProductivity Set BillCount = (Select Count(Distinct InvoiceID) From #tempCGWiseLineCnt Where CustomerID = 
	#tmpCustProductivity.CustomerID)

	
		--Alter The Table to add CategoryGroup Column headers 
		Declare @CGName as nVarchar(500)
		Declare @CGSql as nVarchar(4000)
		Declare @CGCol as nVarchar(4000)
		Set @CGCol =''

		If Exists(Select * From SysObjects Where Name like 'tblCGDivMapping' And Xtype = 'u')
			Declare CGColCur Cursor For 
			Select Distinct CategoryGroup From tblCGDivMapping
		Else
			Declare CGColCur Cursor For 
			Select  GroupName From ProductCategoryGroupAbstract


		Open CGColCur
		Fetch From  CGColCur Into @CGName
		While @@Fetch_Status = 0
		Begin
			Set @CGSQL = ''
			If isNull(@CGName,'') <> ''
						
			Set @CGSQL = 'Alter Table #tmpCustProductivity Add [Avg Bill Value-' + @CGName + '] Decimal(18,6)'
			Exec sp_ExecuteSql @CGSQL
			Set @CGCol = @CGCol + ',[Avg Bill Value-' + @CGName + ']'
			Set @CGSQL = 'Update #tmpCustProductivity  Set [Avg Bill Value-' + @CGName + '] = 
			isNull((Select Sum(NetSales) From #tmpCustProductivity T Where CustomerID = #tmpCustProductivity.CustomerID And CGName = ' + '''' + @CGName + '''' + '),0)/
			Case (Select Count(Distinct(InvoiceID)) From #tmpCGWiseBill Where CustomerID = #tmpCustProductivity.CustomerID  And CGName = ' + '''' + @CGName + '''' + ') When 0 Then 1 Else
			(Select Count(Distinct(InvoiceID)) From #tmpCGWiseBill Where CustomerID = #tmpCustProductivity.CustomerID  And CGName = ' + '''' + @CGName + '''' + ') End '
			Exec sp_ExecuteSql @CGSQL
			
			Set @CGSQL = 'Alter Table #tmpCustProductivity Add [Bills Cut-' + @CGName + '] Int'
			Exec sp_ExecuteSql @CGSQL
			Set @CGCol = @CGCol + ',[Bills Cut-' + @CGName + ']'
			Set @CGSQL = 'Update #tmpCustProductivity  Set [Bills Cut-' + @CGName + '] = 
			(Select Count(Distinct(InvoiceID)) From #tmpCGWiseBill Where CustomerID = #tmpCustProductivity.CustomerID  And CGName = ' + '''' + @CGName + '''' + ')'
			Exec sp_ExecuteSql @CGSQL
			

			Set @CGSQL = 'Alter Table #tmpCustProductivity Add [Avg Lines Cut-' + @CGName + '] Int'
			Exec sp_ExecuteSql @CGSQL
			Set @CGCol = @CGCol + ',[Avg Lines Cut-' + @CGName + ']'
			Set @CGSQL = 'Update #tmpCustProductivity  Set [Avg Lines Cut-' + @CGName + '] = 
			isNull((Select Sum(LineCount) From #tempCGWiseLineCnt Where CustomerID = #tmpCustProductivity.CustomerID  And CGName = ' + '''' + @CGName + '''' + ' ),0)/
			Case (Select Count(Distinct(InvoiceID)) From #tmpCGWiseBill Where CustomerID = #tmpCustProductivity.CustomerID  And CGName = ' + '''' + @CGName + '''' + ') When 0 Then 1 Else
			(Select Count(Distinct(InvoiceID)) From #tmpCGWiseBill Where CustomerID = #tmpCustProductivity.CustomerID  And CGName = ' + '''' + @CGName + '''' + ') End '
			Exec sp_ExecuteSql @CGSQL


			Set @CGSQL = 'Alter Table #tmpCustProductivity Add [Total Lines Cut-' + @CGName + '] Int'
			Exec sp_ExecuteSql @CGSQL
			Set @CGCol = @CGCol + ',[Total Lines Cut-' + @CGName + ']'
			Set @CGSQL = 'Update #tmpCustProductivity  Set [Total Lines Cut-' + @CGName + '] = 
			isNull((Select Sum(LineCount) From #tempCGWiseLineCnt Where CustomerID = #tmpCustProductivity.CustomerID  And CGName = ' + '''' + @CGName + '''' + ' ),0)'
			Exec sp_ExecuteSql @CGSQL

			
			
			Fetch Next From  CGColCur Into @CGName	
		End
		Close CGColCur
		Deallocate CGColCur
	
		Declare @Col1 as nVarchar(max)
		Set @Col1 = Substring(@CGCol,2,len(@CGCol))
		Insert Into #tmpCGColumn
		Select * from dbo.sp_SplitIn2Rows(@Col1,',')
		
		
		


	Declare @CategoryName nVarchar(255)
	Declare @CategoryID Int
	Declare @Sql nVarchar(max)
	Declare @Columns nVarchar(max)
	Declare @Col nVarchar(255)
	Set @Columns = ''

	Declare DynamicCol Cursor For 
	Select Distinct CatLevel, CatName From #tmpCategories
	Order By CatName
	Open DynamicCol 
	Fetch From DynamicCol Into @CategoryID, @CategoryName
	While @@Fetch_Status = 0  
	Begin  
		Set @Col = '[' + @CategoryName + ']'
		Set @Sql =  'Alter Table #tmpCustProductivity Add ' + @Col + ' Decimal(18,6)  default 0'
		Set @Columns = @Columns + ',' + @Col 
		Exec sp_ExecuteSql @Sql
		If @Sales = 'Value'
			Set @Sql = 'Update #tmpCustProductivity Set ' + @Col + ' = #tmpTotalValue.NetSales ' 
		Else
			Set @Sql = 'Update #tmpCustProductivity Set ' + @Col + ' = #tmpTotalValue.Quantity' 

		Set @Sql = @Sql + ' From #tmpCustProductivity, #tmpTotalValue '
		Set @Sql = @Sql + ' Where #tmpCustProductivity.CustomerID = #tmpTotalValue.CustomerID '
		Set @Sql = @Sql + '	And ' + Cast (@CategoryID as nVarchar) + ' = #tmpTotalValue.CatID'
		Exec sp_ExecuteSql @Sql

		--Null columns will be shown with zero value		
		Set @Sql = 'Update #tmpCustProductivity Set ' + @Col + ' = (Case isNull(' + @Col + ',0 ) When 0 Then 0 Else ' + @Col + ' End)'
		Exec sp_ExecuteSql @Sql

		Fetch From DynamicCol Into @CategoryID, @CategoryName
	End
	Close DynamicCol
	Deallocate DynamicCol

	Set @Col1 = Substring(@Columns,2,len(@Columns))
	Insert Into #tmpCatColumn
	Select * from dbo.sp_SplitIn2Rows(@Col1,',')

	
	Create Table #tmpConsolidate(
	[WDCode] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[WD Code] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[WD Dest Code] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[From Date] DateTime,
	[To Date] DateTime,
	[Customer Code] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[RCS ID] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	CustomerName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	Address nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	[Channel] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	[New Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	[New Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	[New Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,

	NetSales Decimal(18,6),[Avg Bill Value] Decimal(18,6) ,[Bills Cut]	Int,
	[Total Lines Cut] Int,[Avg Lines Cut] Decimal(18,6),[Base GOI Market ID] Int, [Base GOI Market Name] Nvarchar(240)COLLATE SQL_Latin1_General_CP1_CI_AS )

	
	--To add The Category Group column dynamically
	Declare @Coll as nVarchar(500)
	Declare CurCol Cursor For
	Select  ColumnName From #tmpCGColumn Order By ColID
	Open CurCol
	Fetch From CurCol Into @Coll
	While @@Fetch_Status = 0
	Begin
		If (Substring(@Coll,1,len('[bills cut-')) = '[bills cut-' Or 
			Substring(@Coll,1,len('[Avg Lines Cut-')) = '[Avg Lines Cut-' Or
			Substring(@Coll,1,len('[Total Lines Cut-')) = '[Total Lines Cut-' )
			Set @Sql =  'Alter Table #tmpConsolidate Add ' + @Coll + ' Int' 
		Else
			Set @Sql =  'Alter Table #tmpConsolidate Add ' + @Coll + ' Decimal(18,6)' 
		
		Exec sp_ExecuteSql @Sql
		Fetch Next From CurCol Into @Coll
	End
	Close CurCol
	Deallocate CurCol

	--To add The Category column dynamically
	Declare CurCol Cursor For
	Select  ColumnName From #tmpCatColumn Order By ColID
	Open CurCol
	Fetch From CurCol Into @Coll
	While @@Fetch_Status = 0
	Begin
		Set @Sql =  'Alter Table #tmpConsolidate Add ' + @Coll + ' Decimal(18,6)' 
		Exec sp_ExecuteSql @Sql
		Fetch Next From CurCol Into @Coll
	End
	Close CurCol
	Deallocate CurCol


	If @CGCOL <> ''
		Begin
			Set @Sql = 'Insert Into #tmpConsolidate ([WDCode],[WD Code],[WD Dest Code],[From Date] ,[To Date] ,[Customer Code],[RCS ID], [CustomerName], [Address], 
			[Channel], [New Channel Type], [New Outlet Type], [New Loyalty Program],[NetSales] ,[Avg Bill Value],
			[Bills Cut],[Total Lines Cut] ,[Avg Lines Cut] ' + @CGCOL + @Columns + ')' 
		End
	Else
		Set @Sql = 'Insert Into #tmpConsolidate ([WDCode],[WD Code],[WD Dest Code],[From Date] ,[To Date] ,[Customer Code],[RCS ID], [CustomerName], [Address], 
		[Channel], [New Channel Type], [New Outlet Type], [New Loyalty Program],[NetSales] ,[Avg Bill Value],
		[Bills Cut],[Total Lines Cut] ,[Avg Lines Cut] ' + @Columns + ')' 

	--Set @Sql = 'Insert Into #tmpConsolidate ' 
	Set @Sql = @Sql + 'Select Distinct ' + '''' + Cast(@WDCode as nVarchar(255)) + ''''   + ',' + ''''  
	Set @Sql = @Sql +  Cast(@WDCode as nVarchar(255)) + '''' +  ',' + '''' + Cast(@WDDestCode as nVarchar(255)) + '''' + ',' + ''''
	Set @Sql =  @Sql + Cast(@FromDate as nVarchar(255)) + '''' +  ',' + '''' + Cast(@ToDate as nVarchar(255)) + '''' 
	Set @Sql = @Sql +  ' , CustomerID as [Customer Code], IsNull(RCSID, '''') as [RCS ID], CustomerName as [Customer Name], Address as [Address1],'
	If @CGCOL <> ''
	Begin
		Set @Sql = @Sql + 'Channel as [Channel] ,[Channel Type], [Outlet Type], [Loyalty Program], Sum(NetSales) as [Net Total Sales], Sum(NetSales)/(Case  Max(BillCount) When 0 Then 1 Else  Max(BillCount) End) as [Avg Bill Value],'
		Set @Sql = @Sql + 'IsNull(Max(BillCount),0) as [Bills Cut], Max(LinesCut) as [Total Lines Cut],  "Avg Lines Cut" = Cast(Max(LinesCut) as Decimal(18,6)) /(Case Max(BillCount) When 0 Then 1 Else Cast(Max(BillCount) as Decimal(18,6)) End)' + @CGCOL + @Columns   + ' From #tmpCustProductivity '
	End
	Else
	Begin
		Set @Sql = @Sql + 'Channel as [Channel] , [Channel Type], [Outlet Type], [Loyalty Program], Sum(NetSales) as [Net Total Sales], Sum(NetSales)/(Case Max(BillCount) When 0 Then 1 Else Max(BillCount) End) as [Avg Bill Value], '
		Set @Sql = @Sql + 'IsNull(Max(BillCount),0) as [Bills Cut], Max(LinesCut) as [Total Lines Cut],  "Avg Lines Cut" = Cast(Max(LinesCut) as Decimal(18,6)) /(Case Max(BillCount) When 0 Then 1 Else Cast(Max(BillCount) as Decimal(18,6)) End) ' + @Columns   + ' From #tmpCustProductivity '	
	End

	If @CGCOL <> ''
		Set @Sql = @Sql + 'Group By CustomerID, RCSID, CustomerName, Address, Channel, [Channel Type], [Outlet Type], [Loyalty Program]' + @CGCol + @Columns
	Else
		Set @Sql = @Sql + 'Group By CustomerID, RCSID, CustomerName, Address, Channel, [Channel Type], [Outlet Type], [Loyalty Program]'  + @Columns

	Exec sp_ExecuteSql @Sql
	
	Declare @RptRcvd Int
	If (Select Count(*) From Reports Where ReportName = 'CustomerWise Productivity Analysis' And ParameterID in   
	(Select ParameterID From dbo.GetReportParametersForSPR('CustomerWise Productivity Analysis') Where   
	FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)) )>=1
	Begin  
		set @RptRcvd  = 1
		Insert Into #tmpConsolidate 
		([WDCode],[WD Code],[WD Dest Code],[From Date], [To Date],[Customer Code] ,[RCS ID] ,CustomerName ,Address ,
		Channel  , [Channel Type], [Outlet Type], [Loyalty Program], NetSales  ,[Avg Bill Value] ,
		[Bills Cut],[Total Lines Cut], [Avg Lines Cut])
		Select Field1,Field1, Field2,      Field3,      Field4 ,   Field5,         Field6 ,   Field7 ,     Field8 ,
		Field9,    Field10,        Field11,       Field12,           Field13,    Field14,
		Field15,  Field16,             Field17
		From Reports, ReportAbstractReceived
		Where Reports.ReportID in
		(Select Distinct ReportID From Reports
		Where ReportName = 'CustomerWise Productivity Analysis'
		And ParameterID in (Select ParameterID From dbo.GetReportParametersForSPR('CustomerWise Productivity Analysis') Where
		FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)))
		And ReportAbstractReceived.ReportID = Reports.ReportID
		and ReportAbstractReceived.Field1 <> 'WD Code'
		and ReportAbstractReceived.Field1 <> @SUBTOTAL
		and ReportAbstractReceived.Field1 <> @GRNTOTAL
	End
	If @RptRcvd = 1
	Begin  
		Declare @ReportID Int,@RPID NVarchar(255)  ,@SqlCol as Varchar(8000) 
		Declare @RecID Int,@RecColName nVarchar(255)
		Create Table #tmpRecColName(RecCol Int Identity(15,1),ColName nVarchar(255))
		Declare   
		
		 @Field18 NVarchar(255), @Field19 NVarchar(255), @Field20 NVarchar(255)
		,@Field21 NVarchar(255), @Field22 NVarchar(255), @Field23 NVarchar(255), @Field24 NVarchar(255)
		,@Field25 NVarchar(255), @Field26 NVarchar(255), @Field27 NVarchar(255), @Field28 NVarchar(255)
		,@Field29 NVarchar(255), @Field30 NVarchar(255), @Field31 NVarchar(255), @Field32 NVarchar(255)
		,@Field33 NVarchar(255), @Field34 NVarchar(255), @Field35 NVarchar(255), @Field36 NVarchar(255)
		,@Field37 NVarchar(255), @Field38 NVarchar(255), @Field39 NVarchar(255), @Field40 NVarchar(255)
		,@Field41 NVarchar(255), @Field42 NVarchar(255), @Field43 NVarchar(255), @Field44 NVarchar(255)
		,@Field45 NVarchar(255), @Field46 NVarchar(255), @Field47 NVarchar(255), @Field48 NVarchar(255)
		,@Field49 NVarchar(255), @Field50 NVarchar(255), @Field51 NVarchar(255), @Field52 NVarchar(255)
		,@Field53 NVarchar(255), @Field54 NVarchar(255), @Field55 NVarchar(255), @Field56 NVarchar(255)
		,@Field57 NVarchar(255), @Field58 NVarchar(255), @Field59 NVarchar(255), @Field60 NVarchar(255)
		,@Field61 NVarchar(255), @Field62 NVarchar(255), @Field63 NVarchar(255), @Field64 NVarchar(255)
		,@Field65 NVarchar(255), @Field66 NVarchar(255), @Field67 NVarchar(255), @Field68 NVarchar(255)
		,@Field69 NVarchar(255), @Field70 NVarchar(255), @Field71 NVarchar(255), @Field72 NVarchar(255)
		,@Field73 NVarchar(255), @Field74 NVarchar(255), @Field75 NVarchar(255), @Field76 NVarchar(255)
		,@Field77 NVarchar(255), @Field78 NVarchar(255), @Field79 NVarchar(255), @Field80 NVarchar(255)
		,@Field81 NVarchar(255), @Field82 NVarchar(255), @Field83 NVarchar(255), @Field84 NVarchar(255)
		,@Field85 NVarchar(255), @Field86 NVarchar(255), @Field87 NVarchar(255), @Field88 NVarchar(255)
		,@Field89 NVarchar(255), @Field90 NVarchar(255), @Field91 NVarchar(255), @Field92 NVarchar(255)
		,@Field93 NVarchar(255), @Field94 NVarchar(255), @Field95 NVarchar(255), @Field96 NVarchar(255)
		,@Field97 NVarchar(255), @Field98 NVarchar(255), @Field99 NVarchar(255), @Field100 NVarchar(255)
		,@Field101 NVarchar(255), @Field102 NVarchar(255), @Field103 NVarchar(255), @Field104 NVarchar(255)
		,@Field105 NVarchar(255), @Field106 NVarchar(255), @Field107 NVarchar(255), @Field108 NVarchar(255)
		,@Field109 NVarchar(255), @Field110 NVarchar(255), @Field111 NVarchar(255), @Field112 NVarchar(255)
		,@Field113 NVarchar(255), @Field114 NVarchar(255), @Field115 NVarchar(255), @Field116 NVarchar(255)
		,@Field117 NVarchar(255), @Field118 NVarchar(255), @Field119 NVarchar(255), @Field120 NVarchar(255)
		,@Field121 NVarchar(255), @Field122 NVarchar(255), @Field123 NVarchar(255), @Field124 NVarchar(255)
		,@Field125 NVarchar(255), @Field126 NVarchar(255), @Field127 NVarchar(255), @Field128 NVarchar(255)
		,@Field129 NVarchar(255), @Field130 NVarchar(255), @Field131 NVarchar(255), @Field132 NVarchar(255)
		,@Field133 NVarchar(255), @Field134 NVarchar(255), @Field135 NVarchar(255), @Field136 NVarchar(255)
		,@Field137 NVarchar(255), @Field138 NVarchar(255), @Field139 NVarchar(255), @Field140 NVarchar(255)
		,@Field141 NVarchar(255), @Field142 NVarchar(255), @Field143 NVarchar(255)
	  
		Declare CurReportID Cursor For 
		Select Distinct ReportID From ReportAbstractReceived 
		Where ReportID In
			(Select ReportID From Reports Where ReportName = 'CustomerWise Productivity Analysis' And
				ParameterID in 
				(Select ParameterID From dbo.GetReportParametersForSPR('CustomerWise Productivity Analysis') 
				Where FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)
				)
			)

		Open CurReportID  
  
		Fetch Next From CurReportID Into @ReportID  
	  
		While @@Fetch_Status=0  
		Begin  
			
			Select 
			@Field18 = IsNull(Field18,0),
			@Field19 = IsNull(Field19,0),@Field20 = IsNull(Field20,0),@Field21 = IsNull(Field21,0),
			@Field22 = IsNull(Field22,0),@Field23 = ISNull(Field23,0),@Field24 = IsNull(Field24,0),
			@Field25 = IsNull(Field25,0),@Field26 = IsNull(Field26,0),@Field27 = IsNull(Field27,0),
			@Field28 = IsNull(Field28,0),@Field29 = IsNull(Field29,0),@Field30 = IsNull(Field30,0),
			@Field31 = IsNull(Field31,0),@Field32 = IsNull(Field32,0),@Field33 = IsNull(Field33,0),
			@Field34 = IsNull(Field34,0),@Field35 = IsNull(Field35,0),@Field36 = IsNull(Field36,0),
			@Field37 = IsNull(Field37,0),@Field38 = IsNull(Field38,0),@Field39 = IsNull(Field39,0),
			@Field40 = IsNull(Field40,0),@Field41 = IsNull(Field41,0),@Field42 = IsNull(Field42,0),
			@Field43 = IsNull(Field43,0),@Field44 = IsNull(Field44,0),@Field45 = IsNull(Field45,0),
			@Field46 = IsNull(Field46,0),@Field47 = IsNull(Field47,0),@Field48 = IsNull(Field48,0),
			@Field49 = IsNull(Field49,0),@Field50 = IsNull(Field50,0),@Field51 = IsNull(Field51,0),
			@Field52 = IsNull(Field52,0),@Field53 = IsNull(Field53,0),@Field54 = IsNull(Field54,0),
			@Field55 = IsNull(Field55,0),@Field56 = IsNull(Field56,0),@Field57 = IsNull(Field57,0),
			@Field58 = IsNull(Field58,0),@Field59 = IsNull(Field59,0),@Field60 = IsNull(Field60,0),
			@Field61 = IsNull(Field61,0),@Field62 = IsNull(Field62,0),@Field63 = IsNull(Field63,0),
			@Field64 = IsNull(Field64,0),@Field65 = IsNull(Field65,0),@Field66 = IsNull(Field66,0),
			@Field67 = IsNull(Field67,0),@Field68 = IsNull(Field68,0),@Field69 = IsNull(Field69,0),
			@Field70 = IsNull(Field70,0),@Field71 = IsNull(Field71,0),@Field72 = IsNull(Field72,0),
			@Field73 = IsNull(Field73,0),@Field74 = IsNull(Field74,0),@Field75 = IsNull(Field75,0),
			@Field76 = IsNull(Field76,0),@Field77 = IsNull(Field77,0),@Field78 = IsNull(Field78,0),
			@Field79 = IsNull(Field79,0),@Field80 = IsNull(Field80,0),@Field81 = IsNull(Field81,0),
			@Field82 = IsNull(Field82,0),@Field83 = IsNull(Field83,0),@Field84 = IsNull(Field84,0),
			@Field85 = IsNull(Field85,0),@Field86 = IsNull(Field86,0),@Field87 = IsNull(Field87,0),
			@Field88 = IsNull(Field88,0),@Field89 = IsNull(Field89,0),@Field90 = IsNull(Field90,0),
			@Field91 = IsNull(Field91,0),@Field92 = IsNull(Field92,0),@Field93 = IsNull(Field93,0),
			@Field94 = IsNull(Field94,0),@Field95 = IsNull(Field95,0),@Field96 = IsNull(Field96,0),
			@Field97 = IsNull(Field97,0),@Field98 = IsNull(Field98,0),@Field99 = IsNull(Field99,0),
			@Field100 = IsNull(Field100,0),@Field101 = IsNull(Field101,0),@Field102 = IsNull(Field102,0),
			@Field103 = IsNull(Field103,0),@Field104 = IsNull(Field104,0),@Field105 = IsNull(Field105,0),
			@Field106 = IsNull(Field106,0),@Field107 = IsNull(Field107,0),@Field108 = IsNull(Field108,0),
			@Field109 = IsNull(Field109,0),@Field110 = IsNull(Field110,0),@Field111 = IsNull(Field111,0),
			@Field112 = IsNull(Field112,0),@Field113 = IsNull(Field113,0),@Field114 = IsNull(Field114,0),
		    @Field115 = IsNull(Field115,0),@Field116 = IsNull(Field116,0),@Field117 = IsNull(Field117,0),
			@Field118 = IsNull(Field118,0),@Field119 = IsNull(Field119,0),@Field120 = IsNull(Field120,0),
			@Field121 = IsNull(Field121,0),@Field122 = IsNull(Field122,0),@Field123 = IsNull(Field123,0),
			@Field124 = IsNull(Field124,0),@Field125 = IsNull(Field125,0),@Field126 = IsNull(Field126,0),
			@Field127 = IsNull(Field127,0),@Field128 = IsNull(Field128,0),@Field129 = IsNull(Field129,0),
			@Field130 = IsNull(Field130,0),@Field131 = IsNull(Field131,0),@Field132 = IsNull(Field132,0),
			@Field133 = IsNull(Field133,0),@Field134 = IsNull(Field134,0),@Field135 = IsNull(Field135,0),
			@Field136 = IsNull(Field136,0),@Field137 = IsNull(Field137,0),@Field138 = IsNull(Field138,0),
			@Field139 =IsNull(Field139,0),@Field140 = IsNull(Field140,0), 
			@Field141 = IsNull(Field141,0), @Field142 = IsNull(Field142,0), @Field143 = IsNull(Field143,0)

			From ReportAbstractReceived  
			Where ReportID=@ReportID 
			And Field1 = 'WD Code'


			Set @SqlCol = Cast(@Field18 as nVarchar(255))  + ',' + Cast(@Field19 as nVarchar(255)) + ',' +
					   Cast(@Field20 as nVarchar(255)) + ',' + Cast(@Field21 as nVarchar(255))  + ',' + Cast(@Field22 as nVarchar(255)) + ',' +
				       Cast(@Field23 as nVarchar(255)) + ',' + Cast(@Field24 as nVarchar(255))  + ',' + Cast(@Field25 as nVarchar(255)) + ',' +
					   Cast(@Field26 as nVarchar(255)) + ',' + Cast(@Field27 as nVarchar(255))  + ',' + Cast(@Field28 as nVarchar(255)) + ',' +
					   Cast(@Field29 as nVarchar(255)) + ',' + Cast(@Field30 as nVarchar(255))  + ',' + Cast(@Field31 as nVarchar(255)) + ',' +
					   Cast(@Field32 as nVarchar(255)) + ',' + Cast(@Field33 as nVarchar(255))  + ',' + Cast(@Field34 as nVarchar(255)) + ',' +			
					   Cast(@Field35 as nVarchar(255)) + ',' + Cast(@Field36 as nVarchar(255))  + ',' + Cast(@Field37 as nVarchar(255)) + ',' +
					   Cast(@Field38 as nVarchar(255)) + ',' + Cast(@Field39 as nVarchar(255))  + ',' + Cast(@Field40 as nVarchar(255)) + ',' +
					   Cast(@Field41 as nVarchar(255)) + ',' + Cast(@Field42 as nVarchar(255))  + ',' + Cast(@Field43 as nVarchar(255)) + ',' +			
					   Cast(@Field44 as nVarchar(255)) + ',' + Cast(@Field45 as nVarchar(255))  + ',' + Cast(@Field46 as nVarchar(255)) + ',' +
					   Cast(@Field47 as nVarchar(255)) + ',' + Cast(@Field48 as nVarchar(255))  + ',' + Cast(@Field49 as nVarchar(255)) + ',' +
					   Cast(@Field50 as nVarchar(255)) + ',' + Cast(@Field51 as nVarchar(255))  + ',' + Cast(@Field52 as nVarchar(255)) + ',' +
					   Cast(@Field53 as nVarchar(255)) + ',' + Cast(@Field54 as nVarchar(255))  + ',' + Cast(@Field55 as nVarchar(255)) + ',' +
					   Cast(@Field56 as nVarchar(255)) + ',' + Cast(@Field57 as nVarchar(255))  + ',' + Cast(@Field58 as nVarchar(255)) + ',' +			
					   Cast(@Field59 as nVarchar(255)) + ',' + Cast(@Field60 as nVarchar(255))  + ',' + Cast(@Field61 as nVarchar(255)) + ',' +
					   Cast(@Field62 as nVarchar(255)) + ',' + Cast(@Field63 as nVarchar(255))  + ',' + Cast(@Field64 as nVarchar(255)) + ',' +
					   Cast(@Field65 as nVarchar(255)) + ',' + Cast(@Field66 as nVarchar(255))	+ ',' + Cast(@Field67 as nVarchar(255)) + ',' +
					   Cast(@Field67 as nVarchar(255)) + ',' + Cast(@Field68 as nVarchar(255))  + ',' + Cast(@Field69 as nVarchar(255)) + ',' +			
					   Cast(@Field70 as nVarchar(255)) + ',' + Cast(@Field71 as nVarchar(255))  + ',' + Cast(@Field72 as nVarchar(255)) + ',' +
					   Cast(@Field73 as nVarchar(255)) + ',' + Cast(@Field74 as nVarchar(255))  + ',' + Cast(@Field75 as nVarchar(255)) + ',' +
					   Cast(@Field76 as nVarchar(255)) + ',' + Cast(@Field76 as nVarchar(255))  + ',' + Cast(@Field77 as nVarchar(255)) + ',' +			
					   Cast(@Field78 as nVarchar(255)) + ',' + Cast(@Field79 as nVarchar(255))  + ',' + Cast(@Field80 as nVarchar(255)) + ',' +
					   Cast(@Field81 as nVarchar(255)) + ',' + Cast(@Field82 as nVarchar(255))  + ',' + Cast(@Field83 as nVarchar(255)) + ',' +
					   Cast(@Field84 as nVarchar(255)) + ',' + Cast(@Field85 as nVarchar(255))  + ',' + Cast(@Field86 as nVarchar(255)) + ',' +
					   Cast(@Field87 as nVarchar(255)) + ',' + Cast(@Field88 as nVarchar(255))  + ',' + Cast(@Field89 as nVarchar(255)) + ',' +
					   Cast(@Field90 as nVarchar(255)) + ',' + Cast(@Field91 as nVarchar(255))  + ',' + Cast(@Field92 as nVarchar(255)) + ',' +			
					   Cast(@Field93 as nVarchar(255)) + ',' + Cast(@Field94 as nVarchar(255))  + ',' + Cast(@Field95 as nVarchar(255)) + ',' +
					   Cast(@Field96 as nVarchar(255)) + ',' + Cast(@Field97 as nVarchar(255))  + ',' + Cast(@Field98 as nVarchar(255)) + ',' +
					   Cast(@Field99 as nVarchar(255)) + ',' + Cast(@Field100 as nVarchar(255))	+ ',' + Cast(@Field101 as nVarchar(255)) + ',' +
					   Cast(@Field102 as nVarchar(255)) + ',' + Cast(@Field103 as nVarchar(255))  + ',' + Cast(@Field104 as nVarchar(255)) + ',' +
					   Cast(@Field105 as nVarchar(255)) + ',' + Cast(@Field106 as nVarchar(255))  + ',' + Cast(@Field107 as nVarchar(255)) + ',' +			
					   Cast(@Field108 as nVarchar(255)) + ',' + Cast(@Field109 as nVarchar(255))  + ',' + Cast(@Field110 as nVarchar(255)) + ',' +
					   Cast(@Field111 as nVarchar(255)) + ',' + Cast(@Field112 as nVarchar(255))  + ',' + Cast(@Field113 as nVarchar(255)) + ',' +
					   Cast(@Field114 as nVarchar(255)) + ',' + Cast(@Field115 as nVarchar(255))  + ',' + Cast(@Field116 as nVarchar(255)) + ',' +
					   Cast(@Field117 as nVarchar(255)) + ',' + Cast(@Field118 as nVarchar(255))  + ',' + Cast(@Field119 as nVarchar(255)) + ',' +			
					   Cast(@Field120 as nVarchar(255)) + ',' + Cast(@Field121 as nVarchar(255))  + ',' + Cast(@Field122 as nVarchar(255)) + ',' +
					   Cast(@Field123 as nVarchar(255)) + ',' + Cast(@Field124 as nVarchar(255))  + ',' + Cast(@Field125 as nVarchar(255)) + ',' +
					   Cast(@Field126 as nVarchar(255)) + ',' + Cast(@Field127 as nVarchar(255))  + ',' + Cast(@Field128 as nVarchar(255)) + ',' +
					   Cast(@Field129 as nVarchar(255)) + ',' + Cast(@Field130 as nVarchar(255))  + ',' + Cast(@Field131 as nVarchar(255)) + ',' +			
					   Cast(@Field131 as nVarchar(255)) + ',' + Cast(@Field132 as nVarchar(255))  + ',' + Cast(@Field133 as nVarchar(255)) + ',' +
					   Cast(@Field134 as nVarchar(255)) + ',' + Cast(@Field135 as nVarchar(255))  + ',' + Cast(@Field136 as nVarchar(255)) + ',' +
					   Cast(@Field137 as nVarchar(255)) + ',' + Cast(@Field138 as nVarchar(255))  + ',' + Cast(@Field139 as nVarchar(255)) + ',' +
					   Cast(@Field140 as nVarchar(255)) + ',' + Cast(@Field141 as nVarchar(255)) + ',' + Cast(@Field142 as nVarchar(255)) + ',' + 
					   Cast(@Field143 as nVarchar(255)) 
					   
	
			Truncate Table #tmpRecColName
			Insert Into #tmpRecColName
			Select * From dbo.sp_SplitIn2Rows(@SqlCol,',')

			
			Declare @Colmn nVarchar(255)
			Declare CurRecCol Cursor For
			Select RecCol,ColName From #tmpRecColName Where (isNull(ColName,'') <> '' And Cast(ColName As nVarchar) <> '0')
			Open CurRecCol
			Fetch From CurRecCol Into @RecID,@RecColName
			While @@Fetch_Status = 0
			Begin 
				Set @Colmn = '[' + @RecColName +']'
				If (Substring(@Colmn,1,len('[Bills Cut-')) = '[bills cut-' Or 
						Substring(@Colmn,1,len('[Avg Lines Cut-')) = '[Avg Lines Cut-' Or
						Substring(@Colmn,1,len('[Total Lines Cut-')) = '[Total Lines Cut-' Or
						Substring(@Colmn,1,len('[Avg Bill Value-')) = '[Avg Bill Value-' )	
				Begin	
					If Not Exists (Select * From #tmpCGColumn Where ColumnName=@Colmn)
					Begin
			   			Insert Into #tmpCGColumn (ColumnName) Values(@Colmn)
						If @RecColName Like 'Avg Bill Value-%'
							Set @Sql='Alter Table #tmpConsolidate Add [' + @RecColName + '] Decimal(18,6)'
						Else
							Set @Sql='Alter Table #tmpConsolidate Add [' + @RecColName + '] Int'
							Exec sp_ExecuteSql @Sql
						End
				End	
				Else
				Begin
					If Not Exists (Select * From #tmpCatColumn Where ColumnName=@Colmn)
					Begin
						Insert Into #tmpCatColumn (ColumnName) Values(@Colmn)
						Set @Sql='Alter Table #tmpConsolidate Add [' + @RecColName + '] Decimal(18,6)'
							Exec sp_ExecuteSql @Sql
					End	
				End	

				Set @Sql= 'Update #tmpConsolidate  Set ' + @Colmn  + ' = isNull((Select Sum(Cast(Field' + Cast(@RecID as nVarchar(255)) 
				+ ' as Decimal(18,6))) From ReportAbstractReceived Where ReportID = ' + Cast(@ReportID as nVarchar) + ' And  Field1 =
				#tmpConsolidate.[WD Code] And Field2  = #tmpConsolidate.[WD Dest Code] And Field5  = [Customer Code] And Field6 = [RCS ID] ),0)'


				Exec sp_ExecuteSql @Sql
				Fetch From CurRecCol Into @RecID,@RecColName
			End
			Close CurRecCol
			Deallocate CurRecCol
		Fetch Next From CurReportID Into @ReportID  
	End  
	Close CurReportID  
	Deallocate CurReportID  
End  

	Update T Set T.[Base GOI Market ID] = T1.MarketID,T.[Base GOI Market Name] = T1.MarketName
	From #tmpConsolidate T, MarketInfo T1,CustomerMarketInfo T2
	Where Ltrim(Rtrim(T.[Customer Code])) = Ltrim(Rtrim(T2.CustomerCode))
	And T2.Active = 1
	And T1.MMID = T2.MMID
--	And T1.Active = 1

	Select  * From #tmpConsolidate

	Drop Table #tmpCategories
	Drop Table #tempCategory
	Drop Table #tmpCustProductivity
	Drop Table #tmpCustomer
	Drop Table #tmpChannel
	Drop Table #tmpTotalValue
	Drop Table #tempCategoryList
	Drop Table #tempCGWiseLineCnt
	Drop Table #tmpCGWiseBill
	Drop Table #tempCatIDCG
	Drop Table #tmpLinesCut

	Drop Table #tmpConsolidate
	Drop Table #tmpCatColumn
	Drop Table #tmpCGColumn
End


