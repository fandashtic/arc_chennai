Create Procedure mERP_spr_SOVsInvoice_ARU
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
Set @Delimeter = Char(15)
Declare @CategoryID int  
Set @Continue = 1  
Select @SC = Prefix From VoucherPrefix Where TranID = 'SALE CONFIRMATION'
Select @Inv = Prefix From VoucherPrefix Where TranID = 'INVOICE'


--By Default Key Accounts and Independent Self Service Stores channeltype alone will be considered
--while uploading the reports.
Set @SmanName  = '%'
Set @SmanType = '%'
Set @Customer = '%'
Set @Prod_Hierarchy = '%'
Set @Category  = '%'
Set @UOM  = 'Base UOM'
Set @LvlOfRpt = 'Detail'
Set @DayWise = 'Yes'
Set @Channel = 'Key Accounts'+ char(15) + 'Independent Self Service Stores'


Set @SUBTOTAL = dbo.LookupDictionaryItem(N'SubTotal:', Default)
Set @GRNTOTAL = dbo.LookupDictionaryItem(N'GrandTotal:', Default)


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


Insert Into #tmpcatID(Catid)
Select 
	distinct T.categoryid  
from 
	(Select Distinct CategoryID From #tempcategory) T,
	ItemCategories IC 
Where 
	T.CategoryID = IC.CategoryID And
	IC.Level = 4


Update #tmpCatID Set DivName = dbo.fn_GetLevelName(#tmpCatID.CatID,2)
Update #tmpCatID Set SubCatName = dbo.fn_GetLevelName(#tmpCatID.CatID,3)


Create Table #tmpSO(
OutletID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
RCSOutletID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
OutletName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
ChannelDesc nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
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
	Select C.CustomerID,C.RCSOutletID,C.Company_Name,CH.ChannelDesc,SM.SalesmanID,SM.Salesman_Name,'',
	TCat.DivName,TCat.SubCatName ,SOD.Product_Code,I.ProductName,SOA.SONumber,@SC  + CAST(DocumentID AS nvarchar),SODate,
	Sum(Case @UOM When N'UOM1' Then isNull(SOD.Quantity,0)/(Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End) 	 
    When N'UOM2' Then isNull(SOD.Quantity,0)/(Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1 Else I.UOM2_Conversion End) 	 		
	Else isNull(SOD.Quantity,0) End),
	Sum(isNull(SOD.Quantity,0) * isNull(SOD.Saleprice,0)  + (isNull(SOD.Quantity,0) * isNull(SOD.Saleprice,0) * Saletax/100)),
	UOM.Description ,Max(SOA.POReference), 
	Sum(Case @UOM When N'UOM1' Then isNull(SOD.Pending,0)/(Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End) 	 
    When N'UOM2' Then isNull(SOD.Pending,0)/(Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1 Else I.UOM2_Conversion End) 	 		
	Else isNull(SOD.Pending,0) End),''
From 
	SOAbstract SOA,SODetail SOD,Salesman SM,Customer C,Customer_Channel CH,
	Items I,#tmpCatID TCat,UOM
Where 
	SODate Between @FromDate And @ToDate And
	ISnULL(SOA.Status,0) in (2,130,134,6,194) And
	SOA.SalesmanID In (Select SalesmanID From #tmpSalesman) And
	SOA.CustomerID In (Select CustomerID From #tmpCustomer) And
	SOA.SalesmanID = SM.SalesmanID And
	SOA.CustomerID = C.CustomerID And
	C.ChannelType = CH.ChannelType And
	CH.ChannelType In (Select ChannelType From #tmpChannel) And
	SOA.SONumber = SOD.SONumber And
	SOD.Product_Code = I.Product_Code And
	I.CategoryID = TCat.CatID And
	(UOM.UOM = Case @UOM When 'Base UOM' Then I.UOM 
	When 'UOM1' Then I.UOM1
	Else I.UOM2 End) 
Group By
	C.CustomerID,C.RCSOutletID,C.Company_Name,CH.ChannelDesc,SM.SalesmanID,SM.Salesman_Name,
	TCat.DivName,TCat.SubCatName ,SOD.Product_Code,I.ProductName,SOA.SONumber,SOA.DocumentID,SODate,UOM.Description 

Update #tmpSO Set SalesmanType = 
(Select Top 1 isNull(DSTypeValue,'') From DSType_Master DM,DSType_Details DD where DM.DSTypeID = DD.DSTypeID and DD.SalesmanID = #tmpSO.SalesmanID and DD.DSTypeCtlPos  = 1) 

Create Table #tmpInv(SONumber Int,InvDate Datetime,InvoiceID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
DocRef nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Prod_Code nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
InvQty Decimal(18,6),InvValue Decimal(18,6))

Insert Into #tmpInv
Select 
	(Case isNull(SONumber,0) When 0 Then Case IA.InvoiceType When 3 Then IA.ReferenceNumber Else 
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

	Create Table #tmpOutput(
	[WDCode] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[WD Code] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[WD Dest Code] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[From Date] DateTime,
	[To Date] DateTime,
	[OutletID] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Outlet ID] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[RCS ID] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Outlet Name] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Channel Type] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
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
		@WDCode,@WDCode,@WDDestCode,@FromDate,@ToDate,OutletID,OutletID,RCSOutletID,OutletName,ChannelDesc,SalesmanID,SalesmanName,
		SalesmanType,DivName,SubCatName,Item_Code,Item_Name,SODate,SO.SONo,SO.OrdDocRef,
		InvDate,InvoiceID,DocRef,
		UOM,OrdQty,SO.OrdStatus,case when SO.OrdStatus <> 'Cancelled' then case when (IsNull(OrdQty, 0) - IsNull(InvQty, 0)) < 0 then 0 else (IsNull(OrdQty, 0) - IsNull(InvQty, 0)) end else 0 end, IsNull(OrdValue, 0), IsNull(InvQty, 0), IsNull(InvValue, 0) 
	From 
		#tmpSO SO
		Left Outer Join #tmpInv Inv On SO.SONumber = Inv.SONumber And		SO.Item_Code = Inv.Prod_Code 
		
	If (Select Count(*) From Reports Where ReportName = 'Order Vs Invoice' And ParameterID in   
	(Select ParameterID From dbo.GetReportParametersForSPR('Order Vs Invoice') Where   
	FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)) )>=1
	Begin  
		set @RptRcvd  = 1
		Insert Into #tmpOutput 
		Select Field1,Field1,Field2,Field3,Field4 ,Field5,Field6 ,Field7 ,Field8 ,Field9,Field10,Field11,Field12, Field13, Field14,
		Field15,Field16 ,Field17 ,Field18 ,Field19,Field20,Field21,Field22, Field23, Field24,Field25,Field26,Field27,Field28, Field29
		From Reports, ReportAbstractReceived
		Where Reports.ReportID in
		(Select Distinct ReportID From Reports
		Where ReportName = 'Order Vs Invoice'
		And ParameterID in (Select ParameterID From dbo.GetReportParametersForSPR('Order Vs Invoice') Where
		FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)))
		And ReportAbstractReceived.ReportID = Reports.ReportID
		and ReportAbstractReceived.Field1 <> 'WD Code'
		and ReportAbstractReceived.Field1 <> @SUBTOTAL
		and ReportAbstractReceived.Field1 <> @GRNTOTAL
	End

	Select * From #tmpOutput Order by [Order Date]
End
Else If @DayWise = 'No' 
Begin
	select 
		OutletID,
		"Outlet ID"  = OutletID,
		"RCS ID  " = RCSOutletID,
		"Outlet Name" = OutletName,
		"Channel Type" = ChannelDesc,
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
		OutletID,RCSOutletID,OutletName,ChannelDesc,DivName,SubCatName,Item_Code,Item_Name,UOM
		
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
If @DayWise = 'Yes' 
Drop Table #tmpOutput


End


