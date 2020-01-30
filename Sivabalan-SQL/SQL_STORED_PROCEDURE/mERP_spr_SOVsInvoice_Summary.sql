Create Procedure mERP_spr_SOVsInvoice_Summary
(
@Category  nVarchar(4000),
@UOM  nVarchar(20),
@ReportType nVarchar(100),
@FromDate Datetime,
@ToDate Datetime
)
As
Begin
SET Dateformat dmy
Declare @Expirydate datetime
set @Expirydate= dbo.getSOExpiryDate()

Declare @CategoryID1 Int
Declare @Continue Int          
Declare @Inc Int          
Declare @TCat Int          
Declare @Delimeter as char
Declare @SC nVarchar(15)
Declare @Inv nVarchar(15)
Declare @RptRcvd Int
Declare @CompaniesToUploadCode as nVarchar(255)   	
Declare @WDCode as nVarchar(255)    
Declare @WDDestCode as nVarchar(255)
Declare @SUBTOTAL nVarchar(50)
Declare @GRNTOTAL nVarchar(50)
Declare @TOBEDEFINED nVarchar(50)

Declare @PrevDate DateTime
Declare @LastDate DateTime
	
Set @Delimeter = Char(15)
Declare @CategoryID int  
Set @Continue = 1  
Select @SC = Prefix From VoucherPrefix Where TranID = 'SALE CONFIRMATION'
Select @Inv = Prefix From VoucherPrefix Where TranID = 'INVOICE'

Set @SUBTOTAL = dbo.LookupDictionaryItem(N'SubTotal:', Default)
Set @GRNTOTAL = dbo.LookupDictionaryItem(N'GrandTotal:', Default)
Set @TOBEDEFINED=dbo.LookupDictionaryItem(N'To be defined', Default)

Set @PrevDate = Cast(Cast('01' + '/' + REPLACE(RIGHT(CONVERT(VARCHAR(20), DateAdd(Month, -1, Getdate()), 106), 8), ' ', '/') as nVarchar(15)) as datetime)
Set @LastDate = dbo.StripTimeFromDate(GetDate() - 7)


Create Table #tmpFinal(
[Outlet ID] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[RCS ID] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Outlet Name] nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Customer Type] nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
[DS ID] Int,
[DS Name] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
SalesmanType nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
Division nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Sub Category] nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Market SKU] nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Item Code] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Item Name] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
SoNumber Int,
SONo nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
SODate Datetime,
OrdQty Decimal(18,6),
OrdValue Decimal(18,6),
UOM nVarchar(500),
OrdDocRef nVarChar(255),
OrdPending Decimal(18,6),
OrdStatus nVarChar(10)
,BeatID Int
,Beat nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
,InvQty Decimal(18, 6)
,InvValue Decimal(18, 6)
)

--Select @FromDate, @PrevDate, @LastDate
IF @ReportType = "Customer Wise Category Wise Date Wise"
Begin
	If @FromDate < @LastDate
	Begin
		Select SONo, "Order No" = SONo, "Order Date" = SODate,
			[Outlet ID], [RCS ID], [Outlet Name], [DS Name], [Channel Type], [Outlet Type],	[Loyalty Program],
			"Division" = Division, "Sub Category" = [Sub Category], "Market SKU" = [Market SKU],
			"UOM"= UOM,	"Order Qty" =OrdQty,"Order Value" = OrdValue, "Invoice Qty" = InvQty ,
			"Invoice Value" = InvValue, "Fill Rate% -Qty" =  OrdQty, "Fill Rate% -Value" = OrdValue
		From #tmpFinal 
		
		Drop Table #tmpFinal
		Goto Out
	End
End

Else IF @ReportType = "Customer Wise Category Wise"
Begin
	If @FromDate < @PrevDate
	Begin
		Select [Outlet ID], [Outlet ID], [RCS ID], [Outlet Name], [DS Name], [Channel Type], [Outlet Type],	[Loyalty Program],
			"Division" = Division, "Sub Category" = [Sub Category], "Market SKU" = [Market SKU],
			"UOM"= UOM,	"Order Qty" =OrdQty,"Order Value" = OrdValue, "Invoice Qty" = InvQty ,
			"Invoice Value" = InvValue, "Fill Rate% -Qty" =  OrdQty, "Fill Rate% -Value" = OrdValue
		From #tmpFinal 
		
		Drop Table #tmpFinal
		Goto Out
	End
