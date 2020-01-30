Create Procedure mERP_spr_SlabwiseSalesRpt_ITC(
	@MonthFrm nVarchar(20),
	@Month2 nVarchar(20),
	@ProductHierarchy nVarchar(256),
	@Category nVarchar(2555),
	@UOM nVarchar(20),
	@Slabs nVarchar(2555)
)
As
Begin
-----

Declare @FromMonth nVarchar(20)
Declare @ToMonth nVarchar(20)
Declare @MonthFrom Datetime
Declare @MonthTo Datetime
Declare @Delimeter Char(1)
Declare @Delimeter1 Char(1) 
Declare @CatName As nVarchar(255)
Declare @CatID As Int
Declare @ColumnRowCount Int
Declare @i Int
Declare @SlabValue nVarchar(256)
Declare @SQLStr nVarchar(4000)
Declare @FromUOM nVarchar(256), @ToUOM nVarchar(256)
Declare @Column1 nVarchar(256)
Declare @Column2 nVarchar(256)
Declare @UOMSlab Table (IDs Int Identity (1, 1), NoOfSlabs nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)
Declare @FromToValue Table ([From] Decimal(18, 6), [To] Decimal(18, 6))
Create Table #tempCategoryList(CategoryId Int)
Create table #tempCategory (CategoryID Int, Status Int)
Create Table #tmpCategories(Division nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, CatLevel Int, CatName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, LeafLevelCat Int)
Create Table #tmpItems(Product_Code nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #FOutPut([Month From] nVarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	[Month To] nVarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS)
-----

Set @i = 0
Set @ColumnRowCount = 0
Set @MonthFrom = Cast(('01/' + @MonthFrm) As Datetime)
Set @MonthTo = Cast(('01/' + @Month2) as Datetime)
Set @FromMonth = Substring(Datename(m, @MonthFrom), 1, 3) + N'-' + Substring(Cast(Datepart(YY, @MonthFrom) As nVarchar), 3, 2)
Set @ToMonth = Substring(Datename(m, @MonthTo), 1, 3) + N'-' + Substring(Cast(Datepart(YY, @MonthTo) As nVarchar), 3, 2)
Set @Delimeter = Char(15)
Set @Delimeter1 = '-'

If @ProductHierarchy = '%'
Set @ProductHierarchy = N'Company'

--Select * from ItemCategories where CategoryID = 447
--Company/Division/SubCategory/SystemSKU

If @Category = N'%'
Begin
	Insert Into #tempCategoryList(CategoryID) Select * From dbo.mERP_fn_GetCategory(@ProductHierarchy)
End
Else
Begin
	Insert Into #tempCategoryList(CategoryID) Select CategoryID From ItemCategories 
	Where Category_Name In (Select * From dbo.sp_SplitIn2Rows(@Category, @Delimeter))
End

Insert Into #tmpCategories(CatLevel , CatName , LeafLevelCat) Select ItCat.CategoryID, ItCat.Category_Name, ItCat.CategoryID
	From ItemCategories ItCat
	Where ItCat.CategoryID In (select CategoryID from #tempCategoryList)

IF @ProductHierarchy = N'System SKU'
Begin
	If @Category = N'%'
		Insert Into #tmpCategories(CatLevel , CatName , LeafLevelCat)
		Select Distinct IT.CategoryID, IT.Product_Code, IT.CategoryID
		From Items IT
	Else
		Insert Into  #tmpCategories(CatLevel , CatName , LeafLevelCat)
		Select Distinct IT.CategoryID, IT.Product_Code, IT.CategoryID
		From Items IT
		Where IT.Product_Code In (Select * From dbo.sp_SplitIn2Rows(@Category, @Delimeter))
End

--/*To Update Division ID*/
If @ProductHierarchy = N'Sub_Category'
  Update tCat Set tCat.Division = CatDiv.Category_Name
  From #tmpCategories tCat, ItemCategories CatDiv, /*ItemCategories CatSub, */ItemCategories iCat
  Where CatDiv.Level = 2 and CatDiv.CategoryID = iCat.ParentID 
  And iCat.Level = 3 and iCat.CategoryID = tCat.LeafLevelCat
Else If @ProductHierarchy = 'System SKU' Or @ProductHierarchy = 'Market_SKU'
 Update tCat Set tCat.Division = CatDiv.Category_Name
 From #tmpCategories tCat, ItemCategories CatDiv, ItemCategories CatSub, ItemCategories iCat
 Where CatDiv.Level=2 and CatDiv.CategoryID = CatSub.ParentID 
 And CatSub.Level = 3 and CatSub.CategoryID =  iCat.ParentID
 And iCat.Level = 4 and iCat.CategoryID = tCat.LeafLevelCat

Set @SQLStr = N'Alter Table #FOutPut Add [' + @ProductHierarchy + ']  
	nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS , Description nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Serviced Outlet] Int, UOM nVarchar(2555) COLLATE SQL_Latin1_General_CP1_CI_AS '
