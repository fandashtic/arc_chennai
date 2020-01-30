Create PROCEDURE spr_List_Collection_DSWise_BeatWise_Abstract_ITC_OCG  
(  
   @CategoryGrouptype nVarchar(100),  
   @Category_Group nVarchar(4000),  
   @Hierarchy NVARCHAR(50),  
   @Category NVARCHAR(4000),  
   @DS nVarchar(50),  
   @Beat nVarchar(4000),  
   @DocType nVarchar(100),  
   @szInvFromDate  nVarchar(50),  
   @szInvToDate  nVarchar(50),  
   @szCollFromDate  nVarchar(50),  
   @szCollToDate  nVarchar(50),  
   @InvPaymentMode nVarchar(50),  
   @CollPaymentMode nVarchar(50)  
)  
AS  
  
DECLARE @Delimiter as Char(1)  
DECLARE @CategoryID as int  
Declare @OTHERS NVarchar(50)  
Declare @InvPaymentModeNo int  
Declare @CollPaymentModeNo int  
Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)  
SET @Delimiter=Char(15)  
      
Declare @MLCash nVarchar(50)  
Declare @MLCheque nVarchar(50)  
Declare @MLDD nVarchar(50)  
Declare @MLBankTransfer nVarchar(50)  
Declare @MLCredit nVarchar(50)  
      
Set @MLCash = dbo.LookupDictionaryItem(N'Cash', Default)  
Set @MLCheque = dbo.LookupDictionaryItem(N'Cheque', Default)  
Set @MLDD = dbo.LookupDictionaryItem(N'DD', Default)  
Set @MLBankTransfer = dbo.LookupDictionaryItem(N'Bank Transfer', Default)  
Set @MLCredit = 'Credit'  
  
--Handle the date parameter  
Declare @InvFromDate DATETIME  
Declare @InvToDate DATETIME  
Declare @CollFromDate DATETIME  
Declare @CollToDate DATETIME  
Declare @GroupId Int  
Declare @GroupName nvarchar(1000)  
--If hierarchy parameter deleted then make the second level as hierarchy by default  
if @Hierarchy  = '%' or @Hierarchy  = 'Division'  
select @Hierarchy = HierarchyName from itemhierarchy where hierarchyid = 2  
      
if (@szInvFromDate <> '' and @szInvFromDate <> '%' and @szInvToDate <> '' and @szInvToDate <> '%') --Both date entered properly  
BEGIN  
 set @InvFromDate = cast(@szInvFromDate as DateTime)  
 set @InvToDate = cast(@szInvToDate as DateTime)  
End  
Else  
BEGIN  
 Select @InvFromDate = min(InvoiceDate) from invoiceAbstract  
 select @InvToDate = max(InvoiceDate) from invoiceAbstract  
End  
      
if (@szCollFromDate <> '' and @szCollFromDate <> '%' and @szCollToDate <> '' and @szCollToDate <> '%') --Both date entered properly  
BEGIN  
 set @CollFromDate = cast(@szCollFromDate as DateTime)  
 set @CollToDate = cast(@szCollToDate as DateTime)  
End  
Else  
BEGIN  
 Select @CollFromDate = min(DocumentDate) from Collections  
 select @CollToDate = max(DocumentDate) from Collections  
End  
  
Create Table #tempSalesMan (Salesman_Name NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS)  
If @DS = '%'  
 Insert Into #tempSalesMan Select Salesman_Name From Salesman  
Else  
 Insert Into #tempSalesMan Select * From DBO.sp_SplitIn2Rows(@DS,@Delimiter)  
      
Create Table #tempBeat (BeatName NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS)  
If @Beat = '%'   --If @Beat = '%' and If @DS = '%' No validation  
  BEGIN  
      If @DS = '%'  
          Insert Into #tempBeat  
          Select [Description]  From Beat  
      Else  
          Insert Into #tempBeat  
          Select [Description]  From Beat  
          where Beat.BeatID in (select * from dbo.fn_GetBeatForSalesMan_ITC(@DS,@Delimiter))  
  End  
Else  
 Insert Into #tempBeat Select * From DBO.sp_SplitIn2Rows(@Beat,@Delimiter)  
      
      
Create Table #tempCategoryGroup (CategoryGroup NVarChar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS)  
                  
If @CATEGORY_GROUP = '%'  
If @CategoryGrouptype='Operational'  
 Insert Into #tempCategoryGroup   
 Select GroupName From productcategorygroupabstract where OCGtype = 1  
Else  
 Insert Into #tempCategoryGroup   
 Select GroupName From productcategorygroupabstract where GroupName in (Select distinct CategoryGroup from tblcgdivmapping)  
  
Else  
 Insert Into #tempCategoryGroup Select * From DBO.sp_SplitIn2Rows(@CATEGORY_GROUP,@Delimiter)  
   
Create Table #tempCategoryName (Category_Name NVarChar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS,GroupName nvarchar(255),CombinedGroupName NVarChar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS)  

Create Table #CategoryDetails(CatID int,GroupName nvarchar(255),CombinedGroupName nvarchar(max))
Insert into #CategoryDetails Select * from dbo.fn_GetCGFrmCGtype_Itc_RPT('%', @Hierarchy, @CategoryGrouptype,@InvFromDate,@InvToDate,default)
      