End

Else
Begin
	If @FromDate < @PrevDate
	Begin
		Select Division, "Division" = Division, "Sub Category" = [Sub Category], "Market SKU" = [Market SKU],
			"UOM"= UOM,	"Order Qty" =OrdQty,"Order Value" = OrdValue, "Invoice Qty" = InvQty ,
			"Invoice Value" = InvValue, "Fill Rate% -Qty" =  OrdQty, "Fill Rate% -Value" = OrdValue
		From #tmpFinal 
		
		Drop Table #tmpFinal
		Goto Out
	End
End

Create Table #tempcategory(CategoryID Int,Status Int)
Create Table #tmpcatID(Catid int,DivName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
						,SubCatName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
						,MarketSKU nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)


Create table #tmpCat(Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
IF @Category='%'     
   Insert into #tmpCat select Category_Name from ItemCategories  
Else    
   Insert into #tmpCat select * from dbo.sp_SplitIn2Rows(@Category,@Delimeter)    


Insert into #tempCategory select CategoryID, 0   
From ItemCategories
Where ItemCategories.Category_Name In (Select Category from #tmpCat)

While @Continue > 0  
Begin  
	Declare Parent Cursor Keyset For  
	Select CategoryID From #tempCategory Where Status = 0  
	Open Parent  
	Fetch From Parent Into @CategoryID  
	While @@Fetch_Status = 0  
	Begin  
		Insert into #tempCategory   
		Select CategoryID, 0 From ItemCategories   
		Where ParentID = @CategoryID  
		If @@RowCount > 0   
			Update #tempCategory Set Status = 1 Where CategoryID = @CategoryID  
		Else  
			Update #tempCategory Set Status = 2 Where CategoryID = @CategoryID  
		Fetch Next From Parent Into @CategoryID  
	End  
	Close Parent  
	DeAllocate Parent  
	Select @Continue = Count(*) From #tempCategory Where Status = 0  
End  
	
Delete #tempcategory Where Status not in  (0, 2)  
Drop Table #tmpCat  

select Distinct CategoryID, Status Into #tempCtg from #tempCategory
truncate table #tempCategory
Insert Into #tempCategory select * from #tempCtg

Insert Into #tmpcatID(Catid)
Select 
	distinct T.categoryid  
from 
	(Select Distinct CategoryID From #tempcategory) T,
	ItemCategories IC 
Where 
	T.CategoryID = IC.CategoryID And
	IC.Level = 4


Update tmpCtg Set DivName = IC2.Category_name, SubCatName = IC3.Category_name, MarketSKU = IC4.Category_name
from #tmpCatID tmpCtg
Join Itemcategories IC4 on tmpCtg.CatID = IC4.CategoryId Join Itemcategories IC3 on IC4.ParentId = IC3.CategoryId
Join Itemcategories IC2 on IC3.ParentId = IC2.CategoryId

--Select * From #tmpcatID

-- Channel type name changed, and new channel classifications added

CREATE TABLE #OLClassMapping (OLClassID Int, CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)  

Insert Into #OLClassMapping 
Select  olcm.OLClassID, olcm.CustomerId, olc.Channel_Type_Desc, olc.Outlet_Type_Desc, 
olc.SubOutlet_Type_Desc 
From tbl_merp_olclass olc, tbl_merp_olclassmapping olcm
Where olc.ID = olcm.OLClassID And
olc.Channel_Type_Active = 1 And olc.Outlet_Type_Active = 1 And olc.SubOutlet_Type_Active = 1 And 
olcm.Active = 1 


Create Table #tmpSO(
OutletID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
RCSOutletID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
OutletName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
ChannelDesc nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
SalesmanID Int,
SalesmanName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
SalesmanType nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
DivName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
SubCatName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
MarketSKU nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Item_Code nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Item_Name nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
SoNumber Int,
SONo nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
SODate Datetime,
OrdQty Decimal(18,6),
OrdValue Decimal(18,6),
UOM nVarchar(500),
OrdDocRef nVarChar(255),
OrdPending Decimal(18,6),
OrdStatus nVarChar(10)
,BeatID Int
,BeatName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
,InvQty Decimal(18, 6)
,InvValue Decimal(18, 6)
)


Insert Into #tmpSO(OutletID, RCSOutletID, OutletName, ChannelDesc, [Channel Type], [Outlet Type], [Loyalty Program], SalesmanID
					,SalesmanName, SalesmanType, DivName, SubCatName, MarketSKU, Item_Code, Item_Name, SoNumber, SONo, SODate
					, OrdQty ,OrdValue, UOM, OrdDocRef, OrdPending, OrdStatus, BeatID, BeatName, InvQty, InvValue)
	Select C.CustomerID,C.RCSOutletID,C.Company_Name,CH.ChannelDesc,
	Case IsNull(olcm.[Channel Type], '') 
	When '' Then 
		@TOBEDEFINED
	Else 
		olcm.[Channel Type]
	End,

	Case IsNull(olcm.[Outlet Type], '') 
	When '' Then 
		@TOBEDEFINED
	Else 
		olcm.[Outlet Type]
	End,

	Case IsNull(olcm.[Loyalty Program], '') 
	When '' Then 
		@TOBEDEFINED
	Else 
		olcm.[Loyalty Program] 
	End,

	SM.SalesmanID,SM.Salesman_Name,'',
	TCat.DivName,TCat.SubCatName, TCat.MarketSKU, SOD.Product_Code,I.ProductName,SOA.SONumber,@SC  + CAST(DocumentID AS nvarchar),SODate,
	Sum(Case @UOM When N'UOM1' Then isNull(SOD.Quantity,0)/(Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End) 	 
    When N'UOM2' Then isNull(SOD.Quantity,0)/(Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1 Else I.UOM2_Conversion End) 	 		
	Else isNull(SOD.Quantity,0) End),
	--Sum(isNull(SOD.Quantity,0) * isNull(SOD.Saleprice,0)  + (isNull(SOD.Quantity,0) * isNull(SOD.Saleprice,0) * Saletax/100)),
	Sum(isNull(SOD.Quantity,0) * isNull(SOD.Saleprice,0)),
	UOM.Description , 
	Case When Max(SOA.POReference) Like 'ERP%' And IsNull(SOA.ForumSC, 0) = 0 Then Max(SOA.PODocReference) Else Max(SOA.POReference) End, 
	Sum(Case @UOM When N'UOM1' Then isNull(SOD.Pending,0)/(Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End) 	 
    When N'UOM2' Then isNull(SOD.Pending,0)/(Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1 Else I.UOM2_Conversion End) 	 		
	Else isNull(SOD.Pending,0) End),''
	, SOA.BeatID, '', 0, 0
From 
	SOAbstract SOA 
	inner join SODetail SOD on SOA.SONumber = SOD.SONumber  
	inner join Salesman SM on SOA.SalesmanID = SM.SalesmanID  
	 inner join Customer C on SOA.CustomerID = C.CustomerID  
	inner join Customer_Channel CH on C.ChannelType = CH.ChannelType  
	right outer join #OLClassMapping olcm on olcm.CustomerID = c.CustomerID   
	inner join Items I on SOD.Product_Code = I.Product_Code  
	inner join #tmpCatID TCat on I.CategoryID = TCat.CatID  
	inner join UOM on (UOM.UOM = Case @UOM When 'Base UOM' Then I.UOM 
	When 'UOM1' Then I.UOM1
	Else I.UOM2 End) 
Where 
	dbo.striptimefromdate(SODate) Between @FromDate And @ToDate And
	ISNULL(SOA.Status,0) in (2,130,134,6,194)  
Group By
	C.CustomerID,C.RCSOutletID,C.Company_Name,CH.ChannelDesc,SM.SalesmanID,SM.Salesman_Name,
	TCat.DivName,TCat.SubCatName ,TCat.MarketSKU,SOD.Product_Code,I.ProductName,SOA.SONumber,SOA.DocumentID,SODate,UOM.Description ,
	olcm.[Channel Type] , olcm.[Outlet Type] , olcm.[Loyalty Program], SOA.ForumSC, SOA.BeatID  


--To delete fully cancelled sale order
Create Table #tmpSONumber(SONumber int)

Insert Into #tmpSONumber
Select SONumber From SOAbstract Where (IsNull(SOAbstract.Status,0) & 192) = 192 and dbo.striptimefromdate(SODate) Between @FromDate And @ToDate
and SONumber Not in( Select Distinct SONumber From InvoiceAbstract Where DocumentID In
						(Select Documentid From InvoiceAbstract Where IsNull(Status,0) & 64 = 0 and IsNull(Status,0) & 128 = 0)
					)

Delete From #tmpSO Where SONumber In(Select SONumber From #tmpSONumber)
--To delete fully cancelled sale order

Update #tmpSO Set SalesmanType = 
(Select Top 1 isNull(DSTypeValue,'') From DSType_Master DM,DSType_Details DD where DM.DSTypeID = DD.DSTypeID and DD.SalesmanID = #tmpSO.SalesmanID and DD.DSTypeCtlPos  = 1) 

Create Table #tmpInv(SONumber Int,InvDate Datetime,InvoiceID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
DocRef nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Prod_Code nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
InvQty Decimal(18,6),InvValue Decimal(18,6),InvID int, SalesmanID int,Division nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
SubCategory nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, MarketSKU nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)


Insert Into #tmpInv
Select 
	(Case isNull(SONumber,0) When 0 Then Case IA.InvoiceType When 3 Then 
		(Select Top 1 SONumber From InvoiceAbstract Where Documentid = IA.DocumentID and CustomerID = IA.CustomerID Order By InvoiceID) Else 
	 (Select Top 1 SONumber From InvoiceAbstract Where Documentid = IA.DocumentID Order By InvoiceID) End
	Else SONumber End ) ,
	InvoiceDate,(@Inv + Cast(IA.DocumentID as nVarchar) ),IA.CustomerID,DocReference,
	I.Product_Code ,
	Sum(Case @UOM When N'UOM1' Then isNull(ID.Quantity,0)/(Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End) 	 
	When N'UOM2' Then isNull(ID.Quantity,0)/(Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1 Else I.UOM2_Conversion End) 	 		
	Else isNull(ID.Quantity,0) End) ,
	--Sum(ID.Amount),
	Sum(isNull(ID.Quantity,0) * isNull(ID.Saleprice,0)),
	IA.Invoiceid, IA.SalesmanID, TCat.DivName, TCat.SubCatName, TCat.MarketSKU
	
From
	InvoiceAbstract IA,InvoiceDetail ID,
	Items I, #tmpCatID TCat