Exec (@SQLStr)

Set @SQLStr = N'Insert InTo #FOutPut([Month From] , [Month To], [' + @ProductHierarchy + '], 
	Description , [Serviced Outlet], UOM) 
	Select ''' + Cast(@FromMonth As nVarchar) + ''', ''' + Cast(@ToMonth As nVarchar) + ''', tc.CatName, 
		Case ''' + @ProductHierarchy + ''' When N''System SKU'' Then 
				IsNull((Select ProductName From Items Where Product_Code = tc.CatName), '''')
			Else
				IsNull((Select Top 1 Description From ItemCategories itc Where itc.CategoryID = tc.CatLevel), '''')
		End,
		"Serviced Outlet" = Cast(dbo.mERP_fn_SubSlabwiseSales_ITC(''' + Cast(@MonthFrom As nVarchar) + ''', ''' 
		+ Cast(@MonthTo As nVarchar) + ''', tc.CatName, ''' + @ProductHierarchy + ''', 1, ''' + @UOM + ''', 0, 0) As Int),
		"UOM" = dbo.mERP_fn_SubSlabwiseSales_ITC(''' + Cast(@MonthFrom As nVarchar) + ''', 
		''' + Cast(@MonthTo As nVarchar) + ''', 
		tc.CatName, ''' + @ProductHierarchy + ''', 2, ''' + @UOM + ''', 0, 0)
	From #tmpCategories tc
	Group By tc.Division, tc.CatName, tc.CatLevel Order By tc.Division,tc.CatName'


Exec (@SQLStr)

--Select * from #FOutPut

If @Slabs <> N'%'
Begin
	Insert InTo @UOMSlab Select * From dbo.sp_SplitIn2Rows(@Slabs, @Delimeter)

	Select @ColumnRowCount = Count(NoOfSlabs) From @UOMSlab

	While @i < @ColumnRowCount 
	Begin
		Select @SlabValue = NoOfSlabs From @UOMSlab
		Where IDs = @i + 1
		Insert InTo @FromToValue ([From], [To]) 
		Select "From" = (Select Top 1 Cast(ItemValue As Decimal(18, 6)) From dbo.sp_SplitIn2Rows(@SlabValue, @Delimeter1) Order By Cast(ItemValue As Decimal(18, 6))),
				"To" = (Select Top 1 Cast(ItemValue As Decimal(18, 6)) From dbo.sp_SplitIn2Rows(@SlabValue, @Delimeter1) 
											Order By Cast(ItemValue As Decimal(18, 6)) Desc)
	

	Select @FromUOM = [From], @ToUOM = [To] From @FromToValue

	
	Set @Column1 = 'No of O/L [' + Cast(@FromUOM As nVarchar) + ' to ' 
		+ Cast(@ToUOM As nVarchar) + ']]'

	Set @Column2 = 'Qty [' + Cast(@FromUOM As nVarchar) + ' to ' 
		+ Cast(@ToUOM As nVarchar) + ']]'

	Set @SQLStr = N'Alter Table #FOutPut Add [' + @Column1 + '] Int, [' + @Column2 + '] Decimal(18, 6)'

	Exec (@SQLStr)

	Set @SQLStr = N'Update #FOutPut Set [' + @Column1 + '] = Cast(IsNull(dbo.mERP_fn_SubSlabwiseSales_ITC(''' + 
		Cast(@MonthFrom As nVarchar) + ''', ''' 
		+ Cast(@MonthTo As nVarchar) + ''', #FOutPut.[' + @ProductHierarchy + '], ''' + 
		@ProductHierarchy + ''', 3, ''' + @UOM + ''', ' + @FromUOM + ', ' + @ToUOM + '), 0) As Int), 
		
		[' + @Column2 + '] = Cast(IsNull(dbo.mERP_fn_SubSlabwiseSales_ITC(''' + 
		Cast(@MonthFrom As nVarchar) + ''', ''' 
		+ Cast(@MonthTo As nVarchar) + ''', #FOutPut.[' + @ProductHierarchy + '], ''' + 
		@ProductHierarchy + ''', 4, ''' + @UOM + ''', ' + @FromUOM + ', ' + @ToUOM + '), 0) As Decimal(18, 6))'

	Exec (@SQLStr)


	Set @i = @i + 1
End

Set @SQLStr = N'Select [' + @ProductHierarchy + '], * from #FOutPut Where IsNull([Serviced Outlet],0) > 0'

Exec (@SQLStr)
--Select * from #FOutPut

--Select * from @UOMSlab
--Select * From @FromToValue
End
EndRun:
End