If @CATEGORY = '%'  
 Insert Into #tempCategoryName(Category_Name) Select Category_Name From ItemCategories where CategoryId in ( select CatId from #CategoryDetails) --dbo.fn_GetCGFrmCGtype_Itc_RPT('%', @Hierarchy, @CategoryGrouptype,@InvFromDate,@InvToDate, default))  
Else  
 Insert Into #tempCategoryName(Category_Name) Select * From DBO.sp_SplitIn2Rows(@CATEGORY,@Delimiter)  

update T set GroupName=Fn.GroupName,CombinedGroupName=FN.CombinedGroupName From #tempCategoryName T,#CategoryDetails FN,ItemCategories IC  
where FN.CatID=IC.CategoryID  
And IC.Category_Name=T.Category_Name  
If @Hierarchy = 'Division' 
Begin  
	Update T set GroupName=pcga.GroupName,CombinedGroupName=pcga.GroupName From #tempCategoryName T,tblcgdivmapping cgdm, ProductCategoryGroupAbstract pcga, ItemCategories icat  
	Where cgdm.CategoryGroup = pcga.GroupName And cgdm.Division = icat.Category_Name  
	And T.Category_Name=icat.Category_Name  
	And isnull(T.GroupName,'') = ''  
End

Else If @Hierarchy = 'Sub_category' 
Begin  
	Update T set GroupName=pcga.GroupName,CombinedGroupName=pcga.GroupName From #tempCategoryName T,tblcgdivmapping cgdm, ProductCategoryGroupAbstract pcga, ItemCategories IC2,ItemCategories IC3  
	Where cgdm.CategoryGroup = pcga.GroupName And cgdm.Division = iC2.Category_Name  
	And T.Category_Name=IC3.Category_Name  
	And IC3.ParentID=IC2.CategoryID
	And isnull(T.GroupName,'') = ''  
End
Else If @Hierarchy = 'Market_SKU' 
Begin  
	Update T set GroupName=pcga.GroupName,CombinedGroupName=pcga.GroupName From #tempCategoryName T,tblcgdivmapping cgdm, ProductCategoryGroupAbstract pcga, ItemCategories IC2,ItemCategories IC3,ItemCategories IC4
	Where cgdm.CategoryGroup = pcga.GroupName And cgdm.Division = iC2.Category_Name  
	And T.Category_Name=IC4.Category_Name  
	And IC3.ParentID=IC2.CategoryID
	And IC4.ParentID=IC3.CategoryID
	And isnull(T.GroupName,'') = ''  
End

Create Table #tempItemhierarchy (HierarchyID int)  
      
If @Hierarchy = '%'  
 Insert Into #tempItemhierarchy Select HierarchyID From Itemhierarchy  
Else  
 Insert Into #tempItemhierarchy  
 select HierarchyID From Itemhierarchy  
 where HierarchyName  = @Hierarchy  
        
-- Category Group Handling based on the CategoryGroup definition  
  
Declare @TempCGCatMapping Table (GroupID Int, Product_Code nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,  
CategoryID Int, CategoryName nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)  
  
Insert InTo @TempCGCatMapping  
Select "GroupID" = pcga.GroupID, "GroupName" = cgdm.CategoryGroup,  
"CategoryID" = icat.CategoryID, "CategoryName" = cgdm.Division  
From tblcgdivmapping cgdm, ProductCategoryGroupAbstract pcga, ItemCategories icat  
Where cgdm.CategoryGroup = pcga.GroupName And cgdm.Division = icat.Category_Name  
  
Create Table #tempCategory(CategoryID int)  
--Filter #tempCategory for Category group  
insert into #tempCategory  
select distinct ItemCategories.CategoryID  
from ProductCategorygroupAbstract,@TempCGCatMapping As ProductCategorygroupDetail,ItemCategories  
Where productcategorygroupabstract.GroupID = productcategorygroupdetail.GroupID  
and  ProductCategorygroupDetail.CategoryID = ItemCategories.CategoryID  
and ProductCategorygroupAbstract.GroupName In (Select CategoryGroup COLLATE SQL_Latin1_General_CP1_CI_AS From #tempCategoryGroup)  
  
--Get the leaf categories for the paraent categories  
Create Table #tempCategoryTree(initParentCategoryID int,CategoryID int,HierarchyID int)  
      
DECLARE initParentCategory CURSOR KEYSET FOR  
SELECT CategoryID from #tempCategory  
Open  initParentCategory  
Fetch From initParentCategory into @CategoryID  
WHILE @@FETCH_STATUS = 0  
BEGIN  
     insert into #tempCategoryTree  
     select @CategoryID,* from sp_get_Catergory_RootToChild(@CategoryID)  
     Fetch next From initParentCategory into @CategoryID  
End  
Deallocate initParentCategory  
  
  
--Get the leaf categories for the parent categories for Category parameter  
Create Table #tempCategory2(CategoryID int)  
If @CATEGORY = '%'  
   insert into #tempCategory2  
   Select * From dbo.fn_GetCatFrmCG_ITC_OCG(@CATEGORY_GROUP,@Hierarchy,@Delimiter,'%')  
Else  
   insert into #tempCategory2  
   Select CategoryID From itemcategories  
   where category_Name in(Select * From DBO.sp_SplitIn2Rows(@CATEGORY,@Delimiter))  
  
      
Create Table #tempCategoryTree2(initParentCategoryID int, CategoryID int, HierarchyID int)  
  
DECLARE initParentCategory CURSOR KEYSET FOR  
SELECT CategoryID from #tempCategory2  
Open  initParentCategory  
Fetch From initParentCategory into @CategoryID  
WHILE @@FETCH_STATUS = 0  
BEGIN  
     insert into #tempCategoryTree2  
     select @CategoryID,* from sp_get_Catergory_RootToChild(@CategoryID)  
     Fetch next From initParentCategory into @CategoryID  
End  
Deallocate initParentCategory  
--Filter According to Hierarchy and Category  
delete from #tempCategoryTree  
where #tempCategoryTree.CategoryID not In (select categoryid from #tempCategoryTree2)  


      
Create table #TempCategory1(IDS Int Identity(1,1), CategoryID Int,Category NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Status Int)  
      
--Get the Category Name for each item at the selected Hierarchy  
create table #tmpItems  
(Product_Code NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 Productname NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,CategoryID int default 0,  
 UOM1_Conversion Decimal(18,6) Default 0,UOM2_Conversion Decimal(18,6) Default 0,  
 HierarchyCatName NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS default N'',  
HierarchyCatID int default 0)  
      
Declare @HierarchyLevel int  
Declare @CntHierarchyLevel int  
select @HierarchyLevel = HierarchyID from Itemhierarchy where HierarchyName = @Hierarchy  
--set @HierarchyLevel = 2  
select  @CntHierarchyLevel = max(HierarchyID) from Itemhierarchy  
      
insert into #tmpItems(Product_Code,Productname,CategoryID,UOM1_Conversion,UOM2_Conversion,HierarchyCatName,  
HierarchyCatID)  
select Items.Product_Code,Items.Productname,Items.CategoryID,Items.UOM1_Conversion,  
       Items.UOM2_Conversion, ItemCategories.Category_Name, ItemCategories.categoryid  
