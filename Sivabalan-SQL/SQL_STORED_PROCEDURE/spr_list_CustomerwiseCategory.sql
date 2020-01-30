
CREATE Procedure spr_list_CustomerwiseCategory(
	@ProductHierarchy nvarchar(100), 
	@CategoryGroup  nVarchar(4000),
	@Category nVarchar(4000),
	@Salesman nvarchar(2550),	
	@Beat nvarchar(2550),    
	@MerchandiseType nvarchar(2550), 
	@Sales nVarchar(10),
	@UOM nVarchar(10),
	@FromDate DateTime, 
	@ToDate DateTime,
	@CustomerProductivity nVarchar(50))
As                
Declare @Delimeter as Char(1), @NoRecs Int
Set @Delimeter=Char(15)        
Create table #tmpBeat(BeatID Int, Beat nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)       
Create Table #tmpSalesMan ( SalesmanID Int, SalesMan_Name nvarchar (255) COLLATE SQL_Latin1_General_CP1_CI_AS)     
Create Table #tmpMerchandiseType (ID Integer Identity(1,1), MerchandiseType nvarchar (255) COLLATE SQL_Latin1_General_CP1_CI_AS)    

If @Beat=N'%'         
Begin      
	Insert into #tmpBeat select BeatID, description from Beat Union Select 0, ''       
--	Insert InTo #tmpBeat Values (N'')      
End      
Else        
Begin      
	Insert into #tmpBeat select BeatID, description from Beat 
	Where description In (select * from dbo.sp_SplitIn2Rows(@Beat,@Delimeter))
End      
      
If @Salesman=N'%'         
Begin      
	Insert into #tmpSalesMan select SalesmanID, SalesMan_Name from SalesMan Union Select 0, ''        
--	Insert InTo #tmpSalesMan Values (N'')      
End      
Else        
Begin      
	Insert into #tmpSalesMan select SalesmanID, SalesMan_Name from SalesMan 
	Where SalesMan_Name In (select * from dbo.sp_SplitIn2Rows(@SalesMan,@Delimeter))
End      
    
--------Changes based on new parameter

Declare @Continue AS INT       
Declare @Inc AS INT     
Declare @TCat AS INT      
Declare @Continue1 AS INT      
Declare @CategoryID AS INT  

Set @Continue = 0
Set @Inc = 1

Create Table #tmpCat(IDS Int Identity(1,1), CatID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS) 
Create Table #temp3 (CatID Int, Status Int)   
Create Table #temp4 (LeafId int,CatID Int, Parent nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)          
Create Table #tempCG(IDS Int Identity(1,1),CatID Int)  
Create Table #tempCatGroup(GroupName nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)    
Create Table #tempCatGroupID (CatID Int, Status Int)          

if @CategoryGroup = N'%'
	Insert Into #tempCatGroup Select GroupName From ProductCategoryGroupAbstract
else
Begin
  Insert Into #tempCatGroup select * from dbo.sp_SplitIn2Rows( @CategoryGroup, @Delimeter)
End

If @ProductHierarchy = N'%'   Or @ProductHierarchy = N'Division'
	Insert into #tmpCat select CategoryID from ItemCategories Where [level] = 2        
else if @ProductHierarchy <> N'%'   
	Insert InTo #tmpCat select Categoryid From itemcategories itc, itemhierarchy ith          
    where itc.[level] = ith.hierarchyid and ith.hierarchyname = @ProductHierarchy        

