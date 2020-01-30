CREATE PROCEDURE sp_DetailedSchemes_WD_ITC
(
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

Declare @Delimeter nVarchar(1)
Set @Delimeter = Char(15)

Create Table #TempCategory     (CategoryID Int, Status Int)
Create Table #TempSelectedCats (CatID int , CatName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #TempSelCatsLeaf  (SelCat int, SelCatName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,LeafCat int)
Create Table #TempChannels     (ChannelType int)
Create Table #TempSalesMans    (SalesManID int)
Create Table #TempBeats        (BeatID int)
Create Table #TempCust         (CustomerID nVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #TempAllSchemes   (SchemeID int,SchemeName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #TempSchemes      (SchemeID int)

If @ReportLevel <> N'Category Wise' And @ReportLevel <> N'Channel Wise' And @ReportLevel <> 'DS wise' And @ReportLevel <> 'Beat wise' And @ReportLevel <> 'Customer wise'
Set @ReportLevel = 'Category Wise'

If @DiscType <> 'Scheme' And @DiscType <> 'Product Discount' And @DiscType <> 'Addl. Discount' And @DiscType <> 'Trade Discount' And @DiscType <> 'Only Free Item' And @DiscType <> 'All without Free Item'
Set @DiscType = 'All without Free Item'

If @UOM <> N'Base UOM' And @UOM <> N'UOM1' And @UOM <> N'UOM2'
Set @UOM = 'UOM2'

If @Claimable <> 'Yes' And @Claimable <> 'No' And @Claimable <> 'Both'
Set @Claimable = 'Both'

If @FreeValAt <> 'PTS' And @FreeValAt <> 'PTR'
Set @FreeValAt = 'PTS'

If @ProductHierarchy = N'%' Or @ProductHierarchy = N'Division'
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
	SchValue Decimal(18,6),
	SplSchItem_Code nVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
	SplSchQty Decimal(18,6),
	SPlSchValue Decimal(18,6),
	SplFlag Int,
	TotQty Decimal(18,6),
	NetValue Decimal(18,6),
	DiscSalValue Decimal(18,6),
	SDiscSalValue Decimal(18,6),
	ClaimableInvSch int,
	InvSchemeID Int,
	InvSchemeValue Decimal(18,6),
	ClaimableSch Int,
	SchemeID Int,
	SchemeValue Decimal(18,6),
	ClaimableSplSch Int,
	SplCatSchemeID Int,
	SplCatSchemeValue Decimal(18,6),
	SNetValue Decimal(18,6),
	PNetValue Decimal(18,6),
	PDisc Decimal(18,6),
	ANetValue Decimal(18,6),
	ADisc Decimal(18,6),
	TNetValue Decimal(18,6),
	TDisc Decimal(18,6),
	MUOM nVarChar(2000)
)

if @DiscType = 'Only Free Item'
	Begin
		Insert Into #TempSale
			(SelCat,SelCatName,CatID,Channel,SalesManID,Beat,CustomerID,
			ItemCode,UOM,UOM1,UOM2,Serial,Free,FreeValue)
		Select
			Cat.SelCat,
			Cat.SelCatName,
			Cat.LeafCat,
			C.ChannelType,
			IA.SalesManID,
			IA.BeatID,
			IA.CustomerID,
			I.Product_Code,
			Max(I.UOM),Max(I.UOM1),Max(I.UOM2),
			IDT.Serial,
			( Case IA.InvoiceType When 4 Then -1*Sum(IDT.Quantity) Else sum(IDT.Quantity) End) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),
			((Case IA.InvoiceType When 4 Then -1*Sum(IDT.Quantity) Else Sum(IDT.Quantity) End) * (Case @FreeValAt When 'PTR' Then Max(IDT.PTR) Else Max(IDT.PTS) End))
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
			And IDT.FlagWord = 0
			And IDT.SalePrice = 0
			And IA.InvoiceID = IDT.InvoiceID   
			And I.Product_Code = IDT.Product_Code
		  And I.CategoryID = Cat.LeafCat
		  And IA.CustomerID = C.CustomerID
		Group By
			Cat.SelCat, Cat.SelCatName, Cat.LeafCat, C.ChannelType, IA.SalesManID, IA.BeatID, 
			IA.CustomerID,IDT.InvoiceID,IA.InvoiceType,I.Product_Code,IDT.Serial -- ,IA.SchemeID, IDT.SchemeID, IDT.SplCatSchemeID
	End
