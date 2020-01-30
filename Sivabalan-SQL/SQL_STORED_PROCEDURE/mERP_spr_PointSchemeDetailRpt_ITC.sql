Create Procedure mERP_spr_PointSchemeDetailRpt_ITC  
(    
	@ActivityCode nVarchar(2550), 
	@Salesman nVarchar(2550),
	@Beat nVarchar(2550)
)            
AS          

Declare @Open As nVarchar(10)
Declare @Closed As nVarchar(10)

Set @Open = dbo.LookupDictionaryItem(N'Open', Default)  
Set @Closed = dbo.LookupDictionaryItem(N'Closed', Default)  

Declare @Delimeter As Char(1)
Declare @PayoutStatus Int
Declare @ActCode nVarchar(256)
Declare @RU Decimal(18, 6)
Declare @CSSchemeID nVarchar(256) 
Declare @SchemeName nVarchar(256)
Declare @PayoutFromDate Datetime
Declare @PayoutToDate Datetime
Declare @SchFrom Datetime
Declare @SchTo Datetime
Declare @SchId Int
--*******************************************************************************
Declare @ParamCol Table(IDS Int IDENTITY(1,1) NOT NULL, ActCode nVarchar(256) )
Set @Delimeter = Char(15)

Insert InTo @ParamCol
Select * from dbo.sp_SplitIn2Rows(@ActivityCode, @Delimeter)

Select @PayoutStatus = ActCode From @ParamCol pc
Where pc.IDS = 1

Select @ActCode = ActCode From @ParamCol pc
Where pc.IDS = 2

Select @RU = ActCode From @ParamCol pc
Where pc.IDS = 3

Select @CSSchemeID = ActCode From @ParamCol pc
Where pc.IDS = 4

Select @SchemeName = ActCode From @ParamCol pc
Where pc.IDS = 5

Select @PayoutFromDate = ActCode From @ParamCol pc
Where pc.IDS = 6

Select @PayoutToDate = ActCode From @ParamCol pc
Where pc.IDS = 7

Select @SchFrom = ActCode From @ParamCol pc
Where pc.IDS = 8

Select @SchTo = ActCode From @ParamCol pc
Where pc.IDS = 9

Declare @SchemeID Int, @AppOn Int, @ItemGp Int, @POutFrom Datetime
Declare @POutTo Datetime, @GID Int, @UOM Int, @SStart Decimal(18, 6), @SEnd Decimal(18, 6), @Onward Decimal(18, 6)
Declare @Value Decimal(18, 6), @UR Decimal(18, 6), @SchmFrom Datetime, @SchmTo Datetime, @PayOutID Int, @SKUCount Int

Declare @TotPoints Table (InvoiceID Int, CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
ChannelType nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
DefaultBeat nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
RatePerUnit Decimal(18, 6), TPoints Decimal(18, 6), 
ItemCode nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, PointsValue Decimal(18, 6), 
RedeemedPoint Decimal(18, 6), AmountSpent Decimal(18, 6), 
PlannedPayout nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
PendingPoints Decimal(18, 6), PayOutID Int)

Declare @TotPoints2 Table (InvoiceID Int, CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
ChannelType nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
DefaultBeat nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
RatePerUnit Decimal(18, 6), TPoints Decimal(18, 6), 
ItemCode nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, PointsValue Decimal(18, 6), 
RedeemedPoint Decimal(18, 6), AmountSpent Decimal(18, 6), 
PlannedPayout nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
PendingPoints Decimal(18, 6), PayOutID Int)

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CustList3]') and OBJECTPROPERTY(id, N'IsTable') = 1) 
Drop Table CustList3 

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IPScope]') and OBJECTPROPERTY(id, N'IsTable') = 1) 
Drop Table IPScope

Create Table CustList3 ( CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,SchemeID Int, GroupID Int, QPS Int )

Create Table IPScope (ItemCode nVarchar(256), ItemName nVarchar(256), MarketSKULevelID Int, 
MarketSKULevelName nVarchar(256), UOM Int, UOM1 Int, 
UOM1Conversion Decimal(18, 6), UOM2 Int, UOM2Conversion Decimal(18, 6), 
SubCategoryLevelID Int, SubCategoryLevelName nVarchar(256),
DivisionLevelID Int, DivisionLevelName nVarchar(256), CompanyLevelID Int, CompanyLevelName nVarchar(256),
SchemeID Int, ProductScopeID Int)
-------Salesman & Beat Filter--------

