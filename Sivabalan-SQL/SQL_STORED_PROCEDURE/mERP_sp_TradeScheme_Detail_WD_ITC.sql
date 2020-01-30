CREATE PROCEDURE mERP_sp_TradeScheme_Detail_WD_ITC
(@Code nVarChar(255),
@CategoryGroup nVarChar(2550),@ProductHierarchy nVarchar(510),
@Category nVarchar(2550),@Channels nVarChar(2550),
@SalesMan nVarChar(2550),@Beat nVarChar(2550),
@Customers nVarChar(2550),@ReportLevel nVarChar(50),
@UOM nVarChar(10),
@FromDate DateTime,@ToDate DateTime
)
AS
BEGIN
	Declare @CatID Int
	Declare @CatName nVarChar(255)
	Declare @SqlStat nVarChar(4000)

	Declare @DivCatList nVarChar(4000)
	Declare @DivName nVarChar(255)
	Declare @InvDispOption int

	Declare @Delimeter nVarchar(1)
	Set @Delimeter = Char(15)

	Create Table #TempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)  
	exec sp_CatLevelwise_ItemSorting

	Create Table #TempCategory     (CategoryID Int, Status Int)
	Create Table #TempSelectedCats (CatID int , CatName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Create Table #TempDivCats      (DivCat Int,DivCatName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Create Table #TempSelCatsLeaf  (SelCat int, SelCatName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,DivCat int, DivCatName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,LeafCat int)
	Create Table #TempChannels     (ChannelType int)
	Create Table #TempSalesMans    (SalesManID int)
	Create Table #TempBeats        (BeatID int)
	Create Table #TempCust         (CustomerID nVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS)

	

	If @ReportLevel <> 'Category Wise' And @ReportLevel <> 'Customer Type wise' And @ReportLevel <> 'DS wise' And @ReportLevel <> 'Beat wise' And @ReportLevel <> 'Customer wise'
		Set @ReportLevel = 'Category Wise'


	If @UOM <> 'Base UOM' And @UOM <> 'UOM1' And @UOM <> 'UOM2'
		Set @UOM = 'UOM2'

	If @ProductHierarchy = N'%' Or @ProductHierarchy = 'Division'
		Set @ProductHierarchy = (select Distinct HierarchyName from ItemHierarchy where HierarchyID = 2)

	Exec Sp_GetCGLeafCategories_ITC @CategoryGroup,@ProductHierarchy,@CATEGORY 

	Insert Into #TempSelCatsLeaf (LeafCat) Select Distinct CategoryID From #TempCategory

	If @Category = '%'
		Insert into #TempSelectedCats Select CategoryID,Category_Name from ItemCategories
		Where [Level] = (Select HierarchyID From ItemHierarchy Where HierarchyName = @ProductHierarchy)
	Else
		Insert into #TempSelectedCats Select CategoryID,Category_Name from ItemCategories
		Where Category_Name In (select * from dbo.sp_SplitIn2Rows(@Category,@Delimeter))

	Declare SelCatLeafCat Cursor For Select CatID,CatName from #TempSelectedCats
	Open SelCatLeafCat
	Fetch From SelCatLeafCat Into @CatID,@CatName
		While @@Fetch_Status = 0 
			Begin
				Delete from #TempCategory
				Exec GetLeafCategories @ProductHierarchy, @CatName
				Update #TempSelCatsLeaf Set SelCat = @CatID ,SelCatName = @CatName
				Where LeafCat in (Select CategoryID from #TempCategory)
				Fetch Next From SelCatLeafCat Into @CatID,@CatName
			End
	Close SelCatLeafCat
	Deallocate SelCatLeafCat

	Set @DivCatList = N''
	Set @DivName = (select Distinct HierarchyName from ItemHierarchy where HierarchyID = 2)
	Declare DivCategory Cursor Keyset For 
	Select CatID From dbo.fn_GetCatFromCatGroup_ITC(@CategoryGroup,@DivName,@Delimeter)
	Open DivCategory
	Fetch From DivCategory into @CatID
	While @@FETCH_STATUS = 0                                
	Begin     
		Set @DivCatList = @DivCatList + (Select Category_Name from ItemCategories Where CategoryID = @CatID) + char(15)
		Fetch Next From DivCategory Into @CatID        
	End   
	Close DivCategory
	DeAllocate DivCategory
	Set @DivCatList = Left(@DivCatList,Len(@DivCatList)-1)

	Insert into #TempDivCats Select CategoryID,Category_Name from ItemCategories
	Where Category_Name In (select * from dbo.sp_SplitIn2Rows(@DivCatList,@Delimeter))

	Declare DivCatLeafCat Cursor For Select DivCat,DivCatName from #TempDivCats
	Open DivCatLeafCat
	Fetch From DivCatLeafCat Into @CatID,@CatName
	While @@Fetch_Status = 0 
	Begin
		Delete from #TempCategory
		Exec GetLeafCategories @DivName, @CatName
		Update #TempSelCatsLeaf Set DivCat = @CatID ,DivCatName = @CatName
		Where LeafCat in (Select CategoryID from #TempCategory)
		Fetch Next From DivCatLeafCat Into @CatID,@CatName
	End
	Close DivCatLeafCat
	Deallocate DivCatLeafCat

	If @Channels = '%'
		Insert Into #TempChannels
		Select Distinct ChannelType from Customer_Channel
	Else
		Insert Into #TempChannels
		Select Distinct ChannelType from Customer_Channel
		Where ChannelDesc In (Select * from  Dbo.sp_SplitIn2Rows(@Channels,@Delimeter))

	If @SalesMan = '%'
		Insert Into #TempSalesMans
		Select Distinct SalesManID From SalesMan              
	Else              
		Insert Into #TempSalesMans
		Select Distinct SalesManId From SalesMan 
		Where SalesMan_Name In (Select * From Dbo.sp_SplitIn2Rows(@SalesMan,@Delimeter))
	              
	If @Beat = '%'
		Insert Into #TempBeats
		Select Distinct BeatId From Beat              
	Else              
		Insert Into #TempBeats
		Select Distinct BeatId From Beat Where Description In ( Select * From Dbo.sp_SplitIn2Rows(@Beat,@Delimeter))
	        
	If @Customers = '%'
		Insert Into #TempCust
		Select Distinct CustomerID from Customer
	Else
		Insert Into #TempCust
		Select Distinct CustomerID from Customer
		Where Company_Name In (Select * from Dbo.sp_SplitIn2Rows(@Customers,@Delimeter))

	Create Table #TempSale
	( 
		SelCat Int,
		SelCatName nVarChar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,
		DivCat int,
		DivCatName nVarChar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,
		CatID int,
		Channel int,SalesManID int,Beat int,
		CustomerID nVarChar(30)COLLATE SQL_Latin1_General_CP1_CI_AS,    	
		ItemCode NVarChar(30)COLLATE SQL_Latin1_General_CP1_CI_AS,
		UOM int,UOM1 int,UOM2 int, 
		Serial nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
		TotQty Decimal(18,6),
		NetValue Decimal(18,6),
		ANetValue Decimal(18,6),
		ADisc Decimal(18,6),
	)

	If @ReportLevel = 'Customer Type wise'
		Insert Into #TempSale
			(SelCat,SelCatName,DivCat,DivCatName,CatID,Channel,SalesManID,Beat,CustomerID,
			ItemCode,UOM,UOM1,UOM2,Serial,
			TotQty,NetValue,
			ANetValue,ADisc)
		Select
			Cat.SelCat,
			Cat.SelCatName,
			Max(Cat.DivCat),Max(Cat.DivCatName),
			Cat.LeafCat,
			C.ChannelType,
			IA.SalesManID,
			IA.BeatID,
			IA.CustomerID,
			I.Product_Code,
			Max(I.UOM),Max(I.UOM1),Max(I.UOM2),
			cast(IDT.Serial as nVarchar(100)),
			Sum(IDT.Quantity) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),
			Max(IDT.Amount),
			(Case When Max(IA.AdditionalDiscount) > 0 Then (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) ) Else 0 End ),
			((((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.AdditionalDiscount)) / 100) )--,
		From    
			InvoiceAbstract IA, InvoiceDetail IDT, Items I, Customer C, #TempSelCatsLeaf Cat
		Where 
			IA.Status & 128 = 0
			And IA.InvoiceType in (1,3)
			And IA.InvoiceDate Between @FromDate And @ToDate
			And IA.SalesmanID In (Select SalesManID From #TempSalesMans)
			And IA.BeatID In (Select BeatID From #TempBeats)
			And IA.CustomerID In (Select CustomerID From #TempCust)
			And C.ChannelType = Cast(@Code as Int)
			And IDT.FlagWord = 0
			And IDT.SalePrice > 0
			And IA.InvoiceID = IDT.InvoiceID   
			And I.Product_Code = IDT.Product_Code
		  And I.CategoryID = Cat.LeafCat
		  And IA.CustomerID = C.CustomerID
		Group By
			Cat.SelCat, Cat.SelCatName, Cat.LeafCat, C.ChannelType, IA.SalesManID, IA.BeatID,
			IA.CustomerID,IDT.InvoiceID,IA.InvoiceType, I.Product_Code, 
			IDT.Serial
	Else If @ReportLevel = 'DS wise'
		Insert Into #TempSale
			(SelCat,SelCatName,DivCat,DivCatName,CatID,Channel,SalesManID,Beat,CustomerID,
			ItemCode,UOM,UOM1,UOM2,Serial,
			TotQty,NetValue,
			ANetValue,ADisc)
		Select
			Cat.SelCat,
			Cat.SelCatName,
			Max(Cat.DivCat),Max(Cat.DivCatName),
			Cat.LeafCat,
			C.ChannelType,
			IA.SalesManID,
			IA.BeatID,
			IA.CustomerID,
			I.Product_Code,
			Max(I.UOM),Max(I.UOM1),Max(I.UOM2),
			Cast(IDT.Serial as nVarchar(50)),
			Sum(IDT.Quantity) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),
			Max(IDT.Amount),
			(Case When Max(IA.AdditionalDiscount) > 0 Then (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) ) Else 0 End ),
			((((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.AdditionalDiscount)) / 100))
		From    
			InvoiceAbstract IA, InvoiceDetail IDT, Items I, Customer C, #TempSelCatsLeaf Cat
		Where 
			IA.Status & 128 = 0
			And IA.InvoiceType in (1,3)
			And IA.InvoiceDate Between @FromDate And @ToDate
			And IA.SalesmanID = Cast(@Code As Int)
			And IA.BeatID In (Select BeatID From #TempBeats)
		  And IA.CustomerID In (Select CustomerID From #TempCust)
			And C.ChannelType In (Select ChannelType From #TempChannels)
			And IDT.FlagWord = 0
			And IDT.SalePrice > 0
			And IA.InvoiceID = IDT.InvoiceID
			And I.Product_Code = IDT.Product_Code
		  And I.CategoryID = Cat.LeafCat
		  And IA.CustomerID = C.CustomerID
		Group By
			Cat.SelCat, Cat.SelCatName, Cat.LeafCat, C.ChannelType, IA.SalesManID, IA.BeatID, 
			IA.CustomerID,IDT.InvoiceID,IA.InvoiceType, I.Product_Code ,
			IDT.Serial
	Else If @ReportLevel = 'Beat wise'
		Insert Into #TempSale
			(SelCat,SelCatName,DivCat,DivCatName,CatID,Channel,SalesManID,Beat,CustomerID,
			ItemCode,UOM,UOM1,UOM2,Serial,
			TotQty,NetValue,
			ANetValue,ADisc)
		Select
			Cat.SelCat,
			Cat.SelCatName,
			Max(Cat.DivCat),Max(Cat.DivCatName),
			Cat.LeafCat,
			C.ChannelType,
			IA.SalesManID,
			IA.BeatID,
			IA.CustomerID,
			I.Product_Code,
			Max(I.UOM),Max(I.UOM1),Max(I.UOM2),
			IDT.Serial, 
			Sum(IDT.Quantity) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),
			Max(IDT.Amount),
			(Case When Max(IA.AdditionalDiscount) > 0 Then (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) ) Else 0 End ),
			((((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.AdditionalDiscount)) / 100))
		From    
			InvoiceAbstract IA, InvoiceDetail IDT, Items I, Customer C, #TempSelCatsLeaf Cat
		Where 
			IA.Status & 128 = 0
			And IA.InvoiceType in (1,3)
			And IA.InvoiceDate Between @FromDate And @ToDate
			And IA.SalesmanID In (Select SalesManID From #TempSalesMans)
			And IA.BeatID = Cast(@Code As Int)
		  And IA.CustomerID In (Select CustomerID From #TempCust)
			And C.ChannelType In (Select ChannelType From #TempChannels)
			And IDT.FlagWord = 0
			And IDT.SalePrice > 0
			And IA.InvoiceID = IDT.InvoiceID   
			And I.Product_Code = IDT.Product_Code
		  And I.CategoryID = Cat.LeafCat
		  And IA.CustomerID = C.CustomerID
		Group By
			Cat.SelCat, Cat.SelCatName, Cat.LeafCat, C.ChannelType, IA.SalesManID, IA.BeatID, 
			IA.CustomerID,IDT.InvoiceID,IA.InvoiceType, I.Product_Code, 
			IDT.Serial
	Else If @ReportLevel = 'Customer wise'
		Insert Into #TempSale
			(SelCat,SelCatName,DivCat,DivCatName,CatID,Channel,SalesManID,Beat,CustomerID,
			ItemCode,UOM,UOM1,UOM2,Serial,
			TotQty,NetValue,
			ANetValue,ADisc)
		Select
			Cat.SelCat,
			Cat.SelCatName,
			Max(Cat.DivCat),Max(Cat.DivCatName),
			Cat.LeafCat,
			C.ChannelType,
			IA.SalesManID,
			IA.BeatID,
			IA.CustomerID,
			I.Product_Code,
			Max(I.UOM),Max(I.UOM1),Max(I.UOM2),
			Cast(IDT.Serial as nVarchar(50)),
			Sum(IDT.Quantity) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),
			Max(IDT.Amount),
			(Case When Max(IA.AdditionalDiscount) > 0 Then (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) ) Else 0 End ),
			((((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.AdditionalDiscount)) / 100) ) --,
		From    
			InvoiceAbstract IA, InvoiceDetail IDT, Items I, Customer C, #TempSelCatsLeaf Cat
		Where 
			IA.Status & 128 = 0
			And IA.InvoiceType in (1,3)		
			And IA.InvoiceDate Between @FromDate And @ToDate
			And IA.SalesmanID In (Select SalesManID From #TempSalesMans)
			And IA.BeatID In (Select BeatID From #TempBeats)
			And IA.CustomerID = @Code
			And C.ChannelType In (Select ChannelType From #TempChannels)
			And IDT.FlagWord = 0
			And IDT.SalePrice > 0
			And IA.InvoiceID = IDT.InvoiceID   
			And I.Product_Code = IDT.Product_Code
		  And I.CategoryID = Cat.LeafCat
		  And IA.CustomerID = C.CustomerID
		Group By
			Cat.SelCat, Cat.SelCatName, Cat.LeafCat, C.ChannelType, IA.SalesManID, IA.BeatID, 
			IA.CustomerID,IDT.InvoiceID,IA.InvoiceType, I.Product_Code, 
			IDT.Serial
	Else --'Category Wise'
		Insert Into #TempSale
			(SelCat,SelCatName,DivCat,DivCatName,CatID,Channel,SalesManID,Beat,CustomerID,
			ItemCode,UOM,UOM1,UOM2,Serial,
			TotQty,NetValue,
			ANetValue,ADisc)
		Select
			Cat.SelCat,
			Cat.SelCatName,
			Max(Cat.DivCat),Max(Cat.DivCatName),
			Cat.LeafCat,
			C.ChannelType,
			IA.SalesManID,
			IA.BeatID,
			IA.CustomerID,
			I.Product_Code,
			Max(I.UOM),Max(I.UOM1),Max(I.UOM2),
			Cast(IDT.Serial as nVarchar(50)),
			Sum(IDT.Quantity) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),
			Max(IDT.Amount),
			(Case When Max(IA.AdditionalDiscount) > 0 Then (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) ) Else 0 End ),
			((((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.AdditionalDiscount)) / 100) ) --,
			From    
				InvoiceAbstract IA, InvoiceDetail IDT, Items I, Customer C, #TempSelCatsLeaf Cat
			Where 
				IA.Status & 128 = 0
				And IA.InvoiceType in (1,3)
				And IA.InvoiceDate Between @FromDate And @ToDate
				And IA.SalesmanID In (Select SalesManID From #TempSalesMans)
				And IA.BeatID In (Select BeatID From #TempBeats)
				And IA.CustomerID In (Select CustomerID From #TempCust)
				And C.ChannelType In (Select ChannelType From #TempChannels)
				And Cat.SelCat = Cast(@Code As Int)
				And IDT.FlagWord = 0
				And IDT.SalePrice > 0
				And IA.InvoiceID = IDT.InvoiceID
				And I.Product_Code = IDT.Product_Code
				And I.CategoryID = Cat.LeafCat 
				And IA.CustomerID = C.CustomerID
			Group By
				Cat.SelCat, Cat.SelCatName,Cat.LeafCat, C.ChannelType, IA.SalesManID, IA.BeatID,   	
				IA.CustomerID,IDT.InvoiceID,IA.InvoiceType, I.Product_Code, 
				IDT.Serial
	   

	Declare @Prod_Code as nvarchar(100)
	Declare @SCatID int
	Declare @SDivCat int
	Declare @SDivCatName nvarchar(510)
	Declare @SUOM int
	Declare @SUOM1 int
	Declare @SUOM2 int
	Declare @Serial int
	Declare @TotQty decimal(18,6)
	Declare @NetValue decimal(18,6)
	Declare @ItemCode nvarchar(50)

	Declare @RowID int


	Create table #TmpResult
	(CatID int,
	 DivCat int,
	 DivCatName	nVarChar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,
	 ItemCode nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
	 UOM int,
	 UOM1 int,
	 UOM2 int,
	 Serial int,
	 TotQty decimal(18,6),
	 NetValue decimal(18,6),
	 DiscSalValue decimal(18,6),
	 ANetValue Decimal(18,6),
	 ADisc Decimal(18,6)
	 )


	 Create table #TmpFinal
	(CatID int,
	 DivCat int,
	 DivCatName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	 ItemCode nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	 UOM int,
	 UOM1 int,
	 UOM2 int, 
	 TotQty decimal(18,6),
	 NetValue decimal(18,6),
	 ANetValue Decimal(18,6),
	 ADisc Decimal(18,6)
	 )
	 
	/*To Group the Rows */
	Select SelCat, SelCatName,DivCat,DivCatName,CatID,Channel,SalesManID, Beat, CustomerID, ItemCode, UOM, UOM1, UOM2, Min(Serial) 'Serial', 
	   Sum(TotQty) 'TotQty', Sum(NetValue) 'NetValue', Sum(ANetValue)'ANetValue',Sum(ADisc)'ADisc'
	Into #TempSale2 From #TempSale
	Group By SelCat, SelCatName,DivCat,DivCatName,CatID,Channel,SalesManID, Beat, CustomerID, ItemCode, UOM, UOM1, UOM2

	Select "Code" = Max(CatID),
	"Division" = Max(DivCatName),
	"Item Name" = Max(I.ProductName),
	"UOM" = Max(UOM.Description),
	"Total Volume" = Sum(TotQty),
	"Total Sales Value" = Sum(NetValue),
--	"Trade Discount %" = Case When Abs(Sum(ANetValue)) > 0 Then Abs((Sum(ADisc)) / AbS(Sum(ANetValue))) * 100 Else 0 End,
	"Trade Discount" = Sum(ADisc)
	from  #TempSale2 TS,Items I,UOM,#TempCategory1 ISort
	Where TS.ItemCode = I.Product_Code
	And I.CategoryID = ISort.CategoryID
	And UOM.UOM = (Case @UOM when 'UOM2' Then TS.UOM2 When 'UOM1' Then TS.UOM1 Else TS.UOM End)
	Group By I.Product_Code,ISort.IDS
	Order By ISort.IDS			

	Drop Table #TempCategory
	Drop Table #TempSelectedCats
	Drop Table #TempDivCats
	Drop Table #TempSelCatsLeaf
	Drop Table #TempChannels
	Drop Table #TempSalesMans
	Drop Table #TempBeats
	Drop Table #TempCust
	Drop Table #TempSale
	Drop Table #TempSale2
	Drop Table #TempCategory1
END