from Items,ItemCategories  
Where Items.categoryid = ItemCategories.categoryid  
      
while @CntHierarchyLevel > @HierarchyLevel  
BEGIN  
    Update #tmpItems  
    set  #tmpItems.CategoryID = Itemcategories.ParentID ,  
         #tmpItems.HierarchyCatName = Itemcategories.ParentCategoryName,  
         #tmpItems.HierarchyCatID = Itemcategories.ParentCategoryID  
    from #tmpItems,  
         (  
             select Itemcategories.Category_Name,Itemcategories.CategoryID,  
                    Itemcategories.ParentID,Itemcategories1.Category_Name as ParentCategoryName,  
                    Itemcategories1.CategoryID as ParentCategoryID  
             from  Itemcategories, Itemcategories as Itemcategories1  
             Where ItemCategories.Parentid = Itemcategories1.categoryid  
                   and Itemcategories.[Level] > @HierarchyLevel  
         ) as Itemcategories  
    where #tmpItems.CategoryID = Itemcategories.CategoryID  
          
    set @CntHierarchyLevel = @CntHierarchyLevel - 1  
End  

delete from #tmpItems where CategoryID <= 0  
      
--Get the catogory table with sort order  
Exec sp_CatLevelwise_ItemSorting  
  
truncate table #tmpItems  

Select Distinct CatId Into #tmpCatId From #CategoryDetails --dbo.fn_GetCGFrmCGtype_Itc_RPT(@Category_Group, @Hierarchy, @CategoryGrouptype,@InvFromDate,@InvToDate,Default)  
If @Hierarchy = 'Division'  
    Insert Into #tmpItems  
    select I.product_code, I.ProductName, CatId, I.uom1_Conversion, I.uom2_Conversion, IC2.Category_Name, CatId  
    from #tmpCatId tC Join ItemCategories IC2 on tC.CatId = IC2.CategoryId  
    Join ItemCategories IC3 on IC2.CategoryId = IC3.ParentId  
    Join ItemCategories IC4 on IC3.CategoryId = IC4.ParentId  
    Join Items I on IC4.CategoryId = I.CategoryId  
Else If @Hierarchy = 'Sub_Category'  
    Insert Into #tmpItems  
    select I.product_code, I.ProductName, CatId, I.uom1_Conversion, I.uom2_Conversion, IC3.Category_Name, CatId  
    from #tmpCatId tC Join ItemCategories IC3 on tC.CatId = IC3.CategoryId  
    Join ItemCategories IC4 on IC3.CategoryId = IC4.ParentId  
    Join Items I on IC4.CategoryId = I.CategoryId  
Else If @Hierarchy = 'Market_SKU'  
    Insert Into #tmpItems  
    select I.product_code, I.ProductName, CatId, I.uom1_Conversion, I.uom2_Conversion, IC4.Category_Name, CatId  
    from #tmpCatId tC Join ItemCategories IC4 on tC.CatId = IC4.CategoryId  
    Join Items I on IC4.CategoryId = I.CategoryId  
  
 
--Find the invoice Payment mode  
set @InvPaymentModeNo = -1  
if @InvPaymentMode = @MLCredit  
     set @InvPaymentModeNo = 0  
if @InvPaymentMode = @MLCash  
     set @InvPaymentModeNo = 1  
Else if @InvPaymentMode = @MLCheque  
     set @InvPaymentModeNo = 2  
if @InvPaymentMode = @MLDD  
     set @InvPaymentModeNo = 3  
      
