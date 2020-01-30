CREATE PROCEDURE [dbo].[Spr_NewProductLaunchTrackerReport_Summary_ITC] (@ProdHierarchy NVarchar(256),   
        @Category NVarchar(256),
        @ItemCode NVarchar(256),
        @FromDate Datetime,
        @ToDate Datetime)
           
As
            
Begin
Declare @Delimeter Char(1)
Declare @SKU NVarchar(50)
Declare @SUBTOTAL NVarchar(50)
Declare @GRNTOTAL NVarchar(50)
Declare @WDCode NVarchar(255), @WDDest NVarchar(255)
Declare @CompaniesToUploadCode NVarchar(255)
Declare @SPRExist Int
-- Declare @RFromDate Datetime
-- Declare @RTODate Datetime
  
-- Set @RFromDate = dbo.StripDateFromTime(@FromDate)
-- Set @RTODate = dbo.StripDateFromTime(@ToDate)
  
Set @SKU = dbo.LookupDictionaryItem(N'Item Code', Default)
Set @SUBTOTAL = dbo.LookupDictionaryItem(N'SubTotal:', Default)
Set @GRNTOTAL = dbo.LookupDictionaryItem(N'GrandTotal:', Default)
  
-- Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload
-- Select Top 1 @WDCode = RegisteredOwner From Setup
      
-- If @CompaniesToUploadCode='ITC001'
--  Set @WDDest= @WDCode
-- Else
-- Begin
--  Set @WDDest= @WDCode
--  Set @WDCode= @CompaniesToUploadCode
-- End
  
Create Table #TempConsolidate (IDS Int,
WDDCode nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
ItemCode nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
ItemName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
NfPCers Int, NPC Int, RC Int, UM  nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Otps Decimal(18, 6), RS Decimal(18, 6), FSS Decimal(18, 6),
ASPC Decimal(18, 6))
  
Set @Delimeter = Char(15)
  
Create Table #tempCategory(CategoryID Int, Status Int)
Exec GetLeafCategories @ProdHierarchy, @Category    
Select Distinct CategoryID InTo #temcat1 From #tempCategory
  

Create Table #Itm(ItemCode nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)
  
If @ItemCode = '%'
 Insert InTo #itm  Select product_code From items
 Where Categoryid In (Select CategoryID From #temcat1 )
Else
    Insert into #itm select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)
  
Create table #tempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)
Exec sp_CatLevelwise_ItemSorting
  
Create Table #tmp1 (WDC nVarChar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS, ItemCode nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
ItemName nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, nfpc int, npc int, rc int, uom nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
otps Decimal(18, 6), rs Decimal(18, 6), fss Decimal(18, 6))
  
-----------------------------------------
  
-- Select Quantity, invd.Product_code From invoiceabstract inva, invoicedetail invd where inva.invoiceid = invd.invoiceid   
-- And inva.customerid in (Select Distinct CustomerID From invoiceabstract inva Where   
-- invoiceDate Between @FromDate And  @ToDate
-- -- And IsNull((select count(Distinct Cast(Datepart(dd, InvoiceDate) As nVarChar) + '/' + Cast(Datepart(mm, InvoiceDate) As nVarChar) + '/' + Cast(DatePart(YYYY, InvoiceDate) As nVarchar))  from invoiceabstract   
-- -- where CustomerID = inva.CustomerID and invoiceDate Between @FromDate And  @ToDate  
-- -- And Status & 192 = 0), 0)  =  1
-- And inva.Status & 192 = 0
-- And inva.InvoiceType In (1, 3))
-- And inva.InvoiceDate Between @FromDate And  @ToDate
-- And invd.SalePrice > 0
-- --And invd.Product_Code = ind.Product_code
-- And CustomerID Not In ('0')
-- And inva.Status & 192 = 0
-- And inva.InvoiceType In (1, 3)
  
----------------------------------------  
Create Table #TempCatLevel(CatName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CatID Int)
If @Category ='%'
BEGIN
	Insert into #TempCatLevel Select Distinct Category_Name,CategoryID From ItemCategories --Where Level in(2,3)
