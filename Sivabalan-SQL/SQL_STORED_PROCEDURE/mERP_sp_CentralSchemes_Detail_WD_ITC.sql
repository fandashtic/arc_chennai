CREATE PROCEDURE mERP_sp_CentralSchemes_Detail_WD_ITC
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


If @DiscType = 'Trade Discount'
Set @DiscType = 'Addl. Discount'

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
	Serial nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Free Decimal(18,6),
	FreeValue Decimal(18,6),

	SchItem_Code nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
	SchQty nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
	SchUOM nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
	SchValue nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
    TotSchValue Decimal(18,6),

	SplSchItem_Code nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
	SplSchQty nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
	SplSchUOM nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
	SPlSchValue nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
    TotSPlSchValue Decimal(18,6),

	FreeSerial  nVarChar(110) COLLATE SQL_Latin1_General_CP1_CI_AS,
	SplFlag nVarChar(110) COLLATE SQL_Latin1_General_CP1_CI_AS,
	TotQty Decimal(18,6),
	NetValue Decimal(18,6),
	DiscSalValue Decimal(18,6),

	InvSchemeID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	InvSchemeValue nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
    TotInvSchemeValue Decimal(18,6),

	SchemeID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	SchemeValue nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
    TotSchemeValue Decimal(18,6),

	SplCatSchemeID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	SplCatSchemeValue nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
    TotSplCatSchemeValue Decimal(18,6),

--	PNetValue Decimal(18,6),
--	PDisc Decimal(18,6),
	ANetValue Decimal(18,6),
	ADisc Decimal(18,6),
--	TNetValue Decimal(18,6),
--	TDisc Decimal(18,6), 
    ItemRowsCount Int Default 0, 
    SplCatRowsCount Int Default 0  ,
	InvSchRowCount Int Default 0
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
		cast(IDT.Serial as nVarchar(100)),
		(Sum(IDT.Quantity) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End)),
		(Sum(IDT.Quantity) * (Case @FreeValAt When 'PTR' Then Max(IDT.PTR) Else Max(IDT.PTS) End) )
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
		cast(IDT.Serial as nVarchar(100)),
		( Sum(IDT.Quantity)  / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End)),
		( Sum(IDT.Quantity)  * (Case @FreeValAt When 'PTR' Then Max(IDT.PTR) Else Max(IDT.PTS) End) )
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
		cast(IDT.Serial as nVarchar(100)),
		( Sum(IDT.Quantity) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End)),
		( Sum(IDT.Quantity) * (Case @FreeValAt When 'PTR' Then Max(IDT.PTR) Else Max(IDT.PTS) End) )
		From    
			InvoiceAbstract IA, InvoiceDetail IDT, Items I, Customer C, #TempSelCatsLeaf Cat
		Where 
			IA.Status & 128 = 0
			And IA.InvoiceType in (1,3)
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
		cast(IDT.Serial as nVarchar(100)),
		( Sum(IDT.Quantity) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End)),
		( Sum(IDT.Quantity) * (Case @FreeValAt When 'PTR' Then Max(IDT.PTR) Else Max(IDT.PTS) End) )
		From    
			InvoiceAbstract IA, InvoiceDetail IDT, Items I, Customer C, #TempSelCatsLeaf Cat
		Where 
			IA.Status & 128 = 0
			And IA.InvoiceType in (1,3)		
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
			cast(IDT.Serial as nVarchar(100)),
			( Sum(IDT.Quantity) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End)),
			( Sum(IDT.Quantity) * (Case @FreeValAt When 'PTR' Then Max(IDT.PTR) Else Max(IDT.PTS) End) )
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
			ItemCode,UOM,UOM1,UOM2,Serial,
            SchItem_Code,SchQty,SchUOM,SchValue,TotSchValue,
            SplSchItem_Code,SplSchQty,SplSchUOM,SplSchValue,TotSplSchValue,
            FreeSerial,
			TotQty,NetValue,DiscSalValue,	
            InvSchemeID, InvSchemeValue, TotInvSchemeValue, 
            SchemeID, SchemeValue, TotSchemeValue, 
            SplCatSchemeID, SplCatSchemeValue, TotSplCatSchemeValue,
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
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 1, 1,I.Product_Code,IDT.Serial) 'SchItem_Code',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 2, 1,I.Product_Code,IDT.Serial) 'SchQty',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 5, 1,I.Product_Code,IDT.Serial) 'SchUOM',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 3, 1,I.Product_Code,IDT.Serial) 'SchValue',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 4, 1,I.Product_Code,IDT.Serial) 'TotSchValue',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 1, 2,I.Product_Code,IDT.Serial) 'SplSchItem_Code',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 2, 2,I.Product_Code,IDT.Serial) 'SplSchQty',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 5, 2,I.Product_Code,IDT.Serial) 'SplSchUOM',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 3, 2,I.Product_Code,IDT.Serial) 'SplSchValue',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 4, 2,I.Product_Code,IDT.Serial) 'TotSplSchValue',
            (Select Case When Flagword=1 And Len(IsNull(FreeSerial,'')) > 0 then Min(FreeSerial) 
                        When Flagword=1 And Len(IsNull(SplCatSerial,'')) > 0 then Min(SplCatSerial) 
                        Else '' End
            from InvoiceDetail Where InvoiceID = IDT.InvoiceID 
            and Cast(Serial as nVarchar(100)) in (
                Case When IDT.Flagword=1 And Len(IsNull(IDT.FreeSerial,'')) > 0 then (IsNull(Min(IDT.FreeSerial),''))
                        When IDT.Flagword=1 And Len(IsNull(IDT.SplCatSerial,'')) > 0 then (IsNull(Min(IDT.SplCatSerial),'')) Else '' End) Group by Flagword, IsNull(SplCatSerial,''),IsNull(FreeSerial,'')) 'Free Serial',
--            (Select Min(SplCatSerial) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Cast(Serial as nVarchar(100)) in (IsNull(Min(IDT.SplCatSerial),''))),
            Sum(IDT.Quantity) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),
			Max(IDT.Amount),
			(Case When (Max(IA.DiscountValue) <> 0 Or Max(IA.AddlDiscountValue) <> 0 or Max(IDT.DiscountValue) <> 0 Or Max(IDT.SchemeID) <> 0 Or Max(IDT.SplCatSchemeID) <> 0) Then Max(IDT.Amount) Else 0 End),
            /*RFA Claimable*/ 
            (Case When Len(IsNull(IA.InvoiceSchemeID,'')) > 0 Then dbo.merp_fn_List_CSIDByRFA(IA.InvoiceSchemeID,@Claimable) Else '0' End) 'InvSchemeID', 			
            (Case When 
              (Len(IsNull(IA.InvoiceSchemeID,'')) = 0 AND Max(IA.SchemeDiscountPercentage) > 0) Then dbo.merp_fn_Get_CSValueByRFA(IsNull(IA.MultipleSchemeDetails,''),@Claimable,IDT.InvoiceID,I.Product_Code,IDT.Serial) 
            When
              (Len(IsNull(IA.InvoiceSchemeID,'')) > 0 AND Max(IA.SchemeDiscountPercentage) > 0) Then (dbo.merp_fn_Get_CSValueByRFA(IsNull(IA.MultipleSchemeDetails,''),@Claimable,IDT.InvoiceID,I.Product_Code,IDT.Serial) + Char(15) + dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, IsNull(IA.InvoiceSchemeID,''), @FreeValAt, 1, 3,I.Product_Code,IDT.Serial))
            When 
              (Len(IsNull(IA.InvoiceSchemeID,'')) > 0 AND Max(IA.SchemeDiscountPercentage) = 0) Then dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, IsNull(IA.InvoiceSchemeID,''), @FreeValAt, 1, 3,I.Product_Code,IDT.Serial) Else '0' End) 'InvSchemeValue',  
            
            --(Case When Len(IsNull(IA.InvoiceSchemeID,'')) > 0 Then (Max(IA.SchemeDiscountAmount) + Cast(dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, IsNull(IA.InvoiceSchemeID,''), @FreeValAt, 2, 3) as Decimal(18,6))) Else 0 End) 'TotInvSchemeValue',
            (Case When Len(IsNull(IA.InvoiceSchemeID,'')) > 0 Then ((dbo.merp_fn_Get_InvSchemeValue(IDT.InvoiceID,I.Product_Code,IDT.Serial)) + Cast(dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, IsNull(IA.InvoiceSchemeID,''), @FreeValAt, 2, 3,I.Product_Code,IDT.Serial) as Decimal(18,6))) Else 0 End) 'TotInvSchemeValue',
  
            (Case When Len(IsNull(IDT.MultipleSchemeID,'')) >0 Then dbo.merp_fn_List_CSIDByRFA(IsNull(IDT.MultipleSchemeID,''),@Claimable) Else '' End) 'SchemeID', 			
            (Case When Len(IsNull(IDT.MultipleSchemeID,'')) >0 Then dbo.merp_fn_Get_CSValueByRFA(IsNull(IDT.MultipleSchemeDetails,''),@Claimable,IDT.InvoiceID,I.Product_Code,IDT.Serial) Else '' End) 'SchemeValue',
            (Case When Len(IsNull(IDT.MultipleSchemeID,'')) > 0 Then Max(IDT.SchemeDiscAmount) Else 0 End) 'TotSchemeValue',

            (Case When Len(IsNull(IDT.MultipleSplCatSchemeID,'')) > 0 then dbo.merp_fn_List_CSIDByRFA(IsNull(IDT.MultipleSplCatSchemeID,''),@Claimable) Else '' End) 'SplCatSchemeID', 
            (Case When Len(IsNull(IDT.MultipleSplCatSchemeID,'')) > 0 then dbo.merp_fn_Get_CSValueByRFA(IsNull(IDT.MultipleSplCategorySchDetail,''),@Claimable,IDT.InvoiceID,I.Product_Code,IDT.Serial) Else '' End)  'SplCatSchemeValue',
            (Case When Len(IsNull(IDT.MultipleSplCatSchemeID,'')) > 0 Then Max(IDT.SplCatDiscAmount) Else 0 End) 'TotSplCatSchemeValue',

             /*End of RFA Claimable*/
		 -- (Case When (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) >0 Then (Sum(IDT.Quantity) * Max(IDT.SalePrice))Else 0 End ),
		 -- ((Sum(IDT.Quantity) * Max(IDT.SalePrice)) * (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) /100),
		  (Case When Max(IA.AdditionalDiscount) > 0 Then (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) ) Else 0 End ),
		  ((((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.AdditionalDiscount)) / 100) )--,
		--  (Case When (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) > 0 Then (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue))) Else 0 End),
		--  ((((Sum(IDT.Quantity) * Max(IDT.SalePrice)-Max(IDT.DiscountValue))) * (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) / 100))
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
	--		And C.ChannelType In (Select ChannelType From #TempChannels)
		Group By
			Cat.SelCat, Cat.SelCatName, Cat.LeafCat, C.ChannelType, IA.SalesManID, IA.BeatID, IA.MultipleSchemeDetails,
            IDT.MultipleSchemeID, IDT.MultipleSchemeDetails, IDT.MultipleSplCatSchemeID, IDT.MultipleSplCategorySchDetail,
			IA.CustomerID,IDT.InvoiceID,IA.InvoiceType, I.Product_Code, IA.InvoiceSchemeID, 
			IDT.Serial, IDT.SplCatSerial, IDT.FreeSerial, IDT.Flagword  --, IDT.SchemeID, IDT.SplCatSchemeID
	Else If @ReportLevel = 'DS wise'
		Insert Into #TempSale
			(SelCat,SelCatName,DivCat,DivCatName,CatID,Channel,SalesManID,Beat,CustomerID,
			ItemCode,UOM,UOM1,UOM2,Serial,
            SchItem_Code,SchQty,SchUOM,SchValue,TotSchValue,
            SplSchItem_Code,SplSchQty,SplSchUOM,SplSchValue,TotSplSchValue,
            FreeSerial,
			TotQty,NetValue,DiscSalValue,	
            InvSchemeID, InvSchemeValue, totInvSchemeValue,
            SchemeID, SchemeValue, TotSchemeValue, 
            SplCatSchemeID, SplCatSchemeValue, TotSplCatSchemeValue,
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
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 1, 1,I.Product_Code,IDT.Serial) 'SchItem_Code',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 2, 1,I.Product_Code,IDT.Serial) 'SchQty',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 5, 1,I.Product_Code,IDT.Serial) 'SchUOM',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 3, 1,I.Product_Code,IDT.Serial) 'SchValue',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 4, 1,I.Product_Code,IDT.Serial) 'TotSchValue',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 1, 2,I.Product_Code,IDT.Serial) 'SplSchItem_Code',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 2, 2,I.Product_Code,IDT.Serial) 'SplSchQty',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 5, 2,I.Product_Code,IDT.Serial) 'SplSchUOM',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 3, 2,I.Product_Code,IDT.Serial) 'SplSchValue',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 4, 2,I.Product_Code,IDT.Serial) 'TotSplSchValue',
            (Select Case When Flagword=1 And Len(IsNull(FreeSerial,'')) > 0 then Min(FreeSerial) 
                        When Flagword=1 And Len(IsNull(SplCatSerial,'')) > 0 then Min(SplCatSerial) 
                        Else '' End
            from InvoiceDetail Where InvoiceID = IDT.InvoiceID 
            and Cast(Serial as nVarchar(100)) in (
                Case When IDT.Flagword=1 And Len(IsNull(IDT.FreeSerial,'')) > 0 then (IsNull(Min(IDT.FreeSerial),''))
                        When IDT.Flagword=1 And Len(IsNull(IDT.SplCatSerial,'')) > 0 then (IsNull(Min(IDT.SplCatSerial),'')) Else '' End) Group by Flagword, IsNull(SplCatSerial,''),IsNull(FreeSerial,'')) 'Free Serial',
