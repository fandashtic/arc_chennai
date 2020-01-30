Create Procedure mERP_spr_PointSchemeRpt_ITC  
(	
	@FromDate Datetime,
	@ToDate Datetime,
	@ActivityCode nVarchar(2550),
	@PayoutStatus nVarchar(10),
	@Salesman nVarchar(2550),
	@Beat nVarchar(2550)
)            
AS          

Declare @Open As nVarchar(10)
Declare @Closed As nVarchar(10)

Set @Open = dbo.LookupDictionaryItem(N'Open', Default)  
Set @Closed = dbo.LookupDictionaryItem(N'Closed', Default)  

Declare @ACount Int
Declare @Delimeter As Char(1)
Declare @ActDelimeter As Char(1)
Declare @ActivityCodeOne nVarchar(2550)
Declare @i int
Set @Delimeter = Char(15)
Set @ActDelimeter = '~'
Set @ACount = 0
Set @i = 0
--Declare @GraceDays as Int
--Select @GraceDays = DateDiff(d, ActiveTo, ExpiryDate) From tbl_mERP_SchemeAbstract Where SchemeID = @nSchemeid


Declare @ActCode Table (ActivityCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
Declare @scheme Table (SchemeID int)
Declare @ComActCode Table (IDs Int Identity(1, 1), ActivityCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    

if @ActivityCode = N'%'     
Begin
   Insert InTo @ActCode Select Distinct ActivityCode From tbl_mERP_SchemeAbstract where schemetype=4
End
Else    
Begin
   Insert InTo @ComActCode Select ItemValue From dbo.sp_SplitIn2Rows(@ActivityCode, @Delimeter)
   Select @ACount = Count(ActivityCode) From  @ComActCode
   While @Acount > 0
   Begin
		Select @ActivityCodeOne = ActivityCode From @ComActCode Where IDs = @i + 1
		Insert InTo @ActCode Select ItemValue From dbo.sp_SplitIn2Rows(@ActivityCodeOne, @ActDelimeter)
		Set @Acount = @Acount - 1
		Set @i = @i + 1
   End
End
Insert into @Scheme 
select SchemeID from tbl_merp_schemeabstract sa inner join @ActCode Ac on sa.ActivityCode = ac.activityCode where sa.active =1

--Begin of creating tables
Declare @POS Table (Status Int)
Declare @Saleman Table (Salesman nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, SalesmanID Int)    
Declare @Bt Table (Beat nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, BeatID Int)    
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CustList3]') and OBJECTPROPERTY(id, N'IsTable') = 1) 
Drop Table CustList3 

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IPScope]') and OBJECTPROPERTY(id, N'IsTable') = 1) 
Drop Table IPScope

Create Table CustList3 ( CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,SchemeID Int, GroupID Int, QPS Int )
Create table IPScope (SchemeId Int,ItemCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

--*********To Get Customer List ****************************************************************
/*
Declare @CustList1 Table( CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
CustomerName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, ChannelID Int, 
Channel nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, GroupID Int, SchemeID Int, 
OLMapID Int )

Declare @CustList2 Table( CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
CustomerName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, ChannelID Int, 
Channel nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, GroupID Int, SchemeID Int, 
OLMapID Int )

Create Table CustList3 ( CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
CustomerName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, ChannelID Int, 
Channel nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, GroupID Int, SchemeID Int, QPS Int, 
OLMapID Int )

------------Logic Change for OLClass

Declare @OLClass Table (OLMapID Int, 
CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)
Declare @ItemList1 Table (ItemCode nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
ItemName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, MarketSKULevelID Int, 
MarketSKULevelName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, UOM Int, UOM1 Int, 
UOM1Conversion Decimal(18, 6), UOM2 Int, UOM2Conversion Decimal(18, 6), 
SubCategoryLevelID Int, SubCategoryLevelName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
DivisionLevelID Int, DivisionLevelName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
CompanyLevelID Int, CompanyLevelName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)
*/
--Declare @PScope1 Table (SchemeID Int, ProductScopeID Int, 
--SKUCode nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
--MarketSKU nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
--SubCategory nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
--Division nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)
--
--Create Table IPScope (ItemCode nVarchar(256), ItemName nVarchar(256), MarketSKULevelID Int, 
--MarketSKULevelName nVarchar(256), UOM Int, UOM1 Int, 
--UOM1Conversion Decimal(18, 6), UOM2 Int, UOM2Conversion Decimal(18, 6), 
--SubCategoryLevelID Int, SubCategoryLevelName nVarchar(256),
--DivisionLevelID Int, DivisionLevelName nVarchar(256), CompanyLevelID Int, CompanyLevelName nVarchar(256),
--SchemeID Int, ProductScopeID Int)
--Declare @Items table (SchemeId Int,Product_code nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

Declare @OPut1 Table (SchemeID Int, PayoutID Int, PayoutFromDate Datetime, PayoutToDate Datetime, SchFrom Datetime, 
SchTo Datetime, ActivityCode nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
CSSchemeID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, SchemeName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
PayoutPeriod nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
PayoutStatus nVarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS, SchemeFrom Datetime, SchemeTo Datetime, 
RatePerUnit Decimal(18,6), TotalPoints Decimal(18, 6), TotalPointsValue Decimal(18, 6), 
TotalRedeemedpoint Decimal(18, 6), TotalAmoutSpent Decimal(18, 6), PendingPoints Decimal(18, 6), GraceDays Int)

Declare @OPut2 Table (PayoutID Int, PayoutFromDate Datetime, PayoutToDate Datetime, SchFrom Datetime, 
SchTo Datetime, ActivityCode nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
CSSchemeID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, SchemeName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
PayoutPeriod nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
PayoutStatus nVarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS, SchemeFrom Datetime, SchemeTo Datetime, 
RatePerUnit Decimal(18,6), TotalPoints Decimal(18, 6), TotalPointsValue Decimal(18, 6), 
TotalRedeemedpoint Decimal(18, 6), TotalAmoutSpent Decimal(18, 6), PendingPoints Decimal(18, 6), GraceDays Int)




--End of creating tables

--Check any point scheme available
if not exists(select top 1 * from @ActCode)
	goto SelectFinal

If @PayoutStatus = N'%'
	Insert InTo @POS Select 0 Union Select 1
Else If @PayoutStatus = @Open
	Insert InTo @POS Select 0
Else If @PayoutStatus = @Closed
	Insert InTo @POS Select 1

-------Salesman & Beat Filter--------


if @Salesman = N'%'     
   Insert InTo @Saleman Select Distinct Salesman_Name, SalesmanID From Salesman
Else    
   Insert InTo @Saleman Select Distinct Salesman_Name, SalesmanID From Salesman 
   Where Salesman_Name In (Select * from dbo.sp_SplitIn2Rows(@Salesman, @Delimeter))


if @Beat = N'%'     
   Insert InTo @Bt Select Distinct Description, BeatID From Beat
Else    
   Insert InTo @Bt Select Distinct Description, BeatID From Beat 
   Where Description In (Select * from dbo.sp_SplitIn2Rows(@Beat, @Delimeter))

-------------------------------------
/*
Insert Into @OLClass 
Select isNull(OLClassID,0),  CustomerID from  tbl_Merp_OlclassMapping where Active =1


--Select ctm.TMDValue, ctd.CustomerID 
--From Cust_TMD_Master ctm, Cust_TMD_Details ctd
--Where ctm.TMDID = ctd.TMDID And ctm.TMDCtlPos = 6

Insert InTo @CustList1 
Select c.CustomerID, c.Company_Name, '', cc.Channel_Type_desc, sc.GroupID, sc.SchemeID,
olc.OLMapID
From Customer c, tbl_merp_Olclass cc, @OLClass olc,tbl_mERP_SchemeChannel sc Inner join tbl_merp_schemeabstract Sa
on Sa.SchemeId = SC.schemeID Inner join @ActCode Ac on Sa.ActivityCode = Ac.ActivityCode 
Where olc.OLMapID = cc.ID And 
cc.Channel_Type_desc = Case sc.Channel When N'ALL' Then cc.Channel_Type_desc Else sc.Channel End And
c.CustomerID = olc.CustomerID



Insert InTo @CustList2
Select cl1.CustomerID , cl1.CustomerName , cl1.ChannelID , cl1.Channel , cl1.GroupID , cl1.SchemeID, 
cl1.OLMapID
From @CustList1 cl1, tbl_mERP_SchemeOutletClass soc, tbl_merp_Olclass cc
Where cl1.GroupID = soc.GroupID And cl1.SchemeID = soc.SchemeID And 
cl1.OLMAPID = cc.ID And 
IsNull(cc.Outlet_Type_desc, N'a') = Case soc.OutletClass When N'ALL' Then IsNull(cc.Outlet_Type_desc, N'a') Else soc.OutletClass End

Insert InTo CustList3
Select cl2.CustomerID , cl2.CustomerName , cl2.ChannelID , cl2.Channel , cl2.GroupID , cl2.SchemeID, so.QPS,
cl2.OLMapID
From @CustList2 cl2, tbl_mERP_SchemeOutlet so, tbl_mERP_SchemeLoyaltyList SLList
Where cl2.GroupID = so.GroupID And cl2.SchemeID = so.SchemeID And 
SLList.GroupID = SO.GroupID And
cl2.CustomerID = Case so.OutletID When N'ALL' Then cl2.CustomerID Else so.OutletID End
*/
--********************************************************************************************
--************************Product Scope*******************************************************
--padhu
declare @SchemeId Int
Declare c1 Cursor  For
select schemeid from @scheme 
Open c1
Fetch From c1 Into @Schemeid
	While @@FETCH_STATUS = 0  
	Begin   
	Insert into CustList3 select * from dbo.mERP_fn_GetSchemeOutletDetails(@Schemeid)
	insert into IPScope(Schemeid,ItemCode) Select @schemeid,SKUCODE from dbo.mERP_fn_GetSchemeItems(@schemeid)	
	Fetch From c1 Into @Schemeid
	End
Close c1
deallocate c1




/*
Insert InTo @ItemList1 (ItemCode , ItemName , MarketSKULevelID , MarketSKULevelName , UOM , UOM1 , 
UOM1Conversion , UOM2 , UOM2Conversion , SubCategoryLevelID )
Select its.Product_Code, its.ProductName, its.CategoryID, icat.Category_Name, 
its.UOM, its.UOM1, its.UOM1_Conversion, its.UOM2, its.UOM2_Conversion, icat.ParentID
From Items its, ItemCategories icat
Where its.CategoryID = icat.CategoryID

Update il1 Set il1.SubCategoryLevelName = icat.Category_Name, il1.DivisionLevelID = icat.ParentID
From @ItemList1 il1, ItemCategories icat
Where il1.SubCategoryLevelID = icat.CategoryID 

Update il1 Set il1.DivisionLevelName = icat.Category_Name, il1.CompanyLevelID = icat.ParentID, 
il1.CompanyLevelName = (Select Top 1 icat2.Category_Name From ItemCategories icat2
Where icat2.CategoryID = icat.ParentID)
From @ItemList1 il1, ItemCategories icat
Where il1.DivisionLevelID = icat.CategoryID 


Insert InTo @PScope1
Select ssku.SchemeID, ssku.ProductScopeID, ssku.SKUCode, 
msku.MarketSKU, scat.SubCategory, cats.Category
From tbl_mERP_SchSKUCodeScope  ssku, tbl_mERP_SchMarketSKUScope msku,
tbl_mERP_SchSubCategoryScope scat, tbl_mERP_SchCategoryScope cats, tbl_mERP_SchemeProductScopeMap sps Inner Join tbl_merp_schemeabstract SA on SPS.Schemeid = SA.SchemeID
Where ssku.SchemeID = msku.SchemeID And ssku.ProductScopeID = msku.ProductScopeID And
msku.SchemeID = scat.SchemeID And msku.ProductScopeID = scat.ProductScopeID And
scat.SchemeID = cats.SchemeID And scat.ProductScopeID = cats.ProductScopeID And
cats.SchemeID = sps.SchemeID And cats.ProductScopeID = sps.ProductScopeID 
SA.SchemeType =4 and SA.Active = 1

Insert InTo IPScope 
Select il1.ItemCode , il1.ItemName , il1.MarketSKULevelID , il1.MarketSKULevelName , il1.UOM , il1.UOM1 , 
il1.UOM1Conversion , il1.UOM2 , il1.UOM2Conversion , il1.SubCategoryLevelID , il1.SubCategoryLevelName ,
il1.DivisionLevelID , il1.DivisionLevelName , il1.CompanyLevelID , il1.CompanyLevelName, 
ps1.SchemeID, ps1.ProductScopeID
From @ItemList1 il1, @PScope1 ps1
Where il1.ItemCode = Case ps1.SKUCode When N'ALL' Then il1.ItemCode Else ps1.SKUCode End And 
il1.MarketSKULevelName = Case ps1.MarketSKU When N'ALL' Then il1.MarketSKULevelName Else ps1.MarketSKU End And 
il1.SubCategoryLevelName = Case ps1.SubCategory When N'ALL' Then il1.SubCategoryLevelName Else ps1.SubCategory End And 
il1.DivisionLevelName = Case ps1.Division When N'ALL' Then il1.DivisionLevelName Else ps1.Division End 
Order By il1.ItemCode 
*/
--*************************************************************************************************************



Insert Into @OPut1 
Select  
"SchemeID" = sa.SchemeID, "PayoutID" = IsNull(spp.Status, 0), "PayoutFromDate" = spp.PayoutPeriodFrom, 
"PayoutToDate" = spp.PayoutPeriodTo, "SchFrom" = sa.SchemeFrom, "SchTo" = sa.SchemeTo,
"ActivityCode" = sa.ActivityCode, "CSSchemeID" = sa.CS_RecSchID, 
"SchemeName" = sa.Description, 
"PayoutPeriod" = Cast(Convert(Char(13), spp.PayoutPeriodFrom, 103) As nVarchar) + N' - ' + Cast(Convert(Char(13), spp.PayoutPeriodTo , 103) As nVarchar),
"PayoutStatus" = Case When spp.Status = 0 Then @Open 
					  When spp.Status & 1 = 1 Then @Closed End, 
"SchemeFrom" = Convert(Char(13), sa.SchemeFrom, 103), "SchemeTo" = Convert(Char(13), sa.SchemeTo, 103), 
"RatePerUnit" = ssd.UnitRate , 
"TotalPoints" = (Cast(IsNull(dbo.mERP_fn_TotalPoints_ITC(sa.SchemeID , sa.ApplicableOn ,
		sa.ItemGroup , spp.PayoutPeriodFrom , spp.PayoutPeriodTo , ssd.GroupID , 
		ssd.UOM , ssd.SlabStart , ssd.SlabEnd , ssd.Onward , ssd.[Value] , 
		ssd.UnitRate , sa.SchemeFrom , sa.SchemeTo, sa.SKUCount, @Salesman, @Beat), 0) As Int)) ,
--==================
--sa.SchemeID , sa.ApplicableOn ,
--		sa.ItemGroup , spp.PayoutPeriodFrom , spp.PayoutPeriodTo , ssd.GroupID , 
--		ssd.UOM , ssd.SlabStart , ssd.SlabEnd , ssd.Onward , ssd.[Value] , 
--		ssd.UnitRate , sa.SchemeFrom , sa.SchemeTo, sa.SKUCount, @Salesman, @Beat,
--spp.PayoutPeriodFrom , DateAdd(ss, -1, spp.PayoutPeriodTo  + 1) , 
--DateAdd(ss, -1, DateAdd(D, DateDiff(d, sa.ActiveTo, sa.ExpiryDate),spp.PayoutPeriodTo) + 1),
--sa.SchemeID, ssd.GroupID,


--=================

"TotalPointsValue" = (Cast(IsNull(dbo.mERP_fn_TotalPoints_ITC(sa.SchemeID , sa.ApplicableOn ,
		sa.ItemGroup , spp.PayoutPeriodFrom , spp.PayoutPeriodTo , ssd.GroupID , 
		ssd.UOM , ssd.SlabStart , ssd.SlabEnd , ssd.Onward , ssd.[Value] , 
		ssd.UnitRate , sa.SchemeFrom , sa.SchemeTo, sa.SKUCount, @Salesman, @Beat), 0) As Int) * ssd.UnitRate),

"TotalRedeemedpoint" = IsNull((Select Sum(IsNull(scr.RedeemedPoints, 0)) From tbl_mERP_CSRedemption scr 
	Where scr.SchemeID = sa.SchemeID And scr.RFAStatus In (1,0) And scr.PayOutID = spp.ID And
	OutletCode In (Select ia.CustomerID From InvoiceAbstract ia, InvoiceDetail idl 
--		Inner Join IPScope IT
--		on idl.Product_code = IT.Itemcode and it.schemeid = sa.schemeid		
		Where ia.InvoiceID = idl.InvoiceID And ia.Status & 128 = 0 And ia.InvoiceType In (1,3, 4) And 
		ia.InvoiceDate Between spp.PayoutPeriodFrom And  DateAdd(ss, -1, spp.PayoutPeriodTo  + 1) And 
		ia.CreationTime Between spp.PayoutPeriodFrom And  DateAdd(ss, -1, DateAdd(D, DateDiff(d, sa.ActiveTo, sa.ExpiryDate),spp.PayoutPeriodTo) + 1) And 
		ia.CustomerID In (Select CustomerID From CustList3 cl3 Where cl3.SchemeID = sa.SchemeID 
		And cl3.GroupID = ssd.GroupID ) 
--		And idl.Product_Code In (Select ItemCode From IPScope ips Where ips.SchemeID = sa.SchemeID )
		And ia.SalesmanID In (Select SalesmanID From @Saleman) And
		ia.BeatID In (Select BeatID From @bt) )), 0),

"TotalAmoutSpent" = IsNull((Select Sum(IsNull(scr.AmountSpent, 0)) From tbl_mERP_CSRedemption scr 
	Where scr.SchemeID = sa.SchemeID And scr.RFAStatus In (1,0) And scr.PayOutID = spp.ID And 
	OutletCode In (Select ia.CustomerID From InvoiceAbstract ia, InvoiceDetail idl 
--		Inner Join IPScope IT
--		on idl.Product_code = IT.Itemcode and it.schemeid = sa.schemeid	
		Where ia.InvoiceID = idl.InvoiceID And ia.Status & 128 = 0 And ia.InvoiceType In (1,3, 4) And 
		ia.InvoiceDate Between spp.PayoutPeriodFrom And  DateAdd(ss, -1, spp.PayoutPeriodTo  + 1) And 
		ia.CreationTime Between spp.PayoutPeriodFrom And  DateAdd(ss, -1, DateAdd(D, DateDiff(d, sa.ActiveTo, sa.ExpiryDate),spp.PayoutPeriodTo) + 1) And 
		ia.CustomerID In (Select CustomerID From CustList3 cl3 Where cl3.SchemeID = sa.SchemeID 
		And cl3.GroupID = ssd.GroupID ) 
--		And idl.Product_Code In (Select ItemCode From IPScope ips Where ips.SchemeID = sa.SchemeID )
		And ia.SalesmanID In (Select SalesmanID From @Saleman) And
		ia.BeatID In (Select BeatID From @bt) )	), 0),

"PendingPoints" = 0, --Sum(0),

"GraceDays" = DateDiff(d, sa.ActiveTo, sa.ExpiryDate) --,
--"test" = DateAdd(ss, -1, DateAdd(D, DateDiff(d, sa.ActiveTo, sa.ExpiryDate),spp.PayoutPeriodTo) + 1)

From tbl_mERP_SchemeAbstract sa, tbl_mERP_SchemePayoutPeriod spp, tbl_mERP_SchemeSlabDetail ssd, 
tbl_mERP_SchemeLoyaltyList SLList
Where sa.SchemeID = spp.SchemeID And sa.SchemeID = ssd.SchemeID And 
	sa.SchemeID = SLList.SchemeID And 
	sa.SchemeType = 4 And 
	ssd.SlabType = 5 And sa.ActivityCode In (Select ActivityCode From @ActCode) And
	((sa.ActiveFrom Between @FromDate And @ToDate) Or (sa.ActiveFrom Between @FromDate And @ToDate ) Or
	 (@FromDate Between sa.ActiveFrom And sa.ActiveTo) Or (@ToDate Between sa.ActiveFrom And sa.ActiveTo)
	) And 
	--(@FromDate Between sa.ActiveFrom And sa.ActiveTo Or @ToDate Between sa.ActiveFrom And sa.ActiveTo ) And 
    /*Need not to check the status as the report has to be generated at any point of time */
	sa.Active = 1 --And spp.Status & 192 = 0 
Group By sa.SchemeID, spp.Status, spp.PayoutPeriodFrom, 
	spp.PayoutPeriodTo, sa.SchemeFrom, sa.SchemeTo,
	sa.ActivityCode, sa.CS_RecSchID, sa.Description, 
	sa.SchemeFrom, sa.SchemeTo, ssd.UnitRate, spp.ID, ssd.GroupID, sa.ActiveTo, sa.ExpiryDate , 
sa.SchemeID , sa.ApplicableOn ,
		sa.ItemGroup , spp.PayoutPeriodFrom , spp.PayoutPeriodTo , ssd.GroupID , 
		ssd.UOM , ssd.SlabStart , ssd.SlabEnd , ssd.Onward , ssd.[Value] , 
		ssd.UnitRate , sa.SchemeFrom , sa.SchemeTo, sa.SKUCount

--+++++++++++++++++++++++++
--Select * From @OPut1
--select * from IPScope
--select * from CustList3
--select * from @Saleman
--select * from @bt
--+++++++++++++++++++++++++
SelectFinal:
Select Cast(PayoutID As nVarchar) + @Delimeter + ActivityCode + @Delimeter + Cast(RatePerUnit As nVarchar) + 
@Delimeter + Cast(CSSchemeID as nvarchar) + @Delimeter + SchemeName + @Delimeter + 
Cast(PayoutFromDate As nVarchar) + @Delimeter + Cast(PayoutToDate as nVarchar) + @Delimeter + 
Cast(SchFrom As nVarchar) + @Delimeter + Cast(SchTo As nVarchar),
ActivityCode , --CSSchemeID , 
SchemeName , 
PayoutPeriod , PayoutStatus , SchemeFrom , SchemeTo , 
RatePerUnit , "TotalPoints" = Sum(TotalPoints) , 
"TotalPointsValue" = Sum(TotalPointsValue) , 
"TotalRedeemedpoint" = Sum(TotalRedeemedpoint) , 
"TotalAmoutSpent" = Sum(TotalAmoutSpent) , 
"PendingPoints" = Sum(TotalPoints - TotalRedeemedpoint) 
From @OPut1 
Where PayoutStatus Like @PayoutStatus and totalPoints > 0 
Group By ActivityCode, ActivityCode , CSSchemeID , SchemeName , 
PayoutPeriod , PayoutStatus , SchemeFrom , SchemeTo , 
RatePerUnit, PayoutID, PayoutFromDate, PayoutToDate, SchFrom, SchTo
--Having Sum(TotalPoints) <> 0


-----
Drop Table CustList3 
Drop Table IPScope