--Find the Collection Payment mode [cash - 0/CHEQUE - 1/DD - 2/Credit Card - 3/Bank Transfer - 4/Coupon - 5/CrediNote - 6/GiftVoucher - 7]  
set @CollPaymentModeNo = -1  
if @CollPaymentMode = @MLCash  
     set @CollPaymentModeNo = 0  
else if @CollPaymentMode = @MLCheque  
     set @CollPaymentModeNo = 1  
else if @CollPaymentMode = @MLDD  
     set @CollPaymentModeNo = 2  
Else if @CollPaymentMode = @MLBankTransfer  
     set @CollPaymentModeNo = 4  
      
--Get the Abstract data's  
create table #tempCollAbstract  
(  
CollectionID int,SalesmanID int default 0, BeatID int default 0,  
CustomerID NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS default '',  
Salesman_Name NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS default '',  
Beat NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS default '',  
TotalCollection decimal(18,6) default 0,  
AdvancedCollection decimal(18,6) default 0,  
PaymentMode Int default 0,  
Realised Int default 0,  
RealisedDate DateTime  
)  
if @CollPaymentModeNo = -1  
   insert into #tempCollAbstract  
   Select Collections.Documentid as CollectionID,Salesman.SalesmanID, Beat.BeatID, Collections.CustID,  
          IsNull(Salesman.Salesman_Name, @OTHERS) as Salesman_Name,  
          IsNull(Beat.[Description], @OTHERS) as Beat,sum(Value) as TotalCollection,  
          sum(Balance) as AdvancedCollection, IsNull(Collections.PaymentMode, 0) as PaymentMode,  
          IsNull(Realised, 0) as Realised,  
          isnull(RealisationDate,getdate()) as RealisedDate  
   From (select Collections.*, Customer.CustomerID as CustID  
         From Collections, Customer  
         where Collections.CustomerID = Customer.CustomerID) as collections
		 Left Outer Join salesman On Collections.SalesmanID = Salesman.SalesmanID
		 Left Outer Join Beat  On Collections.BeatID = Beat.BeatID  
   Where Collections.DocumentDate between @CollFromDate And @CollToDate  
         And IsNull(Collections.DocSerialType, '') Like @DocType  
         And (IsNull(Collections.Status,0) & 128) = 0  
         and (IsNull(Collections.Status,0) & 64) = 0  
--           and Collections.Paymentmode = @CollPaymentMode  
         and Collections.CustomerID is Not Null  
         And Collections.Value >= 0 --to exclude invoice adjustments with credit payment mode  
and salesman.Salesman_Name in (select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tempSalesMan)  
         and Beat.[Description] in (select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tempBeat)  
   group by  Collections.Documentid,Salesman.SalesmanID, Beat.BeatID,  
          Salesman.Salesman_Name, Beat.[Description], Collections.CustID, IsNull(Collections.PaymentMode, 0),  
          IsNull(Realised, 0),isnull(RealisationDate,getdate())  
Else  
   insert into #tempCollAbstract  
   Select Collections.Documentid as CollectionID,Salesman.SalesmanID, Beat.BeatID, Collections.CustID,  
          IsNull(Salesman.Salesman_Name, @OTHERS) as Salesman_Name,  
          IsNull(Beat.[Description], @OTHERS) as Beat,sum(Value) as TotalCollection,  
          sum(Balance) as AdvancedCollection, IsNull(Collections.PaymentMode, 0) as PaymentMode,  
          IsNull(Realised, 0) as Realised,  
          isnull(RealisationDate,getdate()) as RealisedDate  
   From (select Collections.*, Customer.CustomerID as CustID  
         From Collections, Customer  
         where Collections.CustomerID = Customer.CustomerID) as collections
		 Left Outer Join salesman On Collections.SalesmanID = Salesman.SalesmanID 
		 Left Outer Join Beat  On  Collections.BeatID = Beat.BeatID  
   Where  Collections.DocumentDate between @CollFromDate And @CollToDate  
         And IsNull(Collections.DocSerialType, '') Like @DocType  
         And (IsNull(Collections.Status,0) & 128) = 0  
         and (IsNull(Collections.Status,0) & 64) = 0  
         and Collections.Paymentmode = @CollPaymentModeNo  
         and Collections.CustomerID is Not Null  
         And Collections.Value >= 0 --to exclude invoice adjustments with credit payment mode  
         and salesman.Salesman_Name in (select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tempSalesMan)  
         and Beat.[Description] in (select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tempBeat)  
   group by  Collections.Documentid,Salesman.SalesmanID, Beat.BeatID,  
          Salesman.Salesman_Name, Beat.[Description], Collections.CustID, IsNull(Collections.PaymentMode, 0),  
          IsNull(Realised, 0),isnull(RealisationDate,getdate())  
  
create table #tmpInvoiceAbstract  
(  
InvoiceID int,SalesmanID int default 0, BeatID int default 0,  
Salesman_Name NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS default '',  
Beat NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS default '',  
InvoiceAdjustments decimal(18,6) default 0,  
AddlDiscountValue decimal(18,6) default 0,  
DiscountValue decimal(18,6) default 0,  
InvAmount decimal(18,6) default 0  
)  
if @InvPaymentModeNo = -1  
    insert into #tmpInvoiceAbstract  
    Select InvoiceAbstract.InvoiceID,Salesman.SalesmanID, Beat.BeatID,  
           Salesman.Salesman_Name, Beat.[Description] as Beat,  
           Sum(Isnull(Invoiceabstract.AdjustedAmount,0)) as InvoiceAdjustments,  
           Sum(Isnull(Invoiceabstract.AddlDiscountValue,0)) as AddlDiscountValue,  
           Sum(Isnull(Invoiceabstract.DiscountValue,0)) as DiscountValue,  
           Sum(Isnull(Invoiceabstract.NetValue,0)) as Amount  
    From InvoiceAbstract,Customer,salesman,Beat  
    Where InvoiceAbstract.CustomerID = Customer.CustomerID  
          and InvoiceAbstract.InvoiceDate Between @InvFromDate AND @InvToDate  
          and InvoiceAbstract.Status & 128 = 0  
          and InvoiceAbstract.InvoiceType in (1,3)  
