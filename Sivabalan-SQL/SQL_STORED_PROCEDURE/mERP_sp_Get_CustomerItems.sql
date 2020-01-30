Create Procedure mERP_sp_Get_CustomerItems(@Salesman nVarchar(2550),
											@Beat nVarchar(2550),
											@CatLevel Int,
											@CategoryID NVarchar(2550),
											@UOM Int,
											@Stock Int)

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




	Create Table #tmpItem(ItemCode nVarchar(500))
	Insert Into #tmpItem Values('Customer Code')
	Insert Into #tmpItem Values('Customer Name')
	Insert Into #tmpItem Values('Order Number')
	Insert Into #tmpItem Values('Salesman')
	Insert Into #tmpItem Values('Beat')

	If @Stock = 0 --All Items
	Begin
		Insert Into #tmpItem
		Select 
			Cast(Product_Code as nVarchar(100)) + '~' + Cast(ProductName as nVarchar(100)) + '~' + Cast(U.Description as nVarchar(255))
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
			Cast(I.Product_Code as nVarchar(100)) + '~' + Cast(I.ProductName as nVarchar(100)) + '~' + Cast(U.Description as nVarchar(255))
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
		B.BeatID In (Select BeatID From #tmpBeat)
	Order By SM.Salesman_Name,B.DeScription,Company_Name

	Select Count(*) - 5  From #tmpItem

	Select * From #tmpItem

	Select Count(*) From #tmpCustomer

	Select * From #tmpCustomer


Drop Table #tmpItem
Drop Table #tempCategory
Drop Table #tmpSalesMan
Drop Table #tmpBeat
Drop table #tmpCustomer

End

