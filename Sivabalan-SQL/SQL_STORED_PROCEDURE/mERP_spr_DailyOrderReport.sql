Create Procedure mERP_spr_DailyOrderReport
(
@SmanName  nVarchar(255),
@SmanType nVarchar(500),
@Channel nVarchar(500),
@Customer nVarchar(4000),
@Prod_Hierarchy  nVarchar(100),
@Category  nVarchar(255),
@UOM  nVarchar(20),
@LvlOfRpt nVarchar(15),
@DayWise nVarchar(255),
@FromDate Datetime,
@ToDate Datetime
)
As
Begin
Set dateformat dmy  
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

Set @Delimeter = Char(15)
Declare @CategoryID int  
Set @Continue = 1  
Select @SC = Prefix From VoucherPrefix Where TranID = 'SALE CONFIRMATION'
Select @Inv = Prefix From VoucherPrefix Where TranID = 'INVOICE'

Set @SUBTOTAL = dbo.LookupDictionaryItem(N'SubTotal:', Default)
Set @GRNTOTAL = dbo.LookupDictionaryItem(N'GrandTotal:', Default)
Set @TOBEDEFINED=dbo.LookupDictionaryItem(N'To be defined', Default)
If @Prod_Hierarchy = '%' or ltrim(rtrim(@Prod_Hierarchy)) = '' 
    select @Prod_Hierarchy = 'Division'

Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload        
Select Top 1 @WDCode = RegisteredOwner From Setup  

If @CompaniesToUploadCode='ITC001'        
	Set @WDDestCode= @WDCode        
Else        
	Begin        
		Set @WDDestCode= @WDCode        
		Set @WDCode= @CompaniesToUploadCode        
	End    


Create Table #tmpSManType(SmanID Int)
Create Table #tmpSman(SmanID Int)
Create Table #tmpSalesman(SalesmanID Int)
Create Table #tempcategory(CategoryID Int,Status Int)
Create Table #tmpcatID(Catid int,DivName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,SubCatName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #tmpCustomer(CustomerID NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #tmpChannel(ChannelType nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)


If @SmanType = N'%' Or @SmanType = N''    
	Insert Into #tmpSManType    
	Select SalesManID From Salesman Where Active = 1
Else    
	Insert Into #tmpSManType    
	Select SalesmanId From DSType_Details Where DSTypeID In (select DSTypeID From DSType_Master Where DSTypeValue In (Select * From dbo.sp_splitIn2Rows(@SmanType,@Delimeter)) and DSTypeCtlPos = 1 )    

	
If @SmanName = '%' Or @SmanType = N''    
	Insert Into #tmpSman    
	Select SalesmanID From Salesman Where Active = 1
Else    
	Insert Into #tmpSman    
	Select SalesmanID From Salesman Where Salesman_Name In (Select * From dbo.sp_splitin2Rows(@SmanName,@Delimeter))    

	
Insert Into #tmpSalesman    
Select 
	T.SmanID    
From 
	#tmpSManType T,#tmpSman S    
Where 
	T.SmanID = S.SmanID    

If (@Channel = N'%') OR  (@Channel = N'All Channels')
	Insert Into #tmpChannel Select ChannelType From Customer_Channel
Else
	Insert Into #tmpChannel Select ChannelType 
	From Customer_Channel Where ChannelDesc In (Select * From dbo.sp_SplitIn2Rows(@Channel, @Delimeter))

If @Customer = '%' Or @Customer = ''
	Insert Into #tmpCustomer Select CustomerID From Customer Where Active = 1
Else
	Insert Into #tmpCustomer Select CustomerID From Customer Where Company_Name In(Select * From dbo.sp_SplitIn2Rows(@Customer,@Delimeter))


Create table #tmpCat(Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
if @Category='%'     
   Insert into #tmpCat select Category_Name from ItemCategories    
Else    
   Insert into #tmpCat select * from dbo.sp_SplitIn2Rows(@Category,@Delimeter)    

