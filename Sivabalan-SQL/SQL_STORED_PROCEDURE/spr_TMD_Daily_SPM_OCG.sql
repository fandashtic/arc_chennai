Create Procedure spr_TMD_Daily_SPM_OCG
(    
	@ToDate as DateTime    
)    
As    
Begin 
	Declare @SmanName as [nvarchar](4000)   
	Declare @SmanType as [nvarchar](4000)
	Declare @Hierarchy as [nvarchar](20) 
	Declare @CatGrp as [nvarchar](4000) 
	Declare @Category as [nvarchar](4000)
	Declare @FromDate as DateTime
	Declare @CompaniesToUploadCode as [nvarchar](255) 
	Declare @Delimeter as nVarchar      
	Declare @WDCode as [nvarchar](255) 
	Declare @WDDestCode as [nvarchar](255) 
	Declare @TOTOutlet [nvarchar](50) 
	Declare @SUBTOTAL [nvarchar](50) 
	Declare @GRNTOTAL [nvarchar](50) 
	Declare @CategoryType as [nvarchar](50) 

	Set @SUBTOTAL = dbo.LookupDictionaryItem(N'SubTotal:', Default)       
	Set @GRNTOTAL = dbo.LookupDictionaryItem(N'GrandTotal:', Default)       
	Set @TOTOutlet = dbo.LookupDictionaryItem(N'Total Outlets', Default)     
	Set @Delimeter = char(15)    
	set dateformat DMY
	set @FromDate = cast(('01/' + cast(month(@ToDate) as nvarchar) + '/' + cast(year(@ToDate) as nvarchar)) as datetime)

	Create Table #tmpOutputData([WDCode] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS ,
			[WD Code] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS ,    
			[WD Dest Code] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS , 
			[From Date] DateTime, [To Date] DateTime, 
			[Salesman ID] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS ,
			[Salesman Name] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS ,    
			[Salesman Type] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS ,
			[Category Level] nVarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS ,    
			[Total Outlets] Int,
			[MTD_TTL No. of Bills] Int,
			[MTD_Unique Outlets Billed] Int,
			[MTD_Total Bill Qty] Decimal(18,6),    
			[MTD_Total Bill Value] Decimal(18,6),    
			[MTD_Net Bill Qty] Decimal(18,6),    
			[MTD_Net Bill Value]  Decimal(18,6),    
			[MTD_TTL No. of Lines]  Int,
			[MTD_TTL Unique Lines Cut] Int
			,[MTD_No. of Days Worked] Int
			,[DAY_TTL No. of Bills] Int
			,[DAY_Unique Outlets Billed] Int
			,[DAY_Total Bill Qty] Decimal(18,6)
			,[DAY_Total Bill Value] Decimal(18,6)
			,[Day_Net Bill Qty] Decimal(18,6)
			,[Day_Net Bill Value] Decimal(18,6)
			,[DAY_TTL No. of Lines] Int
			,[DAY_TTL Unique Lines Cut] Int
			,[Category Type Level] Nvarchar(50)) 

	Declare @OCGFlag as Int
	Set @OCGFlag = (select Top 1 Isnull(Flag,0) Flag from tbl_merp_Configabstract where screenCode = 'OCGDS')

	Set @CategoryType = 'Regular'

StartProcess:

Create Table #tempOut ( 
			S_id Int,
			S_Name [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			S_type [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			Cat_level [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			Tot_Outlet Int,
			MTD_TotBill Int,
			MTD_uni_Outlet Int,
			MTD_Total_Bill_Qty Decimal(18,6),
			MTD_Totbillvalue Decimal(18,6),
			MTD_Net_Bill_Qty Decimal(18,6),
			MTD_Net_Bill_Value Decimal(18,6),
			MTD_TotLines Int,
			MTD_uni_Lines Int,
			MTD_Workdays Int,
			TD_TotBill Int,
			TD_Uni_Outlet Int,
			TD_Total_Bill_Qty Decimal(18,6),
			TD_Totbillvalue Decimal(18,6),
			TD_Net_Bill_Qty Decimal(18,6),
			TD_Net_Bill_Value Decimal(18,6),
			TD_Totlines Int,
			TD_Uni_Lines Int,
			ord int)

Create Table #tmpSManType(SmanID Int)    
Create Table #tmpSman(SmanID Int)    
Create Table #tmpSManID(SmanID Int)    
Create Table #tmpcatgroup(CatGroup [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)  
Create Table #tmpcat(Cat [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)  
Create Table #tmpOutput([WDCode] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS ,
		[WD Code] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS ,    
		[WD Dest Code] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS , 
		[From Date] DateTime, [To Date] DateTime, 
		[Salesman ID] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS ,
		[Salesman Name] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS ,    
		[Salesman Type] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS ,
		[Category Level] nVarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS ,    
		[Total Outlets] Int,
		[MTD_TTL No. of Bills] Int,
		[MTD_Unique Outlets Billed] Int,
		[MTD_Total Bill Qty] Decimal(18,6),    
		[MTD_Total Bill Value] Decimal(18,6),    
		[MTD_Net Bill Qty] Decimal(18,6),    
		[MTD_Net Bill Value]  Decimal(18,6),    
		[MTD_TTL No. of Lines]  Int,
		[MTD_TTL Unique Lines Cut] Int
		,[MTD_No. of Days Worked] Int
		,[DAY_TTL No. of Bills] Int
		,[DAY_Unique Outlets Billed] Int
		,[DAY_Total Bill Qty] Decimal(18,6)
		,[DAY_Total Bill Value] Decimal(18,6)
		,[Day_Net Bill Qty] Decimal(18,6)
		,[Day_Net Bill Value] Decimal(18,6)
		,[DAY_TTL No. of Lines] Int
		,[DAY_TTL Unique Lines Cut] Int
		) 
Create Table #tmpsalesman (S_id Int,S_Name [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,S_Type [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
Create Table #tmpcategory (Product_code [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,categoryID Int,Category_Name [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,Brandname [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,Categorygroup [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
Create Table #Group_Level (Cal_Level nvarchar (255) COLLATE SQL_Latin1_General_CP1_CI_AS, Levels int)
Create Table #tempInvoiceidAll (Checked [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,I_id Int,Customerid [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,Salesmanid Int,Salesman_Name [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, Salesman_Type [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,Netvalue Decimal(18,6),Invoicedate DateTime,Product_Code [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,Subcategory [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, Division [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, GroupID [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL , Quantity Decimal (18,6) , SalePrice Decimal (18,6), InvoiceType Int )
Create Table #TempCat_1 (Customerid [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,Salesmanid int,categoryid [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,category_name [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,GroupName [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,ParentID Int, ParentName [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
Create Table #Cat_1 (Sub_Category  [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,Division  [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,CategoryGroup [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
Create Table #tempInvoiceid (Checked [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,I_id Int,Customerid [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,Salesmanid Int,Salesman_Name [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, Salesman_Type [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,Netvalue Decimal(18,6),Invoicedate DateTime,Product_Code [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,Subcategory [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, Division [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, GroupID [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL , Quantity Decimal (18,6) ,SalePrice Decimal (18,6), InvoiceType Int)
Create Table #tempInvoiceidToday (Checked [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,I_id Int,Customerid [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,Salesmanid Int,Salesman_Name [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, Salesman_Type [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,Netvalue Decimal(18,6),Invoicedate DateTime,Product_Code [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,Subcategory [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, Division [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, GroupID [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL , Quantity Decimal (18,6) ,SalePrice Decimal (18,6), InvoiceType Int)
Create Table #Outletdata (salesmanid Int, customerid [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, DSTypeid Int , GROUPID Int, GroupName [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL )
Create Table #TmpLines (Product_Code [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, Invoiceid [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,Salesmanid [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,Subcategory [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, Division [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, GroupID [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,Checked [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
Create Table #TmpLinesToday (Product_Code [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, Invoiceid [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,Salesmanid [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,Subcategory [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, Division [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, GroupID [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,Checked [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)



	Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload        
	Select Top 1 @WDCode = RegisteredOwner From Setup          
	
	If @CompaniesToUploadCode='ITC001'        
		Set @WDDestCode= @WDCode        
	Else        
	Begin        
		Set @WDDestCode= @WDCode        
		Set @WDCode= @CompaniesToUploadCode        
	End 	

--*****************************************************************************************************************************************************************************************************************************************************************
--Get All SalesmanID for DSType Mapping
	Insert Into #tmpSManType    
	Select SalesManID From Salesman    
--*****************************************************************************************************************************************************************************************************************************************************************
--Get All SalesmanID 
	Insert Into #tmpSman    
	Select SalesmanID From Salesman    
--*****************************************************************************************************************************************************************************************************************************************************************
--Update Salesman Type 
	Insert Into #tmpSManID    
	Select T.SmanID    
	From #tmpSManType T,#tmpSman S    
	Where T.SmanID = S.SmanID    
--*****************************************************************************************************************************************************************************************************************************************************************
--Get Category GroupID
IF @CategoryType = 'Regular'
Begin  
	Insert Into #tmpcatgroup
	select Distinct CategoryGroup from tblCGDivMapping
End
Else
Begin
	Insert Into #tmpcatgroup
	Select Distinct GroupName From ProductCategoryGroupAbstract Where Isnull(OCGType,0) = 1 and Active = 1
End
--*****************************************************************************************************************************************************************************************************************************************************************
insert into #tmpsalesman 
select s.salesmanid,s.salesman_name,DSM.DSTypevalue from salesman s, DSType_Details DSD, DSType_Master DSM
where DSD.salesmanid = s.salesmanid and
DSD.DSTypeCtlPos = 1 and
DSM.DStypeid = DSD.DStypeid order by s.salesmanid asc
--*****************************************************************************************************************************************************************************************************************************************************************
IF @CategoryType = 'Regular'
Begin
	insert into #tmpcategory 
	select I.Product_code, IC4.categoryID, IC4.Category_Name, GR.Division, GR.Categorygroup 
	from items I , tblCGDivMapping GR, ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2 where
	IC4.categoryid = i.categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid 
	and IC2.Category_Name = GR.Division
End
Else
Begin
	insert into #tmpcategory 
	select I.Product_Code,IC4.CategoryID, IC4.Category_Name, IC2.Category_Name,P.GroupName 
	from Fn_GetOCGSKU('%') I,ProductCategoryGroupAbstract P,
	ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2
	Where P.GroupID = I.GroupID
	And P.Active = 1
	And IC4.categoryid = i.categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid 
End
	Declare @categoryid as [nvarchar](255)
	Declare @clu Cursor 
	Set @clu = Cursor for
	Select categoryid from #tmpcategory
	Open @clu
	Fetch Next from @clu into @categoryid
	While @@fetch_status =0
		Begin
			Update #tmpcategory set Category_Name = 
			(select Category_Name from ItemCategories 
			where categoryid in (select Parentid from ItemCategories Where categoryid = @categoryid)) Where categoryid = @categoryid
			Fetch Next from @clu into @categoryid
		End
	Close @clu
	Deallocate @clu

	Insert Into #tmpcat 	select Distinct BrandName from #tmpcategory
	Insert Into #tmpcat 	select Distinct Category_Name from #tmpcategory
--*****************************************************************************************************************************************************************************************************************************************************************
--Get Group Level for Set Report Order by.....
Insert Into #Group_Level values ('All',1)
Insert Into #Group_Level (Cal_Level) (select Distinct CategoryGroup from #tmpcategory)
Update #Group_Level set Levels = 2 where isnull(Levels,0) = 0
Insert Into #Group_Level (Cal_Level) (select Distinct Brandname from #tmpcategory)
Update #Group_Level set Levels = 3 where isnull(Levels,0) = 0
Insert Into #Group_Level (Cal_Level) (select Distinct Category_name from #tmpcategory)
Update #Group_Level set Levels = 4 where isnull(Levels,0) = 0
--*****************************************************************************************************************************************************************************************************************************************************************
--Get All Invoice details form First date to Tilldate....
IF @CategoryType = 'Regular'
Begin
	Insert into #tempInvoiceidAll 
	select 'All',IA.Invoiceid,IA.Customerid,IA.Salesmanid,Null,Null,
	Case When IA.InvoiceType in (1,3) Then ID.Amount
								When IA.InvoiceType in (4) Then (- ID.Amount)
								End,
	DATEADD(dd, 0, DATEDIFF(dd, 0,IA.Invoicedate)),
	 ID.Product_Code,Null,Null,Null,
	Case When IA.InvoiceType in (1,3) Then ID.Quantity
								When IA.InvoiceType in (4) Then (- ID.Quantity)
								End,ID.SalePrice,IA.InvoiceType
	from invoiceabstract IA , invoiceDetail ID,#tmpSManID T1S
	Where dbo.striptimefromdate(Invoicedate) between dbo.striptimefromdate(@FromDate) and dbo.striptimefromdate(@ToDate) 
	and ( IsNull(IA.Status,0) & 128 = 0) -- and IA.InvoiceType in(1,3) 
	And IA.Invoiceid = ID.Invoiceid  and IA.Salesmanid = T1S.SmanID 
--	And ID.GroupID  in(select Distinct GroupID From ProductCategoryGroupAbstract Where isnull(OCGType,0) = 0)
	Order by IA.Invoiceid asc 
End
Else
Begin
	Insert into #tempInvoiceidAll 
	select 'All',IA.Invoiceid,IA.Customerid,IA.Salesmanid,Null,Null,
	Case When IA.InvoiceType in (1,3) Then ID.Amount
							When IA.InvoiceType in (4) Then (- ID.Amount)
							End,
	DATEADD(dd, 0, DATEDIFF(dd, 0,IA.Invoicedate)),
	 ID.Product_Code,Null,Null,Null,
	Case When IA.InvoiceType in (1,3) Then ID.Quantity
							When IA.InvoiceType in (4) Then (- ID.Quantity)
							End,ID.SalePrice,IA.InvoiceType
	from invoiceabstract IA , invoiceDetail ID,#tmpSManID T1S
	Where dbo.striptimefromdate(Invoicedate) between dbo.striptimefromdate(@FromDate) and dbo.striptimefromdate(@ToDate) 
	and ( IsNull(IA.Status,0) & 128 = 0) -- and IA.InvoiceType in(1,3) 
	And IA.Invoiceid = ID.Invoiceid  and IA.Salesmanid = T1S.SmanID 
--	And ID.GroupID  in(select Distinct GroupID From ProductCategoryGroupAbstract Where isnull(OCGType,0) = 1)
	Order by IA.Invoiceid asc 

End
Update #tempInvoiceidAll set Quantity = 0 Where SalePrice = 0
Update TI set TI.Salesman_Name = TS.S_Name ,TI.Salesman_Type = TS.S_Type From #tempInvoiceidAll TI, #tmpsalesman TS Where TI.Salesmanid = TS.S_Id
Update TI Set TI.Subcategory = TC.Category_Name,TI.Division = TC.Brandname, TI.GroupID  = TC.Categorygroup From #tempInvoiceidAll TI, #tmpcategory TC Where TI.Product_code = TC.Product_code
--*****************************************************************************************************************************************************************************************************************************************************************
--Collect Master level data for calculate Total Outlet Column...
--Insert into #TempCat_1 (Customerid,Salesmanid,categoryid,category_name)
--select BS.Customerid,BS.salesmanid,CPC.categoryid,IC.category_name 
--from CustomerProductCategory CPC ,ItemCategories IC,beat_salesman BS,Customer C
--where BS.Customerid = CPC.Customerid
--And C.Active = 1 and C.CustomerCategory <> 5 
--and IC.categoryid = CPC.categoryid
--And CPC.Customerid= C.Customerid

IF @CategoryType = 'Regular'
Begin
	Insert into #Cat_1 Select  T2.CNT as Sub_Category ,T3.CNT as Division, GM.CategoryGroup from (select Categoryid,Parentid ,Category_Name CNT from ItemCategories Where Level = 3) T2
							,(select Categoryid,Parentid ,Category_Name CNT from ItemCategories Where Level = 2) T3
							,tblCGDivMapping GM where T3.Categoryid = T2.Parentid and GM.Division = T3.CNT  order by 2 asc
End
Else
Begin
	Insert into #Cat_1 Select  T2.CNT as Sub_Category ,T3.CNT as Division, GM.CategoryGroup from (select Categoryid,Parentid ,Category_Name CNT from ItemCategories Where Level = 3) T2
							,(select Categoryid,Parentid ,Category_Name CNT from ItemCategories Where Level = 2) T3
							,(select Distinct IC2.Category_Name Division,G.GroupName CategoryGroup
							  from Fn_GetOCGSKU('%')F, ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2, ProductCategoryGroupAbstract G
							  where IC4.categoryid = F.Categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid 
							  And G.GroupID = F.GroupID) GM where T3.Categoryid = T2.Parentid and GM.Division = T3.CNT  order by 2 asc
--	Insert into #Cat_1 select Distinct IC3.Category_Name,IC2.Category_Name,G.GroupName
--	from Fn_GetOCGSKU('%')F, ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2, ProductCategoryGroupAbstract G
--	where IC4.categoryid = F.Categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid 
--	And G.GroupID = F.GroupID
End

Insert into #TempCat_1 (Customerid,Salesmanid,categoryid,category_name,GroupName)
select BS.Customerid,BS.salesmanid,CPC.categoryid,IC.category_name ,T2.CategoryGroup
from CustomerProductCategory CPC ,ItemCategories IC,beat_salesman BS,Customer C,#Cat_1 T2
where BS.Customerid = CPC.Customerid
And C.Active = 1 and C.CustomerCategory <> 5 
and IC.categoryid = CPC.categoryid
And CPC.Customerid= C.Customerid
And IC.Category_Name = T2.Sub_Category

Insert into #TempCat_1 (Customerid,Salesmanid,categoryid,category_name,GroupName)
select BS.Customerid,BS.salesmanid,CPC.categoryid,IC.category_name ,T2.CategoryGroup
from CustomerProductCategory CPC ,ItemCategories IC,beat_salesman BS,Customer C,#Cat_1 T2
where BS.Customerid = CPC.Customerid
And C.Active = 1 and C.CustomerCategory <> 5 
and IC.categoryid = CPC.categoryid
And CPC.Customerid= C.Customerid
And IC.Category_Name = T2.Division

--Update T1  Set T1.GroupName = T2.Cnt  from #TempCat_1 T1,(Select Distinct Division,CategoryGroup as Cnt from #Cat_1) T2
--Where T1.Category_Name = T2.Division
--Update T1  Set T1.GroupName = T2.Cnt  from #TempCat_1 T1,(Select Distinct Sub_Category,CategoryGroup as Cnt from #Cat_1) T2
--Where T1.Category_Name = T2.Sub_Category
Update T  Set T.Parentid = IC.Parentid from ItemCategories IC, #TempCat_1 T Where IC.CateGoryid = T.CateGoryid
Update T  Set T.ParentName = IC.category_name from ItemCategories IC, #TempCat_1 T Where IC.CateGoryid = T.Parentid
Update #TempCat_1 set ParentName = category_name Where ParentName = 'ITD'
Delete from #TempCat_1 where GroupName is null 
--*****************************************************************************************************************************************************************************************************************************************************************
--Split data for Monthly data....
	Insert into #tempInvoiceid
	select * from #tempInvoiceidAll where GroupID in (select CatGroup From #tmpcatgroup) and Division in (select Distinct Cat from #tmpcat)
	Insert into #tempInvoiceid
	select * from #tempInvoiceidAll where GroupID in (select CatGroup From #tmpcatgroup) and Subcategory in (select Distinct Cat from #tmpcat)
--*****************************************************************************************************************************************************************************************************************************************************************
--Splite data for Daily (Today) data....
Insert into #tempInvoiceidToday select TI.* from #tempInvoiceid TI Where dbo.striptimefromdate(TI.Invoicedate) = dbo.striptimefromdate(@ToDate)
--*****************************************************************************************************************************************************************************************************************************************************************
Insert Into #TmpLines select Distinct TI.Product_Code,TI.I_Id,Ti.Salesmanid,TI.Subcategory,TI.Division,TI.Groupid,'All' from  #tempInvoiceid TI  Where InvoiceType in (1,3)
--*****************************************************************************************************************************************************************************************************************************************************************
Insert Into #TmpLinesToday select Distinct TI.Product_Code,TI.I_Id,Ti.Salesmanid,TI.Subcategory,TI.Division,TI.Groupid,'All' from  #tempInvoiceidToday TI  Where InvoiceType in (1,3)
--*****************************************************************************************************************************************************************************************************************************************************************
insert into  #Outletdata select BS.salesmanid,BS.customerid,DSD.DSTypeid,DSMP.GROUPID,DSGM.GroupName 
from beat_salesman BS ,customer C  , DSType_Details DSD,  tbl_mERP_DSTypeCGMapping DSMP, ProductCategoryGroupAbstract DSGM
Where BS.salesmanid = DSD.salesmanid And DSD.DSTypeid = DSMP.DSTypeid and isnull(BS.customerid,0) <> '' and isnull(BS.salesmanid,0) <> 0 and 
BS.customerid = c.customerid and c.active = 1 and CustomerCategory <> 5 and isnull(DSD.DSTypectlpos,0) = 1 and DSMP.GROUPID = DSGM.GROUPID and isnull(DSMP.Active,0) = 1 order by 1,3,2,4 asc
--*****************************************************************************************************************************************************************************************************************************************************************
Truncate Table #tempOut
IF Isnull(@OCGFlag,0) = 1 
Begin
	IF @CategoryType = 'Operational'
	Begin
		Insert Into #tempOut(Cat_level) values ('All')
		Insert Into #tempOut(Cat_level) select Distinct Division from #tempInvoiceid Group By Division 
		Insert Into #tempOut(Cat_level) select Distinct Subcategory from #tempInvoiceid Group By Subcategory
	End
End
Else
Begin
	Insert Into #tempOut(Cat_level) values ('All')
	Insert Into #tempOut(Cat_level) select Distinct Division from #tempInvoiceid Group By Division 
	Insert Into #tempOut(Cat_level) select Distinct Subcategory from #tempInvoiceid Group By Subcategory
End
Insert Into #tempOut(Cat_level) select Distinct Groupid from #tempInvoiceid Group By Groupid
--Insert Into #tempOut(Cat_level) select Distinct Division from #tempInvoiceid Group By Division 
--Insert Into #tempOut(Cat_level) select Distinct Subcategory from #tempInvoiceid Group By Subcategory

update #tempOut set S_id = '', S_Name = 'All Salesman', S_type = 'All Ds Types',Tot_Outlet = Null where isnull(s_id,0) = 0 

Insert Into #tempOut(S_id,S_Name,S_type,Cat_level,Tot_Outlet)
select Salesmanid,Salesman_Name,Salesman_Type,Null,Null from #tempInvoiceid Group By Salesmanid,Salesman_Name,Salesman_Type Order by Salesmanid,Salesman_Type Asc

Update #tempOut Set Cat_level = 'All' Where Cat_level is Null

Insert Into #tempOut(S_id,S_Name,S_type,Cat_level,Tot_Outlet)
select Salesmanid,Salesman_Name,Salesman_Type,Groupid,Null from #tempInvoiceid Group By Salesmanid,Salesman_Name,Salesman_Type,Groupid Order by Salesmanid,Salesman_Type Asc

		Insert Into #tempOut(S_id,S_Name,S_type,Cat_level,Tot_Outlet)
		select Salesmanid,Salesman_Name,Salesman_Type,Division,Null from #tempInvoiceid Group By Salesmanid,Salesman_Name,Salesman_Type,Division Order by Salesmanid,Salesman_Type Asc
		Insert Into #tempOut(S_id,S_Name,S_type,Cat_level,Tot_Outlet)
		select Salesmanid,Salesman_Name,Salesman_Type,Subcategory,Null from #tempInvoiceid Group By Salesmanid,Salesman_Name,Salesman_Type,Subcategory Order by Salesmanid,Salesman_Type Asc

--*****************************************************************************************************************************************************************************************************************************************************************
--Data Update for Month Till to date.................
--*****************************************************************************************************************************************************************************************************************************************************************

Update #tempOut set Tot_Outlet = (Select Count( Distinct customerid) from customer where active = 1 and CustomerCategory <> 5 )  Where Cat_level = 'All' and isnull(s_id,0) = 0
Update T1  Set T1.Tot_Outlet = isnull(T2.Cnt,0)  from #tempOut T1,(Select salesmanid,Count( Distinct customerid) as Cnt from #Outletdata Group By salesmanid) T2 Where T1.s_id = T2.salesmanid and Cat_level = 'All' 
Update T1  Set T1.Tot_Outlet = isnull(T2.Cnt,0)  from #tempOut T1,(Select GroupName,Count( Distinct customerid) as Cnt from #TempCat_1 Group By GroupName) T2 Where T1.Cat_level = T2.GroupName and S_type = 'All Ds Types'
Update T1  Set T1.Tot_Outlet = isnull(T2.Cnt,0)  from #tempOut T1,(Select Category_Name,Count( Distinct customerid) as Cnt from #TempCat_1 Group By Category_Name) T2 Where T1.Cat_level = T2.Category_Name and S_type = 'All Ds Types'
Update T1  Set T1.Tot_Outlet = isnull(T2.Cnt,0)  from #tempOut T1,(Select ParentName,Count( Distinct customerid) as Cnt from #TempCat_1 Group By ParentName) T2 Where T1.Cat_level = T2.ParentName and S_type = 'All Ds Types'
Update T1  Set T1.Tot_Outlet = isnull(T2.Cnt,0)  from #tempOut T1,(Select GroupName,Salesmanid,Count( Distinct customerid) as Cnt from #TempCat_1 Group By GroupName,Salesmanid) T2 Where T1.Cat_level = T2.GroupName and isnull(s_id,0) = T2.Salesmanid and isnull(s_id,0) <> 0
Update T1  Set T1.Tot_Outlet = isnull(T2.Cnt,0)  from #tempOut T1,(Select Category_Name,Salesmanid,Count( Distinct customerid) as Cnt from #TempCat_1 Group By Category_Name,Salesmanid) T2 Where T1.Cat_level = T2.Category_Name and isnull(s_id,0) = T2.Salesmanid and isnull(s_id,0) <> 0
Update T1  Set T1.Tot_Outlet = isnull(T2.Cnt,0)  from #tempOut T1,(Select ParentName,Salesmanid,Count( Distinct customerid) as Cnt from #TempCat_1 Group By ParentName,Salesmanid) T2 Where T1.Cat_level = T2.ParentName and isnull(s_id,0) = T2.Salesmanid and isnull(s_id,0) <> 0
update #tempOut set Tot_Outlet = 0 where isnull(Tot_Outlet,0) =0
Update #tempOut set MTD_TotBill = (Select Count( Distinct I_id) from #tempInvoiceid Where InvoiceType in (1,3)) Where isnull(s_id,0) = 0 and Cat_level = 'All' 
Update #tempOut set MTD_uni_Outlet = (Select Count( Distinct Customerid) from #tempInvoiceid Where InvoiceType in (1,3)) Where isnull(s_id,0) = 0 and Cat_level = 'All' 
Update #tempOut set MTD_Total_Bill_Qty = (Select Sum(Quantity)/2 from #tempInvoiceid Where InvoiceType in (1,3)) Where isnull(s_id,0) = 0 and Cat_level = 'All' 
Update #tempOut set MTD_Totbillvalue = (Select Sum(Netvalue)/2 from #tempInvoiceid Where InvoiceType in (1,3)) Where isnull(s_id,0) = 0 and Cat_level = 'All' 
Update #tempOut set MTD_Net_Bill_Qty = (Select Sum(Quantity)/2 from #tempInvoiceid) Where isnull(s_id,0) = 0 and Cat_level = 'All' 
Update #tempOut set MTD_Net_Bill_value = (Select Sum(Netvalue)/2 from #tempInvoiceid) Where isnull(s_id,0) = 0 and Cat_level = 'All' 
Update #tempOut set MTD_TotLines = (Select Count( Product_Code) from #TmpLines) Where isnull(s_id,0) = 0 and Cat_level = 'All' 
Update #tempOut set MTD_uni_Lines = (Select Count( Distinct Product_Code) from #tempInvoiceid Where InvoiceType in (1,3)) Where isnull(s_id,0) = 0 and Cat_level = 'All' 
Update #tempOut set MTD_Workdays = (Select Count( Distinct Invoicedate) from #tempInvoiceid Where InvoiceType in (1,3)) Where isnull(s_id,0) = 0 --and Cat_level = 'All' 
Update T1  Set T1.MTD_TotBill = T2.Cnt  from #tempOut T1,(Select Groupid,Count( Distinct I_id) as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by Groupid) T2 Where T1.Cat_level = T2.Groupid and isnull(T1.s_id,0) = 0  
Update T1  Set T1.MTD_uni_Outlet = T2.Cnt  from #tempOut T1,(Select Groupid,Count( Distinct Customerid) as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by Groupid) T2 Where T1.Cat_level = T2.Groupid and isnull(T1.s_id,0) = 0  
Update T1  Set T1.MTD_Total_Bill_Qty = T2.Cnt  from #tempOut T1,(Select Groupid,Sum(Quantity)/2 as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by Groupid) T2 Where T1.Cat_level = T2.Groupid and isnull(T1.s_id,0) = 0  
Update T1  Set T1.MTD_Totbillvalue = T2.Cnt  from #tempOut T1,(Select Groupid,Sum(Netvalue)/2 as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by Groupid) T2 Where T1.Cat_level = T2.Groupid and isnull(T1.s_id,0) = 0  
Update T1  Set T1.MTD_Net_Bill_Qty = T2.Cnt  from #tempOut T1,(Select Groupid,Sum(Quantity)/2 as Cnt from #tempInvoiceid Group by Groupid) T2 Where T1.Cat_level = T2.Groupid and isnull(T1.s_id,0) = 0  
Update T1  Set T1.MTD_Net_Bill_value = T2.Cnt  from #tempOut T1,(Select Groupid,Sum(Netvalue)/2 as Cnt from #tempInvoiceid Group by Groupid) T2 Where T1.Cat_level = T2.Groupid and isnull(T1.s_id,0) = 0  
Update T1  Set T1.MTD_TotLines = T2.Cnt  from #tempOut T1,(Select Groupid,Count( Product_Code) as Cnt  from #TmpLines Group by Groupid) T2 Where T1.Cat_level = T2.Groupid and isnull(T1.s_id,0) = 0  
Update T1  Set T1.MTD_uni_Lines = T2.Cnt  from #tempOut T1,(Select Groupid,Count( Distinct Product_Code) as Cnt  from #tempInvoiceid Where InvoiceType in (1,3) Group by Groupid) T2 Where T1.Cat_level = T2.Groupid and isnull(T1.s_id,0) = 0  
--Update T1  Set T1.MTD_Workdays = T2.Cnt  from #tempOut T1,(Select Groupid,Count( Distinct Invoicedate) as Cnt  from #tempInvoiceid Group by Groupid) T2 Where T1.Cat_level = T2.Groupid and isnull(T1.s_id,0) = 0  
Update T1  Set T1.MTD_TotBill = T2.Cnt  from #tempOut T1,(Select Division,Count( Distinct I_id) as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by Division) T2 Where T1.Cat_level = T2.Division and isnull(T1.s_id,0) = 0  
Update T1  Set T1.MTD_uni_Outlet = T2.Cnt  from #tempOut T1,(Select Division,Count( Distinct Customerid) as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by Division) T2 Where T1.Cat_level = T2.Division and isnull(T1.s_id,0) = 0  
Update T1  Set T1.MTD_Total_Bill_Qty = T2.Cnt  from #tempOut T1,(Select Division,Sum(Quantity)/2 as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by Division) T2 Where T1.Cat_level = T2.Division and isnull(T1.s_id,0) = 0  
Update T1  Set T1.MTD_Totbillvalue = T2.Cnt  from #tempOut T1,(Select Division,Sum(Netvalue)/2 as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by Division) T2 Where T1.Cat_level = T2.Division and isnull(T1.s_id,0) = 0  
Update T1  Set T1.MTD_Net_Bill_Qty = T2.Cnt  from #tempOut T1,(Select Division,Sum(Quantity)/2 as Cnt from #tempInvoiceid Group by Division) T2 Where T1.Cat_level = T2.Division and isnull(T1.s_id,0) = 0  
Update T1  Set T1.MTD_Net_Bill_value = T2.Cnt  from #tempOut T1,(Select Division,Sum(Netvalue)/2 as Cnt from #tempInvoiceid Group by Division) T2 Where T1.Cat_level = T2.Division and isnull(T1.s_id,0) = 0  
Update T1  Set T1.MTD_TotLines = T2.Cnt  from #tempOut T1,(Select Division,Count( Product_Code) as Cnt  from #TmpLines Group by Division) T2 Where T1.Cat_level = T2.Division and isnull(T1.s_id,0) = 0  
Update T1  Set T1.MTD_uni_Lines = T2.Cnt  from #tempOut T1,(Select Division,Count( Distinct Product_Code) as Cnt  from #tempInvoiceid Where InvoiceType in (1,3) Group by Division) T2 Where T1.Cat_level = T2.Division and isnull(T1.s_id,0) = 0  
--Update T1  Set T1.MTD_Workdays = T2.Cnt  from #tempOut T1,(Select Division,Count( Distinct Invoicedate) as Cnt  from #tempInvoiceid Group by Division) T2 Where T1.Cat_level = T2.Division and isnull(T1.s_id,0) = 0  
Update T1  Set T1.MTD_TotBill = T2.Cnt  from #tempOut T1,(Select Subcategory,Count( Distinct I_id) as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by Subcategory) T2 Where T1.Cat_level = T2.Subcategory and isnull(T1.s_id,0) = 0  
Update T1  Set T1.MTD_uni_Outlet = T2.Cnt  from #tempOut T1,(Select Subcategory,Count( Distinct Customerid) as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by Subcategory) T2 Where T1.Cat_level = T2.Subcategory and isnull(T1.s_id,0) = 0  
Update T1  Set T1.MTD_Total_Bill_Qty = T2.Cnt  from #tempOut T1,(Select Subcategory,Sum(Quantity)/2 as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by Subcategory) T2 Where T1.Cat_level = T2.Subcategory and isnull(T1.s_id,0) = 0  
Update T1  Set T1.MTD_Totbillvalue = T2.Cnt  from #tempOut T1,(Select Subcategory,Sum(Netvalue)/2 as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by Subcategory) T2 Where T1.Cat_level = T2.Subcategory and isnull(T1.s_id,0) = 0  
Update T1  Set T1.MTD_Net_Bill_Qty = T2.Cnt  from #tempOut T1,(Select Subcategory,Sum(Quantity)/2 as Cnt from #tempInvoiceid Group by Subcategory) T2 Where T1.Cat_level = T2.Subcategory and isnull(T1.s_id,0) = 0  
Update T1  Set T1.MTD_Net_Bill_value = T2.Cnt  from #tempOut T1,(Select Subcategory,Sum(Netvalue)/2 as Cnt from #tempInvoiceid Group by Subcategory) T2 Where T1.Cat_level = T2.Subcategory and isnull(T1.s_id,0) = 0  
Update T1  Set T1.MTD_TotLines = T2.Cnt  from #tempOut T1,(Select Subcategory,Count( Product_Code) as Cnt  from #TmpLines Group by Subcategory) T2 Where T1.Cat_level = T2.Subcategory and isnull(T1.s_id,0) = 0  
Update T1  Set T1.MTD_uni_Lines = T2.Cnt  from #tempOut T1,(Select Subcategory,Count( Distinct Product_Code) as Cnt  from #tempInvoiceid Where InvoiceType in (1,3) Group by Subcategory) T2 Where T1.Cat_level = T2.Subcategory and isnull(T1.s_id,0) = 0  
--Update T1  Set T1.MTD_Workdays = T2.Cnt  from #tempOut T1,(Select Subcategory,Count( Distinct Invoicedate) as Cnt  from #tempInvoiceid Group by Subcategory) T2 Where T1.Cat_level = T2.Subcategory and isnull(T1.s_id,0) = 0  
Update T1  Set T1.MTD_TotBill = T2.Cnt  from #tempOut T1,(Select salesmanid,Count( Distinct I_id) as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by salesmanid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level = 'All'  
Update T1  Set T1.MTD_uni_Outlet = T2.Cnt  from #tempOut T1,(Select salesmanid,Count( Distinct Customerid) as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by salesmanid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level = 'All' 
Update T1  Set T1.MTD_Total_Bill_Qty = T2.Cnt  from #tempOut T1,(Select salesmanid,Sum(Quantity)/2 as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by salesmanid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level = 'All' 
Update T1  Set T1.MTD_Totbillvalue = T2.Cnt  from #tempOut T1,(Select salesmanid,Sum(Netvalue)/2 as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by salesmanid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level = 'All' 
Update T1  Set T1.MTD_Net_Bill_Qty = T2.Cnt  from #tempOut T1,(Select salesmanid,Sum(Quantity)/2 as Cnt from #tempInvoiceid Group by salesmanid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level = 'All' 
Update T1  Set T1.MTD_Net_Bill_value = T2.Cnt  from #tempOut T1,(Select salesmanid,Sum(Netvalue)/2 as Cnt from #tempInvoiceid Group by salesmanid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level = 'All' 
Update T1  Set T1.MTD_TotLines = T2.Cnt  from #tempOut T1,(Select salesmanid,Count( Product_Code) as Cnt  from #TmpLines Group by salesmanid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level = 'All' 
Update T1  Set T1.MTD_uni_Lines = T2.Cnt  from #tempOut T1,(Select salesmanid,Count( Distinct Product_Code) as Cnt  from #tempInvoiceid Where InvoiceType in (1,3) Group by salesmanid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level = 'All' 
--Update T1  Set T1.MTD_Workdays = T2.Cnt  from #tempOut T1,(Select salesmanid,Count( Distinct Invoicedate) as Cnt  from #tempInvoiceid Group by salesmanid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level = 'All' 
Update T1  Set T1.MTD_TotBill = T2.Cnt  from #tempOut T1,(Select salesmanid,Groupid,Count( Distinct I_id) as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by salesmanid,Groupid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Groupid 
Update T1  Set T1.MTD_uni_Outlet = T2.Cnt  from #tempOut T1,(Select salesmanid,Groupid,Count( Distinct Customerid) as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by salesmanid,Groupid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Groupid
Update T1  Set T1.MTD_Total_Bill_Qty = T2.Cnt  from #tempOut T1,(Select salesmanid,Groupid,Sum(Quantity)/2 as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by salesmanid,Groupid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Groupid
Update T1  Set T1.MTD_Totbillvalue = T2.Cnt  from #tempOut T1,(Select salesmanid,Groupid,Sum(Netvalue)/2 as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by salesmanid,Groupid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Groupid
Update T1  Set T1.MTD_Net_Bill_Qty = T2.Cnt  from #tempOut T1,(Select salesmanid,Groupid,Sum(Quantity)/2 as Cnt from #tempInvoiceid Group by salesmanid,Groupid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Groupid
Update T1  Set T1.MTD_Net_Bill_value = T2.Cnt  from #tempOut T1,(Select salesmanid,Groupid,Sum(Netvalue)/2 as Cnt from #tempInvoiceid Group by salesmanid,Groupid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Groupid
Update T1  Set T1.MTD_TotLines = T2.Cnt  from #tempOut T1,(Select salesmanid,Groupid,Count( Product_Code) as Cnt  from #TmpLines Group by salesmanid,Groupid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Groupid
Update T1  Set T1.MTD_uni_Lines = T2.Cnt  from #tempOut T1,(Select salesmanid,Groupid,Count( Distinct Product_Code) as Cnt  from #tempInvoiceid Where InvoiceType in (1,3) Group by salesmanid,Groupid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Groupid
--Update T1  Set T1.MTD_Workdays = T2.Cnt  from #tempOut T1,(Select salesmanid,Groupid,Count( Distinct Invoicedate) as Cnt  from #tempInvoiceid Group by salesmanid,Groupid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Groupid
Update T1  Set T1.MTD_TotBill = T2.Cnt  from #tempOut T1,(Select salesmanid,Division,Count( Distinct I_id) as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by salesmanid,Division) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Division 
Update T1  Set T1.MTD_uni_Outlet = T2.Cnt  from #tempOut T1,(Select salesmanid,Division,Count( Distinct Customerid) as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by salesmanid,Division) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Division
Update T1  Set T1.MTD_Total_Bill_Qty = T2.Cnt  from #tempOut T1,(Select salesmanid,Division,Sum(Quantity)/2 as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by salesmanid,Division) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Division
Update T1  Set T1.MTD_Totbillvalue = T2.Cnt  from #tempOut T1,(Select salesmanid,Division,Sum(Netvalue)/2 as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by salesmanid,Division) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Division
Update T1  Set T1.MTD_Net_Bill_Qty = T2.Cnt  from #tempOut T1,(Select salesmanid,Division,Sum(Quantity)/2 as Cnt from #tempInvoiceid Group by salesmanid,Division) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Division
Update T1  Set T1.MTD_Net_Bill_value = T2.Cnt  from #tempOut T1,(Select salesmanid,Division,Sum(Netvalue)/2 as Cnt from #tempInvoiceid Group by salesmanid,Division) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Division
Update T1  Set T1.MTD_TotLines = T2.Cnt  from #tempOut T1,(Select salesmanid,Division,Count( Product_Code) as Cnt  from #TmpLines Group by salesmanid,Division) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Division
Update T1  Set T1.MTD_uni_Lines = T2.Cnt  from #tempOut T1,(Select salesmanid,Division,Count( Distinct Product_Code) as Cnt  from #tempInvoiceid Where InvoiceType in (1,3) Group by salesmanid,Division) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Division
--Update T1  Set T1.MTD_Workdays = T2.Cnt  from #tempOut T1,(Select salesmanid,Division,Count( Distinct Invoicedate) as Cnt  from #tempInvoiceid Group by salesmanid,Division) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Division
Update T1  Set T1.MTD_TotBill = T2.Cnt  from #tempOut T1,(Select salesmanid,Subcategory,Count( Distinct I_id) as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by salesmanid,Subcategory) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Subcategory 
Update T1  Set T1.MTD_uni_Outlet = T2.Cnt  from #tempOut T1,(Select salesmanid,Subcategory,Count( Distinct Customerid) as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by salesmanid,Subcategory) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Subcategory
Update T1  Set T1.MTD_Total_Bill_Qty = T2.Cnt  from #tempOut T1,(Select salesmanid,Subcategory,Sum(Quantity)/2 as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by salesmanid,Subcategory) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Subcategory
Update T1  Set T1.MTD_Totbillvalue = T2.Cnt  from #tempOut T1,(Select salesmanid,Subcategory,Sum(Netvalue)/2 as Cnt from #tempInvoiceid Where InvoiceType in (1,3) Group by salesmanid,Subcategory) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Subcategory
Update T1  Set T1.MTD_Net_Bill_Qty = T2.Cnt  from #tempOut T1,(Select salesmanid,Subcategory,Sum(Quantity)/2 as Cnt from #tempInvoiceid Group by salesmanid,Subcategory) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Subcategory
Update T1  Set T1.MTD_Net_Bill_value = T2.Cnt  from #tempOut T1,(Select salesmanid,Subcategory,Sum(Netvalue)/2 as Cnt from #tempInvoiceid Group by salesmanid,Subcategory) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Subcategory
Update T1  Set T1.MTD_TotLines = T2.Cnt  from #tempOut T1,(Select salesmanid,Subcategory,Count( Product_Code) as Cnt  from #TmpLines Group by salesmanid,Subcategory) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Subcategory
Update T1  Set T1.MTD_uni_Lines = T2.Cnt  from #tempOut T1,(Select salesmanid,Subcategory,Count( Distinct Product_Code) as Cnt  from #tempInvoiceid Where InvoiceType in (1,3) Group by salesmanid,Subcategory) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Subcategory
--Update T1  Set T1.MTD_Workdays = T2.Cnt  from #tempOut T1,(Select salesmanid,Subcategory,Count( Distinct Invoicedate) as Cnt  from #tempInvoiceid Group by salesmanid,Subcategory) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Subcategory
Update T1  Set T1.MTD_Workdays = T2.Cnt  from #tempOut T1,(Select salesmanid,Count( Distinct Invoicedate) as Cnt  from #tempInvoiceid Where InvoiceType in (1,3) Group by salesmanid) T2 Where T1.S_ID = T2.salesmanid
update #tempOut set MTD_TotBill = 0 where isnull(MTD_TotBill,0) =0
update #tempOut set MTD_uni_Outlet = 0 where isnull(MTD_uni_Outlet,0) =0
update #tempOut set MTD_Total_Bill_Qty = 0 where isnull(MTD_Total_Bill_Qty,0) =0
update #tempOut set MTD_Totbillvalue = 0 where isnull(MTD_Totbillvalue,0) =0
update #tempOut set MTD_Net_Bill_Qty = 0 where isnull(MTD_Net_Bill_Qty,0) =0
update #tempOut set MTD_Net_Bill_value = 0 where isnull(MTD_Net_Bill_value,0) =0
update #tempOut set MTD_TotLines = 0 where isnull(MTD_TotLines,0) =0
update #tempOut set MTD_uni_Lines = 0 where isnull(MTD_uni_Lines,0) =0
update #tempOut set MTD_Workdays = 0 where isnull(MTD_Workdays,0) =0
--*****************************************************************************************************************************************************************************************************************************************************************
--Data Update for To date.................
--*****************************************************************************************************************************************************************************************************************************************************************

Update #tempOut set TD_TotBill = (Select Count( Distinct I_id) from #tempInvoiceidToday Where InvoiceType in (1,3)) Where isnull(s_id,0) = 0 and Cat_level = 'All' 
Update #tempOut set TD_Uni_Outlet = (Select Count( Distinct Customerid) from #tempInvoiceidToday Where InvoiceType in (1,3)) Where isnull(s_id,0) = 0 and Cat_level = 'All' 
Update #tempOut set TD_Total_Bill_Qty = (Select Sum(Quantity)/2 from #tempInvoiceidToday Where InvoiceType in (1,3)) Where isnull(s_id,0) = 0 and Cat_level = 'All' 
Update #tempOut set TD_Totbillvalue = (Select Sum(Netvalue)/2 from #tempInvoiceidToday Where InvoiceType in (1,3)) Where isnull(s_id,0) = 0 and Cat_level = 'All' 
Update #tempOut set TD_Net_Bill_Qty = (Select Sum(Quantity)/2 from #tempInvoiceidToday) Where isnull(s_id,0) = 0 and Cat_level = 'All' 
Update #tempOut set TD_Net_Bill_Value = (Select Sum(Netvalue)/2 from #tempInvoiceidToday) Where isnull(s_id,0) = 0 and Cat_level = 'All' 
Update #tempOut set TD_Totlines = (Select Count( Product_Code) from #TmpLinesToday) Where isnull(s_id,0) = 0 and Cat_level = 'All' 
Update #tempOut set TD_Uni_Lines = (Select Count( Distinct Product_Code) from #tempInvoiceidToday Where InvoiceType in (1,3)) Where isnull(s_id,0) = 0 and Cat_level = 'All' 
Update T1  Set T1.TD_TotBill = T2.Cnt  from #tempOut T1,  (Select Groupid,Count( Distinct I_id) as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by Groupid) T2 Where T1.Cat_level = T2.Groupid and isnull(T1.s_id,0) = 0  
Update T1  Set T1.TD_Uni_Outlet = T2.Cnt  from #tempOut T1,(Select Groupid,Count( Distinct Customerid) as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by Groupid) T2 Where T1.Cat_level = T2.Groupid and isnull(T1.s_id,0) = 0  
Update T1  Set T1.TD_Total_Bill_Qty = T2.Cnt  from #tempOut T1,(Select Groupid,Sum(Quantity)/2 as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by Groupid) T2 Where T1.Cat_level = T2.Groupid and isnull(T1.s_id,0) = 0  
Update T1  Set T1.TD_Totbillvalue = T2.Cnt  from #tempOut T1,(Select Groupid,Sum(Netvalue)/2 as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by Groupid) T2 Where T1.Cat_level = T2.Groupid and isnull(T1.s_id,0) = 0  
Update T1  Set T1.TD_Net_Bill_Qty = T2.Cnt  from #tempOut T1,(Select Groupid,Sum(Quantity)/2 as Cnt from #tempInvoiceidToday Group by Groupid) T2 Where T1.Cat_level = T2.Groupid and isnull(T1.s_id,0) = 0  
Update T1  Set T1.TD_Net_Bill_Value = T2.Cnt  from #tempOut T1,(Select Groupid,Sum(Netvalue)/2 as Cnt from #tempInvoiceidToday Group by Groupid) T2 Where T1.Cat_level = T2.Groupid and isnull(T1.s_id,0) = 0  
Update T1  Set T1.TD_Totlines = T2.Cnt  from #tempOut T1,(Select Groupid,Count( Product_Code) as Cnt  from #TmpLinesToday Group by Groupid) T2 Where T1.Cat_level = T2.Groupid and isnull(T1.s_id,0) = 0  
Update T1  Set T1.TD_Uni_Lines = T2.Cnt  from #tempOut T1,(Select Groupid,Count( Distinct Product_Code) as Cnt  from #tempInvoiceidToday Where InvoiceType in (1,3) Group by Groupid) T2 Where T1.Cat_level = T2.Groupid and isnull(T1.s_id,0) = 0  
Update T1  Set T1.TD_TotBill = T2.Cnt  from #tempOut T1,(Select Division,Count( Distinct I_id) as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by Division) T2 Where T1.Cat_level = T2.Division and isnull(T1.s_id,0) = 0  
Update T1  Set T1.TD_Uni_Outlet = T2.Cnt  from #tempOut T1,(Select Division,Count( Distinct Customerid) as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by Division) T2 Where T1.Cat_level = T2.Division and isnull(T1.s_id,0) = 0  
Update T1  Set T1.TD_Total_Bill_Qty = T2.Cnt  from #tempOut T1,(Select Division,Sum(Quantity)/2 as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by Division) T2 Where T1.Cat_level = T2.Division and isnull(T1.s_id,0) = 0  
Update T1  Set T1.TD_Totbillvalue = T2.Cnt  from #tempOut T1,(Select Division,Sum(Netvalue)/2 as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by Division) T2 Where T1.Cat_level = T2.Division and isnull(T1.s_id,0) = 0  
Update T1  Set T1.TD_Net_Bill_Qty = T2.Cnt  from #tempOut T1,(Select Division,Sum(Quantity)/2 as Cnt from #tempInvoiceidToday Group by Division) T2 Where T1.Cat_level = T2.Division and isnull(T1.s_id,0) = 0  
Update T1  Set T1.TD_Net_Bill_Value = T2.Cnt  from #tempOut T1,(Select Division,Sum(Netvalue)/2 as Cnt from #tempInvoiceidToday Group by Division) T2 Where T1.Cat_level = T2.Division and isnull(T1.s_id,0) = 0  
Update T1  Set T1.TD_Totlines = T2.Cnt  from #tempOut T1,(Select Division,Count( Product_Code) as Cnt  from #TmpLinesToday Group by Division) T2 Where T1.Cat_level = T2.Division and isnull(T1.s_id,0) = 0  
Update T1  Set T1.TD_Uni_Lines = T2.Cnt  from #tempOut T1,(Select Division,Count( Distinct Product_Code) as Cnt  from #tempInvoiceidToday Where InvoiceType in (1,3) Group by Division) T2 Where T1.Cat_level = T2.Division and isnull(T1.s_id,0) = 0  
Update T1  Set T1.TD_TotBill = T2.Cnt  from #tempOut T1,(Select Subcategory,Count( Distinct I_id) as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by Subcategory) T2 Where T1.Cat_level = T2.Subcategory and isnull(T1.s_id,0) = 0  
Update T1  Set T1.TD_Uni_Outlet = T2.Cnt  from #tempOut T1,(Select Subcategory,Count( Distinct Customerid) as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by Subcategory) T2 Where T1.Cat_level = T2.Subcategory and isnull(T1.s_id,0) = 0  
Update T1  Set T1.TD_Total_Bill_Qty = T2.Cnt  from #tempOut T1,(Select Subcategory,Sum(Quantity)/2 as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by Subcategory) T2 Where T1.Cat_level = T2.Subcategory and isnull(T1.s_id,0) = 0  
Update T1  Set T1.TD_Totbillvalue = T2.Cnt  from #tempOut T1,(Select Subcategory,Sum(Netvalue)/2 as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by Subcategory) T2 Where T1.Cat_level = T2.Subcategory and isnull(T1.s_id,0) = 0  
Update T1  Set T1.TD_Net_Bill_Qty = T2.Cnt  from #tempOut T1,(Select Subcategory,Sum(Quantity)/2 as Cnt from #tempInvoiceidToday Group by Subcategory) T2 Where T1.Cat_level = T2.Subcategory and isnull(T1.s_id,0) = 0  
Update T1  Set T1.TD_Net_Bill_Value = T2.Cnt  from #tempOut T1,(Select Subcategory,Sum(Netvalue)/2 as Cnt from #tempInvoiceidToday Group by Subcategory) T2 Where T1.Cat_level = T2.Subcategory and isnull(T1.s_id,0) = 0  
Update T1  Set T1.TD_Totlines = T2.Cnt  from #tempOut T1,(Select Subcategory,Count( Product_Code) as Cnt  from #TmpLinesToday Group by Subcategory) T2 Where T1.Cat_level = T2.Subcategory and isnull(T1.s_id,0) = 0  
Update T1  Set T1.TD_Uni_Lines = T2.Cnt  from #tempOut T1,(Select Subcategory,Count( Distinct Product_Code) as Cnt  from #tempInvoiceidToday Where InvoiceType in (1,3) Group by Subcategory) T2 Where T1.Cat_level = T2.Subcategory and isnull(T1.s_id,0) = 0  
Update T1  Set T1.TD_TotBill = T2.Cnt  from #tempOut T1,(Select salesmanid,Count( Distinct I_id) as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by salesmanid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level = 'All'  
Update T1  Set T1.TD_Uni_Outlet = T2.Cnt  from #tempOut T1,(Select salesmanid,Count( Distinct Customerid) as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by salesmanid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level = 'All' 
Update T1  Set T1.TD_Total_Bill_Qty = T2.Cnt  from #tempOut T1,(Select salesmanid,Sum(Quantity)/2 as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by salesmanid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level = 'All' 
Update T1  Set T1.TD_Totbillvalue = T2.Cnt  from #tempOut T1,(Select salesmanid,Sum(Netvalue)/2 as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by salesmanid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level = 'All' 
Update T1  Set T1.TD_Net_Bill_Qty = T2.Cnt  from #tempOut T1,(Select salesmanid,Sum(Quantity)/2 as Cnt from #tempInvoiceidToday Group by salesmanid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level = 'All' 
Update T1  Set T1.TD_Net_Bill_Value = T2.Cnt  from #tempOut T1,(Select salesmanid,Sum(Netvalue)/2 as Cnt from #tempInvoiceidToday Group by salesmanid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level = 'All' 
Update T1  Set T1.TD_Totlines = T2.Cnt  from #tempOut T1,(Select salesmanid,Count( Product_Code) as Cnt  from #TmpLinesToday Group by salesmanid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level = 'All' 
Update T1  Set T1.TD_Uni_Lines = T2.Cnt  from #tempOut T1,(Select salesmanid,Count( Distinct Product_Code) as Cnt  from #tempInvoiceidToday Where InvoiceType in (1,3) Group by salesmanid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level = 'All' 
Update T1  Set T1.TD_TotBill = T2.Cnt  from #tempOut T1,(Select salesmanid,Groupid,Count( Distinct I_id) as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by salesmanid,Groupid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Groupid 
Update T1  Set T1.TD_Uni_Outlet = T2.Cnt  from #tempOut T1,(Select salesmanid,Groupid,Count( Distinct Customerid) as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by salesmanid,Groupid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Groupid
Update T1  Set T1.TD_Total_Bill_Qty = T2.Cnt  from #tempOut T1,(Select salesmanid,Groupid,Sum(Quantity)/2 as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by salesmanid,Groupid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Groupid
Update T1  Set T1.TD_Totbillvalue = T2.Cnt  from #tempOut T1,(Select salesmanid,Groupid,Sum(Netvalue)/2 as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by salesmanid,Groupid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Groupid
Update T1  Set T1.TD_Net_Bill_Qty = T2.Cnt  from #tempOut T1,(Select salesmanid,Groupid,Sum(Quantity)/2 as Cnt from #tempInvoiceidToday Group by salesmanid,Groupid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Groupid
Update T1  Set T1.TD_Net_Bill_Value = T2.Cnt  from #tempOut T1,(Select salesmanid,Groupid,Sum(Netvalue)/2 as Cnt from #tempInvoiceidToday Group by salesmanid,Groupid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Groupid
Update T1  Set T1.TD_Totlines = T2.Cnt  from #tempOut T1,(Select salesmanid,Groupid,Count( Product_Code) as Cnt  from #TmpLinesToday Group by salesmanid,Groupid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Groupid
Update T1  Set T1.TD_Uni_Lines = T2.Cnt  from #tempOut T1,(Select salesmanid,Groupid,Count( Distinct Product_Code) as Cnt  from #tempInvoiceidToday Where InvoiceType in (1,3) Group by salesmanid,Groupid) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Groupid
Update T1  Set T1.TD_TotBill = T2.Cnt  from #tempOut T1,(Select salesmanid,Division,Count( Distinct I_id) as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by salesmanid,Division) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Division 
Update T1  Set T1.TD_Uni_Outlet = T2.Cnt  from #tempOut T1,(Select salesmanid,Division,Count( Distinct Customerid) as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by salesmanid,Division) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Division
Update T1  Set T1.TD_Total_Bill_Qty = T2.Cnt  from #tempOut T1,(Select salesmanid,Division,Sum(Quantity)/2 as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by salesmanid,Division) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Division
Update T1  Set T1.TD_Totbillvalue = T2.Cnt  from #tempOut T1,(Select salesmanid,Division,Sum(Netvalue)/2 as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by salesmanid,Division) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Division
Update T1  Set T1.TD_Net_Bill_Qty = T2.Cnt  from #tempOut T1,(Select salesmanid,Division,Sum(Quantity)/2 as Cnt from #tempInvoiceidToday Group by salesmanid,Division) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Division
Update T1  Set T1.TD_Net_Bill_Value = T2.Cnt  from #tempOut T1,(Select salesmanid,Division,Sum(Netvalue)/2 as Cnt from #tempInvoiceidToday Group by salesmanid,Division) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Division
Update T1  Set T1.TD_Totlines = T2.Cnt  from #tempOut T1,(Select salesmanid,Division,Count( Product_Code) as Cnt  from #TmpLinesToday Group by salesmanid,Division) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Division
Update T1  Set T1.TD_Uni_Lines = T2.Cnt  from #tempOut T1,(Select salesmanid,Division,Count( Distinct Product_Code) as Cnt  from #tempInvoiceidToday Where InvoiceType in (1,3) Group by salesmanid,Division) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Division
Update T1  Set T1.TD_TotBill = T2.Cnt  from #tempOut T1,(Select salesmanid,Subcategory,Count( Distinct I_id) as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by salesmanid,Subcategory) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Subcategory 
Update T1  Set T1.TD_Uni_Outlet = T2.Cnt  from #tempOut T1,(Select salesmanid,Subcategory,Count( Distinct Customerid) as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by salesmanid,Subcategory) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Subcategory
Update T1  Set T1.TD_Total_Bill_Qty = T2.Cnt  from #tempOut T1,(Select salesmanid,Subcategory,Sum(Quantity)/2 as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by salesmanid,Subcategory) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Subcategory
Update T1  Set T1.TD_Totbillvalue = T2.Cnt  from #tempOut T1,(Select salesmanid,Subcategory,Sum(Netvalue)/2 as Cnt from #tempInvoiceidToday Where InvoiceType in (1,3) Group by salesmanid,Subcategory) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Subcategory
Update T1  Set T1.TD_Net_Bill_Qty = T2.Cnt  from #tempOut T1,(Select salesmanid,Subcategory,Sum(Quantity)/2 as Cnt from #tempInvoiceidToday Group by salesmanid,Subcategory) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Subcategory
Update T1  Set T1.TD_Net_Bill_Value = T2.Cnt  from #tempOut T1,(Select salesmanid,Subcategory,Sum(Netvalue)/2 as Cnt from #tempInvoiceidToday Group by salesmanid,Subcategory) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Subcategory
Update T1  Set T1.TD_Totlines = T2.Cnt  from #tempOut T1,(Select salesmanid,Subcategory,Count( Product_Code) as Cnt  from #TmpLinesToday Group by salesmanid,Subcategory) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Subcategory
Update T1  Set T1.TD_Uni_Lines = T2.Cnt  from #tempOut T1,(Select salesmanid,Subcategory,Count( Distinct Product_Code) as Cnt  from #tempInvoiceidToday Where InvoiceType in (1,3) Group by salesmanid,Subcategory) T2 Where T1.S_ID = T2.salesmanid and T1.Cat_level =  T2.Subcategory
update #tempOut set TD_TotBill = 0 where isnull(TD_TotBill,0) =0
update #tempOut set TD_Uni_Outlet = 0 where isnull(TD_Uni_Outlet,0) =0
update #tempOut set TD_Total_Bill_Qty = 0 where isnull(TD_Total_Bill_Qty,0) =0
update #tempOut set TD_Totbillvalue = 0 where isnull(TD_Totbillvalue,0) =0
update #tempOut set TD_Net_Bill_Qty = 0 where isnull(TD_Net_Bill_Qty,0) =0
update #tempOut set TD_Net_Bill_Value = 0 where isnull(TD_Net_Bill_Value,0) =0
update #tempOut set TD_Totlines = 0 where isnull(TD_Totlines,0) =0
update #tempOut set TD_Uni_Lines = 0 where isnull(TD_Uni_Lines,0) =0

--*****************************************************************************************************************************************************************************************************************************************************************
Update T1  Set T1.ord = T2.Cnt  from #tempOut T1,(Select Cal_Level,Levels as Cnt from #Group_Level ) T2 Where T1.Cat_level = T2.Cal_Level

if (Select Count(*) from #tempOut) <> 1 --and (Select Top 1 Cat_Level from #tempOut) <> 'All'
Begin
	INSERT INTO #tmpOutput SELECT @WDCode,@WDCode,@WDDestCode,dbo.striptimefromdate(@FromDate),dbo.striptimefromdate(@ToDate),S_id,S_Name,S_type,Cat_level,Tot_Outlet,MTD_TotBill,MTD_uni_Outlet,MTD_Total_Bill_Qty,MTD_Totbillvalue, MTD_Net_Bill_Qty ,MTD_Net_Bill_Value ,MTD_TotLines,MTD_uni_Lines,MTD_Workdays,TD_TotBill,
							TD_Uni_Outlet,TD_Total_Bill_Qty,TD_Totbillvalue, TD_Net_Bill_Qty,TD_Net_Bill_Value,TD_Totlines,TD_Uni_Lines FROM #tempOut order by S_id,Ord,Cat_level asc
End
--Update #tmpOutput set [Salesman ID] = 'All' where [Salesman ID] = 0
--*****************************************************************************************************************************************************************************************************************************************************************
	Insert Into #tmpOutputData 
	select *,Null from #tmpOutput 

	Update #tmpOutputData set [Category Type Level] = 'All',Wdcode = 0 Where [Category Level] = 'All'

	If @CategoryType = 'Operational'
	Begin
		Update T set T.[Category Type Level] = T1.LevelName,Wdcode = 2 From #tmpOutputData T ,
		(Select Distinct GroupName,'OCG' as LevelName From ProductCategoryGroupAbstract Where isnull(OCGType,0) = 1) T1
		Where T.[Category Level] = T1.GroupName And Isnull(T.[Category Type Level],'') = ''
	End
	Else If @CategoryType = 'Regular'
	Begin
		Update T set T.[Category Type Level] = T1.LevelName,Wdcode = 1 From #tmpOutputData T ,
		(Select Distinct GroupName,'CG' as LevelName From ProductCategoryGroupAbstract Where GroupName in (select Distinct CategoryGroup from tblcgdivmapping)) T1
		Where T.[Category Level] = T1.GroupName And Isnull(T.[Category Type Level],'') = ''
	End

	Update T set T.[Category Type Level] = T1.LevelName,Wdcode = 3 From #tmpOutputData T ,
	(Select Distinct Category_Name,'Division' as LevelName From ItemCategories Where level = 2) T1
	Where T.[Category Level] = T1.Category_Name And Isnull(T.[Category Type Level],'') = ''

	Update T set T.[Category Type Level] = T1.LevelName,Wdcode = 4 From #tmpOutputData T ,
	(Select Distinct Category_Name,'SubCategory' as LevelName From ItemCategories Where level = 3) T1
	Where T.[Category Level] = T1.Category_Name And Isnull(T.[Category Type Level],'') = ''

	If @OCGFlag = 1 and @CategoryType = 'Regular' And (select Isnull(Flag,0) from tbl_merp_Configabstract where screenCode = 'OCGDS') = 1
	Begin
		Set @CategoryType = 'Operational'
		Drop Table #tmpSManType    
		Drop Table #tmpSman   
		Drop Table #tmpSManID   
		Drop Table #tmpsalesman
		Drop Table #tmpcatgroup
		Drop Table #tmpcategory
		Drop Table #Group_Level
		Drop Table #tmpcat
		Drop Table #tempInvoiceidAll
		Drop Table #tempInvoiceid
		Drop Table #tempInvoiceidToday
		Drop Table #TmpLines
		Drop Table #TmpLinesToday
		Drop Table #Outletdata
		Drop Table #TempCat_1
		Drop Table #Cat_1
		Drop Table #tempOut
		Drop Table #tmpOutput
		Goto StartProcess
	End
	Else
	Begin
		Goto OUT
	End
	
OUT:
	Select Distinct * from #tmpOutputData  Order By  [Salesman ID],Wdcode Asc
--*****************************************************************************************************************************************************************************************************************************************************************
	Drop Table #tmpSManType    
	Drop Table #tmpSman   
	Drop Table #tmpSManID   
	Drop Table #tmpsalesman
	Drop Table #tmpcatgroup
	Drop Table #tmpcategory
	Drop Table #Group_Level
	Drop Table #tmpcat
	Drop Table #tempInvoiceidAll
	Drop Table #tempInvoiceid
	Drop Table #tempInvoiceidToday
	Drop Table #TmpLines
	Drop Table #TmpLinesToday
	Drop Table #Outletdata
	Drop Table #TempCat_1
	Drop Table #Cat_1
	Drop Table #tempOut
	Drop Table #tmpOutput
	Drop Table #tmpOutputData
--*****************************************************************************************************************************************************************************************************************************************************************
End
