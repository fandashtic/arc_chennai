Create Procedure dbo.Sp_SKUOPT_DataPosting(@DayCloseFlag Int)
As  
Begin  
-- Declaration...
Declare @FromDate as DateTime
Declare @Todate as DateTime
Declare @Type as Int
Declare @WDSKUList as Int
Declare @SKUPortfolio as Int
Declare @HMSKU as Int
Declare @TranDate as dateTime
Declare @LastDaycloseDate as dateTime
Declare @E_FromDate as dateTime
Declare @ZMIN as Int
Declare @ZMAX as Int
Declare @CustomerId as Nvarchar(255)
Declare @CategoryGroup as Nvarchar(255)
Declare @MasterCategoryGroup as Nvarchar(255)
Declare @Formula as Nvarchar(255)
Declare @ProductLevel as Int
Declare @Sql as Nvarchar(4000)
Declare @GetCount as Int
Declare @FormulaCountValue as Decimal(18,6)
Declare @DiffCount as Int
Declare @Balance as Int
Declare @LEVEL as Int
Declare @L_Level as Int
Declare @L_CustomerID as Nvarchar(255)
Declare @DateCount as int
Declare @NewFromDate as Datetime
Declare @Id as int
Declare @SystemDate as dateTime
Declare @LastMonthFirstdate as dateTime
Declare @DeleteFlag as Int

Set DateFormat DMY
Set @SystemDate = dbo.stripdatefromtime(Getdate())
Set @LastMonthFirstdate = Cast(('01/'+ cast(Month(@SystemDate) as Nvarchar)  + '/' + cast(Year(@SystemDate) as Nvarchar)) as DateTime)
Set @DeleteFlag = 0
--Create Temp Tables...

Declare  @TempItemMaster as Table (
[SKUCode] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupName] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Category] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubCategory] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MarketSKU] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)

Declare  @TempRecevedSKU  as Table (
[E_FromDate] DateTime,
[CustomerID] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRIORITY] [int]  NULL,
[Product_Code] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
[LEVEL] [int]  NULL
)

Declare  @TempWDSKUListing  as Table (
[E_FromDate] DateTime Null,
[CategoryGroup] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ZMin] [int] NULL,
[ZMax] [int] NULL,
[Formula] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)

Declare @TempAllCustomer as Table 
([CustomerID] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

Declare @tempItem Table(Product_Code nvarchar(15),CategoryID int,SOH decimal(18,6))
Declare @tempSOH Table (CategoryID int,sumSOH decimal(18,6))
Declare @MaxProductCode Table (CategoryID int,Product_Code nvarchar(15))
Declare @tempMaxSOH Table(Product_Code nvarchar(15),CategoryID int,SOH decimal(18,6))
Declare @tmpfinal table (Product_Code nvarchar(15),CategoryID int,SOH decimal(18,6))
Declare @Prefinal table (Product_Code nvarchar(15),CategoryID int,SOH decimal(18,6))

CREATE TABLE #TempSales (
[Invoiceid] [int] NOT NULL,
[InvoiceDate] [datetime] NULL,
[InvoiceType] [int] NOT NULL,
[CustomerID] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Product_Code] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MarketSKU] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubCategory] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Category] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupName] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NetValue] [decimal](18, 6) NULL,
[StockOnHand] [decimal](18, 6) NULL
) ON [PRIMARY]

/* New Table Added for aggregation of MarketSKUs and rank the same */
Create table #TempSalesAgg
(
[GroupName] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MarketSKU] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NetValue] [decimal](18, 6) NULL,
[StockOnHand] [decimal](18, 6) NULL,
[Ranking] int null
)ON [PRIMARY]

Create table #TempSalesMaxAgg
(
[GroupName] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaxRank] int null,
[FormulaValue] int null,
[BalanceNumber] int null
)ON [PRIMARY]

Create Table  #TempAllSales (
[Invoiceid] [int] NOT NULL,
[InvoiceDate] [datetime] NULL,
[InvoiceType] [int] NOT NULL,
[CustomerID] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Product_Code] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MarketSKU] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubCategory] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Category] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupName] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NetValue] [decimal](18, 6) NULL,
[StockOnHand] [decimal](18, 6) NULL
)ON [PRIMARY]

CREATE TABLE #TempBalanceSKU (
[CustomerID] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRIORITY] [int] NULL,
[MarketSKU] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupName] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
) ON [PRIMARY]

CREATE TABLE #TempBalanceSKUWithRank (
[CustomerID] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRIORITY] [int] NULL,
[MarketSKU] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupName] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ranking] int NULL,
) ON [PRIMARY]	


CREATE TABLE #Temp (
[CustomerID] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MarketSKU] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
[GroupName] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
) ON [PRIMARY]


CREATE TABLE #TempCateGoryGroup (
[E_FromDate] DateTime Null,
[CategoryGroup] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZMax] [int] NULL,
[ZMin] [int] NULL,
[Formula] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