If @Prod_Hierarchy = '%'
Begin
	Insert into #tempCategory select CategoryID, 0   
	From ItemCategories
	Where ItemCategories.Category_Name In (Select Category from #tmpCat)
End
Else
Begin
	Insert into #tempCategory select CategoryID, 0   
	From ItemCategories, ItemHierarchy  
	Where ItemCategories.Category_Name In (Select Category from #tmpCat) And   
	ItemCategories.Level =  ItemHierarchy.HierarchyID And  
	ItemHierarchy.HierarchyName like @Prod_Hierarchy  
End



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
Update tmpCtg Set DivName = IC2.Category_name, SubCatName = IC3.Category_name 
from #tmpCatID tmpCtg
Join Itemcategories IC4 on tmpCtg.CatID = IC4.CategoryId Join Itemcategories IC3 on IC4.ParentId = IC3.CategoryId 
Join Itemcategories IC2 on IC3.ParentId = IC2.CategoryId 


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
DivName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
SubCatName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
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
)


Insert Into #tmpSO
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
	TCat.DivName,TCat.SubCatName ,SOD.Product_Code,I.ProductName,SOA.SONumber,@SC  + CAST(DocumentID AS nvarchar),SODate,
	Sum(Case @UOM When N'UOM1' Then isNull(SOD.Quantity,0)/(Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End) 	 
    When N'UOM2' Then isNull(SOD.Quantity,0)/(Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1 Else I.UOM2_Conversion End) 	 		
	Else isNull(SOD.Quantity,0) End),Case Isnull(SOD.TaxOnQty,0)  When 0 then 
	Sum(isNull(SOD.Quantity,0) * isNull(SOD.Saleprice,0)  + (isNull(SOD.Quantity,0) * isNull(SOD.Saleprice,0) * Saletax/100)) Else
	Sum(isNull(SOD.Quantity,0) * isNull(SOD.Saleprice,0)  + (isNull(SOD.Quantity,0) * Saletax)) end ,
	UOM.Description , 
	Case When Max(SOA.POReference) Like 'ERP%' And IsNull(SOA.ForumSC, 0) = 0 Then Max(SOA.PODocReference) Else Max(SOA.POReference) End, 
	Sum(Case @UOM When N'UOM1' Then isNull(SOD.Pending,0)/(Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End) 	 
    When N'UOM2' Then isNull(SOD.Pending,0)/(Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1 Else I.UOM2_Conversion End) 	 		
	Else isNull(SOD.Pending,0) End),''
From SOAbstract SOA
	Inner Join SODetail SOD On SOA.SONumber = SOD.SONumber
	Inner Join Salesman SM On SOA.SalesmanID = SM.SalesmanID
	Inner Join Customer C On SOA.CustomerID = C.CustomerID
	Inner Join Customer_Channel CH On C.ChannelType = CH.ChannelType
	Left Outer Join  #OLClassMapping olcm On olcm.CustomerID = c.CustomerID 
	Inner Join Items I On SOD.Product_Code = I.Product_Code
	Inner Join #tmpCatID TCat On I.CategoryID = TCat.CatID
	Inner Join UOM On UOM.UOM = Case @UOM When 'Base UOM' Then I.UOM 	When 'UOM1' Then I.UOM1	Else I.UOM2 End 
Where SODate Between @FromDate And @ToDate And
	ISnULL(SOA.Status,0) in (2,130,134,6,194) And
	SOA.SalesmanID In (Select SalesmanID From #tmpSalesman) And
	SOA.CustomerID In (Select CustomerID From #tmpCustomer) And	CH.ChannelType In (Select ChannelType From #tmpChannel) 
Group By
	C.CustomerID,C.RCSOutletID,C.Company_Name,CH.ChannelDesc,SM.SalesmanID,SM.Salesman_Name,
	TCat.DivName,TCat.SubCatName ,SOD.Product_Code,I.ProductName,SOA.SONumber,SOA.DocumentID,SODate,UOM.Description ,
	olcm.[Channel Type] , olcm.[Outlet Type] , olcm.[Loyalty Program], SOA.ForumSC, Isnull(SOD.TaxOnQty,0)  



Update #tmpSO Set SalesmanType = 
(Select Top 1 isNull(DSTypeValue,'') From DSType_Master DM,DSType_Details DD where DM.DSTypeID = DD.DSTypeID and DD.SalesmanID = #tmpSO.SalesmanID and DD.DSTypeCtlPos  = 1) 

Create Table #tmpInv(SONumber Int,InvDate Datetime,InvoiceID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
DocRef nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Prod_Code nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
InvQty Decimal(18,6),InvValue Decimal(18,6))


Insert Into #tmpInv
Select 
	(Case isNull(SONumber,0) When 0 Then Case IA.InvoiceType When 3 Then (Select Top 1 SONumber From InvoiceAbstract Where Documentid = IA.DocumentID Order By InvoiceID desc) Else 
	 (Select Top 1 SONumber From InvoiceAbstract Where Documentid = IA.DocumentID Order By InvoiceID Asc) End
	Else SONumber End ) ,
	InvoiceDate,(@Inv + Cast(IA.DocumentID as nVarchar) ),IA.CustomerID,DocReference,
	I.Product_Code ,
	Sum(Case @UOM When N'UOM1' Then isNull(ID.Quantity,0)/(Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End) 	 
	When N'UOM2' Then isNull(ID.Quantity,0)/(Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1 Else I.UOM2_Conversion End) 	 		
	Else isNull(ID.Quantity,0) End) ,Sum(ID.Amount)
	
From
	InvoiceAbstract IA,InvoiceDetail ID,
	Items I
Where 
	(
		IA.SONumber In(Select SoNumber From #tmpSO) Or 
		IA.DocumentID In(Select DocumentID From InvoiceAbstract Where SONumber In(Select SoNumber From #tmpSO))
	)And
	isNull(IA.Status,0) & 128 = 0 And
	IA.InvoiceID = ID.InvoiceID And
	ID.Product_Code = I.Product_Code And
	I.CategoryID In (Select CategoryID From #tmpCatID) 
Group By 
	SONumber,DocumentID,IA.InvoiceDate,(@Inv + Cast(IA.DocumentID as nVarchar) ),
	I.Product_Code ,DocReference,IA.CustomerID, IA.InvoiceType, IA.ReferenceNumber  


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
	Else isNull(ID.Quantity,0) End) ,Sum(ID.Amount)
From
	InvoiceAbstract IA,InvoiceDetail ID,
	Items I,#tmpDisp
Where 
	IA.DocumentID = #tmpDisp.DocumentID And
	isNull(IA.Status,0) & 128 = 0 And
	IA.InvoiceID = ID.InvoiceID And
	ID.Product_Code = I.Product_Code And
	I.CategoryID In (Select CategoryID From #tmpCatID) 
Group By 
	#tmpDisp.SONumber,IA.DocumentID,IA.InvoiceDate,(@Inv + Cast(IA.DocumentID as nVarchar) ),
	I.Product_Code ,DocReference,IA.CustomerID



If @LvlOfRpt = 'Summary'
	Set @DayWise = 'N/A'
Else If @LvlOfRpt ='Detail' 
Begin
	if @DayWise = 'N/A' 
	   Set @DayWise = 'Yes'
End


If @DayWise = 'Yes' 
Begin
	Update #tmpSO Set OrdStatus = (Select Case When isNull(Status,0) = 194 Then 'Cancelled' 
	Else (Select Case When Sum(Quantity) = Sum(Pending) Then 'Open' Else 'Closed' End 
	From SODetail Where SODetail.SONumber = #tmpSO.SoNumber) End From SOAbstract 
	Where SOAbstract.SONumber  = #tmpSO.SoNumber )

	/* To get the non cancelled SO data*/
	Create Table #tmpSOExpiry(SONumber int)
	Insert into #tmpSOExpiry
	Select SODetail.SONumber from SODetail,#tmpSO,SOAbstract
	where SODetail.SONumber=#tmpSO.SONumber
	And SODetail.SONumber=SOAbstract.SONumber
	And SOAbstract.SONumber=#tmpSO.SONumber
	And isNull(SOAbstract.Status,0) <> 194
	And isnull(Pending,0) <> 0
	group by SODetail.SONumber having Sum(Pending) <= Sum(Quantity)

	Update #tmpSO Set OrdStatus = 'Expired' From SOAbstract 
	Where SOAbstract.SONumber  = #tmpSO.SoNumber 
	And Convert(Nvarchar(10),SOAbstract.SODate,103) <= @Expirydate
	And SOAbstract.SONumber in(select SONumber from #tmpSOExpiry)

	
	Drop Table #tmpSOExpiry
	

	Create Table #tmpOutput(
	[WDCode] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[WD Code] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[WD Dest] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[From Date] DateTime,
	[To Date] DateTime,
	--[OutletID] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Outlet ID] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[RCS ID] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Outlet Name] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Customer Type] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[DS ID] Int ,
	[DS Name] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[DS Type] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Division nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Sub Category] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Item Code] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Item Name] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Order Date] Datetime,
	[Order No] nVarchar(25),
	[Order Doc Ref] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,	
	[Invoice Date] Datetime,
	[Invoice No] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Invoice Doc Ref] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	UOM nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Order Qty] Decimal(18,6),
	[Status] nVarChar(10),
	[Pending Qty] Decimal(18,6),
	[Order Item Value] Decimal(18,6),
	[Invoice Qty] Decimal(18,6),
	[Invoice Item Value] Decimal(18,6))


	Insert Into #tmpOutput
	Select 
		@WDCode,@WDCode,@WDDestCode,@FromDate,@ToDate,OutletID,RCSOutletID,OutletName,ChannelDesc,
		[Channel Type] , [Outlet Type] , [Loyalty Program], SalesmanID,SalesmanName,
		SalesmanType,DivName,SubCatName,Item_Code,Item_Name,SODate,SO.SONo,SO.OrdDocRef,
		InvDate,InvoiceID,DocRef,UOM,OrdQty,SO.OrdStatus,case when SO.OrdStatus <> 'Cancelled' then case when (IsNull(OrdQty, 0) - IsNull(InvQty, 0)) < 0 then 0 else (IsNull(OrdQty, 0) - IsNull(InvQty, 0)) end else 0 end, IsNull(OrdValue, 0),IsNull(InvQty, 0), IsNull(InvValue, 0) --SO.OrdPending
	From	#tmpSO SO
		Left Outer Join #tmpInv Inv On SO.SONumber = Inv.SONumber And SO.Item_Code = Inv.Prod_Code