--            (Select Min(SplCatSerial) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Cast(Serial as nVarchar(100)) in (IsNull(Min(IDT.SplCatSerial),''))),
            Sum(IDT.Quantity) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),
			Max(IDT.Amount),
			(Case When (Max(IA.DiscountValue) <> 0 Or Max(IA.AddlDiscountValue) <> 0 or Max(IDT.DiscountValue) <> 0 Or Max(IDT.SchemeID) <> 0 Or Max(IDT.SplCatSchemeID) <> 0) Then Max(IDT.Amount) Else 0 End),

            (Case When Len(IsNull(IA.InvoiceSchemeID,'')) > 0 Then dbo.merp_fn_List_CSIDByRFA(IA.InvoiceSchemeID,@Claimable) Else '0' End) 'InvSchemeID', 			
            (Case When 
              (Len(IsNull(IA.InvoiceSchemeID,'')) = 0 AND Max(IA.SchemeDiscountPercentage) > 0) Then dbo.merp_fn_Get_CSValueByRFA(IsNull(IA.MultipleSchemeDetails,''),@Claimable,IDT.InvoiceID,I.Product_Code,IDT.Serial) 
            When
              (Len(IsNull(IA.InvoiceSchemeID,'')) > 0 AND Max(IA.SchemeDiscountPercentage) > 0) Then (dbo.merp_fn_Get_CSValueByRFA(IsNull(IA.MultipleSchemeDetails,''),@Claimable,IDT.InvoiceID,I.Product_Code,IDT.Serial) + Char(15) + dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, IsNull(IA.InvoiceSchemeID,''), @FreeValAt, 1, 3,I.Product_Code,IDT.Serial))
            When 
              (Len(IsNull(IA.InvoiceSchemeID,'')) > 0 AND Max(IA.SchemeDiscountPercentage) = 0) Then dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, IsNull(IA.InvoiceSchemeID,''), @FreeValAt, 1, 3,I.Product_Code,IDT.Serial) Else '0' End) 'InvSchemeValue',
  
            --(Case When Len(IsNull(IA.InvoiceSchemeID,'')) > 0 Then (Max(IA.SchemeDiscountAmount) + Cast(dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, IsNull(IA.InvoiceSchemeID,''), @FreeValAt, 2, 3) as Decimal(18,6))) Else 0 End) 'TotInvSchemeValue',
            (Case When Len(IsNull(IA.InvoiceSchemeID,'')) > 0 Then ((dbo.merp_fn_Get_InvSchemeValue(IDT.InvoiceID,I.Product_Code,IDT.Serial)) + Cast(dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, IsNull(IA.InvoiceSchemeID,''), @FreeValAt, 2, 3,I.Product_Code,IDT.Serial) as Decimal(18,6))) Else 0 End) 'TotInvSchemeValue',


            (Case When Len(IsNull(IDT.MultipleSchemeID,'')) >0 Then dbo.merp_fn_List_CSIDByRFA(IsNull(IDT.MultipleSchemeID,''),@Claimable) Else '' End) 'SchemeID', 			
            (Case When Len(IsNull(IDT.MultipleSchemeID,'')) >0 Then dbo.merp_fn_Get_CSValueByRFA(IsNull(IDT.MultipleSchemeDetails,''),@Claimable,IDT.InvoiceID,I.Product_Code,IDT.Serial) Else '' End) 'SchemeValue',
            (Case When Len(IsNull(IDT.MultipleSchemeID,'')) > 0 Then Max(IDT.SchemeDiscAmount) Else 0 End) 'TotSchemeValue',

            (Case When Len(IsNull(IDT.MultipleSplCatSchemeID,'')) > 0 then dbo.merp_fn_List_CSIDByRFA(IsNull(IDT.MultipleSplCatSchemeID,''),@Claimable) Else '' End) 'SplCatSchemeID', 
            (Case When Len(IsNull(IDT.MultipleSplCatSchemeID,'')) > 0 then dbo.merp_fn_Get_CSValueByRFA(IsNull(IDT.MultipleSplCategorySchDetail,''),@Claimable,IDT.InvoiceID,I.Product_Code,IDT.Serial) Else '' End)  'SplCatSchemeValue',
            (Case When Len(IsNull(IDT.MultipleSplCatSchemeID,'')) > 0 Then Max(IDT.SplCatDiscAmount) Else 0 End) 'TotSplCatSchemeValue',

		-- (Case When (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) >0 Then (Sum(IDT.Quantity) * Max(IDT.SalePrice))Else 0 End ),
		--  ((Sum(IDT.Quantity) * Max(IDT.SalePrice)) * (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) /100),
			(Case When Max(IA.AdditionalDiscount) > 0 Then (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) ) Else 0 End ),
			((((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.AdditionalDiscount)) / 100) )--,
		--	(Case When (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) > 0 Then (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue))) Else 0 End),
		--	((((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) / 100))
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
	--		And IA.SalesmanID In (Select SalesManID From #TempSalesMans)
		Group By
			Cat.SelCat, Cat.SelCatName, Cat.LeafCat, C.ChannelType, IA.SalesManID, IA.BeatID, IA.MultipleSchemeDetails,
            IDT.MultipleSchemeID, IDT.MultipleSchemeDetails, IDT.MultipleSplCatSchemeID, IDT.MultipleSplCategorySchDetail,
			IA.CustomerID,IDT.InvoiceID,IA.InvoiceType, I.Product_Code ,IA.InvoiceSchemeID, 
			IDT.Serial, IDT.SplCatSerial, IDT.FreeSerial, IDT.Flagword --, IDT.SchemeID, IDT.SplCatSchemeID
	Else If @ReportLevel = 'Beat wise'
		Insert Into #TempSale
			(SelCat,SelCatName,DivCat,DivCatName,CatID,Channel,SalesManID,Beat,CustomerID,
			ItemCode,UOM,UOM1,UOM2,Serial,
            SchItem_Code,SchQty,SchUOM,SchValue,TotSchValue,
            SplSchItem_Code,SplSchQty,SplSchUOM,SplSchValue,TotSplSchValue,
            FreeSerial,
			TotQty,NetValue,DiscSalValue,	InvSchemeID, InvSchemeValue, TotInvSchemeValue, 
            SchemeID, SchemeValue, TotSchemeValue, SplCatSchemeID, SplCatSchemeValue, TotSplCatSchemeValue, 
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
			IDT.Serial, --Cast(IDT.Serial as nVarchar(50)),
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 1, 1,I.Product_Code,IDT.Serial) 'SchItem_Code',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 2, 1,I.Product_Code,IDT.Serial) 'SchQty',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 5, 1,I.Product_Code,IDT.Serial) 'SchUOM',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 3, 1,I.Product_Code,IDT.Serial) 'SchValue',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 4, 1,I.Product_Code,IDT.Serial) 'TotSchValue',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 1, 2,I.Product_Code,IDT.Serial) 'SplSchItem_Code',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 2, 2,I.Product_Code,IDT.Serial) 'SplSchQty',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 5, 2,I.Product_Code,IDT.Serial) 'SplSchUOM',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 3, 2,I.Product_Code,IDT.Serial) 'SplSchValue',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 4, 2,I.Product_Code,IDT.Serial) 'TotSplSchValue',
            (Select Case When Flagword=1 And Len(IsNull(FreeSerial,'')) > 0 then Min(FreeSerial) 
                        When Flagword=1 And Len(IsNull(SplCatSerial,'')) > 0 then Min(SplCatSerial) 
                        Else '' End
            from InvoiceDetail Where InvoiceID = IDT.InvoiceID 
            and Cast(Serial as nVarchar(100)) in (
                Case When IDT.Flagword=1 And Len(IsNull(IDT.FreeSerial,'')) > 0 then (IsNull(Min(IDT.FreeSerial),''))
                        When IDT.Flagword=1 And Len(IsNull(IDT.SplCatSerial,'')) > 0 then (IsNull(Min(IDT.SplCatSerial),'')) Else '' End) Group by Flagword, IsNull(SplCatSerial,''),IsNull(FreeSerial,'')) 'Free Serial',