CREATE TABLE #TempMonthly (
	[Fromdate] [datetime] NULL,
	[Todate] [datetime] NULL,
	[SKUPortfolioID] [int] NULL,
	[WDSKUListID] [int] NULL,
	[HMSKUID] [int] NULL,
	[CustomerID] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SKU] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MARKETSKU] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GroupName] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NetValue] [decimal](18, 6) NULL,
	[StockOnHand] [decimal](18, 6) NULL,
	[Type] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Status] [int] NULL
) ON [PRIMARY]

Declare @tempHMSKU as Table(
	[CustomerID] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SKU] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MARKETSKU] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GroupName] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

/* For Monthly Optimization and finding the SKU Codes */

CREATE TABLE #tempMarketSKU (
	MKTSKU nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CategoryID int,
	Flag nvarchar(1) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
	OverallSOH decimal(18,6),
	SKU nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS
) ON [PRIMARY]

StartdataPosting:

-- Get Data From Master Table.....
Delete From @TempWDSKUListing
Delete From @TempRecevedSKU


select Top 1 @Type = Type,@FromDate = dbo.stripdatefromtime(FromDate),@Todate = dbo.stripdatefromtime(ToDate),@WDSKUList = WDSKUListID, @SKUPortfolio = SKUPortfolioID, @HMSKU = Isnull(HMSKUID,0) From tbl_SKUOPT_int
Insert Into @TempWDSKUListing Select EFFECTIVEFROMDATE,CATEGORYGROUP,ZMIN,ZMAX,FORM From WDSKUList Where Id = @WDSKUList And Active = 1
Insert into @TempRecevedSKU select EFFECTIVEFROMDATE,CUSTOMERID,PRODUCTPRIORITY,PRODUCTCODE,PRODUCTLEVEL From SKUPortfolio Where ID = @SKUPortfolio And Active = 1
Insert Into @tempHMSKU (CustomerID,SKU) Select Distinct CUSTOMERID,PRODUCTCODE From HMSKU Where Id = @HMSKU and Active = 1
-- If day close date is less than Dataposting todate then data posting is not happened...

IF @Type = 1
Begin
	If (select Top 1 LastInventoryUpload from setup) < dbo.stripdatefromtime(@Todate)
	Begin
		Goto Out
	End
End
-- Prepare Temp Item Master...

Insert into @TempItemMaster (SKUCode) select Distinct Product_code From Items where isnull(active,0)=1

Update T Set T.GroupName = T1.Categorygroup , T.Category = T1.Division , T.SubCategory = T1.Category_Name, T.MarketSKU = T2.Category_Name
From  @TempItemMaster T,
(select Distinct I.Product_code, IC3.categoryID, IC3.Category_Name, GR.Division, GR.Categorygroup
from items I , tblCGDivMapping GR, ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2
where IC4.categoryid = i.categoryid
and IC4.ParentId = IC3.categoryid
and IC3.ParentId = IC2.categoryid
and IC2.Category_Name = GR.Division) T1,
(select Distinct I.Product_code, IC4.categoryID, IC4.Category_Name, GR.Division, GR.Categorygroup
from items I , tblCGDivMapping GR, ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2
where IC4.categoryid = i.categoryid
and IC4.ParentId = IC3.categoryid
and IC3.ParentId = IC2.categoryid
and IC2.Category_Name = GR.Division) T2
Where  T1.Product_code = T.SKUCode
And T2.Product_code = T.SKUCode

Update T set T.MarketSKU = T1.MarketSKU, T.GroupName = T1.GroupName From @tempHMSKU T, @TempItemMaster T1 
Where T1.SKUCode = T.SKU

/* Not Required since data will be at MarketSKU Level 
-- If Received Level is category Then....

Insert into #TempBalanceSKU
select T.CustomerId,T.PRIORITY,T1.SKUCode,T.[LEVEL],T.Product_Code,T1.GroupName,0 From @TempRecevedSKU T, @TempItemMaster T1
Where T.Product_Code = T1.Category and T.Level = 2

-- If Received Level is Sub category Then....

Insert into #TempBalanceSKU
select T.CustomerId,T.PRIORITY,T1.SKUCode,T.[LEVEL],T.Product_Code,T1.GroupName,0 From @TempRecevedSKU T, @TempItemMaster T1
Where T.Product_Code = T1.SubCategory and T.Level = 3
*/
-- If Received Level is Market SKU Then....


Insert into #TempBalanceSKU
select distinct T.CustomerId,T.PRIORITY,T1.MarketSKU,T1.GroupName From @TempRecevedSKU T, @TempItemMaster T1
Where T.Product_Code = T1.MarketSKU and T.Level = 4

