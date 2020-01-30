Create Procedure mERP_sp_Find_InvDispSchemeID
(
	@OutletID nVarchar(255),
	@InvoiceAmt Decimal(18,6),
	@TotalAmt Decimal(18,6),
	@InvoiceDate DateTime,
	@SKUCount Int,
	@CreationDate as nVarchar(50) = N'')
As
Begin

	Declare @OLClass nVarchar(255)
	Declare @Channel nVarchar(255)
	Declare @SchemeID Int
	Declare @SchemeDesc nVarchar(255)
	Declare @GroupID Int
	Declare @SlabType Int
	Declare @UOM Int
	Declare @Onward Decimal(18,6)
	Declare @Value Decimal(18,6)
	Declare @SchemeAmt Decimal(18,6)
	Declare @SchemePer Decimal(18,6)
	Declare @FreeUOM Int
	Declare @Volume Int
	Declare @SchemeUOM Int
	Declare @SchemeVolume Int
	Declare @SKUCode nVarchar(255)
	Declare @SKUList nVarchar(2000)
	Declare @SlabID Int
	Set @SKUList = ''

	Declare @OlMapId int
	Declare @OlChannel nVarchar(255)
	Declare @OlOutlettype nVarchar(255)
	Declare @OlLoyalty nVarchar(255)


	If isNull(@CreationDate,N'') = N''
		Select @CreationDate = GetDate()
	
	Set @CreationDate = Cast(@CreationDate as Datetime)

/* Begin: Commented Old Scheme functionality of customerchannel  as New functionality based on OLClass Mapping Implemented */
--	Select @Channel = ChannelDesc From Customer_Channel CC, Customer C
--		 Where C.CustomerID = @OutletID
--		 And CC.ChannelType = C.ChannelType
--
--	Select @OLClass = CM.TMDValue From Cust_TMD_Master CM, Cust_TMD_Details CD 
--			Where CM.TMDID = CD.TMDID
--			And CD.CustomerID = @OutletID
--			And CM.TMDCtlPos = 6
/* End: Commented Old Scheme functionality of customerchannel  as New functionality based on OLClass Mapping Implemented */

/* Begin: New functionality Implemented based on OLClass Mapping */
	Select @OlMapId = OLClassID from  tbl_Merp_OlclassMapping where CustomerID = @OutletID and Active =1
	Select @OlChannel = Channel_TYpe_desc, @OlOutlettype = Outlet_Type_desc, @OlLoyalty= SubOutlet_Type_desc
	From tbl_merp_Olclass where ID = @OlMapId
/* End: New functionality Implemented based on OLClass Mapping */

	/* To get Register or Unregister Customer */
	Declare @RegCustomer as nvarchar(100)
	Set @RegCustomer = ''
	Select @RegCustomer = Case When isnull(IsRegistered,0) = 1 Then 'Registered' Else 'UnRegistered' End
	From Customer Where CustomerID = @OutletID

	Create Table #tmpScheme(SchemeID Int, Description nVarchar(255), GroupID Int)
	Create Table #tmpDetail(SchemeID Int, Description nVarchar(255), SchAmount Decimal(18,6), 
				SchPercentage Decimal(18,6), FreeUOM Int, Volume Int, SlabID Int, SlabType Int, SKUList nVarchar(2000) )

	Insert Into #tmpScheme Select SA.SchemeID, SA.Description, Min(SO.GroupId)
		From tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemeOutlet SO, 
		tbl_mERP_SchemeChannel SC, tbl_mERP_SchemeOutletClass SOC, tbl_mERP_SchemeLoyaltyList SLList
		Where SA.Active  = 1
		And SA.ApplicableOn = 2
		And SA.SchemeType in (1,2)
		And SA.SKUCount <= @SKUCount
		And dbo.StripTimeFromDate(@InvoiceDate) Between dbo.StripTimeFromDate(SA.ActiveFrom) And dbo.StripTimeFromDate(SA.ActiveTo)
		And (dbo.stripTimeFromDate(@CreationDate) Between ActiveFrom And ExpiryDate) 
		And SA.SchemeID = SO.SchemeID
		And SO.QPS = 0 --Direct Scheme
		And (SO.OutletID = @OutletID Or SO.OutletID = N'ALL')
		And SO.SchemeID = SC.SchemeID
		And SO.GroupID = SC.GroupID
--		And (SC.Channel = @Channel Or SC.Channel = N'ALL')
		And (SC.Channel = @OlChannel Or SC.Channel = N'All')  
		And SO.SchemeID = SOC.SchemeID 
		And SO.GroupID = SOC.GroupID