--            (Select Min(SplCatSerial) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Cast(Serial as nVarchar(100)) in (IsNull(Min(IDT.SplCatSerial),''))),
            Sum(IDT.Quantity) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),
			Max(IDT.Amount),
			(Case When (Max(IA.DiscountValue) <> 0 Or Max(IA.AddlDiscountValue) <> 0 or Max(IDT.DiscountValue) <> 0 Or Max(IDT.SchemeID) <> 0 Or Max(IDT.SplCatSchemeID) <> 0) Then Max(IDT.Amount) Else 0 End),

            (Case When Len(IsNull(IA.InvoiceSchemeID,'')) > 0 Then dbo.merp_fn_List_CSIDByRFA(IA.InvoiceSchemeID,@Claimable) Else '0' End) 'InvSchemeID', 			
            (Case When 
              (Len(IsNull(IA.InvoiceSchemeID,'')) = 0 AND Max(IA.SchemeDiscountPercentage) > 0) Then dbo.merp_fn_Get_CSValueByRFA(IsNull(IA.MultipleSchemeDetails,''),@Claimable,IDT.InvoiceID,I.Product_Code,IDT.Serial) 
            When
              (Len(IsNull(IA.InvoiceSchemeID,'')) > 0 AND Max(IA.SchemeDiscountPercentage) > 0) Then (dbo.merp_fn_Get_CSValueByRFA(IsNull(IA.MultipleSchemeDetails,''),@Claimable,IDT.InvoiceID,I.Product_Code,IDT.Serial) + Char(15) + dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, IsNull(IA.InvoiceSchemeID,''), @FreeValAt, 1, 3,I.Product_Code,IDT.Serial))
            When 
              (Len(IsNull(IA.InvoiceSchemeID,'')) > 0 AND Max(IA.SchemeDiscountPercentage) = 0) Then dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, IsNull(IA.InvoiceSchemeID,''), @FreeValAt, 1, 3,I.Product_Code,IDT.Serial) Else '0' End) 'InvSchemeValue',  
            
            --(Case When Len(IsNull(IA.InvoiceSchemeID,'')) > 0 Then (Max(IA.SchemeDiscountAmount) + Cast(dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, IsNull(IA.InvoiceSchemeID,''), @FreeValAt, 2, 3) as Decimal(18,6))) Else 0 End) 'TotInvSchemeValue',
			(Case When Len(IsNull(IA.InvoiceSchemeID,'')) > 0 Then ((dbo.merp_fn_Get_InvSchemeValue(IDT.InvoiceID,I.Product_Code,IDT.Serial)) + Cast(dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, IsNull(IA.InvoiceSchemeID,''), @FreeValAt, 2, 3,I.Product_Code,IDT.Serial) as Decimal(18,6))) Else 0 End) 'TotInvSchemeValue',	

            (Case When Len(IsNull(IDT.MultipleSchemeID,'')) >0 Then dbo.merp_fn_List_CSIDByRFA(IsNull(IDT.MultipleSchemeID,''),@Claimable) Else '' End) 'SchemeID', 			
            (Case When Len(IsNull(IDT.MultipleSchemeID,'')) >0 Then dbo.merp_fn_Get_CSValueByRFA(IsNull(IDT.MultipleSchemeDetails,''),@Claimable,IDT.InvoiceID,I.Product_Code,IDT.Serial) Else '' End) 'SchemeValue',
            (Case When Len(IsNull(IDT.MultipleSchemeID,'')) > 0 Then Max(IDT.SchemeDiscAmount) Else 0 End) 'TotSchemeValue',

            (Case When Len(IsNull(IDT.MultipleSplCatSchemeID,'')) > 0 then dbo.merp_fn_List_CSIDByRFA(IsNull(IDT.MultipleSplCatSchemeID,''),@Claimable) Else '' End) 'SplCatSchemeID', 
            (Case When Len(IsNull(IDT.MultipleSplCatSchemeID,'')) > 0 then dbo.merp_fn_Get_CSValueByRFA(IsNull(IDT.MultipleSplCategorySchDetail,''),@Claimable,IDT.InvoiceID,I.Product_Code,IDT.Serial) Else '' End)  'SplCatSchemeValue',
            (Case When Len(IsNull(IDT.MultipleSplCatSchemeID,'')) > 0 Then Max(IDT.SplCatDiscAmount) Else 0 End) 'TotSplCatSchemeValue',

		 -- (Case When (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) >0 Then (Sum(IDT.Quantity) * Max(IDT.SalePrice))Else 0 End ),
		 --  ((Sum(IDT.Quantity) * Max(IDT.SalePrice)) * (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) /100),
			(Case When Max(IA.AdditionalDiscount) > 0 Then (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) ) Else 0 End ),
			((((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.AdditionalDiscount)) / 100) )--,
		 --	(Case When (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) > 0 Then (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue))) Else 0 End),
		 --	((((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) / 100))
		From    
			InvoiceAbstract IA, InvoiceDetail IDT, Items I, Customer C, #TempSelCatsLeaf Cat
		Where 
			IA.Status & 128 = 0
			And IA.InvoiceType in (1,3)
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
			Cat.SelCat, Cat.SelCatName, Cat.LeafCat, C.ChannelType, IA.SalesManID, IA.BeatID, IA.MultipleSchemeDetails,
            IDT.MultipleSchemeID, IDT.MultipleSchemeDetails, IDT.MultipleSplCatSchemeID, IDT.MultipleSplCategorySchDetail,
			IA.CustomerID,IDT.InvoiceID,IA.InvoiceType, I.Product_Code ,IA.InvoiceSchemeID, 
			IDT.Serial, IDT.SplCatSerial, IDT.FreeSerial, IDT.Flagword --, IDT.SchemeID, IDT.SplCatSchemeID
	Else If @ReportLevel = 'Customer wise'
		Insert Into #TempSale
			(SelCat,SelCatName,DivCat,DivCatName,CatID,Channel,SalesManID,Beat,CustomerID,
			ItemCode,UOM,UOM1,UOM2,Serial,
			SchItem_Code,SchQty,SchUOM,SchValue,TotSchValue,
			SplSchItem_Code,SplSchQty,SplSchUOM,SplSchValue,TotSplSchValue,
			FreeSerial,
			TotQty,NetValue,DiscSalValue,	InvSchemeID, InvSchemeValue, TotInvSchemeValue, 
            SchemeID, SchemeValue, TotSchemeValue, SplCatSchemeID, SplCatSchemeValue, TotSplCatSchemeValue,
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
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 1, 1,I.Product_Code,IDT.Serial) 'SchItem_Code',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 2, 1,I.Product_Code,IDT.Serial) 'SchQty',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 5, 1,I.Product_Code,IDT.Serial) 'SchUOM',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 3, 1,I.Product_Code,IDT.Serial) 'SchValue',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 4, 1,I.Product_Code,IDT.Serial) 'TotSchValue',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 1, 2,I.Product_Code,IDT.Serial) 'SplSchItem_Code',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 2, 2,I.Product_Code,IDT.Serial) 'SplSchQty',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 5, 2,I.Product_Code,IDT.Serial) 'SplSchUOM',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 3, 2,I.Product_Code,IDT.Serial) 'SplSchValue',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 4, 2,I.Product_Code,IDT.Serial) 'TotSplSchValue',
            (Select Case When Flagword=1 And Len(IsNull(FreeSerial,'')) > 0 then Min(FreeSerial) 
                        When Flagword=1 And Len(IsNull(SplCatSerial,'')) > 0 then Min(SplCatSerial) 
                        Else '' End
            from InvoiceDetail Where InvoiceID = IDT.InvoiceID 
            and Cast(Serial as nVarchar(100)) in (
                Case When IDT.Flagword=1 And Len(IsNull(IDT.FreeSerial,'')) > 0 then (IsNull(Min(IDT.FreeSerial),''))
                        When IDT.Flagword=1 And Len(IsNull(IDT.SplCatSerial,'')) > 0 then (IsNull(Min(IDT.SplCatSerial),'')) Else '' End) Group by Flagword, IsNull(SplCatSerial,''),IsNull(FreeSerial,'')) 'Free Serial',
--            (Select Min(SplCatSerial) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Cast(Serial as nVarchar(100)) in (IsNull(Min(IDT.SplCatSerial),''))),
            Sum(IDT.Quantity) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),
			Max(IDT.Amount),
			(Case When (Max(IA.DiscountValue) <> 0 Or Max(IA.AddlDiscountValue) <> 0 or Max(IDT.DiscountValue) <> 0 Or Max(IDT.SchemeID) <> 0 Or Max(IDT.SplCatSchemeID) <> 0) Then Max(IDT.Amount) Else 0 End),

            (Case When Len(IsNull(IA.InvoiceSchemeID,'')) > 0 Then dbo.merp_fn_List_CSIDByRFA(IA.InvoiceSchemeID,@Claimable) Else '0' End) 'InvSchemeID', 			
            (Case When 
              (Len(IsNull(IA.InvoiceSchemeID,'')) = 0 AND Max(IA.SchemeDiscountPercentage) > 0) Then dbo.merp_fn_Get_CSValueByRFA(IsNull(IA.MultipleSchemeDetails,''),@Claimable,IDT.InvoiceID,I.Product_Code,IDT.Serial) 
            When
              (Len(IsNull(IA.InvoiceSchemeID,'')) > 0 AND Max(IA.SchemeDiscountPercentage) > 0) Then (dbo.merp_fn_Get_CSValueByRFA(IsNull(IA.MultipleSchemeDetails,''),@Claimable,IDT.InvoiceID,I.Product_Code,IDT.Serial) + Char(15) + dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, IsNull(IA.InvoiceSchemeID,''), @FreeValAt, 1, 3,I.Product_Code,IDT.Serial))
            When 
              (Len(IsNull(IA.InvoiceSchemeID,'')) > 0 AND Max(IA.SchemeDiscountPercentage) = 0) Then dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, IsNull(IA.InvoiceSchemeID,''), @FreeValAt, 1, 3,I.Product_Code,IDT.Serial) Else '0' End) 'InvSchemeValue',  
            
			--(Case When Len(IsNull(IA.InvoiceSchemeID,'')) > 0 Then (Max(IA.SchemeDiscountAmount) + Cast(dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, IsNull(IA.InvoiceSchemeID,''), @FreeValAt, 2, 3) as Decimal(18,6))) Else 0 End) 'TotInvSchemeValue',
			(Case When Len(IsNull(IA.InvoiceSchemeID,'')) > 0 Then ((dbo.merp_fn_Get_InvSchemeValue(IDT.InvoiceID,I.Product_Code,IDT.Serial)) + Cast(dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, IsNull(IA.InvoiceSchemeID,''), @FreeValAt, 2, 3,I.Product_Code,IDT.Serial) as Decimal(18,6))) Else 0 End) 'TotInvSchemeValue',
	
            (Case When Len(IsNull(IDT.MultipleSchemeID,'')) >0 Then dbo.merp_fn_List_CSIDByRFA(IsNull(IDT.MultipleSchemeID,''),@Claimable) Else '' End) 'SchemeID', 			
            (Case When Len(IsNull(IDT.MultipleSchemeID,'')) >0 Then dbo.merp_fn_Get_CSValueByRFA(IsNull(IDT.MultipleSchemeDetails,''),@Claimable,IDT.InvoiceID,I.Product_Code,IDT.Serial) Else '' End) 'SchemeValue',
            (Case When Len(IsNull(IDT.MultipleSchemeID,'')) > 0 Then Max(IDT.SchemeDiscAmount) Else 0 End) 'TotSchemeValue',

            (Case When Len(IsNull(IDT.MultipleSplCatSchemeID,'')) > 0 then dbo.merp_fn_List_CSIDByRFA(IsNull(IDT.MultipleSplCatSchemeID,''),@Claimable) Else '' End) 'SplCatSchemeID', 
            (Case When Len(IsNull(IDT.MultipleSplCatSchemeID,'')) > 0 then dbo.merp_fn_Get_CSValueByRFA(IsNull(IDT.MultipleSplCategorySchDetail,''),@Claimable,IDT.InvoiceID,I.Product_Code,IDT.Serial) Else '' End)  'SplCatSchemeValue',
            (Case When Len(IsNull(IDT.MultipleSplCatSchemeID,'')) > 0 Then Max(IDT.SplCatDiscAmount) Else 0 End) 'TotSplCatSchemeValue',

		 -- (Case When (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) >0 Then (Sum(IDT.Quantity) * Max(IDT.SalePrice))Else 0 End ),
		 --((Sum(IDT.Quantity) * Max(IDT.SalePrice)) * (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) /100),
			(Case When Max(IA.AdditionalDiscount) > 0 Then (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) ) Else 0 End ),
			((((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.AdditionalDiscount)) / 100) ) --,
		--	(Case When (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) > 0 Then (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue))) Else 0 End),
		--	((((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) / 100))
		From    
			InvoiceAbstract IA, InvoiceDetail IDT, Items I, Customer C, #TempSelCatsLeaf Cat
		Where 
			IA.Status & 128 = 0
			And IA.InvoiceType in (1,3)		
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
			Cat.SelCat, Cat.SelCatName, Cat.LeafCat, C.ChannelType, IA.SalesManID, IA.BeatID,  IA.MultipleSchemeDetails,
            IDT.MultipleSchemeID, IDT.MultipleSchemeDetails, IDT.MultipleSplCatSchemeID, IDT.MultipleSplCategorySchDetail,
			IA.CustomerID,IDT.InvoiceID,IA.InvoiceType, I.Product_Code ,IA.InvoiceSchemeID, 
			IDT.Serial, IDT.SplCatSerial, IDT.FreeSerial, IDT.Flagword --, IDT.SchemeID, IDT.SplCatSchemeID
	Else --'Category Wise'
		Insert Into #TempSale
			(SelCat,SelCatName,DivCat,DivCatName,CatID,Channel,SalesManID,Beat,CustomerID,
			ItemCode,UOM,UOM1,UOM2,Serial,
            SchItem_Code,SchQty,SchUOM,SchValue,TotSchValue,
            SplSchItem_Code,SplSchQty,SplSchUOM,SplSchValue,TotSplSchValue,
            FreeSerial,
			TotQty,NetValue,DiscSalValue, InvSchemeID, InvSchemeValue, TotInvSchemeValue, 
            SchemeID, SchemeValue, TotSchemeValue, SplCatSchemeID, SplCatSchemeValue, TotSplCatSchemeValue,
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
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 1, 1,I.Product_Code,IDT.Serial) 'SchItem_Code',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 2, 1,I.Product_Code,IDT.Serial) 'SchQty',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 5, 1,I.Product_Code,IDT.Serial) 'SchUOM',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 3, 1,I.Product_Code,IDT.Serial) 'SchValue',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 4, 1,I.Product_Code,IDT.Serial) 'TotSchValue',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 1, 2,I.Product_Code,IDT.Serial) 'SplSchItem_Code',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 2, 2,I.Product_Code,IDT.Serial) 'SplSchQty',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 5, 2,I.Product_Code,IDT.Serial) 'SplSchUOM',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 3, 2,I.Product_Code,IDT.Serial) 'SplSchValue',
            dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 4, 2,I.Product_Code,IDT.Serial) 'TotSplSchValue',

            (Select Case When Flagword=1 And Len(IsNull(FreeSerial,'')) > 0 then Min(FreeSerial) 
                        When Flagword=1 And Len(IsNull(SplCatSerial,'')) > 0 then Min(SplCatSerial) 
                        Else '' End
            from InvoiceDetail Where InvoiceID = IDT.InvoiceID 
            and Cast(Serial as nVarchar(100)) in (
                Case When IDT.Flagword=1 And Len(IsNull(IDT.FreeSerial,'')) > 0 then (IsNull(Min(IDT.FreeSerial),''))
                        When IDT.Flagword=1 And Len(IsNull(IDT.SplCatSerial,'')) > 0 then 
			(IsNull(Min(IDT.SplCatSerial),'')) Else '' End) Group by Flagword, IsNull(SplCatSerial,''),
			IsNull(FreeSerial,'') ),

            --(Select Min(SplCatSerial) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Cast(Serial as nVarchar(100)) in (IsNull(Min(IDT.SplCatSerial),''))),
            Sum(IDT.Quantity) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),
			Max(IDT.Amount),
			(Case When (Max(IA.DiscountValue) <> 0 Or Max(IA.AddlDiscountValue) <> 0 or Max(IDT.DiscountValue) <> 0 Or Max(IDT.SchemeID) <> 0 Or Max(IDT.SplCatSchemeID) <> 0) Then Max(IDT.Amount) Else 0 End),
            (Case When Len(IsNull(IA.InvoiceSchemeID,'')) > 0 Then dbo.merp_fn_List_CSIDByRFA(IA.InvoiceSchemeID,@Claimable) Else '0' End) 'InvSchemeID', 	
		
            (Case When 
              (Len(IsNull(IA.InvoiceSchemeID,'')) = 0 AND Max(IA.SchemeDiscountPercentage) > 0) Then dbo.merp_fn_Get_CSValueByRFA(IsNull(IA.MultipleSchemeDetails,''),@Claimable,IDT.InvoiceID,I.Product_Code,IDT.Serial) 
            When
              (Len(IsNull(IA.InvoiceSchemeID,'')) > 0 AND Max(IA.SchemeDiscountPercentage) > 0) Then (dbo.merp_fn_Get_CSValueByRFA(IsNull(IA.MultipleSchemeDetails,''),@Claimable,IDT.InvoiceID,I.Product_Code,IDT.Serial) + Char(15) + dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, IsNull(IA.InvoiceSchemeID,''), @FreeValAt, 1, 3,I.Product_Code,IDT.Serial))
            When 
              (Len(IsNull(IA.InvoiceSchemeID,'')) > 0 AND Max(IA.SchemeDiscountPercentage) = 0) Then dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, IsNull(IA.InvoiceSchemeID,''), @FreeValAt, 1, 3,I.Product_Code,IDT.Serial) Else '0' End) 'InvSchemeValue',  
            
			--(Case When Len(IsNull(IA.InvoiceSchemeID,'')) > 0 Then (Max(IA.SchemeDiscountAmount) + Cast(dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, IsNull(IA.InvoiceSchemeID,''), @FreeValAt, 2, 3) as Decimal(18,6))) Else 0 End) 'TotInvSchemeValue',
			(Case When Len(IsNull(IA.InvoiceSchemeID,'')) > 0 Then ((dbo.merp_fn_Get_InvSchemeValue(IDT.InvoiceID,I.Product_Code,IDT.Serial)) + Cast(dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, IsNull(IA.InvoiceSchemeID,''), @FreeValAt, 2, 3,I.Product_Code,IDT.Serial) as Decimal(18,6))) Else 0 End) 'TotInvSchemeValue',

            (Case When Len(IsNull(IDT.MultipleSchemeID,'')) >0 Then dbo.merp_fn_List_CSIDByRFA(IsNull(IDT.MultipleSchemeID,''),@Claimable) Else '' End) 'SchemeID', 			
            (Case When Len(IsNull(IDT.MultipleSchemeID,'')) >0 Then dbo.merp_fn_Get_CSValueByRFA(IsNull(IDT.MultipleSchemeDetails,''),@Claimable,IDT.InvoiceID,I.Product_Code,IDT.Serial) Else '' End) 'SchemeValue',
            (Case When Len(IsNull(IDT.MultipleSchemeID,'')) > 0 Then Max(IDT.SchemeDiscAmount) Else 0 End) 'TotSchemeValue',

            (Case When Len(IsNull(IDT.MultipleSplCatSchemeID,'')) > 0 then dbo.merp_fn_List_CSIDByRFA(IsNull(IDT.MultipleSplCatSchemeID,''),@Claimable) Else '' End) 'SplCatSchemeID', 
            (Case When Len(IsNull(IDT.MultipleSplCatSchemeID,'')) > 0 then dbo.merp_fn_Get_CSValueByRFA(IsNull(IDT.MultipleSplCategorySchDetail,''),@Claimable,IDT.InvoiceID,I.Product_Code,IDT.Serial) Else '' End)  'SplCatSchemeValue',
            (Case When Len(IsNull(IDT.MultipleSplCatSchemeID,'')) > 0 Then Max(IDT.SplCatDiscAmount) Else 0 End) 'TotSplCatSchemeValue',

		 -- (Case When (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) >0 Then (Sum(IDT.Quantity) * Max(IDT.SalePrice))Else 0 End ),
		 -- ((Sum(IDT.Quantity)* Max(IDT.SalePrice)) * (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) /100),
			(Case When Max(IA.AdditionalDiscount) > 0 Then (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) ) Else 0 End ),
			((((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.AdditionalDiscount)) / 100) ) --,
		--	(Case When (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) > 0 Then (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue))) Else 0 End),
		--	((((sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) / 100))
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
				Cat.SelCat, Cat.SelCatName,Cat.LeafCat, C.ChannelType, IA.SalesManID, IA.BeatID,  IA.MultipleSchemeDetails,
                IDT.MultipleSchemeID, IDT.MultipleSchemeDetails, IDT.MultipleSplCatSchemeID, IDT.MultipleSplCategorySchDetail, 	
			    IA.CustomerID,IDT.InvoiceID,IA.InvoiceType, I.Product_Code ,IA.InvoiceSchemeID, 
				IDT.Serial, IDT.SplCatSerial, IDT.FreeSerial, IDT.Flagword	-- ,IDT.SchemeID, IDT.SplCatSchemeID,IDT.Serial

    --select * from #TempSale

	Update #TempSale Set SchemeID= '' Where IsNull(SchItem_Code,'') = '' And IsNull(SchQty,0) = 0 And IsNull(SchemeValue,'') = ''
	Update #TempSale Set SplCatSchemeID = '' Where IsNull(SplSchItem_Code,'') = '' And IsNull(SplSchQty,0) = 0 And IsNull(SplCatSchemeValue,'') = ''
	Update #TempSale Set SchemeValue = 0, SchValue = 0 Where (Len(IsNull(SchemeID,'')) =  0 Or IsNull(SchemeID,'') = '')
	Update #TempSale Set SplCatSchemeValue = 0,SplSchValue = 0 Where (Len(IsNull(SplCatSchemeID,'')) = 0 Or IsNull(SplCatSchemeID,'') = '')
	Update #TempSale Set InvSchemeValue = 0 Where (Len(IsNull(InvSchemeID,'')) = 0 Or IsNull(InvSchemeID,'') = '')
    
	Update #TempSale Set SplFlag = 0 Where Serial not in (IsNull(FreeSerial,''))
	--Update #TempSale Set SplFlag = 1 Where Serial = Case CharIndex(',',FreeSerial) When 0 Then FreeSerial Else Left(FreeSerial,CharIndex(',',FreeSerial)-1) End
    Update #TempSale Set SplFlag = 1 Where Serial in  (IsNull(FreeSerial,''))

	   
    Declare @TmpSchemesID Table (SchemeIDLst nVarchar(100), SchType Int)
    Insert into @TmpSchemesID
    Select IsNull(SchemeID,''), 1 from #TempSale Where IsNull(SchemeID,N'') <> N''
    Union 
    Select IsNull(SplCatSchemeID,N''),2 from #TempSale Where IsNull(SplCatSchemeID,N'') <> N''
    Union
    Select IsNull(InvSchemeID,N''),3 from #TempSale Where IsNull(InvSchemeID,N'') <> N''

    Declare @TempSchemes Table (SchemeType Int, SchemeID Int)
    Declare @SchemeIdLst nVarchar(100)
    Declare @SchemeType Int
    Declare CurTempSchIdLst Cursor For
    Select SchemeIDLst,SchType From @TmpSchemesID
    Open CurTempSchIdLst
    Fetch Next From CurTempSchIdLst Into @SchemeIdLst, @SchemeType
    While @@FEtch_Status = 0 
    Begin
      Insert Into @TempSchemes
      Select @SchemeType, ItemValue from dbo.Sp_SplitIn2Rows(@SchemeIdLst,',') Where ItemValue > 0 And ItemValue not In (Select SchemeID From @TempSchemes)
      Fetch Next From CurTempSchIdLst Into @SchemeIdLst, @SchemeType
    End
    Close CurTempSchIdLst 
    Deallocate CurTempSchIdLst

	Select @SchDispOption = Count(Distinct SchemeID) from @TempSchemes Where SchemeType = 1
	Select @SplSchDispOption = Count(Distinct SchemeID) from @TempSchemes Where SchemeType = 2
	Select @InvDispOption = Count(Distinct SchemeID) from @TempSchemes Where SchemeType = 3
End


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
Declare @DiscSalValue decimal(18,6)
Declare @InvSchID nVarchar(500)
Declare @InvSchValue nvarchar(500)
Declare @TotInvSchValue decimal(18,6)
Declare @Flag int
Declare @SchemeID int
Declare @SchemeValue Decimal(18,6)
Declare @SplCatSchemeValue nvarchar(510)
Declare @ItmSchemeValue nvarchar(510)
Declare @SADisc decimal(18,6)
Declare @SNetVlaue Decimal(18,6)
Declare @SSchValue nvarchar(510)
Declare @SSchItem_Code nVarChar(510)
Declare @SSchQty  nVarchar(510)
Declare @SSchUOM nVarchar(510)
Declare @ItemCode nvarchar(50)
Declare @nSchQty  decimal(18,6)
Declare @FreeSerial as nvarchar(50)

Declare @SSplSchValue nVarChar(510)
Declare @SSplSchItem_Code  nVarchar(510)
Declare @SSplSchQty nVarchar(510)
Declare @SSplSchUom nvarchar(50)

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
 InvSchemeID int,
 InvSchemeValue decimal(18,6),
 TotInvSchemeValue decimal(18,6),
 ANetValue Decimal(18,6),
 ADisc Decimal(18,6),
 /*SchItem_Code nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
 SchQty nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
 SchUOM nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,*/
 Flag int  
 )

 Create table #TmpFreeItem
 (
 ItemCode nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
 SchItem_Code nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
 SchQty decimal(18,6),
 SchUOM decimal(18,6),
 RowNumber int 
 )
 
 Create table #TmpFreeSplItem
 (
    ItemCode nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
	SplSchItem_Code nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
	SplSchQty decimal(18,6),
	SplSchUOM decimal(18,6),
    RowNumber int   
  )

   Create table #TmpFreeItemCode
  (
	RowID int,ItemCode nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS    	
   )  
   Create table #TmpFreeQty
  (
	RowID int,Quantity Decimal(18,6) 	
   )  
    Create table #TmpFreeUOM
  (
	RowID int,UOM decimal(18,6)
   ) 

 Create table #TmpFinal
(CatID int,
 DivCat int,
 DivCatName nVarChar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,
 ItemCode nvarchar(50),	
 UOM int,
 UOM1 int,
 UOM2 int, 
 TotQty decimal(18,6),
 NetValue decimal(18,6),
 DiscSalValue decimal(18,6), 

 SchItem_Code nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
 SchQty nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
 SchUOM nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
 SchValue nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
 TotSchValue Decimal(18,6),

 SplSchItem_Code nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
 SplSchQty nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
 SplSchUOM nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
 SPlSchValue nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
 TotSPlSchValue Decimal(18,6),

 InvSchemeID nVarchar(501)COLLATE SQL_Latin1_General_CP1_CI_AS,
 InvSchemeValue nVarchar(501) COLLATE SQL_Latin1_General_CP1_CI_AS,
 TotInvSchemeValue decimal(18,6),

 SplCatSchemeID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
 SplCatSchemeValue nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
 TotSplCatSchemeValue Decimal(18,6),

 SchemeID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
 SchemeValue nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
 TotSchemeValue Decimal(18,6),

 ANetValue Decimal(18,6),
 ADisc Decimal(18,6),
 ItemRowsCount Int Default 0	
 )
 
create table #TmpInvSchemeID(SchemeID int)
create table #TmpSchData(SchemeData nvarchar(510))
--Declare @TmpSchData Table (SchemeData nVarchar(510))

Declare CUR_SCHITEM Cursor for select ItemCode from #TempSale Group by ItemCode
Open CUR_SCHITEM
Fetch Next From CUR_SCHITEM Into @Prod_Code
While @@Fetch_Status=0
Begin

    /* Item Based Free Item Schemes are Grouped, when more than one row exists for a single scheme on single item*/
    Select CatID,DivCat,DivCatName,UOM,UOM1,UOM2, Serial, TotQty, NetValue, DiscSalValue,
    InvSchemeID,InvSchemeValue, TotInvSchemeValue, SplCatSchemeValue,SchemeValue, ANetValue,ADisc,
    SchValue,SchItem_Code,SchQty,SchUOM,SplSchValue,SplSchItem_Code,SplSchQty,SplSchUom, FreeSerial
    Into #tmpSalGrp
    From (
      select CatID,DivCat,DivCatName,UOM,UOM1,UOM2,Min(Serial)'Serial',Sum(TotQty)'TotQty',Sum(NetValue)'NetValue',Sum(DiscSalValue)'DiscSalValue',
      InvSchemeID,InvSchemeValue,Sum(TotInvSchemeValue)'TotInvSchemeValue',SplCatSchemeValue,SchemeValue,Sum(ANetValue)'ANetValue',Sum(ADisc)'ADisc',
      SchValue,SchItem_Code,SchQty,SchUOM,SplSchValue,SplSchItem_Code,SplSchQty,SplSchUom, IsNull(FreeSerial,'') 'FreeSerial'
      from  #TempSale where ItemCode=@Prod_Code and (Len(IsNull(SchItem_Code,'')) > 0)
      Group by CatID,DivCat,DivCatName,UOM,UOM1,UOM2,InvSchemeID,InvSchemeValue,SplCatSchemeValue,SchemeValue,
      SchValue,SchItem_Code,SchQty,SchUOM,SplSchValue,SplSchItem_Code,SplSchQty,SplSchUom, IsNull(FreeSerial,'')
      Union all
      select CatID,DivCat,DivCatName,UOM,UOM1,UOM2,Serial,TotQty,NetValue,DiscSalValue,
      InvSchemeID,InvSchemeValue,TotInvSchemeValue,SplCatSchemeValue,SchemeValue,ANetValue,ADisc,
      SchValue,SchItem_Code,SchQty,SchUOM,SplSchValue,SplSchItem_Code,SplSchQty,SplSchUom,IsNull(FreeSerial,'')
      from  #TempSale where ItemCode=@Prod_Code and (Len(IsNull(SchItem_Code,'')) = 0)
        ) A

--    select * from #tmpSalGrp

    Declare Cur_SchItmDetail Cursor for 
    Select CatID,DivCat,DivCatName,UOM,UOM1,UOM2,Serial,TotQty,NetValue,DiscSalValue,
      InvSchemeID,InvSchemeValue,TotInvSchemeValue,SplCatSchemeValue,SchemeValue,ANetValue,ADisc,
      SchValue,SchItem_Code,SchQty,SchUOM,SplSchValue,SplSchItem_Code,SplSchQty,SplSchUom, FreeSerial
    From #tmpSalGrp
    Open Cur_SchItmDetail
	Fetch Next From Cur_SchItmDetail Into @SCatID,@SDivCat,@SDivCatName,@SUOM,@SUOM1,@SUOM2,@Serial,@TotQty,
    @NetValue,@DiscSalValue, @InvSchID,@InvSchValue,@TotInvSchValue,@SplCatSchemeValue,
    @ItmSchemeValue,@SNetVlaue,@SADisc,@SSchValue,@SSchItem_Code,@SSchQty,@SSchUOM,
    @SSplSchValue,@SSplSchItem_Code,@SSplSchQty,@SSplSchUom, @FreeSerial

	While @@Fetch_Status=0
	Begin
		
		Insert into #TmpSchData 
		Select * from dbo.sp_SplitIn2Rows(@InvSchValue, @Delimeter) Where ItemValue <> ''
        Declare CutSchemeList Cursor For		
		Select CAST(Left(SchemeData, (CharIndex(N'|',SchemeData))-1) as INT),
        substring(SchemeData,charindex('|',SchemeData)+1,len(SchemeData)) 
		From #TmpSchData  where SchemeData <>'0'
        Open CutSchemeList     
		Fetch Next From CutSchemeList Into @SchemeID,@SchemeValue
        While @@Fetch_Status=0
        Begin
             Insert into #TmpResult Values(@SCatID,@SDivCat,@SDivCatName,@Prod_Code,@SUOM,@SUOM1,@SUOM2,@Serial,@TotQty,
			 @NetValue,@DiscSalValue, @SchemeID,@SchemeValue,@SchemeValue,@SNetVlaue,@SADisc,1)
			 --@SSchItem_Code,@SSchQty,@SSchUOM, 				 
             Fetch Next From CutSchemeList Into @SchemeID,@SchemeValue
             set @TotQty=0
             Set @NetValue=0
             Set @DiscSalValue=0
        End
		Truncate table #TmpSchData
        Close  CutSchemeList
		Deallocate CutSchemeList
        
		Insert into #TmpSchData 
		Select * from dbo.sp_SplitIn2Rows(@SplCatSchemeValue, @Delimeter) Where ItemValue <> ''                                          
		Declare CutSchemeList Cursor For
		Select CAST(Left(SchemeData, (CharIndex(N'|',SchemeData))-1) as INT),
        substring(SchemeData,charindex('|',SchemeData)+1,len(SchemeData)) 
		From #TmpSchData  where SchemeData <>'0'
        Open CutSchemeList     
		Fetch Next From CutSchemeList Into @SchemeID,@SchemeValue
        While @@Fetch_Status=0
        Begin
             Insert into #TmpResult Values(@SCatID,@SDivCat,@SDivCatName,@Prod_Code,@SUOM,@SUOM1,@SUOM2,@Serial,@TotQty,
			 @NetValue,@DiscSalValue, @SchemeID,@SchemeValue,@SchemeValue,@SNetVlaue, Case when @TotQty > 1 then @SADisc Else 0 End ,2)
			 --@SSchItem_Code,@SSchQty,@SSchUOM,			 
             Fetch Next From CutSchemeList Into @SchemeID,@SchemeValue
             set @TotQty=0
             Set @NetValue=0
             Set @DiscSalValue=0
        End
		Truncate table #TmpSchData
        Close  CutSchemeList
		Deallocate CutSchemeList


		Insert into #TmpSchData 
		Select * from dbo.sp_SplitIn2Rows(@SSplSchValue, @Delimeter) Where ItemValue <> ''                                          
		Declare CutSchemeList Cursor For
		Select CAST(Left(SchemeData, (CharIndex(N'|',SchemeData))-1) as INT),
        substring(SchemeData,charindex('|',SchemeData)+1,len(SchemeData)) 
		From #TmpSchData  where SchemeData <>'0'
        Open CutSchemeList     
		Fetch Next From CutSchemeList Into @SchemeID,@SchemeValue
        While @@Fetch_Status=0
        Begin
             Insert into #TmpResult Values(@SCatID,@SDivCat,@SDivCatName,@Prod_Code,@SUOM,@SUOM1,@SUOM2,@Serial,@TotQty,
			 @NetValue,@DiscSalValue, @SchemeID,@SchemeValue,@SchemeValue,@SNetVlaue, Case when @TotQty > 1 then @SADisc Else 0 End ,2)
			 --@SSchItem_Code,@SSchQty,@SSchUOM,			 
             Fetch Next From CutSchemeList Into @SchemeID,@SchemeValue
             set @TotQty=0
             Set @NetValue=0
             Set @DiscSalValue=0
        End
		Truncate table #TmpSchData
        Close  CutSchemeList
		Deallocate CutSchemeList
		

		Insert into #TmpSchData 
		Select * from dbo.sp_SplitIn2Rows(@ItmSchemeValue, @Delimeter) Where ItemValue <> ''                                  
        Declare CutSchemeList Cursor For
		Select CAST(Left(SchemeData, (CharIndex(N'|',SchemeData))-1) as INT),
        substring(SchemeData,charindex('|',SchemeData)+1,len(SchemeData)) 
		From #TmpSchData  where SchemeData <>'0'
        Open CutSchemeList     
		Fetch Next From CutSchemeList Into @SchemeID,@SchemeValue
        While @@Fetch_Status=0
        Begin
             Insert into #TmpResult Values(@SCatID,@SDivCat,@SDivCatName,@Prod_Code,@SUOM,@SUOM1,@SUOM2,@Serial,@TotQty,
			 @NetValue,@DiscSalValue, @SchemeID,@SchemeValue,@SchemeValue,@SNetVlaue, Case when @TotQty > 1 then @SADisc Else 0 End ,3)			 
             Fetch Next From CutSchemeList Into @SchemeID,@SchemeValue
             set @TotQty=0
             Set @NetValue=0
             Set @DiscSalValue=0
			 Set @SNetVlaue=0
             Set @SADisc=0
        End
		Truncate table #TmpSchData
        Close  CutSchemeList
		Deallocate CutSchemeList 


		Insert into #TmpSchData 
		Select * from dbo.sp_SplitIn2Rows(@SSchValue, @Delimeter) Where ItemValue <> ''                                          
		Declare CutSchemeList Cursor For
		Select CAST(Left(SchemeData, (CharIndex(N'|',SchemeData))-1) as INT),
        substring(SchemeData,charindex('|',SchemeData)+1,len(SchemeData)) 
		From #TmpSchData  where SchemeData <>'0'
        Open CutSchemeList     
		Fetch Next From CutSchemeList Into @SchemeID,@SchemeValue
        While @@Fetch_Status=0
        Begin
             Insert into #TmpResult Values(@SCatID,@SDivCat,@SDivCatName,@Prod_Code,@SUOM,@SUOM1,@SUOM2,@Serial,@TotQty,
			 @NetValue,@DiscSalValue, @SchemeID,@SchemeValue,@SchemeValue,@SNetVlaue,Case when @TotQty > 1 then @SADisc Else 0 End ,3)			 
             Fetch Next From CutSchemeList Into @SchemeID,@SchemeValue
             set @TotQty=0
             Set @NetValue=0
             Set @DiscSalValue=0
        End
		Truncate table #TmpSchData
        Close  CutSchemeList
		Deallocate CutSchemeList 
        
        If @SSchQty<>''
		Begin
			 Insert into #TmpFreeItemCode
			 select * from dbo.sp_SplitIn2Rows_WithID(@SSchItem_Code, '|') Where ItemValue <> ''
			 Insert into #TmpFreeQty
			 select * from dbo.sp_SplitIn2Rows_WithID(@SSchQty, '|') Where ItemValue <> ''
             Insert into #TmpFreeUOM
			 select * from dbo.sp_SplitIn2Rows_WithID(@SSchUOM, '|') Where ItemValue <> ''                   
             
             Declare CutSchFreeQty Cursor For select * from #TmpFreeItemCode
             Open CutSchFreeQty 
             Fetch Next From CutSchFreeQty into @RowID,@SSchItem_Code
			 While @@FETCH_STATUS=0
			 Begin
	           Insert into #TmpFreeItem(Itemcode,SchItem_Code,RowNumber)
               Values(@Prod_Code,@SSchItem_Code,@RowID)
               Update #TmpFreeItem set  SchQty=(select Quantity from #TmpFreeQty where RowID=@RowID)
               where RowNUmber=@RowID
			   Update #TmpFreeItem set  SchUom=(select UOM from #TmpFreeUOM where RowID=@RowID)
               where RowNUmber=@RowID
			   Fetch Next From CutSchFreeQty into @RowID,@SSchItem_Code
			 End
             close CutSchFreeQty
			 Deallocate CutSchFreeQty	
             Update #TmpFreeItem set RowNumber=0

             Truncate table #TmpFreeItemCode
             Truncate table #TmpFreeQty
			 Truncate table #TmpFreeUOM 
			