--Get All LeafID'S For the ProductHierarchy  selected      
Set @Continue = IsNull((Select Count(*) From #tmpCat), 0)          
While @Inc <= @Continue          
Begin          
 Insert InTo #temp3 Select CatID, 0 From #tmpCat Where IDS = @Inc          
    Select @TCat = CatID From #tmpCat Where IDS = @Inc          
 Select @Continue1 = Count(*) From #temp3 Where Status = 0              
 While @Continue1 > 0              
 Begin              
     Declare Parent Cursor Keyset For              
     Select CatID From #temp3  Where Status = 0              
     Open Parent              
     Fetch From Parent Into @CategoryID        
     While @@Fetch_Status = 0              
     Begin              
      Insert into #temp3 Select CategoryID, 0 From ItemCategories               
      Where ParentID = @CategoryID      
      If @@RowCount > 0               
        Update #temp3 Set Status = 1 Where CatID = @CategoryID              
      Else                 
        Update #temp3 Set Status = 2 Where CatID = @CategoryID      
      Fetch Next From Parent Into @CategoryID         
     End         
     Close Parent              
     DeAllocate Parent               
     Select @Continue1 = Count(*) From #temp3 Where Status = 0              
   End              
 Delete #temp3 Where Status not in  (0, 2)              
 Insert InTo #temp4 Select CatID, @TCat,         
 (Select Category_Name From ItemCategories where CategoryID = @TCat) From #temp3         
 Delete #temp3          
-- Set @Continue1 = 1          
 Set @Inc = @Inc + 1          
End   

-- Category Group Handling based on the CategoryGroup definition 

Declare @TempCGCatMapping Table (GroupID Int, Product_Code nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryID Int, CategoryName nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert InTo @TempCGCatMapping  
Select "GroupID" = pcga.GroupID, "GroupName" = cgdm.CategoryGroup, 
"CategoryID" = icat.CategoryID, "CategoryName" = cgdm.Division
From tblcgdivmapping cgdm, ProductCategoryGroupAbstract pcga, ItemCategories icat
Where cgdm.CategoryGroup = pcga.GroupName And cgdm.Division = icat.Category_Name

if @Category =N'%'  
 Insert into #tempCG    
 select PD.CategoryID     
 from ProductCategorygroupAbstract PA,@TempCGCatMapping PD  
 where PA.groupid = PD.groupid    
 and PA.GroupName In (Select GroupName COLLATE SQL_Latin1_General_CP1_CI_AS From  #tempCatGroup)      
ELSE  
    Insert into #tempCG  
 select Categoryid From itemcategories itc Where Category_Name   
 In(Select * from dbo.sp_SplitIn2Rows(@Category,@Delimeter))                

Set @Inc =1  
Set @CategoryID  =0  
Delete #temp3          

--Inserts leaf categories for the selected category group  
Set @Continue = IsNull((Select Count(*) From #tempCG), 0)          
While @Inc <= @Continue          
Begin          
 Insert InTo #tempCatGroupID Select CatID, 0 From #tempCG Where IDS = @Inc          
 Select @Continue1 = Count(*) From #tempCatGroupID Where Status = 0              
 While @Continue1 > 0              
 Begin              
     Declare Parent Cursor Keyset For              
     Select CatID From #tempCatGroupID  Where Status = 0              
     Open Parent              
     Fetch From Parent Into @CategoryID        
     While @@Fetch_Status = 0              
     Begin              
      Insert into #tempCatGroupID Select CategoryID, 0 From ItemCategories               
      Where ParentID = @CategoryID      
      If @@RowCount > 0               
        Update #tempCatGroupID Set Status = 1 Where CatID = @CategoryID              
      Else                 
        Update #tempCatGroupID Set Status = 2 Where CatID = @CategoryID      
      Fetch Next From Parent Into @CategoryID             
     End         
     Close Parent              
     DeAllocate Parent               
     Select @Continue1 = Count(*) From #tempCatGroupID Where Status = 0              
   End              
 Delete #tempCatGroupID Where Status not in  (0, 2)     
 Set @Inc = @Inc + 1          
End   

------------Customer Filter

Declare @TempCustomerList Table (CustomerID nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)

If @CustomerProductivity = N'Only Productive Customer' 
Begin
	Insert InTo @TempCustomerList 
	Select ia.CustomerID From InvoiceDetail ide, InvoiceAbstract ia , Items its 
	Where                 
	ia.InvoiceID = ide.InvoiceID And  
	its.Product_code = ide.Product_code And 
	its.CategoryID In (Select LeafId From #temp4 ) And 
	its.CategoryID In (Select CatID From #tempCatGroupID) And 
	(IsNull(ia.Status, 0) & 192) = 0 And ia.InvoiceType != 2 And 
	InvoiceDate Between @FromDate And	@ToDate And 
	ia.SalesmanID In (select SalesmanID From #tmpSalesMan) And 
	ia.BeatID In (Select BeatID From #tmpBeat) 
End
Else
Begin
	Insert InTo @TempCustomerList 
	Select cu.CustomerID From Customer cu
	Where DefaultBeatID In (Select BeatID From #tmpBeat)
	And DefaultBeatID In (Select Distinct BeatID From Beat_Salesman
		Where SalesmanID In (select SalesmanID From #tmpSalesMan))
	And Active = 1
End

-----------------



--------------------------------------------------------
If @MerchandiseType =N'%'    
Begin      
	Insert into #tmpMerchandiseType select Merchandise from Merchandise Order by Merchandise
End      
Else        
Begin      
	Insert into #tmpMerchandiseType select * from dbo.sp_SplitIn2Rows(@MerchandiseType,@Delimeter)         
End      
    
Declare @SelQuery Varchar(max), @ColSelected nVarchar(4000), @LevelCatLst varchar(max)  

Set @LevelCatLst = N''            
Set @SelQuery = N''
SET @ColSelected = N''  

Declare @ProductHierarchyID int                
If RTRIM(LTRIM(@ProductHierarchy)) Is Null Or RTRIM(LTRIM(@ProductHierarchy)) =  N'%' or RTRIM(LTRIM(@ProductHierarchy)) = N''              
	Set @ProductHierarchyID = 1              
Else              
	Select @ProductHierarchyID = HierarchyID From ItemHierarchy Where IsNull(HierarchyName, N'') Like @ProductHierarchy                
              
-- Channel type name changed, and new channel classifications added

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

If Exists (Select * From Sysobjects
	Where [Name] Like 'tbl_mERP_OLClass' And xtype = 'U')
Begin
	Create Table #tmpChannelType (ChannelType nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Insert Into #tmpChannelType Select Distinct Channel_Type_Desc From tbl_merp_olclass Union Select @TOBEDEFINED

	Create Table #tmpOutletType (OutletType nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Insert Into #tmpOutletType Select Distinct Outlet_Type_Desc From tbl_merp_olclass Union Select @TOBEDEFINED

	Create Table #tmpLoyaltyProgram (LoyaltyProgram nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Insert Into #tmpLoyaltyProgram  Select Distinct SubOutlet_Type_Desc From tbl_merp_olclass Union Select @TOBEDEFINED


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
	Right Outer Join Customer C On olcm.CustomerID = C.CustomerID

End
Else
Begin

	Insert Into #OLClassMapping 
	Select  0, '', '', '', ''
	

	Insert Into #OLClassCustLink 
	Select olcm.OLClassID, C.CustomerId, C.ChannelType , C.Active, IsNull(olcm.[Channel Type], ''), 
	IsNull(olcm.[Outlet Type], '') , IsNull(olcm.[Loyalty Program], '') 
	From #OLClassMapping olcm
	Right Outer Join  Customer C On olcm.CustomerID = C.CustomerID
End 
-----
Create Table #temtab1 ([ID] Int Identity(1, 1), CustomerID nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
CustomerName nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, 
RCSID nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, 
TinNumber nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, 
DefaultBeat nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
Defaultsalesman nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
DefaultDSType nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
CustomerType nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
ChannelType	nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
OutletType nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
LayaltyProgram nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
CatsID Int,              
Quantity Decimal(18,6), GrossValue Decimal(18,6), TaxValue Decimal(18,6),  Discount Decimal(18,6), 
NetAmount Decimal(18,6), RoundOffAmt Decimal(18,6), RoundedNetValue Decimal(18,6))              

Create Table #temtab1of2 ([ID] Int Identity(1, 1), CustomerID nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
CustomerName nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, 
RCSID nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, 
TinNumber nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, 
DefaultBeat nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
Defaultsalesman nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
DefaultDSType nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
CustomerType nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
ChannelType	nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
OutletType nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
LayaltyProgram nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
CatsID Int,              
Quantity Decimal(18,6), GrossValue Decimal(18,6), Discount Decimal(18,6), TaxValue Decimal(18,6),  
NetAmount Decimal(18,6), RoundOffAmt Decimal(18,6), RoundedNetValue Decimal(18,6))              

Create Table #temtab1of3 ([ID] Int Identity(1, 1), CustomerID nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
CustomerName nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, 
RCSID nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, 
TinNumber nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, 
DefaultBeat nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
Defaultsalesman nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
DefaultDSType nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
CustomerType nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
ChannelType	nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
OutletType nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
LayaltyProgram nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
CatsID Int,              
Quantity Decimal(18,6), GrossValue Decimal(18,6), Discount Decimal(18,6), TaxValue Decimal(18,6),  
NetAmount Decimal(18,6), RoundOffAmt Decimal(18,6), RoundedNetValue Decimal(18,6))              
              
Create Table #temtab2 ( ID Int Identity(1, 1), CustomerID nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
CustomerName nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, 
RCSID nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, 
TinNumber nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, 
DefaultBeat nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
Defaultsalesman nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
DefaultDSType nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
CustomerType nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
ChannelType	nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
OutletType nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
LoyaltyProgram nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS
)              
--Quantity Decimal(18,6), GrossValue Decimal(18,6), TaxValue Decimal(18,6), Discount Decimal(18,6), NetAmount               
--Decimal(18,6))                        

-------------------

-------------RoundoffValue and NetRoundOff valu


Declare @tblInvoice Table (InvID Int)
Declare @CustwiseRoff Table (InvID Int, CustID nVarchar(256), RounOff Decimal(18, 6), NetRoundOff Decimal(18, 6))
Declare @CustwiseRoff2 Table (CustID nVarchar(256), RounOff Decimal(18, 6), NetRoundOff Decimal(18, 6))
Declare @RoundOffValue Decimal(18, 6)
Declare @NetRoundOffValue Decimal(18, 6)

Set @RoundOffValue = 0
Set @NetRoundOffValue  = 0

Insert InTo @tblInvoice 
Select ia.InvoiceID
From InvoiceDetail ide, InvoiceAbstract ia , Items its , Customer cu
Where                 
	ia.InvoiceID = ide.InvoiceID And  cu.CustomerID = ia.CustomerID And 
	its.Product_code = ide.Product_code And 
	cu.CustomerID In (Select CustomerID From @TempCustomerList) And 
	its.CategoryID In (Select LeafId From #temp4 ) And 
	its.CategoryID In (Select CatID From #tempCatGroupID) And 
	(IsNull(ia.Status, 0) & 192) = 0 And ia.InvoiceType != 2 And 
	InvoiceDate Between @FromDate And	@ToDate  

--Select Distinct InvID From @tblInvoice

Insert InTo @CustwiseRoff
Select ia.InvoiceID, ia.CustomerID, 
((Case ia.InvoiceType When 4 Then -1 Else 1 End)  * ia.RoundOffAmount), 
Sum((Case ia.InvoiceType When 4 Then -1 Else 1 End)  * ide.Amount)
From InvoiceDetail ide, InvoiceAbstract ia, items its
Where ia.InvoiceID = ide.InvoiceID And 
ia.InvoiceID In (Select Distinct InvID From @tblInvoice) And 
its.Product_Code = ide.Product_Code and 
its.CategoryID In (Select LeafId From #temp4 ) And 
its.CategoryID In (Select CatID From #tempCatGroupID)

Group By ia.InvoiceID , ia.CustomerID, ia.InvoiceType, ia.RoundOffAmount

--select * from @CustwiseRoff

If @CategoryGroup = '%' and @Category = '%'
Begin
	Insert InTo @CustwiseRoff2
	Select CustID , Sum(RounOff) , Sum(NetRoundOff)
	From @CustwiseRoff
	Group By CustID
End
Else
Begin
	Insert InTo @CustwiseRoff2
	Select CustID , Sum(0) , Sum(NetRoundOff)
	From @CustwiseRoff
	Group By CustID
End

--------------------
Insert InTo #temtab1of2 (CustomerID , CustomerName , RCSID , 
TinNumber , DefaultBeat , Defaultsalesman , DefaultDSType , 
CustomerType , ChannelType	, OutletType , 
LayaltyProgram)
Select "CustomerID" = cu.CustomerID, cu.Company_Name, 
"RCSID" = cu.RCSOutletID,
"TinNumber" = cu.TIN_Number,
"DefaultBeat" = (Select Top 1 Description From Beat
	Where BeatID = cu.DefaultBeatID),
"DefaultSalesman" = (Select Top 1 Salesman_Name From Salesman
	where salesmanid In (Select top 1 Salesmanid From Beat_Salesman
	where  beatid = cu.DefaultBeatID)),
"DefaultDSType" = (Select  Top 1 DSTypeValue from DSType_Master
	Where DSTypeID In (Select Top 1 DSTypeID from DSType_Details
	Where SalesManID In (Select Top 1 SalesmanID From Salesman
	where salesmanid in ( Select top 1 Salesmanid From Beat_Salesman
	where  beatid = cu.DefaultBeatID)) And DSTypeCtlPos = 1)),
"CustomerType" = (Select Top 1 ChannelDesc From Customer_Channel
	Where ChannelType In (Select ChannelType From Customer 
	Where customerid = cu.CustomerID)),
"ChannelType" = (Select [Channel Type] From #OLClassCustLink
	Where CustomerID = cu.CustomerID),
"OutletType" = (Select [Outlet Type] From #OLClassCustLink
	Where CustomerID = cu.CustomerID),
"LayaltyProgram" = (Select [Loyalty Program] From #OLClassCustLink
	Where CustomerID = cu.CustomerID)
From Customer cu 
Where cu.CustomerID In (Select CustomerID From @TempCustomerList) 
	
Insert #temtab1 Select * From (                
Select CustomerID, Company_Name, 
RCSID, TinNumber, DefaultBeat, DefaultSalesman,
DefaultDSType, CustomerType, ChannelType,
OutletType, LayaltyProgram, 
CatID, Sum(Qty) Quantity, Sum([Gross Value]) "Gross Value",                 
Sum([Tax Value]) "Tax Value", Sum(Discount) Discount,
Sum([Net Value]) "Net Value", 
Sum(RoundOffAmt) "RoundOffAmt",
Sum(RoundedNetValue) "RoundedNetValue"
 From (                

Select "CustomerID" = cu.CustomerID, cu.Company_Name, 
"RCSID" = cu.RCSOutletID,
"TinNumber" = cu.TIN_Number,
"DefaultBeat" = (Select Top 1 Description From Beat
	Where BeatID = cu.DefaultBeatID),
"DefaultSalesman" = (Select Top 1 Salesman_Name From Salesman
	where salesmanid In (Select top 1 Salesmanid From Beat_Salesman
	where  beatid = cu.DefaultBeatID)),
"DefaultDSType" = (Select  Top 1 DSTypeValue from DSType_Master
	Where DSTypeID In (Select Top 1 DSTypeID from DSType_Details
	Where SalesManID In (Select Top 1 SalesmanID From Salesman
	where salesmanid in ( Select top 1 Salesmanid From Beat_Salesman
	where  beatid = cu.DefaultBeatID)) And DSTypeCtlPos = 1)),
"CustomerType" = (Select Top 1 ChannelDesc From Customer_Channel
	Where ChannelType In (Select ChannelType From Customer 
	Where customerid = cu.CustomerID)),
"ChannelType" = (Select [Channel Type] From #OLClassCustLink
	Where CustomerID = cu.CustomerID),
"OutletType" = (Select [Outlet Type] From #OLClassCustLink
	Where CustomerID = cu.CustomerID),
"LayaltyProgram" = (Select [Loyalty Program] From #OLClassCustLink
	Where CustomerID = cu.CustomerID),
dbo.fin_cat(@ProductHierarchyID, ide.Product_Code) CatID, 
Sum((Case ia.InvoiceType When 4 Then -1 Else 1 End) *                 
(Case When @Sales = 'Value' Then ide.Amount Else 
	Case @UOM When 'UOM1' Then ide.Quantity / (Case IsNull(its.UOM1_Conversion, 0) When 0 
		Then 1 Else its.UOM1_Conversion End)
	When 'UOM2' Then ide.Quantity / (Case IsNull(its.UOM2_Conversion, 0) When 0 
		Then 1 Else its.UOM2_Conversion End)
	Else ide.Quantity End End)) Qty, 
Sum(((Case ia.InvoiceType When 4 Then -1 Else 1 End) * ide.Quantity) * ide.SalePrice) "Gross Value",                 
Sum(((Case ia.InvoiceType When 4 Then -1 Else 1 End) * (ide.CSTPayable + ide.STPayable)) +                 
(((ide.Quantity * ide.SalePrice) * ide.TaxSuffered)/100)) "Tax Value",  
              

Sum((Case ia.InvoiceType When 4 Then -1 Else 1 End) * (ide.DiscountValue
+ ((ide.Quantity * ide.SalePrice) - ide.DiscountValue) * (ia.DiscountPercentage / 100) 
+ ((ide.Quantity * ide.SalePrice) - ide.DiscountValue) * (ia.AdditionalDiscount / 100) 
) ) "Discount",

              
Sum((Case ia.InvoiceType When 4 Then -1 Else 1 End) * ide.Amount) "Net Value",
Sum((0)) "RoundOffAmt",
Sum(0)  "RoundedNetValue"
From InvoiceDetail ide, InvoiceAbstract ia , Items its , Customer cu
	
Where                 
	ia.InvoiceID = ide.InvoiceID And  cu.CustomerID = ia.CustomerID And 
	its.Product_code = ide.Product_code And 
	cu.CustomerID In (Select CustomerID From @TempCustomerList) And 
	its.CategoryID In (Select LeafId From #temp4 ) And 
	its.CategoryID In (Select CatID From #tempCatGroupID) And 
	(IsNull(ia.Status, 0) & 192) = 0 And ia.InvoiceType != 2 And 
	InvoiceDate Between @FromDate And	@ToDate  
	
Group By ide.Product_Code, cu.Company_Name, cu.CustomerID, cu.RCSOutletID, cu.TIN_Number,
	cu.DefaultBeatID 
	) temtab 
	Where CatID > 0 
	Group By CatID, Company_Name, CustomerID, RCSID, TinNumber, DefaultBeat, DefaultSalesman,
	DefaultDSType, CustomerType, ChannelType,
	OutletType, LayaltyProgram ) abse                


Delete From #temtab1of2
Where CustomerID In ( Select CustomerID From #temtab1)

--select * from #temtab1

Insert InTo #temtab1of2
	(CustomerID , CustomerName , RCSID , TinNumber , 
	DefaultBeat , Defaultsalesman , DefaultDSType , CustomerType , 
	ChannelType	, OutletType , LayaltyProgram , CatsID , 
	Quantity , GrossValue , Discount , TaxValue ,  
	NetAmount , RoundOffAmt , RoundedNetValue)
	Select CustomerID , CustomerName , RCSID , TinNumber , 
	DefaultBeat , Defaultsalesman , DefaultDSType , CustomerType , 
	ChannelType	, OutletType , LayaltyProgram , CatsID , 
	Quantity , GrossValue , Discount , TaxValue ,  
	NetAmount , RoundOffAmt , RoundedNetValue From #temtab1

Insert InTo #temtab1of3
	(CustomerID , CustomerName , RCSID , TinNumber , 
	DefaultBeat , Defaultsalesman , DefaultDSType , CustomerType , 
	ChannelType	, OutletType , LayaltyProgram , CatsID , 
	Quantity , GrossValue , Discount , TaxValue ,  
	NetAmount , RoundOffAmt , RoundedNetValue)
	Select CustomerID , CustomerName , RCSID , TinNumber , 
	DefaultBeat , Defaultsalesman , DefaultDSType , CustomerType , 
	ChannelType	, OutletType , LayaltyProgram , CatsID , 
	Quantity , GrossValue , Discount , TaxValue ,  
	NetAmount , RoundOffAmt , RoundedNetValue From #temtab1of2

--------------
--select * from #temtab1of3
--------------

Declare @Count1 Int, @VarID1 Int, @VarID2 Int, @Count2 Int, @LevelCat nvarchar(50), @VarString1 nvarchar(4000)    
Set @VarID1 = 1                
Select @Count1 = Count(*) From #temtab1of3                
If @Count1 > 0                
Begin                
	If @ProductHierarchy = '%' 
	Begin
		Set @ProductHierarchy = (Select hierarchyname From ItemHierarchy Where Hierarchyid = 1)
	End
	Create Table #catname([ID] Int Identity(1, 1), CID Int, CName nvarchar(100))                
	Insert  #catname Select * From (Select distinct CategoryID, Category_Name From ItemCategories 
	Where CategoryID In (Select * From dbo.fn_GetCatFrmCG_ITC(	@CategoryGroup, @ProductHierarchy , default))) ccn
End                
Else               
Begin              
	Set @NoRecs = 1
	GoTo Lab1              
End              


Select @Count2 = Count(*) From #catname                
While @VarID1 <= @Count2                
Begin                
 Select @VarID2 = CID From #catname Where [ID] = @VarID1                
 Select @LevelCat = CName From #catname Where CID = @VarID2                
 Set @VarString1 = N'Alter table #temtab2 Add [' + @LevelCat + N'] Decimal(18,6) Default(0)'                
 Exec sp_executesql @VarString1           
 set @LevelCatLst = @LevelCatLst + ',[' + @LevelCat + ']'
 Set @VarID1 = @VarID1 + 1                
End                
Alter table #temtab2 Add GrossValue Decimal(18,6), Discount Decimal(18,6), TaxValue Decimal(18,6), 
NetValue Decimal(18,6), RoundOffAmt Decimal(18,6), RoundedNetValue Decimal(18,6)
--Declare @aCount1 Int, @bVarID1 Int, @cVarID2 Int, @dCount2 Int,             
--@LevelCat nvarchar(50), @nvVarString1 nvarchar(4000)                    
Declare @TempCatID Int, @VarString2 nvarchar(4000), @CatName nvarchar(100),              
@CustomerName nvarchar(100)                
Declare @Qty Decimal(18,6), @GV Decimal(18,6), @TV Decimal(18,6), @Dis Decimal(18,6), @NA Decimal(18,6),
	@RoundOff Decimal(18,6), @RoundedNV Decimal(18,6)
Set @VarID1 = 1  
----
--select @Count1
---              
While @VarID1 <= @Count1                
Begin                
 Select @TempCatID = catsid, @CustomerName = CustomerName From #temtab1of3 Where [ID] = @VarID1   
 If IsNull(@TempCatID, 0) = 0
 Begin
	 Set @TempCatID = (Select Top 1 CID From #catname
		Where [ID] Not In (Select IsNull(CatsID, 0) From #temtab1of3))
 End
             

 Select @CatName = CName From #catname Where CID = @TempCatID            
 If Exists (Select * From #temtab2 Where CustomerName = @CustomerName)                
  Begin                
   Select @TempCatID = [ID] From #temtab2 Where CustomerName = @CustomerName            
   Select @Qty = IsNull(Quantity, 0), @GV = IsNull(GrossValue, 0), @TV = IsNull(TaxValue, 0), 
	@Dis = IsNull(Discount, 0), @NA = IsNull(NetAmount, 0),                
	@RoundOff = IsNull(RoundOffAmt, 0) , @RoundedNV = IsNull(RoundedNetValue, 0)
   From #temtab1of3 Where [ID] = @VarID1             
   Set @VarString2 = N'Update #temtab2 Set [' + @CatName + N'] = ' +  N'IsNull([' + @CatName + N'], 0) + '            
   + Cast(@Qty As nvarchar) +                 
   N', GrossValue = GrossValue + ' +  Cast(@GV As nvarchar) + N', TaxValue = TaxValue + ' +                 
   Cast(@TV As nvarchar) + N', Discount = Discount + ' + Cast(@Dis As nvarchar) + ',                 
   NetValue = NetValue + ' + Cast(@NA As nvarchar) + N',
   RoundOffAmt = RoundOffAmt + ' + Cast(@RoundOff As nVarchar) + ',
   RoundedNetValue = RoundedNetValue + ' + Cast(@RoundedNV As nVarchar) + N' 
   Where [ID] = ' + Cast(@TempCatID As nvarchar)            
   exec sp_executesql @VarString2            
   Set @VarID1 = @VarID1 + 1                
  End                
 Else                
 Begin       
--	select 'inside insert tab2'
--	select @CatName         
  Set @VarString2 = N'Insert #temtab2( CustomerID, CustomerName, 
	RCSID, TinNumber, DefaultBeat, DefaultSalesman,
	DefaultDSType, CustomerType, ChannelType,
	OutletType, LoyaltyProgram, [' + @CatName + N'], GrossValue,                 
    TaxValue, Discount, NetValue, RoundOffAmt, RoundedNetValue) 
	Select CustomerID, CustomerName, RCSID, TinNumber, DefaultBeat, DefaultSalesman,
	DefaultDSType, CustomerType, ChannelType,
	OutletType, LayaltyProgram, IsNull(Quantity, 0), IsNull(GrossValue, 0), IsNull(TaxVAlue, 0), 
	IsNull(Discount, 0), 
	IsNull(NetAmount, 0),
	IsNull(RoundOffAmt, 0), IsNull(RoundedNetValue, 0)
	From #temtab1of3 Where [ID] = ' + Cast(@VarID1 As nvarchar)                 
  exec sp_executesql @VarString2 
------------------------
--select * from #temtab2
--select * from #temtab1of3
------------------------           
  Set @VarID1 = @VarID1 + 1                
 End                
End                
set @LevelCatLst = @LevelCatLst + ', GrossValue, Discount, TaxValue, NetValue, RoundOffAmt, RoundedNetValue'  
Drop table #catname              
    

Declare @MrcTypeCnt Int    
Declare @RecCnt Int, @tmpMrcType nVarchar(255)    
Declare @VarString3 nVarchar(1000)    
Select @MrcTypeCnt = Count(*) From #tmpMerchandiseType  
Alter table #temtab2 Add MapFlag Int Default 0

SET @RecCnt = 1     
While @RecCnt <= @MrcTypeCnt    
 Begin   
   Select @tmpMrcType = MerchandiseType From #tmpMerchandiseType Where ID = @RecCnt    
   Set @VarString3 = N'Alter table #temtab2 Add [' + @tmpMrcType + N'] nVarchar(5) COLLATE SQL_Latin1_General_CP1_CI_AS'    
   Exec sp_executesql @VarString3    
    
   Set @VarString3 = 'Update tmp Set [' + @tmpMrcType + '] = '+ CHAR(39)+ N'Yes' +CHAR(39)+ ', MapFlag = 1 From #temtab2 tmp, Customer Cust, CustMerchandise CustMrc    
   Where Cust.CustomerID = CustMrc.CustomerID and     
   Cust.Company_Name = tmp.CustomerName and    
   CustMrc.MerchandiseID = (select MerchandiseID From Merchandise Where Merchandise =N' + CHAR(39)+@tmpMrcType + CHAR(39)+')'    
   Exec sp_executesql @VarString3    
    
   Set @VarString3 = 'Update #temtab2 Set [' + @tmpMrcType + '] = '+ CHAR(39)+ N'No' +CHAR(39)+  ' Where [' + @tmpMrcType + '] Is Null'    
   Exec sp_executesql @VarString3    
   Set @RecCnt = @RecCnt + 1     
   Set @ColSelected = @ColSelected + ',['+ @tmpMrcType + ']'  
 End    
          

Update t1 Set t1.RoundOffAmt = t2.RounOff , t1.RoundedNetValue = (t2.RounOff + t2.NetRoundOff)
From #temtab2 t1 , @CustwiseRoff2 t2
Where  
t1.CustomerID = t2.CustID

--select * from @CustwiseRoff2

Lab1:              
--Set @SelQuery = 'Select ID, CustomerName ' + @ColSelected + @LevelCatLst + ' From #temtab2'  
Set @SelQuery = 'Select ID, "CustomerCode" = CustomerID, CustomerName, 
RCSID, TinNumber, DefaultBeat, DefaultSalesman,
DefaultDSType, CustomerType, ChannelType,
OutletType, LoyaltyProgram ' + @LevelCatLst + @ColSelected + ' From #temtab2'  

-----
--select  @LevelCatLst 
--select  @ColSelected + ' From #temtab2'

-----
If (@MerchandiseType <> N'%') And (@NoRecs = 0)
	Set @SelQuery = @SelQuery + ' Where MapFlag = 1'


Set @SelQuery = @SelQuery + ' Order By CustomerName'

--select @SelQuery
Exec (@SelQuery  )
--Drop table #catname                
Drop table #temtab1                
Drop table #temtab2                
Drop Table #tmpBeat      
Drop Table #tmpSalesMan    
Drop table #tmpMerchandiseType
Drop Table #temtab1of2
Drop Table #temtab1of3
