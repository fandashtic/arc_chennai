CREATE Procedure mERP_spr_TMDOutletSalDmg_Upload(@FromDate DateTime, @ToDate DateTime)
As
set dateformat dmy
Declare @WDCode NVarchar(255)
Declare @WDDest NVarchar(255)
Declare @CompaniesToUploadCode NVarchar(255)

Declare @CUSTID nVarChar(50)
Declare @SUBTOTAL NVarchar(50)  
Declare @GRNTOTAL NVarchar(50)  
Declare @DayClosed Int 

	/* To Find Whether Day isclosed for the current month Last Day */
	Select @DayClosed = 0
	If (Select isNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') = 1
		Begin
			If ((Select dbo.StripTimeFromDate(LastInventoryUpload) From Setup) >= dbo.StripTimeFromDate(@ToDate))
			Set @DayClosed = 1
		End
	/* Report should be generated only if the last day of the month is Closed */
	If @DayClosed = 0
	GoTo OvernOut


Set @SUBTOTAL = dbo.LookupDictionaryItem(N'SubTotal:', Default)   
Set @GRNTOTAL = dbo.LookupDictionaryItem(N'GrandTotal:', Default)   
Set @CUSTID = dbo.LookupDictionaryItem(N'Customer ID', Default) 


Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload  
Select Top 1 @WDCode = RegisteredOwner From Setup    
  
If @CompaniesToUploadCode='ITC001'  
 Set @WDDest= @WDCode  
Else  
Begin  
 Set @WDDest= @WDCode  
 Set @WDCode= @CompaniesToUploadCode  
End  

-- new channel classifications added-------------------------------

Declare @TOBEDEFINED nVarchar(50)

Set @TOBEDEFINED=dbo.LookupDictionaryItem(N'To be defined', Default)

CREATE TABLE #OLClassMapping (OLClassID Int, CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)  

Create Table #OLClassCustLink (OLClassID Int, CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
ChannelType Int, Active Int, [Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert Into #OLClassMapping 
Select  olcm.OLClassID, olcm.CustomerId, olc.Channel_Type_Desc, olc.Outlet_Type_Desc, 
olc.SubOutlet_Type_Desc 
From tbl_merp_olclass olc, tbl_merp_olclassmapping olcm
Where olc.ID = olcm.OLClassID And
olc.Channel_Type_Active = 1 And olc.Outlet_Type_Active = 1 And olc.SubOutlet_Type_Active = 1 And 
olcm.Active = 1  

Insert Into #OLClassCustLink 
Select olcm.OLClassID, C.CustomerId, C.ChannelType , C.Active, IsNull(olcm.[Channel Type], @TOBEDEFINED), 
IsNull(olcm.[Outlet Type], @TOBEDEFINED) , IsNull(olcm.[Loyalty Program], @TOBEDEFINED) 
From #OLClassMapping olcm
Right Outer Join  Customer C On olcm.CustomerID = C.CustomerID

-------------------------------------------------

Create Table #TempConsolidate(
WDCode NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
WDDest NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[From Date] DateTime,
[To Date] Datetime,
CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
RCSID nVarChar(255),
SKUCode nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
Sales Decimal(18,6),
SRDmg Decimal(18,6), 
Val Decimal(18,6),
[Active in RCS] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
SalesWithGV Decimal(18,6), 
ValueWithGV	Decimal(18,6), 
CustomerType nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
ChannelType	nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
OutletType nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
LoyaltyProgram nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Base GOI Market ID] Int,
[Base GOI Market Name] nVarchar(240) COLLATE SQL_Latin1_General_CP1_CI_AS
)

