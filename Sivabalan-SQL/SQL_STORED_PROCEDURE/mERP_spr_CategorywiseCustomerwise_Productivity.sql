CREATE Procedure [dbo].[mERP_spr_CategorywiseCustomerwise_Productivity]
(
@CatLevel nVarchar(255),
@CateName nVarchar(4000),
@Channel nVarchar(4000),
@ChannelType nVarchar(4000),
@OutletType nVarchar(4000),
@LoyaltyProgram nVarchar(4000),
@DS nVarchar(4000),
@Beat nVarchar(4000),
@MerchandiseType nVarchar(4000),
@Productivity nVarchar(400),
@Sales nVarchar(50),
@CategoryHandler nvarchar(30),
@UOM nVarchar(20),
@FromDate DateTime,
@ToDate DateTime
)
As
Begin

Declare @Customer nVarchar(4000)
Declare @SQL as nVarchar(4000)
Declare @BeatCol as nVarchar(255)
Declare @SManCol as nVarchar(255)
Declare @CatName As nVarchar(255)
Declare @CatID As Int
Declare @i as Int
Declare @j as Int
Declare @BeatID as nVarchar(500)
Declare @BEAT1 as nVarchar(500)
Declare @SALESMAN1 as nVarchar(500)
Declare @BeatColumn as nVarchar(2000)
Declare @SalesColumn as nVarchar(2000)
Declare @BeatCnt as Integer
Declare @DefaultBeatID as Int
Declare @Delimeter as Char(1)
Declare @CategoryColumn as nvarchar(3)
Declare @categoryhandler1  As nVarchar(10)
Set @Delimeter=Char(15)
Declare @ProdCode nVarchar(255)


Create table #tmpProdDetails(ProdCode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, CompanyID int, DivisionID int, SubCategoryID int, MSKUID int, Company nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
SubCategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, MSKU nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create Table #tempCategoryList(CategoryId Int)
Create table #tempCategory (CategoryID Int, Status Int)
Create Table #tmpCategories(CatLevel Int, CatName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, LeafLevelCat Int)
Create Table #tmpChannel(ChannelType nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #tmpDS(SalesmanID Int)
Create Table #tmpDSName(SalesmanName nvarchar(100))
Create Table #tmpBeat(BeatID Int)
Create Table #tmpBeatName(BeatName nVarchar(256))
Create Table #tmpMerchandise(MerchandiseID Int)
Create Table #tmpCustomer(CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #tmpCust(CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #tmpItems(Product_Code nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)


--This table is to display the categories in the Order
Create table #tempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)
Exec sp_CatLevelwise_ItemSorting

If @CatLevel = '%'
Set @CatLevel = N'Company'
If @Sales = '%'
Set @Sales = N'Value'
If @UOM = '%'
Set @UOM = N'Base UOM'

If @Sales = 'Volume' And @UOM = 'N/A'
Set @UOM = N'Base UOM'

If @Sales = 'Value' And @UOM <> 'N/A'
Set @UOM = N'N/A'
set @CategoryHandler1 = @categoryhandler--Used to check further with input value
If @CategoryHandler = 'Yes'
SET @CategoryHandler = '''Yes'''
ELSE If @CategoryHandler = 'No'
SET @CategoryHandler = '''No'''
ELSE If @CategoryHandler = '%' Or @CategoryHandler = '' Or @CategoryHandler = 'All'
SET @CategoryHandler = '''Yes''' + ',' + '''No'''

If @CatLevel = 'Company'
SET @CategoryHandler = ''''''

If @CateName = '%'
Begin
Insert Into #tempCategoryList Select * From dbo.mERP_fn_GetCategory(@CatLevel)
End
Else
Insert Into #tempCategoryList Select CategoryID From ItemCategories Where Category_Name In(
Select * From dbo.sp_SplitIn2Rows(@CateName, @Delimeter))

