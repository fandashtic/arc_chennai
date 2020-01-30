
Create Procedure [dbo].[mERP_sp_List_Applicable_InvCumSplCatSchemes]  
(  
@OutletID nVarchar(255),  
@InvoiceAmt Decimal(18,6),  
@InvoiceDate DateTime,  
@SKUCount Int,  
@ProductList nvarchar(4000) = '',  
@CreationDate as nvarchar(30)=N''  
)  
As  
Begin  
  
	Declare @OlMapId int  
	Declare @OlChannel nVarchar(255)  
	Declare @OlOutlettype nVarchar(255)  
	Declare @OlLoyalty nVarchar(255)  
	  
	Declare @OLClass nVarchar(255)  
	Declare @Channel nVarchar(255)  
	Declare @SchemeID Int  
	Declare @SchemeDesc nVarchar(255)  
	Declare @GroupID Int  
	Create Table #tmpPrdtScope (SchemeID Int, Product_code nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	Create Table #tmpInvProducts (Product_code nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	Declare @Delimiter Char(1)  
	Set @Delimiter = '|'  
	  
	If (@CreationDate ='')  
		Set @CreationDate = getdate()  
	Else  
		Select @CreationDate = Convert(Datetime, @CreationDate)  
	  
	/* Begin: Commented Old Scheme functionality as New functionality based on OLClass Mapping Implemented */  
	--Select @Channel = ChannelDesc From Customer_Channel CC, Customer C  
	--Where C.CustomerID = @OutletID  
	--And CC.ChannelType = C.ChannelType  
	--  
	--Select @OLClass = CM.TMDValue From Cust_TMD_Master CM, Cust_TMD_Details CD  
	--Where CM.TMDID = CD.TMDID  
	--And CD.CustomerID = @OutletID  
	--And CM.TMDCtlPos = 6  
	/* End: Commented Old Scheme functionality as New functionality based on OLClass Mapping Implemented */  
	  
	/* Begin: New functionality Implemented based on OLClass Mapping */  
	 Select @OlMapId = IsNull(OLClassID,0) from  tbl_Merp_OlclassMapping where CustomerID = @OutletID and Active =1  
	 Select @OlChannel = IsNull(Channel_TYpe_desc,''), @OlOutlettype = IsNull(Outlet_Type_desc,''),   
	 @OlLoyalty= IsNull(SubOutlet_Type_desc,'')  
	 From tbl_merp_Olclass where ID = @OlMapId  
	/* End: New functionality Implemented based on OLClass Mapping */  	  

	/* To get Register or Unregister Customer */
	Declare @RegCustomer as nvarchar(100)
	Set @RegCustomer = ''
	Select @RegCustomer = Case When isnull(IsRegistered,0) = 1 Then 'Registered' Else 'UnRegistered' End
	From Customer Where CustomerID = @OutletID        
	  
	Create Table #tmpScheme(SchemeID Int, Description nVarchar(255), GroupID Int)  
	/*To Fetch Invoice based Schems */  
	Insert Into #tmpScheme Select SA.SchemeID, SA.Description, Min(SO.GroupID)  
	From tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemeOutlet SO,  
	tbl_mERP_SchemeChannel SC, tbl_mERP_SchemeOutletClass SOC,  tbl_mERP_SchemeLoyaltyList SLList  
	Where SA.Active  = 1  
	And SA.ApplicableOn = 2  
	And SA.SchemeType in (1,2)  
	And SA.SKUCount <= @SKUCount  
	And dbo.StripTimeFromDate(@InvoiceDate)  Between dbo.StripTimeFromDate(SA.ActiveFrom) And dbo.StripTimeFromDate(SA.ActiveTo)  
	And dbo.stripTimeFromDate(@CreationDate) Between dbo.StripTimeFromDate(SA.ActiveFrom) And dbo.StripTimeFromDate(SA.ExpiryDate)   
	And SA.SchemeID = SO.SchemeID  
	And SO.QPS = 0 --Direct Scheme  
	And (SO.OutletID = @OutletID Or SO.OutletID = N'ALL')  
	And SO.SchemeID = SC.SchemeID  
	And SO.GroupID = SC.GroupID  
	-- And (SC.Channel = @Channel Or SC.Channel = N'ALL')  
	And (SC.Channel = @OlChannel Or SC.Channel = N'All')    
	And SO.SchemeID = SOC.SchemeID  
	And SO.GroupID = SOC.GroupID  
	-- And (SOC.OutletClass = @OLClass Or SOC.OutletClass = N'ALL')  
	And (SOC.OutLetClass = @OlOutlettype Or SOC.OutLetClass = N'All')    
	And SO.SchemeID = SLList.SchemeID   
	And SO.GroupID = SLList.GroupID   
	And(SLList.LoyaltyName = @OlLoyalty Or SLList.LoyaltyName = N'All')  
	and isnull(SA.Color,'') = Case When isnull(SA.Color,'') = '' Then '' Else @RegCustomer End
	Group By SA.SchemeID, SA.Description  
	  
	/*To Verify the Product Scope*/  
	If Not @ProductList = ''  
	Begin  
		Insert into #tmpInvProducts Select * from dbo.sp_SplitIn2Rows(@ProductList,@Delimiter)  
	End  
	  
	Declare CurSplCatSchemes Cursor For  
	Select SA.SchemeID From tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemeOutlet SO,  
	tbl_mERP_SchemeChannel SC, tbl_mERP_SchemeOutletClass SOC,  tbl_mERP_SchemeLoyaltyList SLList  
	Where SA.Active  = 1  
	And SA.ApplicableOn = 1  
	And SA.ItemGroup = 2  
	And SA.SchemeType in (1,2)  
	/*And SA.SKUCount <= @SKUCount*/  
	And dbo.StripTimeFromDate(@InvoiceDate) Between dbo.StripTimeFromDate(SA.ActiveFrom) And dbo.StripTimeFromDate(SA.ActiveTo)  
	And dbo.stripTimeFromDate(@CreationDate) Between dbo.StripTimeFromDate(SA.ActiveFrom) And dbo.StripTimeFromDate(SA.ExpiryDate)   
	And SA.SchemeID = SO.SchemeID  
	And SO.QPS = 0 --Direct Scheme  
	And (SO.OutletID = @OutletID Or SO.OutletID = N'ALL')  
	And SO.SchemeID = SC.SchemeID  
	And SO.GroupID = SC.GroupID  
	-- And (SC.Channel = @Channel Or SC.Channel = N'ALL')  
	And (SC.Channel = @OlChannel Or SC.Channel = N'All')    
	And SO.SchemeID = SOC.SchemeID  
	And SO.GroupID = SOC.GroupID  
	--And (SOC.OutletClass = @OLClass Or SOC.OutletClass = N'ALL')  
	And (SOC.OutLetClass = @OlOutlettype Or SOC.OutLetClass = N'All')    
	And SO.SchemeID = SLList.SchemeID   
	And SO.GroupID  = SLList.GroupID   
	And (SLList.LoyaltyName = @OlLoyalty Or SLList.LoyaltyName = N'All') 
	and isnull(SA.Color,'') = Case When isnull(SA.Color,'') = '' Then '' Else @RegCustomer End 
	Group By SA.SchemeID  
	Open CurSplCatSchemes  
	Fetch Next From CurSplCatSchemes Into @SchemeID  
	While (@@Fetch_Status = 0)  
	Begin  
		Insert into #tmpPrdtScope Select SchemeID, Product_Code  From dbo.mERP_fn_Get_CSProductScope(@SchemeID)  
		Fetch Next From CurSplCatSchemes Into @SchemeID  
	End  
	Close CurSplCatSchemes  
	Deallocate CurSplCatSchemes  
	  
	/*To Fetch Spl Cat based Schemes */  
	Insert Into #tmpScheme  
	Select SA.SchemeID, SA.Description, Min(SO.GroupID)  
	From tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemeOutlet SO,  
	tbl_mERP_SchemeChannel SC, tbl_mERP_SchemeOutletClass SOC,  tbl_mERP_SchemeLoyaltyList SLList  
	Where SA.Active  = 1  
	And SA.ApplicableOn = 1  
	And SA.ItemGroup = 2  
	And SA.SchemeType in (1,2)  
	/*And SA.SKUCount <= @SKUCount*/  
	And dbo.StripTimeFromDate(@InvoiceDate) Between dbo.StripTimeFromDate(SA.ActiveFrom) And dbo.StripTimeFromDate(SA.ActiveTo)  
	And dbo.stripTimeFromDate(@CreationDate) Between dbo.StripTimeFromDate(SA.ActiveFrom) And dbo.StripTimeFromDate(SA.ExpiryDate)   
	And SA.SchemeID = SO.SchemeID  
	And SO.QPS = 0 --Direct Scheme  
	And (SO.OutletID = @OutletID Or SO.OutletID = N'ALL')  
	And SO.SchemeID = SC.SchemeID  
	And SO.GroupID = SC.GroupID  
	-- And (SC.Channel = @Channel Or SC.Channel = N'ALL')  
	And (SC.Channel = @OlChannel Or SC.Channel = N'All')    
	And SO.SchemeID = SOC.SchemeID  
	And SO.GroupID = SOC.GroupID  
	-- And (SOC.OutletClass = @OLClass Or SOC.OutletClass = N'ALL')  
	And (SOC.OutLetClass = @OlOutlettype Or SOC.OutLetClass = N'All')    
	And  SO.SchemeID = SLList.SchemeID   
	And SO.GroupID = SLList.GroupID   
	And (SLList.LoyaltyName = @OlLoyalty Or SLList.LoyaltyName = N'All')  
	And SA.SchemeID in (Select Distinct tmpPS.SchemeID From  #tmpInvProducts tmpIP, #tmpPrdtScope tmpPS Where tmpPS.Product_Code = tmpIP.Product_Code)  
	and isnull(SA.Color,'') = Case When isnull(SA.Color,'') = '' Then '' Else @RegCustomer End
	Group By SA.SchemeID, SA.Description  
	  
	Select Distinct SABS.SchemeID,CS_RecSchID,ActivityCode,SABS.Description, ActiveFrom, ActiveTo, CSAppType.ApplicableOn, CSIGrp.ItemGroup, GroupID, SABS.ApplicableOn, SABS.ItemGroup  
	From tbl_mERP_schemeAbstract SABS, #tmpScheme T, tbl_mERP_SchemeItemGroup CSIGrp, tbl_mERP_SchemeApplicableType CSAppType  
	Where SABS.SchemeID = T.SchemeID And  
	SABS.ApplicableOn = CSAppType.ID And  
	SABS.ItemGroup = CSIGrp.ID  
	  
	Drop table #tmpScheme  
	Drop table #tmpInvProducts  
	Drop table #tmpPrdtScope  
End  