Select * into #tmpInvoiceAbstract From (Select * from InvoiceAbstract Where InvoiceDate between @FromDate and @ToDate
And CustomerID in (Select customerID from #OLClassCustLink)) T
Select * into #tmpInvoiceDetail From (Select * from InvoiceDetail where InvoiceID In ( Select InvoiceID From #tmpInvoiceAbstract)) T

Select * into #TmpCollectionDetail From (Select CD.* from CollectionDetail CD,#tmpInvoiceAbstract IA Where CD.InvoiceID =IA.InvoiceID and CD.DocumentType=10) T

Insert into #TempConsolidate 
(WDCode, WDDest, [From Date],
[To Date], CustomerID, RCSID, SKUCode, Sales, SRDmg, Val, [Active in RCS],
SalesWithGV, ValueWithGV, CustomerType, ChannelType, OutletType, LoyaltyProgram)

Select @WDCode, @WDDest, @FromDate, @ToDate, IA.CustomerID, C.RCSOutLetID, ID.Product_Code,
Sum(
Case When IA.InvoiceType in (1,3) Then ID.Quantity 
     When IA.InvoiceType = 4 and IsNull(IA.Status,0) & 32 = 0 Then -ID.Quantity Else 0 End),
Sum(
Case When IA.InvoiceType = 4 and IsNull(IA.Status,0) & 32 <> 0 Then ID.Quantity Else 0 End),

Sum(Case When IA.InvoiceType in (1,3) Then ID.Amount
     When IA.InvoiceType = 4 Then -ID.Amount Else 0 End ),

isNull((Select isNull(TMDValue,'No') From Cust_TMD_Master Where TMDID = 
	(Select Top 1 TMDID From Cust_TMD_Details Where TMDCtlPos = 3 And CustomerID = C.CustomerID)),'No'),

Case When IsNull((Select Count(*) From #TmpCollectionDetail
Where DocumentType = 10 And InvoiceID = IA.InvoiceID), 0) > 0  Then 
Sum(Case When IA.InvoiceType in (1,3) Then ID.Quantity 
     When IA.InvoiceType = 4 and IsNull(IA.Status,0) & 32 = 0 Then -ID.Quantity Else 0 End) Else 0 End ,

Case When IsNull((Select Count(*) From #TmpCollectionDetail
Where DocumentType = 10 And InvoiceID = IA.InvoiceID), 0) > 0  Then 
Sum(Case When IA.InvoiceType in (1,3) Then ID.Amount
     When IA.InvoiceType = 4 Then -ID.Amount Else 0 End) Else 0 End,

(SELECT ChannelDesc FROM Customer_Channel 
Where ChannelType = C.ChannelType),

IsNull(olcl.[Channel Type], @TOBEDEFINED) , 
IsNull(olcl.[Outlet Type], @TOBEDEFINED), 
IsNull(olcl.[Loyalty Program], @TOBEDEFINED)

From #tmpInvoiceAbstract IA, #tmpInvoiceDetail ID, Customer C, #OLClassCustLink olcl
Where IsNull(IA.Status,0) & 128 = 0 
And IA.InvoiceType in (1,3,4)
And ID.SalePrice <> 0
And IA.InvoiceDate between @FromDate and @ToDate
And IA.InvoiceID = ID.InvoiceID
And IA.CustomerID = C.CustomerID
And IA.CustomerID = olcl.CustomerID 
Group By IA.CustomerID,C.RCSOutLetID, ID.Product_Code, C.CustomerID, 
IA.InvoiceID, C.ChannelType, olcl.[Channel Type], 
olcl.[Outlet Type], olcl.[Loyalty Program]

--Branch Integration is not for ITC and below lines are commented
/*
If (Select Count(*) From Reports Where ReportName = 'TMD- Outlet Wise Sales & Damage' And ParameterID in   
(Select ParameterID From dbo.GetReportParametersForSPR('TMD- Outlet Wise Sales & Damage') Where   
FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)))>=1  
Begin  
Insert into #TempConsolidate
(WDCode, WDDest, [From Date],
[To Date], CustomerID, RCSID, SKUCode, Sales, SRDmg, Val, [Active in RCS],
SalesWithGV, ValueWithGV, CustomerType, ChannelType, OutletType, LoyaltyProgram,MarketID,MarketName)
Select Field1, Field2, Field3, Field4, Field5, Field6, Field7,
Cast(Field8 as Decimal(18,6)),
Cast(Field9 as Decimal(18,6)),
Cast(Field10 as Decimal(18,6)),
Field11,
Cast(Field12 as Decimal(18,6)),
Cast(Field13 as Decimal(18,6)),
Field14,
Field15,
Field16,
Field17,
Field18,
Field19
From Reports, ReportAbstractReceived  
Where Reports.ReportID in           
(Select Distinct ReportID From Reports                 
Where ReportName = 'TMD- Outlet Wise Sales & Damage'           
And ParameterID in (Select ParameterID From dbo.GetReportParametersForSPR('TMD- Outlet Wise Sales & Damage') Where          
FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)))  
And ReportAbstractReceived.ReportID = Reports.ReportID              
and ReportAbstractReceived.Field1 <> @SUBTOTAL      
and ReportAbstractReceived.Field1 <> @GRNTOTAL   
and ReportAbstractReceived.Field3 <> @CUSTID
End
*/
Update T Set T.[Base GOI Market ID] = T1.MarketID,T.[Base GOI Market Name] = T1.MarketName From #TempConsolidate T, MarketInfo T1,CustomerMarketInfo T2
Where Ltrim(Rtrim(T.CustomerID)) = Ltrim(Rtrim(T2.CustomerCode))
And T2.Active = 1
And T1.MMID = T2.MMID
--And T1.Active = 1

Select "_1" = dbo.mERP_fn_FilterSplChar_ITC(IsNull(WDCode, '')), 
	"_2" = dbo.mERP_fn_FilterSplChar_ITC(IsNull(WDDest, '')), 
	"_3" = Convert(nVarchar(10),@FromDate,103)  ,
	"_4" = Convert(nVarchar(10),@ToDate,103), 
	"_5" = dbo.mERP_fn_FilterSplChar_ITC(IsNull(CustomerID, '')), 
	"_6" = dbo.mERP_fn_FilterSplChar_ITC(IsNull(RCSID, '')),
	"_7" = dbo.mERP_fn_FilterSplChar_ITC(IsNull(SKUCode, '')), 
	"_8" = Sum(IsNull(Sales,0)), 
	"_9" = Sum(IsNull(SRDmg, 0)),
	"_10" = Sum(IsNull(Val, 0)), 
	"_11" = dbo.mERP_fn_FilterSplChar_ITC(IsNull([Active in RCS], '')),
	"_12" = Sum(IsNull(SalesWithGV, 0)),
	"_13" = Sum(IsNull(ValueWithGV, 0)), 
	"_14" = dbo.mERP_fn_FilterSplChar_ITC(IsNull(CustomerType, '')),
	"_15" = dbo.mERP_fn_FilterSplChar_ITC(IsNull(ChannelType, '')),
	"_16" = dbo.mERP_fn_FilterSplChar_ITC(IsNull(OutletType, '')),
	"_17" = dbo.mERP_fn_FilterSplChar_ITC(IsNull(LoyaltyProgram, '')),
	"_18" = dbo.mERP_fn_FilterSplChar_ITC(IsNull([Base GOI Market ID], '')),
	"_19" = dbo.mERP_fn_FilterSplChar_ITC(IsNull([Base GOI Market Name], ''))
From #TempConsolidate as Abstract 
Group By 
WDCode, WDDest, [From Date], [To Date], 
CustomerID, RCSID, SKUCode, [Active in RCS],
CustomerType, ChannelType, OutletType, LoyaltyProgram,
[Base GOI Market ID],[Base GOI Market Name]
Order By CustomerID for XML Auto, ROOT ('Root')  
 
Drop Table #TempConsolidate 
OvernOut:

