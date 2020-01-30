Create Procedure mERP_sp_Get_CustomerItems_ImportSO(@Salesman nVarchar(2550),
											@Beat nVarchar(2550),
											@CatLevel Int,
											@CategoryID NVarchar(2550),
											@UOM Int,
											@Stock Int,@customerID nvarchar(4000))

As
Begin

	Declare @Continue int
	Declare @Counter Int
	Declare @Delimeter as Char(1)

	Set @Continue = 1
	Set @Counter = 1
	Set @Delimeter= ','

	Create Table #tmpSalesMan(SalesmanID int)
	Create Table #tmpBeat(BeatID int)
	Create Table #tmpSelectedCustomer(CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS)

	Create Table #tempCategory (CategoryID Int, Status Int)
    Exec mERP_sp_GetLeafCategories @CatLevel, @CategoryID  

	Create table #tmpCat1(Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
    Create table #tempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)


	Create Table #tmpCustomer(CustomerID nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CustomerName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,OrderNumber nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Salesman nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Beat nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS)


	If @Salesman=N'%' Or @Salesman=N''     
	Begin
		Insert into #tmpSalesMan Select SalesmanID From Salesman Where Active = 1
		Insert into #tmpSalesMan Select 0
	End
	Else
		Insert into #tmpSalesMan Select SalesmanID From Salesman Where SalesmanID in (select * from dbo.sp_SplitIn2Rows(@Salesman, @Delimeter))

	If @Beat=N'%' Or @Beat=N''
	Begin
		Insert into #tmpBeat Select BeatID From Beat Where Active = 1
		Insert into #tmpBeat Select 0
	End
	Else
		Insert into #tmpBeat Select BeatID From Beat Where BeatID in (select * from dbo.sp_SplitIn2Rows(@Beat, @Delimeter)) 

	If @customerID=N'%' Or @customerID=N''
	Begin
		Insert into #tmpSelectedCustomer Select CustomerID From Customer Where Active = 1
		Insert into #tmpSelectedCustomer Select 0
	End
	Else
		Insert into #tmpSelectedCustomer Select CustomerID From Customer Where Active = 1 and CustomerID in (select * from dbo.sp_SplitIn2Rows(@customerID, @Delimeter)) 


	Insert into #tmpCat1 select Category_Name from ItemCategories
	Where [Level] = 1 Order By Category_Name
        
	Insert into #tempCategory1 select CategoryID, Category_Name, 0 as Status
	From ItemCategories
	Where ItemCategories.Category_Name In (Select Category from #tmpCat1)
	Order By Category_Name
        
	While @Continue > 0
	Begin 
	  Declare Parent Cursor Keyset For
	  Select CategoryID From #tempCategory1 Where Status = 0
	  Open Parent 
	  Fetch From Parent Into @CategoryID
	  While @@Fetch_Status = 0  
	  Begin
			Insert into #tempCategory1
			Select Distinct CategoryID, Category_Name, 0 as status From ItemCategories
			Where ParentID = @CategoryID Order By Category_Name
			If @@RowCount > 0
			  Update #tempCategory1 Set Status = 1 Where CategoryID = @CategoryID
			Else
			  Update #tempCategory1 Set Status = 2 Where CategoryID = @CategoryID

			Fetch Next From Parent Into @CategoryID
	  End
		 Close Parent
		 DeAllocate Parent
		 Select @Continue = Count(*) From #tempCategory1 Where Status = 0
	End




	Create Table #tmpItem(ItemCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,ItemName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,UOM nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
--	Insert Into #tmpItem Values('Customer Code')
--	Insert Into #tmpItem Values('Customer Name')
--	Insert Into #tmpItem Values('Order Number')
--	Insert Into #tmpItem Values('Salesman')
--	Insert Into #tmpItem Values('Beat')

	If @Stock = 0 --All Items
	Begin
		Insert Into #tmpItem
		Select 
			I.Product_Code,ProductName,U.Description
		From 
			Items I ,UOM U ,ItemCategories IC,#tempCategory1 T
		Where
			I.CategoryID = IC.CategoryID And
			IC.CategoryID In(Select Distinct CategoryID From #tempCategory) And
			U.UOM = (Case @UOM When 0 Then I.UOM When 1 Then I.UOM1 When 2 Then I.UOM2 End) And
			I.CategoryID = T.CategoryID And I.Active = 1
		Order By T.IDS
	End
	Else If @Stock = 1 --Items With stock
	Begin
		Insert Into #tmpItem
		Select 
			I.Product_Code,ProductName,U.Description
		From 
			Items I ,UOM U ,ItemCategories IC ,Batch_Products BP ,#tempCategory1 T
	    Where
			I.CategoryID = IC.CategoryID And
			IC.CategoryID In(Select Distinct CategoryID From #tempCategory) And
			U.UOM = (Case @UOM When 0 Then I.UOM When 1 Then I.UOM1 When 2 Then I.UOM2 End) And
			I.Product_Code = BP.Product_Code And
			IsNull(BP.Damage, 0) = 0 And 
			IsNull(BP.Expiry,GetDate()) >= GetDate() And
			IsNull(BP.Quantity, 0) > 0 And 
			I.CategoryID = T.CategoryID And I.Active = 1
		Group by 
			I.Product_Code, I.ProductName ,U.Description,T.IDS
		Order By T.IDS

	End

	Insert Into #tmpCustomer
	Select C.CustomerID ,C.Company_Name ,'',SM.Salesman_Name,B.DeScription
	From 
		Customer C,Beat_Salesman BS,Salesman SM,Beat B
	Where 
		C.Active = 1 And 
		C.CustomerID = BS.CustomerID And 
		SM.SalesmanID = BS.SalesmanID And
		B.BeatID = BS.BeatID And
		isNull(BS.CustomerID,'') <> '' And
		isNull(BS.SalesmanID,0) <> 0 And
		isNull(BS.BeatID,0) <> 0 And 
		SM.SalesmanID In (Select SalesmanID From #tmpSalesMan) And 
		B.BeatID In (Select BeatID From #tmpBeat) And
		C.CustomerID in (Select CustomerID from #tmpSelectedCustomer)

	Order By SM.Salesman_Name,B.DeScription,Company_Name

--	Select Count(*) - 5  From #tmpItem
--
--	Select * From #tmpItem

	Create Table #tmpOutput(CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,CustomerName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Salesman nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Beat nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
	OrderNo nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,OrderDate datetime,DeliveryDate nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ItemCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,ItemName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	UOM nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Quantity nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

	/* Since All Items need to be shown for each customer, we wrote below query */
	Insert into #tmpOutput(CustomerID,CustomerName,Salesman,Beat,OrderNo,OrderDate,DeliveryDate,ItemCode,ItemName,UOM,Quantity)
	Select Distinct CustomerID,CustomerName,Salesman,Beat,OrderNumber,getdate(),'',ItemCode,ItemName,UOM,'' From #tmpCustomer,#tmpItem
	
	
	Select Count(*) From #tmpOutput

	Select CustomerID [Customer ID],CustomerName [Customer Name],Salesman,Beat,OrderNo [Order No.],OrderDate [Order Date],DeliveryDate [Delivery Date],
	ItemCode [Item Code],ItemName [Item Desc],UOM,Quantity From #tmpOutput order by CustomerName,Salesman,Beat,ItemName


Drop Table #tmpItem
Drop Table #tempCategory
Drop Table #tmpSalesMan
Drop Table #tmpBeat
Drop table #tmpCustomer
Drop Table #tmpSelectedCustomer
Drop Table #tmpOutput
End