--Get leaflevel categories of given hierarchy level
Declare Category Cursor  For
Select ItemCategories.Category_Name, ItemCategories.CategoryID
From ItemCategories Where ItemCategories.CategoryID In (select CategoryID from #tempCategoryList)
Open Category
Fetch From Category Into @CatName, @CatID
While @@Fetch_Status = 0
Begin
Exec GetLeafCategories @CatLevel , @CatName
Insert Into #tmpCategories Select @CatID, @CatName, CategoryID From #tempCategory
Delete From #tempCategory
Fetch From Category Into @CatName, @CatID
End
Close Category
Deallocate Category


IF @CatLevel = 'System SKU'
Begin
If @CateName = '%'
Insert Into #tmpCategories(CatLevel , CatName , LeafLevelCat)
Select Distinct IT.CategoryID, Category_Name,IT.CategoryID
From Items IT,ItemCategories ITC
Where IT.CategoryID = ITC.CategoryID
Else
Insert Into  #tmpCategories(CatLevel , CatName , LeafLevelCat)
Select Distinct IT.CategoryID, Category_Name,IT.CategoryID
From Items IT,ItemCategories ITC
Where IT.CategoryID = ITC.CategoryID
And IT.ProductName In
(Select * From dbo.sp_SplitIn2Rows(@CateName, @Delimeter))
End


IF @CatLevel = 'System SKU'
Begin
If @CateName = '%'
Insert Into #tmpItems
Select Product_Code From Items
Else
Insert Into #tmpItems
Select Product_Code From Items Where ProductName In(
Select * From dbo.sp_SplitIn2Rows(@CateName, @Delimeter))
End
Else
Insert Into #tmpItems
Select Product_Code From Items
If (@Channel = N'%') OR  (@Channel = N'All Channels')
Insert Into #tmpChannel Select ChannelType From Customer_Channel
Else
Insert Into #tmpChannel Select ChannelType
From Customer_Channel Where ChannelDesc In (Select * From dbo.sp_SplitIn2Rows(@Channel, @Delimeter))


If @DS = '%'
Insert Into #tmpDS Select SalesmanID From Salesman
Else
Insert Into #tmpDS Select SalesmanID From Salesman
Where Salesman_Name In(Select * From dbo.sp_SplitIn2Rows(@DS, @Delimeter))

If @DS = '%'
Insert Into #tmpDSName Select Salesman_Name From Salesman
Else
Insert Into #tmpDSName Select Salesman_Name From Salesman
Where Salesman_Name In(Select * From dbo.sp_SplitIn2Rows(@DS, @Delimeter))

IF @Beat = '%'
Insert Into #tmpBeat Select BeatID From Beat
--(Select SalesmanID From #tmpDS)
Else
Insert Into #tmpBeat Select BeatID From Beat Where Description in
(Select * From dbo.sp_SplitIn2Rows(@Beat, @Delimeter))

Insert Into #tmpBeatName Select Description From Beat 
Where BeatID In (Select BeatID from #tmpBeat)


If @MerchandiseType = '%'
Insert Into #tmpMerchandise Select MerchandiseID  From Merchandise
Else
Insert Into #tmpMerchandise Select MerchandiseID  From Merchandise
Where Merchandise In(Select * From dbo.sp_SplitIn2Rows(@MerchandiseType, @Delimeter))


If @MerchandiseType = '%'
Insert Into #tmpCustomer Select CustomerID From Customer
Where ChannelType In (Select * From #tmpChannel)
Else
Insert Into #tmpCustomer Select CustomerID From Customer
Where ChannelType In (Select * From #tmpChannel) And
CustomerID In(Select CustomerID from CustMerchandise Where MerchandiseID In
(Select MerchandiseID  From #tmpMerchandise))

iF @dS ='%' AND @bEAT ='%' 
INSERT INTO #tmpCust Select CustomerID from Customer where Active =1 and customercategory = 2
else if  @dS ='%' AND @bEAT <>'%' 
insert into #tmpCust Select cu.CustomerID from Customer cu,Beat_salesman bs where cu.customerid =bs.customerid and cu.Active =1 and customercategory = 2
And bs.BeatID In (Select BeatID From #tmpBeat) 
else
insert into #tmpCust Select cu.CustomerID from Customer cu,Beat_salesman bs where cu.customerid =bs.customerid and cu.Active =1 and customercategory = 2
and bs.salesmanid in (Select SalesmanID From #tmpDS)
And bs.BeatID In (Select BeatID From #tmpBeat) 


Create Table #tmpCustProductivity(CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
RCSID nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, CustomerName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryHandler nvarchar(3) COLLATE SQL_Latin1_General_CP1_CI_AS,  
Address nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
Channel nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
CatLevel nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, CatID Int,ProdCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
ProdName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Totactivecust int,NoOfMappedCust Int)

Create Table #tmpAllCustomer(CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
RCSID nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, CustomerName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryHandler nvarchar(3) COLLATE SQL_Latin1_General_CP1_CI_AS,  
Address nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Channel nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
CatLevel nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, CatID Int,ProdCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
ProdName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Totactivecust int,NoOfMappedCust Int)


-- Channel type name changed, and new channel classifications added

Declare @TOBEDEFINED nVarchar(50)

Set @TOBEDEFINED=dbo.LookupDictionaryItem(N'To be defined', Default)


Create Table #tmpChannelType (ChannelType nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
If (@ChannelType = N'%') OR  (@ChannelType = N'All Type')
	Insert Into #tmpChannelType Select Distinct Channel_Type_Desc From tbl_merp_olclass Union Select @TOBEDEFINED
Else
	Insert Into #tmpChannelType Select Distinct Channel_Type_Desc From tbl_merp_olclass
		Where Channel_Type_Desc In (Select * From dbo.sp_SplitIn2Rows(@ChannelType, @Delimeter))

Create Table #tmpOutletType (OutletType nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
If (@OutletType = N'%') OR  (@OutletType = N'All Type')
	Insert Into #tmpOutletType Select Distinct Outlet_Type_Desc From tbl_merp_olclass Union Select @TOBEDEFINED
Else
	Insert Into #tmpOutletType Select Distinct Outlet_Type_Desc From tbl_merp_olclass 
		Where Outlet_Type_Desc In (Select * From dbo.sp_SplitIn2Rows(@OutletType, @Delimeter))

Create Table #tmpLoyaltyProgram (LoyaltyProgram nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
If (@LoyaltyProgram = N'%') OR (@LoyaltyProgram = N'All Type')
	Insert Into #tmpLoyaltyProgram  Select Distinct SubOutlet_Type_Desc From tbl_merp_olclass Union Select @TOBEDEFINED
Else
	Insert Into #tmpLoyaltyProgram Select Distinct SubOutlet_Type_Desc From tbl_merp_olclass
		Where SubOutlet_Type_Desc In (Select * From dbo.sp_SplitIn2Rows(@LoyaltyProgram , @Delimeter))


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
From #OLClassMapping olcm right outer join Customer C on olcm.CustomerID = C.CustomerID
-----

if @Productivity =  'Non - Productive'
Begin

Create Table #tmpBilledCustomer(CategoryName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CatID Int,
ProdCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
ProdName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CustomerID nVarchar(500)COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert Into #tmpBilledCustomer
Select
tmp.CatName,--Category name for the selected Hierarchy(for div AG)
tmp.CatLevel,--category id for the selected hierarchy
ID.Product_Code,IT.ProductName	,
IA.CustomerID
From
#tmpCategories tmp, InvoiceAbstract IA, InvoiceDetail ID, 
Customer CS, Items IT,Customer_Channel CH, #OLClassCustLink olcl
Where
IA.InvoiceDate Between @FromDate And @ToDate
And IA.Status & 128 = 0
And IA.InvoiceID = ID.InvoiceID
And CS.CustomerID = IA.CustomerID
And CS.Active = 1
And IA.CustomerID In (Select CustomerID From #tmpCustomer)
And IA.SalesmanID In (Select SalesmanID From #tmpDS)
And IA.BeatID In (Select BeatID From #tmpBeat)
And ID.Product_Code = IT.Product_Code
And IT.CategoryID = tmp.LeafLevelCat
And IT.Product_Code In(Select Product_Code From #tmpItems)
And CS.ChannelType = CH.ChannelType
And CH.ChannelType In (Select ChannelType From #tmpChannel)
And olcl.CustomerID = CS.CustomerID
And olcl.[Channel Type] In (Select ChannelType From #tmpChannelType)
And olcl.[Outlet Type] In (Select OutletType From #tmpOutletType)
And olcl.[Loyalty Program] In (Select LoyaltyProgram From #tmpLoyaltyProgram)
Group By
IA.CustomerID, tmp.CatName, tmp.CatLevel,
ID.Product_Code,IT.ProductName, olcl.[Channel Type] , olcl.[Outlet Type] , olcl.[Loyalty Program]

--Select  Distinct Customerid from #tmpBilledCustomer

If @CatLevel = 'System SKU'
Begin
Insert Into #tmpAllCustomer(CustomerID ,RCSID , CustomerName ,Address, Channel,CatID,ProdCode,ProdName,CategoryHandler)
Select  CS.CustomerID,
CS.RCSOutletID,
CS.Company_Name,
CS.BillingAddress,
CH.ChannelDesc ,
I.CategoryID,
I.Product_Code,
I.ProductName,
"CategoryHandler"= 'No'
From
Customer CS,Customer_Channel CH,Items I
, #tmpCust tc, #OLClassCustLink olcl
Where
I.CategoryID In(Select LeafLevelCat From #tmpCategories)
And CustomerCategory = 2
And CS.Active = 1 
And CS.ChannelType = CH.ChannelType
And CH.ChannelType In (Select ChannelType From #tmpChannel)
and cs.customerid =tc.customerid
And olcl.CustomerID = CS.CustomerID
And olcl.[Channel Type] In (Select ChannelType From #tmpChannelType)
And olcl.[Outlet Type] In (Select OutletType From #tmpOutletType)
And olcl.[Loyalty Program] In (Select LoyaltyProgram From #tmpLoyaltyProgram)


End
Else
Begin
Insert Into #tmpAllCustomer(CustomerID ,RCSID , CustomerName ,Address, Channel,CatLevel, CatID, CategoryHandler)
Select  CS.CustomerID,
CS.RCSOutletID,
CS.Company_Name,
CS.BillingAddress,
CH.ChannelDesc,
tmp.CatName,--Category name for the selected Hierarchy(for div AG)
tmp.CatLevel,--category id for the selected hierarchy
"CategoryHandler" = 'NO'
From
#tmpCategories tmp,Customer CS,Customer_Channel CH, #tmpCust tc, #OLClassCustLink olcl
Where
--CS.CustomerID Not In(Select CustomerID From #tmpBilledCustomer) And
CustomerCategory = 2
And CS.Active = 1 
And CS.ChannelType = CH.ChannelType
And CH.ChannelType In (Select ChannelType From #tmpChannel)
and cs.customerid =tc.customerid
And olcl.CustomerID = CS.CustomerID
And olcl.[Channel Type] In (Select ChannelType From #tmpChannelType)
And olcl.[Outlet Type] In (Select OutletType From #tmpOutletType)
And olcl.[Loyalty Program] In (Select LoyaltyProgram From #tmpLoyaltyProgram)

End
/* To Insert Only the Non Productinve Customer For each Category Wise */
Declare @CatgryID Int
Declare  Cur_Category  Cursor For
Select Distinct CatID From #tmpAllCustomer 
Open Cur_Category
Fetch From Cur_Category Into @CatgryID
While @@Fetch_Status = 0
Begin
	If @CatLevel = 'System SKU'
		Insert Into #tmpCustProductivity(CustomerID ,RCSID , CustomerName ,Address, Channel, 
		[Channel Type], [Outlet Type], [Loyalty Program], CatID,ProdCode,ProdName,CategoryHandler)
		Select Distinct #tmpAllCustomer.CustomerID ,RCSID , CustomerName ,Address, Channel, 
		IsNull(olcl.[Channel Type], @TOBEDEFINED) , 
		IsNull(olcl.[Outlet Type], @TOBEDEFINED), 
		IsNull(olcl.[Loyalty Program], @TOBEDEFINED),
		CatID,ProdCode,ProdName,CategoryHandler 
		From #tmpAllCustomer, #OLClassCustLink olcl 
		Where olcl.CustomerID = #tmpAllCustomer.CustomerID 
		And #tmpAllCustomer.CustomerID Not In(Select CustomerID From #tmpBilledCustomer Where CatID = @CatgryID)
		And CatID = @CatgryID 
		And olcl.[Channel Type] In (Select ChannelType From #tmpChannelType)
		And olcl.[Outlet Type] In (Select OutletType From #tmpOutletType)
		And olcl.[Loyalty Program] In (Select LoyaltyProgram From #tmpLoyaltyProgram)
	ELSE
		Insert Into #tmpCustProductivity(CustomerID ,RCSID , CustomerName ,Address, Channel, 
		[Channel Type], [Outlet Type], [Loyalty Program], CatLevel, CatID, CategoryHandler)
		Select Distinct #tmpAllCustomer.CustomerID ,RCSID , CustomerName ,Address, Channel,
		IsNull(olcl.[Channel Type], @TOBEDEFINED) , 
		IsNull(olcl.[Outlet Type], @TOBEDEFINED), 
		IsNull(olcl.[Loyalty Program], @TOBEDEFINED),
		CatLevel, CatID, CategoryHandler 
		From #tmpAllCustomer, #OLClassCustLink olcl 
		Where olcl.CustomerID = #tmpAllCustomer.CustomerID 
		And #tmpAllCustomer.CustomerID Not In(Select CustomerID From #tmpBilledCustomer Where CatID = @CatgryID)
		And CatID = @CatgryID
		And olcl.[Channel Type] In (Select ChannelType From #tmpChannelType)
		And olcl.[Outlet Type] In (Select OutletType From #tmpOutletType)
		And olcl.[Loyalty Program] In (Select LoyaltyProgram From #tmpLoyaltyProgram)
	
	Fetch Next From Cur_Category Into @CatgryID
End
Close Cur_Category
Deallocate  Cur_Category


Update #tmpCustProductivity  Set CategoryHandler = 
	(Case @CatLevel When 'System SKU' Then 
		( Select TOP 1 'Yes' From CustomerProductCategory Where CustomerID = #tmpCustProductivity.CustomerID And CategoryID = 
		(Select ParentID From ItemCategories Where CategoryID = #tmpCustProductivity.CatID))
	
	 When 'Market_SKU' Then 
		( Select TOP 1 'Yes' From CustomerProductCategory Where CustomerID = #tmpCustProductivity.CustomerID And CategoryID = 
		(Select ParentID From ItemCategories Where categoryID = #tmpCustProductivity.CatID))
	ELSE
		  (Select TOP 1 'Yes' From CustomerProductCategory Where CustomerID = #tmpCustProductivity.CustomerID 
		  And CategoryID = #tmpCustProductivity.CatID)
	END)

if @CatLevel = (Select HierarchyName From ItemHierarchy Where HierarchyID = 1)
Begin
	Update #tmpCustProductivity Set [totactivecust] =
	(Select Count(Distinct(CustomerID))From #tmpCust)
	Update #tmpCustProductivity  Set [NoOfMappedCust] =
	(Select Count(Distinct(CustomerID))From #tmpCust)- (Select Count(Distinct CustomerID) From #tmpBilledCustomer T Where  CatID = #tmpCustProductivity.CatID )
end
Else if @CatLevel = (Select HierarchyName From ItemHierarchy Where HierarchyID = 3)
Begin
	Update #tmpCustProductivity Set [totactivecust] =
	(Select Count(Distinct(CustomerID))From #tmpCust)
if(@CategoryHandler1)= 'Yes'
Begin
	Update #tmpCustProductivity  Set [NoOfMappedCust] =
	(Select Count(Distinct tc.CustomerID) From CustomerProductCategory cpc,#tmpcust tc Where cpc.customerid =tc.customerid and  Active = 1 And CategoryID In
	(Select CategoryID From ItemCategories Where CategoryiD = #tmpCustProductivity.CatID) )-
	(Select Count(Distinct CustomerID) From #tmpBilledCustomer T Where  CatID = #tmpCustProductivity.CatID and T.customerid in(select distinct customerid from CustomerProductCategory where Categoryid = #tmpCustProductivity.CatID))
End
else if @CategoryHandler1 = 'No'
Begin
	Update #tmpCustProductivity  Set [NoOfMappedCust] =
	(Select Count(Distinct CustomerID) From  #tmpcust Where customerid  not in (select Distinct customerid from customerproductcategory where Active = 1 And CategoryID In
	(Select CategoryID From ItemCategories Where CategoryID = #tmpCustProductivity.CatID)))-
	(Select Count(Distinct CustomerID) From #tmpBilledCustomer T Where  CatID = #tmpCustProductivity.CatID and T.customerid not in(select distinct customerid from CustomerProductCategory where Categoryid = #tmpCustProductivity.CatID))
End
else
Begin 
	Update #tmpCustProductivity  Set [NoOfMappedCust] =
	(Select Count(Distinct(CustomerID))From #tmpCust) - (Select Count(Distinct CustomerID) From #tmpBilledCustomer T Where  CatID = #tmpCustProductivity.CatID )
End
End
Else If @CatLevel = (Select HierarchyName From ItemHierarchy Where HierarchyID = 2)
Begin
	Update #tmpCustProductivity Set [totactivecust] =
	(Select Count(Distinct(CustomerID))From #tmpCust)
	if(@CategoryHandler1)= 'Yes'
Begin
	Update #tmpCustProductivity  Set [NoOfMappedCust] =
	(Select Count(Distinct tc.CustomerID) From CustomerProductCategory cpc,#tmpcust tc Where cpc.customerid =tc.customerid and  Active = 1 And CategoryID In
	(Select CategoryID From ItemCategories Where categoryID = #tmpCustProductivity.CatID) )-
	(Select Count(Distinct CustomerID) From #tmpBilledCustomer T Where  CatID = #tmpCustProductivity.CatID and T.customerid in(select distinct customerid from CustomerProductCategory where Categoryid = #tmpCustProductivity.CatID))

End
else if @CategoryHandler1 = 'No'
Begin
	Update #tmpCustProductivity  Set [NoOfMappedCust] =
	(Select Count(Distinct CustomerID) From #tmpcust Where customerid  not in (select Distinct customerid from customerproductcategory where Active = 1 And CategoryID In
	(Select CategoryID From ItemCategories Where categoryID = #tmpCustProductivity.CatID)))-
	(Select Count(Distinct CustomerID) From #tmpBilledCustomer T Where  CatID = #tmpCustProductivity.CatID and T.customerid not in(select distinct customerid from CustomerProductCategory where Categoryid = #tmpCustProductivity.CatID))
End
else
Begin 
	Update #tmpCustProductivity  Set [NoOfMappedCust] =
	(Select Count(Distinct(CustomerID))From #tmpCust) - (Select Count(Distinct CustomerID) From #tmpBilledCustomer T Where  CatID = #tmpCustProductivity.CatID )
End
End
Else If @CatLevel = (Select HierarchyName From ItemHierarchy Where HierarchyID = 4)
Begin
	Update #tmpCustProductivity Set [totactivecust] =
	(Select Count(Distinct(CustomerID))From #tmpCust)
if(@CategoryHandler1)= 'Yes'
Begin
	Update #tmpCustProductivity  Set [NoOfMappedCust] =
	(Select Count(Distinct tc.CustomerID) From CustomerProductCategory cpc,#tmpcust tc Where cpc.customerid =tc.customerid and  Active = 1 And CategoryID In
	(Select ParentID From ItemCategories Where CategoryiD = #tmpCustProductivity.CatID) )-
	(Select Count(Distinct CustomerID) From #tmpBilledCustomer T Where  CatID = #tmpCustProductivity.CatID and T.customerid in(select distinct customerid from CustomerProductCategory where CategoryID In
	(Select ParentID From ItemCategories Where CategoryiD = #tmpCustProductivity.CatID)))
End
else if @CategoryHandler1 = 'No'
Begin
	Update #tmpCustProductivity  Set [NoOfMappedCust] =
	(Select Count(Distinct CustomerID) From  #tmpcust Where customerid  not in (select Distinct customerid from customerproductcategory where Active = 1 And CategoryID In
	(Select ParentID From ItemCategories Where CategoryID = #tmpCustProductivity.CatID)))-
	(Select Count(Distinct CustomerID) From #tmpBilledCustomer T Where  CatID = #tmpCustProductivity.CatID and T.customerid NOT in(select distinct customerid from CustomerProductCategory where CategoryID In
	(Select ParentID From ItemCategories Where CategoryiD = #tmpCustProductivity.CatID)))
End
else
Begin 
	Update #tmpCustProductivity  Set [NoOfMappedCust] =
	(Select Count(Distinct(CustomerID))From #tmpCust) - (Select Count(Distinct CustomerID) From #tmpBilledCustomer T Where  CatID = #tmpCustProductivity.CatID )
End
End
Else If @CatLevel = 'System SKU'
Begin
	Update #tmpCustProductivity Set [totactivecust] =
	(Select Count(Distinct(CustomerID))From #tmpCust)
if(@CategoryHandler1)= 'Yes'
Begin
	Update #tmpCustProductivity  Set [NoOfMappedCust] =
	(Select Count(Distinct tc.CustomerID) From CustomerProductCategory cpc,#tmpcust tc Where cpc.customerid =tc.customerid and  Active = 1 And CategoryID In
	(Select ParentID From ItemCategories Where CategoryiD = #tmpCustProductivity.CatID) )-
	(Select Count(Distinct CustomerID) From #tmpBilledCustomer T Where  CatID = #tmpCustProductivity.CatID and T.customerid in(select distinct customerid from CustomerProductCategory where CategoryID In
	(Select ParentID From ItemCategories Where CategoryiD = #tmpCustProductivity.CatID)))
End
else if @CategoryHandler1 = 'No'
Begin
	Update #tmpCustProductivity  Set [NoOfMappedCust] =
	(Select Count(Distinct CustomerID) From  #tmpcust Where customerid  not in (select Distinct customerid from customerproductcategory where Active = 1 And CategoryID In
	(Select ParentID From ItemCategories Where CategoryID = #tmpCustProductivity.CatID)))-
	(Select Count(Distinct CustomerID) From #tmpBilledCustomer T Where  CatID = #tmpCustProductivity.CatID and T.customerid not in(select distinct customerid from CustomerProductCategory where CategoryID In
	(Select ParentID From ItemCategories Where CategoryiD = #tmpCustProductivity.CatID)))
End
else
Begin 
	Update #tmpCustProductivity  Set [NoOfMappedCust] =
	(Select Count(Distinct(CustomerID))From #tmpCust) - (Select Count(Distinct CustomerID) From #tmpBilledCustomer T Where  CatID = #tmpCustProductivity.CatID )
End
End

Update #tmpCustProductivity  Set [NoOfMappedCust] = (Case  When [NoOfMappedCust] < 0 Then 0 Else [NoOfMappedCust] End)

Create Table #tmpCustBeatSman(CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,BeatID Int,BeatName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,BeatOrder Int,SalesmanName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #tmpIdentity(CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,BeatID Int,BeatName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,BeatOrder Int Identity(1,1),SalesmanName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Declare @CustomerID nVarchar(255)
Declare CurBeatOrder Cursor For
Select Distinct T.CustomerID ,C.DefaultBeatID From #tmpCustProductivity T,Customer C
Where T.CustomerID = C.CustomerID
Open CurBeatOrder
Fetch From CurBeatOrder Into @CustomerID,@DefaultBeatID
While @@Fetch_Status = 0
Begin
--First Insert the default Beat And the Salesman for the default Beat  for the Customer
Insert Into #tmpIdentity
Select @CustomerID,B.BeatID,B.Description,
isNull((Select Salesman_Name From Salesman Where SalesmanID = BS.SalesmanID),'')
From Beat B,Beat_Salesman BS Where BS.BeatID = @DefaultBeatID  And CustomerID = @CustomerID
And B.BeatID = BS.BeatID

--Next Insert the  Beat And the mapped Salesman for the  Beat  for the Customer
--Other than the Default Beat
Insert Into #tmpIdentity Select Distinct CustomerID ,B.BeatID,B.Description,
isNull((Select Salesman_Name From Salesman Where SalesmanID = BS.SalesmanID),'') From
Beat_Salesman BS,Beat B--,Salesman S
Where CustomerID = @CustomerID And isNull(BS.BeatID,0) <> 0
And BS.BeatID = B.BeatID
And BS.BeatID <> @DefaultBeatID
And BS.BeatID In(Select BeatID From #tmpBeat)
And BS.SalesmanID In(Select SalesmanID From #tmpDS)
Order By B.BeatID
Insert Into #tmpCustBeatSman Select * From #tmpIdentity


Truncate Table #tmpIdentity
Fetch Next From CurBeatOrder Into @CustomerID,@DefaultBeatID
End
Close CurBeatOrder
Deallocate CurBeatOrder

Create Table #tmpBeatCount(CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,BeatCnt Int)
Insert Into #tmpBeatCount
Select isnull(CustomerID,0) ,isnull(Count(Distinct BeatName),0) from #tmpCustBeatSman
Group By CustomerID
--To add the salesman and beat column dynamically
Set @BEAT1 = 'Beat'
Set @SALESMAN1 = 'Salesman'
Set @i = 0
Set @j = 1
Select @BeatCnt =  isnull(Max(BeatCnt),0) From #tmpBeatCount
Set @BeatColumn = ''
Set @SalesColumn = ''
While (@i <= @BeatCnt )
Begin
if @i = 0
Begin
Set @BeatCol = @BEAT1
Set @SManCol = @SALESMAN1
End
Else
Begin
Set @BeatCol = @BEAT1 + Cast(@i as nVarchar)
Set @SManCol = @SALESMAN1 + Cast(@i as nVarchar)
End


Set @SQL = 'Alter Table #tmpCustProductivity Add ' + @BeatCol   + ' ' + 'nVarchar(500)'
Exec sp_ExecuteSql @SQL

Set @SQL = 'Alter Table #tmpCustProductivity Add '  + @SManCol  +  ' ' + 'nVarchar(500)'
Exec sp_ExecuteSql @SQL

Set @SQL = 'Update #tmpCustProductivity Set ' + @BeatCol   + ' = BeatName ,'  + @SManCol +
' = SalesmanName From #tmpCustBeatSman T Where T.CustomerID = #tmpCustProductivity.CustomerID
And BeatOrder = ' + Cast(@j as nVarchar)
Exec sp_ExecuteSql @SQL

Set @BeatColumn = @BeatColumn + ',[' + @BeatCol + '],' + '[' + @SManCol + ']'
Set @i = @i + 1
Set @j = @j + 1

End

Declare @TotCust Int
Select @TotCust = Count(Distinct CustomerID) From Customer 

End
Else
Begin
--Productive

Declare @LeafID As Int
Declare @ParentCatID As Int
Declare @Level As Int

Create Table #tmpCatIDCG(LeafID Int,CatName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,CGName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS)
Insert Into #tmpCatIDCG(LeafID,CatName)
Select Distinct LeafLevelCat, CatName
From #tmpCategories

-- Category Group Handling based on the CategoryGroup definition 

Declare @TempCGCatMapping Table (GroupID Int, GroupName nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryID Int, CategoryName nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert InTo @TempCGCatMapping
Select "GroupID" = pcga.GroupID, "GroupName" = cgdm.CategoryGroup, 
"CategoryID" = icat.CategoryID, "CategoryName" = cgdm.Division
From tblcgdivmapping cgdm, ProductCategoryGroupAbstract pcga, ItemCategories icat
Where cgdm.CategoryGroup = pcga.GroupName And cgdm.Division = icat.Category_Name

--To Get The GroupName For The Categories
If Exists(Select * From SysObjects Where Name like 'tblCGDivMapping' And Xtype = 'u')
Begin

Declare CurCGName Cursor For
Select Distinct LeafID From #tmpCatIDCG
Open CurCGName
Fetch From CurCGName Into @LeafID
While @@Fetch_Status = 0
Begin
Set @ParentCatID = @LeafID
Set @Level = 0
While @Level <> 3
Begin
Select @Level = Level,@ParentCatID = ParentID From ItemCategories Where CategoryID = @ParentCatID
If @ParentCatID = 0
	Goto Skip
End
Update #tmpCatIDCG Set CGName =
(Select GroupName  From ProductCategoryGroupAbstract Where GroupID =
(Select top 1 GroupID From @TempCGCatMapping As ProductCategoryGroupDetail Where ProductCategoryGroupDetail.CategoryID = @ParentCatID))
Where LeafID = @LeafID
Skip:
Fetch Next From CurCGName Into @LeafID
End
Close CurCGName
Deallocate CurCGName
End

Set @SQL = 	'Alter Table #tmpCustProductivity  Add 	NetSales Decimal(18,6),
Quantity Decimal(18,6), BillCount Int,AvgBillVal Decimal(18,6), LinesCut Int,AvgLinesCut Int,
CGName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,SalesManName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS'
Exec sp_ExecuteSql @SQL

Insert Into #tmpCustProductivity
(CustomerID ,RCSID , CustomerName , CategoryHandler, Address , Channel,
[Channel Type] , [Outlet Type] , [Loyalty Program] ,
CatLevel, CatID ,ProdCode,ProdName, NetSales ,Quantity , BillCount ,AvgBillVal , LinesCut ,AvgLinesCut ,
CGName ,SalesManName )
Select  IA.CustomerID,
CS.RCSOutletID,
CS.Company_Name,
"CategoryHandler" = 
	Case @CatLevel When 'Division' Then 
	(
		Select TOP 1 'Yes' From CustomerProductCategory Where CustomerID = IA.CustomerID And CategoryID IN 
		(
			Select CategoryID From ItemCategories Where ParentID In 
			(
				Select ParentID From ItemCategories Where CategoryID In 
				(
					Select ParentID From ItemCategories Where CategoryID In 
					(
						Select CategoryID From Items Where Items.Product_Code = ID.Product_Code
					)
				)
			)
		)
	) 
	Else
	(
		Select TOP 1 'Yes' From CustomerProductCategory Where CustomerID = IA.CustomerID 
		And CategoryID IN (Select ParentID From Items 
		INNER JOIN ItemCategories ON ItemCategories.CategoryID = Items.CategoryID
		Where Product_Code = ID.Product_Code)
	) 
	End,
CS.BillingAddress,
CH.ChannelDesc,
IsNull(olcl.[Channel Type], @TOBEDEFINED) , 
IsNull(olcl.[Outlet Type], @TOBEDEFINED), 
IsNull(olcl.[Loyalty Program], @TOBEDEFINED),
tmp.CatName,--Category name for the selected Hierarchy(for div AG)
tmp.CatLevel,--category id for the selected hierarchy
ID.Product_Code,IT.ProductName,
Sum(Case IA.InvoiceType
When 4 Then	0 - (ID.Amount)
Else ID.Amount
End) as NetSales,
Sum(Case @UOM
When N'Base UOM' Then
(Case IA.InvoiceType
When 4 Then 0 - ISNULL(ID.Quantity, 0)
Else ISNULL(ID.Quantity, 0)
End)
When N'UOM 1' Then
Case IA.InvoiceType
When 4 Then 0 - (IsNull(ID.Quantity,0) /
(Case IsNull(IT.UOM1_Conversion, 0)
When 0 Then 1
Else IsNull(IT.UOM1_Conversion,1)
End))
Else IsNull(ID.Quantity,0) /
(Case IsNull(IT.UOM1_Conversion, 0)
When 0 Then 1
Else IsNull(IT.UOM1_Conversion,1)
End)
End

When N'UOM 2' Then
Case IA.InvoiceType
When 4 Then 0 - (IsNull(ID.Quantity,0)/
(Case IsNull(IT.UOM2_Conversion, 0)
When 0 Then 1
Else IsNull(IT.UOM2_Conversion,1)
End))
Else IsNull(ID.Quantity,0) /
(Case IsNull(IT.UOM2_Conversion, 0)
When 0 Then 1
Else IsNull(IT.UOM2_Conversion,1)
End)
End
End) as Quantity,
(Select '') as BillCount,0,
(Select '') as LinesCut,0,CG.CGName,

(Select Salesman_Name From Salesman Where SalesmanID = (Select Top 1 SalesmanID From Beat_Salesman Where BeatID =
DefaultBeatID))

From #tmpCategories tmp, InvoiceAbstract IA, InvoiceDetail ID, Customer CS, 
Items IT, Customer_Channel CH, #tmpCatIDCG CG, #OLClassCustLink olcl
Where IA.InvoiceDate Between @FromDate And @ToDate
And (isNull(IA.Status,0) & 128 = 0 )
And IA.InvoiceID = ID.InvoiceID
And CS.CustomerID = IA.CustomerID
And IA.CustomerID In (Select CustomerID From #tmpCustomer)
And IA.SalesmanID In (Select SalesmanID From #tmpDS)
And IA.BeatID In (Select BeatID From #tmpBeat)
And ID.Product_Code = IT.Product_Code
And IT.Product_Code In(Select Product_Code From #tmpItems)
And IT.CategoryID = tmp.LeafLevelCat
And CS.ChannelType = CH.ChannelType
And CH.ChannelType In (Select ChannelType From #tmpChannel)
And IT.CategoryID = CG.LeafID
And olcl.CustomerID = CS.CustomerID
And olcl.[Channel Type] In (Select ChannelType From #tmpChannelType)
And olcl.[Outlet Type] In (Select OutletType From #tmpOutletType)
And olcl.[Loyalty Program] In (Select LoyaltyProgram From #tmpLoyaltyProgram)
Group By IA.CustomerID, CS.RCSOutletID, CS.Company_Name, CS.BillingAddress, CH.ChannelDesc, 
tmp.CatName, tmp.CatLevel,CG.CGName,DefaultBeatID,
ID.Product_Code,IT.ProductName, olcl.[Channel Type] , olcl.[Outlet Type] , olcl.[Loyalty Program]

Create Table #tmpCGWiseBill(CustomerID NvARCHAR(500) COLLATE SQL_Latin1_General_CP1_CI_AS,InvoiceID Int,
CatName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CGName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,ProdCode nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS)
Insert Into #tmpCGWiseBill(CustomerID ,InvoiceID ,CatName,CGName ,ProdCode)
Select
IA.CustomerID, IA.InvoiceID,CG.CatName,CG.CGName,ID.Product_Code
From
#tmpCategories tmp, InvoiceAbstract IA, InvoiceDetail ID, Customer CS,
Items IT, Customer_Channel CH ,#tmpCatIDCG CG, #OLClassCustLink olcl
Where
IA.InvoiceID = ID.InvoiceID
And CS.CustomerID = IA.CustomerID
And IA.CustomerID In (Select CustomerID From #tmpCustomer)
And IA.SalesmanID In (Select SalesmanID From #tmpDS)
And IA.BeatID In (Select BeatID From #tmpBeat)
And ID.Product_Code = IT.Product_Code
And IT.Product_Code In(Select Product_Code From #tmpItems)
And IT.CategoryID = tmp.LeafLevelCat
And  IT.CategoryID =  CG.LeafID
And IA.InvoiceDate Between @FromDate And @ToDate
And CS.ChannelType = CH.ChannelType
And CH.ChannelType In (Select ChannelType From #tmpChannel)
And (isNull(IA.Status,0) & 128 = 0 )
And IA.InvoiceType In(1,3)
And olcl.CustomerID = CS.CustomerID
And olcl.[Channel Type] In (Select ChannelType From #tmpChannelType)
And olcl.[Outlet Type] In (Select OutletType From #tmpOutletType)
And olcl.[Loyalty Program] In (Select LoyaltyProgram From #tmpLoyaltyProgram)

IF @CatLevel = 'System SKU'
Update #tmpCustProductivity Set BillCount =  (Select Count(Distinct InvoiceID) From #tmpCGWiseBill
Where CustomerID = #tmpCustProductivity.CustomerID And isNull(ProdCode,'') = isNull(#tmpCustProductivity.ProdCode,'') And
CGName = #tmpCustProductivity.CGName)
Else
Update #tmpCustProductivity Set BillCount =  (Select Count(Distinct InvoiceID) From #tmpCGWiseBill
Where CustomerID = #tmpCustProductivity.CustomerID And isNull(CatName,'') = isNull(#tmpCustProductivity.CatLevel,'') And
CGName = #tmpCustProductivity.CGName)


Create Table #tmpCGWiseLineCnt(CustomerID nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
CatName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,CGName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,InvoiceID Int,LineCount Int)

Insert Into #tmpCGWiseLineCnt(CustomerID ,CatName,CGName ,InvoiceID ,LineCount )
Select
CustomerID ,CatName,CGName ,InvoiceID ,Count(Distinct ProdCode)
From
#tmpCGWiseBill
Group By
CustomerID ,CatName,InvoiceID ,CGName


Create Table #tmpProdCount(CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CGName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,ProdCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,ProdCount Int)
Insert Into #tmpProdCount(CustomerID ,CGName ,ProdCode)
Select Distinct CustomerID,CGName,ProdCode
From #tmpCGWiseBill


Update #tmpProdCount Set ProdCount = (Select Count(Distinct InvoiceID) From #tmpCGWiseBill
Where ProdCode =  #tmpProdCount.ProdCode And CustomerID = #tmpProdCount.CustomerID And
CGName = #tmpProdCount.CGName)


IF @CatLevel = 'System SKU'
Update #tmpCustProductivity Set LinesCut =  (Select Sum(ProdCount) From #tmpProdCount
Where CustomerID = #tmpCustProductivity.CustomerID And isNull(ProdCode,'') = isNull(#tmpCustProductivity.ProdCode,'') And
CGName = #tmpCustProductivity.CGName)

Else
Update #tmpCustProductivity Set LinesCut =  (Select Sum(LineCount) From #tmpCGWiseLineCnt
Where CustomerID = #tmpCustProductivity.CustomerID And isNull(CatName,'') = isNull(#tmpCustProductivity.CatLevel,'') And
CGName = #tmpCustProductivity.CGName)



IF (@CatLevel = 'System SKU' And @Sales = 'Volume' )
Begin
Set @SQL = 'Alter Table #tmpCustProductivity Add UOM nVarchar(255)'
Exec sp_ExecuteSql @SQL

Update #tmpCustProductivity Set UOM =
(Case @UOM When 'Base Uom' Then (Select Description From Uom Where UOM = (Select uom From Items Where Product_Code = #tmpCustProductivity.ProdCode))
When 'UOM 1' Then (Select Description From Uom Where UOM = (Select uom1 From Items Where Product_Code = #tmpCustProductivity.ProdCode))
When 'UOM 2' Then (Select Description From Uom Where UOM = (Select uom2 From Items Where Product_Code = #tmpCustProductivity.ProdCode))
End)
End

/*
If (@CatLevel = 'System SKU')
Update #tmpCustProductivity Set [NoOfMappedCust]  = (Select Count(Distinct CustomerID) From #tmpCustProductivity T
Where T.ProdCode = #tmpCustProductivity.ProdCode)
Else
Update #tmpCustProductivity Set [NoOfMappedCust]  = (Select Count(Distinct CustomerID) From #tmpCustProductivity T
Where T.CatID = #tmpCustProductivity.CatID)
*/

End


--Dynamic Updation of Merchandising column
Declare @MerchandiseID As Int
Declare @Merchandise as nVarchar(500)
Declare @MerchandiseCol as nVarchar(2000)
Declare @YES as Nvarchar(10)
Declare @NO as Nvarchar(10)
Set  @YES = 'Yes'
Set @NO ='No'
Set @MerchandiseCol = ''
Declare CurMerChandise Cursor For
Select MerchandiseID,Merchandise From Merchandise Where MerchandiseID In
(Select MerchandiseID From #tmpMerchandise)
Open CurMerChandise
Fetch From CurMerChandise Into @MerchandiseID,@Merchandise
While @@Fetch_Status = 0
Begin

Set @SQL = 'Alter Table #tmpCustProductivity Add[' + @Merchandise + ' ' + '] nVarchar(10)'
Exec sp_ExecuteSql @SQL

Set @SQL = 'Update #tmpCustProductivity Set[' + @Merchandise +
'] = isNull((Select Case MerchandiseID When ' + Cast(@MerchandiseID as nVarchar) + ' Then ' + '''' + @YES + '''' + '
Else' + '''' + @NO + '''' + ' End From CustMerchandise
Where CustomerID = #tmpCustProductivity.CustomerID And MerchandiseID = ' + Cast(@MerchandiseID as nVarchar)
+' ),' + '''' + @No+ ''''  + ')'
Exec sp_ExecuteSql @SQL

Set @MerchandiseCol  = @MerchandiseCol + ',[' + @Merchandise + ']'

Fetch Next From CurMerChandise Into @MerchandiseID,@Merchandise
End
Close CurMerChandise
Deallocate CurMerChandise

IF (@Productivity = 'Productive')
Begin
If ( @CatLevel = 'System SKU' or @CatLevel = 'Market_SKU' Or @CatLevel = 'Sub_Category' Or @CatLevel = 'Division' Or @CatLevel = 'Company')
Begin
Set @SQL = 'Alter Table #tmpCustProductivity Add TotActCust int'
Exec sp_ExecuteSql @SQL
Set @SQL = 	'Update #tmpCustProductivity Set [TotActCust] =
(Select Count(Distinct CustomerID) From #tmpCust)'
Exec sp_ExecuteSql @SQL
End
End

IF (@Productivity = 'Productive')
Begin
If @CatLevel = 'System SKU'
Begin
Set @SQL = 'Alter Table #tmpCustProductivity Add Company nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Division nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Sub_Category nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Market_SKU nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS'
Exec sp_ExecuteSql @SQL
End
Else if @CatLevel = 'Market_SKU'
Begin
Set @SQL = 'Alter Table #tmpCustProductivity Add Company nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Division nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Sub_Category nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS'
Exec sp_ExecuteSql @SQL
End
Else if @CatLevel = 'Sub_Category'
Begin
Set @SQL = 'Alter Table #tmpCustProductivity Add Company nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Division nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS'
Exec sp_ExecuteSql @SQL
End
End

Declare ProdCur Cursor For
Select Distinct ProdCode from #tmpCustProductivity
Open ProdCur
Fetch From ProdCur Into @ProdCode
While @@Fetch_Status = 0
Begin

Insert Into #tmpProdDetails (ProdCode, CompanyId, DivisionID, SubCategoryID, MSKUID, Company, Division, SubCategory, MSKU)
Select @ProdCode, A.CategoryID As CompanyID, B.CategoryID As DivisionID, C.CategoryID as SubCategoryID, D.CategoryID as MSKUID,
A.Category_Name As Company, B.Category_Name As Division, C.Category_Name As SubCategory, D.Category_name  As MarketSku
from ItemCategories A, ItemCategories B,ItemCategories C, ItemCategories D
where A.CategoryID = B.ParentID and
B.CategoryID = C.parentID
and C.CategoryID = D.ParentID
and D.CategoryID in
(Select CategoryID from Items Where Product_code = @ProdCode)
Fetch Next From ProdCur Into @ProdCode
End
Close ProdCur
Deallocate ProdCur

--Update Category Handler--
Update #tmpCustProductivity SET CategoryHandler = 'No' Where CategoryHandler is null
if @CatLevel = 'Company'
BEGIN
Update #tmpCustProductivity SET CategoryHandler = ''
END
/* to update NoOfMappedCust wrt Category Handler*/
if(@CategoryHandler1)= 'Yes'
Update #tmpCustProductivity Set [NoOfMappedCust]  = (Select Count(Distinct CustomerID) From #tmpCustProductivity T
Where T.CatID = #tmpCustProductivity.CatID and CategoryHandler = 'Yes')
else if(@CategoryHandler1)= 'No'
Update #tmpCustProductivity Set [NoOfMappedCust]  = (Select Count(Distinct CustomerID) From #tmpCustProductivity T
Where T.CatID = #tmpCustProductivity.CatID and CategoryHandler = 'No')
else
Update #tmpCustProductivity Set [NoOfMappedCust]  = (Select Count(Distinct CustomerID) From #tmpCustProductivity T
Where T.CatID = #tmpCustProductivity.CatID)


--Select * from #tmpCustProductivity

---Select Distinct isNull(CategoryHandler,'') From #tmpCustProductivity

IF @Productivity = 'Non - Productive'
Begin
If @CatLevel = 'System SKU'
Set @SQL = 'Select ProdCode,ProdCode As [Item Code],ProdName As [Item Name],[totactivecust] As [Total Active Customers],[NoOfMappedCust] As [No.Of Customers],CustomerID As [Customer Code],
RCSID As [RCS ID],CustomerName aS [Customer Name], CategoryHandler As [Category Handler], Address as [Billing Address],Channel As [Customer Type], [Channel Type], [Outlet Type], [Loyalty Program]'
Else
Set @SQL = 'Select CatLevel,CatLevel As [Category],[totactivecust] As [Total Active Customers],[NoOfMappedCust] As [No.Of Customers],CustomerID As [Customer Code],
RCSID As [RCS ID],CustomerName as [Customer Name], CategoryHandler As [Category Handler], Address as [Billing Address],Channel As [Customer Type], [Channel Type], [Outlet Type], [Loyalty Program]'


Set @SQL = @SQL + @BeatColumn   + @MerchandiseCol

If @CatLevel = 'System SKU'
Set @SQL = @SQL + 'From #tmpCustProductivity T1,#tempCategory1 T Where T.CategoryID = T1.CatID And CategoryHandler IN (' + @CategoryHandler + ')  Group By ProdCode,ProdName,[totactiveCust],[NoOfMappedCust],CustomerID,RCSID,CategoryHandler,
CustomerName,Address,Channel, [Channel Type], [Outlet Type], [Loyalty Program]'
Else
Set @SQL = @SQL + 'From #tmpCustProductivity T1,#tempCategory1 T Where T.CategoryID = T1.CatID And CategoryHandler IN (' + @CategoryHandler + ')  Group By CatLevel,[totactiveCust],[NoOfMappedCust],CustomerID,RCSID,CategoryHandler,
CustomerName,Address,Channel, [Channel Type], [Outlet Type], [Loyalty Program]'

Set @SQL = @SQL + @BeatColumn  + @MerchandiseCol

Set @SQL = @SQL + ',T.IDS Order By T.IDS'
Exec sp_ExecuteSql @Sql

End
Else
Begin
if @CatLevel = 'System SKU'
Begin
Set @SQL = 'Select T1.ProdCode, T1.ProdCode As [Item Code],ProdName As [Item Name], TotActCust As [Total Active Customer], [NoOfMappedCust] As [No.Of Customers],CustomerID As [Customer Code],
RCSID As [RCS ID],CustomerName aS [Customer Name], CategoryHandler As [Category Handler], Address as [Billing Address],Channel As [Customer Type], [Channel Type], [Outlet Type], [Loyalty Program],
Sum(isNull(NetSales,0)) AS [Net Total Sales(Rs)],Sum(isNull(NetSales,0))/(Case isNull(BillCount,0) When 0 Then 1 Else isNull(BillCount,0) End)   As [Avg Bill Value],
isNull(BillCount,0) As [Bills Cut],isNull(LinesCut,0)/(Case isNull(BillCount,0) When 0 Then 1 Else isNull(BillCount,0) End)  As [Avg Lines Cut],
isNull(LinesCut,0) As [Total Lines Cut], SalesManName As [Salesman]'

If @Sales = 'Volume'
Set @SQL = @SQL + ',UOM As [UOM],Sum(isNull(Quantity,0)) As [Net Total Sales Qty]'

Set @SQL = @SQL + @MerchandiseCol +  ',' + 'T2.Company As [Company]' + ',' + 'T2.Division As [Division]' + ',' + 'T2.SubCategory As [Sub_Category]' + ',' + 'T2.MSKU As [MarketSKU]'

--Set @SQL = @SQL + ' From #tmpCustProductivity T1,#tempCategory1 T Where T.CategoryID = T1.CatID Group By ProdCode,ProdName,NoOfMappedCust,CustomerID,RCSID,CustomerName,Address,Channel,SalesManName,BillCount,LinesCut'
Set @SQL = @SQL + ' From #tmpCustProductivity T1,#tempCategory1 T, #tmpProdDetails T2 Where T.CategoryID = T1.CatID 
and t1.CatID = T2.MSKUID And t1.Prodcode = t2.Prodcode And CategoryHandler IN (' + @CategoryHandler + ') Group By T1.ProdCode,ProdName,
NoOfMappedCust,CustomerID,RCSID,CustomerName,Address,Channel,SalesManName,BillCount,LinesCut, T2.Company, 
T2.Division, T2.SubCategory, T2.MSKU, TotActCust, CategoryHandler, [Channel Type], [Outlet Type], [Loyalty Program]'

If @Sales = 'Volume'
Set @SQL = @SQL + ',UOM'

Set @SQL = @SQL +  @MerchandiseCol
Set @SQL = @SQL + ',T.IDS Order By T.IDS'
Exec sp_ExecuteSql @Sql
End
Else if @CatLevel = 'Sub_Category'
Begin
Set @SQL = 'Select CatLevel, CatLevel As [Sub_Category], CGName as [Category Group], TotActCust As [Total Active Customer], [NoOfMappedCust] As [No.Of Customers],CustomerID As [Customer Code],
RCSID As [RCS ID],CustomerName aS [Customer Name], CategoryHandler As [Category Handler], Address as [Billing Address],Channel As [Customer Type], [Channel Type], [Outlet Type], [Loyalty Program],
Sum(isNull(NetSales,0)) AS [Net Total Sales(Rs)],
Sum(isNull(NetSales,0))/(Case isNull(BillCount,0) When 0 Then 1 Else isNull(BillCount,0) End)   As [Avg Bill Value],
isNull(BillCount,0) As [Bills Cut],isNull(LinesCut,0)/(Case isNull(BillCount,0) When 0 Then 1 Else isNull(BillCount,0) End)  As [Avg Lines Cut],
isNull(LinesCut,0) As [Total Lines Cut],SalesManName As [Salesman]'

If @Sales = 'Volume'
Set @SQL = @SQL + ',Sum(isNull(Quantity,0)) As [Net Total Sales Qty]'

Set @SQL = @SQL + @MerchandiseCol +  ',' + 'T2.Company As [Company]' +  ',' + 'T2.Division As [Division]'
Set @SQL = @SQL + ' From #tmpCustProductivity T1, #tempCategory1 T,  #tmpProdDetails T2 
Where T.CategoryID = T1.CatID and t1.CatID = T2.SubCategoryID And T1.ProdCode = T2.ProdCode 
And CategoryHandler IN (' + @CategoryHandler + ') Group By CatLevel,CGName,NoOfMappedCust,CustomerID,
RCSID,CustomerName,Address,Channel,SalesManName,BillCount,LinesCut, T2.Company, T2.Division, 
TotActCust, CategoryHandler, [Channel Type], [Outlet Type], [Loyalty Program]'
Set @SQL = @SQL +  @MerchandiseCol
Set @SQL = @SQL + ',T.IDS Order By T.IDS'
Exec sp_ExecuteSql @Sql
End
Else if @CatLevel = 'Market_SKU'
Begin
-- Category
Set @SQL = 'Select CatLevel, CatLevel As [Market SKU], CGName as [Category Group], TotActCust As [Total Active Customer], [NoOfMappedCust] As [No.Of Customers],CustomerID As [Customer Code],
RCSID As [RCS ID],CustomerName aS [Customer Name], CategoryHandler As [Category Handler], Address as [Billing Address],Channel As [Customer Type], [Channel Type], [Outlet Type], [Loyalty Program],
Sum(isNull(NetSales,0)) AS [Net Total Sales(Rs)],
Sum(isNull(NetSales,0))/(Case isNull(BillCount,0) When 0 Then 1 Else isNull(BillCount,0) End)   As [Avg Bill Value],
isNull(BillCount,0) As [Bills Cut],isNull(LinesCut,0)/(Case isNull(BillCount,0) When 0 Then 1 Else isNull(BillCount,0) End)  As [Avg Lines Cut],
isNull(LinesCut,0) As [Total Lines Cut],SalesManName As [Salesman]'

If @Sales = 'Volume'
Set @SQL = @SQL + ',Sum(isNull(Quantity,0)) As [Net Total Sales Qty]'

Set @SQL = @SQL + @MerchandiseCol +  ',' + 'T2.Company As [Company]' + ',' + 'T2.Division As [Division]' + ',' + 'T2.SubCategory As [Sub_Category]'
Set @SQL = @SQL + ' From #tmpCustProductivity T1, #tempCategory1 T,  #tmpProdDetails T2 
Where T.CategoryID = T1.CatID and t1.CatID = T2.MSKUID And t1.Prodcode = t2.Prodcode and CategoryHandler IN (' + @CategoryHandler + ') 
Group By CatLevel,CGName,totactivecust,NoOfMappedCust,CustomerID,RCSID,CustomerName,Address,Channel,
SalesManName,BillCount,LinesCut, T2.Company, T2.Division, T2.SubCategory, 
TotActCust, CategoryHandler, [Channel Type], [Outlet Type], [Loyalty Program]'
Set @SQL = @SQL +  @MerchandiseCol
Set @SQL = @SQL + ',T.IDS Order By T.IDS'
Exec sp_ExecuteSql @Sql
End
Else if @CatLevel = 'Division'
begin
-- Category
Set @SQL = 'Select CatLevel, CatLevel As [Division], CGName as [Category Group],TotActCust As [Total Active Customer], [NoOfMappedCust] As [No.Of Customers],CustomerID As [Customer Code],
RCSID As [RCS ID],CustomerName aS [Customer Name], CategoryHandler As [Category Handler], Address as [Billing Address],Channel As [Customer Type], [Channel Type], [Outlet Type], [Loyalty Program],
Sum(isNull(NetSales,0)) AS [Net Total Sales(Rs)],
Sum(isNull(NetSales,0))/(Case isNull(BillCount,0) When 0 Then 1 Else isNull(BillCount,0) End)   As [Avg Bill Value],
isNull(BillCount,0) As [Bills Cut],isNull(LinesCut,0)/(Case isNull(BillCount,0) When 0 Then 1 Else isNull(BillCount,0) End)  As [Avg Lines Cut],
isNull(LinesCut,0) As [Total Lines Cut],SalesManName As [Salesman]'

If @Sales = 'Volume'
Set @SQL = @SQL + ',Sum(isNull(Quantity,0)) As [Net Total Sales Qty]'

Set @SQL = @SQL + @MerchandiseCol +  ',' + 'T2.Company As [Company]'
Set @SQL = @SQL + ' From #tmpCustProductivity T1, #tempCategory1 T,  #tmpProdDetails T2 
Where T.CategoryID = T1.CatID and t1.CatID = T2.DivisionId And T1.ProdCode = T2.ProdCode And 
CategoryHandler IN (' + @CategoryHandler + ') Group By CatLevel,CGName,NoOfMappedCust,CustomerID,RCSID,CustomerName,
Address,Channel,SalesManName,BillCount,LinesCut, T2.Company, T2.Division, 
TotActCust, CategoryHandler, [Channel Type], [Outlet Type], [Loyalty Program]'
Set @SQL = @SQL +  @MerchandiseCol
Set @SQL = @SQL + ',T.IDS Order By T.IDS'
Exec sp_ExecuteSql @Sql
End
Else if @CatLevel = 'Company'
Begin
Set @SQL = 'Select CatLevel, CatLevel As [Category], CGName as [Category Group], TotActCust As [Total Active Customer],  [NoOfMappedCust] As [No.Of Customers],CustomerID As [Customer Code],
RCSID As [RCS ID],CustomerName aS [Customer Name], CategoryHandler As [Category Handler], Address as [Billing Address],Channel As [Customer Type], [Channel Type], [Outlet Type], [Loyalty Program],
Sum(isNull(NetSales,0)) AS [Net Total Sales(Rs)],
Sum(isNull(NetSales,0))/(Case isNull(BillCount,0) When 0 Then 1 Else isNull(BillCount,0) End)   As [Avg Bill Value],
isNull(BillCount,0) As [Bills Cut],isNull(LinesCut,0)/(Case isNull(BillCount,0) When 0 Then 1 Else isNull(BillCount,0) End)  As [Avg Lines Cut],
isNull(LinesCut,0) As [Total Lines Cut],SalesManName As [Salesman]'

If @Sales = 'Volume'
Set @SQL = @SQL + ',Sum(isNull(Quantity,0)) As [Net Total Sales Qty]'

Set @SQL = @SQL + @MerchandiseCol
Set @SQL = @SQL + ' From #tmpCustProductivity T1, #tempCategory1 T Where T.CategoryID = T1.CatID And 
CategoryHandler IN (' + @CategoryHandler + ') Group By CatLevel,CGName,NoOfMappedCust,CustomerID,RCSID,
CustomerName,Address,Channel,SalesManName,BillCount,LinesCut, 
TotActCust, CategoryHandler, [Channel Type], [Outlet Type], [Loyalty Program]'
Set @SQL = @SQL +  @MerchandiseCol
Set @SQL = @SQL + ',T.IDS Order By T.IDS'
Exec sp_ExecuteSql @Sql
End
End
Drop Table #tmpCategories
Drop Table #tempCategory
Drop Table #tmpItems
Drop Table #tmpCustomer
Drop Table #tmpChannel
Drop Table #tmpDS
Drop Table #tmpDSName
Drop Table #tmpBeat
Drop Table #tempCategoryList
Drop Table #tmpMerchandise
Drop Table #tmpCustProductivity
Drop Table #tmpCust
Drop Table #OLClassMapping
Drop Table #OLClassCustLink
if @Productivity = 'Non - Productive'
Begin
Drop Table #tmpIdentity
Drop Table #tmpCustBeatSman
Drop Table #tmpBeatCount
Drop Table #tmpBilledCustomer

End
if @Productivity = 'Productive'
Begin
Drop Table #tmpCatIDCG
Drop Table #tmpCGWiseBill
Drop Table #tmpCGWiseLineCnt
Drop Table #tmpProdCount
Drop Table #tmpAllCustomer
Drop table #tmpProdDetails
End
End