Where 
	(
		IA.SONumber In(Select SoNumber From #tmpSO) Or 
		IA.DocumentID In(Select DocumentID From InvoiceAbstract Where SONumber In(Select SoNumber From #tmpSO))
	)And
	isNull(IA.Status,0) & 128 = 0 And
	IA.InvoiceID = ID.InvoiceID And
	ID.Product_Code = I.Product_Code And
	I.CategoryID = TCat.CatID
	and IsNull(ID.Flagword, 0) = 0
	--I.CategoryID In (Select CategoryID From #tmpCatID) 
Group By 
	SONumber,DocumentID,IA.InvoiceDate,(@Inv + Cast(IA.DocumentID as nVarchar) ),
	I.Product_Code ,DocReference,IA.CustomerID, IA.InvoiceType, IA.ReferenceNumber,IA.Invoiceid, IA.SalesmanID
	, TCat.DivName, TCat.SubCatName, TCat.MarketSKU

Create Table #tmpDisp(SoNumber Int,DocumentID Int)
Insert Into #tmpDisp
Select 
	Cast((Select Top 1 Cast(Refnumber as Int) From DispatchAbstract Where DocumentID = DA.DocumentID Order By DispatchID Asc) as Int),NewInvoiceID
from 
	DispatchAbstract DA
where 
	status = 129 And
	DocumentID In(Select Documentid from DispatchAbstract where 
	RefNumber In (Select Cast(sonumber as nVarchar) From #tmpSO) And Status in(1,385,129))



Insert Into #tmpInv
Select 
	#tmpDisp.SoNumber,
	InvoiceDate,(@Inv + Cast(IA.DocumentID as nVarchar) ),IA.CustomerID,DocReference,
	I.Product_Code ,
	Sum(Case @UOM When N'UOM1' Then isNull(ID.Quantity,0)/(Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End) 	 
	When N'UOM2' Then isNull(ID.Quantity,0)/(Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1 Else I.UOM2_Conversion End) 	 		
	Else isNull(ID.Quantity,0) End) ,
	--Sum(ID.Amount),
	Sum(isNull(ID.Quantity,0) * isNull(ID.Saleprice,0)),
	IA.Invoiceid, IA.SalesmanID, TCat.DivName, TCat.SubCatName, TCat.MarketSKU
From
	InvoiceAbstract IA,InvoiceDetail ID,
	Items I,#tmpDisp, #tmpCatID TCat
Where 
	IA.DocumentID = #tmpDisp.DocumentID And
	isNull(IA.Status,0) & 128 = 0 And
	IA.InvoiceID = ID.InvoiceID And
	ID.Product_Code = I.Product_Code And
	I.CategoryID = TCat.CatID
	and IsNull(ID.Flagword, 0) = 0
	--I.CategoryID In (Select CategoryID From #tmpCatID) 
Group By 
	#tmpDisp.SONumber,IA.DocumentID,IA.InvoiceDate,(@Inv + Cast(IA.DocumentID as nVarchar) ),
	I.Product_Code ,DocReference,IA.CustomerID,IA.Invoiceid, IA.SalesmanID
	, TCat.DivName, TCat.SubCatName, TCat.MarketSKU


Create Table #tmpOutput(
ID int Identity(1,1) Not Null,
SONo nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
SODate Datetime,
OutletID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
RCSID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
OutletName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerType nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
ChannelType nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
OutletType nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
LoyaltyProgram nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
DSName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Division nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
SubCategory nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
MarketSKU nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
UOM nVarchar(20),
OrdQty Decimal(18,6),
OrdValue Decimal(18,6),
InvQty Decimal(18, 6),
InvValue Decimal(18, 6),
FillRateQty Decimal(18, 6),
FillRateValue Decimal(18,6)
)


IF @ReportType = "Customer Wise Category Wise"
Begin
	Insert Into #tmpFinal([Outlet ID], [RCS ID], [Outlet Name], [Customer Type], [Channel Type], [Outlet Type],
							[Loyalty Program], [DS ID], [DS Name], Division, [Sub Category], [Market SKU], UOM,
							OrdQty, OrdValue, InvQty, InvValue)
	Select 		
		OutletID,
		RCSOutletID,
		OutletName,
		ChannelDesc,
		[Channel Type], 
		[Outlet Type],  
		[Loyalty Program],
		SalesmanID,
		SalesmanName,
		DivName,
		SubCatName,
        MarketSKU,	
		"UOM"= UOM,
		"Order Qty" = Sum(OrdQty),
		"Order Item Value" = Sum(OrdValue),
		"Invoice Qty" = (Select Sum(IsNull(InvQty, 0)) From #tmpInv Where MarketSKU = SO.MarketSKU And SONumber = SO.SONumber) ,
		"Invoice Item Value" = (Select Sum(IsNull(InvValue, 0)) From #tmpInv Where MarketSKU = SO.MarketSKU And SONumber = SO.SONumber) 		
	From 
		#tmpSO SO
	Group By
		OutletID,RCSOutletID,OutletName,ChannelDesc,SalesmanID,SalesmanName,DivName,SubCatName,MarketSKU,UOM,
		[Channel Type] , [Outlet Type] ,  [Loyalty Program], SONumber	
	
	Insert into #tmpOutput(OutletID, RCSID, OutletName, DSName, ChannelType, OutletType, LoyaltyProgram,
						Division, SubCategory, MarketSKU, UOM, OrdQty, OrdValue, InvQty, InvValue, FillRateQty, FillRateValue)
	Select 
		[Outlet ID], [RCS ID], [Outlet Name], [DS Name], [Channel Type], [Outlet Type],	[Loyalty Program],
		"Division" = Division,
		"Sub Category" = [Sub Category],
		"Market SKU" = [Market SKU],
		"UOM"= @UOM,
		"Order Qty" = Sum(OrdQty),
		"Order Value" = Sum(OrdValue),
		"Invoice Qty" = Sum(IsNull(InvQty, 0))  ,
		"Invoice Value" = Sum(IsNull(InvValue, 0)) 
		,"Fill Rate% -Qty" =  Case When (Case When Sum(OrdQty) = 0 Then 0 Else (Sum(IsNull(InvQty, 0)) / Sum(OrdQty)) * 100 End) > 100 Then 100 Else (Case When Sum(OrdQty) = 0 Then 0 Else (Sum(IsNull(InvQty, 0)) / Sum(OrdQty)) * 100 End) End
		,"Fill Rate% -Value" = Case When (Case When Sum(OrdValue) = 0 Then 0 Else (Sum(IsNull(InvValue, 0)) / Sum(OrdValue)) * 100 End) > 100 Then 100 Else (Case When Sum(OrdValue) = 0 Then 0 Else (Sum(IsNull(InvValue, 0)) / Sum(OrdValue)) * 100 End) End
	From 
		#tmpFinal 
	Group By
		[Outlet ID], [RCS ID], [Outlet Name], [DS Name], [Channel Type], [Outlet Type],	[Loyalty Program],
		Division, [Sub Category], [Market SKU]
	Order By [Outlet Name], Division, [Sub Category], [Market SKU]

	Insert Into #tmpOutput(OutletID, OrdQty, OrdValue, InvQty, InvValue, FillRateQty, FillRateValue) 
		Select 'Grand Total:', Sum(OrdQty), Sum(OrdValue), Sum(InvQty), Sum(InvValue),
				Case When (Sum(InvQty)/Sum(OrdQty)) * 100 > 100 Then 100 Else (Sum(InvQty)/Sum(OrdQty)) * 100 End, 
				Case When (Sum(InvValue)/Sum(OrdValue)) * 100 > 100 Then 100 Else (Sum(InvValue)/Sum(OrdValue)) * 100 End
		From #tmpOutput
	
	Select 	ID, "OutletID" = OutletID, "RCS ID" = RCSID, "Outlet Name" = OutletName, "DS Name" = DSName, 
			"Channel Type" = ChannelType, "Outlet Type" = OutletType, "Loyalty Program" = LoyaltyProgram,
			Division, "Sub Category" = SubCategory, "Market SKU" = MarketSKU, "UOM" = UOM, 
			"Order Qty" = OrdQty, "Order Value" = OrdValue, "Invoice Qty" = InvQty, "Invoice Value" = InvValue, 
			"Fill Rate% -Qty" = FillRateQty, "Fill Rate% -Value" = FillRateValue
	From #tmpOutput
	Order By ID
End

Else IF @ReportType = "Customer Wise Category Wise Date Wise"
Begin
	Insert Into #tmpFinal([Outlet ID], [RCS ID], [Outlet Name], [Customer Type], [Channel Type], [Outlet Type],
							[Loyalty Program], [DS ID], [DS Name], Division, [Sub Category], [Market SKU],
							 SODate, SO.SONo, UOM, OrdQty, OrdValue, InvQty, InvValue)
	Select 
		OutletID,RCSOutletID,OutletName,ChannelDesc,
		[Channel Type] , [Outlet Type] , [Loyalty Program], SO.SalesmanID,SalesmanName,
		SO.DivName,SO.SubCatName,SO.MarketSKU,dbo.StripTimeFromDate(SODate),SO.SONo,
		UOM,Sum(IsNull(OrdQty, 0)),Sum(IsNull(OrdValue, 0)),		
		"Invoice Qty" = (Select Sum(IsNull(InvQty, 0)) From #tmpInv Where MarketSKU = SO.MarketSKU And SONumber = SO.SONumber) ,
		"Invoice Item Value" = (Select Sum(IsNull(InvValue, 0)) From #tmpInv Where MarketSKU = SO.MarketSKU And SONumber = SO.SONumber) 		
	From 
		#tmpSO SO  
	Group By
		OutletID,RCSOutletID,OutletName,ChannelDesc,SalesmanID,SalesmanName,DivName,SubCatName,MarketSKU,UOM,
		[Channel Type] , [Outlet Type] ,  [Loyalty Program], SONumber, SODate,SO.SONo


	Insert into #tmpOutput(SoNo, SoDate, OutletID, RCSID, OutletName, DSName, ChannelType, OutletType, LoyaltyProgram,
						Division, SubCategory, MarketSKU, UOM, OrdQty, OrdValue, InvQty, InvValue, FillRateQty, FillRateValue)
	Select 
		"Order No" = SONo, "Order Date" = SODate,
		[Outlet ID], [RCS ID], [Outlet Name], [DS Name], [Channel Type], [Outlet Type],	[Loyalty Program],
		"Division" = Division,
		"Sub Category" = [Sub Category],
		"Market SKU" = [Market SKU],
		"UOM"= @UOM,
		"Order Qty" = Sum(OrdQty),
		"Order Value" = Sum(OrdValue),
		"Invoice Qty" = Sum(IsNull(InvQty, 0))  ,
		"Invoice Value" = Sum(IsNull(InvValue, 0)) 
		,"Fill Rate% -Qty" =  Case When (Case When Sum(OrdQty) = 0 Then 0 Else (Sum(IsNull(InvQty, 0)) / Sum(OrdQty)) * 100 End) > 100 Then 100 Else (Case When Sum(OrdQty) = 0 Then 0 Else (Sum(IsNull(InvQty, 0)) / Sum(OrdQty)) * 100 End) End
		,"Fill Rate% -Value" = Case When (Case When Sum(OrdValue) = 0 Then 0 Else (Sum(IsNull(InvValue, 0)) / Sum(OrdValue)) * 100 End) > 100 Then 100 Else (Case When Sum(OrdValue) = 0 Then 0 Else (Sum(IsNull(InvValue, 0)) / Sum(OrdValue)) * 100 End) End
	From 
		#tmpFinal 
	Group By SONo, SODate,
		[Outlet ID], [RCS ID], [Outlet Name], [DS Name], [Channel Type], [Outlet Type],	[Loyalty Program],
		Division, [Sub Category], [Market SKU]
	Order By SODate, [Outlet Name], Division, [Sub Category], [Market SKU] 

	Insert Into #tmpOutput(SONo, OrdQty, OrdValue, InvQty, InvValue, FillRateQty, FillRateValue) 
		Select 'Grand Total:', Sum(OrdQty), Sum(OrdValue), Sum(InvQty), Sum(InvValue),
				Case When (Sum(InvQty)/Sum(OrdQty)) * 100 > 100 Then 100 Else (Sum(InvQty)/Sum(OrdQty)) * 100 End, 
				Case When (Sum(InvValue)/Sum(OrdValue)) * 100 > 100 Then 100 Else (Sum(InvValue)/Sum(OrdValue)) * 100 End
		From #tmpOutput
	
	Select 	ID, "Order No" = SONo, "Order Date" = SODate, "OutletID" = OutletID, "RCS ID" = RCSID, "Outlet Name" = OutletName, "DS Name" = DSName, 
			"Channel Type" = ChannelType, "Outlet Type" = OutletType, "Loyalty Program" = LoyaltyProgram,
			Division, "Sub Category" = SubCategory, "Market SKU" = MarketSKU, "UOM" = UOM, 
			"Order Qty" = OrdQty, "Order Value" = OrdValue, "Invoice Qty" = InvQty, "Invoice Value" = InvValue, 
			"Fill Rate% -Qty" = FillRateQty, "Fill Rate% -Value" = FillRateValue
	From #tmpOutput
	Order By ID

End
Else
Begin

	Insert Into #tmpFinal(Division, [Sub Category], [Market SKU], UOM,
							OrdQty, OrdValue, InvQty, InvValue)
	Select
		DivName,
		SubCatName,
        MarketSKU,
		"UOM"= UOM,
		"Order Qty" = Sum(IsNull(OrdQty, 0)),
		"Order Item Value" = Sum(IsNull(OrdValue, 0)),
		"Invoice Qty" = (Select Sum(IsNull(InvQty, 0)) From #tmpInv Where MarketSKU = SO.MarketSKU And SONumber = SO.SONumber) ,
		"Invoice Item Value" = (Select Sum(IsNull(InvValue, 0)) From #tmpInv Where MarketSKU = SO.MarketSKU And SONumber = SO.SONumber) 		
	From 
		#tmpSO SO
	Group By
		DivName, SubCatName, MarketSKU, UOM, SONumber

	Insert into #tmpOutput(Division, SubCategory, MarketSKU, UOM, OrdQty, OrdValue, InvQty, InvValue, FillRateQty, FillRateValue)
	Select 		
		"Division" = Division,
		"Sub Category" = [Sub Category],
		"Market SKU" = [Market SKU],
		"UOM"= @UOM,
		"Order Qty" = Sum(OrdQty),
		"Order Value" = Sum(OrdValue),
		"Invoice Qty" = Sum(IsNull(InvQty, 0))  ,
		"Invoice Value" = Sum(IsNull(InvValue, 0)) 
		,"Fill Rate% -Qty" =  Case When (Case When Sum(OrdQty) = 0 Then 0 Else (Sum(IsNull(InvQty, 0)) / Sum(OrdQty)) * 100 End) > 100 Then 100 Else (Case When Sum(OrdQty) = 0 Then 0 Else (Sum(IsNull(InvQty, 0)) / Sum(OrdQty)) * 100 End) End
		,"Fill Rate% -Value" = Case When (Case When Sum(OrdValue) = 0 Then 0 Else (Sum(IsNull(InvValue, 0)) / Sum(OrdValue)) * 100 End) > 100 Then 100 Else (Case When Sum(OrdValue) = 0 Then 0 Else (Sum(IsNull(InvValue, 0)) / Sum(OrdValue)) * 100 End) End
	From 
		#tmpFinal
	Group By
		Division, [Sub Category], [Market SKU]
	Order By Division, [Sub Category], [Market SKU]


	Insert Into #tmpOutput(Division, OrdQty, OrdValue, InvQty, InvValue, FillRateQty, FillRateValue) 
		Select 'Grand Total:', Sum(OrdQty), Sum(OrdValue), Sum(InvQty), Sum(InvValue),
				Case When (Sum(InvQty)/Sum(OrdQty)) * 100 > 100 Then 100 Else (Sum(InvQty)/Sum(OrdQty)) * 100 End, 
				Case When (Sum(InvValue)/Sum(OrdValue)) * 100 > 100 Then 100 Else (Sum(InvValue)/Sum(OrdValue)) * 100 End
		From #tmpOutput
	
	Select 	ID,	Division, "Sub Category" = SubCategory, "Market SKU" = MarketSKU, "UOM" = UOM, 
			"Order Qty" = OrdQty, "Order Value" = OrdValue, "Invoice Qty" = InvQty, "Invoice Value" = InvValue, 
			"Fill Rate% -Qty" = FillRateQty, "Fill Rate% -Value" = FillRateValue
	From #tmpOutput
	Order By ID
End

Drop table #tempcategory
Drop table #tmpcatID
Drop Table #tmpSO
Drop Table #tmpInv
Drop Table #tmpDisp
Drop Table #OLClassMapping

Drop Table #tmpFinal
Drop Table #tmpOutput
Drop Table #tmpSONumber

End

Out:

