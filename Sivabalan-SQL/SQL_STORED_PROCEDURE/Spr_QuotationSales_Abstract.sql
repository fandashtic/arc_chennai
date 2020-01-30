Create Procedure [dbo].Spr_QuotationSales_Abstract(@ProductHierarchy Nvarchar(255), @Category Nvarchar(4000),@ItemCode Nvarchar(4000),@UOM Nvarchar(4000),@FromDate DateTime,@ToDate DateTime)
As   
Begin

	Set DateFormat DMY
	Declare @Delimeter as Char(1)
	Declare @DetailInput as Nvarchar(4000)
	Create Table #tempCategory (Category Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS Null)
	Create Table #tempItem (Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS Null)
	Declare @ForumCode as Nvarchar(255)
	Declare @WDName as Nvarchar(500)
	select @ForumCode = RegisteredOwner, @WDName = OrganisationTitle From SetUp

	CREATE TABLE #TempAbs(
		[Detail Info] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Item Code] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Item Name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UOM] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Qty] [decimal](18, 6) NULL,
		[Sales Value] [decimal](18, 6) NULL,
		[PTR Value] [decimal](18, 6) NULL,
		[Category] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Sub Category] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Market SKU] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL)

	Set @Delimeter=Char(15)        

	If @Category = '%'
		Begin
			Insert Into #tempCategory (Category) Select Distinct Category_Name From ItemCategories Where Level = 2
		End
	Else
		Begin
			Insert Into #tempCategory (Category)  select Category_Name From itemcategories Where Category_Name   In(Select * from dbo.sp_SplitIn2Rows(@Category,@Delimeter)) 
		End

	If @ItemCode = '%'
		Begin
			Insert Into #tempItem (Product_Code) Select Distinct Product_Code From Items
		End
	Else
		Begin
			Insert Into #tempItem (Product_Code)  select Distinct Product_Code From Items Where Product_Code   In(Select * from dbo.sp_SplitIn2Rows(@ItemCode,@Delimeter)) 
		End

	Insert into #TempAbs
	select ID.Product_Code [Detail Info],ID.Product_Code, I.ProductName, U.Description [UOM],

	Cast((Sum(Isnull(Case @UOM 
	When 'UOM1' Then (ID.Quantity / IsNull(I.UOM1_Conversion, 1))
	When 'UOM2' Then (ID.Quantity / IsNull(I.UOM2_Conversion, 1))
	Else (ID.Quantity )	End
	, 0))) as Decimal(18,6)) Qty,

	Cast((Sum(Isnull(((ID.Quantity) * (ID.SalePrice)), 0))) as Decimal(18,6)) [Sales Value],

	Cast((Sum(Isnull(((ID.Quantity) * (ID.PTR)), 0))) as Decimal(18,6))[PTR Value],

	GR.Division [Category],IC3.Category_Name [Sub Category],IC4.Category_Name [Market SKU]
	from items I , tblCGDivMapping GR, ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2 ,
	InvoiceAbstract IA(Nolock) , Invoicedetail ID(Nolock), UOM U
	where dbo.stripdatefromtime(IA.Invoicedate) Between @FromDate and @ToDate 
	And IA.InvoiceType in (1,3) 
	And (IA.Status & 128) = 0
	And IC4.categoryid = i.categoryid 
	And IC4.ParentId = IC3.categoryid 
	And IC3.ParentId = IC2.categoryid 
	And IC2.Category_Name = GR.Division 
	And GR.Division In(Select Distinct Category From #tempCategory)
	And I.Product_code In(Select Distinct Product_Code From #tempItem)
	And I.Product_code = ID.Product_code
	And ID.Invoiceid = IA.Invoiceid
	And Isnull(ID.QuotationID,0) > 0
	And U.Active = 1
	And U.UOM = (Select case @UOM When 'Base UOM' Then I.UOM When 'UOM1' then I.UOM1 When 'UOM2' then I.UOM2 End) 
	Group By ID.Product_code ,I.ProductName,GR.Division ,IC3.Category_Name,IC4.Category_Name,U.Description

	select [Detail Info],@ForumCode [ForumCode] ,@WDName [WD Name],[Item Code],
		[Item Name],[UOM],[Qty],[Sales Value] ,[PTR Value],[Category],[Sub Category], [Market SKU] from #TempAbs

	Drop table #tempCategory
	Drop table #TempAbs
	Drop table #tempItem


End
