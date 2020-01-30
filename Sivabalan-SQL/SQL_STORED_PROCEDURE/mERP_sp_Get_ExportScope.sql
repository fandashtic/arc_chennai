Create Procedure mERP_sp_Get_ExportScope(@SchemeID Int)
As
Begin

	Declare @GRoupID int	
	Declare @TRANDATE DateTime
	Declare @SchAbstCount int
	Declare @QPS Int 
	Declare @SubGroupID Int 
	Declare @OutletSCopeCnt int
	Declare @ProductSCopeCnt int
		

	Select Top 1 @TRANDATE = dbo.StripTimeFromDate(Transactiondate) From Setup

	Create table #tempSchAbstract ( ID Int Identity(1, 1), ActivityCode nVarchar(2000), SchemeDesc nVarchar(2000), ActiveFrom datetime, 
	ActiveTo datetime, CSSchemeID nVarchar(255), Status nVarchar(100))

	Create table #ProdScope (Category nVarchar(255), SubCategory nVarchar(255), MSKU nVarchar(255), Prodcode nVarchar(255), Prodname nVarchar(255),
		MIN_RANGE Decimal(18,6),
		UOM Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

	Create table #temp1 (
	ID Int Identity(1, 1), SchemeID Int, GrpID Int, SubGroupID int,
	Channel nVarchar(256) Collate SQL_Latin1_General_CP1_CI_AS,
	Outletclass nVarchar(256) Collate SQL_Latin1_General_CP1_CI_AS,
	Loyalty nVarchar(256) Collate SQL_Latin1_General_CP1_CI_AS
	)

	Create table #temp2 (
	ID Int Identity(1, 1), SchemeID Int, GrpID Int, SubGroupID int,
	OutletCode nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
	OutletName nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS
	)


	Create table #tmpOutletScope(GroupID nVarchar(255), SubGroupID int, 
	Channel nVarchar(256) Collate SQL_Latin1_General_CP1_CI_AS,
	Outletclass nVarchar(256) Collate SQL_Latin1_General_CP1_CI_AS,
	Loyalty nVarchar(256) Collate SQL_Latin1_General_CP1_CI_AS,
	OutletCode nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
	OutletName nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS	
	)

	
	Insert Into #tempSchAbstract(ActivityCode, SchemeDesc, ActiveFrom, ActiveTo, CSSchemeID, status) 
	Select 'Activity Code' = SA.ActivityCode, 'Scheme Name' = SA.Description, "Applicable Period From" = SA.ActiveFrom, 
	"Applicable Period To" = SA.ActiveTo, "Comp Sch Id" = SA.CS_RecSchID, 
	"Current Status" =  Case When (@TRANDATE Between SA.ActiveFrom And SA.ActiveTo) Then 'Active'
		When (@TRANDATE  < SA.ActiveFrom ) Then 'Active'
		When (@TRANDATE > SA.ActiveTo) Then 'Expired' End 	
	From tbl_mERP_SchemeAbstract SA where SchemeID = @SchemeID


	Insert into #temp1(SchemeID, GrpID, SubGroupID, Channel, OutletClass, Loyalty)
	Select @SchemeID, SubGrp.GroupID, SubGrp.SubGroupID, 
	SchChannel.Channel, SchOlclass.OutletClass, SchLoyalty.Loyaltyname
	From
		tbl_mERP_SchemeChannel SchChannel, tbl_mERP_SchemeOutletClass  SchOlclass,
		tbl_mERP_SchemeLoyaltyList SchLoyalty, tbl_mERP_SchemeSubGroup SubGrp
	where
		SubGrp.SchemeID = @SchemeID 
		and SchChannel.SchemeID = @SchemeID 
		and SubGrp.SubGroupID = SchChannel.GroupID 
		and SchOlclass.SChemeID = @SchemeID
		and	SubGrp.SubGroupID = SchOlclass.GroupID
		and SubGrp.SchemeID = SchLoyalty.SChemeID
		and SubGrp.SubGroupID = SchLoyalty.GroupID

	Declare QPSGroup Cursor For
	Select SO.QPS, SubGrp.GroupID, SubGrp.SubGroupID From tbl_mERP_SchemeOutlet SO, tbl_mERP_SchemeSubGroup SubGrp 
	Where SO.SChemeID = SubGrp.SchemeID
	and SO.SchemeID = @SchemeID and SO.GroupID = SubGrp.SubGroupID 
	Open QPSGroup
	Fetch From QPSGroup Into @QPS, @GroupID, @SubGroupID  
	While @@FETCH_STATUS = 0
	Begin 	
  		Insert into #temp2(SchemeID, GrpID, SubGroupID, OutletCode, OutletName)
		Select 	@SchemeID, @GroupID, @SubGroupID, CustScope.CustomerCode, Customer.Company_name 
		from dbo.mERP_fn_Get_CSOutletScope_View(@SchemeID, @QPS, @SubGroupID) CustScope
		Left Outer Join  Customer On CustScope.CustomerCode = Customer.CustomerID
		Group By CustScope.CustomerCode, Customer.Company_name  
		Order by 1 
	Fetch Next From QPSGroup Into @QPS, @GroupID, @SubGroupID 
	End
	Close QPSGroup 
	Deallocate QPSGroup

	Insert Into #tmpOutletScope (GroupID, SubGroupID, Channel, Outletclass, Loyalty,  OutletCode, OutletName)
	Select Distinct
		"Group" = 'Group' + Cast(T1.GrpID as nVarchar), "Seq No" = T1.SubGroupID, "Channel" = T1.Channel, "Outlet Type" = T1.OutletClass, 
		"Loyalty Program"= T1.Loyalty
		, "Outlet Code" = T2.OutletCode, "Outlet Name"= T2.OutletName
	from #temp1 T1 Inner join #temp2 T2 On T1.SchemeID = T2.SchemeID and T1.SubGroupID = T2.SubGroupID
	and T1.GrpID = T2.GrpID



