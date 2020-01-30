CREATE PROCEDURE sp_DetailedSchemes_Detail_WD_ITC
(@Code nVarChar(255),
@CategoryGroup nVarChar(2550),@ProductHierarchy nVarchar(510),
@Category nVarchar(2550),@Channels nVarChar(2550),
@SalesMan nVarChar(2550),@Beat nVarChar(2550),
@Customers nVarChar(2550),@ReportLevel nVarChar(50),
@DiscType nVarchar(50),@UOM nVarChar(10),
@FromDate DateTime,@ToDate DateTime,
@Claimable nVarChar(5),@FreeValAt nVarchar(5)
)
AS
Declare @CatID Int
Declare @CatName nVarChar(255)
Declare @SchID Int
Declare @SchName nVarChar(255)
Declare @SchValue Decimal(18,6)
Declare @SqlStat nVarChar(4000)
Declare @SchList nVarChar(4000)
Declare @SqlSel nVarChar(4000)

Declare @DivCatList nVarChar(4000)
Declare @DivName nVarChar(255)
Declare @SchDispOption int
Declare @SplSchDispOption int
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

If @ReportLevel <> 'Category Wise' And @ReportLevel <> 'Channel Wise' And @ReportLevel <> 'DS wise' And @ReportLevel <> 'Beat wise' And @ReportLevel <> 'Customer wise'
Set @ReportLevel = 'Category Wise'

If @DiscType <> 'Scheme' And @DiscType <> 'Product Discount' And @DiscType <> 'Addl. Discount' And @DiscType <> 'Trade Discount' And @DiscType <> 'Only Free Item' And @DiscType <> 'All without Free Item'
Set @DiscType = 'All without Free Item'

If @UOM <> 'Base UOM' And @UOM <> 'UOM1' And @UOM <> 'UOM2'
Set @UOM = 'UOM2'

If @Claimable <> 'Yes' And @Claimable <> 'No' And @Claimable <> 'Both'
Set @Claimable = 'Both'

If @FreeValAt <> 'PTS' And @FreeValAt <> 'PTR'
Set @FreeValAt = 'PTS'

If @ProductHierarchy = N'%' Or @ProductHierarchy = 'Division'
Set @ProductHierarchy = (select Distinct HierarchyName from ItemHierarchy where HierarchyID = 2)

Exec Sp_GetCGLeafCat_ITC @CategoryGroup,@ProductHierarchy,@CATEGORY 

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
Select CatID From dbo.fn_GetCatFrmCG_ITC(@CategoryGroup,@DivName,@Delimeter)
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

-- Select * from #TempCategory
-- Select * from #TempSelectedCats
-- Select * from #TempSelCatsLeaf
-- Select * from #TempChannels
-- Select * from #TempSalesMans
-- Select * from #TempBeats
-- Select * from #TempCust

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
	Serial int,
	Free Decimal(18,6),
	FreeValue Decimal(18,6),
	SchItem_Code nVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
	SchQty Decimal(18,6),
	SchUOM int,
	SchValue Decimal(18,6),
	SplSchItem_Code nVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
	SplSchQty Decimal(18,6),
	SplSchUOM int,
	SPlSchValue Decimal(18,6),
	FreeSerial int,
	SplFlag Int,
	TotQty Decimal(18,6),
	NetValue Decimal(18,6),
	DiscSalValue Decimal(18,6),
	InvSchemeID Int,
	InvSchemeValue Decimal(18,6),
	SchemeID Int,
	SchemeValue Decimal(18,6),
	SplCatSchemeID Int,
	SplCatSchemeValue Decimal(18,6),
	PNetValue Decimal(18,6),
	PDisc Decimal(18,6),
	ANetValue Decimal(18,6),
	ADisc Decimal(18,6),
	TNetValue Decimal(18,6),
	TDisc Decimal(18,6)
)