--		And (SOC.OutletClass = @OLClass Or SOC.OutletClass = N'ALL')
		And (SOC.OutLetClass = @OlOutlettype Or SOC.OutLetClass = N'All')
		And SA.SchemeID = SLList.SchemeID
		And SLList.GroupID = SO.GroupID 
		And (SLList.LoyaltyName = @OlLoyalty Or SLList.LoyaltyName = N'All')
		and isnull(SA.Color,'') = Case When isnull(SA.Color,'') = '' Then '' Else @RegCustomer End
		Group By SA.SchemeID, SA.Description
	

	Declare SchemeCur Cursor For
	Select SchemeID, Description, GroupID From #tmpScheme			
	Open SchemeCur
	Fetch Next From SchemeCur Into @SchemeID, @SchemeDesc, @GroupID
	While @@Fetch_Status = 0
	Begin 

		Set @SlabID = 0

		--If multiple slabs in a single group are applicable then select the first slab
		Select @SlabID = Min(SlabID)
		From tbl_mERP_SchemeSlabDetail 
		Where SchemeID = @SchemeID
		And GroupID = @GroupID
		And @TotalAmt Between SlabStart And SlabEnd
		Group By SlabType	


		If IsNull(@SlabID,0) = 0 --If slab details not available then skip 
			Goto SkipScheme
		
		Select @SlabType = SlabType, @UOM = UOM, @Onward = IsNull(Onward,0), @Value = IsNull(Value,0) , 
			@FreeUOM =  IsNull(FreeUOM,0), @Volume = IsNull(Volume,0) 
		From tbl_mERP_SchemeSlabDetail 
		Where SlabId = @SlabID

		If @SlabType = 3 --Invoice based qty scheme will not applied in Invoice from Dispatch
			Goto SkipScheme

		If @SlabType = 1 And @Onward > 0 --Amount
			Set @SchemeAmt = Cast(@TotalAmt / @Onward As Int) * @Value
		Else If @SlabType = 1 And @Onward = 0 --Amount without ForEvery value
			Set @SchemeAmt = @Value
		Else If @SlabType = 2 And @Onward > 0 --Percentage
			Set @SchemeAmt = (@Onward * Cast((@TotalAmt / @Onward) As Int)) * (@Value/100)
		Else If @SlabType = 2 And @Onward = 0 --Percentage without ForEvery value
			Set @SchemeAmt = @TotalAmt * (@Value/100)
		Else If @SlabType = 3 And @Onward > 0 --Free Quantity
		Begin
			Set @SchemeUOM = @FreeUOM
			Set @SchemeVolume = Cast(@TotalAmt / @Onward As Int) * @Volume
		End			
		Else If @SlabType = 3 And @Onward = 0 --Free Quantity without ForEvery value
		Begin
			Set @SchemeUOM = @FreeUOM
			Set @SchemeVolume = @Volume
		End	
		Set @SKUList = ''
		If @SlabType = 3 
		Begin
			Declare SKUCursor Cursor For
			Select Top 1 SKUCode From tbl_mERP_SchemeFreeSKU Where SlabID = @SlabID
			Open SKUCursor
			Fetch Next From SKUCursor Into @SKUCode
			While @@Fetch_Status = 0
			Begin
				Set @SKUList = @SKUList + Char(15) + @SKUCode
			Fetch Next From SKUCursor Into @SKUCode
			End
			Close SKUCursor		
			Deallocate SKUCursor
			If Len(@SKUList) > 0 
				Set @SKUList = Right(@SKUList, Len(@SKUList) - 1) 
		End
		--Percentage calculation for Scheme Amount (For amount including tax)
		If @TotalAmt > 0
		Set @SchemePer = (@SchemeAmt / @TotalAmt) * 100

		--Percentage/Amount calculation for net amount(For amount without tax)
		Set @SchemeAmt =  @InvoiceAmt * (@SchemePer / 100)
		Set @SchemePer = (@SchemeAmt / @InvoiceAmt) * 100

		--If @SchemePer > 100 Goto SkipScheme

		Insert Into #tmpDetail Values(@SchemeID, @SchemeDesc, @SchemeAmt, @SchemePer, @SchemeUOM, @SchemeVolume, 
			@SlabID, @SlabType, @SKUList)
SkipScheme:
	Fetch Next From SchemeCur Into @SchemeID, @SchemeDesc, @GroupID
	End
	Close SchemeCur
	Deallocate SchemeCur

	Select SchemeID as SchemeID, Description as Description, IsNull(SchAmount, 0.00) as SchemeAmt, 
			IsNull(SchPercentage, 0) as SchemePer, IsNull(FreeUOM,0) as SchemeUOM, ISNull(Volume,0) as SchemeVolume, 
			SlabID as SlabID, SlabType as SlabType, ISNull(SKUList, '') as SKUList  From #tmpDetail

	Drop Table #tmpScheme
	Drop Table #tmpDetail
End