--			Set @nSchQty = Convert(decimal(18,2),@SSchQty)
--			insert into #TmpFreeItem Values(@Prod_Code,@SSchItem_Code,@nSchQty,@SSchUOM)	
		End
	
		If @SSplSchQty<>''
		Begin			 	
			 Insert into #TmpFreeItemCode
			 select * from dbo.sp_SplitIn2Rows_WithID(@SSplSchItem_Code, '|') Where ItemValue <> ''
			 Insert into #TmpFreeQty
			 select * from dbo.sp_SplitIn2Rows_WithID(@SSplSchQty, '|') Where ItemValue <> ''
             Insert into #TmpFreeUOM
			 select * from dbo.sp_SplitIn2Rows_WithID(@SSplSchUom, '|') Where ItemValue <> ''                   
             
             Declare CutSchFreeQty Cursor For select * from #TmpFreeItemCode
             Open CutSchFreeQty 
             Fetch Next From CutSchFreeQty into @RowID,@SSplSchItem_Code
			 While @@FETCH_STATUS=0
			 Begin
	             Insert into #TmpFreeSplItem(Itemcode,SplSchItem_Code,RowNumber)
                 Values(@Prod_Code,@SSplSchItem_Code,@RowID)
               Update #TmpFreeSplItem set  SplSchQty=(select Quantity from #TmpFreeQty where RowID=@RowID)
               where RowNUmber=@RowID
				 Update #TmpFreeSplItem set  SplSchUom=(select UOM from #TmpFreeUOM where RowID=@RowID)
               where RowNUmber=@RowID
				 Fetch Next From CutSchFreeQty into @RowID,@SSplSchItem_Code
			 End
             close CutSchFreeQty
			 Deallocate CutSchFreeQty	
             Update #TmpFreeSplItem set RowNumber=0
             Truncate table #TmpFreeItemCode
             Truncate table #TmpFreeQty
			 Truncate table #TmpFreeUOM    	 
		End
		                      
	    Fetch Next From Cur_SchItmDetail Into @SCatID,@SDivCat,@SDivCatName,@SUOM,@SUOM1,@SUOM2,@Serial,@TotQty,
        @NetValue,@DiscSalValue, @InvSchID,@InvSchValue,@TotInvSchValue,@SplCatSchemeValue,@ItmSchemeValue,
        @SNetVlaue,@SADisc,@SSchValue,@SSchItem_Code,@SSchQty,@SSchUOM,
        @SSplSchValue,@SSplSchItem_Code,@SSplSchQty,@SSplSchUom, @FreeSerial
    End 
    Close Cur_SchItmDetail
	Deallocate Cur_SchItmDetail	
		
	Declare Cur_SchFinal Cursor for select CatID,DivCat,DivCatName,itemcode,UOM,UOM1,UOM2,sum(TotQty),sum(NetValue),sum(DiscSalValue),InvSchemeID,sum(InvSchemeValue),
    sum(TotInvSchemeValue),Flag,sum(ANetValue),sum(ADisc)
    --,SchItem_Code,SchQty,SchUOM  
    from #TmpResult 
    Group by CatID ,DivCat,DivCatName,itemcode,UOM ,UOM1,UOM2,InvSchemeID,Flag
    --,SchItem_Code,SchQty,SchUOM  
    order by Flag

    Open Cur_SchFinal
    Fetch Next From Cur_SchFinal Into @SCatID,@SDivCat,@SDivCatName,@ItemCode,@SUOM,@SUOM1,@SUOM2,@TotQty,
    @NetValue,@DiscSalValue, @SchemeID,@SchemeValue,@TotInvSchValue,@Flag,@SNetVlaue,@SADisc
    --,@SSchItem_Code,@SSchQty,@SSchUOM    
    While @@Fetch_Status=0
    Begin

        If ((@NetValue>0 or @DiscSalValue>0 or @SchemeID >0) and Not exists(select * from #TmpFinal where ItemCode=@Prod_Code))
        Begin
		   Set	@InvSchID=cast(@SchemeID as varchar)
           Set	@InvSchValue=cast(cast(@SchemeValue as decimal(18,2)) as varchar)
           If @Flag=1
			Insert into #TmpFinal(CatID,DivCat,DivCatName,ItemCode,UOM,UOM1,UOM2,TotQty,NetValue,DiscSalValue,
			InvSchemeID,InvSchemeValue,TotInvSchemeValue,ANetValue,ADisc,ItemRowsCount)
            Values(@SCatID,@SDivCat,@SDivCatName,@Prod_Code,@SUOM,@SUOM1,@SUOM2,@TotQty,
			@NetValue,@DiscSalValue,@InvSchID,@InvSchValue,@TotInvSchValue,@SNetVlaue,@SADisc,1)
           Else if @Flag=2
            Insert into #TmpFinal(CatID,DivCat,DivCatName,ItemCode,UOM,UOM1,UOM2,TotQty,NetValue,DiscSalValue,
			SplCatSchemeID,SplCatSchemeValue,TotSplCatSchemeValue,ANetValue,ADisc,ItemRowsCount)
            Values(@SCatID,@SDivCat,@SDivCatName,@Prod_Code,@SUOM,@SUOM1,@SUOM2,@TotQty,
			@NetValue,@DiscSalValue,@InvSchID,@InvSchValue,@TotInvSchValue,@SNetVlaue,@SADisc,1)
           Else
			Insert into #TmpFinal(CatID,DivCat,DivCatName,ItemCode,UOM,UOM1,UOM2,TotQty,NetValue,DiscSalValue,
			SchemeID,SchemeValue,TotSchemeValue,ANetValue,ADisc,ItemRowsCount)--,SchItem_Code,SchQty,SchUOM
			Values(@SCatID,@SDivCat,@SDivCatName,@Prod_Code,@SUOM,@SUOM1,@SUOM2,@TotQty,
			@NetValue,@DiscSalValue,@InvSchID,@InvSchValue,@TotInvSchValue,@SNetVlaue,@SADisc,1)  --,@SSchItem_Code,@SSchQty,@SSchUOM
        End
        Else
        Begin
			 If @Flag=1
			 Begin
			   Update #TmpFinal set InvSchemeID=InvSchemeID+','+ cast(@SchemeID as nvarchar),
               InvSchemeValue=InvSchemeValue+'|'+cast(cast(@SchemeValue as decimal(18,2)) as nvarchar),               
			   TotInvSchemeValue=TotInvSchemeValue+@TotInvSchValue,
               TotQty=TotQty+ @TotQty,NetValue=NetValue+@NetValue,
               DiscSalValue=DiscSalValue+ @DiscSalValue,
               ANetValue=ANetValue+@SNetVlaue,
               ADisc=ADisc+@SADisc
               where ItemCode=@Prod_Code 
			 End
			 Else If @Flag=2
			 Begin           
			   select @SplCatSchemeValue=SplCatSchemeID from #TmpFinal
			   if @SplCatSchemeValue is null
				Update #TmpFinal set SplCatSchemeID=cast(@SchemeID as nvarchar),SplCatSchemeValue=cast(cast(@SchemeValue as decimal(18,2)) as nvarchar)	
				 ,TotSplCatSchemeValue=@TotInvSchValue,
				TotQty=TotQty+ @TotQty,NetValue=NetValue+@NetValue,
                DiscSalValue=DiscSalValue+ @DiscSalValue,
                ANetValue=ANetValue+@SNetVlaue,
                ADisc=ADisc+@SADisc
                where ItemCode=@Prod_Code 
			   Else  	
				Update #TmpFinal set SplCatSchemeID=SplCatSchemeID+','+ cast(@SchemeID as nvarchar),SplCatSchemeValue=SplCatSchemeValue+'|'+cast(cast(@SchemeValue as decimal(18,2)) as nvarchar)
				,TotSplCatSchemeValue=TotSplCatSchemeValue+@TotInvSchValue,
				TotQty=TotQty+ @TotQty,NetValue=NetValue+@NetValue,
                DiscSalValue=DiscSalValue+ @DiscSalValue,
                ANetValue=ANetValue+@SNetVlaue,
                ADisc=ADisc+@SADisc
                where ItemCode=@Prod_Code
			 End
			 Else
			 Begin
			   Select @SplCatSchemeValue=SchemeID from #TmpFinal
			   If @SplCatSchemeValue is null
               Begin                 
					Update #TmpFinal set SchemeID=cast(@SchemeID as nvarchar),SchemeValue=cast(cast(@SchemeValue as decimal(18,2)) as nvarchar)
					 ,TotSchemeValue=@TotInvSchValue,
					 TotQty=TotQty+ @TotQty,NetValue=NetValue+@NetValue,
					 DiscSalValue=DiscSalValue+ @DiscSalValue,
                     ANetValue=ANetValue+@SNetVlaue,
                     ADisc=ADisc+@SADisc	
                     where ItemCode=@Prod_Code
                End
			   Else	
               Begin			
					Update #TmpFinal set SchemeID=SchemeID+','+ cast(@SchemeID as nvarchar),SchemeValue=SchemeValue+'|'+cast(cast(@SchemeValue as decimal(18,2)) as nvarchar)
					,TotSchemeValue=TotSchemeValue+@TotInvSchValue,
					TotQty=TotQty+ @TotQty,NetValue=NetValue+@NetValue,
					DiscSalValue=DiscSalValue+ @DiscSalValue,
					ANetValue=ANetValue+@SNetVlaue,
					ADisc=ADisc+@SADisc
                    where ItemCode=@Prod_Code
               End
			 End
        End
		Fetch Next From Cur_SchFinal Into @SCatID,@SDivCat,@SDivCatName,@ItemCode,@SUOM,@SUOM1,@SUOM2,@TotQty,
		@NetValue,@DiscSalValue, @SchemeID,@SchemeValue,@TotInvSchValue,@Flag,@SNetVlaue,@SADisc
        --@SSchItem_Code,@SSchQty,@SSchUOM  
    End
	Close Cur_SchFinal  
    Deallocate Cur_SchFinal
    Truncate table #TmpResult

    Declare Cur_FreeItems Cursor for select SchItem_Code,sum(SchQty),SchUOM 
    from #TmpFreeItem 
    where itemcode=@Prod_Code
    Group by Itemcode,SchItem_Code,SchUOM
    Open Cur_FreeItems
    Fetch Next from  Cur_FreeItems Into @SSchItem_Code,@nSchQty,@SSchUOM  
    While @@Fetch_Status=0
    Begin
		select @SplCatSchemeValue=SchItem_Code from #TmpFinal
        if 	@SplCatSchemeValue is null
		Update #TmpFinal set SchItem_Code=@SSchItem_Code,
					SchQty=cast(@nSchQty as nvarchar),
					SchUOM=cast(@SSchUOM as nvarchar)
					where ItemCode=@Prod_Code	
        else
		Update #TmpFinal set SchItem_Code=SchItem_Code+'|'+@SSchItem_Code,
					SchQty=SchQty+'|'+cast(@nSchQty as nvarchar),
					SchUOM=SchUOM+'|'+cast(@SSchUOM as nvarchar)
					where ItemCode=@Prod_Code
		Fetch Next from  Cur_FreeItems Into @SSchItem_Code,@nSchQty,@SSchUOM 
    End
    Close Cur_FreeItems
    Deallocate Cur_FreeItems
	Truncate table 	#TmpFreeItem
   
	Declare Cur_FreeItems Cursor for select SplSchItem_Code,
	sum(SplSchQty),
	SplSchUOM 
    from #TmpFreeSplItem 
    where itemcode=@Prod_Code
    Group by Itemcode,SplSchItem_Code,SplSchUOM

    Open Cur_FreeItems
    Fetch Next from  Cur_FreeItems Into @SSchItem_Code,@nSchQty,@SSchUOM  
    While @@Fetch_Status=0
    Begin
		select @SplCatSchemeValue=SplSchItem_Code from #TmpFinal		
        if 	@SplCatSchemeValue is null
		Update #TmpFinal set SplSchItem_Code=@SSchItem_Code,
					SplSchQty=cast(@nSchQty as nvarchar),
					SplSchUOM=cast(@SSchUOM as nvarchar)
					where ItemCode=@Prod_Code	
        else
		Update #TmpFinal set SplSchItem_Code=SplSchItem_Code+'|'+@SSchItem_Code,
					SplSchQty=SplSchQty+'|'+cast(@nSchQty as nvarchar),
					SplSchUOM=SplSchUOM+'|'+cast(@SSchUOM as nvarchar)
					where ItemCode=@Prod_Code
		Fetch Next from  Cur_FreeItems Into @SSchItem_Code,@nSchQty,@SSchUOM 
    End
    Close Cur_FreeItems
    Deallocate Cur_FreeItems
	Truncate table 	#TmpFreeSplItem
    Drop table #tmpSalGrp

	Fetch Next From CUR_SCHITEM Into @Prod_Code
End
close CUR_SCHITEM
deallocate CUR_SCHITEM


Insert into #TmpFinal(CatID,DivCat,DivCatName,ItemCode,UOM,UOM1,UOM2,TotQty,NetValue,DiscSalValue,
			InvSchemeID,InvSchemeValue,TotInvSchemeValue,SplCatSchemeID,SplCatSchemeValue,TotSplCatSchemeValue,
            SchemeID,SchemeValue,TotSchemeValue,ANetValue,ADisc,ItemRowsCount)
select CatID,DivCat,DivCatName,ItemCode,UOM,UOM1,UOM2,TotQty,NetValue,DiscSalValue,
			InvSchemeID,(InvSchemeValue),TotInvSchemeValue,
            SplCatSchemeID,(SplCatSchemeValue),TotSplCatSchemeValue,
            SchemeID,(SchemeValue),TotSchemeValue,ANetValue,ADisc,ItemRowsCount
from #TempSale 
where len(SchValue) < 2
and len(SPLSchValue) < 2 and len(InvSchemeValue)< 2 and len(SPlCatSchemeValue)< 2
and len(SchemeValue) < 2


--select * from #TmpFinal
 

/*
/* Field RowsCount is req When an Invoice made more than once with same Data */
Update TmpSal Set tmpSal.ItemRowsCount = tItemsal.ItemSchRowsCount
From #TempSale TmpSal,
(Select ItemCode, SchemeValue,SchemeID,Count(ItemCode +  SchemeValue + SCHEMEID ) as 'ItemSchRowsCount'  
 From #TempSale WHERE (ISNULL(SCHEMEID,'') <> '' ) Group By ItemCode, SchemeValue,SchemeID) tItemSal
Where tmpSal.ItemCode = tItemSal.ItemCode 
    And tmpSal.SchemeValue = tItemSal.SchemeValue
    And tmpSal.SCHEMEID = tItemSal.SCHEMEID


/* Field RowsCount is req When an Invoice made more than once with same Data [Special Category Scheme]*/
Update TmpSal Set tmpSal.SplCatRowsCount = tSplCatSal.SplCatRowsCount
From #TempSale TmpSal,
(Select ItemCode, SplCatSchemeValue, SplCatSchemeID,Count(ItemCode + SplCatSchemeValue + SplCatSchemeID ) as 'SplCatRowsCount'  
 From #TempSale WHERE (ISNULL(SPLCATSCHEMEID,'') <> '' ) Group By ItemCode, SplCatSchemeValue,SplCatSchemeID) tSplCatSal  
Where tmpSal.ItemCode = tSplCatSal.ItemCode And  
    tmpSal.SplCatSchemeValue = tSplCatSal.SplCatSchemeValue And
	tmpSal.SplCatSchemeID	= tSplCatSal.SplCatSchemeID 


Update TmpSal Set tmpSal.InvSchRowCount = tCatSal.InvSchRowCount
From #TempSale TmpSal,
(Select ItemCode, InvSchemeValue,InvSchemeID, Count(ItemCode + InvSchemeValue + InvSchemeID ) as 'InvSchRowCount'  
 From #TempSale WHERE (ISNULL(InvSchemeID,'') <> '' And  Cast(ISNULL(InvSchemeID,'') as nVarchar) <> '0' ) Group By ItemCode, InvSchemeValue,InvSchemeID) tCatSal  
Where tmpSal.ItemCode = tCatSal.ItemCode And  
    tmpSal.InvSchemeValue = tCatSal.InvSchemeValue And
	tmpSal.InvSchemeID = tCatSal.InvSchemeID*/


  Update TmpSal Set tmpSal.ItemRowsCount = tItemsal.ItemSchRowsCount
  From #TempSale TmpSal,
  (Select ItemCode, SchemeValue,SchemeID,InvSchemeID , InvSchemeValue , SplCatSchemeID , SplCatSchemeValue,Count(ItemCode +  SchemeValue + SCHEMEID + InvSchemeID + InvSchemeValue + SplCatSchemeID + SplCatSchemeValue ) as 'ItemSchRowsCount'
  From #TempSale WHERE (ISNULL(SCHEMEID,'') <> '' ) Group By ItemCode, SchemeValue,SchemeID,InvSchemeID , InvSchemeValue , SplCatSchemeID , SplCatSchemeValue) tItemSal
  Where tmpSal.ItemCode = tItemSal.ItemCode 
  And tmpSal.SchemeValue = tItemSal.SchemeValue
  And tmpSal.SCHEMEID = tItemSal.SCHEMEID
  and tmpSal.InvSchemeID = tItemSal.InvSchemeID
  and tmpSal.SplCatSchemeID = tItemSal.SplCatSchemeID 
  And tmpSal.InvSchemeValue = tItemSal.InvSchemeValue 
  And tmpSal.SplCatSchemeValue = tItemSal.SplCatSchemeValue 


/*To Group the Rows */
Select SelCat, SelCatName,DivCat,DivCatName,CatID,Channel,SalesManID, Beat, CustomerID, ItemCode, UOM, UOM1, UOM2, Min(Serial) 'Serial', Free, FreeValue, 
   SchItem_Code, SchQty,SchUOM, SchValue,TotSchValue, SplSchItem_Code,SplSchQty,SplSchUOM,SplSchValue,sum(TOtSplSchValue)'TOtSplSchValue', FreeSerial, SplFlag,
   Sum(TotQty) 'TotQty', Sum(NetValue) 'NetValue', Sum(DiscSalValue) 'DiscSalValue', InvSchemeId,InvSchemeValue,sum(TotInvSchemeValue)'TotInvSchemeValue', SchemeID, SchemeValue, sum(TotSchemeValue) 'TotSchemeValue',
   SplCatSchemeID, SplCatSchemeValue, sum(TotSplCatSchemeValue) 'TotSplCatSchemeValue',Sum(ANetValue)'ANetValue',Sum(ADisc)'ADisc',ItemRowsCount,SplCatRowsCount,InvSchRowCount
Into #TempSale2 From #TempSale
Group By SelCat, SelCatName,DivCat,DivCatName,CatID,Channel,SalesManID, Beat, CustomerID, ItemCode, UOM, UOM1, UOM2, Free, FreeValue, 
   SchItem_Code, SchQty,SchUOM, SchValue,TotSchValue, SplSchItem_Code,SplSchQty,SplSchUOM,SplSchValue,
   --TOtSplSchValue,
   FreeSerial, SplFlag,
   InvSchemeId,InvSchemeValue,
   --TotInvSchemeValue, 
    SchemeID, SchemeValue, 
   --TotSchemeValue,
   SplCatSchemeID, SplCatSchemeValue, 
   --TotSplCatSchemeValue,
   ItemRowsCount,SplCatRowsCount,InvSchRowCount


--select * from #TempSale2



/* Field RowsCount is req When an Invoice made more than once with same Data 
Update TmpSal Set tmpSal.ItemRowsCount = tItemsal.ItemSchRowsCount
From #TempSale2 TmpSal,
(Select ItemCode, SchemeValue,SchemeID,Count(ItemCode +  SchemeValue + SCHEMEID ) as 'ItemSchRowsCount'  
 From #TempSale2 WHERE (ISNULL(SCHEMEID,'') <> '' ) Group By ItemCode, SchemeValue,SchemeID) tItemSal
Where tmpSal.ItemCode = tItemSal.ItemCode 
    And tmpSal.SchemeValue = tItemSal.SchemeValue
    And tmpSal.SCHEMEID = tItemSal.SCHEMEID*/
	
/*Update TmpSal Set tmpSal.SplCatRowsCount = tSplCatSal.SplCatRowsCount
From #TempSale2 TmpSal,
(Select ItemCode, SplCatSchemeValue, SplCatSchemeID,Count(ItemCode + SplCatSchemeValue + SplCatSchemeID ) as 'SplCatRowsCount'  
 From #TempSale2 WHERE (ISNULL(SPLCATSCHEMEID,'') <> '' ) Group By ItemCode, SplCatSchemeValue,SplCatSchemeID) tSplCatSal  
Where tmpSal.ItemCode = tSplCatSal.ItemCode And  
    tmpSal.SplCatSchemeValue = tSplCatSal.SplCatSchemeValue And
	tmpSal.SplCatSchemeID	= tSplCatSal.SplCatSchemeID 

Update TmpSal Set tmpSal.InvSchRowCount = tCatSal.InvSchRowCount
From #TempSale2 TmpSal,
(Select ItemCode, InvSchemeValue,InvSchemeID, Count(ItemCode + InvSchemeValue + InvSchemeID ) as 'InvSchRowCount'  
 From #TempSale2 WHERE (ISNULL(InvSchemeID,'') <> '' And  Cast(ISNULL(InvSchemeID,'') as nVarchar) <> '0' ) Group By ItemCode, InvSchemeValue,InvSchemeID) tCatSal  
Where tmpSal.ItemCode = tCatSal.ItemCode And  
    tmpSal.InvSchemeValue = tCatSal.InvSchemeValue And
	tmpSal.InvSchemeID = tCatSal.InvSchemeID*/


If @DiscType = 'Scheme'
Begin
	Select "CatID" = Max(CatID),
	"Division" = Max(DivCatName),
	"Saleable Item Name" = Max(I.ProductName),
	"UOM" = Max(UOM.Description),
	"Quantity" = Sum(TotQty),
	"Value" = Sum(NetValue),
	
	"Scheme Name" = Case Len(IsNull(TS.SchItem_Code,'')) When 0 then '' else  Cast(dbo.mERP_fn_Get_CSDefnList(IsNull(TS.SchemeID,''),'Scheme','',Ts.ItemRowsCount) as nVarchar(100)) End,
	"Scheme Free Item Name" = Case When Len(IsNull(TS.SchemeID,'')) > 0 Then Cast(dbo.mERP_fn_Get_CSDefnList((TS.SchItem_Code),'Product','',Ts.ItemRowsCount) as nVarchar(100)) Else '' End,
	"Scheme UOM" =  Case When Len(IsNull(TS.SchItem_Code,'')) > 0 Then Cast(dbo.mERP_fn_Get_CSDefnList((TS.SchUOM),'UOM','',Ts.ItemRowsCount) as nVarchar(100)) Else '' End,
	"Scheme Quantity" = Case When Len(IsNull(TS.SchItem_Code,'')) > 0 Then Cast(dbo.mERP_fn_Get_CSDefnList((TS.SchQty),'Quantity',(TS.SchItem_Code),Ts.ItemRowsCount)as nVarchar(100)) Else '' End,
	--"Scheme Value" = Case When Len(IsNull(TS.SchemeID,'')) > 0 Then Cast(dbo.mERP_fn_Get_CSDefnList(IsNull(TS.SchValue,''), 'Value', IsNull(TS.SchemeValue,''),Ts.ItemRowsCount) as nVarchar(100)) Else '' End,
    "Scheme Value" = TS.SchemeValue,
 
    "Spl Scheme Name" = Case IsNull(TS.SplSchItem_Code,'') when '' Then Cast(dbo.mERP_fn_Get_CSDefnList(IsNull(TS.SplCatSchemeID,''),'Scheme','',TS.ItemRowsCount)as nVarchar(100)) Else Cast(dbo.mERP_fn_Get_CSDefnList(IsNull(TS.SplCatSchemeID,''),'scheme','',TS.ItemRowsCount)as nVarchar(100)) End,
	"Spl Scheme Free Item Name" = Case When Len(IsNull(TS.SplCatSchemeID,'')) > 0 Then (Case Len(IsNull(TS.SplSchItem_Code,'')) When 0 Then '' Else Cast(dbo.mERP_fn_Get_CSDefnList(IsNull(TS.SplSchItem_Code,''),'Product','',TS.ItemRowsCount) as nVarchar(100)) End) End,
	"Spl Scheme UOM" = Case When Len(IsNull(TS.SplCatSchemeID,'')) > 0 Then (Case Len(IsNull(TS.SplSchItem_Code,'')) When 0 Then '' Else Cast(dbo.mERP_fn_Get_CSDefnList(IsNull(TS.SplSchUOM,''),'UOM','',TS.ItemRowsCount)as nVarchar(100)) End) End,
	"Spl Scheme Quantity" = Case When Len(IsNull(TS.SplCatSchemeID,'')) > 0 Then (Case Len(IsNull(TS.SplSchItem_Code,'')) When 0 Then '' Else Cast(dbo.mERP_fn_Get_CSDefnList(IsNull(TS.SplSchQty,''),'Quantity',(TS.SplSchItem_Code),TS.ItemRowsCount)as nVarchar(100)) End) End,
	"Spl Scheme Value" = Case When Len(IsNull(TS.SplCatSchemeID,'')) > 0  Then (Case Len(IsNull(TS.SplSchItem_Code,'')) When '' Then dbo.mERP_fn_Get_CSDefnList('','value',IsNull(TS.SplCatSchemeValue,''),TS.ItemRowsCount) Else dbo.mERP_fn_Get_CSDefnList(IsNull(TS.SplSchValue,''),'Value',IsNull(Ts.SplCatSchemeValue,''),TS.ItemRowsCount) End) Else '' End,
	
    "Inv Scheme Name" = Case When Len(Isnull(TS.InvSchemeID,'')) > 0 then Cast(dbo.mERP_fn_Get_CSDefnList(IsNull(TS.InvSchemeID,''),'Scheme','',1) as nVarchar(100)) Else '' End,
	--"Inv Scheme Value" = Case When Len(IsNull(TS.InvSchemeID,'')) > 0 Then Cast(dbo.mERP_fn_Get_CSDefnList(IsNull(TS.InvSchemeValue,''),'Value','',TS.ItemRowsCount) as nVarchar(100))Else '' End,
    "Inv Scheme Value" = TS.InvSchemeValue,
	
    --"Total Discount Value" = Sum(IsNull(TotSchValue,0) + IsNull(TotSchemeValue,0) + IsNull(TotSplSchValue,0) + IsNull(TotSplCatSchemeValue,0) + IsNull(TotInvSchemeValue,0)) InTo #PreSchResult
    --Update the Invoice Scheme Value
	"Total Discount Value" = Sum(IsNull(TotSchValue,0) + IsNull(TotSchemeValue,0) + IsNull(TotSplSchValue,0) + IsNull(TotSplCatSchemeValue,0) + IsNull(InvSchemeValue,0)) InTo #PreSchResult
    
	--From  #TempSale2 TS,Items I, UOM, #TempCategory1 ISort
	From  #TmpFinal TS,Items I,UOM ,#TempCategory1 ISort
	Where TS.ItemCode = I.Product_Code
	And I.CategoryID = ISort.CategoryID
	And UOM.UOM = (Case @UOM when 'UOM2' Then TS.UOM2 When 'UOM1' Then TS.UOM1 Else TS.UOM End)
	Group By I.Product_Code, TS.SchemeID, TS.SplCatSchemeID, TS.InvSchemeID,  TS.SplSchItem_Code, ISort.IDS,TS.InvSchemeID, TS.InvSchemeValue, Ts.SchemeValue,
        TS.SchItem_Code, TS.SplSchItem_Code, TS.SchUOM, TS.SchQty, TS.SchValue, TS.SplSchUOM, TS.SplCatSchemeValue, TS.SplSchQty, TS.SPlSchValue, TS.ItemRowsCount
     --, TS.SplCatRowsCount,TS.InvSchRowCount
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
--Else If @DiscType = 'Product Discount'
--	Begin
--		Select "Code" = Max(CatID),
--		"Division" = Max(DivCatName),
--		"Saleable Item Name" = Max(I.ProductName),
--		"UOM" = Max(UOM.Description),
--		"Quantity" = Sum(TotQty),
--		"Value" = Sum(NetValue),
--		"Net Product Discount %" = Case When Abs(Sum(PNetValue)) > 0 Then Abs((Sum(PDisc)) / Abs(Sum(PNetValue))) * 100 Else 0 End,
--		"Product Discount" = Sum(PDisc) Into #PrePResult
--		from  #TempSale TS,Items I,UOM,#TempCategory1 ISort 
--		Where TS.ItemCode = I.Product_Code
--		And I.CategoryID = ISort.CategoryID
--		And UOM.UOM = (Case @UOM when 'UOM2' Then TS.UOM2 When 'UOM1' Then TS.UOM1 Else TS.UOM End)
--		Group By I.Product_Code,ISort.IDS
--		Order By ISort.IDS
--		Select *  from #PrePResult
--	End
Else If @DiscType = 'Addl. Discount' 
	Begin

		Select "Code" = Max(CatID),
		"Division" = Max(DivCatName),
		"Saleable Item Name" = Max(I.ProductName),
		"UOM" = Max(UOM.Description),
		"Quantity" = Sum(TotQty),
		"Value" = Sum(NetValue),
--		"Net Addl. Discount %" = Case When Abs(Sum(ANetValue)) > 0 Then Abs((Sum(ADisc)) / AbS(Sum(ANetValue))) * 100 Else 0 End,
--		"Addl. Discount" = Sum(ADisc) Into #PreAResult
		"Net Trade Discount %" = Case When Abs(Sum(ANetValue)) > 0 Then Abs((Sum(ADisc)) / AbS(Sum(ANetValue))) * 100 Else 0 End,
		"Trade Discount" = Sum(ADisc) Into #PreAResult
		from  #TempSale2 TS,Items I,UOM,#TempCategory1 ISort
		Where TS.ItemCode = I.Product_Code
		And I.CategoryID = ISort.CategoryID
		And UOM.UOM = (Case @UOM when 'UOM2' Then TS.UOM2 When 'UOM1' Then TS.UOM1 Else TS.UOM End)
		Group By I.Product_Code,ISort.IDS
		Order By ISort.IDS		
		
	End
--Else If @DiscType = 'Trade Discount'
--	Begin	
--		Select "Code" = Max(CatID),
--		"Division" = Max(DivCatName),
--		"Saleable Item Name" = Max(I.ProductName),
--		"UOM" = Max(UOM.Description),
--		"Quantity" = Sum(TotQty),
--		"Value" = Sum(NetValue),
--		"Net Trade Discount %" = Case When Abs(Sum(TNetValue)) > 0 Then Abs((Sum(TDisc)) / Abs(Sum(TNetValue))) * 100 Else 0 End,
--		"Trade Discount" = Sum(TDisc) Into #PreTResult
--		from  #TempSale TS,Items I,UOM,#TempCategory1 ISort
--		Where TS.ItemCode = I.Product_Code
--		And I.CategoryID = ISort.CategoryID
--		And UOM.UOM = (Case @UOM when 'UOM2' Then TS.UOM2 When 'UOM1' Then TS.UOM1 Else TS.UOM End)
--		Group By I.Product_Code,ISort.IDS
--		Order By ISort.IDS
--		Select * from #PreTResult
--	End
Else if @DiscType = 'Only Free Item'
	Select "Code" = Max(CatID),
	"Division" = Max(DivCatName),
	"Free Item Name" = Max(I.ProductName),
	"UOM" = Max(UOM.Description),
	"Quantity" = Sum(Free),
	"Value" = Sum(FreeValue)
	from  #TempSale2 TS,Items I,UOM,#TempCategory1 ISort
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

	"Scheme Name" = Case Len(IsNull(TS.SchemeID,'')) When 0 then '' else  Cast(dbo.mERP_fn_Get_CSDefnList(IsNull(TS.SchemeID,''),'Scheme','',Ts.ItemRowsCount) as nVarchar(100)) End,
	"Scheme Free Item Name" = Case When Len(IsNull(TS.SchItem_Code,'')) > 0 Then Cast(dbo.mERP_fn_Get_CSDefnList((TS.SchItem_Code),'Product','',Ts.ItemRowsCount) as nVarchar(100)) Else '' End,
	"Scheme UOM" =  Case When Len(IsNull(TS.SchItem_Code,'')) > 0 Then Cast(dbo.mERP_fn_Get_CSDefnList((TS.SchUOM),'UOM','',Ts.ItemRowsCount) as nVarchar(100)) Else '' End,
	"Scheme Quantity" = Case When Len(IsNull(TS.SchItem_Code,'')) > 0 Then Cast(dbo.mERP_fn_Get_CSDefnList((TS.SchQty),'Quantity',(TS.SchItem_Code),Ts.ItemRowsCount)as nVarchar(100)) Else '' End,
	--"Scheme Value" = Case When Len(IsNull(TS.SchemeID,'')) > 0 Then Cast(dbo.mERP_fn_Get_CSDefnList(IsNull(TS.SchValue,''), 'Value', IsNull(TS.SchemeValue,''),Ts.ItemRowsCount) as nVarchar(100)) Else '' End,
	"Scheme Value" = TS.SchemeValue,
 	
    "Spl Scheme Name" = Case IsNull(TS.SplCatSchemeID,'') when '' Then Cast(dbo.mERP_fn_Get_CSDefnList(IsNull(TS.SplCatSchemeID,''),'Scheme','',TS.ItemRowsCount)as nVarchar(100)) Else Cast(dbo.mERP_fn_Get_CSDefnList(IsNull(TS.SplCatSchemeID,''),'scheme','',TS.ItemRowsCount)as nVarchar(100)) End,
	"Spl Scheme Free Item Name" = Case When Len(IsNull(TS.SplSchItem_Code,'')) > 0 Then (Case Len(IsNull(TS.SplSchItem_Code,'')) When 0 Then '' Else Cast(dbo.mERP_fn_Get_CSDefnList(IsNull(TS.SplSchItem_Code,''),'Product','',TS.ItemRowsCount) as nVarchar(100)) End) End,
	"Spl Scheme UOM" = Case When Len(IsNull(TS.SplCatSchemeID,'')) > 0 Then (Case Len(IsNull(TS.SplSchItem_Code,'')) When 0 Then '' Else Cast(dbo.mERP_fn_Get_CSDefnList(IsNull(TS.SplSchUOM,''),'UOM','',TS.ItemRowsCount)as nVarchar(100)) End) End,
	"Spl Scheme Quantity" = Case When Len(IsNull(TS.SplCatSchemeID,'')) > 0 Then (Case Len(IsNull(TS.SplSchItem_Code,'')) When 0 Then '' Else Cast(dbo.mERP_fn_Get_CSDefnList(IsNull(TS.SplSchQty,''),'Quantity',(TS.SplSchItem_Code),TS.ItemRowsCount)as nVarchar(100)) End) End,
	"Spl Scheme Value" = Case When Len(IsNull(TS.SplCatSchemeID,'')) > 0  Then (Case Len(IsNull(TS.SplSchItem_Code,'')) When 0 Then dbo.mERP_fn_Get_CSDefnList('','value',IsNull(TS.SplCatSchemeValue,''),TS.ItemRowsCount) Else dbo.mERP_fn_Get_CSDefnList(IsNull(TS.SplSchValue,''),'Value',IsNull(Ts.SplCatSchemeValue,''),TS.ItemRowsCount) End) Else '' End,
	
    "Inv Scheme Name" = Case When Len(Isnull(TS.InvSchemeID,'')) > 0 then Cast(dbo.mERP_fn_Get_CSDefnList(IsNull(TS.InvSchemeID,''),'Scheme','',1) as nVarchar(100)) Else '' End,
	--"Inv Scheme Value" = Case When Len(IsNull(TS.InvSchemeID,'')) > 0 Then Cast(dbo.mERP_fn_Get_CSDefnList(IsNull(TS.InvSchemeValue,''),'Value','',TS.ItemRowsCount) as nVarchar(100))Else '' End,
    "Inv Scheme Value" = TS.InvSchemeValue,

   -- "Net Product Discount %" = Case When Abs(Sum(PNetValue)) > 0 Then Abs((Sum(PDisc)) / Abs(Sum(PNetValue))) * 100 Else 0 End,
   --	"Product Discount" = Sum(PDisc),
	"Net Addl. Discount %" = Case When Abs(Sum(ANetValue)) > 0 Then Abs((Sum(ADisc)) / AbS(Sum(ANetValue))) * 100 Else 0 End,
	"Addl. Discount" = Sum(ADisc),
   --"Net Trade Discount %" = Case When Abs(Sum(TNetValue)) > 0 Then Abs((Sum(TDisc)) / Abs(Sum(TNetValue))) * 100 Else 0 End,
   -- "Trade Discount" = Sum(TDisc),

	"Total Discount Value" = Sum(IsNull(TotSchValue,0) + IsNull(TotSchemeValue,0) + IsNull(TotSplSchValue,0) + IsNull(TotSplCatSchemeValue,0) + (IsNull(TotInvSchemeValue,0))) + Sum(ADisc)	InTo #PreAllResult

	--From  #TempSale2 TS,Items I,UOM ,#TempCategory1 ISort 
	From  #TmpFinal TS,Items I,UOM ,#TempCategory1 ISort
	Where TS.ItemCode = I.Product_Code
	And I.CategoryID = ISort.CategoryID
	And UOM.UOM = (Case @UOM when 'UOM2' Then TS.UOM2 When 'UOM1' Then TS.UOM1 Else TS.UOM End)
	Group By I.Product_Code,TS.SchemeID,TS.SplCatSchemeID,TS.InvSchemeID,TS.SplSchItem_Code,ISort.IDS, TS.InvSchemeID, TS.InvSchemeValue, TS.SchemeValue,
    TS.SchItem_Code, TS.SplSchItem_Code, TS.SchUOM, TS.SchQty, TS.SchValue, TS.SplSchUOM, TS.SplCatSchemeValue, TS.SplSchQty, TS.SPlSchValue, TS.ItemRowsCount
    --, TS.SplCatRowsCount,TS.InvSchRowCount
	Order By ISort.IDS

    --update #PreAllResult set [Total Discount Value]=[Total Discount Value]+[Inv Scheme Value]

    If @Claimable ='Yes'
		Begin
			Set @SqlSel = 'Select [CatID],[Division],[Saleable Item Name],[UOM],[Quantity],[Value]'
			if IsNull(@SchDispOption,0) > 0
				Set @SqlSel = @SqlSel + ',[Scheme Name],[Scheme Free Item Name],[Scheme UOM],[Scheme Quantity], [Scheme Value]'
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
				Set @SqlSel = @SqlSel + ',[Scheme Name],[Scheme Free Item Name],[Scheme UOM],[Scheme Quantity], [Scheme Value]'
			If IsNull(@SplSchDispOption,0) > 0 
				Set @SqlSel = @SqlSel + ',[Spl Scheme Name],[Spl Scheme Free Item Name],[Spl Scheme UOM],[Spl Scheme Quantity],[Spl Scheme Value]'
			If IsNull(@InvDispOption,0) > 0
				Set @SqlSel = @SqlSel + ',[Inv Scheme Name],[Inv Scheme Value]'		
			--Set @SqlSel = @SqlSel + ',[Net Product Discount %],[Product Discount],[Net Addl. Discount %],[Addl. Discount],[Net Trade Discount %],[Trade Discount],[Total Discount Value] From #PreAllResult'
			Set @SqlSel = @SqlSel + ',[Net Addl. Discount %] as [Net Trade Discount %],[Addl. Discount] as [Trade Discount],[Total Discount Value] From #PreAllResult'
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
Drop Table #TempSale2
Drop Table #TempCategory1

If @DiscType = 'Scheme' 
 Drop table #PreSchResult
Else IF @DiscType = 'All without Free Item'
 Drop table #PreAllResult