/* Not Required since data will be at MarketSKU Level 
-- If Received Level is SKU Then....

Insert into #TempBalanceSKU
select T.CustomerId,T.PRIORITY,T1.SKUCode,T.[LEVEL],T.Product_Code,T1.GroupName,0 From @TempRecevedSKU T, @TempItemMaster T1
Where T.Product_Code = T1.SKUCode and T.[Level] = 5


Update T Set T.MarketSKU = T1.MarketSKU, T.GroupName = T1.GroupName From #TempBalanceSKU T , @TempItemMaster T1 WHere T.Product_Code = T1.SKUCode
*/

-- As Per ITC CR, Data posting should happen for all the active retailers irrespective of SKU Portfoilo...

Insert into @TempAllCustomer
select Distinct CustomerId From Customer where Active=1

/* Requirement to be checked 
Insert into #TempBalanceSKU  (CustomerId)
select Distinct CustomerId From @TempCustomer Where 
Customerid In (Select Distinct CustomerID from InvoiceAbstract Where dbo.stripdatefromtime(Invoicedate) Between @FromDate and @Todate)
*/

-- Master data Completed.........................................................................................................................................................................................

-- Daily Data Posting Start...
If @Type = 0
Begin
	-- If MOthly data posting done for respected WDlist id and  SKUPortfolioID then only the Daily data posting start...
