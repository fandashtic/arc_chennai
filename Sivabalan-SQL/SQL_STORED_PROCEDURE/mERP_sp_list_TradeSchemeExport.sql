Create procedure mERP_sp_list_TradeSchemeExport(@SchemeCode nVarChar(50), 
@FromDate DateTime, @ToDate DateTime, @FILTER INT = 0, @SchType Int = 0)
As
Declare @TRANDATE DateTime

Select Top 1 @TRANDATE = dbo.StripTimeFromDate(Transactiondate) From Setup

Create Table #tempSchDetails (IDs Int Identity(1, 1), SchemeID Int, CSSchID Int, GrpID Int, 
	Activity_Code nVarchar(510) Collate SQL_Latin1_General_CP1_CI_AS,
	ScType nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS, 
	Activity_Type nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS, 
	Status nVarchar(20) Collate SQL_Latin1_General_CP1_CI_AS, 
	Period nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS, 
	Description nVarchar(510) Collate SQL_Latin1_General_CP1_CI_AS, 
	Applicable_On nVarchar(20) Collate SQL_Latin1_General_CP1_CI_AS, 
	RFA_Frequency nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS, 
	Category nVarchar(256) Collate SQL_Latin1_General_CP1_CI_AS, 
	Sub_Category nVarchar(256) Collate SQL_Latin1_General_CP1_CI_AS, 
	MarketSKU nVarchar(510) Collate SQL_Latin1_General_CP1_CI_AS, 
	SKU nVarchar(510) Collate SQL_Latin1_General_CP1_CI_AS,
	Channel nVarchar(256) Collate SQL_Latin1_General_CP1_CI_AS,
	Outlet nVarchar(256) Collate SQL_Latin1_General_CP1_CI_AS,
	Loyalty nVarchar(256) Collate SQL_Latin1_General_CP1_CI_AS,
	Slabs nVarchar(1000) Collate SQL_Latin1_General_CP1_CI_AS, 
	SlabID Int,
	List nVarchar(510) Collate SQL_Latin1_General_CP1_CI_AS)


Insert InTo #tempSchDetails (SchemeID , CSSchID , 
	Activity_Code , ScType , Activity_Type , Status , 
	Period , Description , Applicable_On)
Select "sc" = sa.SchemeID, "rcsc" = sa.CS_RecSchID, "Activity Code" = SA.ActivityCode, 
	"Type" = ScTy.SchemeType, 
	"Activity Type" = Case SA.SchemeStatus When 2 Then 'Drop' When 1 Then 'CR' Else 'New' End,
	"Status" =  Case When (@TRANDATE Between SA.ActiveFrom And SA.ActiveTo) Then 'Open'
		When (@TRANDATE  < SA.ActiveFrom ) Then 'Open'
		When @TRANDATE > SA.ActiveTo Then 'Expired' End,
	"Period" = (Case Len(Cast(Datepart(dd, SA.SchemeFrom) As nVarchar)) When 1 Then
		'0' + Cast(Datepart(dd, SA.SchemeFrom) As nVarchar) Else 
		Cast(Datepart(dd, SA.SchemeFrom) As nVarchar) End) 
		 + '/' + (Case Len(Cast(Datepart(mm, SA.SchemeFrom) As nVarchar)) When 1 Then
		'0' + Cast(Datepart(mm, SA.SchemeFrom) As nVarchar) Else 
		Cast(Datepart(mm, SA.SchemeFrom) As nVarchar) End) + 
		'/' + Cast(Datepart(yyyy, SA.SchemeFrom) As nVarchar) + ' To ' + 
		(Case Len(Cast(Datepart(dd, SA.SchemeTo) As nVarchar)) When 1 Then
		'0' + Cast(Datepart(dd, SA.SchemeTo) As nVarchar) Else 
		Cast(Datepart(dd, SA.SchemeTo) As nVarchar) End) 
		 + '/' + (Case Len(Cast(Datepart(mm, SA.SchemeTo) As nVarchar)) When 1 Then
		'0' + Cast(Datepart(mm, SA.SchemeTo) As nVarchar) Else 
		Cast(Datepart(mm, SA.SchemeTo) As nVarchar) End) + 
		'/' + Cast(Datepart(yyyy, SA.SchemeTo) As nVarchar),
	"Description" = SA.Description,
	"Applicable On" = Case ScApTy.ApplicableOn When 'LINE' Then 'Item' Else ScApTy.ApplicableOn End --,
From tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemeType ScTy,

	tbl_mERP_SchemeApplicableType ScApTy 
Where SA.SchemeType = scty.ID And 
	sa.ApplicableOn = scapty.ID And 
	(IsNull(SA.SchemeType, 0) = (Case @SchType  When 0 Then 1 When 4 Then 4 When 5 Then 5 End) Or 
	IsNull(SA.SchemeType, 0) = (Case @SchType  When 0 Then 2 End))
		  And ((@FromDate Between sa.ViewDate And sa.SchemeTo)  Or 
          (@ToDate Between sa.ViewDate And sa.SchemeTo) or 
		  (sa.ViewDate Between @FromDate And @ToDate) Or
          (sa.SchemeTo Between @FromDate And @ToDate)) And 
	sa.CS_RecSchID = Case @SchemeCode When N'%' Then sa.CS_RecSchID Else @SchemeCode End  
	And dbo.StripTimeFromDate(sa.ViewDAte) <= (Select Top 1 dbo.StripTimeFromDate(Transactiondate) From Setup)
	And sa.Active = Case @FILTER WHEN 0 THEN sa.Active WHEN 1 THEN 1 WHEN 2 THEN 0 END
Order by sa.CS_RecSchID



---============================================================================
Create Table #RFAFrequencys  ([ID] Int Identity(1,1), SchemeID Int, PayoutID Int, 
RFAFrequency nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)

Create Table #ScCategory  ([ID] Int Identity(1,1), SchemeID Int, 
Category nVarchar(256) Collate SQL_Latin1_General_CP1_CI_AS)

Create Table #SubCategory ([ID] Int Identity(1,1), SchemeID Int, 
SubCat nVarchar(256) Collate SQL_Latin1_General_CP1_CI_AS)

Create Table #MarketSKU ([ID] Int Identity(1,1), SchemeID Int, 
MarSKU nVarchar(256) Collate SQL_Latin1_General_CP1_CI_AS)

Create Table #SystemSKU ([ID] Int Identity(1,1), SchemeID Int, 
SysSKU nVarchar(256) Collate SQL_Latin1_General_CP1_CI_AS)