Else
	Begin
		Insert Into #TempSale
			(SelCat,SelCatName,CatID,Channel,SalesManID,Beat,CustomerID,
			ItemCode,UOM,UOM1,UOM2,Serial,
			SchItem_Code,SchQty,SchValue,
			SplSchItem_Code,SplSchQty,SplSchValue,SplFlag,
			TotQty,NetValue,SDiscSalValue, 
			ClaimableInvSch,	InvSchemeID, InvSchemeValue,
			ClaimableSch, SchemeID, SchemeValue,
			ClaimableSplSch ,SplCatSchemeID, SplCatSchemeValue,
			PNetValue,PDisc,ANetValue,ADisc,TNetValue,TDisc)
		Select
			Cat.SelCat,
			Cat.SelCatName,
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
			(Select Sum(IsNull(Quantity,0)) * Max(Case @FreeValAt When 'PTR' Then PTR Else PTS End) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.FreeSerial)) > 0 Then Left(Max(IDT.FreeSerial),CharIndex(',',Max(IDT.FreeSerial))-1) Else Max(IDT.FreeSerial) End As Int)),
			(Select Max(IsNull(Product_Code,'')) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)),
			(Select Sum(IsNull(Quantity,0)) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)),
			(Select Sum(IsNull(Quantity,0)) * Max(Case @FreeValAt When 'PTR' Then PTR Else PTS End) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)),
			(Select Min(Cast((Case When CharIndex(',',SplCatSerial) > 0 Then Left(SplCatSerial,CharIndex(',',SplCatSerial)-1) Else SplCatSerial End) As Int)) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Serial = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)),
			Sum(IDT.Quantity) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),
			Max(IDT.Amount),
			(Case When (Max(IA.SchemeID) > 0 And Max(IA.SchemeDiscountPercentage) > 0) Or Max(IDT.SplCatSchemeID) > 0 Or Max(IDT.SchemeID) >0 Then (Sum(IDT.Quantity) * Max(IDT.SalePrice)) - (Case When Max(IDT.SplCatSchemeID) = 0 And Max(IDT.SchemeID) = 0 Then Max(IDT.DiscountValue) Else 0 End) Else 0 End),
			(Select IsNull(SecondaryScheme,0) From Schemes Where SchemeID = Max(IA.SchemeID)),
			(Case When Max(IA.SchemeDiscountPercentage) > 0 Then Max(IA.SchemeID) Else 0 End), 
			(Case When Max(IA.SchemeID) > 0 And Max(IA.SchemeDiscountPercentage) > 0 Then (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.SchemeDiscountPercentage)) / 100) Else 0 End),
			(Select IsNull(SecondaryScheme,0) From Schemes Where SchemeID = Max(IDT.SchemeID)),
			Max(IDT.SchemeID) , 
			(Case When Max(IDT.SchemeID) >0 Then Max(IDT.SchemeDiscAmount)	Else 0 End),
			(Select IsNull(SecondaryScheme,0) From Schemes Where SchemeID = Max(IDT.SplCatSchemeID)),
			Max(IDT.SplCatSchemeID), 
			(Case When Max(IDT.SplCatSchemeID) > 0 then Max(IDT.SplCatDiscAmount) Else 0 End),
		  (Case When (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) > 0 Then Sum(IDT.Quantity) * Max(IDT.SalePrice) Else 0 End),
		  ((Sum(IDT.Quantity) * Max(IDT.SalePrice)) * (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) /100),
			(Case When Max(IA.AdditionalDiscount) >0 Then (Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue) Else 0 End),
			(((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.AdditionalDiscount)) / 100),
			(Case When (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) > 0 Then (Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue) Else 0 End),
			(((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) / 100)
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
			And IDT.FlagWord = 0
			And IDT.SalePrice > 0
			And IA.InvoiceID = IDT.InvoiceID   
			And I.Product_Code = IDT.Product_Code
		  And I.CategoryID = Cat.LeafCat
		  And IA.CustomerID = C.CustomerID
		Group By
			Cat.SelCat, Cat.SelCatName, Cat.LeafCat, C.ChannelType, IA.SalesManID, IA.BeatID, 
			IA.CustomerID,IDT.InvoiceID,IA.InvoiceType,I.Product_Code ,IA.SchemeID,IA.SchemeDiscountPercentage,IDT.Serial  --, IDT.SchemeID, IDT.SplCatSchemeID

		Insert Into #TempSale
			(SelCat,SelCatName,CatID,Channel,SalesManID,Beat,CustomerID,
			ItemCode,UOM,UOM1,UOM2,Serial,TotQty,NetValue,SDiscSalValue,
			ClaimableInvSch,	InvSchemeID, InvSchemeValue,
			ClaimableSch, SchemeID, SchemeValue,
			ClaimableSplSch ,SplCatSchemeID, SplCatSchemeValue,
			PNetValue,PDisc,ANetValue,ADisc,TNetValue,TDisc)
		Select
			Cat.SelCat,
			Cat.SelCatName,
			Cat.LeafCat,
			C.ChannelType,
			IA.SalesManID,
			IA.BeatID,
			IA.CustomerID,
			I.Product_Code,
			Max(I.UOM),Max(I.UOM1),Max(I.UOM2),
			IDT.Serial,
			-1 * Sum(IDT.Quantity) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),
			-1 * Max(IDT.Amount),
			-1 * (Case When (Max(IA.SchemeID) > 0 And Max(IA.SchemeDiscountPercentage) > 0) Or Max(IDT.SplCatSchemeID) > 0 Or Max(IDT.SchemeID) >0 Then Sum(IDT.Quantity) * Max(IDT.SalePrice) - (Case When Max(IDT.SplCatSchemeID) = 0 And Max(IDT.SchemeID) = 0 Then Max(IDT.DiscountValue) Else 0 End) Else 0 End),
			(Select IsNull(SecondaryScheme,0) From Schemes Where SchemeID = Max(IA.SchemeID)),
			(Case When  Max(IA.SchemeDiscountPercentage) > 0 Then Max(IA.SchemeID) Else 0 End), 
			-1 * (Case When Max(IA.SchemeID) > 0 And Max(IA.SchemeDiscountPercentage) > 0 Then ((Sum(IDT.Quantity) * Max(IDT.SalePrice)) * (Max(IA.SchemeDiscountPercentage)) / 100) Else 0 End),
			(Select IsNull(SecondaryScheme,0) From Schemes Where SchemeID = Max(IDT.SchemeID)),
			Max(IDT.SchemeID) , 
			-1 * (Case When Max(IDT.SchemeID) >0 Then Max(IDT.SchemeDiscAmount)	Else 0 End),
			(Select IsNull(SecondaryScheme,0) From Schemes Where SchemeID = Max(IDT.SplCatSchemeID)),
			Max(IDT.SplCatSchemeID), 
			-1 * (Case When Max(IDT.SplCatSchemeID) > 0 then Max(IDT.SplCatDiscAmount) Else 0 End),
		  -1 * (Case When (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) > 0 Then Sum(IDT.Quantity) * Max(IDT.SalePrice) Else 0 End),
		  -1 * ((Sum(IDT.Quantity) * Max(IDT.SalePrice)) * (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) /100),
			-1 * (Case When Max(IA.AdditionalDiscount) >0 Then (Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue) Else 0 End),
			-1 * (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.AdditionalDiscount)) / 100),
			-1 * (Case When (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) > 0 Then (Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue) Else 0 End),
			-1 * (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) / 100)
		From    
			InvoiceAbstract IA, InvoiceDetail IDT, Items I, Customer C, #TempSelCatsLeaf Cat
		Where 
			IA.Status & 128 = 0
			And IA.InvoiceType in (4)
			And IA.InvoiceDate Between @FromDate And @ToDate
			And IA.SalesmanID In (Select SalesManID From #TempSalesMans)
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
			IA.CustomerID,IDT.InvoiceID,IA.InvoiceType,I.Product_Code ,IA.SchemeID,IA.SchemeDiscountPercentage,IDT.Serial  --, IDT.SchemeID, IDT.SplCatSchemeID

		Update #TempSale Set SchemeID= 0 Where IsNull(SchItem_Code,'') = '' And IsNull(SchQty,0) = 0 And IsNull(SchemeValue,0) = 0
		Update #TempSale Set SplCatSchemeID = 0 Where IsNull(SplSchItem_Code,'') = '' And IsNull(SplSchQty,0) = 0 And IsNull(SplCatSchemeValue,0) = 0

		If @Claimable = 'Yes'		
			Update #TempSale Set SNetValue = IsNull(SDiscSalValue,0)
				Where (IsNull(InvSchemeID,0) > 0 And IsNull(ClaimableInvSch,0) = 1) Or 
							(IsNull(SchemeID,0) > 0 And  IsNull(ClaimableSch,0) = 1) Or 
							(IsNull(SplCatSchemeID,0) > 0 And IsNull(ClaimableSplSch,0) = 1)
		Else If @Claimable = 'No'
			Update #TempSale Set SNetValue = IsNull(SDiscSalValue,0)
				Where (IsNull(InvSchemeID,0) > 0 And IsNull(ClaimableInvSch,0) = 0) Or 
							(IsNull(SchemeID,0) >0 And  IsNull(ClaimableSch,0) = 0) Or 
							(IsNull(SplCatSchemeID,0) > 0 And IsNull(ClaimableSplSch,0) = 0)
		Else
			Update #TempSale Set SNetValue = IsNull(SDiscSalValue,0)

		Insert Into #TempSchemes Select Distinct IsNull(SchemeID,0) from #TempSale Where IsNull(SchemeID,0) > 0
		Insert Into #TempSchemes Select Distinct IsNull(SplCatSchemeID,0) from #TempSale Where IsNull(SplCatSchemeID,0) > 0
		Insert Into #TempSchemes Select Distinct IsNull(InvSchemeID,0) from #TempSale Where IsNull(InvSchemeID,0) > 0

		If @Claimable = 'Yes'
			Insert Into #TempAllSchemes 
			Select Distinct #TempSchemes.SchemeID,Schemes.SchemeName 
			from #TempSchemes,Schemes
			Where #TempSchemes.SchemeID > 0
			And Schemes.SecondaryScheme = 1
			And #TempSchemes.SchemeID = Schemes.SchemeID
		Else If @Claimable = 'No'
			Insert Into #TempAllSchemes 
			Select Distinct #TempSchemes.SchemeID,Schemes.SchemeName 
			from #TempSchemes,Schemes
			Where #TempSchemes.SchemeID > 0
			And Schemes.SecondaryScheme = 0
			And #TempSchemes.SchemeID = Schemes.SchemeID
		Else
			Insert Into #TempAllSchemes 
			Select Distinct #TempSchemes.SchemeID,Schemes.SchemeName 
			from #TempSchemes,Schemes
			Where #TempSchemes.SchemeID > 0
			And #TempSchemes.SchemeID = Schemes.SchemeID

		Set @SchList = ''

		Declare SchNames Cursor For Select Distinct SchemeID,SchemeName from #TempAllSchemes
		Open SchNames
		Fetch From SchNames Into @SchID,@SchName
		While @@Fetch_status = 0
		Begin
			Set @SchList = @SchList + ', [' + @SchName + ']'
			Set @SqlStat = 'Alter Table #TempSale Add [' + @SchName + '] Decimal(18,6)'
			Exec Sp_sqlExec @SqlStat
			Set @SqlStat = 'Update #TempSale Set [' + @SchName + '] = 
			(Case IsNull(InvSchemeID,0) When ' + Cast(@SchID as nVarChar) + ' Then IsNull(InvSchemeValue,0) Else 0 End)
			+
			(Case IsNull(SchemeID,0) When ' + Cast(@SchID as nVarChar) + ' Then IsNull(SchemeValue,0) + IsNull(SchValue,0) Else 0 End)
			+
			(Case IsNull(SplCatSchemeID,0) When '+ Cast(@SchID as nVarChar) + ' Then IsNull(SplCatSchemeValue,0) Else 0 End)
			+
			(Case When IsNull(SplCatSchemeID,0) = '+ Cast(@SchID as nVarChar) + 'And Serial = IsNull(SplFlag,0) Then IsNull(SplSchValue,0) Else 0 End)'
			Exec Sp_sqlExec @SqlStat
			Fetch Next From SchNames Into @SchID,@SchName
		End

		Close SchNames
		DeAllocate SchNames
	End

--  Select * from #TempAllSchemes 
--  Select * from  #TempSale

Declare @GrpCode Int
Declare @GrpCustCode nVarChar(30)
Declare @UOMS int
Declare @UOMList nVarChar(2000)

If @ReportLevel = 'Channel Wise'
	Begin
		Declare MUomCursor Cursor For Select Channel from #TempSale Group By Channel
		Open MUomCursor 
		Fetch from MUomCursor Into @GrpCode
		While @@Fetch_Status = 0 
		Begin
				Set @UOMList = ''
				If @UOM = 'UOM2'
					Declare Uoms Cursor for Select Distinct UOM2 from #TempSale where Channel = @GrpCode
				Else IF @UOM = 'UOM1'
					Declare Uoms Cursor for Select Distinct UOM1 from #TempSale where Channel = @GrpCode
				Else
					Declare Uoms Cursor for Select Distinct UOM from #TempSale where Channel = @GrpCode
				Open Uoms
				Fetch from Uoms Into @UOMS
				While @@Fetch_Status = 0
				Begin
					If @UOMList = ''
						Set @UOMList = (Select Description from UOM Where UOM = @UOMS)
					Else
						Set @UOMList = @UOMList + '*' + (Select Description from UOM Where UOM = @UOMS)
					Fetch Next from Uoms Into @UOMS
				End
				Close Uoms
				Deallocate Uoms
				Update #TempSale Set MUOM = @UOMList where Channel = @GrpCode
			Fetch Next from MUomCursor Into @GrpCode
		End
		Close MUomCursor 
		Deallocate MUomCursor 
	End
Else If @ReportLevel = 'DS wise'
	Begin
		Declare MUomCursor Cursor For Select SalesManID from #TempSale Group By SalesManID
		Open MUomCursor 
		Fetch from MUomCursor Into @GrpCode
		While @@Fetch_Status = 0 
		Begin
				Set @UOMList = ''
				If @UOM = 'UOM2'
					Declare Uoms Cursor for Select Distinct UOM2 from #TempSale where SalesManID = @GrpCode
				Else IF @UOM = 'UOM1'
					Declare Uoms Cursor for Select Distinct UOM1 from #TempSale where SalesManID = @GrpCode
				Else
					Declare Uoms Cursor for Select Distinct UOM from #TempSale where SalesManID = @GrpCode
				Open Uoms
				Fetch from Uoms Into @UOMS
				While @@Fetch_Status = 0
				Begin
					If @UOMList = ''
						Set @UOMList = (Select Description from UOM Where UOM = @UOMS)
					Else
						Set @UOMList = @UOMList + '*' + (Select Description from UOM Where UOM = @UOMS)
					Fetch Next from Uoms Into @UOMS
				End
				Close Uoms
				Deallocate Uoms
				Update #TempSale Set MUOM = @UOMList where SalesManID = @GrpCode
			Fetch Next from MUomCursor Into @GrpCode
		End
		Close MUomCursor 
		Deallocate MUomCursor 
	End
Else If @ReportLevel = 'Beat wise'
	Begin
		Declare MUomCursor Cursor For Select Beat from #TempSale Group By Beat
		Open MUomCursor 
		Fetch from MUomCursor Into @GrpCode
		While @@Fetch_Status = 0 
		Begin
				Set @UOMList = ''
				If @UOM = 'UOM2'
					Declare Uoms Cursor for Select Distinct UOM2 from #TempSale where Beat = @GrpCode
				Else IF @UOM = 'UOM1'
					Declare Uoms Cursor for Select Distinct UOM1 from #TempSale where Beat = @GrpCode
				Else
					Declare Uoms Cursor for Select Distinct UOM from #TempSale where Beat = @GrpCode
				Open Uoms
				Fetch from Uoms Into @UOMS
				While @@Fetch_Status = 0
				Begin
					If @UOMList = ''
						Set @UOMList = (Select Description from UOM Where UOM = @UOMS)
					Else
						Set @UOMList = @UOMList + '*' + (Select Description from UOM Where UOM = @UOMS)
					Fetch Next from Uoms Into @UOMS
				End
				Close Uoms
				Deallocate Uoms
				Update #TempSale Set MUOM = @UOMList where Beat = @GrpCode
			Fetch Next from MUomCursor Into @GrpCode
		End
		Close MUomCursor 
		Deallocate MUomCursor 
	End
Else If @ReportLevel = 'Customer wise'
	Begin
		Declare MUomCursor Cursor For Select CustomerID from #TempSale Group By CustomerID
		Open MUomCursor 
		Fetch from MUomCursor Into @GrpCustCode
		While @@Fetch_Status = 0 
		Begin
				Set @UOMList = ''
				If @UOM = 'UOM2'
					Declare Uoms Cursor for Select Distinct UOM2 from #TempSale where CustomerID = @GrpCustCode
				Else IF @UOM = 'UOM1'
					Declare Uoms Cursor for Select Distinct UOM1 from #TempSale where CustomerID = @GrpCustCode
				Else
					Declare Uoms Cursor for Select Distinct UOM from #TempSale where CustomerID = @GrpCustCode
				Open Uoms
				Fetch from Uoms Into @UOMS
				While @@Fetch_Status = 0
				Begin
					If @UOMList = ''
						Set @UOMList = (Select Description from UOM Where UOM = @UOMS)
					Else
						Set @UOMList = @UOMList + '*' + (Select Description from UOM Where UOM = @UOMS)
					Fetch Next from Uoms Into @UOMS
				End
				Close Uoms
				Deallocate Uoms
				Update #TempSale Set MUOM = @UOMList where CustomerID = @GrpCustCode
			Fetch Next from MUomCursor Into @GrpCustCode
		End
		Close MUomCursor 
		Deallocate MUomCursor 
	End
Else --'Category Wise'
	Begin
		Declare MUomCursor Cursor For Select SelCat from #TempSale Group By SelCat
		Open MUomCursor 
		Fetch from MUomCursor Into @GrpCode
		While @@Fetch_Status = 0 
		Begin
				Set @UOMList = ''
				If @UOM = 'UOM2'
					Declare Uoms Cursor for Select Distinct UOM2 from #TempSale where SelCat = @GrpCode
				Else IF @UOM = 'UOM1'
					Declare Uoms Cursor for Select Distinct UOM1 from #TempSale where SelCat = @GrpCode
				Else
					Declare Uoms Cursor for Select Distinct UOM from #TempSale where SelCat = @GrpCode
				Open Uoms
				Fetch from Uoms Into @UOMS
				While @@Fetch_Status = 0
				Begin
					If @UOMList = ''
						Set @UOMList = (Select Description from UOM Where UOM = @UOMS)
					Else
						Set @UOMList = @UOMList + '*' + (Select Description from UOM Where UOM = @UOMS)
					Fetch Next from Uoms Into @UOMS
				End
				Close Uoms
				Deallocate Uoms
				Update #TempSale Set MUOM = @UOMList where SelCat = @GrpCode
			Fetch Next from MUomCursor Into @GrpCode
		End
		Close MUomCursor 
		Deallocate MUomCursor 
	End
			Update #TempSale Set DiscSalValue = 
					Case When (Case When IsNull(SNetValue,0) > IsNull(PNetValue,0) Then IsNull(SNetValue,0) Else IsNull(PNetValue,0) End) >
					(Case When IsNull(ANetValue,0) > IsNull(TNetValue,0) Then IsNull(ANetValue,0) Else IsNull(TNetValue,0) End) Then
					(Case When IsNull(SNetValue,0) > IsNull(PNetValue,0) Then IsNull(SNetValue,0) Else IsNull(PNetValue,0) End) Else
					(Case When IsNull(ANetValue,0) > IsNull(TNetValue,0) Then IsNull(ANetValue,0) Else IsNull(TNetValue,0) End) End

--  Select * from  #TempSale

Create Table #TempPreResult  
(
Code int,
GrpBy nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
UOMs nVarChar(2000),
TotQty decimal(18,6),
Free Decimal(18,6),
FreeValue Decimal(18,6),
TotSalVal Decimal(18,6),
DiscSalVal Decimal(18,6),
SDiscSalVal Decimal(18,6),
SchSalVal Decimal(18,6),
PSalVal Decimal(18,6),
PDisc Decimal(18,6),
ASalVal Decimal(18,6),
ADisc Decimal(18,6),
TSalVal Decimal(18,6),
TDisc Decimal(18,6),
TotDisc Decimal(18,6),
TotSchDisc Decimal(18,6)
)

If @ReportLevel = 'Channel Wise'
Insert into #TempPreResult 
(Code, GrpBy, UOMs, TotQty, Free, FreeValue, 
TotSalVal, DiscSalVal,SDiscSalVal, SchSalVal , 
PSalVal , PDisc, ASalVal, ADisc, TSalVal, TDisc, TotDisc)
Select Channel, Max(CC.ChannelDesc),
Max(MUOM),
Sum(IsNull(TotQty,0)),
Sum(IsNull(Free,0)),
Sum(IsNull(FreeValue,0)),
Sum(IsNull(NetValue,0)),
Sum(IsNull(DiscSalValue,0)),
Sum(IsNull(SDiscSalValue,0)),
Sum(IsNull(SNetValue,0)),
Sum(IsNull(PNetValue,0)),
Sum(IsNull(PDisc,0)),
Sum(IsNull(ANetValue,0)),
Sum(IsNull(ADisc,0)),
Sum(IsNull(TNetValue,0)),
Sum(IsNull(TDisc,0)),
Sum(IsNull(PDisc,0)+IsNull(ADisc,0)+IsNull(TDisc,0))
from #TempSale TS,Customer_Channel CC
Where TS.Channel = CC.ChannelType
Group by Channel

Else If @ReportLevel = 'DS wise'
Insert into #TempPreResult 
(Code, GrpBy, UOMs, TotQty, Free, FreeValue, 
TotSalVal,DiscSalVal, SDiscSalVal, SchSalVal , 
PSalVal , PDisc, ASalVal, ADisc, TSalVal, TDisc, TotDisc)
Select TS.SalesManID,Max(SM.SalesMan_Name),
Max(MUOM),
Sum(IsNull(TotQty,0)),
Sum(IsNull(Free,0)),
Sum(IsNull(FreeValue,0)),
Sum(IsNull(NetValue,0)),
Sum(IsNull(DiscSalValue,0)),
Sum(IsNull(sDiscSalValue,0)),
Sum(IsNull(SNetValue,0)),
Sum(IsNull(PNetValue,0)),
Sum(IsNull(PDisc,0)),
Sum(IsNull(ANetValue,0)),
Sum(IsNull(ADisc,0)),
Sum(IsNull(TNetValue,0)),
Sum(IsNull(TDisc,0)),
Sum(IsNull(PDisc,0)+IsNull(ADisc,0)+IsNull(TDisc,0))
from #TempSale TS,SalesMan SM
Where TS.SalesManID = SM.SalesManID
Group by TS.SalesManID

Else If @ReportLevel = 'Beat wise'
Insert into #TempPreResult 
(Code, GrpBy, UOMs, TotQty, Free, FreeValue, 
TotSalVal,DiscSalVal, sDiscSalVal, SchSalVal , 
PSalVal , PDisc, ASalVal, ADisc, TSalVal, TDisc, TotDisc)
Select Beat,Max(B.Description),
Max(MUOM),
Sum(IsNull(TotQty,0)),
Sum(IsNull(Free,0)),
Sum(IsNull(FreeValue,0)),
Sum(IsNull(NetValue,0)),
Sum(IsNull(DiscSalValue,0)),
Sum(IsNull(sDiscSalValue,0)),
Sum(IsNull(SNetValue,0)),
Sum(IsNull(PNetValue,0)),
Sum(IsNull(PDisc,0)),
Sum(IsNull(ANetValue,0)),
Sum(IsNull(ADisc,0)),
Sum(IsNull(TNetValue,0)),
Sum(IsNull(TDisc,0)),
Sum(IsNull(PDisc,0)+IsNull(ADisc,0)+IsNull(TDisc,0))
from #TempSale TS,Beat B
Where Beat = B.BeatID
Group by Beat

Else If @ReportLevel = 'Customer wise'
Insert into #TempPreResult 
(Code, GrpBy, UOMs, TotQty, Free, FreeValue, 
TotSalVal,DiscSalVal, sDiscSalVal, SchSalVal , 
PSalVal , PDisc, ASalVal, ADisc, TSalVal, TDisc, TotDisc)
Select 1,CustomerID,
Max(MUOM),
Sum(IsNull(TotQty,0)),
Sum(IsNull(Free,0)),
Sum(IsNull(FreeValue,0)),
Sum(IsNull(NetValue,0)),
Sum(IsNull(DiscSalValue,0)),
Sum(IsNull(sDiscSalValue,0)),
Sum(IsNull(SNetValue,0)),
Sum(IsNull(PNetValue,0)),
Sum(IsNull(PDisc,0)),
Sum(IsNull(ANetValue,0)),
Sum(IsNull(ADisc,0)),
Sum(IsNull(TNetValue,0)),
Sum(IsNull(TDisc,0)),
Sum(IsNull(PDisc,0)+IsNull(ADisc,0)+IsNull(TDisc,0))
from #TempSale TS
Group by CustomerID

Else --'Category Wise'
Insert into #TempPreResult 
(Code, GrpBy, UOMs, TotQty, Free, FreeValue, 
TotSalVal,DiscSalVal, sDiscSalVal, SchSalVal , 
PSalVal , PDisc, ASalVal, ADisc, TSalVal, TDisc, TotDisc)
Select SelCat, Max(SelCatName),
Max(MUOM),
Sum(IsNull(TotQty,0)),
Sum(IsNull(Free,0)),
Sum(IsNull(FreeValue,0)),
Sum(IsNull(NetValue,0)),
Sum(IsNull(DiscSalValue,0)),
Sum(IsNull(sDiscSalValue,0)),
Sum(IsNull(SNetValue,0)),
Sum(IsNull(PNetValue,0)),
Sum(IsNull(PDisc,0)),
Sum(IsNull(ANetValue,0)),
Sum(IsNull(ADisc,0)),
Sum(IsNull(TNetValue,0)),
Sum(IsNull(TDisc,0)),
Sum(IsNull(PDisc,0)+IsNull(ADisc,0)+IsNull(TDisc,0))
from #TempSale TS
Group by SelCat

-- Select * from #TempPreResult 

if @DiscType <> 'Only Free Item'
	Begin
		Declare SchNames Cursor For Select Distinct SchemeID,SchemeName from #TempAllSchemes
		Open SchNames
		Fetch From SchNames Into @SchID,@SchName
		While @@Fetch_status = 0
		Begin
			Set @SqlStat = 'Alter Table #TempPreResult Add [' + @SchName + '] Decimal(18,6)'
			Exec Sp_sqlExec @SqlStat

			If @ReportLevel = 'Channel Wise'
			  Set @SqlStat = 'Update #TempPreResult Set [' + @SchName + '] = 
				(Select Sum(IsNull(['+ @SchName +'],0)) From #TempSale Where Channel =  #TempPreResult.Code Group BY Channel),
			 	TotSchDisc = IsNull(TotSchDisc,0) +
				(Select Sum(IsNull(['+ @SchName +'],0)) 
				From #TempSale Where Channel =  #TempPreResult.Code Group BY Channel)'
			Else If @ReportLevel = 'DS wise'
			  Set @SqlStat = 'Update #TempPreResult Set [' + @SchName + '] = 
				(Select Sum(IsNull(['+ @SchName +'],0)) From #TempSale Where #TempSale.SalesManID =  #TempPreResult.Code Group BY #TempSale.SalesManID),
			 	TotSchDisc = IsNull(TotSchDisc,0) +
				(Select Sum(IsNull(['+ @SchName +'],0)) 
				From #TempSale Where #TempSale.SalesManID =  #TempPreResult.Code Group BY #TempSale.SalesManID)'
			Else If @ReportLevel = 'Beat wise'
			  Set @SqlStat = 'Update #TempPreResult Set [' + @SchName + '] = 
				(Select Sum(IsNull(['+ @SchName +'],0)) From #TempSale Where Beat =  #TempPreResult.Code Group BY Beat),
			 	TotSchDisc = IsNull(TotSchDisc,0) +
				(Select Sum(IsNull(['+ @SchName +'],0)) 
				From #TempSale Where Beat =  #TempPreResult.Code Group BY Beat)'
			Else If @ReportLevel = 'Customer wise'
			  Set @SqlStat = 'Update #TempPreResult Set [' + @SchName + '] = 
				(Select Sum(IsNull(['+ @SchName +'],0)) From #TempSale Where CustomerID =  #TempPreResult.GrpBy Group BY CustomerID),
			 	TotSchDisc = IsNull(TotSchDisc,0) +
				(Select Sum(IsNull(['+ @SchName +'],0)) 
				From #TempSale Where CustomerID =  #TempPreResult.GrpBy Group BY CustomerID)'
			Else --'Category Wise'
			  Set @SqlStat = 'Update #TempPreResult Set [' + @SchName + '] = 
				(Select Sum(IsNull(['+ @SchName +'],0)) From #TempSale Where SelCat = Code Group BY SelCat),
			 	TotSchDisc = IsNull(TotSchDisc,0) +
				(Select Sum(IsNull(['+ @SchName +'],0)) 
				From #TempSale Where SelCat = Code Group BY SelCat)'
				Exec Sp_sqlExec @SqlStat
				Fetch Next From SchNames Into @SchID,@SchName
		End

		Close SchNames
		DeAllocate SchNames
End

-- Select * from #TempPreResult 

Set @SqlStat = ''

If @DiscType = 'Scheme'
	Begin
		If @ReportLevel = 'Channel Wise'
			Set @SqlStat = @SqlStat + 'Select Code,"Channel Name" = GrpBy,'
		Else If @ReportLevel = 'DS wise'
			Set @SqlStat = @SqlStat + 'Select Code,"DS Name" = GrpBy,'
		Else If @ReportLevel = 'Beat wise'
			Set @SqlStat = @SqlStat + 'Select Code,"Beat Name" = GrpBy,'
		Else If @ReportLevel = 'Customer wise'
			Set @SqlStat = @SqlStat + 'Select GrpBy,"Customer Name" = (Select Company_Name from Customer Where CustomerID = GrpBy),'
		Else --'Category Wise'
			Set @SqlStat = @SqlStat + 'Select Code,"Category Name" = GrpBy,'
	
		Set @SqlStat = @SqlStat + 
			'"UOM" = UOMs,
			"Total Volume" = TotQty,
			"Total Sales Value" = TotSalVal,
			"Discountable Sales Value" = SchSalVal' + @SchList + ',
			"Total Value" = TotSchDisc From #TempPreResult Where SchSalVal <>0'
	End
Else If @DiscType = 'Product Discount'
	Begin
		If @ReportLevel = 'Channel Wise'
			Set @SqlStat = @SqlStat + 'Select Code,"Channel Name" = GrpBy,'	
		Else If @ReportLevel = 'DS wise'
			Set @SqlStat = @SqlStat + 'Select Code,"DS Name" = GrpBy,'	
		Else If @ReportLevel = 'Beat wise'
			Set @SqlStat = @SqlStat + 'Select Code,"Beat Name" = GrpBy,'	
		Else If @ReportLevel = 'Customer wise'
			Set @SqlStat = @SqlStat + 'Select GrpBy,"Customer Name" = (Select Company_Name from Customer Where CustomerID = GrpBy),'		
		Else --'Category Wise'
			Set @SqlStat = @SqlStat + 'Select Code,"Category Name" = GrpBy,'
	
		Set @SqlStat = @SqlStat + 
--			'"UOM" = IsNull((Select Description from UOM Where UOM = UOMID),''*''),
			'"UOM" = UOMs,
			"Total Volume" = TotQty,
			"Total Sales Value" = TotSalVal,
			"Discountable Sales Value" = PSalVal,
			"Product Discount" = PDisc From #TempPreResult Where PSalVal <> 0'
	End
Else If @DiscType = 'Addl. Discount'
	Begin
		If @ReportLevel = 'Channel Wise'
			Set @SqlStat = @SqlStat + 'Select Code,"Channel Name" = GrpBy,'
		Else If @ReportLevel = 'DS wise'
			Set @SqlStat = @SqlStat + 'Select Code,"DS Name" = GrpBy,'
		Else If @ReportLevel = 'Beat wise'
			Set @SqlStat = @SqlStat + 'Select Code,"Beat Name" = GrpBy,'
		Else If @ReportLevel = 'Customer wise'
			Set @SqlStat = @SqlStat + 'Select GrpBy,"Customer Name" = (Select Company_Name from Customer Where CustomerID = GrpBy),'
		Else --'Category Wise'
			Set @SqlStat = @SqlStat + 'Select Code,"Category Name" = GrpBy,'
	
		Set @SqlStat = @SqlStat +
			'"UOM" = UOMs,
			"Total Volume" = TotQty,
			"Total Sales Value" = TotSalVal,
			"Discountable Sales Value" = ASalVal,
			"Addl Discount" = ADisc From #TempPreResult Where ASalVal <> 0'
	End

Else If @DiscType = 'Trade Discount'
	Begin
		If @ReportLevel = 'Channel Wise'
			Set @SqlStat = @SqlStat + 'Select Code,"Channel Name" = GrpBy,'
		Else If @ReportLevel = 'DS wise'
			Set @SqlStat = @SqlStat + 'Select Code,"DS Name" = GrpBy,'
		Else If @ReportLevel = 'Beat wise'
			Set @SqlStat = @SqlStat + 'Select Code,"Beat Name" = GrpBy,'
		Else If @ReportLevel = 'Customer wise'
			Set @SqlStat = @SqlStat + 'Select GrpBy,"Customer Name" = (Select Company_Name from Customer Where CustomerID = GrpBy),'
		Else --'Category Wise'
			Set @SqlStat = @SqlStat + 'Select Code,"Category Name" = GrpBy,'
	
		Set @SqlStat = @SqlStat + 
			'"UOM" = UOMs,
			"Total Volume" = TotQty,
			"Total Sales Value" = TotSalVal,
			"Discountable Sales Value" = TSalVal,
			"Trade Discount" = TDisc From #TempPreResult Where TSalVal <> 0'
	End
Else if @DiscType = 'Only Free Item'
	Begin
		If @ReportLevel = 'Channel Wise'
			Set @SqlStat = @SqlStat + 'Select Code,"Channel Name" = GrpBy,'
		Else If @ReportLevel = 'DS wise'
			Set @SqlStat = @SqlStat + 'Select Code,"DS Name" = GrpBy,'
		Else If @ReportLevel = 'Beat wise'
			Set @SqlStat = @SqlStat + 'Select Code,"Beat Name" = GrpBy,'
		Else If @ReportLevel = 'Customer wise'
			Set @SqlStat = @SqlStat + 'Select GrpBy,"Customer Name" = (Select Company_Name from Customer Where CustomerID = GrpBy),'
		Else --'Category Wise'
			Set @SqlStat = @SqlStat + 'Select Code,"Category Name" = GrpBy,'
	
		Set @SqlStat = @SqlStat +
			'"UOM" = UOMs,
			"Free Item Volume" = Free , 
			"Free Item Value" = FreeValue From #TempPreResult Where Free <> 0'
	End
Else --'All without Free Item'
	Begin
		If @ReportLevel = 'Channel Wise'
			Set @SqlStat = @SqlStat + 'Select Code,"Channel Name" = GrpBy,'
		Else If @ReportLevel = 'DS wise'
			Set @SqlStat = @SqlStat + 'Select Code,"DS Name" = GrpBy,'
		Else If @ReportLevel = 'Beat wise'
			Set @SqlStat = @SqlStat + 'Select Code,"Beat Name" = GrpBy,'
		Else If @ReportLevel = 'Customer wise'
			Set @SqlStat = @SqlStat + 'Select GrpBy,"Customer Name" = (Select Company_Name from Customer Where CustomerID = GrpBy),'
		Else --'Category Wise'
		Set @SqlStat = @SqlStat + 'Select Code,"Category Name" = GrpBy,'
	
	If @Claimable ='Yes'
			Set @SqlStat = @SqlStat +
				'"UOM" = UOMs,
				"Total Volume" = TotQty,
				"Total Sales Value" = TotSalVal,
				"Discountable Sales Value" = SchSalVal ' + @SchList + ',
				"Total Value" = IsNull(TotSchDisc,0) From #TempPreResult Where SchSalVal <> 0'
	Else
			Set @SqlStat = @SqlStat +
				'"UOM" = UOMs,
				"Total Volume" = TotQty,
				"Total Sales Value" = TotSalVal,
				"Discountable Sales Value" = DiscSalVal ' + @SchList + ',
				"Product Discount" = PDisc,
				"Addl Discount" = ADisc,
				"Trade Discount" = TDisc,
				"Total Value" = IsNull(TotDisc,0)+IsNull(TotSchDisc,0) From #TempPreResult Where DiscSalVal <> 0'
	End

Exec Sp_sqlExec @SqlStat

--Select * from #TempPreResult

Drop Table #TempCategory
Drop Table #TempSelectedCats
Drop Table #TempSelCatsLeaf
Drop Table #TempChannels
Drop Table #TempSalesMans
Drop Table #TempBeats
Drop Table #TempCust
Drop Table #TempSale
Drop Table #TempSchemes 
Drop Table #TempAllSchemes 
Drop Table #TempPreResult
