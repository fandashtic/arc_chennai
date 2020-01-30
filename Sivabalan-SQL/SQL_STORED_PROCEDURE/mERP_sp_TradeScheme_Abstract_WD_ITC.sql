CREATE PROCEDURE mERP_sp_TradeScheme_Abstract_WD_ITC
(
@CategoryGroup nVarChar(2550),
@ProductHierarchy nVarchar(510),
@Category nVarchar(2550),
@Channels nVarChar(2550),
@SalesMan nVarChar(2550),
@Beat nVarChar(2550),
@Customers nVarChar(2550),
@ReportLevel nVarChar(50),
@UOM nVarChar(10),
@FromDate DateTime,
@ToDate DateTime
)
AS
BEGIN
	Declare @CatID Int  
	Declare @CatName nVarChar(255)  
	Declare @SqlStat nVarChar(Max)   
	  
	Declare @Delimeter nVarchar(1)  
	Set @Delimeter = Char(15)  
	  
	Create Table #TempCategory     (CategoryID Int, Status Int)  
	Create Table #TempSelectedCats (CatID int , CatName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	Create Table #TempSelCatsLeaf  (SelCat int, SelCatName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,LeafCat int)  
	Create Table #TempChannels     (ChannelType int)  
	Create Table #TempSalesMans    (SalesManID int)  
	Create Table #TempBeats        (BeatID int)  
	Create Table #TempCust         (CustomerID nVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	
	If @ReportLevel <> N'Category Wise' And @ReportLevel <> N'Customer Type wise' And @ReportLevel <> 'DS wise' And @ReportLevel <> 'Beat wise' And @ReportLevel <> 'Customer wise'  
		Set @ReportLevel = 'Category Wise'  
	  
	If @UOM <> N'Base UOM' And @UOM <> N'UOM1' And @UOM <> N'UOM2'  
		Set @UOM = 'UOM2'  
 
	  
	If @ProductHierarchy = N'%' Or @ProductHierarchy = N'Division'  
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
	 RowID Int Identity(1,1), SelCat Int,  
	 SelCatName nVarChar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,  
	 CatID int,  
	 Channel int,SalesManID int,Beat int,  
	 CustomerID nVarChar(30)COLLATE SQL_Latin1_General_CP1_CI_AS,       
	 ItemCode NVarChar(30)COLLATE SQL_Latin1_General_CP1_CI_AS,  
	 UOM int,UOM1 int,UOM2 int,  
	 Serial nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
	 TotQty Decimal(18,6),  
	 NetValue Decimal(18,6),  
	 TNetValue Decimal(18,6),  
	 TDisc Decimal(18,6),  
	 MUOM nVarChar(2000)
	)  
  
	Insert Into #TempSale  
	(SelCat,SelCatName,CatID,Channel,SalesManID,Beat,CustomerID,  
	ItemCode,UOM,UOM1,UOM2,Serial,  
	TotQty,NetValue,
	TNetValue,TDisc)   
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
	Cast(IDT.Serial as nVarchar(100)) 'Serial',  
	Sum(IDT.Quantity) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' 
		Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),  
	Max(IDT.Amount),   
	(Case When Max(IA.AdditionalDiscount) >0 Then (Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue) Else 0 End),  
	(((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.AdditionalDiscount)) / 100)  
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
	IA.CustomerID,IDT.InvoiceID,IA.InvoiceType,I.Product_Code,
	IDT.Serial

	
	
	Select * into #TempSale2 From #TempSale


	Declare @GrpCode Int  
	Declare @GrpCustCode nVarChar(30)  
	Declare @UOMS int  
	Declare @UOMList nVarChar(2000)  
	  
	If @ReportLevel = 'Customer Type wise'  
	Begin  
		Declare MUomCursor Cursor For Select Channel from #TempSale2 Group By Channel  
		Open MUomCursor   
		Fetch from MUomCursor Into @GrpCode  
		While @@Fetch_Status = 0   
		Begin  
			Set @UOMList = ''  
			If @UOM = 'UOM2'  
				Declare Uoms Cursor for Select Distinct UOM2 from #TempSale2 where Channel = @GrpCode  
			Else IF @UOM = 'UOM1'  
				Declare Uoms Cursor for Select Distinct UOM1 from #TempSale2 where Channel = @GrpCode  
			Else  
				Declare Uoms Cursor for Select Distinct UOM from #TempSale2 where Channel = @GrpCode  
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
			Update #TempSale2 Set MUOM = @UOMList where Channel = @GrpCode  
			Fetch Next from MUomCursor Into @GrpCode  
		End  
		Close MUomCursor   
		Deallocate MUomCursor   
	 End  
	 Else If @ReportLevel = 'DS wise'  
	 Begin  
		Declare MUomCursor Cursor For Select SalesManID from #TempSale2 Group By SalesManID  
		Open MUomCursor   
		Fetch from MUomCursor Into @GrpCode  
		While @@Fetch_Status = 0   
		Begin  
			Set @UOMList = ''  
			If @UOM = 'UOM2'  
				Declare Uoms Cursor for Select Distinct UOM2 from #TempSale2 where SalesManID = @GrpCode  
			Else IF @UOM = 'UOM1'  
				Declare Uoms Cursor for Select Distinct UOM1 from #TempSale2 where SalesManID = @GrpCode  
			Else  
				Declare Uoms Cursor for Select Distinct UOM from #TempSale2 where SalesManID = @GrpCode  
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
			Update #TempSale2 Set MUOM = @UOMList where SalesManID = @GrpCode  
			Fetch Next from MUomCursor Into @GrpCode  
		End  
		Close MUomCursor   
		Deallocate MUomCursor   
	 End  
	 Else If @ReportLevel = 'Beat wise'  
	 Begin  
		Declare MUomCursor Cursor For Select Beat from #TempSale2 Group By Beat  
		Open MUomCursor   
		Fetch from MUomCursor Into @GrpCode  
		While @@Fetch_Status = 0   
		Begin  
			Set @UOMList = ''  
			If @UOM = 'UOM2'  
				Declare Uoms Cursor for Select Distinct UOM2 from #TempSale2 where Beat = @GrpCode  
			Else IF @UOM = 'UOM1'  
				Declare Uoms Cursor for Select Distinct UOM1 from #TempSale2 where Beat = @GrpCode  
			Else  
				Declare Uoms Cursor for Select Distinct UOM from #TempSale2 where Beat = @GrpCode  
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
			Update #TempSale2 Set MUOM = @UOMList where Beat = @GrpCode  
			Fetch Next from MUomCursor Into @GrpCode  
		End  
		Close MUomCursor   
		Deallocate MUomCursor   
	 End  
	 Else If @ReportLevel = 'Customer wise'  
	 Begin  
		Declare MUomCursor Cursor For Select CustomerID from #TempSale2 Group By CustomerID  
		Open MUomCursor   
		Fetch from MUomCursor Into @GrpCustCode  
		While @@Fetch_Status = 0   
		Begin  
			Set @UOMList = ''  
			If @UOM = 'UOM2'  
				Declare Uoms Cursor for Select Distinct UOM2 from #TempSale2 where CustomerID = @GrpCustCode  
			Else IF @UOM = 'UOM1'  
				Declare Uoms Cursor for Select Distinct UOM1 from #TempSale2 where CustomerID = @GrpCustCode  
			Else  
				Declare Uoms Cursor for Select Distinct UOM from #TempSale2 where CustomerID = @GrpCustCode  
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
			Update #TempSale2 Set MUOM = @UOMList where CustomerID = @GrpCustCode  
			Fetch Next from MUomCursor Into @GrpCustCode  
		End  
		Close MUomCursor   
		Deallocate MUomCursor   
	 End  
	 Else --'Category Wise'  
	 Begin  
		Declare MUomCursor Cursor For Select SelCat from #TempSale2 Group By SelCat  
		Open MUomCursor   
		Fetch from MUomCursor Into @GrpCode  
		While @@Fetch_Status = 0   
		Begin  
			Set @UOMList = ''  
			If @UOM = 'UOM2'  
				Declare Uoms Cursor for Select Distinct UOM2 from #TempSale2 where SelCat = @GrpCode  
			Else IF @UOM = 'UOM1'  
				Declare Uoms Cursor for Select Distinct UOM1 from #TempSale2 where SelCat = @GrpCode  
			Else  
				Declare Uoms Cursor for Select Distinct UOM from #TempSale2 where SelCat = @GrpCode  
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
			Update #TempSale2 Set MUOM = @UOMList where SelCat = @GrpCode  
			Fetch Next from MUomCursor Into @GrpCode  
		End  
		Close MUomCursor   
		Deallocate MUomCursor   
	 End  

	 
	 Create Table #TempPreResult    
	 (  
	  Code int,  
	  GrpBy nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
	  UOMs nVarChar(2000),  
	  TotQty decimal(18,6),  
	  TotSalVal Decimal(18,6),  
	  DiscSalVal Decimal(18,6),  
	  ASalVal Decimal(18,6),  
	  ADisc Decimal(18,6),  
	  TSalVal Decimal(18,6),  
	  TDisc Decimal(18,6),  
	  TotDisc Decimal(18,6),  
	) 
	  
	If @ReportLevel = 'Customer Type wise'  
		Insert into #TempPreResult   
		(Code, GrpBy, UOMs, TotQty,    
		TotSalVal,    
		TSalVal, TDisc, TotDisc)  
		Select Channel, Max(CC.ChannelDesc),  
		Max(MUOM),  
		Sum(IsNull(TotQty,0)),  
		Sum(IsNull(NetValue,0)),  
		Sum(IsNull(TNetValue,0)),  
		Sum(IsNull(TDisc,0)),  
		Sum(IsNull(TDisc,0))  
		from #TempSale2 TS,Customer_Channel CC  
		Where TS.Channel = CC.ChannelType  
		Group by Channel  
	Else If @ReportLevel = 'DS wise'  
		Insert into #TempPreResult   
		(Code, GrpBy, UOMs, TotQty,   
		TotSalVal,
		TSalVal, TDisc, TotDisc)  
		Select TS.SalesManID,Max(SM.SalesMan_Name),  
		Max(MUOM),  
		Sum(IsNull(TotQty,0)),  
		Sum(IsNull(NetValue,0)),   
		Sum(IsNull(TNetValue,0)),  
		Sum(IsNull(TDisc,0)),  
		Sum(IsNull(TDisc,0))  
		from #TempSale2 TS,SalesMan SM  
		Where TS.SalesManID = SM.SalesManID  
		Group by TS.SalesManID  
	Else If @ReportLevel = 'Beat wise'  
		Insert into #TempPreResult   
		(Code, GrpBy, UOMs, TotQty,    
		TotSalVal,
		TSalVal,TDisc, TotDisc)  
		Select Beat,Max(B.Description),  
		Max(MUOM),  
		Sum(IsNull(TotQty,0)),  
		Sum(IsNull(NetValue,0)),  
		Sum(IsNull(TNetValue,0)),  
		Sum(IsNull(TDisc,0)),  
		Sum(IsNull(TDisc,0))  
		from #TempSale2 TS,Beat B  
		Where Beat = B.BeatID  
		Group by Beat  
	  
	Else If @ReportLevel = 'Customer wise'  
		Insert into #TempPreResult   
		(Code, GrpBy, UOMs, TotQty,   
		TotSalVal,
		TSalVal,TDisc, TotDisc)  
		Select 1,CustomerID,  
		Max(MUOM),  
		Sum(IsNull(TotQty,0)),  
		Sum(IsNull(NetValue,0)),  
		Sum(IsNull(TNetValue,0)),  
		Sum(IsNull(TDisc,0)),  
		Sum(IsNull(TDisc,0))  
		from #TempSale2 TS  
		Group by CustomerID  
	Else --'Category Wise'  
		Insert into #TempPreResult   
		(Code, GrpBy, UOMs, TotQty, 
		TotSalVal,
		TSalVal, TDisc, TotDisc)  
		Select SelCat, Max(SelCatName),  
		Max(MUOM),  
		Sum(IsNull(TotQty,0)),  
		Sum(IsNull(NetValue,0)),  
		Sum(IsNull(TNetValue,0)),  
		Sum(IsNull(TDisc,0)),  
		Sum(IsNull(TDisc,0))  
		from #TempSale2 TS  
		Group by SelCat  
  
	Set @SqlStat = ''  
	  
	If @ReportLevel = 'Customer Type wise'  
		Set @SqlStat = @SqlStat + 'Select Code,"Customer Type" = GrpBy,'  
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

	Exec Sp_sqlExec @SqlStat  

	Drop Table #TempCategory  
	Drop Table #TempSelectedCats  
	Drop Table #TempSelCatsLeaf  
	Drop Table #TempChannels  
	Drop Table #TempSalesMans  
	Drop Table #TempBeats  
	Drop Table #TempCust  
	Drop Table #TempSale  
	Drop Table #TempSale2   
	Drop Table #TempPreResult  
END