Create Table #TotScChannel ([ID] Int Identity(1,1), SchemeID Int, GrpID Int,
Channel nVarchar(256) Collate SQL_Latin1_General_CP1_CI_AS)

Create Table #ScChannel ([ID] Int Identity(1,1), SchemeID Int, GrpID Int,
Channel nVarchar(256) Collate SQL_Latin1_General_CP1_CI_AS)

Create Table #TotScOutlet ([ID] Int Identity(1,1), SchemeID Int, GrpID Int,
Outlet nVarchar(256) Collate SQL_Latin1_General_CP1_CI_AS)

Create Table #ScOutlet ([ID] Int Identity(1,1), SchemeID Int, GrpID Int,
Outlet nVarchar(256) Collate SQL_Latin1_General_CP1_CI_AS)

Create Table #TotScLoyalty ([ID] Int Identity(1,1), SchemeID Int, GrpID Int,
Loyalty nVarchar(256) Collate SQL_Latin1_General_CP1_CI_AS)

Create Table #ScLoyalty ([ID] Int Identity(1,1), SchemeID Int, GrpID Int,
Loyalty nVarchar(256) Collate SQL_Latin1_General_CP1_CI_AS)

Create Table #TotSlabDetl ([ID] Int Identity(1,1), SchemeID Int, GrpID Int,
Slabs nVarchar(1000) Collate SQL_Latin1_General_CP1_CI_AS, SlabID Int)

Create Table #SlabDetl ([ID] Int Identity(1,1), SchemeID Int, GrpID Int,
Slabs nVarchar(1000) Collate SQL_Latin1_General_CP1_CI_AS, SlabID Int)

Create Table #TotSlabItemDetl ([ID] Int Identity(1,1), SchemeID Int, GrpID Int,
Slabs nVarchar(1000) Collate SQL_Latin1_General_CP1_CI_AS, SlabID Int, 
Item nVarchar(510) Collate SQL_Latin1_General_CP1_CI_AS, )

Create Table #SlabItemDetl ([ID] Int Identity(1,1), SchemeID Int, GrpID Int,
Slabs nVarchar(1000) Collate SQL_Latin1_General_CP1_CI_AS, SlabID Int, 
Item nVarchar(510) Collate SQL_Latin1_General_CP1_CI_AS, )

Create Table #TotComSlabItemDetl ([ID] Int Identity(1,1), SchemeID Int, GrpID Int,
Slabs nVarchar(1000) Collate SQL_Latin1_General_CP1_CI_AS, SlabID Int, 
Item nVarchar(510) Collate SQL_Latin1_General_CP1_CI_AS, )

Create Table #ComSlabItemDetl ([ID] Int Identity(1,1), SchemeID Int, GrpID Int,
Slabs nVarchar(1000) Collate SQL_Latin1_General_CP1_CI_AS, SlabID Int, 
Item nVarchar(510) Collate SQL_Latin1_General_CP1_CI_AS, )

Declare @RFACount Int
Declare @STabCount Int
Declare @BCount Int
Declare @GrpCount Int
Declare @GBase Int
Declare @Sc1 Int
Declare @MinID Int 
Declare @StdMinID Int
Declare @ChkGrpID Int
Declare @PreGrpID Int
Declare @MaxChnlC Int
Declare @MaxOutletC Int
Declare @MaxLoylC Int
Declare @MaxChnlColumn Int
Declare @MaxCount2 Int
Declare @LstIDused Int
Declare @Indicator1 Int
Declare @MaxSlabC Int
Declare @MaxSlabItC Int
Declare @ChkSlabID Int
Declare @PreSlabID Int


Set @MaxSlabC = 0
Set @Indicator1 = 0
Set @LstIDused = 0
Set @MaxChnlC = 0
Set @MaxOutletC = 0
Set @MaxLoylC = 0
Set @MaxChnlColumn = 0
Set @ChkGrpID = 0
Set @PreGrpID = 0
Set @BCount = 1
Set @GrpCount = 0
Set @GBase = 1
Set @MaxCount2 = 0
Set @MaxSlabItC = 0
Set @ChkSlabID = 0
Set @PreSlabID = 0

Declare ScDtls Cursor For
Select Distinct SchemeID From #tempSchDetails 
Open ScDtls 
Fetch From ScDtls InTo @Sc1
While @@Fetch_Status = 0
Begin
	Insert Into #RFAFrequencys (SchemeID , PayoutID , 
	RFAFrequency)
 	Select ScPyOut.SchemeID, ScPyOut.ID, 
    "RFA Frequency" = (Case Len(Cast(Datepart(dd, ScPyOut.PayoutPeriodFrom) As nVarchar)) When 1 Then
		'0' + Cast(Datepart(dd, ScPyOut.PayoutPeriodFrom) As nVarchar) Else 
		Cast(Datepart(dd, ScPyOut.PayoutPeriodFrom) As nVarchar) End) 
		 + '/' + (Case Len(Cast(Datepart(mm, ScPyOut.PayoutPeriodFrom) As nVarchar)) When 1 Then
		'0' + Cast(Datepart(mm, ScPyOut.PayoutPeriodFrom) As nVarchar) Else 
		Cast(Datepart(mm, ScPyOut.PayoutPeriodFrom) As nVarchar) End) + 
		'/' + Cast(Datepart(yyyy, ScPyOut.PayoutPeriodFrom) As nVarchar) + ' To ' + 
		(Case Len(Cast(Datepart(dd, ScPyOut.PayoutPeriodTo) As nVarchar)) When 1 Then
		'0' + Cast(Datepart(dd, ScPyOut.PayoutPeriodTo) As nVarchar) Else 
		Cast(Datepart(dd, ScPyOut.PayoutPeriodTo) As nVarchar) End) 
		 + '/' + (Case Len(Cast(Datepart(mm, ScPyOut.PayoutPeriodTo) As nVarchar)) When 1 Then
		'0' + Cast(Datepart(mm, ScPyOut.PayoutPeriodTo) As nVarchar) Else 
		Cast(Datepart(mm, ScPyOut.PayoutPeriodTo) As nVarchar) End) + 
		'/' + Cast(Datepart(yyyy, ScPyOut.PayoutPeriodTo) As nVarchar)
	From tbl_mERP_SchemePAyoutPeriod ScPyOut 
	Where ScPyOut.SchemeID = @Sc1 

	Select @STabCount = Count(SchemeID) From #tempSchDetails 
	Where SchemeID = @Sc1
	
	Select @MinID = Min(IDs) From #tempSchDetails
	Where SchemeID = @Sc1

	While @BCount <= @STabCount 
	Begin
		Update 	#tempSchDetails Set RFA_Frequency = (Select RFAFrequency From #RFAFrequencys 
			Where [ID] = @BCount) 
		Where IDs = @MinID

		Select Top 1 @MinID = IDs From #tempSchDetails
		Where IDs > @MinID And SchemeID = @Sc1 
		Order By IDs
	
		Set @BCount = @BCount + 1		
	End
	
	Insert InTo #tempSchDetails (SchemeID, RFA_Frequency)
	Select SchemeID, RFAFrequency From #RFAFrequencys
	Where RFAFrequency Not In (Select RFA_Frequency From #tempSchDetails 
		Where SchemeID = @Sc1)
	
	Truncate Table #RFAFrequencys
	Set @BCount = 1
	Set @STabCount = 0
	Set @MinID = 0
