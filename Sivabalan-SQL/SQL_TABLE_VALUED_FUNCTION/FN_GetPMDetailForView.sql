Create Function FN_GetPMDetailForView()
Returns 
	@TmpView Table(
	SalesmanID Int NULL,
	Group_ID [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	PMProductID [int] NULL,
	[Level] [int] NULL,
	Product_Code [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,	
	Product_Name [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
AS
BEGIN

	Declare @CurrentDate Datetime
	Set @CurrentDate = dbo.StripTimeFromDate(Cast(GetDate() as Datetime))

	IF EXISTS (Select 'x' From HHViewLog Where dbo.StripTimeFromDate(Date) = @CurrentDate)
		Insert Into @TmpView (SalesmanID,Group_ID,PMProductID,[Level],Product_Code,Product_Name)
		Select SalesmanID,Group_ID,PMProductID,[Level],Product_Code,Product_Name From TmpPMDetail
	ELSE
	BEGIN
		Declare @TmpAbstract Table(
			SalesmanID [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			Group_ID [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			PMProductID [int] NULL,
			PMProductName [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,	
			SalesTarget [decimal](18, 6) NULL Default 0,	
			Achievement	[decimal](18, 6) NULL Default 0,
			BillsCut [decimal](18, 6) NULL Default 0,
			LinesCut [decimal](18, 6) NULL Default 0,
			ValidFromDate  [datetime] NULL,
			ValidToDate  [datetime] NULL)

		Insert Into @TmpAbstract
		select * from FN_GetPMAbstractForView()

		Declare @SalesmanID as int
		Declare @PMProductID as int
		Declare @Group_ID as Nvarchar(50)
		Declare @PMProductName as Nvarchar(255)
		Declare @SQL as Nvarchar(Max)

		Declare @TmpDetail as Table (
		Product_Code [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Product_Name [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CategoryID [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		LevelofProduct [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

		Declare @TempPMCategoryList as Table (  
		Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,   
		Product_Name Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
		CategoryID Nvarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,  
		LevelofProduct Nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)  
		
		Declare  @ViewItems as Table (Item_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
		Item_Name  Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
		Item_Description Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

		Insert Into @ViewItems (Item_Code,Item_Name,Item_Description) Select Distinct Item_Code,Item_Name,Item_Description From V_Item_Master
		
		Declare @cluParamID Cursor 
		Set @cluParamID = Cursor for
		Select Distinct PMProductID,SalesmanID,Group_ID,PMProductName from @TmpAbstract
		Open @cluParamID
		Fetch Next from @cluParamID into @PMProductID,@SalesmanID,@Group_ID,@PMProductName
		While @@fetch_status =0
			Begin	

				Delete From @TempPMCategoryList

				Insert Into @TempPMCategoryList (Product_Code,CategoryID,LevelofProduct)  
				Select (Case When PMF.ProdCat_Code = 'All' Then 'Overall' Else PMF.ProdCat_Code End),Null,PMF.ProdCat_Level From tbl_mERP_PMParamFocus PMF Where PMF.ParamID = @PMProductID And Isnull(PMF.ProdCat_Code,'') <> ''

				Update @TempPMCategoryList set CategoryID = 'Overall' Where Product_Code = 'Overall'

				Update T set T.CategoryID = IC.CategoryID From @TempPMCategoryList T, ItemCategories IC
				Where Isnull(T.CategoryID,'') = '' and T.Product_Code = IC.Category_Name

				Update T set T.CategoryID = I.Product_Code From @TempPMCategoryList T, Items I
				Where Isnull(T.CategoryID,'') = '' and T.Product_Code = I.Product_Code
				
				Insert Into @TmpDetail(Product_Code,Product_Name,CategoryID,LevelofProduct)
				select * from @TempPMCategoryList
				
				Insert into @TmpView (SalesmanID,Group_ID,PMProductID,[Level],Product_Code,Product_Name)
				Select @SalesmanID,@Group_ID,@PMProductID,LevelofProduct,CategoryID,Product_Code From @TmpDetail

				Update T set T.Product_Name = (Case When Isnull(IC.Description,'') <> '' Then IC.Description Else IC.Category_Name End) 
				From @TmpView T, ItemCategories IC
				Where T.Product_Code = IC.CategoryID and T.Product_Name <> 'Overall' And T.Level <> 5

				Update T set T.Product_Name = (Case When Isnull(I.Item_Description,'') <> '' Then I.Item_Description Else I.Item_Name End) 
				From @TmpView T, @ViewItems I
				Where T.Product_Code = I.Item_Code and T.Product_Name <> 'Overall' And T.Level = 5
				Delete From @TmpView Where Level = 5 and Product_Code Not In (select Distinct Item_Code from @ViewItems)

				Delete From @TmpDetail
				Fetch Next from @cluParamID into @PMProductID,@SalesmanID,@Group_ID,@PMProductName
			End
		Close @cluParamID
		Deallocate @cluParamID
		Delete From @ViewItems
	END
	Return

End