Declare @Saleman Table (Salesman nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, SalesmanID Int)    

if @Salesman = N'%'     
   Insert InTo @Saleman Select Distinct Salesman_Name, SalesmanID From Salesman
Else    
   Insert InTo @Saleman Select Distinct Salesman_Name, SalesmanID From Salesman 
   Where Salesman_Name In (Select * from dbo.sp_SplitIn2Rows(@Salesman, @Delimeter))

Declare @Bt Table (Beat nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, BeatID Int)    

if @Beat = N'%'     
   Insert InTo @Bt Select Distinct Description, BeatID From Beat
Else    
   Insert InTo @Bt Select Distinct Description, BeatID From Beat 
   Where Description In (Select * from dbo.sp_SplitIn2Rows(@Beat, @Delimeter))

------------------------------



--*********To Get Customer List ****************************************************************

/*
Declare @CustList1 Table( CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
CustomerName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, ChannelID Int, 
Channel nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, GroupID Int, SchemeID Int, 
OLMapID Int)

Declare @CustList2 Table( CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
CustomerName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, ChannelID Int, 
Channel nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, GroupID Int, SchemeID Int, 
OLMapID Int)
*/

/*
------------Logic Change for OLClass
Declare @OLClass Table (OLMapID Int, 
CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert Into @OLClass 
Select isNull(OLClassID,0),  CustomerID from  tbl_Merp_OlclassMapping where Active =1

--Declare @OLClass Table (TMDVal nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
--CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)
--
--Insert Into @OLClass 
--Select ctm.TMDValue, ctd.CustomerID 
--From Cust_TMD_Master ctm, Cust_TMD_Details ctd
--Where ctm.TMDID = ctd.TMDID And ctm.TMDCtlPos = 6


Insert InTo @CustList1
Select c.CustomerID, c.Company_Name, '', cc.Channel_Type_desc, sc.GroupID, sc.SchemeID,
olc.OLMapID
From Customer c, tbl_merp_Olclass cc, tbl_mERP_SchemeChannel sc Inner Join tbl_merp_schemeabstract sa on sa.schemeid=sc.schemeid, @OLClass olc
Where sa.activitycode = @ActCode and  olc.OLMapID = cc.ID And 
cc.Channel_Type_desc = Case sc.Channel When N'ALL' Then cc.Channel_Type_desc Else sc.Channel End And
c.CustomerID = olc.CustomerID
 

Insert InTo @CustList2
Select cl1.CustomerID , cl1.CustomerName , cl1.ChannelID , cl1.Channel , cl1.GroupID , cl1.SchemeID, 
cl1.OLMapID
From @CustList1 cl1, tbl_mERP_SchemeOutletClass soc Inner Join tbl_merp_schemeabstract sa on sa.Schemeid=soc.schemeid, tbl_merp_Olclass cc
Where Sa.ActivityCode= @ActCode and cl1.GroupID = soc.GroupID And cl1.SchemeID = soc.SchemeID And 
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
-- Selecting Outlet codes and ProductCode related to the activity code
Declare sch cursor for
select schemeid from tbl_merp_schemeabstract where activitycode = @ActCode and active =1
Open sch
Fetch From sch InTo @SchId 
While @@Fetch_Status = 0        
Begin
	Insert into CustList3 select * from dbo.mERP_fn_GetSchemeOutletDetails(@SchId)
	insert into IPScope(Schemeid,ItemCode) Select @SchID,SKUCODE from dbo.mERP_fn_GetSchemeItems(@schid)	

	Fetch Next From sch InTo @SchID
End
Close sch
DeAllocate sch



--********************************************************************************************
--************************Product Scope*******************************************************
/*
Declare @ItemList1 Table (ItemCode nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
ItemName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, MarketSKULevelID Int, 
MarketSKULevelName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, UOM Int, UOM1 Int, 
UOM1Conversion Decimal(18, 6), UOM2 Int, UOM2Conversion Decimal(18, 6), 
SubCategoryLevelID Int, SubCategoryLevelName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
DivisionLevelID Int, DivisionLevelName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
CompanyLevelID Int, CompanyLevelName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)

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

Declare @PScope1 Table (SchemeID Int, ProductScopeID Int, 
SKUCode nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
MarketSKU nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
SubCategory nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
Division nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert InTo @PScope1
Select ssku.SchemeID, ssku.ProductScopeID, ssku.SKUCode, 
msku.MarketSKU, scat.SubCategory, cats.Category
From tbl_mERP_SchSKUCodeScope  ssku, tbl_mERP_SchMarketSKUScope msku,
tbl_mERP_SchSubCategoryScope scat, tbl_mERP_SchCategoryScope cats, tbl_mERP_SchemeProductScopeMap sps
Where ssku.SchemeID = msku.SchemeID And ssku.ProductScopeID = msku.ProductScopeID And
msku.SchemeID = scat.SchemeID And msku.ProductScopeID = scat.ProductScopeID And
scat.SchemeID = cats.SchemeID And scat.ProductScopeID = cats.ProductScopeID And
cats.SchemeID = sps.SchemeID And cats.ProductScopeID = sps.ProductScopeID 
*/