--	IF Not Exists (select Top 1 * from tbl_SKUOpt_Monthly Where SKUPortfolioID = @SKUPortfolio and WDSKUListID = @WDSKUList And Status = 1)
--	Begin
--		Goto Out
--	End
--	Else
	Begin
		If Exists (Select * From tbl_SKUOpt_Incremental Where SKUPortfolioID = @SKUPortfolio and WDSKUListID = @WDSKUList And Status = 1 and FromDate >= @FromDate)
		Begin
			Delete From tbl_SKUOpt_Incremental Where SKUPortfolioID = @SKUPortfolio and WDSKUListID = @WDSKUList And Status = 1 and FromDate >= @FromDate
			Set @DeleteFlag = 1
		End
		-- For Optimisation  Process... (04/01/2012)

		truncate table #TempAllSales

		Insert into #TempAllSales (Invoiceid,Invoicedate,InvoiceType,CustomerID,Product_Code,NetValue)
		Select Distinct IA.Invoiceid, dbo.stripdatefromtime(IA.Invoicedate) as InvoiceDate ,IA.InvoiceType,IA.CustomerID,ID.Product_Code,(ID.Amount) NetValue
		from Invoicedetail ID(Nolock),  InvoiceAbstract IA(Nolock)
		Where dbo.stripdatefromtime(IA.Invoicedate) Between @FromDate and @Todate
		And IA.InvoiceType in (1,3)
		And (IA.Status & 128) = 0
		And Id.Invoiceid = IA.Invoiceid
		Order By IA.Invoiceid Asc

		Update T set T.MARKETSKU = TI.MARKETSKU, T.SubCategory = TI.SubCategory , T.Category = TI.Category, T.GroupName = TI.GroupName
		From #TempAllSales T, @TempItemMaster TI
		Where T.Product_Code = TI.SKUCODE

		/* SOH check not required for Daily Sales
		Update T set T.StockOnHand = T1.BaseUOMQty From  @TempAllSales T,
		(select T.Product_Code,Sum(Isnull(T.Quantity,0) / Isnull(T1.UOM2_Conversion,1)) UOM2Qty, Sum(Isnull(T.Quantity,0)) BaseUOMQty from batch_products T, (select Product_Code,UOM2_Conversion from items) T1
		where T.Product_Code = T1.Product_Code and T.Quantity > 0 And Isnull(T.Free,0)=0 And isnull(T.Damage,0) = 0 Group By T.Product_Code) T1
		Where Isnull(T.StockOnHand,0) = 0
		And T1.UOM2Qty > 1
		And T1.Product_Code = T.Product_Code
		*/

		Declare @CurDaily Cursor

		/* Not Required for functionality
		Declare @OldFromDate as DateTime
		Set @OldFromDate = @FromDate
		*/

		Set @CurDaily = Cursor for
			Select CategoryGroup from @TempWDSKUListing
		Open @CurDaily
		Fetch Next from @CurDaily into @MasterCategoryGroup
		While @@fetch_status =0
		Begin

			Update tbl_SKUOpt_Incremental Set Status = 0 Where Status = 1 and SKUPortfolioId <> @SKUPortfolio
			Update tbl_SKUOpt_Incremental Set Status = 0 Where Status = 1 and WDSKUListID <> @WDSKUList


			Insert Into tbl_SKUOpt_Incremental
			(Fromdate,Todate,SKUPortfolioID,WDSKUListID,CustomerID,SKU,MARKETSKU,GroupName,NetValue,StockOnHand,Type,Status)
			select InvoiceDate,InvoiceDate,@SKUPortfolio,@WDSKUList,CustomerID,Product_Code,MARKETSKU,GroupName,
			Sum(NetValue),0,'Incremental',1
			from #TempAllSales T Where GroupName = @MasterCategoryGroup and
			CustomerId in (select Distinct CustomerId from @TempAllCustomer)
			Group By InvoiceDate,Product_Code,CustomerID,MARKETSKU,GroupName

			Update T set T.Type = 'Main'
			From tbl_SKUOpt_Incremental T, tbl_SKUOpt_Monthly TM where
			T.SKUPortfolioID=TM.SKUPortfolioID and 
			T.WDSKUListID=TM.WDSKUListID and
			T.CustomerID=TM.CustomerID and
			T.SKU=TM.SKU and TM.Status=1

			delete from tbl_SKUOpt_Incremental where Type = 'Main'

			update tbl_SKUOpt_Incremental set Status=1
			

			/* Why is this required ?, we need to post all those SKUs which are not in the main list but have been billed between the from an to dates
			Set @FromDate = @OldFromDate
			If @FromDate <> @Todate
			Begin
				Set @DateCount = Cast((DateDiff(Day,@FromDate, @Todate)) as Int)
			End
			Else
			Begin
				Set @DateCount = 0
			End

			Set @Id = 1

			While @Id <= (@DateCount + 1)
			Begin
				Declare @CurDailyNew Cursor
				Set @CurDailyNew = Cursor for
					Select Distinct Customerid from #TempBalanceSKU
				Open @CurDailyNew
				Fetch Next from @CurDailyNew into @Customerid
				While @@fetch_status =0
				Begin
				-- For Optimisation  Process... (04/01/2012)
					Truncate table #TempSales
					Insert into #TempSales
					Select * from @TempAllSales
					Where dbo.stripdatefromtime(Invoicedate) = @FromDate
					And CustomerID  = @Customerid

					Delete From @TempMaketSKU

					Insert Into @TempMaketSKU
					Select Distinct CustomerID,MarketSKU,0 From #TempSales
					Where GroupName = @MasterCategoryGroup And
					CustomerId = @Customerid
					And MarketSKU not In (select Distinct MARKETSKU from tbl_SKUOpt_Monthly Where SKUPortfolioID = @SKUPortfolio and WDSKUListID = @WDSKUList And Status = 1 AND CUSTOMERID = @CUSTOMERID)

					Truncate Table #Temp

					Insert Into #Temp
					select Distinct CustomerID,Product_Code,MarketSKU,GroupName, Sum(NetValue) NetValue, Sum(StockOnHand) StockOnHand, 0 From #TempSales
					Where MarketSKU In (select Distinct MarketSKU From @TempMaketSKU)
					Group By CustomerId,Product_Code,GroupName,MarketSKU,StockOnHand



					Update tbl_SKUOpt_Incremental Set Status = 0 Where Status = 1 and SKUPortfolioId <> @SKUPortfolio
					Update tbl_SKUOpt_Incremental Set Status = 0 Where Status = 1 and WDSKUListID <> @WDSKUList

					Insert Into tbl_SKUOpt_Incremental
					select Distinct @FROMDate,@FROMDate,@SKUPortfolio,@WDSKUList,CustomerID,Product_Code,MARKETSKU,GroupName,Sum(NetValue),Sum(StockOnHand),'Incremental',1
					from #Temp T Where MARKETSKU Not In (select Distinct MARKETSKU From tbl_SKUOpt_Monthly Where SKUPortfolioID = @SKUPortfolio and WDSKUListID = @WDSKUList And Status = 1 and customerid = @CustomerID)
					Group By Product_Code,CustomerID,MARKETSKU,GroupName
					Delete From @TempSKU


					Fetch Next from @CurDailyNew into @Customerid
			End
			Close @CurDailyNew
			Deallocate @CurDailyNew

			Set @FromDate = DateAdd(Day,+1,@FromDate)
			Set @Id = @Id + 1

			End
			*/

			Fetch Next from @CurDaily into @MasterCategoryGroup
		End
		Close @CurDaily
		Deallocate @CurDaily

		Truncate Table tbl_SKUOPT_int
		If @DayCloseFlag = 0
			Begin
				Insert Into tbl_SKUOPT_int (AlertFlag) select 1
			End
		Else If @DayCloseFlag = 1 and @DeleteFlag = 0
			Begin
				Insert Into tbl_SKUOPT_int (AlertFlag) select 1
			End
	End
End

-- Daily Data Posting End...
--*******************************************************************************************************************************************************************************************************************************************************************************************
-- Monthly Data Posting Start...