---------------------------------------------------------------
--Category

	Insert InTo #ScCategory (SchemeID , Category)
	Select Distinct sccat.SchemeID, "Category" = sccat.Category
	From tbl_mERP_SchCategoryScope sccat 
	Where sccat.SchemeID = @Sc1 

	Select @STabCount = Count(SchemeID) From #tempSchDetails 
	Where SchemeID = @Sc1
	
	Select @MinID = Min(IDs) From #tempSchDetails
	Where SchemeID = @Sc1

	While @BCount <= @STabCount 
	Begin
		Update 	#tempSchDetails Set Category = (Select Category From #ScCategory 
			Where [ID] = @BCount) 
		Where IDs = @MinID

		Select Top 1 @MinID = IDs From #tempSchDetails
		Where IDs > @MinID And SchemeID = @Sc1 
		Order By IDs
	
		Set @BCount = @BCount + 1		
	End
	
	Insert InTo #tempSchDetails (SchemeID, Category)
	Select SchemeID, Category From #ScCategory
	Where Category Not In (Select Category From #tempSchDetails 
		Where SchemeID = @Sc1)

	Truncate Table #ScCategory
	Set @BCount = 1
	Set @STabCount = 0
	Set @MinID = 0

--=======================================
--Sub category

	Insert Into #SubCategory (SchemeID, SubCat)
	Select Distinct scsubcat.SchemeID, "Sub Category" = scsubcat.SubCategory
	From tbl_mERP_SchSubCategoryScope scsubcat
	Where scsubcat.SchemeID = @Sc1

	Select @STabCount = Count(SchemeID) From #tempSchDetails 
	Where SchemeID = @Sc1
	
	Select @MinID = Min(IDs) From #tempSchDetails
	Where SchemeID = @Sc1

	While @BCount <= @STabCount 
	Begin
		Update 	#tempSchDetails Set Sub_Category = (Select SubCat From #SubCategory 
			Where [ID] = @BCount) 
		Where IDs = @MinID

		Select Top 1 @MinID = IDs From #tempSchDetails
		Where IDs > @MinID And SchemeID = @Sc1 
		Order By IDs
	
		Set @BCount = @BCount + 1		
	End
	
	Insert InTo #tempSchDetails (SchemeID, Sub_Category)
	Select SchemeID, SubCat From #SubCategory
	Where SubCat Not In (Select Sub_Category From #tempSchDetails 
		Where SchemeID = @Sc1)

	Truncate Table #SubCategory
	Set @BCount = 1
	Set @STabCount = 0
	Set @MinID = 0


--=======================================
-- Market SKU

	Insert InTo #MarketSKU (SchemeID, MarSKU) 
	Select Distinct scmk.SchemeID, "MarketSKU" = scmk.MarketSKU 
	From tbl_mERP_SchMarketSKUScope scmk 
	Where scmk.SchemeID = @Sc1

	Select @STabCount = Count(SchemeID) From #tempSchDetails 
	Where SchemeID = @Sc1
	
	Select @MinID = Min(IDs) From #tempSchDetails
	Where SchemeID = @Sc1

	While @BCount <= @STabCount 
	Begin
		Update 	#tempSchDetails Set MarketSKU = (Select MarSKU From #MarketSKU 
			Where [ID] = @BCount) 
		Where IDs = @MinID

		Select Top 1 @MinID = IDs From #tempSchDetails
		Where IDs > @MinID And SchemeID = @Sc1 
		Order By IDs
	
		Set @BCount = @BCount + 1		
	End
	
	Insert InTo #tempSchDetails (SchemeID, MarketSKU)
	Select SchemeID, MarSKU From #MarketSKU
	Where MarSKU Not In (Select MarketSKU From #tempSchDetails 
		Where SchemeID = @Sc1)

	Truncate Table #MarketSKU
	Set @BCount = 1
	Set @STabCount = 0
	Set @MinID = 0


--=======================================
--system sku

	Insert InTo #SystemSKU (SchemeID, SysSku) 
	Select Distinct scsku.SchemeID, "SKU" = scsku.SKUCode 
	From  tbl_mERP_SchSKUCodeScope scsku
	Where scsku.SchemeID = @Sc1
	
	Select @STabCount = Count(SchemeID) From #tempSchDetails 
	Where SchemeID = @Sc1
	
	Select @MinID = Min(IDs) From #tempSchDetails
	Where SchemeID = @Sc1

	While @BCount <= @STabCount 
	Begin
		Update 	#tempSchDetails Set SKU = (Select SysSku From #SystemSKU 
			Where [ID] = @BCount) 
		Where IDs = @MinID

		Select Top 1 @MinID = IDs From #tempSchDetails
		Where IDs > @MinID And SchemeID = @Sc1 
		Order By IDs
	
		Set @BCount = @BCount + 1		
	End
	
	Insert InTo #tempSchDetails (SchemeID, SKU)
	Select SchemeID, SysSku From #SystemSKU
	Where SysSku Not In (Select SKU From #tempSchDetails 
		Where SchemeID = @Sc1)

	Truncate Table #SystemSKU
	Set @BCount = 1
	Set @STabCount = 0
	Set @MinID = 0