if @DiscType = 'Only Free Item'
Begin
	If @ReportLevel = 'Channel Wise'
	Insert Into #TempSale
		(SelCat,SelCatName,DivCat,DivCatName,CatID,Channel,SalesManID,Beat,CustomerID,
		ItemCode,UOM,UOM1,UOM2,Serial,Free,FreeValue)
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
		( Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),
		((Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) * (Case @FreeValAt When 'PTR' Then Max(IDT.PTR) Else Max(IDT.PTS) End) )
		From    
			InvoiceAbstract IA, InvoiceDetail IDT, Items I, Customer C, #TempSelCatsLeaf Cat
		Where 
			IA.Status & 128 = 0
			And IA.InvoiceType in (1,3,4)
			And IA.InvoiceDate Between @FromDate And @ToDate
			And IA.SalesmanID In (Select SalesManID From #TempSalesMans)
			And IA.BeatID In (Select BeatID From #TempBeats)
		  And IA.CustomerID In (Select CustomerID From #TempCust)
			And C.ChannelType = Cast(@Code as Int)
			And IDT.FlagWord = 0
			And IDT.SalePrice = 0
			And IA.InvoiceID = IDT.InvoiceID   
			And I.Product_Code = IDT.Product_Code
		  And I.CategoryID = Cat.LeafCat
		  And IA.CustomerID = C.CustomerID
	--		And C.ChannelType In (Select ChannelType From #TempChannels)
		Group By
			Cat.SelCat, Cat.SelCatName, Cat.LeafCat, C.ChannelType, IA.SalesManID, IA.BeatID, 
			IA.CustomerID,IDT.InvoiceID,IA.InvoiceType, I.Product_Code,IDT.Serial --,IA.SchemeID, IDT.SchemeID, IDT.SplCatSchemeID
	Else If @ReportLevel = 'DS wise'
	Insert Into #TempSale
		(SelCat,SelCatName,DivCat,DivCatName,CatID,Channel,SalesManID,Beat,CustomerID,
		ItemCode,UOM,UOM1,UOM2,Serial,Free,FreeValue)
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
		( Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),
		((Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else sum(IDT.Quantity) End) * (Case @FreeValAt When 'PTR' Then Max(IDT.PTR) Else Max(IDT.PTS) End) )
		From    
			InvoiceAbstract IA, InvoiceDetail IDT, Items I, Customer C, #TempSelCatsLeaf Cat
		Where 
			IA.Status & 128 = 0
			And IA.InvoiceType in (1,3,4)
			And IA.InvoiceDate Between @FromDate And @ToDate
			And IA.SalesmanID = Cast(@Code As Int)
			And IA.BeatID In (Select BeatID From #TempBeats)
		  And IA.CustomerID In (Select CustomerID From #TempCust)
			And C.ChannelType In (Select ChannelType From #TempChannels)
			And IDT.FlagWord = 0
			And IDT.SalePrice = 0
			And IA.InvoiceID = IDT.InvoiceID
			And I.Product_Code = IDT.Product_Code
		  And I.CategoryID = Cat.LeafCat
		  And IA.CustomerID = C.CustomerID
	--		And IA.SalesmanID In (Select SalesManID From #TempSalesMans)
		Group By
			Cat.SelCat, Cat.SelCatName, Cat.LeafCat, C.ChannelType, IA.SalesManID, IA.BeatID, 
			IA.CustomerID,IDT.InvoiceID,IA.InvoiceType, I.Product_Code,IDT.Serial -- ,IA.SchemeID, IDT.SchemeID, IDT.SplCatSchemeID
	Else If @ReportLevel = 'Beat wise'
	Insert Into #TempSale
		(SelCat,SelCatName,DivCat,DivCatName,CatID,Channel,SalesManID,Beat,CustomerID,
		ItemCode,UOM,UOM1,UOM2,Serial,Free,FreeValue)
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
		( Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),
		((Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) * (Case @FreeValAt When 'PTR' Then Max(IDT.PTR) Else Max(IDT.PTS) End) )
		From    
			InvoiceAbstract IA, InvoiceDetail IDT, Items I, Customer C, #TempSelCatsLeaf Cat
		Where 
			IA.Status & 128 = 0
			And IA.InvoiceType in (1,3,4)
			And IA.InvoiceDate Between @FromDate And @ToDate
			And IA.SalesmanID In (Select SalesManID From #TempSalesMans)
	--		And IA.BeatID In (Select BeatID From #TempBeats)
			And IA.BeatID = Cast(@Code As Int)
		  And IA.CustomerID In (Select CustomerID From #TempCust)
			And C.ChannelType In (Select ChannelType From #TempChannels)
			And IDT.FlagWord = 0
			And IDT.SalePrice = 0
			And IA.InvoiceID = IDT.InvoiceID   
			And I.Product_Code = IDT.Product_Code
		  And I.CategoryID = Cat.LeafCat
		  And IA.CustomerID = C.CustomerID
		Group By
			Cat.SelCat, Cat.SelCatName, Cat.LeafCat, C.ChannelType, IA.SalesManID, IA.BeatID, 
			IA.CustomerID,IDT.InvoiceID,IA.InvoiceType, I.Product_Code,IDT.Serial -- ,IA.SchemeID, IDT.SchemeID, IDT.SplCatSchemeID
	Else If @ReportLevel = 'Customer wise'
	Insert Into #TempSale
		(SelCat,SelCatName,DivCat,DivCatName,CatID,Channel,SalesManID,Beat,CustomerID,
		ItemCode,UOM,UOM1,UOM2,Serial,Free,FreeValue)
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
		( Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),
		((Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) * (Case @FreeValAt When 'PTR' Then Max(IDT.PTR) Else Max(IDT.PTS) End) )
		From    
			InvoiceAbstract IA, InvoiceDetail IDT, Items I, Customer C, #TempSelCatsLeaf Cat
		Where 
			IA.Status & 128 = 0
			And IA.InvoiceType in (1,3,4)		
			And IA.InvoiceDate Between @FromDate And @ToDate
			And IA.SalesmanID In (Select SalesManID From #TempSalesMans)
			And IA.BeatID In (Select BeatID From #TempBeats)
	--	  And IA.CustomerID In (Select CustomerID From #TempCust)
			And IA.CustomerID = @Code
			And C.ChannelType In (Select ChannelType From #TempChannels)
			And IDT.FlagWord = 0
			And IDT.SalePrice = 0
			And IA.InvoiceID = IDT.InvoiceID   
			And I.Product_Code = IDT.Product_Code
		  And I.CategoryID = Cat.LeafCat
		  And IA.CustomerID = C.CustomerID
		Group By
			Cat.SelCat, Cat.SelCatName, Cat.LeafCat, C.ChannelType, IA.SalesManID, IA.BeatID, 
			IA.CustomerID,IDT.InvoiceID,IA.InvoiceType, I.Product_Code,IDT.Serial -- ,IA.SchemeID, IDT.SchemeID, IDT.SplCatSchemeID
	Else --'Category Wise'
		Insert Into #TempSale
			(SelCat,SelCatName,DivCat,DivCatName,CatID,Channel,SalesManID,Beat,CustomerID,
			ItemCode,UOM,UOM1,UOM2,Serial,Free,FreeValue)
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
			( Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),
			((Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) * (Case @FreeValAt When 'PTR' Then Max(IDT.PTR) Else Max(IDT.PTS) End) )
			From    
				InvoiceAbstract IA, InvoiceDetail IDT, Items I, Customer C, #TempSelCatsLeaf Cat
			Where 
				IA.Status & 128 = 0
				And IA.InvoiceType in (1,3,4)
				And IA.InvoiceDate Between @FromDate And @ToDate
				And IA.SalesmanID In (Select SalesManID From #TempSalesMans)
				And IA.BeatID In (Select BeatID From #TempBeats)
			  And IA.CustomerID In (Select CustomerID From #TempCust)
				And C.ChannelType In (Select ChannelType From #TempChannels)
				And Cat.SelCat = Cast(@Code As Int)
				And IDT.FlagWord = 0
				And IDT.SalePrice = 0
				And IA.InvoiceID = IDT.InvoiceID
				And I.Product_Code = IDT.Product_Code
			  And I.CategoryID = Cat.LeafCat
			  And IA.CustomerID = C.CustomerID
			Group By
				Cat.SelCat, Cat.SelCatName, Cat.LeafCat, C.ChannelType, IA.SalesManID, IA.BeatID, 
				IA.CustomerID,IDT.InvoiceID,IA.InvoiceType, I.Product_Code,IDT.Serial -- ,IA.SchemeID, IDT.SchemeID, IDT.SplCatSchemeID
	End
Else
Begin
	If @ReportLevel = 'Channel Wise'
		Insert Into #TempSale
			(SelCat,SelCatName,DivCat,DivCatName,CatID,Channel,SalesManID,Beat,CustomerID,
			ItemCode,UOM,UOM1,UOM2,Serial,SchItem_Code,SchQty,SchUOM,SchValue,SplSchItem_Code,SplSchQty,SplSchUOM,SplSchValue,FreeSerial,
			TotQty,NetValue,DiscSalValue,	InvSchemeID, InvSchemeValue, SchemeID, SchemeValue, SplCatSchemeID, SplCatSchemeValue,
			PNetValue,PDisc,ANetValue,ADisc,TNetValue,TDisc)
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
			(Select Max(IsNull(Product_Code,'')) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.FreeSerial)) > 0 Then Left(Max(IDT.FreeSerial),CharIndex(',',Max(IDT.FreeSerial))-1) Else Max(IDT.FreeSerial) End As Int)),
			(Select Sum(IsNull(Quantity,0)) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.FreeSerial)) > 0 Then Left(Max(IDT.FreeSerial),CharIndex(',',Max(IDT.FreeSerial))-1) Else Max(IDT.FreeSerial) End As Int)),
			(Select IsNull(UOM2,0) from Items Where Product_Code = (Select Max(IsNull(Product_Code,'')) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.FreeSerial)) > 0 Then Left(Max(IDT.FreeSerial),CharIndex(',',Max(IDT.FreeSerial))-1) Else Max(IDT.FreeSerial) End As Int))),
			(Select Sum(IsNull(Quantity,0)) * Max(Case @FreeValAt When 'PTR' Then PTR Else PTS End) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.FreeSerial)) > 0 Then Left(Max(IDT.FreeSerial),CharIndex(',',Max(IDT.FreeSerial))-1) Else Max(IDT.FreeSerial) End As Int)),
			(Select Max(IsNull(Product_Code,'')) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)),
			(Select Sum(IsNull(Quantity,0)) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)),
			(Select IsNull(UOM2,0) from Items Where Product_Code = (Select Max(IsNull(Product_Code,'')) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int))),
			(Select Sum(IsNull(Quantity,0)) * Max(Case @FreeValAt When 'PTR' Then PTR Else PTS End) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)),
			(Select Min(Cast((Case When CharIndex(',',SplCatSerial) > 0 Then Left(SplCatSerial,CharIndex(',',SplCatSerial)-1) Else SplCatSerial End) As Int))  from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)),
			(Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),
			(Case IA.InvoiceType When 4 Then -Max(IDT.Amount) Else Max(IDT.Amount) End),
			(Case When (Max(IA.DiscountValue) <> 0 Or Max(IA.AddlDiscountValue) <> 0 or Max(IDT.DiscountValue) <> 0 Or Max(IDT.SchemeID) <> 0 Or Max(IDT.SplCatSchemeID) <> 0) Then (Case IA.InvoiceType When 4 Then -Max(IDT.Amount) Else Max(IDT.Amount) End) Else 0 End),
			(Select IsNull(SchemeID,0) From Schemes where SchemeID = IA.SchemeID And Max(IA.SchemeDiscountPercentage) > 0 And SecondaryScheme & (Case @Claimable When 'Both' Then 0 Else 1 End) = (Case @Claimable When 'Yes' Then 1 Else 0 End)),
			(Case When IA.SchemeID > 0 Then ((Case IA.InvoiceType When 4 Then -1 Else 1 End) * ((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.SchemeDiscountPercentage)) / 100) Else 0 End),
			(Select IsNull(SchemeID,0) From Schemes where SchemeID = Max(IDT.SchemeID) And SecondaryScheme & (Case @Claimable When 'Both' Then 0 Else 1 End) = (Case @Claimable When 'Yes' Then 1 Else 0 End)),
			(Case When Max(IDT.SchemeID) >0 Then (Case IA.InvoiceType When 4 Then -Max(IDT.SchemeDiscAmount) Else Max(IDT.SchemeDiscAmount) End) Else 0 End),
			(Select IsNull(SchemeID,0) From Schemes where SchemeID = Max(IDT.SplCatSchemeID) And SecondaryScheme & (Case @Claimable When 'Both' Then 0 Else 1 End) = (Case @Claimable When 'Yes' Then 1 Else 0 End)),
			(Case When Max(IDT.SplCatSchemeID) > 0 then (Case IA.InvoiceType When 4 Then -Max(IDT.SplCatDiscAmount) Else Max(IDT.SplCatDiscAmount) End) Else 0 End),
		  (Case When (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) >0 Then ((Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) * Max(IDT.SalePrice))Else 0 End ),
		  (((Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) * Max(IDT.SalePrice)) * (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) /100),
			(Case When Max(IA.AdditionalDiscount) > 0 Then (Case IA.InvoiceType When 4 Then -1 Else 1 End) * (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) ) Else 0 End ),
			( (Case IA.InvoiceType When 4 Then -1 Else 1 End) * (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.AdditionalDiscount)) / 100) ),
			(Case When (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) > 0 Then (Case IA.InvoiceType When 4 Then -1 Else 1 End) * (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue))) Else 0 End),
			( (Case IA.InvoiceType When 4 Then -1 Else 1 End) * (((Sum(IDT.Quantity) * Max(IDT.SalePrice)-Max(IDT.DiscountValue))) * (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) / 100))
		From    
			InvoiceAbstract IA, InvoiceDetail IDT, Items I, Customer C, #TempSelCatsLeaf Cat
		Where 
			IA.Status & 128 = 0
			And IA.InvoiceType in (1,3,4)
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
	--		And C.ChannelType In (Select ChannelType From #TempChannels)
		Group By
			Cat.SelCat, Cat.SelCatName, Cat.LeafCat, C.ChannelType, IA.SalesManID, IA.BeatID, 
			IA.CustomerID,IDT.InvoiceID,IA.InvoiceType, I.Product_Code ,IA.SchemeID,IDT.Serial --, IDT.SchemeID, IDT.SplCatSchemeID
	Else If @ReportLevel = 'DS wise'
		Insert Into #TempSale
			(SelCat,SelCatName,DivCat,DivCatName,CatID,Channel,SalesManID,Beat,CustomerID,
			ItemCode,UOM,UOM1,UOM2,Serial,SchItem_Code,SchQty,SchUOM,SchValue,SplSchItem_Code,SplSchQty,SplSchUOM,SplSchValue,FreeSerial,
			TotQty,NetValue,DiscSalValue,	InvSchemeID, InvSchemeValue, SchemeID, SchemeValue, SplCatSchemeID, SplCatSchemeValue,
			PNetValue,PDisc,ANetValue,ADisc,TNetValue,TDisc)
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
			(Select Max(IsNull(Product_Code,'')) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.FreeSerial)) > 0 Then Left(Max(IDT.FreeSerial),CharIndex(',',Max(IDT.FreeSerial))-1) Else Max(IDT.FreeSerial) End As Int)),
			(Select Sum(IsNull(Quantity,0)) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.FreeSerial)) > 0 Then Left(Max(IDT.FreeSerial),CharIndex(',',Max(IDT.FreeSerial))-1) Else Max(IDT.FreeSerial) End As Int)),
			(Select IsNull(UOM2,0) from Items Where Product_Code = (Select Max(IsNull(Product_Code,'')) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.FreeSerial)) > 0 Then Left(Max(IDT.FreeSerial),CharIndex(',',Max(IDT.FreeSerial))-1) Else Max(IDT.FreeSerial) End As Int))),
			(Select Sum(IsNull(Quantity,0)) * Max(Case @FreeValAt When 'PTR' Then PTR Else PTS End) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.FreeSerial)) > 0 Then Left(Max(IDT.FreeSerial),CharIndex(',',Max(IDT.FreeSerial))-1) Else Max(IDT.FreeSerial) End As Int)),
			(Select Max(IsNull(Product_Code,'')) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)),
			(Select Sum(IsNull(Quantity,0)) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)),
			(Select IsNull(UOM2,0) from Items Where Product_Code = (Select Max(IsNull(Product_Code,'')) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int))),
			(Select Sum(IsNull(Quantity,0)) * Max(Case @FreeValAt When 'PTR' Then PTR Else PTS End) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)),
			(Select Min(Cast((Case When CharIndex(',',SplCatSerial) > 0 Then Left(SplCatSerial,CharIndex(',',SplCatSerial)-1) Else SplCatSerial End) As Int))  from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)),
			(Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),
			(Case IA.InvoiceType When 4 Then -Max(IDT.Amount) Else Max(IDT.Amount) End),
			(Case When (Max(IA.DiscountValue) <> 0 Or Max(IA.AddlDiscountValue) <> 0 or Max(IDT.DiscountValue) <> 0 Or Max(IDT.SchemeID) <> 0 Or Max(IDT.SplCatSchemeID) <> 0) Then (Case IA.InvoiceType When 4 Then -Max(IDT.Amount) Else Max(IDT.Amount) End) Else 0 End),
			(Select IsNull(SchemeID,0) From Schemes where SchemeID = IA.SchemeID And Max(IA.SchemeDiscountPercentage) > 0 And SecondaryScheme & (Case @Claimable When 'Both' Then 0 Else 1 End) = (Case @Claimable When 'Yes' Then 1 Else 0 End)),
			(Case When IA.SchemeID > 0 Then ((Case IA.InvoiceType When 4 Then -1 Else 1 End) * ((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.SchemeDiscountPercentage)) / 100) Else 0 End),
			(Select IsNull(SchemeID,0) From Schemes where SchemeID = Max(IDT.SchemeID) And SecondaryScheme & (Case @Claimable When 'Both' Then 0 Else 1 End) = (Case @Claimable When 'Yes' Then 1 Else 0 End)),
			(Case When Max(IDT.SchemeID) >0 Then (Case IA.InvoiceType When 4 Then -Max(IDT.SchemeDiscAmount) Else Max(IDT.SchemeDiscAmount) End) Else 0 End),
			(Select IsNull(SchemeID,0) From Schemes where SchemeID = Max(IDT.SplCatSchemeID) And SecondaryScheme & (Case @Claimable When 'Both' Then 0 Else 1 End) = (Case @Claimable When 'Yes' Then 1 Else 0 End)),
			(Case When Max(IDT.SplCatSchemeID) > 0 then (Case IA.InvoiceType When 4 Then -Max(IDT.SplCatDiscAmount) Else Max(IDT.SplCatDiscAmount) End) Else 0 End),
		  (Case When (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) >0 Then ((Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) * Max(IDT.SalePrice))Else 0 End ),
		  (((Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) * Max(IDT.SalePrice)) * (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) /100),
			(Case When Max(IA.AdditionalDiscount) > 0 Then (Case IA.InvoiceType When 4 Then -1 Else 1 End) * (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) ) Else 0 End ),
			( (Case IA.InvoiceType When 4 Then -1 Else 1 End) * (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.AdditionalDiscount)) / 100) ),
			(Case When (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) > 0 Then (Case IA.InvoiceType When 4 Then -1 Else 1 End) * (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue))) Else 0 End),
			( (Case IA.InvoiceType When 4 Then -1 Else 1 End) * (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) / 100))
		From    
			InvoiceAbstract IA, InvoiceDetail IDT, Items I, Customer C, #TempSelCatsLeaf Cat
		Where 
			IA.Status & 128 = 0
			And IA.InvoiceType in (1,3,4)
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
	--		And IA.SalesmanID In (Select SalesManID From #TempSalesMans)
		Group By
			Cat.SelCat, Cat.SelCatName, Cat.LeafCat, C.ChannelType, IA.SalesManID, IA.BeatID, 
			IA.CustomerID,IDT.InvoiceID,IA.InvoiceType, I.Product_Code ,IA.SchemeID,IDT.Serial --, IDT.SchemeID, IDT.SplCatSchemeID
	Else If @ReportLevel = 'Beat wise'
		Insert Into #TempSale
			(SelCat,SelCatName,DivCat,DivCatName,CatID,Channel,SalesManID,Beat,CustomerID,
			ItemCode,UOM,UOM1,UOM2,Serial,SchItem_Code,SchQty,SchUOM,SchValue,SplSchItem_Code,SplSchQty,SplSchUOM,SplSchValue,FreeSerial,
			TotQty,NetValue,DiscSalValue,	InvSchemeID, InvSchemeValue, SchemeID, SchemeValue, SplCatSchemeID, SplCatSchemeValue,
			PNetValue,PDisc,ANetValue,ADisc,TNetValue,TDisc)
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
			(Select Max(IsNull(Product_Code,'')) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.FreeSerial)) > 0 Then Left(Max(IDT.FreeSerial),CharIndex(',',Max(IDT.FreeSerial))-1) Else Max(IDT.FreeSerial) End As Int)),
			(Select Sum(IsNull(Quantity,0)) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.FreeSerial)) > 0 Then Left(Max(IDT.FreeSerial),CharIndex(',',Max(IDT.FreeSerial))-1) Else Max(IDT.FreeSerial) End As Int)),
			(Select IsNull(UOM2,0) from Items Where Product_Code = (Select Max(IsNull(Product_Code,'')) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.FreeSerial)) > 0 Then Left(Max(IDT.FreeSerial),CharIndex(',',Max(IDT.FreeSerial))-1) Else Max(IDT.FreeSerial) End As Int))),
			(Select Sum(IsNull(Quantity,0)) * Max(Case @FreeValAt When 'PTR' Then PTR Else PTS End) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.FreeSerial)) > 0 Then Left(Max(IDT.FreeSerial),CharIndex(',',Max(IDT.FreeSerial))-1) Else Max(IDT.FreeSerial) End As Int)),
			(Select Max(IsNull(Product_Code,'')) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)),
			(Select Sum(IsNull(Quantity,0)) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)),
			(Select IsNull(UOM2,0) from Items Where Product_Code = (Select Max(IsNull(Product_Code,'')) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int))),
			(Select Sum(IsNull(Quantity,0)) * Max(Case @FreeValAt When 'PTR' Then PTR Else PTS End) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)),
			(Select Min(Cast((Case When CharIndex(',',SplCatSerial) > 0 Then Left(SplCatSerial,CharIndex(',',SplCatSerial)-1) Else SplCatSerial End) As Int))  from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)),
			(Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),
			(Case IA.InvoiceType When 4 Then -Max(IDT.Amount) Else Max(IDT.Amount) End),
			(Case When (Max(IA.DiscountValue) <> 0 Or Max(IA.AddlDiscountValue) <> 0 or Max(IDT.DiscountValue) <> 0 Or Max(IDT.SchemeID) <> 0 Or Max(IDT.SplCatSchemeID) <> 0) Then (Case IA.InvoiceType When 4 Then -Max(IDT.Amount) Else Max(IDT.Amount) End) Else 0 End),
			(Select IsNull(SchemeID,0) From Schemes where SchemeID = IA.SchemeID And Max(IA.SchemeDiscountPercentage) > 0 And SecondaryScheme & (Case @Claimable When 'Both' Then 0 Else 1 End) = (Case @Claimable When 'Yes' Then 1 Else 0 End)),
			(Case When IA.SchemeID > 0 Then ((Case IA.InvoiceType When 4 Then -1 Else 1 End) * ((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.SchemeDiscountPercentage)) / 100) Else 0 End),
			(Select IsNull(SchemeID,0) From Schemes where SchemeID = Max(IDT.SchemeID) And SecondaryScheme & (Case @Claimable When 'Both' Then 0 Else 1 End) = (Case @Claimable When 'Yes' Then 1 Else 0 End)),
			(Case When Max(IDT.SchemeID) >0 Then (Case IA.InvoiceType When 4 Then -Max(IDT.SchemeDiscAmount) Else Max(IDT.SchemeDiscAmount) End) Else 0 End),
			(Select IsNull(SchemeID,0) From Schemes where SchemeID = Max(IDT.SplCatSchemeID) And SecondaryScheme & (Case @Claimable When 'Both' Then 0 Else 1 End) = (Case @Claimable When 'Yes' Then 1 Else 0 End)),
			(Case When Max(IDT.SplCatSchemeID) > 0 then (Case IA.InvoiceType When 4 Then -Max(IDT.SplCatDiscAmount) Else Max(IDT.SplCatDiscAmount) End) Else 0 End),
		  (Case When (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) >0 Then ((Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) * Max(IDT.SalePrice))Else 0 End ),
		  (((Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) * Max(IDT.SalePrice)) * (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) /100),
			(Case When Max(IA.AdditionalDiscount) > 0 Then (Case IA.InvoiceType When 4 Then -1 Else 1 End) * (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) ) Else 0 End ),
			( (Case IA.InvoiceType When 4 Then -1 Else 1 End) * (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.AdditionalDiscount)) / 100) ),
			(Case When (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) > 0 Then (Case IA.InvoiceType When 4 Then -1 Else 1 End) * (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue))) Else 0 End),
			( (Case IA.InvoiceType When 4 Then -1 Else 1 End) * (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) / 100))
		From    
			InvoiceAbstract IA, InvoiceDetail IDT, Items I, Customer C, #TempSelCatsLeaf Cat
		Where 
			IA.Status & 128 = 0
			And IA.InvoiceType in (1,3,4)
			And IA.InvoiceDate Between @FromDate And @ToDate
			And IA.SalesmanID In (Select SalesManID From #TempSalesMans)
	--		And IA.BeatID In (Select BeatID From #TempBeats)
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
			IA.CustomerID,IDT.InvoiceID,IA.InvoiceType, I.Product_Code ,IA.SchemeID,IDT.Serial --, IDT.SchemeID, IDT.SplCatSchemeID
	Else If @ReportLevel = 'Customer wise'
		Insert Into #TempSale
			(SelCat,SelCatName,DivCat,DivCatName,CatID,Channel,SalesManID,Beat,CustomerID,
			ItemCode,UOM,UOM1,UOM2,Serial,SchItem_Code,SchQty,SchUOM,SchValue,SplSchItem_Code,SplSchQty,SplSchUOM,SplSchValue,FreeSerial,
			TotQty,NetValue,DiscSalValue,	InvSchemeID, InvSchemeValue, SchemeID, SchemeValue, SplCatSchemeID, SplCatSchemeValue,
			PNetValue,PDisc,ANetValue,ADisc,TNetValue,TDisc)
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
			(Select Max(IsNull(Product_Code,'')) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.FreeSerial)) > 0 Then Left(Max(IDT.FreeSerial),CharIndex(',',Max(IDT.FreeSerial))-1) Else Max(IDT.FreeSerial) End As Int)),
			(Select Sum(IsNull(Quantity,0)) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.FreeSerial)) > 0 Then Left(Max(IDT.FreeSerial),CharIndex(',',Max(IDT.FreeSerial))-1) Else Max(IDT.FreeSerial) End As Int)),
			(Select IsNull(UOM2,0) from Items Where Product_Code = (Select Max(IsNull(Product_Code,'')) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.FreeSerial)) > 0 Then Left(Max(IDT.FreeSerial),CharIndex(',',Max(IDT.FreeSerial))-1) Else Max(IDT.FreeSerial) End As Int))),
			(Select Sum(IsNull(Quantity,0)) * Max(Case @FreeValAt When 'PTR' Then PTR Else PTS End) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.FreeSerial)) > 0 Then Left(Max(IDT.FreeSerial),CharIndex(',',Max(IDT.FreeSerial))-1) Else Max(IDT.FreeSerial) End As Int)),
			(Select Max(IsNull(Product_Code,'')) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)),
			(Select Sum(IsNull(Quantity,0)) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)),
			(Select IsNull(UOM2,0) from Items Where Product_Code = (Select Max(IsNull(Product_Code,'')) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int))),
			(Select Sum(IsNull(Quantity,0)) * Max(Case @FreeValAt When 'PTR' Then PTR Else PTS End) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)),
			(Select Min(Cast((Case When CharIndex(',',SplCatSerial) > 0 Then Left(SplCatSerial,CharIndex(',',SplCatSerial)-1) Else SplCatSerial End) As Int))  from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)),
			(Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),
			(Case IA.InvoiceType When 4 Then -Max(IDT.Amount) Else Max(IDT.Amount) End),
			(Case When (Max(IA.DiscountValue) <> 0 Or Max(IA.AddlDiscountValue) <> 0 or Max(IDT.DiscountValue) <> 0 Or Max(IDT.SchemeID) <> 0 Or Max(IDT.SplCatSchemeID) <> 0) Then (Case IA.InvoiceType When 4 Then -Max(IDT.Amount) Else Max(IDT.Amount) End) Else 0 End),
			(Select IsNull(SchemeID,0) From Schemes where SchemeID = IA.SchemeID And Max(IA.SchemeDiscountPercentage) > 0 And SecondaryScheme & (Case @Claimable When 'Both' Then 0 Else 1 End) = (Case @Claimable When 'Yes' Then 1 Else 0 End)),
			(Case When IA.SchemeID > 0 Then ((Case IA.InvoiceType When 4 Then -1 Else 1 End) * ((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.SchemeDiscountPercentage)) / 100) Else 0 End),
			(Select IsNull(SchemeID,0) From Schemes where SchemeID = Max(IDT.SchemeID) And SecondaryScheme & (Case @Claimable When 'Both' Then 0 Else 1 End) = (Case @Claimable When 'Yes' Then 1 Else 0 End)),
			(Case When Max(IDT.SchemeID) >0 Then (Case IA.InvoiceType When 4 Then -Max(IDT.SchemeDiscAmount) Else Max(IDT.SchemeDiscAmount) End) Else 0 End),
			(Select IsNull(SchemeID,0) From Schemes where SchemeID = Max(IDT.SplCatSchemeID) And SecondaryScheme & (Case @Claimable When 'Both' Then 0 Else 1 End) = (Case @Claimable When 'Yes' Then 1 Else 0 End)),
			(Case When Max(IDT.SplCatSchemeID) > 0 then (Case IA.InvoiceType When 4 Then -Max(IDT.SplCatDiscAmount) Else Max(IDT.SplCatDiscAmount) End) Else 0 End),
		  (Case When (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) >0 Then ((Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) * Max(IDT.SalePrice))Else 0 End ),
		  (((Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) * Max(IDT.SalePrice)) * (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) /100),
			(Case When Max(IA.AdditionalDiscount) > 0 Then (Case IA.InvoiceType When 4 Then -1 Else 1 End) * (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) ) Else 0 End ),
			( (Case IA.InvoiceType When 4 Then -1 Else 1 End) * (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.AdditionalDiscount)) / 100) ),
			(Case When (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) > 0 Then (Case IA.InvoiceType When 4 Then -1 Else 1 End) * (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue))) Else 0 End),
			( (Case IA.InvoiceType When 4 Then -1 Else 1 End) * (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) / 100))
		From    
			InvoiceAbstract IA, InvoiceDetail IDT, Items I, Customer C, #TempSelCatsLeaf Cat
		Where 
			IA.Status & 128 = 0
			And IA.InvoiceType in (1,3,4)		
			And IA.InvoiceDate Between @FromDate And @ToDate
			And IA.SalesmanID In (Select SalesManID From #TempSalesMans)
			And IA.BeatID In (Select BeatID From #TempBeats)
	--	  And IA.CustomerID In (Select CustomerID From #TempCust)
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
			IA.CustomerID,IDT.InvoiceID,IA.InvoiceType, I.Product_Code ,IA.SchemeID,IDT.Serial --, IDT.SchemeID, IDT.SplCatSchemeID
	Else --'Category Wise'
		Insert Into #TempSale
			(SelCat,SelCatName,DivCat,DivCatName,CatID,Channel,SalesManID,Beat,CustomerID,
			ItemCode,UOM,UOM1,UOM2,Serial,SchItem_Code,SchQty,SchUOM,SchValue,SplSchItem_Code,SplSchQty,SplSchUOM,SplSchValue,FreeSerial,
			TotQty,NetValue,DiscSalValue,	InvSchemeID, InvSchemeValue, SchemeID, SchemeValue, SplCatSchemeID, SplCatSchemeValue,
			PNetValue,PDisc,ANetValue,ADisc,TNetValue,TDisc)
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
			(Select Max(IsNull(Product_Code,'')) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.FreeSerial)) > 0 Then Left(Max(IDT.FreeSerial),CharIndex(',',Max(IDT.FreeSerial))-1) Else Max(IDT.FreeSerial) End As Int)),
			(Select Sum(IsNull(Quantity,0)) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.FreeSerial)) > 0 Then Left(Max(IDT.FreeSerial),CharIndex(',',Max(IDT.FreeSerial))-1) Else Max(IDT.FreeSerial) End As Int)),
			(Select IsNull(UOM2,0) from Items Where Product_Code = (Select Max(IsNull(Product_Code,'')) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.FreeSerial)) > 0 Then Left(Max(IDT.FreeSerial),CharIndex(',',Max(IDT.FreeSerial))-1) Else Max(IDT.FreeSerial) End As Int))),
			(Select Sum(IsNull(Quantity,0)) * Max(Case @FreeValAt When 'PTR' Then PTR Else PTS End) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.FreeSerial)) > 0 Then Left(Max(IDT.FreeSerial),CharIndex(',',Max(IDT.FreeSerial))-1) Else Max(IDT.FreeSerial) End As Int)),
			(Select Max(IsNull(Product_Code,'')) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)),
			(Select Sum(IsNull(Quantity,0)) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)),
			(Select IsNull(UOM2,0) from Items Where Product_Code = (Select Max(IsNull(Product_Code,'')) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int))),
			(Select Sum(IsNull(Quantity,0)) * Max(Case @FreeValAt When 'PTR' Then PTR Else PTS End) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)),
			(Select Min(Cast((Case When CharIndex(',',SplCatSerial) > 0 Then Left(SplCatSerial,CharIndex(',',SplCatSerial)-1) Else SplCatSerial End) As Int))  from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)),
			(Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),
			(Case IA.InvoiceType When 4 Then -Max(IDT.Amount) Else Max(IDT.Amount) End),
			(Case When (Max(IA.DiscountValue) <> 0 Or Max(IA.AddlDiscountValue) <> 0 or Max(IDT.DiscountValue) <> 0 Or Max(IDT.SchemeID) <> 0 Or Max(IDT.SplCatSchemeID) <> 0) Then (Case IA.InvoiceType When 4 Then -Max(IDT.Amount) Else Max(IDT.Amount) End) Else 0 End),
			(Select IsNull(SchemeID,0) From Schemes where SchemeID = IA.SchemeID And Max(IA.SchemeDiscountPercentage) > 0 And SecondaryScheme & (Case @Claimable When 'Both' Then 0 Else 1 End) = (Case @Claimable When 'Yes' Then 1 Else 0 End)),
			(Case When IA.SchemeID > 0 Then ((Case IA.InvoiceType When 4 Then -1 Else 1 End) * ((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.SchemeDiscountPercentage)) / 100) Else 0 End),
			(Select IsNull(SchemeID,0) From Schemes where SchemeID = Max(IDT.SchemeID) And SecondaryScheme & (Case @Claimable When 'Both' Then 0 Else 1 End) = (Case @Claimable When 'Yes' Then 1 Else 0 End)),
			(Case When Max(IDT.SchemeID) >0 Then (Case IA.InvoiceType When 4 Then -Max(IDT.SchemeDiscAmount) Else Max(IDT.SchemeDiscAmount) End) Else 0 End),
			(Select IsNull(SchemeID,0) From Schemes where SchemeID = Max(IDT.SplCatSchemeID) And SecondaryScheme & (Case @Claimable When 'Both' Then 0 Else 1 End) = (Case @Claimable When 'Yes' Then 1 Else 0 End)),
			(Case When Max(IDT.SplCatSchemeID) > 0 then (Case IA.InvoiceType When 4 Then -Max(IDT.SplCatDiscAmount) Else Max(IDT.SplCatDiscAmount) End) Else 0 End),
		  (Case When (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) >0 Then ((Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) * Max(IDT.SalePrice))Else 0 End ),
		  (((Case IA.InvoiceType When 4 Then -Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) * Max(IDT.SalePrice)) * (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) /100),
			(Case When Max(IA.AdditionalDiscount) > 0 Then (Case IA.InvoiceType When 4 Then -1 Else 1 End) * (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) ) Else 0 End ),
			( (Case IA.InvoiceType When 4 Then -1 Else 1 End) * (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.AdditionalDiscount)) / 100) ),
			(Case When (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) > 0 Then (Case IA.InvoiceType When 4 Then -1 Else 1 End) * (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue))) Else 0 End),
			( (Case IA.InvoiceType When 4 Then -1 Else 1 End) * (((sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) / 100))
			From    
				InvoiceAbstract IA, InvoiceDetail IDT, Items I, Customer C, #TempSelCatsLeaf Cat
			Where 
				IA.Status & 128 = 0
				And IA.InvoiceType in (1,3,4)
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
				Cat.SelCat, Cat.SelCatName, Cat.LeafCat, C.ChannelType, IA.SalesManID, IA.BeatID, 
				IA.CustomerID,IDT.InvoiceID,IA.InvoiceType, I.Product_Code ,IA.SchemeID, IDT.Serial	-- ,IDT.SchemeID, IDT.SplCatSchemeID,IDT.Serial

	Update #TempSale Set SchemeID= 0 Where IsNull(SchItem_Code,'') = '' And IsNull(SchQty,0) = 0 And IsNull(SchemeValue,0) = 0
	Update #TempSale Set SplCatSchemeID = 0 Where IsNull(SplSchItem_Code,'') = '' And IsNull(SplSchQty,0) = 0 And IsNull(SplCatSchemeValue,0) = 0
	Update #TempSale Set SchemeValue = 0, SchValue = 0 Where IsNull(SchemeID,0) =  0
	Update #TempSale Set SplCatSchemeValue = 0,SplSchValue = 0 Where IsNull(SplCatSchemeID,0) = 0
	Update #TempSale Set InvSchemeValue = 0 Where IsNull(InvSchemeID,0) = 0

	Update #TempSale Set SplFlag = 0 Where Serial <> FreeSerial
	Update #TempSale Set SplFlag = 1 Where Serial = FreeSerial
		
	Select @SchDispOption = Count(Distinct SchemeID) from #TempSale Where IsNull(SchemeID,0) > 0
	Select @SplSchDispOption = Count(Distinct SplCatSchemeID) from #TempSale Where IsNull(SplCatSchemeID,0) > 0
	Select @InvDispOption = Count(Distinct InvSchemeID) from #TempSale Where IsNull(InvSchemeID,0) > 0
End

-- Select * from #TempSale 

If @DiscType = 'Scheme'
Begin
	Select "CatID" = Max(CatID),
	"Division" = Max(DivCatName),
	"Saleable Item Name" = Max(I.ProductName),
	"UOM" = Max(UOM.Description),
	"Quantity" = Sum(TotQty),
	"Value" = Sum(NetValue),
	"Scheme Name" = (Select IsNull(SchemeName,'') from Schemes Where SchemeID = TS.SchemeID),
	"Scheme Free Item Name" = Case When TS.SchemeID > 0 Then (Select IsNull(ProductName,'') from Items where Product_Code = Max(TS.SchItem_Code)) Else '' End,
	"Scheme UOM" =  Case When TS.SchemeID > 0 Then (Select ISNull(Description,'') From UOM Where UOM = Max(TS.SchUOM)) Else '' End,
	"Scheme Quantity" = (Sum(Case When TS.SchemeID > 0 Then IsNull(SchQty,0) Else 0 End))/(Select (Case When IsNull(UOM2_Conversion,0) > 0 Then UOM2_Conversion Else 1 End) from Items Where Product_code = Max(TS.SchItem_Code)),
	"Scheme Value" = Sum(Case When TS.SchemeID > 0 Then IsNull(SchValue,0) + IsNull(SchemeValue,0) Else 0 End),
	"Spl Scheme Name" = Case IsNull(TS.SplSchItem_Code,'') when '' Then (Select IsNull(SchemeName,'') from Schemes Where SchemeID = TS.SplCatSchemeID) Else (Case splflag When 1 then (Select IsNull(SchemeName,'') from Schemes Where SchemeID = TS.SplCatSchemeID) Else '' End) End,
	"Spl Scheme Free Item Name" = Case When TS.SplCatSchemeID > 0 Then (Case SplFlag When 1 Then (Select IsNull(ProductName,'') from Items where Product_Code = Max(TS.SplSchItem_Code)) Else '' End) Else '' End,
	"Spl Scheme UOM" = Case When TS.SplCatSchemeID > 0 Then (Case SplFlag When 1 Then (Select ISNull(Description,'') From UOM Where UOM = Max(TS.SplSchUOM)) Else '' End) Else '' End,
	"Spl Scheme Quantity" = (Sum(Case When TS.SplCatSchemeID > 0 Then (Case SplFlag When 1 Then SplSchQty Else 0 End) Else 0 End))/(Select (Case When IsNull(UOM2_Conversion,0) > 0 Then UOM2_Conversion Else 1 End) from Items Where Product_code = Max(TS.SplSchItem_Code)),
	"Spl Scheme Value" = Sum(Case When TS.SplCatSchemeID > 0 Then (Case IsNull(TS.SplSchItem_Code,'') when '' Then IsNull(SplCatSchemeValue,0) Else (Case SplFlag When 1 Then (IsNull(SplSchValue,0) + IsNull(SplCatSchemeValue,0)) Else 0 End) End) Else 0 End),
	"Inv Scheme Name" = (Select IsNull(SchemeName,'') from Schemes Where SchemeID = TS.InvSchemeID),
	"Inv Scheme Value" = Sum(Case When TS.InvSchemeID > 0 Then IsNull(InvSchemeValue,0) Else 0 End),
	"Total Discount Value" = Sum(IsNull(SchValue,0) + IsNull(SchemeValue,0) + (Case SplFlag When 1 Then IsNull(SplSchValue,0) Else 0 End) + IsNull(SplCatSchemeValue,0) + IsNull(InvSchemeValue,0))	InTo #PreSchResult
	From  #TempSale TS,Items I,UOM,#TempCategory1 ISort
	Where TS.ItemCode = I.Product_Code
	And I.CategoryID = ISort.CategoryID
	And UOM.UOM = (Case @UOM when 'UOM2' Then TS.UOM2 When 'UOM1' Then TS.UOM1 Else TS.UOM End)
	Group By I.Product_Code,TS.SchemeID,TS.SplCatSchemeID,TS.InvSchemeID,TS.SplFlag,TS.SplSchItem_Code,ISort.IDS
	Order By ISort.IDS

Set @SqlSel = 'Select [CatID],[Division],[Saleable Item Name],[UOM],[Quantity],[Value]'
if IsNull(@SchDispOption,0) > 0
Set @SqlSel = @SqlSel + ',[Scheme Name],[Scheme Free Item Name],[Scheme UOM],[Scheme Quantity],[Scheme Value]'
If IsNull(@SplSchDispOption,0) > 0 
Set @SqlSel = @SqlSel + ',[Spl Scheme Name],[Spl Scheme Free Item Name],[Spl Scheme UOM],[Spl Scheme Quantity],[Spl Scheme Value]'
If IsNull(@InvDispOption,0) > 0
Set @SqlSel = @SqlSel + ',[Inv Scheme Name],[Inv Scheme Value]'

Set @SqlSel = @SqlSel + ',[Total Discount Value] From #PreSchResult'

Exec Sp_ExecuteSql @SqlSel

End
Else If @DiscType = 'Product Discount'
	Begin
		Select "Code" = Max(CatID),
		"Division" = Max(DivCatName),
		"Saleable Item Name" = Max(I.ProductName),
		"UOM" = Max(UOM.Description),
		"Quantity" = Sum(TotQty),
		"Value" = Sum(NetValue),
		"Net Product Discount %" = Case When Abs(Sum(PNetValue)) > 0 Then Abs((Sum(PDisc)) / Abs(Sum(PNetValue))) * 100 Else 0 End,
		"Product Discount" = Sum(PDisc) Into #PrePResult
		from  #TempSale TS,Items I,UOM,#TempCategory1 ISort 
		Where TS.ItemCode = I.Product_Code
		And I.CategoryID = ISort.CategoryID
		And UOM.UOM = (Case @UOM when 'UOM2' Then TS.UOM2 When 'UOM1' Then TS.UOM1 Else TS.UOM End)
		Group By I.Product_Code,ISort.IDS
		Order By ISort.IDS
		Select *  from #PrePResult
	End
Else If @DiscType = 'Addl. Discount'
	Begin
		Select "Code" = Max(CatID),
		"Division" = Max(DivCatName),
		"Saleable Item Name" = Max(I.ProductName),
		"UOM" = Max(UOM.Description),
		"Quantity" = Sum(TotQty),
		"Value" = Sum(NetValue),
		"Net Addl. Discount %" = Case When Abs(Sum(ANetValue)) > 0 Then Abs((Sum(ADisc)) / AbS(Sum(ANetValue))) * 100 Else 0 End,
		"Addl. Discount" = Sum(ADisc) Into #PreAResult
		from  #TempSale TS,Items I,UOM,#TempCategory1 ISort
		Where TS.ItemCode = I.Product_Code
		And I.CategoryID = ISort.CategoryID
		And UOM.UOM = (Case @UOM when 'UOM2' Then TS.UOM2 When 'UOM1' Then TS.UOM1 Else TS.UOM End)
		Group By I.Product_Code,ISort.IDS
		Order By ISort.IDS
		Select * from #PreAResult
	End
Else If @DiscType = 'Trade Discount'
	Begin	
		Select "Code" = Max(CatID),
		"Division" = Max(DivCatName),
		"Saleable Item Name" = Max(I.ProductName),
		"UOM" = Max(UOM.Description),
		"Quantity" = Sum(TotQty),
		"Value" = Sum(NetValue),
		"Net Trade Discount %" = Case When Abs(Sum(TNetValue)) > 0 Then Abs((Sum(TDisc)) / Abs(Sum(TNetValue))) * 100 Else 0 End,
		"Trade Discount" = Sum(TDisc) Into #PreTResult
		from  #TempSale TS,Items I,UOM,#TempCategory1 ISort
		Where TS.ItemCode = I.Product_Code
		And I.CategoryID = ISort.CategoryID
		And UOM.UOM = (Case @UOM when 'UOM2' Then TS.UOM2 When 'UOM1' Then TS.UOM1 Else TS.UOM End)
		Group By I.Product_Code,ISort.IDS
		Order By ISort.IDS
		Select * from #PreTResult
	End
Else if @DiscType = 'Only Free Item'
	Select Max(CatID),
	"Division" = Max(DivCatName),
	"Free Item Name" = Max(I.ProductName),
	"UOM" = Max(UOM.Description),
	"Quantity" = Sum(Free),
	"Value" = Sum(FreeValue)
	from  #TempSale TS,Items I,UOM,#TempCategory1 ISort
	Where TS.ItemCode = I.Product_Code
	And I.CategoryID = ISort.CategoryID
	And UOM.UOM = (Case @UOM when 'UOM2' Then TS.UOM2 When 'UOM1' Then TS.UOM1 Else TS.UOM End)
	Group By I.Product_Code,ISort.IDS
	Order By ISort.IDS
Else --'All without Free Item'
Begin
	Select "CatID" = Max(CatID),
	"Division" = Max(DivCatName),
	"Saleable Item Name" = Max(I.ProductName),
	"UOM" = Max(UOM.Description),
	"Quantity" = Sum(TotQty),
	"Value" = Sum(NetValue),
	"Scheme Name" = (Select IsNull(SchemeName,'') from Schemes Where SchemeID = TS.SchemeID),
	"Scheme Free Item Name" = Case When TS.SchemeID > 0 Then (Select IsNull(ProductName,'') from Items where Product_Code = Max(TS.SchItem_Code)) Else '' End,
	"Scheme UOM" =  Case When TS.SchemeID > 0 Then (Select ISNull(Description,'') From UOM Where UOM = Max(TS.SchUOM)) Else '' End,
	"Scheme Quantity" = (Sum(Case When TS.SchemeID > 0 Then IsNull(SchQty,0) Else 0 End))/(Select (Case When IsNull(UOM2_Conversion,0) > 0 Then UOM2_Conversion Else 1 End) from Items Where Product_code = Max(TS.SchItem_Code)),
	"Scheme Value" = Sum(Case When TS.SchemeID > 0 Then IsNull(SchValue,0) + IsNull(SchemeValue,0) Else 0 End),
	"Spl Scheme Name" = Case IsNull(TS.SplSchItem_Code,'') when '' Then (Select IsNull(SchemeName,'') from Schemes Where SchemeID = TS.SplCatSchemeID) Else (Case splflag When 1 then (Select IsNull(SchemeName,'') from Schemes Where SchemeID = TS.SplCatSchemeID) Else '' End) End,
	"Spl Scheme Free Item Name" = Case When TS.SplCatSchemeID > 0 Then (Case SplFlag When 1 Then (Select IsNull(ProductName,'') from Items where Product_Code = Max(TS.SplSchItem_Code)) Else '' End) Else '' End,
	"Spl Scheme UOM" = Case When TS.SplCatSchemeID > 0 Then (Case SplFlag When 1 Then (Select ISNull(Description,'') From UOM Where UOM = Max(TS.SplSchUOM)) Else '' End) Else '' End,
	"Spl Scheme Quantity" = (Sum(Case When TS.SplCatSchemeID > 0 Then (Case SplFlag When 1 Then SplSchQty Else 0 End) Else 0 End))/(Select (Case When IsNull(UOM2_Conversion,0) > 0 Then UOM2_Conversion Else 1 End) from Items Where Product_code = Max(TS.SplSchItem_Code)),
	"Spl Scheme Value" = Sum(Case When TS.SplCatSchemeID > 0 Then (Case IsNull(TS.SplSchItem_Code,'') when '' Then IsNull(SplCatSchemeValue,0) Else (Case SplFlag When 1 Then (IsNull(SplSchValue,0) + IsNull(SplCatSchemeValue,0)) Else 0 End) End) Else 0 End),
	"Inv Scheme Name" = (Select IsNull(SchemeName,'') from Schemes Where SchemeID = TS.InvSchemeID),
	"Inv Scheme Value" = Sum(Case When TS.InvSchemeID > 0 Then IsNull(InvSchemeValue,0) Else 0 End),
	"Net Product Discount %" = Case When Abs(Sum(PNetValue)) > 0 Then Abs((Sum(PDisc)) / Abs(Sum(PNetValue))) * 100 Else 0 End,
	"Product Discount" = Sum(PDisc),
	"Net Addl. Discount %" = Case When Abs(Sum(ANetValue)) > 0 Then Abs((Sum(ADisc)) / AbS(Sum(ANetValue))) * 100 Else 0 End,
	"Addl. Discount" = Sum(ADisc),
	"Net Trade Discount %" = Case When Abs(Sum(TNetValue)) > 0 Then Abs((Sum(TDisc)) / Abs(Sum(TNetValue))) * 100 Else 0 End,
	"Trade Discount" = Sum(TDisc),
	"Total Discount Value" = Sum((IsNull(SchValue,0) + IsNull(SchemeValue,0) + (Case SplFlag When 1 Then IsNull(SplSchValue,0) Else 0 End) + IsNull(SplCatSchemeValue,0) + IsNull(InvSchemeValue,0)) + (Case @Claimable When 'Yes' Then 0 Else IsNull(PDIsc,0) + IsNull(ADIsc,0) + IsNull(TDisc,0) End)) Into #PreAllResult
	From  #TempSale TS,Items I,UOM ,#TempCategory1 ISort
	Where TS.ItemCode = I.Product_Code
	And I.CategoryID = ISort.CategoryID
	And UOM.UOM = (Case @UOM when 'UOM2' Then TS.UOM2 When 'UOM1' Then TS.UOM1 Else TS.UOM End)
	Group By I.Product_Code,TS.SchemeID,TS.SplCatSchemeID,TS.InvSchemeID,TS.SplFlag,TS.SplSchItem_Code,ISort.IDS
	Order By ISort.IDS
 
-- Select * from #PreAllResult

	If @Claimable ='Yes'
		Begin
			Set @SqlSel = 'Select [CatID],[Division],[Saleable Item Name],[UOM],[Quantity],[Value]'
			if IsNull(@SchDispOption,0) > 0
				Set @SqlSel = @SqlSel + ',[Scheme Name],[Scheme Free Item Name],[Scheme UOM],[Scheme Quantity],[Scheme Value]'
			If IsNull(@SplSchDispOption,0) > 0 
				Set @SqlSel = @SqlSel + ',[Spl Scheme Name],[Spl Scheme Free Item Name],[Spl Scheme UOM],[Spl Scheme Quantity],[Spl Scheme Value]'
			If IsNull(@InvDispOption,0) > 0
				Set @SqlSel = @SqlSel + ',[Inv Scheme Name],[Inv Scheme Value]'		
			Set @SqlSel = @SqlSel + ',[Total Discount Value] From #PreAllResult'
		End
	Else
		Begin
			Set @SqlSel = 'Select [CatID],[Division],[Saleable Item Name],[UOM],[Quantity],[Value]'
			if IsNull(@SchDispOption,0) > 0
				Set @SqlSel = @SqlSel + ',[Scheme Name],[Scheme Free Item Name],[Scheme UOM],[Scheme Quantity],[Scheme Value]'
			If IsNull(@SplSchDispOption,0) > 0 
				Set @SqlSel = @SqlSel + ',[Spl Scheme Name],[Spl Scheme Free Item Name],[Spl Scheme UOM],[Spl Scheme Quantity],[Spl Scheme Value]'
			If IsNull(@InvDispOption,0) > 0
				Set @SqlSel = @SqlSel + ',[Inv Scheme Name],[Inv Scheme Value]'		
			Set @SqlSel = @SqlSel + ',[Net Product Discount %],[Product Discount],[Net Addl. Discount %],[Addl. Discount],[Net Trade Discount %],[Trade Discount],[Total Discount Value] From #PreAllResult'
		End
Exec Sp_ExecuteSql @SqlSel

End

Drop Table #TempCategory
Drop Table #TempSelectedCats
Drop Table #TempDivCats
Drop Table #TempSelCatsLeaf
Drop Table #TempChannels
Drop Table #TempSalesMans
Drop Table #TempBeats
Drop Table #TempCust
Drop Table #TempSale
Drop Table #TempCategory1