IF @Type = 1
Begin
	-- For Optimisation  Process... (04/01/2012)
	Truncate Table #TempSales

	Insert into #TempSales (Invoiceid,Invoicedate,InvoiceType,CustomerID,Product_Code,NetValue)
	Select Distinct IA.Invoiceid, dbo.stripdatefromtime(IA.Invoicedate) as InvoiceDate ,IA.InvoiceType,IA.CustomerID,ID.Product_Code,(ID.Amount) NetValue
	from Invoicedetail ID(Nolock),  InvoiceAbstract IA(Nolock)
	Where dbo.stripdatefromtime(IA.Invoicedate) Between @FromDate and @Todate
	And IA.InvoiceType in (1,3)
	And (IA.Status & 128) = 0
	And Id.Invoiceid = IA.Invoiceid
	And IA.CustomerId in (select Distinct CustomerId from @TempAllCustomer)
	Order By IA.Invoiceid Asc

	Update T set T.MARKETSKU = TI.MARKETSKU, T.SubCategory = TI.SubCategory , T.Category = TI.Category, T.GroupName = TI.GroupName
	From #TempSales T, @TempItemMaster TI
	Where T.Product_Code = TI.SKUCODE

	/* SOH Not Required as per latest requirement	
	Update T set T.StockOnHand = (select sum(Quantity) from batch_products where Isnull(Free,0)=0 And isnull(Damage,0) = 0 and Product_code=T.Product_code)
	from #TempSales T where Isnull(T.StockOnHand,0) = 0

	Update T set T.StockOnHand = (select sum(Quantity) from batch_products where Isnull(Free,0)=0 And isnull(Damage,0) = 0 and Product_code=T.Product_code)
	from #TempBalanceSKU T where Isnull(T.StockOnHand,0) = 0*/
	

	Declare @Cur Cursor
	Set @Cur = Cursor for
		Select E_FromDate,CategoryGroup,Zmax,Zmin,Formula from @TempWDSKUListing
	Open @Cur
	Fetch Next from @Cur into @E_FromDate,@MasterCategoryGroup,@ZMAX,@ZMIN,@Formula
	While @@fetch_status =0
	Begin

		Truncate table #TempCateGoryGroup
		Truncate table #TempSalesAgg
		Truncate table #TempSalesMaxAgg
		Truncate table #TempBalanceSKUWithRank

		Insert into #TempCateGoryGroup (E_FromDate,CategoryGroup,Zmax,Zmin,Formula) 
		select Top 1 E_FromDate,CategoryGroup,Zmax,Zmin,Formula From @TempWDSKUListing Where CategoryGroup = @MasterCategoryGroup	
		
		insert into #TempSalesAgg
		([Ranking],[CustomerID],[MarketSKU],[NetValue],[GroupName])
		select row_number() over (partition by CustomerID order by sum(NetValue) desc),CustomerID,MarketSKU,sum(NetValue) NetValue,GroupName 
		from #TempSales
		where GroupName=@MasterCategoryGroup
		group by CustomerID,MarketSKU,GroupName
	
		Set @Sql = ''
		Set @Sql = 'Select  GroupName,CustomerID,max(Ranking),round(' + replace(@Formula,'$n','max(Ranking)') + ',0),0 From #TempSalesAgg '
		Set @Sql = @Sql + ' where GroupName in (Select Distinct CategoryGroup From #TempCateGoryGroup) group by GroupName,CustomerID '
		
		Insert Into #TempSalesMaxAgg
		Exec (@Sql)

		update #TempSalesMaxAgg set [BalanceNumber]=
		case  
			when [FormulaValue]> @Zmax then 
				case 
					when (@Zmax - [MaxRank]) < 0 then 0
					else @Zmax - [MaxRank]
				end
			when [FormulaValue] < @Zmin then @Zmin-[MaxRank]
			else [FormulaValue] - [MaxRank]
		end ,
		[MaxRank]=
		case 
			when [MaxRank] >= @Zmax then @Zmax
			else   [MaxRank]
		end	where GroupName=@MasterCategoryGroup
		
		delete from #TempBalanceSKU where GroupName=@MasterCategoryGroup and (CustomerID + '#' + MarketSKU) in
		( select CustomerID + '#' + MarketSKU from #TempSalesAgg where GroupName=@MasterCategoryGroup)

		insert into #TempBalanceSKUWithRank 
		([Ranking],[CustomerID],[MarketSKU],[GroupName])
		select row_number() over (partition by CustomerID order by Priority),CustomerID,MarketSKU,GroupName
		from #TempBalanceSKU where GroupName=@MasterCategoryGroup

		Insert Into #Temp([CustomerID],[MarketSKU],[GroupName])
		select SA.CustomerID,SA.MarketSKU,SA.GroupName
		from #TempSalesAgg SA,#TempCateGoryGroup TCG,#TempSalesMaxAgg SMA
		where SA.GroupName=TCG.CategoryGroup and SA.CustomerID=SMA.CustomerID 
		and SA.Ranking <= SMA.MaxRank 
		

		Insert Into #Temp([CustomerID],[MarketSKU],[GroupName])
		select BSR.CustomerID,BSR.MarketSKU,BSR.GroupName
		from #TempBalanceSKUWithRank BSR,#TempCateGoryGroup TCG,#TempSalesMaxAgg SMA
		where BSR.GroupName=TCG.CategoryGroup and BSR.CustomerID=SMA.CustomerID 
		and BSR.Ranking <= SMA.BalanceNumber 

		/*

		Delete From @FormulaCount

		Declare @CurCustomer Cursor
		Set @CurCustomer = Cursor for
			select Distinct CustomerId From #TempBalanceSKU
		Open @CurCustomer
		Fetch Next from @CurCustomer into @CustomerID
		While @@fetch_status =0
		Begin
			Set @Sql = ''

			-- First take Tap max market sku form 6 Week sales....

			Delete From @TempMaketSKU

			Set @Sql = 'Select Distinct Top ' + cast(isNull(@ZMAX,0) as Nvarchar)+ ' ''' + @customerID + ''', MarketSKU,Sum(NetValue) NetValue  From #TempSales '
			Set @Sql = @Sql + 'Where CustomerId = ''' + @CustomerID + ''' And GroupName in (Select Distinct CategoryGroup From #TempCateGoryGroup) Group By MarketSKU Order by NetValue Desc'

			Insert Into @TempMaketSKU
			Exec (@Sql)

			--
			-- Based on select Market SKU the Items are Posted....

			Insert Into #Temp
			select Distinct T6.CustomerID,T6.Product_Code,T6.MarketSKU,T6.GroupName, Sum(T6.NetValue) NetValue, Sum(T6.StockOnHand) StockOnHand, 0 
			From #TempSales T6
			Where T6.CustomerId in (@CustomerID) and  T6.MarketSKU In (select Distinct MarketSKU From  @TempMaketSKU) --and T6.StockOnHand > 0
			Group By T6.CustomerId,T6.Product_Code,T6.GroupName,T6.MarketSKU,T6.StockOnHand


			Set @Balance = 0
			Set @GetCount = 0
			Set @FormulaCountValue = 0
			Set @Sql = ''

			Set @GetCount = Isnull((select Count(MarketSKU) from @TempMaketSKU Group By  CustomerID),0)


			--General query to find Formula value
			Begin Try
				Set @Sql = 'set @FormulaCountValue= (Select ' + Replace(@Formula,'n',@GetCount) +')'
				Execute sp_executesql @sql, N'@FormulaCountValue decimal(18,6) output', @FormulaCountValue=@FormulaCountValue output
			End Try
			Begin Catch
				set @FormulaCountValue = 0
			End Catch
			If (@FormulaCountValue > Round(@FormulaCountValue,0)) > 0
				Set @FormulaCountValue =  Round(@FormulaCountValue,0) + 1
			Else
				Set @FormulaCountValue =  Round(@FormulaCountValue,0)

			-- Total sales is less than or Eqal to Min....

			If @GetCount <= @zMin
			Begin
				If (@GetCount + @FormulaCountValue) < =@zMin
				Begin
					Set @Balance = Isnull((@zMin - @GetCount),0)
				End
				Else If (@GetCount + @FormulaCountValue) < =@zMax
				Begin
					Set @Balance = @FormulaCountValue
				End
				Else If (@GetCount + @FormulaCountValue) > @zMax
				Begin
					Set @Balance = Isnull((@zMax - @GetCount),0)
				End
			End
			Else If @GetCount < =@zMax 	-- Total sales is less than to Max and Greater than Min...
			Begin
				If (@GetCount + @FormulaCountValue) <= @zMax
				Begin
					Set @Balance = @FormulaCountValue
				End

				If (@GetCount + @FormulaCountValue) > @zMax
				Begin
					Set @Balance = (@zMax - @GetCount)
				End
			End

			-- If Need Balance Than only....
			If @Balance > 0
			Begin
				-- Here Take Distinct Market SKU from SKUPortfolio Where Market SKU not in 6 Week sales Order by PRIORITY Asc...

				Delete From @TempMaketSKU
				Set @Sql = ''
				Set @Sql = 'Select Distinct Top ' + cast(isNull(@Balance,0) as Nvarchar)+ ' ''' + @CustomerID  + ''', MarketSKU,PRIORITY From #TempBalanceSKU '
				Set @Sql = @Sql + 'Where CustomerId = ''' + @CustomerID + ''' And '
				Set @Sql = @Sql + 'MarketSKU Not In (select Distinct MarketSKU from #Temp Where CustomerID in (''' + @CustomerID + ''') )'
				Set @Sql = @Sql + ' And GroupName in (Select Distinct CategoryGroup From #TempCateGoryGroup) '--and GroupName='''+@CustomerID +''''
				Set @Sql = @Sql + 'Group By CustomerID,MarketSKU,PRIORITY Order by PRIORITY Asc'
				Insert Into @TempMaketSKU
				Exec (@Sql)

				Set @Sql = ''

				-- Based on select Market SKU the Items are Posted....

				IF @MasterCategoryGroup<>'ALL'
				Begin
					Insert Into #Temp
					select Distinct TB.CustomerID,TB.Product_Code,TB.MarketSKU,TB.GroupName, 0 NetValue, Sum(TB.StockOnHand) StockOnHand, TB.PRIORITY 
					From #TempBalanceSKU TB, @TempMaketSKU TM
					Where TB.CustomerID=@CustomerID and TB.CustomerID=TM.CustomerID and TB.GroupName=@MasterCategoryGroup and TB.MarketSKU=TM.MarketSKU
					and TB.MarketSKU not in (select Distinct MarketSKU From  #Temp where customerID=@CustomerID)
					Group By TB.CustomerId,TB.Product_Code,TB.GroupName,TB.MarketSKU,TB.StockOnHand,TB.PRIORITY
				End
				Else
				Begin
					Insert Into #Temp
					select Distinct TB.CustomerID,TB.Product_Code,TB.MarketSKU,TB.GroupName, 0 NetValue, Sum(TB.StockOnHand) StockOnHand, TB.PRIORITY 
					From #TempBalanceSKU TB, @TempMaketSKU TM
					Where TB.Customerid = @CustomerID and TB.Customerid=TM.Customerid and TB.MarketSKU=TM.MarketSKU
					and TB.MarketSKU not in (select Distinct MarketSKU From  #Temp where customerID=@CustomerID)
					--	Where TB.CustomerId in (select Distinct CustomerId From  @TempMaketSKU) and  TB.MarketSKU In (select Distinct MarketSKU From  @TempMaketSKU
					--	Where MarketSKU Not In (select Distinct MarketSKU From  #Temp where customerID=@CustomerID ) )
					Group By TB.CustomerId,TB.Product_Code,TB.GroupName,TB.MarketSKU,TB.StockOnHand,TB.PRIORITY
				End

				-- Additional SKU Posted...
				Delete From @TempSKU
				Insert into @TempSKU Select Distinct CustomerId,Product_Code,MarketSKU From #Temp Where CustomerId = @CustomerId

				Insert Into #Temp
				select Distinct T.CustomerID,T1.SKUCODE,T.MARKETSKU,T1.GroupName,0,0,0
				From @TempSKU T,@TempItemMaster T1
				Where T.MARKETSKU = T1.MARKETSKU And T1.SKUCODE not In( select Distinct Product_Code From @TempSKU Where customerid = @CustomerID)
				And T.CustomerID = @CustomerID

			End
			Fetch Next from @CurCustomer into @CustomerID
		End
		Close @CurCustomer
		Deallocate @CurCustomer
		*/
		Fetch Next from @Cur into @E_FromDate,@MasterCategoryGroup,@Zmax,@Zmin,@Formula
	End
	Close @Cur
	Deallocate @Cur

	Delete from tbl_SKUOpt_Monthly
	Delete from tbl_SKUOpt_Incremental

	truncate table #TempMonthly
	truncate table #tempMarketSKU

	Insert Into #TempMonthly
	select Distinct @FROMDate,@Todate,@SKUPortfolio,@WDSKUList,@HMSKU,a.CustomerID,b.SKUCode,a.MARKETSKU,a.GroupName,0,0,'MAIN' ,1
	from #Temp a,@TempItemMaster b 
	where a.MARKETSKU=b.MARKETSKU

	insert into #tempMarketSKU (MKTSKU,customerID,Flag,SKU)
	select distinct MarketSKU,customerID,'M',SKU from #TempMonthly where isnull(status,0)=1
	

	/* updating category ID*/
	update M set CategoryID=IC.CategoryID from #tempMarketSKU M, Itemcategories IC
	Where IC.Category_Name=M.MKTSKU
	and isnull(IC.active,0)=1

	/* Inserting into tempItemMaster */
	insert into @tempItem (Product_Code,CategoryID,SOH)
	Select I.Product_Code,I.CategoryID,sum(BP.Quantity) from items I,Batch_products BP where I.Product_Code in (Select SKU from #tempMarketSKU)
	and isnull(active,0)=1
	and BP.Product_Code=I.Product_Code
	and Isnull(BP.Free,0)=0 And isnull(BP.Damage,0) = 0
	Group by I.Product_Code,I.CategoryID


	/* updating sum of Stock On Hand*/
	insert into @tempSOH(CategoryID,sumSOH)
	Select CategoryID,sum(SOH) from @tempItem
	Group by CategoryID

	/* updating Stock On Hand in master table*/
	update M set OverallSOH=sumSOH from #tempMarketSKU M,@tempSOH S
	Where M.CategoryID=S.CategoryID

	/* For OverallSOH =0*/
	insert into @MaxProductCode(CategoryID,Product_Code)
	Select CategoryID,max(Product_Code) from items
	Where categoryId in (select CategoryID from #tempMarketSKU where isnull(OverallSOH,0)=0)
	and isnull(active,0)=1
	group by CategoryID

	Delete from #tempMarketSKU where SKU not in (select Product_Code from @MaxProductCode)
	And isnull(OverallSOH,0)=0

	/* For non zero SOH. As per ITC request, only one SKU with highest quantity should show in view */
	/* Start */
	insert into @tempMaxSOH (Product_Code,CategoryID,SOH)
	Select Product_Code,CategoryID,SOH from @tempItem
	where CategoryID in (select CategoryID from #tempMarketSKU)

	Declare @CID int
	Declare @Ident nvarchar(15)
	Declare @maxSOH decimal(18,6)
	/* Cursor is used to get the Maximum stock on hand for each CategoryID*/
	Declare AllCat Cursor For select CategoryID,max(SOH) as MAXSOH from @tempMaxSOH Group by CategoryID
	Open AllCat
	Fetch from Allcat into @CID,@maxSOH
	While @@fetch_status=0
	Begin

		insert into @tmpfinal(Product_Code,CategoryID,SOH)
		Select Product_Code,@CID,@maxSOH from @tempMaxSOH
		Where CategoryID=@CID and SOH=@maxSOH

		Fetch next from Allcat into @CID,@maxSOH
	End
	close Allcat
	Deallocate Allcat

	/* To handle the following scenario. If more than one product
	under same category has same SOH*/
	insert into @prefinal(Product_Code,CategoryID,SOH)
	Select max(Product_Code),CategoryID,max(SOH) from @tmpfinal
	Group by CategoryID

	Delete from #tempMarketSKU where SKU not in (select Product_Code from @prefinal) and isnull(overallSOH,0)>0
	/* End */

	insert into tbl_SKUOpt_Monthly(Fromdate,Todate,SKUPortfolioID,WDSKUListID,HMSKUID,CustomerID,SKU,MARKETSKU,GroupName,NetValue,StockOnHand,Type,Status)
	select TM.Fromdate,TM.Todate,TM.SKUPortfolioID,TM.WDSKUListID,TM.HMSKUID,TM.CustomerID,TM.SKU,TM.MARKETSKU,TM.GroupName,TM.NetValue,TM.StockOnHand,
	TM.Type,TM.Status
	from #tempMarketSKU M,Items I,#TempMonthly TM
	Where M.CategoryID=I.CategoryID and M.MKTSKU=TM.MarketSKU and  M.CustomerID=TM.CustomerID and M.SKU=TM.SKU
	And M.SKU=I.Product_code
	And isnull(i.active,0)=1

	/* Add HMSKU Into Monthly Table */
	insert into tbl_SKUOpt_Monthly(Fromdate,Todate,SKUPortfolioID,WDSKUListID,HMSKUID,CustomerID,SKU,MARKETSKU,GroupName,NetValue,StockOnHand,Type,Status)
	Select 	@FromDate,@Todate,@SKUPortfolio,@WDSKUList,@HMSKU,CUSTOMERID,SKU,MARKETSKU,GroupName,0,0,'HM',1 From @tempHMSKU 
	/*
	/*If A SKU and Customerid Set Is Already Available in HM Type then it is not required in Main Type*/
	Delete From tbl_SKUOpt_Monthly Where Type = 'MAIN' and Customerid in (select Distinct CustomerID From tbl_SKUOpt_Monthly Where Type = 'HM')
	And SKU In (select Distinct SKU From tbl_SKUOpt_Monthly Where Type = 'HM')
*/
	Truncate Table tbl_SKUOPT_int
	-- if Last day close date is greater then MOnth End day close date, the Daily data posting also done.

	Set @FromDate = dbo.stripdatefromtime(@LastMonthFirstdate)
	Set @Todate = (select dbo.stripdatefromtime(LastInventoryUpload) from setup)

	If @Todate < @FromDate
	Begin
		Set @FromDate = DateAdd(Day, +1,dbo.stripdatefromtime((select Top 1 Todate From tbl_SKUOpt_Monthly Where Status = 1 and SKUPortfolioId = @SKUPortfolio And WDSKUListID = @WDSKUList)))
		Exec Sp_SKUOPT_Daily_Int @FromDate,@Todate
		GoTo StartdataPosting
	End
	Else
	Begin
		Exec Sp_SKUOPT_Daily_Int @FromDate,@Todate
		GoTo StartdataPosting
	End
	If Exists(select * from tbl_SKUOpt_Monthly Where WDSKUListID = @WDSKUList and SKUPortfolioID = @SKUPortfolio and Status = 1)
		Begin
			Insert Into tbl_SKUOPT_int (AlertFlag) select 1
		End
	Else
		Begin
			Insert Into tbl_SKUOPT_int (AlertFlag) select 0
		End
End

-- MOnth Data Posting End...
-- Drop Temp Tables...

Out:
Drop table #Temp
Drop table #TempBalanceSKU
Drop table #TempSales
Drop table #TempSalesAgg
Drop table #TempCateGoryGroup
Drop table #TempSalesMaxAgg
Drop Table #TempBalanceSKUWithRank
Drop Table #TempAllSales
Drop table #TempMonthly
Drop table #tempMarketSKU




End