--=======================================
--Channel 

	Insert InTo #TotScChannel (SchemeID , GrpID, Channel )
	Select Distinct scchl.SchemeID, scchl.GroupID, "Channel" = scchl.Channel From 
	tbl_mERP_SchemeChannel scchl
	Where scchl.SchemeID = @Sc1
	Order By scchl.GroupID

	Insert InTo #TotScLoyalty (SchemeID , GrpID , Loyalty)
	Select Distinct scly.SchemeID, scly.GroupID, scly.Loyaltyname From 
	tbl_mERP_SchemeLoyaltyList scly
	Where scly.SchemeID = @Sc1
	Order By scly.GroupID

	Insert InTo #TotScOutlet (SchemeID , GrpID , Outlet)
	Select Distinct scotl.SchemeID, scotl.GroupID, scotl.OutletClass From 
	tbl_mERP_SchemeOutletClass scotl
	Where scotl.SchemeID = @Sc1
	Order By scotl.GroupID

	Insert InTo #TotSlabDetl (SchemeID , GrpID , Slabs, SlabID )
	Select Distinct scsld.SchemeID, scsld.GroupID, "Slabs" = 'From ' + Cast(scsld.SlabStart As nVarchar) + 
		' To ' + Cast(scsld.SlabEnd As nVarchar) + 
		Case IsNull(5, 0) When 1 Then ' BUOM' When 2 Then ' UOM1' When 3 Then ' UOM2' When 4 
		Then ' Rs.' Else ' ' End + ' (For Every ' + Cast(IsNull(scsld.Onward,0) As nVarchar) + 
		Case IsNull(scsld.UOM,0) When 1 Then ' BUOM) ' When 2 Then ' UOM1) ' When 3 Then ' UOM2) ' When 4 
		Then ' Rs.) ' Else ' ' End + 
		Case scsld.SlabType When 1 Then Cast(IsNull(scsld.[Value],0) As nVarchar) + ' Rs. Discount'
		When 2 Then Cast(IsNull(scsld.[Value],0) As nVarchar) + ' % Discount' 
		When 3 Then Cast(IsNull(scsld.Volume,0) As nVarchar) + 
			(Case IsNull(scsld.FreeUOM,0) When 1 Then ' BUOM Free' When 2 Then ' UOM1 Free' When 3 Then ' UOM2 Free' When 4 
			Then ' Rs. Discount' Else ' ' End)
		When 5 Then Cast(IsNull(scsld.[Value],0) As nVarchar) + ' Points' 
		Else ' ' End, SlabID
	From tbl_mERP_SchemeSlabDetail scsld
	Where scsld.SchemeID = @Sc1
	Order By scsld.GroupID

	Insert InTo #TotSlabItemDetl (SchemeID , GrpID , Slabs, SlabID , Item) 
	Select Distinct tsd.SchemeID , tsd.GrpID , tsd.Slabs, tsd.SlabID, FreeSKU.SKUCode + '~' + IsNull(Items.ProductName, '') 
	From tbl_mERP_SchemeFreeSKU FreeSKU 
	inner join #TotSlabDetl tsd on FreeSKU.SlabID = tsd.SlabID
	left outer join Items  on FreeSKU.SKUCode = Items.Product_Code
	
	Order by 1

	Insert Into #TotComSlabItemDetl (SchemeID , GrpID , Slabs, SlabID , Item)
	Select tsd.SchemeID , tsd.GrpID , tsd.Slabs, tsd.SlabID, tsid.Item
	From #TotSlabDetl tsd left outer join #TotSlabItemDetl tsid
	on  tsd.SlabID = tsid.SlabID

--	Select "Items" = FreeSKU.SKUCode + '~' + IsNull(Items.ProductName, '') 
--	From tbl_mERP_SchemeFreeSKU FreeSKU, Items 
--	Where FreeSKU.SlabID =@SlabID  And 
--	FreeSKU.SKUCode *= Items.Product_Code
--	Order by 1 

--	Select * From dbo.MERP_FN_GetSlabWiseItem_ITC(SlabID)

	Select @GrpCount = Count(*) From (
	Select "GrpCount" = Count(Channel), GrpId
	From #TotScChannel
	Group By GrpId) st
	
	Select Top 1 @ChkGrpID = GrpId From #TotScChannel
	Group By GrpId
	Order By GrpId

	Set @PreGrpID = @ChkGrpID

	While @GBase <= @GrpCount 
	Begin
	
		Select @MaxChnlC = Count(Channel)
		From #TotScChannel
		Where GrpId = @PreGrpID
	--		Group By GrpId

		Select @MaxOutletC = Count(Outlet)
		From #TotScOutlet
		Where GrpId = @PreGrpID
	--		Group By GrpId

		Select @MaxLoylC = Count(Loyalty)
		From #TotScLoyalty
		Where GrpId = @PreGrpID
	--		Group By GrpId

		Select @MaxSlabC = Count(Slabs) 
		From #TotComSlabItemDetl 
		Where GrpID = @PreGrpID

--		Select @MaxSlabItC = Count(Item)
--		From #TotSlabItemDetl 
--		Where GrpID = @PreGrpID 

		If @MaxChnlC > @MaxOutletC 
			Set @MaxChnlColumn = @MaxChnlC
		Else 
			Set @MaxChnlColumn = @MaxOutletC

		If @MaxChnlColumn > @MaxLoylC
			Set @MaxChnlColumn = @MaxChnlColumn
		Else 
			Set @MaxChnlColumn = @MaxLoylC

		If @MaxChnlColumn > @MaxSlabC
			Set @MaxChnlColumn = @MaxChnlColumn
		Else 
			Set @MaxChnlColumn = @MaxSlabC
		
--		If @MaxChnlColumn > @MaxSlabItC
--			Set @MaxChnlColumn = @MaxChnlColumn
--		Else 
--			Set @MaxChnlColumn = @MaxSlabItC
		

		Insert InTo #ScChannel (SchemeID , GrpID, Channel )
		Select  SchemeID , GrpID, IsNull((Select Top 1 Right(Channel_Type_Code, 2) From tbl_merp_olclass 
	Where Channel_Type_Desc = Channel), '') + '~' + Channel From #TotScChannel 
		Where GrpID = @PreGrpID 
		Order By GrpID 
	
--		Select @MaxCount2 = Count(Channel) From 
--		ScChannel 

--select @GrpCount, @MaxChnlColumn, @MaxChnlC, @LstIDused
--Select * from ScChannel



