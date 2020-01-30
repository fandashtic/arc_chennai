Create Procedure dbo.Sp_PM_DataPosting (@FromDate DateTime, @Todate DateTime)
As  
Begin
Set DateFormat DMY

Declare @MonthName as Nvarchar(25)
Set @MonthName = (select Left(DateName(Month,@Todate),3)+ '-' +  Cast(Year(@Todate) as Nvarchar(10)))

CREATE TABLE #TempData(
	[SalesManID] [int] NOT NULL,
	[DSTypeID] [int] NULL,
	[Groupname] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Category] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SubCategory] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[MarketSKU] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Product_code] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalesValue] Decimal (18,6) NULL Default (0)
) ON [PRIMARY]

CREATE TABLE #TempPostData(
	[InvoiceDate] DateTime Null,
	[SalesManID] [int] NOT NULL,
	[DSTypeID] [int] NULL,
	[Groupname] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
	[Category] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
	[SubCategory] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
	[MarketSKU] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
	[Product_code] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
	[SalesValue] Decimal (18,6) NULL Default (0)
) ON [PRIMARY]

CREATE TABLE #TempSales(
	[InvoiceDate] DateTime,
	[SalesManID] [int] NOT NULL,
	[DSTypeID] [int] NULL,
	[Product_code] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalesValue] Decimal (18,6) NULL  Default (0),
	[InvoiceType] [int] NOT NULL
) ON [PRIMARY]



If (Select isnull(Flag,0) From Tbl_merp_Configabstract Where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup')=0
Begin
	Insert into #TempData
	select S.SalesManID
	,DS.DSTypeID
	,GR.Categorygroup
	,IC2.Category_Name Category
	,IC3.Category_Name SubCategory
	,IC4.Category_Name MarketSKU 
	,I.Product_code ,0
	from items I , tblCGDivMapping GR, ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2, 
	ProductCategoryGroupAbstract PGR ,Salesman S, DSType_Details DS
	where IC4.categoryid = i.categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid 
	and IC2.Category_Name = GR.Division and GR.Categorygroup  = PGR.GroupName 
	And DS.DSTypeCtlPos = 1 And DS.SalesManID = S.SalesManID
	And GR.Categorygroup Not In ('GR4')
End
Else
Begin
	Insert into #TempData
	select S.SalesManID
	,DS.DSTypeID
	,PGR.groupName
	,IC2.Category_Name Category
	,IC3.Category_Name SubCategory
	,IC4.Category_Name MarketSKU 
	,I.Product_code ,0
	from items I, ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2, dbo.Fn_GetOCGSKU('%') Temp,
	ProductCategoryGroupAbstract PGR ,Salesman S, DSType_Details DS
	where IC4.categoryid = i.categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid 
	and I.Product_code=Temp.Product_code
	And PGR.GroupId=Temp.GroupID
	And DS.DSTypeCtlPos = 1 And DS.SalesManID = S.SalesManID 
	And PGR.OCGType=1
	And PGR.Active=1
	Delete from #TempData where Category in(Select Distinct Division from tblCGDivMapping where Categorygroup In ('GR4'))
End

Insert Into #TempSales(InvoiceDate, SalesManid, DSTypeID, Product_Code, SalesValue, InvoiceType)
select dbo.stripdatefromtime(IA.Invoicedate),IA.SalesManID,IA.DSTypeID,Id.Product_Code, Case When IA.InvoiceType in (1,3) Then Isnull(ID.Amount,0) When IA.InvoiceType in (4) Then (-(Isnull(ID.Amount,0))) End,  IA.InvoiceType 
from Invoicedetail ID(Nolock),  InvoiceAbstract IA(Nolock) 
		Where dbo.stripdatefromtime(IA.Invoicedate) Between @FromDate and @Todate
		And (IA.Status & 128) = 0
		And (IA.InvoiceType) in (1,3,4)
		And Id.Invoiceid = IA.Invoiceid
Order By IA.InvoiceType Asc

Insert into #TempPostData (InvoiceDate, SalesManid, DSTypeID, Product_Code, SalesValue)
select InvoiceDate, SalesManid, DSTypeID, Product_Code, sum(SalesValue) From #TempSales
Group By InvoiceDate, SalesManid, DSTypeID, Product_Code

Update T set T.Groupname = TD.Groupname,
T.Category = TD.Category,
T.SubCategory = TD.SubCategory,
T.MarketSKU = TD.MarketSKU
From #TempPostData T,  #TempData TD
Where T.Product_Code = TD.Product_Code

Delete From #TempPostData Where isnull(SalesValue,0) = 0
Delete From #TempPostData Where isnull(Groupname,'') = ''

If Exists (select * from PM_DS_Data Where dbo.stripdatefromtime(Invoicedate) >= @FromDate)
	Begin
		Delete From PM_DS_Data Where dbo.stripdatefromtime(Invoicedate) >= @FromDate
	End

Insert Into PM_DS_Data (SalesManId,DSTypeID,GroupName,Division,SubCategory,MarketSKU,Product_Code,SalesValue,CreationDate,ModifiedDate,Active,InvoiceDate)
select SalesManID,DSTypeID,Groupname,Category,SubCategory,MarketSKU,Product_code,SalesValue,Getdate(),Getdate(),1,InvoiceDate from #TempPostData

Update DayCloseModules set DayCloseDate = @Todate where Module = 'PM DataPosting'

--select * from PM_DS_Data

Drop table #TempData
Drop table #TempSales
Drop Table #TempPostData
End
