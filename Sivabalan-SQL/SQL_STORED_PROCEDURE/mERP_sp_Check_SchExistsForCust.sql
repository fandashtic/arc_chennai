CREATE Procedure mERP_sp_Check_SchExistsForCust(@InvoiceDate Datetime,@OutletID nVarchar(500),@CreationDate nVarchar(50) = N'')
As
Begin
--	Declare @CustChannel As nVarchar(255)
--	Declare @TMDField4  As nVarchar(255)

	Declare @OlMapId int
	Declare @OlChannel nVarchar(255)
	Declare @OlOutlettype nVarchar(255)
	Declare @OlLoyalty nVarchar(255)
    Declare @CDate datetime	
	
	If isNull(@CreationDate,N'') = N''
		Select @CreationDate = GetDate()
	
	Set @CreationDate = Cast(@CreationDate as Datetime)
	set @CDate = dbo.striptimefromdate(@CreationDate)
	set @InvoiceDate = dbo.striptimefromdate(@InvoiceDate)
	/* Begin: Commented Old Scheme functionality of customerchannel  as New functionality based on OLClass Mapping Implemented */	
	--	Select 
	--			@CustChannel = isNull(ChannelDesc,'') , 
	--			@TMDField4 = (Select isNull(TMDMas.TMDValue,'') From  Cust_TMD_Master TMDMas ,Cust_TMD_Details TMDDet 
	--						 Where TMDMas.TMDCtlPos = 6 And TMDMas.TMDID = TMDDet.TMDID And TMDDet.CustomerID = C.CustomerID )
	--	From 
	--			Customer  C,Customer_Channel CH 
	--	Where 
	--			C.CustomerID = @OutletID And
	--			CH.ChannelType = C.ChannelType 
	/* End: Commented Old Scheme functionality of customerchannel as New functionality based on OLClass Mapping Implemented */			

	/* To get Register or Unregister Customer */
	Declare @RegCustomer as nvarchar(100)
	Set @RegCustomer = ''
	Select @RegCustomer = Case When isnull(IsRegistered,0) = 1 Then 'Registered' Else 'UnRegistered' End
	From Customer Where CustomerID = @OutletID

	/* Begin: New functionality Implemented based on OLClass Mapping */

	Select @OlMapId = isNull(OLClassID,0) from  tbl_Merp_OlclassMapping where CustomerID = @OutletID and Active =1

	Select
		 @OlChannel = isNull(Channel_Type_desc,''), 
		 @OlOutlettype = isNull(Outlet_Type_desc,''),
		 @OlLoyalty = isNull(SubOutlet_Type_desc,'')
	From 
		tbl_merp_Olclass 
	where 
		ID = @OlMapId

	/* End: New functionality Implemented based on OLClass Mapping */


--	Select   Count(Distinct S.SchemeID)
	Select   Top 1 S.SchemeID
	From 
		tbl_mERP_SchemeAbstract S,tbl_mERP_SchemeOutlet SO,tbl_mERP_SchemeChannel SC,
		tbl_mERP_SchemeOutletClass  SOLC , tbl_mERP_SchemeLoyaltyList SLList
	Where 
		(@InvoiceDate Between ActiveFrom And ActiveTo) And
		(@CDate Between ActiveFrom And ExpiryDate) And
		Active = 1 And
		S.SchemeType In(1,2) And
		--S.ApplicableOn = 1 And --1  means ItemBased Scheme
		--S.ItemGroup = 1 And
		S.SchemeID = SO.SchemeID And
		(SO.OutletID = @OutletID Or SO.OutletID = N'All')  And
		SO.QPS = 0 And  ---0 - Direct Scheme
		S.SchemeID = SC.SchemeID And
		SC.GroupID = SO.GroupID And
--		(SC.Channel = @CustChannel Or SC.Channel = N'All')  And 
		(SC.Channel = @OlChannel Or SC.Channel = N'All')  And 
		S.SchemeID = SOLC.SchemeID And
		SOLC.GroupID = SO.GroupID And
--		(SOLC.OutLetClass = @TMDField4 Or SOLC.OutLetClass = N'All') 
		(SOLC.OutLetClass = @OlOutlettype Or SOLC.OutLetClass = N'All')  And
		S.SchemeID = SLList.SchemeID And
		SLList.GroupID = SO.GroupID And
		(SLList.LoyaltyName = @OlLoyalty Or SLList.LoyaltyName = N'All')
		and isnull(S.Color,'') = Case When isnull(S.Color,'') = '' Then '' Else @RegCustomer End
End