END
ELSE
BEGIN
	Insert into #TempCatLevel(CatName) select * from dbo.sp_SplitIn2Rows(@Category,@Delimeter)
    Declare @CatName Nvarchar(255)
   Declare Cat Cursor For Select Distinct CatName from #TempCatLevel
    Open Cat
	Fetch From Cat into @CatName
    While @@Fetch_status = 0
	BEGIN
		Update #TempCatLevel Set CatID=(Select CategoryID From ItemCategories Where Category_Name=@CatName)
		Where CatName=@CatName
		Fetch Next From Cat into @CatName
	END
	
	Close Cat
	Deallocate Cat
END

Insert InTo #tmp1
Select s.registeredowner, ind.Product_Code, its.ProductName,
IsNull((select Count(distinct(CustomerProductCategory.customerID)) from CustomerProductCategory,
customer,ItemCategories,#TempCatLevel
where CustomerProductCategory.active = 1
And Customer.Active = 1
And Customer.CustomerID Not In ('0')
And CustomerProductCategory.CustomerId= Customer.CustomerID
And CustomerProductCategory.CategoryID = #TempCatLevel.CatID
And ItemCategories.ParentID IN (Select ParentID From ItemCategories
Where CategoryID in (Select CatID From #TempCatLevel))), 0),
  

IsNull((Select Count(Distinct CustomerID) From invoiceabstract inva, invoicedetail invd
        Where inva.Status & 192 = 0
 And inva.InvoiceType In (1, 3)
 And invoiceDate Between @FromDate And  @ToDate
 And CustomerID Not In ('0')
 And inva.InvoiceID = invd.InvoiceID
-- And IsNull((select count(Distinct Cast(Datepart(dd, InvoiceDate) As nVarChar) + '/' + Cast(Datepart(mm, InvoiceDate) As nVarChar) + '/' + Cast(DatePart(YYYY, InvoiceDate) As nVarchar))  from invoiceabstract
-- where CustomerID = inva.CustomerID and invoiceDate Between @FromDate And  @ToDate
-- And Status & 192 = 0), 0)  =  1   
 And invd.Product_Code = ind.Product_Code
        ), 0),
IsNull((Select Count(Distinct CustomerID) From invoiceabstract inva, invoicedetail invd
        Where inva.Status & 192 = 0
 And inva.InvoiceType In (1, 3)
 And invoiceDate Between @FromDate And  @ToDate
 And CustomerID Not In ('0')
 And IsNull((select count(Distinct Cast(Datepart(dd, InvoiceDate) As nVarChar) + '/' + Cast(Datepart(mm, InvoiceDate) As nVarChar) + '/' + Cast(DatePart(YYYY, InvoiceDate) As nVarchar))
   from invoiceabstract ia, InvoiceDetail idt
   where
   Status & 192 = 0
   And InvoiceType In (1, 3)
   And invoiceDate Between @FromDate And  @ToDate
   and ia.InvoiceID = idt.InvoiceID
   And idt.Product_Code = invd.Product_Code
   And CustomerID = Inva.CustomerID
   ), 0)  >  1
 And invd.Product_Code = ind.Product_Code
 and inva.InvoiceID = invd.InvoiceID
 ), 0),
  
uom.[Description],
  
--set dateformat dmy
(Select Sum(Quantity) From invoiceabstract inva, invoicedetail invd
where
inva.Status & 192 = 0
And inva.InvoiceType In (1, 3)
And inva.InvoiceDate Between @FromDate And  @ToDate
And invd.SalePrice > 0
And inva.CustomerID Not In ('0')
And inva.customerid in
(Select Distinct CustomerID From invoiceabstract iab,invoicedetail idd
   Where
   iab.Status & 192 = 0
   And iab.InvoiceType In (1, 3)
   And iab.invoiceDate Between @FromDate And  @ToDate
   And Cast(Datepart(dd, iab.InvoiceDate) As nVarChar) + '/' +
       Cast(Datepart(mm, iab.InvoiceDate) As nVarChar) + '/' +   
       Cast(DatePart(YYYY, iab.InvoiceDate)  As nVarchar)
       In (IsNull((select Top 1 Cast(Datepart(dd, ia.InvoiceDate) As nVarChar) + '/' +
     Cast(Datepart(mm, ia.InvoiceDate) As nVarChar) + '/' +
     Cast(DatePart(YYYY, ia.InvoiceDate) As nVarchar)
     from invoiceabstract ia, InvoiceDetail idt
     where
     ia.Status & 192 = 0
     And ia.InvoiceType In (1, 3)
     And ia.invoiceDate Between @FromDate And  @ToDate
     And ia.CustomerID = iab.CustomerID
     And ia.InvoiceID = idt.InvoiceID 
     And idt.Product_Code = idd.Product_Code
     Order By Cast(Datepart(dd, ia.InvoiceDate) As nVarChar) + '/' +
     Cast(Datepart(mm, ia.InvoiceDate) As nVarChar) + '/' +
     Cast(DatePart(YYYY, ia.InvoiceDate) As nVarchar)
    ), ''))
   And iab.InvoiceID = idd.InvoiceID
   )
And Cast(Datepart(dd, inva.InvoiceDate) As nVarChar) + '/' +
    Cast(Datepart(mm, inva.InvoiceDate) As nVarChar) + '/' +
    Cast(DatePart(YYYY, inva.InvoiceDate)  As nVarchar)
    In (IsNull((select Top 1
  Cast(Datepart(dd, ia.InvoiceDate) As nVarChar) + '/' +
  Cast(Datepart(mm, ia.InvoiceDate) As nVarChar) + '/' +   
  Cast(DatePart(YYYY, ia.InvoiceDate) As nVarchar)
  from invoiceabstract ia, InvoiceDetail idt
  where ia.Status & 192 = 0
  And ia.InvoiceType In (1, 3)
  And ia.invoiceDate Between @FromDate And  @ToDate
  And ia.CustomerID = inva.CustomerID  
  And ia.InvoiceID = idt.InvoiceID 
  And idt.Product_Code = invd.Product_Code
  Order By Cast(Datepart(dd, ia.InvoiceDate) As nVarChar) + '/' +
    Cast(Datepart(mm, ia.InvoiceDate) As nVarChar) + '/' +
    Cast(DatePart(YYYY, ia.InvoiceDate) As nVarchar)
  ), ''))
And inva.invoiceid = invd.invoiceid
And invd.Product_Code = ind.Product_code
),
  
(Select Sum(Quantity) From invoiceabstract inva, invoicedetail invd   where
inva.Status & 192 = 0
And inva.InvoiceType In (1, 3)
And inva.InvoiceDate Between @FromDate And  @ToDate
And invd.SalePrice > 0
And inva.CustomerID Not In ('0')
And inva.customerid in (Select Distinct CustomerID
   From invoiceabstract iab,invoicedetail idd
   Where
   iab.Status & 192 = 0
   And iab.InvoiceType In (1, 3)
   And invoiceDate Between @FromDate And  @ToDate
   And Cast(Datepart(dd, iab.InvoiceDate) As nVarChar) + '/' +
       Cast(Datepart(mm, iab.InvoiceDate) As nVarChar) + '/' +
       Cast(DatePart(YYYY, iab.InvoiceDate)  As nVarchar)
       Not In (IsNull((select Top 1 Cast(Datepart(dd, ia.InvoiceDate) As nVarChar) + '/' +
      Cast(Datepart(mm, ia.InvoiceDate) As nVarChar) + '/' +
      Cast(DatePart(YYYY, ia.InvoiceDate) As nVarchar)
      from invoiceabstract ia, InvoiceDetail idt
      where
      ia.Status & 192 = 0
      And ia.InvoiceType In (1, 3)
      And ia.invoiceDate Between @FromDate And  @ToDate
      And ia.CustomerID = iab.CustomerID
      And ia.InvoiceID = idt.InvoiceID
      And idt.Product_Code = idd.Product_Code
      Order By Cast(Datepart(dd, ia.InvoiceDate) As nVarChar) + '/' +
      Cast(Datepart(mm, ia.InvoiceDate) As nVarChar) + '/' +
      Cast(DatePart(YYYY, ia.InvoiceDate) As nVarchar)
         ), ''))
   And idd.Product_Code = invd.Product_Code
   And iab.InvoiceID = idd.InvoiceID
   )   
And Cast(Datepart(dd, inva.InvoiceDate) As nVarChar) + '/' +
    Cast(Datepart(mm, inva.InvoiceDate) As nVarChar) + '/' +
    Cast(DatePart(YYYY, inva.InvoiceDate)  As nVarchar)
    Not In (IsNull((select Top 1
      Cast(Datepart(dd, ia.InvoiceDate) As nVarChar) + '/' +
      Cast(Datepart(mm, ia.InvoiceDate) As nVarChar) + '/' +
      Cast(DatePart(YYYY, ia.InvoiceDate) As nVarchar)
     from invoiceabstract ia, InvoiceDetail idt
     where ia.Status & 192 = 0
     And ia.InvoiceType In (1, 3)
     And ia.invoiceDate Between @FromDate And  @ToDate
     And ia.CustomerID = inva.CustomerID
     And ia.InvoiceID = idt.InvoiceID 
     And idt.Product_Code = invd.Product_Code
     Order By Cast(Datepart(dd, ia.InvoiceDate) As nVarChar) + '/' +
       Cast(Datepart(mm, ia.InvoiceDate) As nVarChar) + '/' +
       Cast(DatePart(YYYY, ia.InvoiceDate) As nVarchar)
     ), ''))
And invd.Product_Code = ind.Product_code
And inva.invoiceid = invd.invoiceid
),
(Select Sum(Quantity) From invoiceabstract inva, invoicedetail invd
 where inva.Status & 192 = 0
 And inva.InvoiceType In (1, 3)
 And inva.InvoiceDate Between @FromDate And  @ToDate
 And invd.SalePrice =  0
 And CustomerID Not In ('0')
 And inva.invoiceid = invd.invoiceid
 And invd.Product_code = ind.Product_Code
)
  
From setup s, InvoiceAbstract ina, InvoiceDetail ind, Items its, UOM
Where ina.status & 192 = 0
And Ina.InvoiceType In (1, 3)
And ina.InvoiceDate Between @Fromdate And @Todate
And CustomerID Not In ('0')
And  ind.product_code In (select ItemCode From #Itm)
And its.UOM = UOM.UOM
And ina.InvoiceID = ind.InvoiceID
And ind.Product_Code = its.Product_Code
Group By s.registeredowner, ind.Product_Code, its.ProductName, UOM.[Description]
  
--Select * From #TempCatLevel Order by CatID

Insert InTo #TempConsolidate (IDS, WDDCode, ItemCode, ItemName,
NfPCers, NPC, RC, UM, Otps, RS, FSS, ASPC)
Select #tempCategory1.IDS, "WD Dest. Code" = WDC, "Item Code" = ItemCode, "Item Name" = ItemName,
"No of Potential Customers" =
Case (select Count(distinct(CustomerProductCategory.customerID)) from CustomerProductCategory,
customer,ItemCategories,#TempCatLevel
where CustomerProductCategory.active = 1
And Customer.Active = 1
And Customer.CustomerID Not In ('0')
And CustomerProductCategory.CustomerId= Customer.CustomerID
And CustomerProductCategory.CategoryID = #TempCatLevel.CatID
And ItemCategories.ParentID IN (Select ParentID From ItemCategories
Where CategoryID in (Select CatID From #TempCatLevel))) When 0 then
nfpc + (select Count(distinct(CustomerProductCategory.customerID)) from CustomerProductCategory,
customer,ItemCategories,#TempCatLevel
where CustomerProductCategory.active = 1
And Customer.Active = 1
And Customer.CustomerID Not In ('0')
And CustomerProductCategory.CustomerId= Customer.CustomerID
And CustomerProductCategory.CategoryID = #TempCatLevel.CatID
And ItemCategories.ParentID IN (Select ParentID From ItemCategories
Where CategoryID in (Select CatID From #TempCatLevel)))
Else
(select Count(distinct(CustomerProductCategory.customerID)) from CustomerProductCategory,
customer,ItemCategories,#TempCatLevel
where CustomerProductCategory.active = 1
And Customer.Active = 1
And Customer.CustomerID Not In ('0')
And CustomerProductCategory.CustomerId= Customer.CustomerID
And CustomerProductCategory.CategoryID = #TempCatLevel.CatID
And ItemCategories.ParentID IN (Select ParentID From ItemCategories
Where CategoryID in (Select CatID From #TempCatLevel)))
End,
"New Productive Customers" = npc, "Repeat Customers" = rc,
"UOM" = #tmp1.UOM, "1st time productive sale" = IsNull(otps, 0), "Repeat Sale" = IsNull(rs, 0),
"Free Sale/Sample Given" = IsNull(fss, 0),
"Average Sale Per Customer" = (IsNull(otps, 0) + IsNull(RS, 0) + IsNull(fss, 0)) / Case (npc) When 0 Then 1 Else (npc)  End
From #tmp1, items, #tempCategory1
Where
#tmp1.ItemCode = Items.Product_Code And
Items.CategoryID = #tempCategory1.CategoryID
order by #tempCategory1.IDS
  
If (Select Count(*) From Reports Where ReportName = 'New Product Launch Tracker Summary Report'
And ParameterID In (Select ParameterID From
dbo.GetReportParametersForChnLpNplCws('New Product Launch Tracker Summary Report') Where
FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)))>=1
Begin
 set @SPRExist =1
  
 Insert InTo #TempConsolidate (IDS, WDDCode, ItemCode, ItemName,
 NfPCers, NPC, RC, UM, Otps, RS, FSS, ASPC)
 Select #tempCategory1.IDS, IsNull(Field1, ''), IsNull(Field2, ''),
 IsNull(Field3, ''), IsNull(Field4, 0), IsNull(Field5, 0),
 IsNull(Field6, 0), IsNull(Field7, ''),
 IsNull(Field8, 0), IsNull(Field9, 0), IsNull(Field10, 0), IsNull(Field11, 0)
 From Reports, ReportAbstractReceived, items, #tempCategory1
 Where ReportAbstractReceived.Field2 <> @SKU
 and ReportAbstractReceived.Field1 <> @SUBTOTAL
 and ReportAbstractReceived.Field1 <> @GRNTOTAL
 and Reports.ReportID in
 (Select Distinct ReportID From Reports
 Where ReportName = 'New Product Launch Tracker Summary Report'
 And ParameterID in (Select ParameterID From dbo.GetReportParametersForChnLpNplCws('New Product Launch Tracker Summary Report') 
      Where FromDate = dbo.StripDateFromTime(@FromDate)
      And ToDate = dbo.StripDateFromTime(@ToDate)
      )
 )
 And Items.CategoryID = #tempCategory1.CategoryID
 And ReportAbstractReceived.ReportID = Reports.ReportID
 And ReportAbstractReceived.Field2 = Items.Product_Code
 --And ReportAbstractReceived.Field3 In (Select * From #TempMarketSKU)
End
  
Select Top 1 @CompaniesToUploadCode = ForumCode From Companies_To_Upload
Where ForumCode = N'ITC001'
  
Select Top 1 @WDCode = RegisteredOwner From Setup
  
If @CompaniesToUploadCode = 'ITC001'
Begin
 Update #TempConsolidate Set WDDCode = @WDCode
 Where WDDCode In (Select WareHouseID From Warehouse)
End
  
Update #TempConsolidate Set ItemName = ProductName
From Items Where Items.Product_Code = #TempConsolidate.ItemCode


Select IDS, "WD Dest. Code" = WDDCode, "Item Code" = ItemCode,
"Item Name" = ItemName, "No of Potential Customers" = Sum(NfPCers),
"New Productive Customers" = Sum(NPC), "Repeat Customers" = Sum(RC),
"UOM" = UM, "1st time productive sale" = Sum(Otps), "Repeat Sale" = Sum(RS),
"Free Sale/Sample Given" = Sum(FSS),
"Average Sale Per Customer" = (Sum(Otps) + Sum(RS) + Sum(FSS)) / Sum(NPC)-- Sum(ASPC)
From #TempConsolidate
Where ItemCode In (select ItemCode From #Itm)
Group By IDS, WDDCode, ItemCode, ItemName, UM  
Order By IDS, ItemCode
       
Drop Table #tmp1
Drop Table #itm
Drop Table #tempCategory1
Drop Table #TempConsolidate
Drop Table #TempCatLevel
End
  