--           and InvoiceAbstract.Paymentmode = @InvPaymentModeNo  
          and InvoiceAbstract.SalesmanID = salesman.SalesmanID  
          and InvoiceAbstract.BeatID = Beat.BeatID  
          and salesman.Salesman_Name in (select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tempSalesMan)  
          and Beat.[Description] in (select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tempBeat)  
          and Invoiceabstract.NetValue >0  
     group by InvoiceAbstract.InvoiceID,Salesman.SalesmanID, BEat.BeatID,Salesman.Salesman_Name, Beat.[Description]  
Else  
    insert into #tmpInvoiceAbstract  
    Select InvoiceAbstract.InvoiceID,Salesman.SalesmanID, Beat.BeatID,  
           Salesman.Salesman_Name, Beat.[Description] as Beat,  
           Sum(Isnull(Invoiceabstract.AdjustedAmount,0)) as InvoiceAdjustments,  
           Sum(Isnull(Invoiceabstract.AddlDiscountValue,0)) as AddlDiscountValue,  
           Sum(Isnull(Invoiceabstract.DiscountValue,0)) as DiscountValue ,  
           sum(isnull(InvoiceAbstract.NetValue,0)) as Amount  
    From InvoiceAbstract,customer,salesman,Beat  
    Where InvoiceAbstract.CustomerID = Customer.CustomerID  
          and InvoiceAbstract.InvoiceDate Between @InvFromDate AND @InvToDate  
          and InvoiceAbstract.Status & 128 = 0  
          and InvoiceAbstract.InvoiceType in (1,3)  
          and InvoiceAbstract.Paymentmode = @InvPaymentModeNo  
          and InvoiceAbstract.SalesmanID = salesman.SalesmanID  
          and InvoiceAbstract.BeatID = Beat.BeatID  
          and salesman.Salesman_Name in (select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tempSalesMan)  
          and Beat.[Description] in (select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tempBeat)  
          and Invoiceabstract.NetValue >0  
     group by InvoiceAbstract.InvoiceID,Salesman.SalesmanID, BEat.BeatID,Salesman.Salesman_Name, Beat.[Description]  
  
--Get the CollectionDetail and Invoicebased data  
---------------------------------------------------------  
-- 1  
Create table #ItmCatOne( IDS Int Identity(1,1), CategoryId Int, CategoryName nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS,  
    GroupName nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS, GroupId Int)  
  
If @CategoryGrouptype = 'Regular'  
BEGIN  
    Insert Into #ItmCatOne( CategoryId, CategoryName, GroupName, GroupId )  
    select "CategoryID" = ItemCategories.CategoryID,  
           "Category" = ItemCategories.Category,  
           "GroupName" = isnull(productcategorygroupabstract.GroupName,'') ,  
           "GroupID" = isnull(productcategorygroupabstract.GroupID,'')  
    from productcategorygroupabstract, @TempCGCatMapping As productcategorygroupdetail,  
        (  
            select #TempCategory1.IDS,#TempCategory1.CategoryID,#TempCategory1.Category,  
                   tempCategoryTree.initParentCategoryID  
            from #TempCategory1, #tempCategoryTree as tempCategoryTree  
            where #TempCategory1.CategoryID = tempCategoryTree.CategoryID  
        ) ItemCategories  
    where ItemCategories.initParentCategoryID = productcategorygroupdetail.CategoryId  
          and productcategorygroupabstract.GroupID = productcategorygroupDetail.GroupID  
    group by ItemCategories.IDS,ItemCategories.CategoryID,ItemCategories.Category,  
              productcategorygroupabstract.GroupName,productcategorygroupabstract.GroupID  
End  
Else  
BEGIN  
    truncate table #ItmCatOne  
    DECLARE GetGrpName CURSOR KEYSET FOR SELECT CategoryGroup from #tempCategoryGroup  
    Open GetGrpName  
    Fetch From GetGrpName into @GroupName  
    WHILE @@FETCH_STATUS = 0  
    BEGIN  
        Select @GroupId = GroupId from ProductCategoryGroupabstract where GroupName = @GroupName  
        Insert Into #ItmCatOne( CategoryId, CategoryName, GroupName, GroupId )  
        Select distinct  
            Case @Hierarchy  
                when 'Division' then IC2.CategoryID  
                when 'Sub_Category' Then IC3.CategoryID  
                when 'Market_SKU' Then IC4.CategoryID  
            End, (select Category_name from Itemcategories where CategoryId = Case @Hierarchy  
                when 'Division' then IC2.CategoryID  
                when 'Sub_Category' Then IC3.CategoryID  
                when 'Market_SKU' Then IC4.CategoryID  
                End), @GroupName, @GroupId  
        from ItemCategories IC4, ItemCategories IC3, ItemCategories IC2, dbo.Fn_GetOCGSKU(@GroupId) FN where  
        FN.categoryid = IC4.categoryid And IC4.Parentid = IC3.categoryid And IC3.Parentid = IC2.categoryid  
  
        Fetch From GetGrpName into @GroupName  
    End  
    Close GetGrpName  
    Deallocate GetGrpName  