Select @OutletSCopeCnt = Count(*) from #tmpOutletScope


Insert Into #ProdScope(Category, SubCategory, MSKU, Prodcode, Prodname)
Select IC3.Category_name, IC4.Category_name, IC5.Category_name, itm.Product_Code, itm.ProductName
from dbo.mERP_fn_Get_CSProductScope(@SchemeID) ProdScope Inner join Items itm on ProdScope.Product_Code = Itm.Product_Code 
join Itemcategories Ic5 on itm.categoryid = IC5.categoryid
join Itemcategories Ic4 on Ic5.parentid = IC4.categoryid
join Itemcategories Ic3 on Ic4.parentid = IC3.categoryid
Order by itm.Product_Code

Update T Set 
	T.MIN_RANGE = Isnull(T1.MIN_RANGE,0),
	T.UOM = Isnull(T1.UOM,'') From #ProdScope T,
	(Select Distinct Product_Code,MIN_RANGE,
	(Case When UOM = 1 Then 'Base UOM'
		When UOM = 2 Then 'UOM1'
		When UOM = 3 Then 'UOM2'
		When UOM = 4 Then 'Value'
		Else Null End) UOM 
	From mERP_fn_Get_CSProductminrange(@SchemeID)) T1
	Where T1.Product_Code = T.Prodcode

Select @ProductSCopeCnt = Count(*) from #ProdScope

Select 7, @OutletSCopeCnt, 5, @ProductSCopeCnt

Select ActivityCode 'Activity Code', SchemeDesc 'Scheme Name', ActiveFrom 'Applicable Period From ' 
,ActiveTo 'Applicable Period To', CSSchemeID 'Comp Sch Id', Status 'Current Status'
from #tempSchAbstract

Select GroupID 'Group', SubGroupID 'Seq No', Channel 'Channel', Outletclass 'Outlet Type', Loyalty 'Loyalty Program',
OutletCode 'Outlet Code', OutletName '  Outlet Name'
from #tmpOutletScope

Select Category 'Category', SubCategory 'Sub Category', MSKU 'Market SKU' , Prodcode 'Item Code'
, Prodname 'Item Name',MIN_RANGE,UOM from #ProdScope

Drop table #ProdScope
Drop table #tempSchAbstract
Drop table #temp1
Drop table #temp2
Drop table #tmpOutletScope
End