--===============================================================

		Select @STabCount = Count(SchemeID) From #tempSchDetails 
		Where SchemeID = @Sc1 And IDs > @LstIDused
		
		Select @MinID = Min(IDs) From #tempSchDetails
		Where SchemeID = @Sc1 And IDs > @LstIDused

		While @BCount <= @STabCount 
		Begin
			If @BCount <= @MaxChnlC 
			Begin
				Update 	#tempSchDetails Set Channel = (Select Channel From #ScChannel 
				Where [ID] = @BCount) , GrpID = (Select GrpID From #ScChannel 
				Where [ID] = @BCount)
				Where IDs = @MinID

				Set @LstIDused = @MinID

				Select Top 1 @MinID = IDs From #tempSchDetails
				Where IDs > @MinID And SchemeID = @Sc1 
				Order By IDs
			End 
			Else If @MaxChnlColumn = @MaxChnlC And @BCount > @MaxChnlC
			Begin
				If @GBase < @GrpCount
				Begin
					Update 	#tempSchDetails Set Channel = '', GrpID = 0
					Where IDs = @MinID

					Set @LstIDused = @MinID
				End
				
				Set @Indicator1 = 1
								
				Goto Lbl_1
				
			End
			Else
			Begin
				Goto Lbl_1				
			End

			Set @BCount = @BCount + 1		
		End

		Lbl_1: 
				While @BCount <= @STabCount 
				Begin
					Select Top 1 @MinID = IDs From #tempSchDetails
					Where IDs > @LstIDused And SchemeID = @Sc1 
					Order By IDs

					If @MaxChnlColumn  > @MaxChnlC
					Begin
						Update 	#tempSchDetails Set Channel = '', GrpID = 0 
						Where IDs = @MinID

						Set @MaxChnlC = @MaxChnlC + 1

						Set @LstIDused = @MinID
					End
					Else 
					Begin
						GoTo Lbl1Lbl
					End
					
					Set @BCount = @BCount + 1
				End 

		Lbl1Lbl:
				If IsNull((Select Count(*) From #ScChannel Where [ID] >= @BCount), 0) > 0
				Begin
					Insert InTo #tempSchDetails (SchemeID, Channel, GrpID)
					Select SchemeID, Channel, GrpID From #ScChannel
					Where [ID] >= @BCount -- Not In (Select Channel From #tempSchDetails 
						--Where SchemeID = @Sc1)

					Select @LstIDused = Max(IDs) From #tempSchDetails
				End

			While @MaxChnlColumn  > @MaxChnlC
			Begin
				Insert InTo #tempSchDetails (SchemeID, Channel, GrpID)
				Select @Sc1, '', 0

				Set @MaxChnlC = @MaxChnlC + 1

				Select @LstIDused = Max(IDs) From #tempSchDetails
			End

			If @Indicator1 = 0
			Begin

				If @BCount <= @STabCount
				Begin
					Select Top 1 @MinID = IDs From #tempSchDetails
					Where IDs > @LstIDused And SchemeID = @Sc1 
					Order By IDs

					If @GBase < @GrpCount
					Begin
						Update 	#tempSchDetails Set Channel = '', GrpID = 0 
						Where IDs = @MinID

						Set @LstIDused = @MinID

						Set @BCount = @BCount + 1
					End

				End
				Else
				Begin
		
					If @GBase < @GrpCount
					Begin
						Insert InTo #tempSchDetails (SchemeID, Channel, GrpID)
						Select @Sc1, '', 0
						Select @LstIDused = Max(IDs) From #tempSchDetails
					End

				End

			End

				

		Truncate Table #ScChannel
		Set @BCount = 1
		Set @STabCount = 0
		Set @MinID = 0
		Set @Indicator1 = 0

		Select Top 1 @PreGrpID = GrpId From #TotScChannel Where GrpId > @PreGrpID
			Group By GrpId
			Order By GrpId

		Set @GBase = @GBase + 1 
	End

Set @GBase = 1
Set @PreGrpID = 0
Set @MaxChnlC = 0
Set @MaxOutletC = 0
Set @MaxLoylC = 0
Set @MaxChnlColumn = 0
Set @LstIDused = 0
Set @MaxSlabC = 0
--=======================================
-- Outlet class


	Set @PreGrpID = @ChkGrpID

	While @GBase <= @GrpCount 
	Begin
	
		Select @MaxChnlC = Count(Channel)
		From #TotScChannel
		Where GrpId = @PreGrpID
	--		Group By GrpId

		Select @MaxOutletC = Count(Outlet)
		From #TotScOutlet
		Where GrpId = @PreGrpID
	--		Group By GrpId

		Select @MaxLoylC = Count(Loyalty)
		From #TotScLoyalty
		Where GrpId = @PreGrpID
	--		Group By GrpId

		Select @MaxSlabC = Count(Slabs) 
		From #TotComSlabItemDetl 
		Where GrpID = @PreGrpID

--		Select @MaxSlabItC = Count(Item)
--		From #TotSlabItemDetl 
--		Where GrpID = @PreGrpID


		If @MaxChnlC > @MaxOutletC 
			Set @MaxChnlColumn = @MaxChnlC
		Else 
			Set @MaxChnlColumn = @MaxOutletC

		If @MaxChnlColumn > @MaxLoylC
			Set @MaxChnlColumn = @MaxChnlColumn
		Else 
			Set @MaxChnlColumn = @MaxLoylC

		If @MaxChnlColumn > @MaxSlabC
			Set @MaxChnlColumn = @MaxChnlColumn
		Else 
			Set @MaxChnlColumn = @MaxSlabC

--		If @MaxChnlColumn > @MaxSlabItC
--			Set @MaxChnlColumn = @MaxChnlColumn
--		Else 
--			Set @MaxChnlColumn = @MaxSlabItC

		Insert InTo #ScOutlet (SchemeID , GrpID , Outlet)
		Select  SchemeID , GrpID, IsNull((Select Top 1 Right(Outlet_Type_Code, 2) From tbl_merp_olclass 
	Where Outlet_Type_Desc = Outlet), '') + '~' + Outlet From #TotScOutlet 
		Where GrpID = @PreGrpID 
		Order By GrpID 


	
--		Select @MaxCount2 = Count(Channel) From 
--		ScChannel 

--select @PreGrpID, @MaxChnlColumn,  @MaxOutletC
--Select * from ScOutlet



--===============================================================

		Select @STabCount = Count(SchemeID) From #tempSchDetails 
		Where SchemeID = @Sc1 And IDs > @LstIDused
		
		Select @MinID = Min(IDs) From #tempSchDetails
		Where SchemeID = @Sc1 And IDs > @LstIDused

		While @BCount <= @STabCount 
		Begin
			If @BCount <= @MaxOutletC 
			Begin
				Update 	#tempSchDetails Set Outlet = (Select Outlet From #ScOutlet 
				Where [ID] = @BCount) 
				Where IDs = @MinID

				Set @LstIDused = @MinID

				Select Top 1 @MinID = IDs From #tempSchDetails
				Where IDs > @MinID And SchemeID = @Sc1 
				Order By IDs
			End 
			Else If @MaxChnlColumn = @MaxOutletC And @BCount > @MaxOutletC
			Begin
				If @GBase < @GrpCount
				Begin
					Update 	#tempSchDetails Set Outlet = ''
					Where IDs = @MinID

					Set @LstIDused = @MinID
				End

				Set @Indicator1 = 1
				
				
				Goto Lbl_2
				
			End
			Else
			Begin
				Goto Lbl_2				
			End

			Set @BCount = @BCount + 1		
		End


		Lbl_2: 

--select @BCount, @STabCount, @LstIDused
				While @BCount <= @STabCount 
				Begin
					Select Top 1 @MinID = IDs From #tempSchDetails
					Where IDs > @LstIDused And SchemeID = @Sc1 
					Order By IDs

					If @MaxChnlColumn  > @MaxOutletC
					Begin
						Update 	#tempSchDetails Set Outlet = ''
						Where IDs = @MinID

						Set @MaxOutletC = @MaxOutletC + 1
						Set @LstIDused = @MinID
					End
					Else 
					Begin
						GoTo Lbl2Lbl
					End
					
					Set @BCount = @BCount + 1
				End 

		Lbl2Lbl:	
				If IsNull((Select Count(*) From #ScOutlet	Where [ID] >= @BCount), 0) > 0
				Begin
					Insert InTo #tempSchDetails (SchemeID, Outlet)
					Select SchemeID, Outlet From #ScOutlet
					Where [ID] >= @BCount -- Not In (Select Channel From #tempSchDetails 
						--Where SchemeID = @Sc1)

					Select @LstIDused = Max(IDs) From #tempSchDetails
				End

			While @MaxChnlColumn  > @MaxOutletC
			Begin
				Insert InTo #tempSchDetails (SchemeID, Outlet)
				Select @Sc1, ''

				Set @MaxOutletC = @MaxOutletC + 1

				Select @LstIDused = Max(IDs) From #tempSchDetails
			End


			If @Indicator1 = 0
			Begin
				If @BCount <= @STabCount
				Begin
					Select Top 1 @MinID = IDs From #tempSchDetails
					Where IDs > @LstIDused And SchemeID = @Sc1 
					Order By IDs

					If @GBase < @GrpCount
					Begin
						Update 	#tempSchDetails Set Outlet = ''
						Where IDs = @MinID

						Set @LstIDused = @MinID
						
						Set @BCount = @BCount + 1
					End

				End
				Else
				Begin
					If @GBase < @GrpCount
					Begin
						Insert InTo #tempSchDetails (SchemeID, Outlet)
						Select @Sc1, ''
						Select @LstIDused = Max(IDs) From #tempSchDetails
					End
				End
			End



		Truncate Table #ScOutlet
		Set @BCount = 1
		Set @STabCount = 0
		Set @MinID = 0
		Set @Indicator1 = 0

		Select Top 1 @PreGrpID = GrpId From #TotScChannel Where GrpId > @PreGrpID
			Group By GrpId
			Order By GrpId

		Set @GBase = @GBase + 1 
	End

Set @GBase = 1
Set @PreGrpID = 0
Set @MaxChnlC = 0
Set @MaxOutletC = 0
Set @MaxLoylC = 0
Set @MaxChnlColumn = 0
Set @LstIDused = 0
Set @MaxSlabC = 0



--=======================================
--Loyalty name 

	Set @PreGrpID = @ChkGrpID

	While @GBase <= @GrpCount 
	Begin
	
		Select @MaxChnlC = Count(Channel)
		From #TotScChannel
		Where GrpId = @PreGrpID
	--		Group By GrpId

		Select @MaxOutletC = Count(Outlet)
		From #TotScOutlet
		Where GrpId = @PreGrpID
	--		Group By GrpId

		Select @MaxLoylC = Count(Loyalty)
		From #TotScLoyalty
		Where GrpId = @PreGrpID
	--		Group By GrpId


		Select @MaxSlabC = Count(Slabs) 
		From #TotComSlabItemDetl 
		Where GrpID = @PreGrpID

--		Select @MaxSlabItC = Count(Item)
--		From #TotSlabItemDetl 
--		Where GrpID = @PreGrpID 


		If @MaxChnlC > @MaxOutletC 
			Set @MaxChnlColumn = @MaxChnlC
		Else 
			Set @MaxChnlColumn = @MaxOutletC

		If @MaxChnlColumn > @MaxLoylC
			Set @MaxChnlColumn = @MaxChnlColumn
		Else 
			Set @MaxChnlColumn = @MaxLoylC

		If @MaxChnlColumn > @MaxSlabC
			Set @MaxChnlColumn = @MaxChnlColumn
		Else 
			Set @MaxChnlColumn = @MaxSlabC

--		If @MaxChnlColumn > @MaxSlabItC
--			Set @MaxChnlColumn = @MaxChnlColumn
--		Else 
--			Set @MaxChnlColumn = @MaxSlabItC

		Insert InTo #ScLoyalty (SchemeID , GrpID , Loyalty)
		Select  SchemeID , GrpID, IsNull((Select Top 1 Right(SubOutlet_Type_Code, 2) From tbl_merp_olclass 
	Where SubOutlet_Type_Desc = Loyalty), '') + '~' + Loyalty From #TotScLoyalty 
		Where GrpID = @PreGrpID 
		Order By GrpID 


	
--		Select @MaxCount2 = Count(Channel) From 
--		ScChannel 

--select @PreGrpID, @MaxChnlColumn,  @MaxLoylC
--Select * from ScLoyalty



--===============================================================

		Select @STabCount = Count(SchemeID) From #tempSchDetails 
		Where SchemeID = @Sc1 And IDs > @LstIDused
		
		Select @MinID = Min(IDs) From #tempSchDetails
		Where SchemeID = @Sc1 And IDs > @LstIDused

		While @BCount <= @STabCount 
		Begin
			If @BCount <= @MaxLoylC 
			Begin
				Update 	#tempSchDetails Set Loyalty = (Select Loyalty From #ScLoyalty 
				Where [ID] = @BCount) 
				Where IDs = @MinID

				Set @LstIDused = @MinID

				Select Top 1 @MinID = IDs From #tempSchDetails
				Where IDs > @MinID And SchemeID = @Sc1 
				Order By IDs
			End 
			Else If @MaxChnlColumn = @MaxLoylC And @BCount > @MaxLoylC
			Begin
				If @GBase < @GrpCount
				Begin
					Update 	#tempSchDetails Set Loyalty = ''
					Where IDs = @MinID

					Set @LstIDused = @MinID
				End				
				Set @Indicator1 = 1
				
				
				Goto Lbl_3
				
			End
			Else
			Begin
				Goto Lbl_3				
			End

			Set @BCount = @BCount + 1		
		End


		Lbl_3: 

--select @BCount, @STabCount, @LstIDused
				While @BCount <= @STabCount 
				Begin
					Select Top 1 @MinID = IDs From #tempSchDetails
					Where IDs > @LstIDused And SchemeID = @Sc1 
					Order By IDs

					If @MaxChnlColumn  > @MaxLoylC
					Begin
						Update 	#tempSchDetails Set Loyalty = ''
						Where IDs = @MinID

						Set @MaxLoylC = @MaxLoylC + 1
						Set @LstIDused = @MinID
					End
					Else 
					Begin
						GoTo Lbl3Lbl
					End
					
					Set @BCount = @BCount + 1
				End 

		Lbl3Lbl:	
				If IsNull((Select Count(*) From #ScLoyalty	Where [ID] >= @BCount), 0) > 0
				Begin
					Insert InTo #tempSchDetails (SchemeID, Loyalty)
					Select SchemeID, Loyalty From #ScLoyalty
					Where [ID] >= @BCount -- Not In (Select Channel From #tempSchDetails 
						--Where SchemeID = @Sc1)

					Select @LstIDused = Max(IDs) From #tempSchDetails
				End

			While @MaxChnlColumn  > @MaxLoylC
			Begin
				Insert InTo #tempSchDetails (SchemeID, Loyalty)
				Select @Sc1, ''

				Set @MaxOutletC = @MaxLoylC + 1

				Select @LstIDused = Max(IDs) From #tempSchDetails
			End


			If @Indicator1 = 0
			Begin
				If @BCount <= @STabCount
				Begin
					Select Top 1 @MinID = IDs From #tempSchDetails
					Where IDs > @LstIDused And SchemeID = @Sc1 
					Order By IDs

					If @GBase < @GrpCount
					Begin
						Update 	#tempSchDetails Set Loyalty = ''
						Where IDs = @MinID

						Set @LstIDused = @MinID

						Set @BCount = @BCount + 1
					End

				End
				Else
				Begin
					If @GBase < @GrpCount
					Begin
						Insert InTo #tempSchDetails (SchemeID, Loyalty)
						Select @Sc1, ''
						Select @LstIDused = Max(IDs) From #tempSchDetails
					End
				End
				
			End



		Truncate Table #ScLoyalty
		Set @BCount = 1
		Set @STabCount = 0
		Set @MinID = 0
		Set @Indicator1 = 0

		Select Top 1 @PreGrpID = GrpId From #TotScChannel Where GrpId > @PreGrpID
			Group By GrpId
			Order By GrpId

		Set @GBase = @GBase + 1 
	End

Set @GBase = 1
Set @PreGrpID = 0
Set @MaxChnlC = 0
Set @MaxOutletC = 0
Set @MaxLoylC = 0
Set @MaxChnlColumn = 0
Set @LstIDused = 0
Set @MaxSlabC = 0



--=======================================
-- Slab details



--====

	Set @PreGrpID = @ChkGrpID

	While @GBase <= @GrpCount 
	Begin

		Select @MaxChnlC = Count(Channel)
		From #TotScChannel
		Where GrpId = @PreGrpID
	--		Group By GrpId

		Select @MaxOutletC = Count(Outlet)
		From #TotScOutlet
		Where GrpId = @PreGrpID
	--		Group By GrpId

		Select @MaxLoylC = Count(Loyalty)
		From #TotScLoyalty
		Where GrpId = @PreGrpID
	--		Group By GrpId

		Select @MaxSlabC = Count(Slabs) 
		From #TotComSlabItemDetl 
		Where GrpID = @PreGrpID

		If @MaxChnlC > @MaxOutletC 
			Set @MaxChnlColumn = @MaxChnlC
		Else 
			Set @MaxChnlColumn = @MaxOutletC

		If @MaxChnlColumn > @MaxLoylC
			Set @MaxChnlColumn = @MaxChnlColumn
		Else 
			Set @MaxChnlColumn = @MaxLoylC

		If @MaxChnlColumn > @MaxSlabC
			Set @MaxChnlColumn = @MaxChnlColumn
		Else 
			Set @MaxChnlColumn = @MaxSlabC

		Insert InTo #ComSlabItemDetl (SchemeID , GrpID , Slabs, SlabID , Item )
		Select  SchemeID , GrpID , Slabs, SlabID , Item From #TotComSlabItemDetl 
		Where GrpID = @PreGrpID 
		Order By GrpID, SlabID
	
--===============================================================

		Select @STabCount = Count(SchemeID) From #tempSchDetails 
		Where SchemeID = @Sc1 And IDs > @LstIDused
		
		Select @MinID = Min(IDs) From #tempSchDetails
		Where SchemeID = @Sc1 And IDs > @LstIDused

		While @BCount <= @STabCount 
		Begin
			If @BCount <= @MaxSlabC 
			Begin
			
				Set @ChkSlabID = (Select IsNull(SlabID, 0) From #ComSlabItemDetl 
				Where [ID] = @BCount)

				If @ChkSlabID = @PreSlabID
				Begin
					Update 	#tempSchDetails Set Slabs = '', SlabID = (Select IsNull(SlabID, 0) From #ComSlabItemDetl 
						Where [ID] = @BCount), List = (Select Item From #ComSlabItemDetl 
						Where [ID] = @BCount)
					Where IDs = @MinID
				End
				Else
				Begin
					Update 	#tempSchDetails Set Slabs = (Select Slabs From #ComSlabItemDetl 
						Where [ID] = @BCount), SlabID = (Select IsNull(SlabID, 0) From #ComSlabItemDetl 
						Where [ID] = @BCount), List = (Select Item From #ComSlabItemDetl 
						Where [ID] = @BCount)
					Where IDs = @MinID
				End

				Set @PreSlabID = @ChkSlabID

				Set @LstIDused = @MinID

				Select Top 1 @MinID = IDs From #tempSchDetails
				Where IDs > @MinID And SchemeID = @Sc1 
				Order By IDs
			End 
			Else If @MaxChnlColumn = @MaxSlabC And @BCount > @MaxSlabC
			Begin
				If @GBase < @GrpCount
				Begin
					Update 	#tempSchDetails Set Slabs = '', SlabID = 0, List = ''
					Where IDs = @MinID

					Set @LstIDused = @MinID
				End
				Set @Indicator1 = 1
				
				
				Goto Lbl_4
				
			End
			Else
			Begin
				Goto Lbl_4				
			End

			Set @BCount = @BCount + 1		
		End

		Lbl_4: 
				While @BCount <= @STabCount 
				Begin
					Select Top 1 @MinID = IDs From #tempSchDetails
					Where IDs > @LstIDused And SchemeID = @Sc1 
					Order By IDs

					If @MaxChnlColumn  > @MaxSlabC
					Begin
						Update 	#tempSchDetails Set Slabs = '', SlabID = 0, List = ''
						Where IDs = @MinID

						Set @MaxSlabC = @MaxSlabC + 1

						Set @LstIDused = @MinID
					End
					Else 
					Begin
						GoTo Lbl4Lbl
					End
					
					Set @BCount = @BCount + 1
				End 

		Lbl4Lbl:
				While IsNull((Select Count(*) From #ComSlabItemDetl Where [ID] >= @BCount), 0) > 0
				Begin
			
					Set @ChkSlabID = (Select IsNull(SlabID, 0) From #ComSlabItemDetl 
					Where [ID] = @BCount)

					If @ChkSlabID = @PreSlabID
					Begin
						Insert InTo #tempSchDetails (SchemeID, Slabs, SlabID, List)
						Select SchemeID, '', SlabID, Item From #ComSlabItemDetl
						Where [ID] = @BCount
					End
					Else
					Begin
					
						Insert InTo #tempSchDetails (SchemeID, Slabs, SlabID, List)
						Select SchemeID, Slabs, SlabID, Item From #ComSlabItemDetl
						Where [ID] = @BCount 
					End

					Set @PreSlabID = @ChkSlabID

					Select @LstIDused = Max(IDs) From #tempSchDetails
					Set @BCount = @BCount + 1
				End

			While @MaxChnlColumn  > @MaxSlabC
			Begin
				Insert InTo #tempSchDetails (SchemeID, Slabs, SlabID)
				Select @Sc1, '', 0

				Set @MaxSlabC = @MaxSlabC + 1

				Select @LstIDused = Max(IDs) From #tempSchDetails
			End

			If @Indicator1 = 0
			Begin

				If @BCount <= @STabCount
				Begin
					Select Top 1 @MinID = IDs From #tempSchDetails
					Where IDs > @LstIDused And SchemeID = @Sc1 
					Order By IDs
					
					If @GBase < @GrpCount
					Begin
						Update 	#tempSchDetails Set Slabs = '', SlabID = 0, List = ''
						Where IDs = @MinID

						Set @LstIDused = @MinID

						Set @BCount = @BCount + 1
					End

				End
				Else
				Begin
					If @GBase < @GrpCount
					Begin
						Insert InTo #tempSchDetails (SchemeID, Slabs, SlabID, List )
						Select @Sc1, '', 0, ''
						Select @LstIDused = Max(IDs) From #tempSchDetails
					End
				End

			End

				

		Truncate Table #ComSlabItemDetl
		Set @BCount = 1
		Set @STabCount = 0
		Set @MinID = 0
		Set @Indicator1 = 0
		Set @ChkSlabID = 0
		Set @PreSlabID = 0

		Select Top 1 @PreGrpID = GrpId From #TotScChannel Where GrpId > @PreGrpID
			Group By GrpId
			Order By GrpId

		Set @GBase = @GBase + 1 
	End

Set @GBase = 1
Set @PreGrpID = 0
Set @MaxChnlC = 0
Set @MaxOutletC = 0
Set @MaxLoylC = 0
Set @MaxChnlColumn = 0
Set @LstIDused = 0
Set @MaxSlabC = 0

--========================================

Truncate Table #TotScChannel
Truncate Table #TotScLoyalty
Truncate Table #TotScOutlet
Truncate Table #TotSlabDetl
Truncate Table #TotSlabItemDetl
Truncate Table #TotComSlabItemDetl

Set @ChkGrpID = 0
Set @GrpCount = 0

--=======================================
	Fetch Next From ScDtls InTo @Sc1
End
Close ScDtls
DeAllocate ScDtls


--Select * from #tempSchDetails
--Order By SchemeID, IDs, CSSchID

--Select * From #TotSlabItemDetl
Select "RowCount" = Count(*) from #tempSchDetails
--Order By SchemeID, IDs, CSSchID

Select SchemeID, GrpID, "Activity Code" = Activity_Code ,
	"Type" = ScType , 
	"Activity Type" = Activity_Type , 
	"Status" = Status , 
	"Period" = Period , 
	"Description" = Description , 
	"Applicable On" = Applicable_On , 
	"RFA Frequency" = RFA_Frequency , 
	"Category" = Category , 
	"Sub Category" = Sub_Category , 
	"MarketSKU/SKU" = Case IsNull(MarketSKU, '') When '' Then '' Else IsNull(MarketSKU, '') + '~' End + 
					  IsNull(SKU, '') ,
	"Channel" = Case IsNull(Channel,'') When '' Then '' Else IsNull(Channel,'') + '~' End + 
				Case IsNull(Outlet, '') When '' Then '' Else IsNull(Outlet, '') + '~' End + 
				IsNull(Loyalty, '') ,
	"Slabs" = Slabs , 
	"List of FreeSKUs" = List 
From #tempSchDetails
Order By SchemeID, IDs, CSSchID

Drop Table #tempSchDetails
Drop Table #RFAFrequencys
Drop Table #ScCategory
Drop Table #SubCategory
Drop Table #MarketSKU
Drop Table #SystemSKU
Drop Table #ScChannel
Drop Table #ScOutlet
Drop Table #ScLoyalty
Drop Table #SlabDetl
Drop Table #SlabItemDetl
Drop Table #ComSlabItemDetl
Drop Table #TotScChannel
Drop Table #TotScLoyalty
Drop Table #TotScOutlet
Drop Table #TotSlabDetl
Drop Table #TotSlabItemDetl
Drop Table #TotComSlabItemDetl