--	If (Select Count(*) From Reports Where ReportName = 'Order Vs Invoice' And ParameterID in   
--	(Select ParameterID From dbo.GetReportParametersForSPR('Order Vs Invoice') Where   
--	FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)) )>=1
--	Begin  
--		set @RptRcvd  = 1
--		Insert Into #tmpOutput 
--		Select Field1, Field1, Field2, Field3, Field4 , Field5, Field6 , Field7 , Field8 , Field9, 
--		Field10, Field11, Field12, Field13, Field14,
--		Field15, Field16 , Field17 , Field18 , Field19, Field20, Field21, Field22, 
--		Field23, Field24, Field25, 
--		Field26, Field27, Field28, Field29, Field30, Field31, Field32
--		From Reports, ReportAbstractReceived
--		Where Reports.ReportID in
--		(Select Distinct ReportID From Reports
--		Where ReportName = 'Order Vs Invoice'
--		And ParameterID in (Select ParameterID From dbo.GetReportParametersForSPR('Order Vs Invoice') Where
--		FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)))
--		And ReportAbstractReceived.ReportID = Reports.ReportID
--		and ReportAbstractReceived.Field1 <> 'WD Code'
--		and ReportAbstractReceived.Field1 <> @SUBTOTAL
--		and ReportAbstractReceived.Field1 <> @GRNTOTAL
--	End

	Select * From #tmpOutput Order by [Order Date]