/*
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

Declare CustDetail Cursor for

	Select Distinct sa.SchemeID , sa.ApplicableOn ,
	sa.ItemGroup , spp.PayoutPeriodFrom , spp.PayoutPeriodTo , ssd.GroupID , 
	ssd.UOM , ssd.SlabStart , ssd.SlabEnd , ssd.Onward , ssd.[Value] , 
	ssd.UnitRate , sa.SchemeFrom , sa.SchemeTo, spp.ID, sa.SKUCount
	From tbl_mERP_SchemeAbstract sa, tbl_mERP_SchemePayoutPeriod spp, tbl_mERP_SchemeSlabDetail ssd,
	tbl_mERP_SchemeLoyaltyList SLList
	Where sa.SchemeID = spp.SchemeID And sa.SchemeID = ssd.SchemeID And 
	sa.SchemeID = SLList.SchemeID And 
	sa.SchemeType = 4 And 
	ssd.SlabType = 5 And 
	spp.Status = @PayoutStatus And sa.ActivityCode = @ActCode And
	ssd.UnitRate = @RU And sa.CS_RecSchID = @CSSchemeID And 
	sa.Description = @SchemeName And spp.PayoutPeriodFrom Between @PayoutFromDate And DateAdd(ss, -1, @PayoutFromDate + 1) And
	spp.PayoutPeriodTo Between @PayoutToDate And DateAdd(ss, -1, @PayoutToDate + 1) And 
	sa.SchemeFrom Between @SchFrom And DateAdd(ss, -1, @SchFrom + 1) And 
	sa.SchemeTo Between @SchTo And DateAdd(ss, -1, @SchTo + 1) And sa.Active = 1

Open CustDetail
Fetch From CustDetail InTo @SchemeID , @AppOn , @ItemGp , @POutFrom ,
@POutTo , @GID , @UOM , @SStart , @SEnd , @Onward ,
@Value , @UR , @SchmFrom , @SchmTo , @PayOutID, @SKUCount
While @@Fetch_Status = 0        
Begin
	Insert InTo @TotPoints 
	Select *, (Cast(TPoints As Int) * @UR), 
	IsNull((Select Sum(IsNull(scr.RedeemedPoints, 0)) From tbl_mERP_CSRedemption scr 
	Where scr.SchemeID = @SchemeID And scr.OutletCode = CustomerID And scr.RFAStatus In (1,0) And scr.PayOutID = @PayOutID) , 0),
	
	IsNull((Select Sum(IsNull(scr.AmountSpent, 0)) From tbl_mERP_CSRedemption scr 
	Where scr.SchemeID = @SchemeID And scr.OutletCode = CustomerID And scr.RFAStatus In (1,0) And scr.PayOutID = @PayOutID) , 0),
	
	IsNull((Select Top 1 IsNull(scr.PlannedPayout, '') From tbl_mERP_CSRedemption scr 
	Where scr.SchemeID = @SchemeID And scr.OutletCode = CustomerID And scr.RFAStatus In (1,0) And scr.PayOutID = @PayOutID) , 0),

	IsNull(TPoints, 0) - IsNull((Select Sum(IsNull(scr.RedeemedPoints, 0)) From tbl_mERP_CSRedemption scr 
	Where scr.SchemeID = @SchemeID And scr.OutletCode = CustomerID And scr.RFAStatus In (1,0) And scr.PayOutID = @PayOutID), 0),

	@PayOutID

	From dbo.mERP_fn_TotalPointsDetail_ITC(@SchemeID , @AppOn , @ItemGp , @POutFrom ,
	@POutTo , @GID , @UOM , @SStart , @SEnd , @Onward ,
	@Value , @UR , @SchmFrom , @SchmTo, @SKUCount, @Salesman, @Beat)

	Fetch Next From CustDetail InTo @SchemeID , @AppOn , @ItemGp , @POutFrom ,
	@POutTo , @GID , @UOM , @SStart , @SEnd , @Onward ,
	@Value , @UR , @SchmFrom , @SchmTo, @PayOutID , @SKUCount
End
Close CustDetail
Deallocate CustDetail  

Insert InTo @TotPoints2 (CustomerID, CustomerName , ChannelType, DefaultBeat , RatePerUnit , TPoints ,
PointsValue, RedeemedPoint , AmountSpent , PlannedPayout , PendingPoints )
Select "Customer ID" = tp.CustomerID, "Customer Name"	= tp.CustomerName, 
"Customer Type" = tp.ChannelType, "Default Beat" = tp.DefaultBeat, "Rate Per Unit" = tp.RatePerUnit, 
"Total Points" = Sum(Cast(IsNull(tp.TPoints, 0) As Int)), "Points Value" = Sum(IsNull(tp.PointsValue, 0)) ,

"Redeemed Point" = IsNull((Select Sum(IsNull(scr.RedeemedPoints, 0)) From tbl_mERP_CSRedemption scr 
	Where scr.SchemeID = @SchemeID And scr.OutletCode = CustomerID And scr.RFAStatus In (1,0) And 
	scr.PayOutID = tp.PayOutID), 0) ,
	
"Amount Spent" = IsNull((Select Sum(IsNull(scr.AmountSpent, 0)) From tbl_mERP_CSRedemption scr 
	Where scr.SchemeID = @SchemeID And scr.OutletCode = CustomerID And scr.RFAStatus In (1, 0) And
	scr.PayOutID = tp.PayOutID), 0) ,
	
"Planned Payout" = IsNull((Select Top 1 IsNull(scr.PlannedPayout, '') From tbl_mERP_CSRedemption scr 
	Where scr.SchemeID = @SchemeID And scr.OutletCode = CustomerID And scr.RFAStatus In (1, 0) And
	scr.PayOutID = tp.PayOutID), 0),

"Pending Points" = IsNull(Sum(Cast(TPoints As Int)), 0) - IsNull((Select Sum(IsNull(scr.RedeemedPoints, 0)) From tbl_mERP_CSRedemption scr 
	Where scr.SchemeID = @SchemeID And scr.OutletCode = CustomerID And scr.RFAStatus In (1, 0) And
	scr.PayOutID = tp.PayOutID), 0)

From @TotPoints tp
Group By tp.CustomerID, tp.CustomerName, tp.ChannelType, tp.DefaultBeat, tp.RatePerUnit, tp.PlannedPayout, tp.PayOutID

Select CustomerID, "Beat" = DefaultBeat, "Customer ID" = CustomerID, "Customer Name"	= CustomerName, 
"Customer Type" = ChannelType, "Rate Per Unit" = RatePerUnit, 
"Total Points" = TPoints, "Points Value" = PointsValue,
"Redeemed Point" = RedeemedPoint ,
"Amount Spent" = AmountSpent ,
"Planned Payout" = PlannedPayout ,
"Pending Points" = PendingPoints 
From @TotPoints2
Where TPoints <> 0
Order By DefaultBeat, CustomerID

-----
Drop Table CustList3 
Drop Table IPScope

