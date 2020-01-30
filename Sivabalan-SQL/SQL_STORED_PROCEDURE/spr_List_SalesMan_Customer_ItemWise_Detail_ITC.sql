CREATE Procedure spr_List_SalesMan_Customer_ItemWise_Detail_ITC
(
@KEYPARAM nVarchar(4000),
@CATEGORY_GROUP nVarchar(4000),
@Hierarchy NVARCHAR(50),
@CATEGORY NVARCHAR(4000),
@UOM nVarChar(100),
@DetailedAt nVarchar(50),
@ItemwiseOnly nVarchar(50),
@DSwise nVarchar(50),
@BeatName nVarchar(4000),
@Customerwise nVarchar(50),
@Datewise nVarchar(50),
@FROMDATE DATETIME,
@TODATE DATETIME,
@LevelOfReport nVarchar(50)
)
AS
begin

DECLARE @Delimiter as Char(1)
Declare @tempString as nVarchar(1000)
Declare @ParamSepcounter int
DECLARE @RptType as varchar(1)
DECLARE @SalesMan_Name as nvarchar(100)
DECLARE @Company_Name as nvarchar(300)
DECLARE @Beat as nvarchar(510)
DECLARE @InvoiceDate as datetime
DECLARE @InvoiceNo as nvarchar(15)
Declare @Gstflag as int
Declare @gstfulldocid as nvarchar(500)
DECLARE @CategoryID as int
DECLARE @IDSSubTotal as int
DECLARE @IDSGrandTotal as int
DECLARE @GrandName as nvarchar(300)

--If hierarchy parameter deleted then make the second level as hierarchy by default
if @Hierarchy  = '%' or @Hierarchy  = 'Division'
select @Hierarchy = HierarchyName from itemhierarchy where hierarchyid = 2

--If @UOM parameter deleted then make the Base UOM by default
if @UOM  = '%'
set @UOM  = 'Base UOM'
--If @DetailedAt parameter deleted then make the "Item" by default
if @DetailedAt  = '%'
set @DetailedAt  = 'Item'
--If @ItemwiseOnly parameter deleted then make the "Yes" by default
if @ItemwiseOnly  = '%'
set @ItemwiseOnly  = 'Yes'
--If @DSwise parameter deleted then make the "N/A" by default
if @DSwise  = '%'
set @DSwise  = 'N/A'
--If @Beat parameter deleted then make the "N/A" by default
if @Beat  = '%'
set @Beat  = 'N/A'
--If @Customerwise parameter deleted then make the "N/A" by default
if @Customerwise  = '%'
set @Customerwise  = 'N/A'
--If @Datewise parameter deleted then make the "N/A" by default
if @Datewise  = '%'
set @Datewise  = 'N/A'
--If @LevelOfReport parameter deleted then make the "N/A" by default
if @LevelOfReport  = '%'
set @LevelOfReport  = 'All'

Set @tempString = @KEYPARAM
SET @Delimiter=Char(15)
set @IDSSubTotal = 2147483646 --2147483647 is the maximum positive number in int data type
set @IDSGrandTotal = 2147483647 --2147483647 is the maximum positive number in int data type
set @GrandName = 'ZZZZZ'

Create Table #tempCategoryGroup (CategoryGroup NVarChar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS)

If @CATEGORY_GROUP = '%'
Insert Into #tempCategoryGroup Select GroupName From productcategorygroupabstract
Else
Insert Into #tempCategoryGroup Select * From DBO.sp_SplitIn2Rows(@CATEGORY_GROUP,@Delimiter)

Create Table #tempCategoryName (Category_Name NVarChar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS)

If @CATEGORY = '%'
Insert Into #tempCategoryName Select Category_Name From ItemCategories
Else
Insert Into #tempCategoryName Select * From DBO.sp_SplitIn2Rows(@CATEGORY,@Delimiter)

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
from ProductCategorygroupAbstract, @TempCGCatMapping As ProductCategorygroupDetail,ItemCategories
where ProductCategorygroupAbstract.groupid = ProductCategorygroupDetail.groupid
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
END
Deallocate initParentCategory

--Get the leaf categories for the parent categories for Category parameter
Create Table #tempCategory2(CategoryID int)
If @CATEGORY = '%'
insert into #tempCategory2
Select * From dbo.fn_GetCatFrmCG_ITC(@CATEGORY_GROUP,@Hierarchy,@Delimiter)
else
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
END
Deallocate initParentCategory


--Filter According to Hierarchy and Category
delete from #tempCategoryTree
where #tempCategoryTree.CategoryID not In (select categoryid from #tempCategoryTree2)

Create table #TempCategory1(IDS Int Identity(1,1), CategoryID Int,Category NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Status Int)

--If the Detailed at parameter is Category the  n get the Category Name for each item at the selected Hierarchy

create table #tmpItems
(Product_Code NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Productname NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,CategoryID int default 0,
HierarchyCatID int default 0,HierarchyCatLevel int default 0,
UOM1_Conversion Decimal(18,6) Default 0,UOM2_Conversion Decimal(18,6) Default 0,
HierarchyCatName NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS default N'',
HierarchyCatName1 NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS default N'')
if @DetailedAt = 'Item'
insert into #tmpItems(Product_Code,Productname,CategoryID,UOM1_Conversion,UOM2_Conversion)
select Product_Code,Productname,CategoryID,UOM1_Conversion,UOM2_Conversion from Items
else if @DetailedAt = 'Category'
Begin
Declare @HierarchyLevel int
Declare @CntHierarchyLevel int
select @HierarchyLevel = HierarchyID from Itemhierarchy where HierarchyName = @Hierarchy
--set @HierarchyLevel = 2
select  @CntHierarchyLevel = max(HierarchyID) from Itemhierarchy

insert into #tmpItems(Product_Code,Productname,CategoryID,HierarchyCatID,HierarchyCatLevel,
UOM1_Conversion,UOM2_Conversion,HierarchyCatName,HierarchyCatName1)
select Items.Product_Code,Items.Productname,Items.CategoryID,Items.CategoryID,Itemcategories.[Level],
Items.UOM1_Conversion,Items.UOM2_Conversion, Itemcategories.Category_Name , Itemcategories.Category_Name
from Items,Itemcategories
where Items.CategoryID = Itemcategories.CategoryID

while @CntHierarchyLevel > @HierarchyLevel
Begin
--Get the CategoryID for Items
Update #tmpItems
set  #tmpItems.CategoryID = Itemcategories.ParentID ,
#tmpItems.HierarchyCatName = Itemcategories.ParentCategoryName
from #tmpItems,
(
select Itemcategories.Category_Name,Itemcategories.CategoryID,
Itemcategories.ParentID,Itemcategories1.Category_Name as ParentCategoryName
from  Itemcategories, Itemcategories as Itemcategories1
where Itemcategories.ParentID = Itemcategories1.CategoryID
and Itemcategories.[Level] > @HierarchyLevel
) as Itemcategories
where #tmpItems.CategoryID = Itemcategories.CategoryID

set @CntHierarchyLevel = @CntHierarchyLevel - 1
End

delete from #tmpItems where CategoryID <= 0
End

--Get the catogory table with sort order
Exec sp_CatLevelwise_ItemSorting

--Split The Key parameters
/* Report Type */
Set @ParamSepcounter = CHARINDEX(@Delimiter,@tempString,1)
set @RptType = isnull(substring(@tempString, 1, @ParamSepcounter-1),0)

/*SalesMan_Name*/
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@KEYPARAM))
Set @ParamSepcounter = CHARINDEX(@Delimiter, @tempString, 1)
set @SalesMan_Name = isnull(substring(@tempString, 1, @ParamSepcounter-1),'')

/*Company_Name*/
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@KEYPARAM))
Set @ParamSepcounter = CHARINDEX(@Delimiter, @tempString, 1)
set @Company_Name = isnull(substring(@tempString, 1, @ParamSepcounter-1),'')

/*Beat*/
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@KEYPARAM))
Set @ParamSepcounter = CHARINDEX(@Delimiter, @tempString, 1)
set @Beat = isnull(substring(@tempString, 1, @ParamSepcounter-1),'')

/*InvoiceDate*/
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@KEYPARAM))
Set @ParamSepcounter = CHARINDEX(@Delimiter, @tempString, 1)
set @InvoiceDate = cast(substring(@tempString, 1, @ParamSepcounter-1) as datetime)

/*InvoiceNo*/
Set @tempString = isnull(substring(@tempString, @ParamSepcounter + 1, len(@KEYPARAM)),'')
set @InvoiceNo =  cast(@tempString as nvarchar)

--Form the intermediate data
select *  into #tmpData from
(
select InvoiceData.InvoiceDate as [Date], InvoiceData.InvoiceID as InvoiceNo1,
Case ISNULL(InvoiceData.GSTFlag,0) when 0 then InvoiceData.DocumentID else isnull(InvoiceData.GSTFullDocID,0) end as InvoiceNo,
InvoiceData.SalesMan_Name ,InvoiceData.Company_Name ,InvoiceData.Beat,
InvoiceData.Category_Name, InvoiceData.Product_Code,InvoiceData.Productname,InvoiceData.HierarchyCatName,
InvoiceData.invoicetype,InvoiceData.IDS,
--Sales Details
sum(isnull(case  when invoicetype in (1,3) then InvoiceData.[Billed Qty] else 0 end,0)) as Sales_BilledQty,
sum(isnull(case  when invoicetype in (1,3) then InvoiceData.[Free Qty] else 0 end,0)) as Sales_FreeQty,
sum(isnull(case  when invoicetype in (1,3) then InvoiceData.[Total Qty] else 0 end,0)) as Sales_TotalQty,
sum(isnull(case  when invoicetype in (1,3) then InvoiceData.[Gross Amount] else 0 end,0)) as Sales_GrossAmount,

(Case  When InvoiceData.InvoiceType in (1,3) Then 1 Else 0 End) * (Sum(IsNull(InvoiceData.SchemeDiscAmount,0) + IsNull(InvoiceData.SplCatDiscAmount,0))
+sum((IsNull(InvoiceData.Quantity,0)*IsNull(InvoiceData.SalePrice,0)-IsNull(InvoiceData.DiscountValue,0)) *  IsNull(SchemeDiscountPercentage,0)/100.)) as Sales_SchemeDiscount,

(Case When InvoiceData.InvoiceType in (1,3) Then 1 Else 0 End) * (Sum(IsNull(InvoiceData.DiscountValue,0) - (IsNull(InvoiceData.SchemeDiscAmount,0) + IsNull(InvoiceData.SplCatDiscAmount,0)) )
+Sum( (IsNull(InvoiceData.Quantity,0)*IsNull(InvoiceData.SalePrice,0)-IsNull(InvoiceData.DiscountValue,0))  *((IsNull(InvoiceData.DiscountPercentage,0) - IsNull(SchemeDiscountPercentage,0))/100.))
+Sum((IsNull(InvoiceData.Quantity,0)*IsNull(InvoiceData.SalePrice,0)-IsNull(InvoiceData.DiscountValue,0)) * IsNull(InvoiceData.AdditionalDiscount,0)/100.)) as Sales_Discount,

sum(isnull(case  when invoicetype in (1,3) then InvoiceData.[VAT Amount] else 0 end,0)) as Sales_VATAmount,
sum(isnull(case  when invoicetype in (1,3) then InvoiceData.[Net Amount] + FreightProportion else 0 end,0)) as Sales_NetAmount,
--Sales return Details
sum(isnull(case  when invoicetype in (4) then InvoiceData.[Billed Qty] else 0 end,0)) as SalesReturn_BilledQty,
sum(isnull(case  when invoicetype in (4) then InvoiceData.[Free Qty] else 0 end,0)) as SalesReturn_FreeQty,
sum(isnull(case  when invoicetype in (4) then InvoiceData.[Total Qty] else 0 end,0)) as SalesReturn_TotalQty,
sum(isnull(case  when invoicetype in (4) then InvoiceData.[Gross Amount] else 0 end,0)) as SalesReturn_GrossAmount,

(Case  When InvoiceData.InvoiceType in (4) Then 1 Else 0 End) * (Sum(IsNull(InvoiceData.SchemeDiscAmount,0) + IsNull(InvoiceData.SplCatDiscAmount,0))
+sum((IsNull(InvoiceData.Quantity,0)*IsNull(InvoiceData.SalePrice,0)-IsNull(InvoiceData.DiscountValue,0)) *  IsNull(SchemeDiscountPercentage,0)/100.)) as SalesReturn_SchemeDiscount,

(Case When InvoiceData.InvoiceType in (4) Then 1 Else 0 End) * (Sum(IsNull(InvoiceData.DiscountValue,0) - (IsNull(InvoiceData.SchemeDiscAmount,0) + IsNull(InvoiceData.SplCatDiscAmount,0)) )
+Sum( (IsNull(InvoiceData.Quantity,0)*IsNull(InvoiceData.SalePrice,0)-IsNull(InvoiceData.DiscountValue,0))  *((IsNull(InvoiceData.DiscountPercentage,0) - IsNull(SchemeDiscountPercentage,0))/100.))
+Sum((IsNull(InvoiceData.Quantity,0)*IsNull(InvoiceData.SalePrice,0)-IsNull(InvoiceData.DiscountValue,0)) * IsNull(InvoiceData.AdditionalDiscount,0)/100.)) as SalesrETURN_Discount,

sum(isnull(case  when invoicetype in (4) then InvoiceData.[VAT Amount] else 0 end,0)) as SalesReturn_VATAmount,
sum(isnull(case  when invoicetype in (4) then InvoiceData.[Net Amount]  + FreightProportion else 0 end,0)) as SalesReturn_NetAmount,

sum(isnull(case  when invoicetype in (1,3) then InvoiceData.[Billed Qty] else 0 end,0) -
isnull(case  when invoicetype in (4) then InvoiceData.[Billed Qty] else 0 end,0)) as Net_BilledQty,
sum(isnull(case  when invoicetype in (1,3) then InvoiceData.[Free Qty] else 0 end,0) -
isnull(case  when invoicetype in (4) then InvoiceData.[Free Qty] else 0 end,0)) as Net_FreeQty,
sum(isnull(case  when invoicetype in (1,3) then InvoiceData.[Total Qty] else 0 end,0) -
isnull(case  when invoicetype in (4) then InvoiceData.[Total Qty] else 0 end,0)) as Net_TotalQty,
sum(isnull(case  when invoicetype in (1,3) then InvoiceData.[Gross Amount] else 0 end,0) -
isnull(case  when invoicetype in (4) then InvoiceData.[Gross Amount] else 0 end,0)) as Net_GrossAmount,

(Case  When InvoiceData.InvoiceType in (1,3) Then 1 Else 0 End) * (Sum(IsNull(InvoiceData.SchemeDiscAmount,0) + IsNull(InvoiceData.SplCatDiscAmount,0))
+sum((IsNull(InvoiceData.Quantity,0)*IsNull(InvoiceData.SalePrice,0)-IsNull(InvoiceData.DiscountValue,0)) *  IsNull(SchemeDiscountPercentage,0)/100.)) -
(Case  When InvoiceData.InvoiceType in (4) Then 1 Else 0 End) * (Sum(IsNull(InvoiceData.SchemeDiscAmount,0) + IsNull(InvoiceData.SplCatDiscAmount,0))
+sum((IsNull(InvoiceData.Quantity,0)*IsNull(InvoiceData.SalePrice,0)-IsNull(InvoiceData.DiscountValue,0)) *  IsNull(SchemeDiscountPercentage,0)/100.)) as Net_SchemeDiscount,

((Case When InvoiceData.InvoiceType in (1,3) Then 1 Else 0 End) * (Sum(IsNull(InvoiceData.DiscountValue,0) - (IsNull(InvoiceData.SchemeDiscAmount,0) + IsNull(InvoiceData.SplCatDiscAmount,0)) )
+Sum( (IsNull(InvoiceData.Quantity,0)*IsNull(InvoiceData.SalePrice,0)-IsNull(InvoiceData.DiscountValue,0))  *((IsNull(InvoiceData.DiscountPercentage,0) - IsNull(SchemeDiscountPercentage,0))/100.))
+Sum((IsNull(InvoiceData.Quantity,0)*IsNull(InvoiceData.SalePrice,0)-IsNull(InvoiceData.DiscountValue,0)) * IsNull(InvoiceData.AdditionalDiscount,0)/100.))  -
(Case When InvoiceData.InvoiceType in (4) Then 1 Else 0 End) * (Sum(IsNull(InvoiceData.DiscountValue,0) - (IsNull(InvoiceData.SchemeDiscAmount,0) + IsNull(InvoiceData.SplCatDiscAmount,0)) )
+Sum( (IsNull(InvoiceData.Quantity,0)*IsNull(InvoiceData.SalePrice,0)-IsNull(InvoiceData.DiscountValue,0))  *((IsNull(InvoiceData.DiscountPercentage,0) - IsNull(SchemeDiscountPercentage,0))/100.))
+Sum((IsNull(InvoiceData.Quantity,0)*IsNull(InvoiceData.SalePrice,0)-IsNull(InvoiceData.DiscountValue,0)) * IsNull(InvoiceData.AdditionalDiscount,0)/100.))) as Net_Discount,

sum(isnull(case  when invoicetype in (1,3) then InvoiceData.[VAT Amount] else 0 end,0) -
isnull(case  when invoicetype in (4) then InvoiceData.[VAT Amount] else 0 end,0)) as Net_VATAmount,

sum(isnull(case  when invoicetype in (1,3) then InvoiceData.[Net Amount] + FreightProportion else 0 end,0) -
isnull(case  when invoicetype in (4) then InvoiceData.[Net Amount] + FreightProportion else 0 end,0))

as Net_NetAmount

from
(
select InvoiceAbstract.InvoiceID,
InvoiceAbstract.DocumentID ,InvoiceAbstract.SalesMan_Name ,InvoiceAbstract.Company_Name ,
InvoiceAbstract.Beat, InvoiceAbstract.InvoiceDate,InvoiceAbstract.InvoiceType,
InvoiceDetail.IDS,InvoiceDetail.Category_Name,InvoiceAbstract.DiscountPercentage,
InvoiceDetail.Product_Code,InvoiceDetail.Productname,InvoiceDetail.HierarchyCatName, InvoiceDetail.[Billed Qty],
InvoiceDetail.[Free Qty],InvoiceDetail.[Total Qty],InvoiceDetail.[Gross Amount],
InvoiceDetail.[VAT Amount],InvoiceDetail.[Net Amount],
InvoiceDetail.SchemeDiscAmount,InvoiceDetail.Quantity,InvoiceDetail.SalePrice,
InvoiceDetail.DiscountValue,InvoiceDetail.SplCatDiscAmount,InvoiceAbstract.NetValue,
InvoiceAbstract.AdditionalDiscount,InvoiceAbstract.SchemeDiscountPercentage,
case when FreightlessNet in (0) then InvoiceAbstract.Freight else (InvoiceAbstract.Freight/(NetValue-InvoiceAbstract.Freight))*[Net Amount] end as FreightProportion
,InvoiceAbstract.GSTfulldocid,InvoiceAbstract.gstflag

--                       (InvoiceAbstract.Freight/(NetValue-InvoiceAbstract.Freight))*[Net Amount] as FreightProportion
from

(
select InvoiceID,DocumentID,AdditionalDiscount,SchemeDiscountPercentage ,SalesMan_Name ,
Company_Name ,Beat, InvoiceDate,InvoiceType,DiscountPercentage,NetValue,Freight,
(NetValue-Freight) as FreightlessNet,GSTflag,GStfulldocid
from
(
Select isnull(Salesman.SalesMan_Name,'') SalesMan_Name ,customer.Company_Name,
isnull(Beat.Description,'') as Beat, InvoiceAbstract.InvoiceID,
Case ISNULL(GSTFlag,0) when 0 then VoucherPrefix.Prefix + cast(InvoiceAbstract.DocumentID as nvarchar)
Else ISNULL(GSTFullDocID,0) END as DocumentID,
--Case ISNULL(GSTFlag,0) when 0 then VoucherPrefix.Prefix + cast(InvoiceAbstract.DocumentID as nvarchar)
--Else ISNULL(GSTFullDocID,0) as DocumentID end
InvoiceAbstract.InvoiceDate, InvoiceAbstract.InvoiceType,InvoiceAbstract.DiscountPercentage,
InvoiceAbstract.AdditionalDiscount,InvoiceAbstract.SchemeDiscountPercentage,InvoiceAbstract.NetValue,InvoiceAbstract.Freight,
InvoiceAbstract.GSTFlag,InvoiceAbstract.GSTFullDocID
From InvoiceAbstract,customer,salesman,Beat ,VoucherPrefix
where InvoiceAbstract.CustomerID = Customer.CustomerID
and InvoiceAbstract.InvoiceDate Between @FROMDATE AND @TODATE
and InvoiceAbstract.Status & 128 = 0
and InvoiceAbstract.InvoiceType in (1,3,4)
and InvoiceAbstract.SalesmanID = salesman.SalesmanID
and InvoiceAbstract.BeatID = Beat.BeatID
and VoucherPrefix.TranID = N'INVOICE'
--                                          and InvoiceAbstract.NetValue > 0
) tmp
)InvoiceAbstract,
(
Select InvoiceDetail.InvoiceID,ItemCategories.IDS,ItemCategories.GroupName as Category_Name,
items.Product_Code,items.Productname,items.HierarchyCatName,
case when saleprice <> 0 then
(Case @UOM When 'Base UOM' Then InvoiceDetail.Quantity
When 'UOM 1' Then dbo.sp_Get_ReportingQty(InvoiceDetail.Quantity, UOM1_Conversion)
When 'UOM 2' Then dbo.sp_Get_ReportingQty(InvoiceDetail.Quantity, UOM2_Conversion)
End)
else 0 end as [Billed Qty],
case saleprice when 0 then
(Case @UOM When 'Base UOM' Then InvoiceDetail.Quantity
When 'UOM 1' Then dbo.sp_Get_ReportingQty(InvoiceDetail.Quantity, UOM1_Conversion)
When 'UOM 2' Then dbo.sp_Get_ReportingQty(InvoiceDetail.Quantity, UOM2_Conversion)
End)
else 0 end as [Free Qty],
(Case @UOM When 'Base UOM' Then InvoiceDetail.Quantity
When 'UOM 1' Then dbo.sp_Get_ReportingQty(InvoiceDetail.Quantity, UOM1_Conversion)
When 'UOM 2' Then dbo.sp_Get_ReportingQty(InvoiceDetail.Quantity, UOM2_Conversion)
End) as [Total Qty],
IsNull(InvoiceDetail.Quantity,0)*IsNull(InvoiceDetail.SalePrice,0) as [Gross Amount],
DiscountValue as [Scheme Discount] ,DiscountValue as [Discount],
--                                 case InvoiceDetail.Vat when 1 then isnull(InvoiceDetail.StPayable,0) + isnull(InvoiceDetail.CStPayable,0) else 0 end as [VAT Amount],
isnull(InvoiceDetail.StPayable,0) + isnull(InvoiceDetail.CStPayable,0) as [VAT Amount],
(IsNull(InvoiceDetail.Quantity,0)*IsNull(InvoiceDetail.SalePrice,0)) + InvoiceDetail.stpayable + InvoiceDetail.cstpayable - InvoiceDetail.discountvalue as [Net Amount],
Quantity,SalePrice,DiscountValue, SchemeDiscAmount ,SplCatDiscAmount
From InvoiceDetail, #tmpItems as Items,
--ItemCategories
(
select ItemCategories.IDS,ItemCategories.CategoryID,ItemCategories.Category,
isnull(productcategorygroupabstract.GroupName,'') as GroupName1,
ItemCategories.Category_Name as GroupName
from productcategorygroupabstract, @TempCGCatMapping As productcategorygroupdetail,
(
select #TempCategory1.IDS,#TempCategory1.CategoryID,#TempCategory1.Category,
tempCategoryTree.initParentCategoryID,tempCategoryTree.Category_Name
from #TempCategory1,
(
select #tempCategoryTree.* ,isnull(Itemcategories.Category_Name,'') as Category_Name
from #tempCategoryTree
Left Outer Join Itemcategories on #tempCategoryTree.initparentcategoryID = Itemcategories.CategoryID
--where #tempCategoryTree.initparentcategoryID *= Itemcategories.CategoryID
) as tempCategoryTree
where #TempCategory1.CategoryID = tempCategoryTree.CategoryID
) ItemCategories
where ItemCategories.initParentCategoryID = productcategorygroupdetail.CategoryID
and productcategorygroupabstract.GroupID = productcategorygroupDetail.GroupID
group by ItemCategories.IDS,ItemCategories.CategoryID,ItemCategories.Category,
productcategorygroupabstract.GroupName, ItemCategories.Category_Name
) ItemCategories
where
InvoiceDetail.Product_Code = Items.product_Code
and Items.CategoryID = ItemCategories.CategoryID
--                                and InvoiceDetail.Amount > 0
--and ItemCategories.CategoryID in (Select CategoryID from #tempCategory)
) InvoiceDetail
where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
) InvoiceData
group by InvoiceData.InvoiceDate, InvoiceData.DocumentID , InvoiceData.InvoiceID,InvoiceData.SalesMan_Name ,
InvoiceData.Company_Name ,InvoiceData.Beat,InvoiceData.Category_Name,
InvoiceData.Product_Code,InvoiceData.Productname,InvoiceData.HierarchyCatName,InvoiceData.invoicetype,
InvoiceData.IDS ,InvoiceData.GSTFlag,InvoiceData.GSTFullDocID
) tmp

--1-ItemWise Only - Yes
--if @RptType = 1 --No filter

--2-SalesmanWise-Summary/CustomerWise-NA/DateWise-NA
if @RptType = 2
begin
delete from #tmpData
where SalesMan_Name <> @SalesMan_Name
end
--3-SalesmanWise-Detail/Beat-Summary/Customerwise-NA/DateWise-NA
else if @RptType = 3
begin
delete from #tmpData
where SalesMan_Name <> @SalesMan_Name or Beat <> @Beat
end
--4-SalesmanWise-Detail/Beat-Detail/CustomerWise-Summary/DateWise-NA
else if @RptType = 4
begin
delete from #tmpData
where SalesMan_Name <> @SalesMan_Name or Company_Name <> @Company_Name or Beat <> @Beat
end
--5-SalesmanWise-Detail/Beat-Detail/CustomerWise-Detail/DateWise-Summary
else if @RptType = 5
begin
delete from #tmpData
where SalesMan_Name <> @SalesMan_Name or Company_Name <> @Company_Name or Beat <> @Beat
or dbo.StripTimeFromDate([Date]) <> dbo.StripTimeFromDate(@InvoiceDate)
end
--6-SalesmanWise-Detail/Beat-Detail/CustomerWise-Detail/DateWise-Detail
else if @RptType = 6
begin
delete from #tmpData
where SalesMan_Name <> @SalesMan_Name or Company_Name <> @Company_Name or Beat <> @Beat
or dbo.StripTimeFromDate([Date]) <> dbo.StripTimeFromDate(@InvoiceDate) or InvoiceNo <> @InvoiceNo
end

--Select the final data depends on the @LevelOfReport

if @LevelOfReport = 'Sales'
Begin
if @DetailedAt = 'Item'
begin
select IDS,"Division" = case IDS when @IDSSubTotal then 'Subtotal:'  when @IDSGrandTotal then 'Grandtotal:' else [Div1] end,"Item Code" = [Item Code],"Item Name" = [Item Name],
"Sales - Billed Qty" = [Sales - Billed Qty],"Sales - Free Qty" = [Sales - Free Qty],"Sales - Total Qty" = [Sales - Total Qty],
"Sales - Gross Amount" = [Sales - Gross Amount],"Sales - Scheme Discount" = [Sales - Scheme Discount],
"Sales - Discount" = [Sales - Discount],"Sales - VAT Amount" = [Sales - VAT Amount], "Sales - Net Amount" = [Sales - Net Amount]
from
(
select IDS,"Div1" = Category_Name,"Item Code" = Product_Code,"Item Name" = Productname,
"Sales - Billed Qty" = sum([Sales_BilledQty]),"Sales - Free Qty" = sum([Sales_FreeQty]),"Sales - Total Qty" = sum([Sales_TotalQty]),
"Sales - Gross Amount" = sum([Sales_GrossAmount]),"Sales - Scheme Discount" = sum([Sales_SchemeDiscount]),
"Sales - Discount" = sum([Sales_Discount]),"Sales - VAT Amount" = sum([Sales_VATAmount]), "Sales - Net Amount" = sum([Sales_NetAmount]) - sum(Net_Discount)
from #tmpData
where (abs([Sales_BilledQty]) + abs([Sales_FreeQty])) <> 0
group by IDS,Product_Code,Productname,Category_Name
union all
select @IDSSubTotal as IDS,"Div1" =Category_Name,"Item Code" = '',"Item Name" = '',
"Sales - Billed Qty" = sum([Sales_BilledQty]),"Sales - Free Qty" = sum([Sales_FreeQty]),"Sales - Total Qty" = sum([Sales_TotalQty]),
"Sales - Gross Amount" = sum([Sales_GrossAmount]),"Sales - Scheme Discount" = sum([Sales_SchemeDiscount]),
"Sales - Discount" = sum([Sales_Discount]),"Sales - VAT Amount" = sum([Sales_VATAmount]), "Sales - Net Amount" = sum([Sales_NetAmount]) - sum(Net_Discount)
from #tmpData
where (abs([Sales_BilledQty]) + abs([Sales_FreeQty])) <> 0
group by Category_Name
union all
select @IDSGrandTotal as IDS,"Div1" =@GrandName,"Item Code" = '',"Item Name" = '',
"Sales - Billed Qty" = sum([Sales_BilledQty]),"Sales - Free Qty" = sum([Sales_FreeQty]),"Sales - Total Qty" = sum([Sales_TotalQty]),
"Sales - Gross Amount" = sum([Sales_GrossAmount]),"Sales - Scheme Discount" = sum([Sales_SchemeDiscount]),
"Sales - Discount" = sum([Sales_Discount]),"Sales - VAT Amount" = sum([Sales_VATAmount]), "Sales - Net Amount" = sum([Sales_NetAmount]) - sum(Net_Discount)
from #tmpData
where (abs([Sales_BilledQty]) + abs([Sales_FreeQty])) <> 0
) tmp
order by [Div1],IDS
end
else if @DetailedAt = 'Category'
begin
select IDS,"Division" = case IDS when @IDSSubTotal then 'Subtotal:'  when @IDSGrandTotal then 'Grandtotal:' else [Div1] end,"Category" = [Category],
"Sales - Billed Qty" = [Sales - Billed Qty],"Sales - Free Qty" = [Sales - Free Qty],"Sales - Total Qty" = [Sales - Total Qty],
"Sales - Gross Amount" = [Sales - Gross Amount],"Sales - Scheme Discount" = [Sales - Scheme Discount],
"Sales - Discount" = [Sales - Discount],"Sales - VAT Amount" = [Sales - VAT Amount], "Sales - Net Amount" = [Sales - Net Amount]
from
(
select IDS,"Div1" = Category_Name,"Category" = HierarchyCatName,
"Sales - Billed Qty" = sum([Sales_BilledQty]),"Sales - Free Qty" = sum([Sales_FreeQty]),"Sales - Total Qty" = sum([Sales_TotalQty]),
"Sales - Gross Amount" = sum([Sales_GrossAmount]),"Sales - Scheme Discount" = sum([Sales_SchemeDiscount]),
"Sales - Discount" = sum([Sales_Discount]),"Sales - VAT Amount" = sum([Sales_VATAmount]), "Sales - Net Amount" = sum([Sales_NetAmount]) - sum(Net_Discount)
from #tmpData
where (abs([Sales_BilledQty]) + abs([Sales_FreeQty])) <> 0
group by IDS,HierarchyCatName,Category_Name
union all
select @IDSSubTotal as IDS,"Div1" =Category_Name,"Category" = '',
"Sales - Billed Qty" = sum([Sales_BilledQty]),"Sales - Free Qty" = sum([Sales_FreeQty]),"Sales - Total Qty" = sum([Sales_TotalQty]),
"Sales - Gross Amount" = sum([Sales_GrossAmount]),"Sales - Scheme Discount" = sum([Sales_SchemeDiscount]),
"Sales - Discount" = sum([Sales_Discount]),"Sales - VAT Amount" = sum([Sales_VATAmount]), "Sales - Net Amount" = sum([Sales_NetAmount]) - sum(Net_Discount)
from #tmpData
where (abs([Sales_BilledQty]) + abs([Sales_FreeQty])) <> 0
group by Category_Name
union all
select @IDSGrandTotal as IDS,"Div1" =@GrandName,"Category" = '',
"Sales - Billed Qty" = sum([Sales_BilledQty]),"Sales - Free Qty" = sum([Sales_FreeQty]),"Sales - Total Qty" = sum([Sales_TotalQty]),
"Sales - Gross Amount" = sum([Sales_GrossAmount]),"Sales - Scheme Discount" = sum([Sales_SchemeDiscount]),
"Sales - Discount" = sum([Sales_Discount]),"Sales - VAT Amount" = sum([Sales_VATAmount]), "Sales - Net Amount" = sum([Sales_NetAmount]) - sum(Net_Discount)
from #tmpData
where (abs([Sales_BilledQty]) + abs([Sales_FreeQty])) <> 0
) tmp
order by [Div1],IDS
end
End
else if @LevelOfReport = 'Sales Return'
Begin
if @DetailedAt = 'Item'
begin
select IDS,"Division" = case IDS when @IDSSubTotal then 'Subtotal:'  when @IDSGrandTotal then 'Grandtotal:' else [Div1] end,"Item Code" = [Item Code],"Item Name" = [Item Name],
"Sales Return - Billed Qty" = [Sales Return - Billed Qty],"Sales Return - Free Qty" = [Sales Return - Free Qty],"Sales Return - Total Qty" = [Sales Return - Total Qty],
"Sales Return - Gross Amount" = [Sales Return - Gross Amount],"Sales Return - Scheme Discount" = [Sales Return - Scheme Discount],
"Sales Return - Discount" = [Sales Return - Discount],"Sales Return - VAT Amount" = [Sales Return - VAT Amount], "Sales Return - Net Amount" = [Sales Return - Net Amount]
from
(
select IDS,"Div1" = Category_Name,"Item Code" = Product_Code,"Item Name" = Productname,
"Sales Return - Billed Qty" = sum([SalesReturn_BilledQty]),"Sales Return - Free Qty" = sum([SalesReturn_FreeQty]),"Sales Return - Total Qty" = sum([SalesReturn_TotalQty]),
"Sales Return - Gross Amount" = sum([SalesReturn_GrossAmount]),"Sales Return - Scheme Discount" = sum([SalesReturn_SchemeDiscount]),
"Sales Return - Discount" = sum([SalesReturn_Discount]),"Sales Return - VAT Amount" = sum([SalesReturn_VATAmount]), "Sales Return - Net Amount" = sum([SalesReturn_NetAmount])
from #tmpData
where (abs([SalesReturn_BilledQty]) + abs([SalesReturn_FreeQty])) <> 0
group by IDS,Product_Code,Productname,Category_Name
union all
select @IDSSubTotal as IDS,"Div1" =Category_Name,"Item Code" = '',"Item Name" = '',
"Sales Return - Billed Qty" = sum([SalesReturn_BilledQty]),"Sales Return - Free Qty" = sum([SalesReturn_FreeQty]),"Sales Return - Total Qty" = sum([SalesReturn_TotalQty]),
"Sales Return - Gross Amount" = sum([SalesReturn_GrossAmount]),"Sales Return - Scheme Discount" = sum([SalesReturn_SchemeDiscount]),
"Sales Return - Discount" = sum([SalesReturn_Discount]),"Sales Return - VAT Amount" = sum([SalesReturn_VATAmount]), "Sales Return - Net Amount" = sum([SalesReturn_NetAmount])
from #tmpData
where (abs([SalesReturn_BilledQty]) + abs([SalesReturn_FreeQty])) <> 0
group by Category_Name
union all
select @IDSGrandTotal as IDS,"Div1" =@GrandName,"Item Code" = '',"Item Name" = '',
"Sales Return - Billed Qty" = sum([SalesReturn_BilledQty]),"Sales Return - Free Qty" = sum([SalesReturn_FreeQty]),"Sales Return - Total Qty" = sum([SalesReturn_TotalQty]),
"Sales Return - Gross Amount" = sum([SalesReturn_GrossAmount]),"Sales Return - Scheme Discount" = sum([SalesReturn_SchemeDiscount]),
"Sales Return - Discount" = sum([SalesReturn_Discount]),"Sales Return - VAT Amount" = sum([SalesReturn_VATAmount]), "Sales Return - Net Amount" = sum([SalesReturn_NetAmount])
from #tmpData
where (abs([SalesReturn_BilledQty]) + abs([SalesReturn_FreeQty])) <> 0
) tmp
order by [Div1],IDS
end
else if @DetailedAt = 'Category'
begin
select IDS,"Division" = case IDS when @IDSSubTotal then 'Subtotal:'  when @IDSGrandTotal then 'Grandtotal:' else [Div1] end,"Category" = [Category],
"Sales Return - Billed Qty" = [Sales Return - Billed Qty],"Sales Return - Free Qty" = [Sales Return - Free Qty],"Sales Return - Total Qty" = [Sales Return - Total Qty],
"Sales Return - Gross Amount" = [Sales Return - Gross Amount],"Sales Return - Scheme Discount" = [Sales Return - Scheme Discount],
"Sales Return - Discount" = [Sales Return - Discount],"Sales Return - VAT Amount" = [Sales Return - VAT Amount], "Sales Return - Net Amount" = [Sales Return - Net Amount]
from
(
select IDS,"Div1" = Category_Name,"Category" = HierarchyCatName,
"Sales Return - Billed Qty" = sum([SalesReturn_BilledQty]),"Sales Return - Free Qty" = sum([SalesReturn_FreeQty]),"Sales Return - Total Qty" = sum([SalesReturn_TotalQty]),
"Sales Return - Gross Amount" = sum([SalesReturn_GrossAmount]),"Sales Return - Scheme Discount" = sum([SalesReturn_SchemeDiscount]),
"Sales Return - Discount" = sum([SalesReturn_Discount]),"Sales Return - VAT Amount" = sum([SalesReturn_VATAmount]), "Sales Return - Net Amount" = sum([SalesReturn_NetAmount])
from #tmpData
where (abs([SalesReturn_BilledQty]) + abs([SalesReturn_FreeQty])) <> 0
group by IDS,HierarchyCatName,Category_Name
union all
select @IDSGrandTotal as IDS,"Div1" =Category_Name,"Category" = '',
"Sales Return - Billed Qty" = sum([SalesReturn_BilledQty]),"Sales Return - Free Qty" = sum([SalesReturn_FreeQty]),"Sales Return - Total Qty" = sum([SalesReturn_TotalQty]),
"Sales Return - Gross Amount" = sum([SalesReturn_GrossAmount]),"Sales Return - Scheme Discount" = sum([SalesReturn_SchemeDiscount]),
"Sales Return - Discount" = sum([SalesReturn_Discount]),"Sales Return - VAT Amount" = sum([SalesReturn_VATAmount]), "Sales Return - Net Amount" = sum([SalesReturn_NetAmount])
from #tmpData
where (abs([SalesReturn_BilledQty]) + abs([SalesReturn_FreeQty])) <> 0
group by Category_Name
union all
select @IDSGrandTotal as IDS,"Div1" =@GrandName,"Category" = '',
"Sales Return - Billed Qty" = sum([SalesReturn_BilledQty]),"Sales Return - Free Qty" = sum([SalesReturn_FreeQty]),"Sales Return - Total Qty" = sum([SalesReturn_TotalQty]),
"Sales Return - Gross Amount" = sum([SalesReturn_GrossAmount]),"Sales Return - Scheme Discount" = sum([SalesReturn_SchemeDiscount]),
"Sales Return - Discount" = sum([SalesReturn_Discount]),"Sales Return - VAT Amount" = sum([SalesReturn_VATAmount]), "Sales Return - Net Amount" = sum([SalesReturn_NetAmount])
from #tmpData
where (abs([SalesReturn_BilledQty]) + abs([SalesReturn_FreeQty])) <> 0
) tmp
order by [Div1],IDS
end
End
else if @LevelOfReport = 'Net Sales'
Begin
if @DetailedAt = 'Item'
begin
select IDS,"Division" = case IDS when @IDSSubTotal then 'Subtotal:'  when @IDSGrandTotal then 'Grandtotal:' else [Div1] end,"Item Code" = [Item Code],"Item Name" = [Item Name],
"Net Sales - Billed Qty" = [Net - Billed Qty],"Net Sales - Free Qty" = [Net - Free Qty],"Net Sales - Total Qty" = [Net - Total Qty],
"Net Sales - Gross Amount" = [Net - Gross Amount],"Net Sales - Scheme Discount" = [Net - Scheme Discount],
"Net Sales - Discount" = [Net - Discount],"Net Sales - VAT Amount" = [Net - VAT Amount], "Net Sales - Net Amount" = [Net - Net Amount]
from
(
select IDS,"Div1" = Category_Name,"Item Code" = Product_Code,"Item Name" = Productname,
"Net - Billed Qty" = sum([Net_BilledQty]),"Net - Free Qty" = sum([Net_FreeQty]),"Net - Total Qty" = sum([Net_TotalQty]),
"Net - Gross Amount" = sum([Net_GrossAmount]),"Net - Scheme Discount" = sum([Net_SchemeDiscount]),
"Net - Discount" = sum([Net_Discount]),"Net - VAT Amount" = sum([Net_VATAmount]), "Net - Net Amount" = sum([Net_NetAmount]) - sum(Net_Discount)
from #tmpData
where (abs([Net_BilledQty]) + abs([Net_FreeQty])) <> 0
group by IDS,Product_Code,Productname,Category_Name
union all
select @IDSSubTotal as IDS,"Div1" =Category_Name,"Item Code" = '',"Item Name" = '',
"Net - Billed Qty" = sum([Net_BilledQty]),"Net - Free Qty" = sum([Net_FreeQty]),"Net - Total Qty" = sum([Net_TotalQty]),
"Net - Gross Amount" = sum([Net_GrossAmount]),"Net - Scheme Discount" = sum([Net_SchemeDiscount]),
"Net - Discount" = sum([Net_Discount]),"Net - VAT Amount" = sum([Net_VATAmount]), "Net - Net Amount" = sum([Net_NetAmount]) - sum(Net_Discount)
from #tmpData
where (abs([Net_BilledQty]) + abs([Net_FreeQty])) <> 0
group by Category_Name
union all
select @IDSGrandTotal as IDS,"Div1" =@GrandName,"Item Code" = '',"Item Name" = '',
"Net - Billed Qty" = sum([Net_BilledQty]),"Net - Free Qty" = sum([Net_FreeQty]),"Net - Total Qty" = sum([Net_TotalQty]),
"Net - Gross Amount" = sum([Net_GrossAmount]),"Net - Scheme Discount" = sum([Net_SchemeDiscount]),
"Net - Discount" = sum([Net_Discount]),"Net - VAT Amount" = sum([Net_VATAmount]), "Net - Net Amount" = sum([Net_NetAmount]) - sum(Net_Discount)
from #tmpData
where (abs([Net_BilledQty]) + abs([Net_FreeQty])) <> 0
) tmp
order by [Div1],IDS
end
else if @DetailedAt = 'Category'
begin
select IDS,"Division" = case IDS when @IDSSubTotal then 'Subtotal:'  when @IDSGrandTotal then 'Grandtotal:' else [Div1] end,"Category" = [Category],
"Net - Billed Qty" = [Net - Billed Qty],"Net - Free Qty" = [Net - Free Qty],"Net - Total Qty" = [Net - Total Qty],
"Net - Gross Amount" = [Net - Gross Amount],"Net - Scheme Discount" = [Net - Scheme Discount],
"Net - Discount" = [Net - Discount],"Net - VAT Amount" = [Net - VAT Amount], "Net - Net Amount" = [Net - Net Amount]
from
(
select IDS,"Div1" = Category_Name,"Category" = HierarchyCatName,
"Net - Billed Qty" = sum([Net_BilledQty]),"Net - Free Qty" = sum([Net_FreeQty]),"Net - Total Qty" = sum([Net_TotalQty]),
"Net - Gross Amount" = sum([Net_GrossAmount]),"Net - Scheme Discount" = sum([Net_SchemeDiscount]),
"Net - Discount" = sum([Net_Discount]),"Net - VAT Amount" = sum([Net_VATAmount]), "Net - Net Amount" = sum([Net_NetAmount]) - sum(Net_Discount)
from #tmpData
where (abs([Net_BilledQty]) + abs([Net_FreeQty])) <> 0
group by IDS,HierarchyCatName,Category_Name
union all
select @IDSSubTotal as IDS,"Div1" =Category_Name,"Category" = '',
"Net - Billed Qty" = sum([Net_BilledQty]),"Net - Free Qty" = sum([Net_FreeQty]),"Net - Total Qty" = sum([Net_TotalQty]),
"Net - Gross Amount" = sum([Net_GrossAmount]),"Net - Scheme Discount" = sum([Net_SchemeDiscount]),
"Net - Discount" = sum([Net_Discount]),"Net - VAT Amount" = sum([Net_VATAmount]), "Net - Net Amount" = sum([Net_NetAmount]) - sum(Net_Discount)
from #tmpData
where (abs([Net_BilledQty]) + abs([Net_FreeQty])) <> 0
group by Category_Name
union all
select @IDSGrandTotal as IDS,"Div1" =@GrandName,"Category" = '',
"Net - Billed Qty" = sum([Net_BilledQty]),"Net - Free Qty" = sum([Net_FreeQty]),"Net - Total Qty" = sum([Net_TotalQty]),
"Net - Gross Amount" = sum([Net_GrossAmount]),"Net - Scheme Discount" = sum([Net_SchemeDiscount]),
"Net - Discount" = sum([Net_Discount]),"Net - VAT Amount" = sum([Net_VATAmount]), "Net - Net Amount" = sum([Net_NetAmount]) - sum(Net_Discount)
from #tmpData
where (abs([Net_BilledQty]) + abs([Net_FreeQty])) <> 0
) tmp
order by [Div1],IDS
end
End
else if @LevelOfReport = 'All'
Begin
if @DetailedAt = 'Item'
Begin
select IDS,"Division" = case IDS when @IDSSubTotal then 'Subtotal:'  when @IDSGrandTotal then 'Grandtotal:' else [Div1] end,"Item Code" = [Item Code],"Item Name" = [Item Name],

"Sales - Billed Qty" = [Sales - Billed Qty],"Sales - Free Qty" = [Sales - Free Qty],"Sales - Total Qty" = [Sales - Total Qty],
"Sales - Gross Amount" = [Sales - Gross Amount],"Sales - Scheme Discount" = [Sales - Scheme Discount],
"Sales - Discount" = [Sales - Discount],"Sales - VAT Amount" = [Sales - VAT Amount], "Sales - Net Amount" = [Sales - Net Amount],

"Sales Return - Billed Qty" = [Sales Return - Billed Qty],"Sales Return - Free Qty" = [Sales Return - Free Qty],"Sales Return - Total Qty" = [Sales Return - Total Qty],
"Sales Return - Gross Amount" = [Sales Return - Gross Amount],"Sales Return - Scheme Discount" = [Sales Return - Scheme Discount],
"Sales Return - Discount" = [Sales Return - Discount],"Sales Return - VAT Amount" = [Sales Return - VAT Amount], "Sales Return - Net Amount" = [Sales Return - Net Amount],

"Net Sales - Billed Qty" = [Net - Billed Qty],"Net Sales - Free Qty" = [Net - Free Qty],"Net Sales - Total Qty" = [Net - Total Qty],
"Net Sales - Gross Amount" = [Net - Gross Amount],"Net Sales - Scheme Discount" = [Net - Scheme Discount],
"Net Sales - Discount" = [Net - Discount],"Net Sales - VAT Amount" = [Net - VAT Amount], "Net Sales - Net Amount" = [Net - Net Amount]
from
(
select IDS,"Div1" = Category_Name,"Item Code" = Product_Code,"Item Name" = Productname,

"Sales - Billed Qty" = sum([Sales_BilledQty]),"Sales - Free Qty" = sum([Sales_FreeQty]),"Sales - Total Qty" = sum([Sales_TotalQty]),
"Sales - Gross Amount" = sum([Sales_GrossAmount]),"Sales - Scheme Discount" = sum([Sales_SchemeDiscount]),
"Sales - Discount" = sum([Sales_Discount]),"Sales - VAT Amount" = sum([Sales_VATAmount]), "Sales - Net Amount" = sum([Sales_NetAmount]) - sum(Net_Discount),

"Sales Return - Billed Qty" = sum([SalesReturn_BilledQty]),"Sales Return - Free Qty" = sum([SalesReturn_FreeQty]),"Sales Return - Total Qty" = sum([SalesReturn_TotalQty]),
"Sales Return - Gross Amount" = sum([SalesReturn_GrossAmount]),"Sales Return - Scheme Discount" = sum([SalesReturn_SchemeDiscount]),
"Sales Return - Discount" = sum([SalesReturn_Discount]),"Sales Return - VAT Amount" = sum([SalesReturn_VATAmount]), "Sales Return - Net Amount" = sum([SalesReturn_NetAmount]),

"Net - Billed Qty" = sum([Net_BilledQty]),"Net - Free Qty" = sum([Net_FreeQty]),"Net - Total Qty" = sum([Net_TotalQty]),
"Net - Gross Amount" = sum([Net_GrossAmount]),"Net - Scheme Discount" = sum([Net_SchemeDiscount]),
"Net - Discount" = sum([Net_Discount]),"Net - VAT Amount" = sum([Net_VATAmount]), "Net - Net Amount" = sum([Net_NetAmount]) - sum(Net_Discount)
from #tmpData
group by IDS,Product_Code,Productname,Category_Name
union all
select @IDSSubTotal as IDS,"Div1" = Category_Name,"Item Code" = '',"Item Name" = '',
"Sales - Billed Qty" = sum([Sales_BilledQty]),"Sales - Free Qty" = sum([Sales_FreeQty]),"Sales - Total Qty" = sum([Sales_TotalQty]),
"Sales - Gross Amount" = sum([Sales_GrossAmount]),"Sales - Scheme Discount" = sum([Sales_SchemeDiscount]),
"Sales - Discount" = sum([Sales_Discount]),"Sales - VAT Amount" = sum([Sales_VATAmount]), "Sales - Net Amount" = sum([Sales_NetAmount]) - sum(Net_Discount),

"Sales Return - Billed Qty" = sum([SalesReturn_BilledQty]),"Sales Return - Free Qty" = sum([SalesReturn_FreeQty]),"Sales Return - Total Qty" = sum([SalesReturn_TotalQty]),
"Sales Return - Gross Amount" = sum([SalesReturn_GrossAmount]),"Sales Return - Scheme Discount" = sum([SalesReturn_SchemeDiscount]),
"Sales Return - Discount" = sum([SalesReturn_Discount]),"Sales Return - VAT Amount" = sum([SalesReturn_VATAmount]), "Sales Return - Net Amount" = sum([SalesReturn_NetAmount]),

"Net - Billed Qty" = sum([Net_BilledQty]),"Net - Free Qty" = sum([Net_FreeQty]),"Net - Total Qty" = sum([Net_TotalQty]),
"Net - Gross Amount" = sum([Net_GrossAmount]),"Net - Scheme Discount" = sum([Net_SchemeDiscount]),
"Net - Discount" = sum([Net_Discount]),"Net - VAT Amount" = sum([Net_VATAmount]), "Net - Net Amount" = sum([Net_NetAmount]) - sum(Net_Discount)
from #tmpData
group by Category_Name
union all
select @IDSGrandTotal as IDS,"Div1" =@GrandName,"Item Code" = '',"Item Name" = '',
"Sales - Billed Qty" = sum([Sales_BilledQty]),"Sales - Free Qty" = sum([Sales_FreeQty]),"Sales - Total Qty" = sum([Sales_TotalQty]),
"Sales - Gross Amount" = sum([Sales_GrossAmount]),"Sales - Scheme Discount" = sum([Sales_SchemeDiscount]),
"Sales - Discount" = sum([Sales_Discount]),"Sales - VAT Amount" = sum([Sales_VATAmount]), "Sales - Net Amount" = sum([Sales_NetAmount]) - sum(Net_Discount),

"Sales Return - Billed Qty" = sum([SalesReturn_BilledQty]),"Sales Return - Free Qty" = sum([SalesReturn_FreeQty]),"Sales Return - Total Qty" = sum([SalesReturn_TotalQty]),
"Sales Return - Gross Amount" = sum([SalesReturn_GrossAmount]),"Sales Return - Scheme Discount" = sum([SalesReturn_SchemeDiscount]),
"Sales Return - Discount" = sum([SalesReturn_Discount]),"Sales Return - VAT Amount" = sum([SalesReturn_VATAmount]), "Sales Return - Net Amount" = sum([SalesReturn_NetAmount]),

"Net - Billed Qty" = sum([Net_BilledQty]),"Net - Free Qty" = sum([Net_FreeQty]),"Net - Total Qty" = sum([Net_TotalQty]),
"Net - Gross Amount" = sum([Net_GrossAmount]),"Net - Scheme Discount" = sum([Net_SchemeDiscount]),
"Net - Discount" = sum([Net_Discount]),"Net - VAT Amount" = sum([Net_VATAmount]), "Net - Net Amount" = sum([Net_NetAmount]) - sum(Net_Discount)
from #tmpData
) tmp order by [Div1],IDS
End
else if @DetailedAt = 'Category'
Begin
select IDS,"Division" = case IDS when @IDSSubTotal then 'Subtotal:'  when @IDSGrandTotal then 'Grandtotal:' else [Div1] end,"Category" = [Category],
"Sales - Billed Qty" = [Sales - Billed Qty],"Sales - Free Qty" = [Sales - Free Qty],"Sales - Total Qty" = [Sales - Total Qty],
"Sales - Gross Amount" = [Sales - Gross Amount],"Sales - Scheme Discount" = [Sales - Scheme Discount],
"Sales - Discount" = [Sales - Discount],"Sales - VAT Amount" = [Sales - VAT Amount], "Sales - Net Amount" = [Sales - Net Amount],

"Sales Return - Billed Qty" = [Sales Return - Billed Qty],"Sales Return - Free Qty" = [Sales Return - Free Qty],"Sales Return - Total Qty" = [Sales Return - Total Qty],
"Sales Return - Gross Amount" = [Sales Return - Gross Amount],"Sales Return - Scheme Discount" = [Sales Return - Scheme Discount],
"Sales Return - Discount" = [Sales Return - Discount],"Sales Return - VAT Amount" = [Sales Return - VAT Amount], "Sales Return - Net Amount" = [Sales Return - Net Amount],

"Net - Billed Qty" = [Net - Billed Qty],"Net - Free Qty" = [Net - Free Qty],"Net - Total Qty" = [Net - Total Qty],
"Net - Gross Amount" = [Net - Gross Amount],"Net - Scheme Discount" = [Net - Scheme Discount],
"Net - Discount" = [Net - Discount],"Net - VAT Amount" = [Net - VAT Amount], "Net - Net Amount" = [Net - Net Amount]
from
(
select IDS,"Div1" = Category_Name,"Category" = HierarchyCatName,
"Sales - Billed Qty" = sum([Sales_BilledQty]),"Sales - Free Qty" = sum([Sales_FreeQty]),"Sales - Total Qty" = sum([Sales_TotalQty]),
"Sales - Gross Amount" = sum([Sales_GrossAmount]),"Sales - Scheme Discount" = sum([Sales_SchemeDiscount]),
"Sales - Discount" = sum([Sales_Discount]),"Sales - VAT Amount" = sum([Sales_VATAmount]), "Sales - Net Amount" = sum([Sales_NetAmount]) - sum(Net_Discount),

"Sales Return - Billed Qty" = sum([SalesReturn_BilledQty]),"Sales Return - Free Qty" = sum([SalesReturn_FreeQty]),"Sales Return - Total Qty" = sum([SalesReturn_TotalQty]),
"Sales Return - Gross Amount" = sum([SalesReturn_GrossAmount]),"Sales Return - Scheme Discount" = sum([SalesReturn_SchemeDiscount]),
"Sales Return - Discount" = sum([SalesReturn_Discount]),"Sales Return - VAT Amount" = sum([SalesReturn_VATAmount]), "Sales Return - Net Amount" = sum([SalesReturn_NetAmount]),

"Net - Billed Qty" = sum([Net_BilledQty]),"Net - Free Qty" = sum([Net_FreeQty]),"Net - Total Qty" = sum([Net_TotalQty]),
"Net - Gross Amount" = sum([Net_GrossAmount]),"Net - Scheme Discount" = sum([Net_SchemeDiscount]),
"Net - Discount" = sum([Net_Discount]),"Net - VAT Amount" = sum([Net_VATAmount]), "Net - Net Amount" = sum([Net_NetAmount]) - sum(Net_Discount)
from #tmpData
group by IDS,HierarchyCatName,Category_Name
union all
select @IDSSubTotal as IDS,"Div1" =Category_Name,"Category" = '',
"Sales - Billed Qty" = sum([Sales_BilledQty]),"Sales - Free Qty" = sum([Sales_FreeQty]),"Sales - Total Qty" = sum([Sales_TotalQty]),
"Sales - Gross Amount" = sum([Sales_GrossAmount]),"Sales - Scheme Discount" = sum([Sales_SchemeDiscount]),
"Sales - Discount" = sum([Sales_Discount]),"Sales - VAT Amount" = sum([Sales_VATAmount]), "Sales - Net Amount" = sum([Sales_NetAmount]) - sum(Net_Discount),

"Sales Return - Billed Qty" = sum([SalesReturn_BilledQty]),"Sales Return - Free Qty" = sum([SalesReturn_FreeQty]),"Sales Return - Total Qty" = sum([SalesReturn_TotalQty]),
"Sales Return - Gross Amount" = sum([SalesReturn_GrossAmount]),"Sales Return - Scheme Discount" = sum([SalesReturn_SchemeDiscount]),
"Sales Return - Discount" = sum([SalesReturn_Discount]),"Sales Return - VAT Amount" = sum([SalesReturn_VATAmount]), "Sales Return - Net Amount" = sum([SalesReturn_NetAmount]),

"Net - Billed Qty" = sum([Net_BilledQty]),"Net - Free Qty" = sum([Net_FreeQty]),"Net - Total Qty" = sum([Net_TotalQty]),
"Net - Gross Amount" = sum([Net_GrossAmount]),"Net - Scheme Discount" = sum([Net_SchemeDiscount]),
"Net - Discount" = sum([Net_Discount]),"Net - VAT Amount" = sum([Net_VATAmount]), "Net - Net Amount" = sum([Net_NetAmount]) - sum(Net_Discount)
from #tmpData
group by Category_Name
union all
select @IDSGrandTotal as IDS,"Div1" =@GrandName,"Category" = '',
"Sales - Billed Qty" = sum([Sales_BilledQty]),"Sales - Free Qty" = sum([Sales_FreeQty]),"Sales - Total Qty" = sum([Sales_TotalQty]),
"Sales - Gross Amount" = sum([Sales_GrossAmount]),"Sales - Scheme Discount" = sum([Sales_SchemeDiscount]),
"Sales - Discount" = sum([Sales_Discount]),"Sales - VAT Amount" = sum([Sales_VATAmount]), "Sales - Net Amount" = sum([Sales_NetAmount]) - sum(Net_Discount),

"Sales Return - Billed Qty" = sum([SalesReturn_BilledQty]),"Sales Return - Free Qty" = sum([SalesReturn_FreeQty]),"Sales Return - Total Qty" = sum([SalesReturn_TotalQty]),
"Sales Return - Gross Amount" = sum([SalesReturn_GrossAmount]),"Sales Return - Scheme Discount" = sum([SalesReturn_SchemeDiscount]),
"Sales Return - Discount" = sum([SalesReturn_Discount]),"Sales Return - VAT Amount" = sum([SalesReturn_VATAmount]), "Sales Return - Net Amount" = sum([SalesReturn_NetAmount]),

"Net - Billed Qty" = sum([Net_BilledQty]),"Net - Free Qty" = sum([Net_FreeQty]),"Net - Total Qty" = sum([Net_TotalQty]),
"Net - Gross Amount" = sum([Net_GrossAmount]),"Net - Scheme Discount" = sum([Net_SchemeDiscount]),
"Net - Discount" = sum([Net_Discount]),"Net - VAT Amount" = sum([Net_VATAmount]), "Net - Net Amount" = sum([Net_NetAmount]) - sum(Net_Discount)
from #tmpData
) tmp order by [Div1],IDS
End
End


----Drop Temporary tables
drop table #tempCategory
drop table #tempCategoryGroup
drop table #tmpData
drop table #tempCategoryName
drop table #tempItemhierarchy
drop table #tempCategoryTree
drop table #TempCategory1
drop table #tempCategory2
drop table #tempCategoryTree2
drop table #tmpItems
end