End
Else If @DayWise = 'No' 
Begin
	select @WDCode [WDCode], @WDCode [WD Code], @WDDestCode [WD Dest], @FromDate [From Date], @ToDate [To Date],
		"Outlet ID"  = OutletID,
		"RCS ID  " = RCSOutletID,
		"Outlet Name" = OutletName,
		"Customer Type" = ChannelDesc,
		"Channel Type" = [Channel Type], 
		"Outlet Type" = [Outlet Type],  
		"Loyalty Program" = [Loyalty Program],
		"Division" = DivName,
		"Sub Category" = SubCatName,
		"Item Code" = Item_Code,
		"Item Name" = Item_Name,
		"UOM"= UOM,
		"Order Qty" = Sum(OrdQty),
		"Order Item Value" = Sum(OrdValue),
		"Invoice Qty" = (Select Sum(InvQty) From #tmpInv Where Prod_Code = SO.Item_Code And CustomerID = SO.OutletID) ,
		"Invoice Item Value" = (Select Sum(InvValue) From #tmpInv Where Prod_Code = SO.Item_Code And CustomerID = SO.OutletID) 
	From 
		#tmpSO SO
	Group By
		OutletID,RCSOutletID,OutletName,ChannelDesc,DivName,SubCatName,Item_Code,Item_Name,UOM,
		[Channel Type] , [Outlet Type] ,  [Loyalty Program]
		
End
Else  If @DayWise = 'N/A' 
Begin
	select 
		DivName,
		"Division" = DivName,
		"Sub Category" = SubCatName,
		"Item Code" = Item_Code,
		"Item Name" = Item_Name,
		"UOM"= UOM,
		"Order Qty" = Sum(OrdQty),
		"Order Item Value" = Sum(OrdValue),
		"Invoice Qty" = (Select Sum(InvQty) From #tmpInv Where Prod_Code = 	SO.Item_Code) ,
		"Invoice Item Value" = (Select Sum(InvValue) From #tmpInv Where Prod_Code = 	SO.Item_Code) 
	From 
		#tmpSO SO
	Group By
		DivName,SubCatName,Item_Code,Item_Name,UOM
End

Drop Table #tmpSManType
Drop Table #tmpSman
Drop Table #tmpSalesman
Drop table #tempcategory
Drop table #tmpcatID
Drop Table #tmpCustomer
Drop Table #tmpSO
Drop Table #tmpInv
Drop Table #tmpDisp
Drop Table #OLClassMapping
If @DayWise = 'Yes' 
Drop Table #tmpOutput


End