End  
  
-- 2  
Select InvoiceDetail.InvoiceID,ItemCategories.IDS,ItemCategories.GroupName as Category_Name,  
      items.HierarchyCatName,items.HierarchyCatID,ItemCategories.GroupID,Items.Product_Code,  
      sum(InvoiceDetail.Amount) as ItemNetAmt,sum(InvoiceDetail.Saleprice) as  Saleprice  
Into #InvDetlOne  
From InvoiceDetail, #tmpItems as Items, #ItmCatOne as ItemCategories  
  
Where  
    InvoiceDetail.Product_Code = Items.Product_Code  
    and Items.CategoryID = ItemCategories.CategoryID  
    and invoicedetail.InvoiceID in (Select distinct invoiceid from #tmpInvoiceAbstract)  
Group by InvoiceDetail.InvoiceID,ItemCategories.IDS,ItemCategories.GroupName,  
      items.HierarchyCatName,items.HierarchyCatID,ItemCategories.GroupID,Items.Product_Code  
  
-- 3  
  
select InvoiceAbstract.InvoiceID,InvoiceDetail.IDS,InvoiceDetail.Category_Name,InvoiceDetail.HierarchyCatName,  
       InvoiceAbstract.SalesmanID, InvoiceAbstract.BeatID,InvoiceAbstract.InvoiceAdjustments,  
       InvoiceAbstract.AddlDiscountValue,InvoiceAbstract.DiscountValue,  
       InvoiceDetail.HierarchyCatID,InvoiceDetail.GroupID,  
       InvoiceAbstract.Salesman_Name, InvoiceAbstract.Beat,  
       sum(ItemNetAmt/InvoiceAbstract.InvAmount) As ItemInvProportion  
Into #InvDataOne  
From  
  
             
     (  
          select #tmpInvoiceAbstract.InvoiceID,#tmpInvoiceAbstract.SalesmanID, #tmpInvoiceAbstract.BeatID,  
                 #tmpInvoiceAbstract.Salesman_Name, #tmpInvoiceAbstract.Beat,  
                 #tmpInvoiceAbstract.InvoiceAdjustments, #tmpInvoiceAbstract.AddlDiscountValue,  
                 #tmpInvoiceAbstract.DiscountValue, #tmpInvoiceAbstract.InvAmount  
          from #tmpInvoiceAbstract  
     )InvoiceAbstract,  #InvDetlOne as InvoiceDetail  
  
  Where InvoiceAbstract.Invoiceid = InvoiceDetail.Invoiceid  
        and InvoiceDetail.Saleprice>0 --Avoid diff product scheme applied free items  
  Group by InvoiceAbstract.InvoiceID,InvoiceDetail.IDS,InvoiceDetail.Category_Name,InvoiceDetail.HierarchyCatName,  
        InvoiceAbstract.SalesmanID, InvoiceAbstract.BeatID,InvoiceAbstract.InvoiceAdjustments,  
        InvoiceAbstract.AddlDiscountValue,InvoiceAbstract.DiscountValue,  
        InvoiceAbstract.Salesman_Name, InvoiceAbstract.Beat,  
        InvoiceDetail.HierarchyCatID,InvoiceDetail.GroupID      
  
-- 4  
  select CollectionDetail.CollectionID,CollectionDetail.DocumentID as CollDocumentID,  
         #tempCollAbstract.SalesmanID, #tempCollAbstract.BeatID,  
         Sum(AdjustedAmount) as AdjustedAmount,  
--                  0 as AdjustedAmount,  
         sum(ExtraCollection) as ExtraCollection,  
--                  sum(Adjustment) as  WriteOffAmount,  
--                  sum(((CollectionDetail.Discount/100)*CollectionDetail.DocumentValue) - Adjustment) as  CollDiscount  
         sum( case when CollectionDetail.Discount in (0) then Adjustment else Adjustment - ( (CollectionDetail.Discount/100)*CollectionDetail.DocumentValue)end)  as  WriteOffAmount,  
         sum( case when CollectionDetail.Discount in (0) then 0 else ( (CollectionDetail.Discount/100)*CollectionDetail.DocumentValue) end)  as  CollDiscount,  
         (IsNull(Sum(AdjustedAmount),0)-IsNull(Sum(DocAdjustAmount),0)) as ChqAmt,  
         Max(PaymentMode) as PaymentMode, Max(Realised) as Realised, Max(RealisedDate) as RealisedDate  
    Into #tmpColDtOne  
  from CollectionDetail, #tempCollAbstract  
  where CollectionDetail.CollectionID =  #tempCollAbstract.CollectionID  
        and CollectionDetail.DocumentType in (4)  
  group by CollectionDetail.CollectionID,CollectionDetail.DocumentID,  
         #tempCollAbstract.SalesmanID, #tempCollAbstract.BeatID  
  
-- 5  
  select InvoiceData.IDS,InvoiceData.InvoiceID,InvoiceData.Category_Name,InvoiceData.HierarchyCatName,  
         InvoiceData.HierarchyCatID,InvoiceData.GroupID,  
         InvoiceData.Salesman_Name, InvoiceData.Beat,  
         InvoiceData.SalesmanID, InvoiceData.BeatID,sum(InvoiceData.InvoiceAdjustments) as InvoiceAdjustments,  
         sum(InvoiceData.AddlDiscountValue) as AddlDiscountValue,  
         sum(InvoiceData.DiscountValue) as DiscountValue,sum(ItemInvProportion) as  ItemInvProportion  
    Into #tmpColInvDataOne  
  from     #InvDataOne as InvoiceData  
  group by InvoiceData.IDS,InvoiceData.InvoiceID,InvoiceData.Category_Name,  
           InvoiceData.Salesman_Name, InvoiceData.Beat,  
           InvoiceData.HierarchyCatName, InvoiceData.SalesmanID, InvoiceData.BeatID,  
           InvoiceData.SalesmanID, InvoiceData.BeatID ,InvoiceData.HierarchyCatID,InvoiceData.GroupID    
  

---------------------------------------------------------  
  
select *  into #tmpCollInvoiceData from  
(  
      Select tmpCollDetail.CollectionID,tmpCollDetail.CollDocumentID,  
             isnull(tmpInvoice.IDS,0) asIDS ,isnull(tmpInvoice.InvoiceID,0) as InvoiceID,  
             isnull(tmpInvoice.Category_Name,'') as CategoryGroupName,  
             isnull(tmpInvoice.HierarchyCatName,'') as HierarchyCatName,  
             tmpInvoice.Salesman_Name, tmpInvoice.Beat,tmpInvoice.SalesmanID, tmpInvoice.BeatID,  
             tmpInvoice.HierarchyCatID,tmpInvoice.GroupID,  
             sum(ItemInvProportion*tmpCollDetail.ExtraCollection) as ExtraCollection,  
             sum(ItemInvProportion*tmpCollDetail.WriteOffAmount) as WriteOffAmount,  
             sum(ItemInvProportion*tmpInvoice.InvoiceAdjustments) as InvoiceAdjustments,  
             sum(ItemInvProportion*tmpInvoice.AddlDiscountValue) as AddlDiscountValue,  
             sum(ItemInvProportion*tmpInvoice.DiscountValue) as DiscountValue,  
             sum(ItemInvProportion*AdjustedAmount) as ProCollAmt,  
             sum(ItemInvProportion*CollDiscount) as CollDiscount,  
             sum(ItemInvProportion* (Case PaymentMode When 1 Then  
            (Case Realised When 1 Then (Case when @CollToDate < RealisedDate  
            then ChqAmt Else 0 End) When 2 Then 0 When 3 Then (dbo.mERP_fn_getCollBalance_ITC_Rpt(IsNull(InvoiceID, 0), 4,@CollToDate,tmpCollDetail.CollectionID,GetDate())) Else ChqAmt End)  
            Else 0 End)) as ProChqInHand  
      from  #tmpColDtOne as tmpCollDetail, #tmpColInvDataOne as tmpInvoice  
      Where tmpCollDetail.CollDocumentID = tmpInvoice.Invoiceid  
      group by tmpCollDetail.CollectionID,tmpCollDetail.CollDocumentID,  
             tmpInvoice.Salesman_Name, tmpInvoice.Beat,tmpInvoice.SalesmanID, tmpInvoice.BeatID,  
             isnull(tmpInvoice.IDS,0),isnull(tmpInvoice.InvoiceID,0),  
             isnull(tmpInvoice.Category_Name,''),isnull(tmpInvoice.HierarchyCatName,''),  
             tmpInvoice.HierarchyCatID,tmpInvoice.GroupID      
) tmpCollInvoiceData  
  

-------------------------------  
-- 1  
select Salesman_Name,Beat, sum(isnull([Advanced collection],0)) as [Advanced collection]  
Into #tmOneOne  
From  
(  
      select #tempCollAbstract.Salesman_Name,#tempCollAbstract.Beat, sum(isnull(#tempCollAbstract.Advancedcollection,0)) as [Advanced collection]  
      from #tempCollAbstract,#tmpCollInvoiceData  
      where #tempCollAbstract.CollectionID = #tmpCollInvoiceData.CollectionID  
      group by #tempCollAbstract.Salesman_Name,#tempCollAbstract.Beat  
      Union All  
      -- Pure advanced collection  
      select #tempCollAbstract.Salesman_Name,#tempCollAbstract.Beat, sum(isnull(#tempCollAbstract.Advancedcollection,0)) as [Advanced collection]  
      from #tempCollAbstract  
      where #tempCollAbstract.CollectionID not in  
      (  
           select CollectionID from collectionDetail  
   )  
      group by #tempCollAbstract.Salesman_Name,#tempCollAbstract.Beat  
 ) tmp2  
 group by Salesman_Name,Beat  
  
-- 2  
 Select * into #tmtwoOne from   
 (  
    select "KEYPARAM" =  cast(isnull(#tmpCollInvoiceData.SalesmanID,0) as varchar(10)) + @Delimiter + cast(isnull(#tmpCollInvoiceData.BeatID,0) as varchar(10)) + @Delimiter + cast(isnull(#tmpCollInvoiceData.GroupID,0) as varchar(10)) + 
@Delimiter + cast(isnull(#tmpCollInvoiceData.HierarchyCatID,0) as varchar(10)),  
     "DS Name" = #tmpCollInvoiceData.Salesman_Name,  
     "Beat" = #tmpCollInvoiceData.Beat,  
     "Category Group" = T.CombinedGroupName,  
     "Category" = #tmpCollInvoiceData.HierarchyCatName,  
     "Total Collection (%c)" = Sum(#tmpCollInvoiceData.ProCollAmt),  
     "Extra Collection (%c)" = Sum(#tmpCollInvoiceData.ExtraCollection),  
    --        "Invoice Adjustment" = Sum(#tmpCollInvoiceData.InvoiceAdjustments),  
     "Write Off (%c)" = Sum(#tmpCollInvoiceData.WriteOffAmount),  
     "Total Discount Amount (%c)" = Sum(#tmpCollInvoiceData.AddlDiscountValue + #tmpCollInvoiceData.DiscountValue + #tmpCollInvoiceData.CollDiscount),  
     "Cheque on Hand (%c)" = Sum(#tmpCollInvoiceData.ProChqInHand)  
    from #tempCollAbstract, #tmpCollInvoiceData,#tempCategoryName T  
    where #tempCollAbstract.CollectionID = #tmpCollInvoiceData.CollectionID  
  And  #tmpCollInvoiceData.CategoryGroupName =T.GroupName  
  And #tmpCollInvoiceData.HierarchyCatName =T.Category_Name  
    group by #tmpCollInvoiceData.SalesmanID,#tmpCollInvoiceData.BeatID,#tmpCollInvoiceData.Salesman_Name, #tmpCollInvoiceData.Beat,  
     #tmpCollInvoiceData.CategoryGroupName, #tmpCollInvoiceData.HierarchyCatName,  
     #tmpCollInvoiceData.HierarchyCatID,#tmpCollInvoiceData.GroupID,T.CombinedGroupName  
 ) t1,  
 (  
 -- select distinct cast(isnull(#tmpCollInvoiceData.SalesmanID,0) as varchar(10)) + @Delimiter + cast(isnull(#tmpCollInvoiceData.BeatID,0) as varchar(10)) + @Delimiter + cast(isnull(#tmpCollInvoiceData.GroupID,0) as varchar(10)) + @Delimiter + cast(isnull(#tmpCollInvoiceData.HierarchyCatID,0) as varchar(10)) as [KeyParam1],  
 --       #tmpCollInvoiceData.InvoiceAdjustments as [Invoice Adjustment]  
 --from #tmpCollInvoiceData  
 select temp3.[KeyParam1],sum(temp3.[Invoice Adjustment]) as [Invoice Adjustment] from (select distinct cast(isnull(#tmpCollInvoiceData.SalesmanID,0) as varchar(10)) + @Delimiter + cast(isnull(#tmpCollInvoiceData.BeatID,0) as varchar(10)) + @Delimiter + 
cast(isnull(#tmpCollInvoiceData.GroupID,0) as varchar(10)) + @Delimiter + cast(isnull(#tmpCollInvoiceData.HierarchyCatID,0) as varchar(10)) as [KeyParam1],  
 #tmpCollInvoiceData.InvoiceAdjustments as [Invoice Adjustment]  
 from #tmpCollInvoiceData) temp3 group by  temp3.[KeyParam1]  
 ) t2  
 Where t1.KEYPARAM = t2.KEYPARAM1  
  
select  
       "KEYPARAM" = tmp2.[KEYPARAM],  
       "DS Name" = tmp2.[DS Name],  
       "Beat" = tmp2.[Beat],  
       "Category Group" = tmp2.[Category Group],  
       "Category" = tmp2.[Category],  
       "Total Collection (%c)" = tmp2.[Total Collection (%c)],  
       "Extra Collection (%c)" = tmp2.[Extra Collection (%c)],  
       "Invoice Adjustment" = tmp2.[Invoice Adjustment],  
       "Write Off (%c)" = tmp2.[Write Off (%c)],  
       "Total Discount Amount (%c)" = tmp2.[Total Discount Amount (%c)],  
       "Advanced collection" = isnull(tmp1.[Advanced collection],0),  
       "Cheque on Hand (%c)" = tmp2.[Cheque on Hand (%c)]--(Select dbo.mERP_fn_GetChequesInfo_ITC(tmp2.[DS Name],tmp2.[Beat], tmp2.[Category]))Into #tempresult  
from  #tmOneOne as tmp1
Left Outer Join #tmtwoOne as tmp2  On tmp2.[DS Name] = tmp1.Salesman_Name  and  tmp2.[Beat] = tmp1.Beat  
--Select * from #tempresult  
-- AdvancedCollection  
----Drop Tables  
      
drop table #tempSalesMan  
drop table #tempBeat  
drop table #tmpCollInvoiceData  
drop table #tempCategory  
drop table #tempCategoryGroup  
drop table #tempCategoryName  
drop table #tempItemhierarchy  
drop table #tempCategoryTree  
drop table #TempCategory1  
drop table #tempCategory2  
drop table #tempCategoryTree2  
drop table #tmpItems  
drop table #tempCollAbstract  
drop table #tmpInvoiceAbstract  
drop table #ItmCatOne  
drop table #InvDetlOne  
drop table #InvDataOne  
drop table #tmpColDtOne  
drop table #tmpColInvDataOne  
drop table #tmOneOne  
drop table #tmtwoOne  
Drop Table #CategoryDetails  
Handler:  
