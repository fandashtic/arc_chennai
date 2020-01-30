Create Procedure [dbo].[mERP_spr_RFAReport_Points](
@FromDate Datetime, @ToDate Datetime, @RFAStatus nvarchar(1000), @ActCode nVarchar(255), @SchemeName nVarchar(255), @PRODUCT_HIERARCHY nVarchar(255))
AS    

Set Dateformat dmy

Declare @Schtype nVarchar(255)
Set @Schtype = 'Point Scheme'

Set @FromDate = dbo.StripTimeFromDate(@FromDate)
Set @ToDate = dbo.StripTimeFromDate(@ToDate)


If @SchType = 'Point Scheme'
Begin
	If @RFAStatus = 'Yes'
		Set @RFAStatus = 1
	Else
		Set @RFAStatus = 0

	Declare @RFADocID int
	Declare @InvPrefix nVarchar(10)
	Declare @ClaimsPrefix nVarchar(10)
	Declare @ActivityCode nVarchar(255)
	Declare @CSSchemeID Int
	Declare @SchemeType nVarchar(255)
	Declare @ActivityType nVarchar(255)
	Declare @ActiveFrom DateTime
	Declare @ActiveTo DateTime
	Declare @PayoutFrom DateTime
	Declare @PayoutTo DateTime
	Declare @ApplicableOn nVarchar(255)
	Declare @ItemGroup Int
	Declare @ExpiryDate DateTime
	Declare @Serial Int
	Declare @RFAApplicable as int
	Declare @FlagWord Int
	Declare @Amount Decimal(18, 6)
	Declare @CompaniesToUploadCode nVarchar(255)
	Declare @WDCode nVarchar(255)
	Declare @WDDest nVarchar(255)
	Declare @InvoiceID Int
	Declare @SchemeDetail nVarchar(1000)
	Declare @SchemeAmt Decimal(18, 6)
	Declare @SKUCode nVarchar(255)
	Declare @Divison nVarchar(255)
	Declare @DivID Int
	Declare @SubCategory nVarchar(255)
	Declare @SubCatID Int
	Declare @MarketSKU nVarchar(255)
	Declare @MarketSKUID Int
	Declare @UOMID Int
	Declare @UOM nVarchar(255)
	Declare @SaleQty Decimal(18,6)
	Declare @FreeQty Decimal(18,6)
	Declare @FreeValue Decimal(18,6)
	Declare @PTR Decimal(18,6)
	Declare @SlabID Int
	Declare @PromotedQty Decimal(18,6)
	Declare @PromotedValue Decimal(18,6)
	Declare @ClaimID Int
	Declare @FreeSKUSerial Int
	Declare @DocType Int
	Declare @DocID Int
	Declare @TaxCode Decimal(18,6)
	Declare @StkPrefix  nVarchar(10)
	Declare @CrNotePrefix  nVarchar(10)
	Declare @Damage Int
	Declare @CustomerID nVarchar(255)
	Declare @RCSID nVarchar(255)
	Declare @SRNo Int
	Declare @PrevSKUCode nVarchar(255)
	Declare @SaleValue Decimal(18,6)
	Declare @FreeFlag Int
	Declare @DocumentID Int
	Declare @UOM1 Decimal(18,6)
	Declare @UOM2 Decimal(18,6)
	Declare @InvoiceType Int
	Declare @UOM1Qty Decimal(18,6)
	Declare @UOM2Qty Decimal(18,6)
	Declare @RebateQty Decimal(18,6)
	Declare @RebateValue Decimal(18,6)
	Declare @Qty Decimal(18,6)
	Declare @Value Decimal(18,6)
	Declare @SchemeGroup Int
	Declare @SchemeOutlet nVarchar(255)
	Declare @RedeemPoints Decimal(18,6)
	Declare @RedeemAmount Decimal(18,6)
	Declare @AllotedPoints Decimal(18,6)
	Declare @AllotedAmount Decimal(18,6)
	Declare @InvoicePoints Decimal(18,6)
	Declare @InvoiceAmount Decimal(18,6)
	Declare @AllotedInvPoints Decimal(18,6)
	Declare @AllotedInvAmount Decimal(18,6)
	Declare @SchemeDesc nVarchar(255)
	Declare @CreditRef nVarchar(50)
	Declare @AdjRef nVarchar(255)
	Declare @BillRef nVarchar(255)
	Declare @SR Int
	Declare @Schemeid as int
	Declare @Payoutid int
	Declare @InvRebateValue Decimal(18,6)
	Declare @SRRebateValue Decimal(18,6)
	Declare @RedeemDate datetime
	Declare @InvoiceRef nVarchar(255)
	Declare @RowCount as Int
	Declare @Counter as Int
	Declare @Delimeter nVarchar(1)
	Declare @OutletCode nVarchar(255)
	Declare @SubmittedStatus int
	
	
	Declare @GRNTOTAL nVarchar(50)    
	Set @GRNTOTAL = dbo.LookupDictionaryItem(N'Grand Total:', Default)  

	Set @Delimeter = Char(15) 
	Create Table #tmpSchemeType(SchemeType nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	Create Table #ActCode(ActivityCode nvarchar(4000)COLLATE SQL_Latin1_General_CP1_CI_AS)
	Create Table #tmpScheme([RowID] Int Identity(1,1),Schemeid int,PayoutID Int)
	Create Table #tmpSchemeFinal([RowID] Int Identity(1,1),Schemeid int,CsSchemeid int,ActivityCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

--	Set Dateformat dmy

	If @ActCode = '%'
		Insert Into #ActCode
		Select ActivityCode from tbl_mERP_SchemeAbstract Where Schemetype = 4 and Active = 1 And RFAApplicable = @RFAStatus
	Else
		Insert Into #ActCode
		Select ActivityCode from tbl_mERP_SchemeAbstract Where Schemetype = 4 and Active = 1 And RFAApplicable = @RFAStatus
		and ActivityCode In (Select * from Dbo.sp_SplitIn2Rows(@ActCode,@Delimeter))


	If @PRODUCT_HIERARCHY = '%'
		Set @PRODUCT_HIERARCHY = N'Company'
	If @PRODUCT_HIERARCHY = 'Division'
		Set @PRODUCT_HIERARCHY = N'Division'
	If @PRODUCT_HIERARCHY = 'Sub-Category' or @PRODUCT_HIERARCHY = 'Sub Category'
		Set @PRODUCT_HIERARCHY = N'Sub_Category'
	If @PRODUCT_HIERARCHY = 'MarketSKU' or @PRODUCT_HIERARCHY = 'Market-SKU' or  @PRODUCT_HIERARCHY = 'Market SKU'
		Set @PRODUCT_HIERARCHY = N'Market_SKU' 
	If @PRODUCT_HIERARCHY = 'System_SKU' or @PRODUCT_HIERARCHY = 'System-SKU' or @PRODUCT_HIERARCHY = 'SystemSKU'
		set @PRODUCT_HIERARCHY = 'System SKU'  
		
	Create Table #RFAInfo(SR Int Identity , InvoiceID Int, BillRef nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, OutletCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
	RCSID nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, ActiveInRCS nVarchar(100) collate SQL_Latin1_General_CP1_CI_AS, LineType nVarchar(50) collate SQL_Latin1_General_CP1_CI_AS, 
	Division nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, SubCategory nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, MarketSKU nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, 
	SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,UOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, SaleQty Decimal(18, 6), SaleValue Decimal(18, 6),
	PromotedQty Decimal(18, 6), PromotedValue Decimal(18, 6), FreeBaseUOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
	RebateQty Decimal(18, 6), RebateValue Decimal(18, 6), PriceExclTax Decimal(18, 6),
	TaxPercentage Decimal(18,6), TaxAmount Decimal(18, 6), PriceInclTax Decimal(18, 6),
	SchemeDetail nVarchar(1000) collate SQL_Latin1_General_CP1_CI_AS, Serial Int, Flagword Int, Amount Decimal(18, 6),
	SchemeID Int, SlabID Int, PTR Decimal(18,6), TaxCode Decimal(18,6), BudgetedValue Decimal(18,6),
	FreeSKUSerial Int,SalePrice Decimal(18,6),  UOM1Conv Decimal(18,6), UOM2Conv Decimal(18,6),
	InvoiceType Int, SchemeOutlet Int, SchemeSKU Int Default(0), SchemeGroup Int, TotalPoints Decimal(18,6),
	PointsValue Decimal(18,6), ReferenceNumber nVarchar(50) collate SQL_Latin1_General_CP1_CI_AS
	, RFASubmissionDate Datetime, PayoutID int, RFADocID int,TaxOnQty int)

	--Create Table #tmpSchemeoutput(Schemeid1 int,Schemeid int,CsSchemeid int,ActivityCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Description	nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,ActiveFrom Datetime, ActiveTo Datetime,SchemeType nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, RFAFrom DateTime, RFATo DateTime, 
	--ApplicableOn nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,SalesQty Decimal(18,6),SaleValue Decimal(18,6),PromotedQty Decimal(18,6),PromotedValue Decimal(18,6),RebateQty Decimal(18,6),RebateValue Decimal(18,6),RFAapplicable nvarchar(100) collate SQL_Latin1_General_CP1_CI_AS, RFAStatus nvarchar(1000) collate SQL_Latin1_General_CP1_CI_AS, RFASubmissionDate DateTime)

	Create Table #tmpSchemeoutput(Schemeid1 int,Schemeid int,CsSchemeid int,
	 ActivityCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Description	nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	 ApplicablePeriod	nVarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS,
	 RFAPeriod nVarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS,
	 ActiveFrom Datetime, ActiveTo Datetime,SchemeType nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, RFAFrom DateTime, RFATo DateTime, 
	 ApplicableOn nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	 SalesQty Decimal(18,6),SaleValue Decimal(18,6),PromotedQty Decimal(18,6),PromotedValue Decimal(18,6),RebateQty Decimal(18,6),RebateValue Decimal(18,6),RFAapplicable nvarchar(100) collate SQL_Latin1_General_CP1_CI_AS, RFAStatus nvarchar(1000) collate SQL_Latin1_General_CP1_CI_AS, SubmissionDate DateTime
	 , RFADocID int, PayoutID int, RFAID int )


	If @RFAStatus = 1 
	Begin
		If @Schemename = '%' 
			Insert Into #tmpScheme(SchemeID, PayoutID)
			Select Distinct SA.SchemeID, SPP.ID From tbl_mERP_SchemeAbstract SA,tbl_mERP_SchemePayoutPeriod SPP
				Where SA.SchemeType In(4)
				And ActivityCode In (Select * From #ActCode)
				And SA.SchemeID = SPP.SchemeID
				And SPP.PayoutPeriodTo Between @FromDate And @ToDate
				And SA.Active = 1 And SPP.Active = 1
				And SA.RFAApplicable = 1
		Else
			Insert Into #tmpScheme(SchemeID, PayoutID)
			Select Distinct SA.Schemeid, SPP.ID  From tbl_mERP_SchemeAbstract SA,tbl_mERP_SchemePayoutPeriod SPP
				Where SchemeType In(4) and Description In (Select * From Dbo.sp_SplitIn2Rows(@SchemeName,@Delimeter))
				And SA.SchemeID = SPP.SchemeID
				And ActivityCode In (Select * From #ActCode)
				And SPP.PayoutPeriodTo Between @FromDate And @ToDate
				And SA.Active = 1 And SPP.Active = 1
				And SA.RFAApplicable = 1
	End	
	Else
	Begin	
		If @Schemename = '%' 
			Insert Into #tmpScheme(SchemeID, PayoutID)
			Select Distinct SchemeID,0 From tbl_mERP_SchemeAbstract 
			Where SchemeType In(4)
			And ActivityCode In (Select * From #ActCode)
			And Active = 1
			And RFAApplicable = 0
		Else
			Insert Into #tmpScheme(SchemeID, PayoutID)
			Select Distinct Schemeid,0 From tbl_mERP_SchemeAbstract
			Where SchemeType In(4) and Description In (Select * From dbo.sp_SplitIn2Rows(@SchemeName,@Delimeter))
			And ActivityCode In (Select * From #ActCode)
			And Active = 1
			And RFAApplicable = 0
	End


	Set @RowCount = (Select max([RowID]) from #tmpScheme)
	Set @counter = 1 

	While @Counter <= @RowCount
	Begin

		Truncate table #RFAInfo	
		Select @SchemeID = Schemeid, @PayoutID = PayoutID from #tmpScheme Where [RowID] = @Counter

		If IsNUll(@RFAStatus,0) = 1 
		Begin /*Points Scheme - Start*/

			Select @SchemeType = ST.SchemeType,
				@ActivityCode = SA.ActivityCode,
				@CSSchemeID = SA.CS_RecSchID,
				@ActivityType = SA.Description,
				@ActiveFrom = SA.ActiveFrom,
				@ActiveTo = SA.ActiveTo,
				@PayoutFrom = SPP.PayoutPeriodFrom,
				@PayoutTo = SPP.PayoutPeriodTo,
				@ExpiryDate = SA.ExpiryDate,
				@ApplicableOn = Case When SA.ApplicableOn =1 And SA.ItemGroup = 1 Then 'ITEM'
								When SA.ApplicableOn =1 And SA.ItemGroup = 2 Then 'SPL_CAT'
								When SA.ApplicableOn = 2 Then 'INVOICE'
								End,
				@ItemGroup = Itemgroup,
				--@Payoutid = SPP.ID,
				@RFAApplicable = SA.RFAApplicable
				From tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemeType ST, tbl_mERP_SchemePayoutPeriod SPP
				Where SA.SchemeID = @SchemeID
				And IsNull(SA.RFAApplicable, 0) = 1
				And SA.SchemeID = SPP.SchemeID
				And SA.SchemeType = ST.ID
				And ST.SchemeType in ('Points')
				And SPP.Active = 1
				And SPP.ID = @PayoutID
--				and dbo.stripTimeFromdate(SPP.PayoutPeriodTo) Between dbo.stripTimeFromdate(@FromDate) And dbo.stripTimeFromdate(@ToDate)
				And SPP.PayoutPeriodTo Between @FromDate And @ToDate


			Select @RedeemDate = dbo.StripTimeFromDate(Max(CreationDate)) From tbl_mERP_CSRedemption 
			Where PayoutID = @PayoutID
			And IsNull(RFAStatus,0) = 1

			Set @RedeemDate =  (Case when IsNull(@RedeemDate,'') <> '' then @RedeemDate else  '01/01/2099' end)


			If (Select Count(*) From tbl_mERP_RFAAbstract Where DocumentID = @SchemeID And PayOutFrom = @PayoutFrom And PayOutTo = @PayoutTo and IsNull(Status,0) <> 5) >= 1 
			Begin -- Submitted Status
				Insert into #tmpSchemeOutput(SchemeID,ActivityCode, Description, ApplicablePeriod, RFAPeriod, SalesQty, SaleValue, 
				PromotedQty, PromotedValue, RebateQty, RebateValue, SubmissionDate, RFAFrom, RFATo, RFADocid, PayoutID)
				Select DocumentID, ActivityCode, Description, 
				"Applicable Period" = Cast(Convert(Char(13), ActiveFrom, 103) As nVarchar) + N' - ' + Cast(Convert(Char(13), ActiveTo, 103) As nVarchar),
				"RFA Period" = Cast(Convert(Char(13), PayoutFrom, 103) As nVarchar) + N' - ' + Cast(Convert(Char(13), PayoutTo, 103) As nVarchar),
				Sum(SaleQty), Sum(SaleValue), Sum(PromotedQty), Sum(PromotedValue), 
				Sum(RebateQty), Sum(RebateValue), SubmissionDate, @PayoutFrom, @PayoutTo, RFADocID, @PayoutID
				From tbl_merp_RFAAbstract Where DocumentID  = @SchemeID and PayoutFrom = @PayoutFrom
				and PayoutTo = @PayoutTo and IsNull(Status,0) <> 5
				Group By DocumentID, ActivityCode, [Description], ActiveFrom, ActiveTo, PayoutFrom, PayoutTo, SubmissionDate, RFADocid
				GoTo NextScheme
			End	-- IsNull(@SubmittedStatus,0) = 1
			Else
			Begin
				If @ApplicableOn = 'ITEM' Or @ApplicableOn = 'SPL_CAT'
				Begin --@ApplicableOn = 'ITEM'
					Insert Into #RFAInfo(InvoiceID, OutletCode, RCSID, LineType, Division, SubCategory, MarketSKU,
					SKUCode, UOM, SaleQty, SaleValue, PromotedQty, PromotedValue, RebateQty, RebateValue, TaxCode,
					UOM1Conv, UOM2Conv, SalePrice, InvoiceType, SchemeOutlet, SchemeGroup, SchemeID, PayoutID,TaxOnQty)
					Select IA.InvoiceID, C.CustomerID, C.RCSOutletID,
					(Case When InvoiceType <> 4 Then 'MAIN'
					    Else
					    Case When IsNull(IA.Status,0) & 32 <> 0 Then 'Sales Return - Damaged'
					    Else 'Sales Return - Saleable'
					    End
					    End)as LineType,
					Null as Division, Null as SubCategory,
					Null as MarketSKU, ID.Product_Code as SKUCode, Null as UOM, Sum(isnull(ID.Quantity,0)) as SaleQty,
					Sum(isnull(ID.Amount,0)) as SaleValue, 0 as PromotedQty, 0 as PromotedValue, 0 as RebateQty, 0 as RebateValue,
					Max(TaxCode) as Tax, 0 as UOM1Conv, 0 as UOM2Conv, ID.SalePrice as SalePrice, IA.InvoiceType,
					Null as SchemeOutlet, Null as SchemeGroup, 
					@SchemeID as SchemeID, @PayoutID as PayoutID,isnull(ID.TaxOnQty,0)
					From InvoiceAbstract IA, InvoiceDetail ID, Customer C
					Where  
					(Case IA.InvoiceType When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract 
							Where DocumentID = IA.DocumentID And InvoiceType = 1 
							And Isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)--(Select dbo.mERP_fn_GetInvoiceDate(IA.InvoiceID, 1))
							Else dbo.StripTimeFromDate(IA.InvoiceDate)
							End) Between @ActiveFrom And @ActiveTo
						And 
							(Case IA.InvoiceType
							When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID = IA.DocumentID
							And InvoiceType = 1 
							And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID) --(Select dbo.mERP_fn_GetInvoiceDate(IA.InvoiceID, 1))
							Else dbo.StripTimeFromDate(IA.InvoiceDate)
							End) Between @PayoutFrom And @PayoutTo
					And IA.InvoiceType In (1,3,4)
					And IA.Status & 128 = 0
					And IA.InvoiceID = ID.InvoiceID
					And IsNull(ID.Flagword, 0) = 0
					And IA.CustomerID = C.CustomerID
					And dbo.StripTimeFromDate(IA.CreationTime) <= @RedeemDate
					Group By IA.InvoiceID, IA.DocumentID, C.CustomerID, C.RCSOutletID, ID.Product_Code, IA.InvoiceType, ID.SalePrice, IA.ReferenceNumber, IA.Status,ID.TaxOnQty
					Order By IA.InvoiceID

					If (Select Count(*) From #RFAInfo) <= 0 
					Begin
						GoTo NextScheme
					End

					Declare SchemeOutletCur Cursor For
						Select Distinct OutletCode From #RFAInfo 
					Open SchemeOutletCur
					Fetch Next From SchemeOutletCur Into @CustomerID
					While (@@Fetch_Status = 0)			
					Begin
						Select @SchemeOutlet = QPS, @SchemeGroup = GroupID From dbo.mERP_fn_CheckSchemeOutlet(@SchemeID, @CustomerID)
						Update #RFAInfo Set SchemeOutlet = @SchemeOutlet, SchemeGroup = @SchemeGroup 
							Where OutletCode = @CustomerID 

						Update #RFAInfo Set ActiveInRCS = IsNull(TMDValue,N'')
							From Cust_TMD_Master CTM, Cust_TMD_Details CTD	
							Where CTM.TMDID = CTD.TMDID
							And CTD.CustomerID = @CustomerID
							And OutletCode = @CustomerID 
						Fetch Next From SchemeOutletCur Into @CustomerID
					End
					Close SchemeOutletCur
					Deallocate SchemeOutletCur


					/*Delete non scheme Outlet*/
					Delete From #RFAInfo Where IsNull(SchemeOutlet, 0) = 2


					/* Update  SchemeSKU  = 1 For Items which comes in any of the Product 
					Scope of the scheme */
					Update #RFAInfo Set SchemeSKU = 1 
					--Where SKUCode In(Select Product_Code From dbo.mERP_fn_Get_CSProductScope(@SchemeID))
					Where SKUCode In(Select Product_Code From dbo.mERP_fn_Get_CSSku(@SchemeID))

					Delete From #RFAInfo Where IsNull(SchemeSKU, 0) = 0


					/* Update Division , Market sku ,And Sub Category */
					Update RFA Set Division = IC2.Category_Name, SubCategory = IC1.Category_Name, MarketSKU = IC.Category_Name, UOM = U.Description,
					UOM1conv = I.UOM1_Conversion,UOM2conv = I.UOM2_Conversion
					From #RFAInfo RFA,Items I , ItemCategories IC, ItemCategories IC1,ItemCategories IC2,UOM U
					Where RFA.SKUCode = I.Product_Code And
					I.CategoryID = IC.CategoryID And
					IC.ParentID = IC1.CategoryID And
					IC1.ParentID = IC2.CategoryID And
					I.UOM = U.UOM

					/*Delete non scheme SKU*/
					Delete From #RFAInfo Where IsNull(SchemeSKU, 0) = 0

					/*Non QPS - Start*/
					 If @ItemGroup = 1 /*Other than SplCategory scheme(Non QPS) - Start*/
					 Begin
						Declare SKUCur Cursor For
						Select InvoiceID, InvoiceType, SchemeGroup, SKUCode, Sum(SaleQty), 
						-- Sum(SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))),  
						Sum(SaleValue),
						UOM1Conv, UOM2Conv From #RFAInfo
						Where IsNull(SchemeOutlet, 0) = 0
						Group By InvoiceID, InvoiceType, SchemeGroup, SKUCode, UOM1Conv, UOM2Conv, InvoiceType
						Open SKUCur
						Fetch Next From SKUCur Into @InvoiceID, @InvoiceType, @SchemeGroup, @SKUCode, @Qty, @Value, @UOM1, @UOM2
						While (@@Fetch_Status = 0)
						Begin
							Set @UOM1Qty = 0
							Set @UOM2Qty = 0
							Set @SaleValue = 0
							Set @UOM1Qty = IsNull((@Qty/@UOM1), 0)
							Set @UOM2Qty = IsNull((@Qty/@UOM2), 0)
							Set @SaleValue = @Value
							Set @SaleQty = @Qty

							Select @PromotedQty = PromotedQty, @PromotedValue = PromotedValue,
							@RebateQty = RebateQty, @RebateValue = RebateValue, @UOMID = UOM
							From dbo.mERP_fn_GetPointsSchValue(@SchemeID, @SchemeGroup, @Qty, @SaleValue,@UOM1Qty, @UOM2Qty,0)

							Update #RFAInfo Set PromotedQty = Case InvoiceType
							When 4 Then (-1) * (Case @UOMID When 2 Then @PromotedQty * UOM1Conv
							When 3 Then @PromotedQty * UOM2Conv
							Else @PromotedQty End)
							Else (Case @UOMID When 2 Then @PromotedQty * UOM1Conv
							When 3 Then @PromotedQty * UOM2Conv
							Else @PromotedQty End)
							End,
							PromotedValue = Case InvoiceType
							When 4 
							Then (-1) * @PromotedValue
							Else @PromotedValue End,
							-- CC Added as on 23.07.2010
							RebateQty = Case InvoiceType
							When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty
							Else (@RebateQty / @SaleQty) * SaleQty
							End,
							RebateValue = Case InvoiceType
							When 4 Then (-1) * (@RebateValue / @SaleQty) * SaleQty
							Else (@RebateValue / @SaleQty) * SaleQty
							End,
							-- CC Added as on 23.07.2010
							TotalPoints = @RebateQty,
							PointsValue = @RebateValue
							Where InvoiceID = @InvoiceID And SKUCode = @SKUCode 
							Fetch Next From SKUCur Into @InvoiceID, @InvoiceType, @SchemeGroup, @SKUCode, @Qty, @Value, @UOM1, @UOM2
						End
						Close SKUCur
						Deallocate SKUCur

					End /*Other than SplCategory scheme - End*/
					Else If @ItemGroup = 2 /*Spl.Category schemes - Start*/
					Begin
						Declare InvoiceCur Cursor For
						Select Distinct InvoiceID, InvoiceType, SchemeGroup
						From #RFAInfo Where IsNull(SchemeOutlet, 0) = 0
						Open InvoiceCur
						Fetch From InvoiceCur Into @InvoiceID, @InvoiceType, @SchemeGroup
						While (@@Fetch_Status = 0)
						Begin
							Set @UOM1Qty = 0
							Set @UOM2Qty = 0
							Set @SaleValue = 0
							Set @SaleQty = 0

							/*To get cumulative value of items per invoice to apply scheme*/
							Declare SKUCur Cursor For
							Select SKUCode, Sum(SaleQty), 
							Sum(SaleValue),
							--Sum(SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))), 
							Max(UOM1Conv), Max(UOM2Conv)
							From #RFAInfo
							Where InvoiceID = @InvoiceID
							And InvoiceType = @InvoiceType
							And SchemeGroup = @SchemeGroup
							Group By SKUCode
							Open SKUCur
							Fetch Next From SKUCur Into @SKUCode, @Qty, @Value, @UOM1, @UOM2
							While @@Fetch_Status = 0
							Begin
								Set @UOM1Qty = @UOM1Qty + IsNull((@Qty/@UOM1), 0)
								Set @UOM2Qty = @UOM2Qty + IsNull((@Qty/@UOM2), 0)
								Set @SaleQty = @SaleQty + @Qty
								Set @SaleValue = @SaleValue + @Value

							Fetch Next From SKUCur Into @SKUCode, @Qty, @Value, @UOM1, @UOM2
							End
							Close SKUCur
							Deallocate SKUCur

							Select @PromotedQty = PromotedQty, @PromotedValue = PromotedValue,
							@RebateQty = RebateQty, @RebateValue = RebateValue, @UOMID = UOM
							From dbo.mERP_fn_GetPointsSchValue(@SchemeID, @SchemeGroup, @SaleQty, @SaleValue,@UOM1Qty, @UOM2Qty,1)

							/*Update SKU wise PromotedQty Or PromotedValue*/
							Update #RFAInfo Set PromotedQty = Case InvoiceType
							When 4 Then (-1)
							 * ((Case @UOMID When 2 Then @PromotedQty * UOM1Conv
							When 3 Then @PromotedQty * UOM2Conv
							Else @PromotedQty End)/@SaleQty) * SaleQty
							Else ((Case @UOMID When 2 Then @PromotedQty * UOM1Conv
							When 3 Then @PromotedQty * UOM2Conv
							Else @PromotedQty End)/@SaleQty) * SaleQty
							End,
							
		--					PromotedValue = Case InvoiceType
		--					When 4 Then (-1) * (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
		--					Else (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))) End,
							PromotedValue = Case InvoiceType
								When 4 Then (-1) * ((SaleValue / @SaleValue) * @PromotedValue)
									Else ((SaleValue / @SaleValue) * @PromotedValue)
								End,
							-- CC Added as on 23.07.2010
							RebateQty = Case InvoiceType
							When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty
							Else (@RebateQty / @SaleQty) * SaleQty
							End,
							RebateValue = Case InvoiceType
								When 4 Then (-1) * (@RebateValue / @SaleQty) * SaleQty
								Else (@RebateValue / @SaleQty) * SaleQty
								End,
							-- CC Added as on 23.07.2010
							TotalPoints = (@RebateQty / @SaleQty) * SaleQty,
							PointsValue = (@RebateValue / @SaleQty) * SaleQty
							Where InvoiceID = @InvoiceID 
							Fetch Next From InvoiceCur Into @InvoiceID, @InvoiceType, @SchemeGroup
						End
						Close InvoiceCur
						Deallocate InvoiceCur
					End 
					/*Spl.Category schemes - End*/
					/*Non QPS - End*/

					/*QPS - Start*/
					If @ItemGroup = 1 /*Other than SplCategory scheme(QPS) - Start*/
					Begin
						Declare OutletCur Cursor for
						Select Distinct OutletCode from #RFAInfo where IsNull(SchemeOutlet, 0) = 1
						Open OutletCur
						Fetch Next from OutletCur Into @OutletCode
						While @@Fetch_Status = 0
						Begin
							Declare SKUCur Cursor For
							Select Distinct SKUCode
							From #RFAInfo 
							Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1

							Open SKUCur Fetch Next From SKUCur Into @SKUCode
							While @@Fetch_Status = 0
							Begin
								Set @UOM1Qty = 0
								Set @UOM2Qty = 0
								Set @SaleValue = 0
								Set @SaleQty = 0

								Declare QPSSKUCur Cursor For
								Select InvoiceID, SchemeGroup, SKUCode, Sum((Case when Invoicetype = 4 then -1 Else 1 End) *SaleQty), 
								Sum((Case when Invoicetype = 4 then -1 Else 1 End) *SaleValue),
								--Sum(SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))), 
								UOM1Conv,UOM2Conv
								From #RFAInfo
								Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1
								And SKUCode = @SKUCode
								Group By InvoiceID, SchemeGroup,SKUCode, UOM1Conv, UOM2Conv

								Open QPSSKUCur
								Fetch Next From QPSSKUCur Into @InvoiceID, @SchemeGroup, @SKUCode, @Qty, @Value, @UOM1, @UOM2
								While (@@Fetch_Status = 0)
								Begin
									Set @UOM1Qty = @UOM1Qty + IsNull((@Qty/@UOM1), 0)
									Set @UOM2Qty = @UOM2Qty + IsNull((@Qty/@UOM2), 0)
									Set @SaleQty = @SaleQty + @Qty
									Set @SaleValue = @SaleValue + @Value
									Fetch Next From QPSSKUCur Into @InvoiceID, @SchemeGroup, @SKUCode, @Qty, @Value, @UOM1, @UOM2
								End
								Close QPSSKUCur
								Deallocate QPSSKUCur

								Select @PromotedQty = PromotedQty, @PromotedValue = PromotedValue,
								@RebateQty = RebateQty, @RebateValue = RebateValue, @UOMID = UOM
								From dbo.mERP_fn_GetPointsSchValue(@SchemeID, @SchemeGroup, @SaleQty, @SaleValue,@UOM1Qty, @UOM2Qty,0)

								Update #RFAInfo Set PromotedQty = Case InvoiceType
								When 4 Then (-1) * ((Case @UOMID When 2 Then @PromotedQty * UOM1Conv
								When 3 Then @PromotedQty * UOM2Conv
								Else @PromotedQty End)/@SaleQty) * SaleQty
								Else ((Case @UOMID When 2 Then @PromotedQty * UOM1Conv
								When 3 Then @PromotedQty * UOM2Conv
								Else @PromotedQty End)/@SaleQty) * SaleQty
								End,

								PromotedValue = Case InvoiceType
									When 4 Then (-1) * ((SaleValue / @SaleValue) * @PromotedValue)
									Else ((SaleValue / @SaleValue) * @PromotedValue)
									End,

		--						PromotedValue = Case InvoiceType
		--						When 4 Then (-1) * (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
		--						Else (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
		--						End,

								-- CC Added as on 23.07.2010
								RebateQty = Case InvoiceType
								When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty
								Else (@RebateQty / @SaleQty) * SaleQty
								End,
								RebateValue = Case InvoiceType
								When 4 Then (-1) * (@RebateValue / @SaleQty) * SaleQty
								Else (@RebateValue / @SaleQty) * SaleQty
								End,
								-- CC Added as on 23.07.2010
								TotalPoints = ((@RebateQty / @SaleQty) * SaleQty),
								PointsValue = ((@RebateValue / @SaleQty) * SaleQty)
								Where SKUCode = @SKUCode
								and OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1
					
								Fetch Next From SKUCur Into @SKUCode
							End
							Close SKUCur
							Deallocate SKUCur
							Fetch Next From OutletCur Into @OutletCode
						End					
						Close OutletCur
						Deallocate OutletCur

					End /*Other than SplCategory scheme(QPS) - End*/

					Else If  @ItemGroup = 2
					Begin /*SplCategory scheme(QPS) - Start*/

						Declare GroupCur Cursor For
						Select Distinct SchemeGroup, OutletCode From #RFAInfo
						Where IsNull(SchemeOutlet, 0) = 1
						Open GroupCur
						
						Fetch Next From GroupCur Into @SchemeGroup,@OutletCode

						While (@@Fetch_Status = 0)
						Begin
							Select @SaleQty = Sum((case when invoicetype =4 then -SaleQty else SaleQty end)), 
				--			@SaleValue = Sum((case when InvoiceType=4 then 
				--			(SaleQty * (SalePrice + (SalePrice * (TaxCode/100))) * -1) else 
				--			(SaleQty * (SalePrice + (SalePrice * (TaxCode/100))) ) end)), 
							@SaleValue = Sum((Case When Invoicetype = 4 then (SaleValue *-1)
												Else (SaleValue) end)),  
							@UOM1Qty = Sum((case when InvoiceType = 4 then (SaleQty*-1) else (SaleQty) end)/UOM1Conv), 
							@UOM2Qty = Sum((Case When InvoiceType=4 then (SaleQty *-1) else (SaleQty) end)/UOM2Conv)
							From #RFAInfo
							-- Where IsNull(SchemeOutlet, 0) = 1
							Where OutletCode=@OutletCode and IsNull(SchemeOutlet, 0) = 1
							And IsNull(SchemeGroup, 0) = @SchemeGroup

							Select @PromotedQty = PromotedQty, @PromotedValue = PromotedValue, @UOMID = UOM,
							@RebateQty = RebateQty, @RebateValue = RebateValue
							From dbo.mERP_fn_GetPointsSchValue(@SchemeID, @SchemeGroup, @SaleQty, @SaleValue,@UOM1Qty, @UOM2Qty,1)


							If @UOMID = 1 --Or @UOMID = 4
								Update #RFAInfo Set PromotedQty = Case InvoiceType
								When 4 Then (-1) * (@PromotedQty / @SaleQty) * SaleQty
								Else (@PromotedQty / @SaleQty) * SaleQty
								End,
								PromotedValue = Case isnull(TaxOnQty,0) When 0 Then 
									Case InvoiceType
									When 4 Then (-1) * (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
									Else (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
									End 
								else
									Case InvoiceType
									When 4 Then (-1) * (@PromotedValue / @SaleValue) *  (SaleQty * ((SaleQty*isnull(TaxCode,0))))
									Else (@PromotedValue / @SaleValue) *  (SaleQty * ((SaleQty*isnull(TaxCode,0))))
									End 									
								end,
								RebateQty = Case InvoiceType
								When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty
								Else (@RebateQty / @SaleQty) * SaleQty
								End,
								RebateValue = Case InvoiceType
								When 4 Then (-1) * (@RebateValue / @SaleQty) * SaleQty
								Else (@RebateValue / @SaleQty) * SaleQty
								End,
								TotalPoints = (@RebateQty / @SaleQty) * SaleQty,
								PointsValue = (@RebateValue / @SaleQty) * SaleQty
								Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1
							Else If @UOMID = 4
								Update #RFAInfo Set PromotedQty = Case InvoiceType 
								When 4 Then (-1) * (@PromotedQty / @SaleQty) * SaleQty 
								Else (@PromotedQty / @SaleQty) * SaleQty 
								End,
				--				PromotedValue = Case InvoiceType
				--				When 4 then (-1) * (@PromotedValue / @SaleValue) * (@SaleValue)	
				--				Else (@PromotedValue / @SaleValue) * (@SaleValue)	
				--				End,
								PromotedValue = Case InvoiceType
								When 4 Then (-1) * ((SaleValue / @SaleValue) * @PromotedValue)
								Else ((SaleValue / @SaleValue) * @PromotedValue)
								End,
				--				Case InvoiceType
				--				When 4 Then (-1) * (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
				--				Else (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))) 
				--				End,
								RebateQty = Case InvoiceType 
								When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty 
								Else (@RebateQty / @SaleQty) * SaleQty 
								End,
								RebateValue = Case InvoiceType 
								When 4 Then (-1) * (@RebateValue / @SaleQty) * SaleQty 
								Else (@RebateValue / @SaleQty) * SaleQty 
								End,
								TotalPoints = (@RebateQty / @SaleQty) * SaleQty,
								PointsValue = (@RebateValue / @SaleQty) * SaleQty
								Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1
				
							Else If @UOMID = 2
								Update #RFAInfo Set PromotedQty = Case InvoiceType
								When 4 Then (-1) * ((@PromotedQty / UOM1Conv) * SaleQty)
								Else ((@PromotedQty / @UOM1Qty) * SaleQty)
								End,
								PromotedValue = 
								Case isnull(TaxOnQty,0) When 0 Then  
									Case InvoiceType
									When 4 Then (-
									1) * (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
									Else (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
									End
								Else
									Case InvoiceType
									When 4 Then (-
									1) * (@PromotedValue / @SaleValue) *  (SaleQty * ((SaleQty*isnull(TaxCode,0))))
									Else (@PromotedValue / @SaleValue) *  (SaleQty * ((SaleQty*isnull(TaxCode,0))))
									End
								End,
								RebateQty = Case InvoiceType
								When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty
								Else (@RebateQty / @SaleQty) * SaleQty
								End,
								RebateValue = Case InvoiceType
								When 4 Then (-1) * (@RebateValue / @SaleQty) * SaleQty
								Else (@RebateValue / @SaleQty) * SaleQty
								End,
								TotalPoints = (@RebateQty / @SaleQty) * SaleQty,
								PointsValue = (@RebateValue / @SaleQty) * SaleQty
								Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1
				
							Else If @UOMID = 3
								Update #RFAInfo
								 Set PromotedQty = Case InvoiceType
								When 4 Then (-1) * ((@PromotedQty / UOM2Conv) * SaleQty)
								Else ((@PromotedQty / @UOM2Qty) * SaleQty)
								End,
								PromotedValue = 
								Case isnull(TaxOnQty,0) When 0 Then 
									Case InvoiceType
									When 4 Then (-1) * (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
									Else (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
									End
								Else
									Case InvoiceType
									When 4 Then (-1) * (@PromotedValue / @SaleValue) * (SaleQty * ((SaleQty*isnull(TaxCode,0))))
									Else (@PromotedValue / @SaleValue) * (SaleQty * ((SaleQty*isnull(TaxCode,0))))
									End
								End,
								RebateQty = Case InvoiceType
								When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty
								Else (@RebateQty / @SaleQty) * SaleQty
								End,
								RebateValue = Case InvoiceType
								When 4 Then (-1) * (@RebateValue / @SaleQty) * SaleQty
								Else (@RebateValue / @SaleQty) * SaleQty
								End,
								TotalPoints = (@RebateQty / @SaleQty) * SaleQty,
								PointsValue = (@RebateValue / @SaleQty) * SaleQty
								Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1

							Fetch Next From GroupCur Into @SchemeGroup,@OutletCode
						End
						Close GroupCur
						Deallocate GroupCur
					End /*SplCategory scheme(QPS) - End*/
					/*QPS - Start*/

				End /* @ApplicableOn = 'ITEM' */
				/*Apply Item based schemes - End*/

				/*Apply Invoice based schemes - Start*/
				Else If @ApplicableOn = 'INVOICE'
				Begin
					If Isnull(@RFAStatus,0) = 1
					Begin	
						Insert Into #RFAInfo (InvoiceID, InvoiceType, OutletCode, RCSID, RebateQty, RebateValue, Amount, SchemeID, SchemeOutlet, SchemeGroup, PayoutID)
						Select IA.InvoiceID, IA.InvoiceType,
						C.CustomerID as OutletCode,
						IsNull(C.RCSOutletID, '') as RCSID,
						0 as RebateQty,
						0 as RebateValue,
						IA.NetValue as Amount,
						--0 as SchemeID,
						@SchemeID as SchemeID, 
						Null as SchemeOutlet,
						Null as SchemeGroup,
						@PayoutID as PayoutID
						From InvoiceAbstract IA, Customer C
						Where IA.InvoiceType In (1,3,4)
						And (IA.Status & 128)=0
						And IA.CustomerID = C.CustomerID
						--And dbo.StripTimeFromDate(IA.InvoiceDate) Between @PayoutFrom And @PayoutTo
						And (Case IA.InvoiceType
							When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID =
							IA.DocumentID
							And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)--(Select dbo.mERP_fn_GetInvoiceDate(IA.InvoiceID, 1))
							Else dbo.StripTimeFromDate(IA.InvoiceDate)
							End) Between @ActiveFrom And @ActiveTo
						And (Case IA.InvoiceType
							When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where 
							DocumentID = IA.DocumentID
							And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID) --(Select dbo.mERP_fn_GetInvoiceDate(IA.InvoiceID, 1))
							Else dbo.StripTimeFromDate(IA.InvoiceDate)
							End) Between @PayoutFrom And @PayoutTo
						And dbo.StripTimeFromDate(IA.CreationTime) <= @RedeemDate
					End
					Else
					Begin
						Insert Into #RFAInfo (InvoiceID, InvoiceType, OutletCode, RCSID, RebateQty, RebateValue, Amount, SchemeID, SchemeOutlet, SchemeGroup, PayoutID)
						Select IA.InvoiceID, IA.InvoiceType,
						C.CustomerID as OutletCode,
						IsNull(C.RCSOutletID, '') as RCSID,
						0 as RebateQty,
						0 as RebateValue,
						IA.NetValue as Amount,
						--0 as SchemeID,
						@SchemeID as SchemeID, 
						Null as SchemeOutlet,
						Null as SchemeGroup,
						@PayoutID as PayoutID
						From InvoiceAbstract IA, Customer C
						Where IA.InvoiceType In (1,3,4)
						And (IA.Status & 128)=0
						And IA.CustomerID = C.CustomerID
						--And dbo.StripTimeFromDate(IA.InvoiceDate) Between @PayoutFrom And @PayoutTo
						And (Case IA.InvoiceType
							When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID =
							IA.DocumentID
							And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)--(Select dbo.mERP_fn_GetInvoiceDate(IA.InvoiceID, 1))
--							Else dbo.StripTimeFromDate(IA.InvoiceDate)
							Else IA.InvoiceDate
							End) Between @ActiveFrom And @ActiveTo
					End

					Declare SchemeOutletCur Cursor For
					Select Distinct OutletCode From #RFAInfo 
					Open SchemeOutletCur
					Fetch Next From SchemeOutletCur Into @CustomerID
					While (@@Fetch_Status = 0)
					Begin
						Select @SchemeOutlet = QPS, @SchemeGroup = GroupID From dbo.mERP_fn_CheckSchemeOutlet(@SchemeID, @CustomerID)
						Update #RFAInfo Set SchemeOutlet = @SchemeOutlet, SchemeGroup = @SchemeGroup
						Where OutletCode = @CustomerID 
						Fetch Next From SchemeOutletCur Into @CustomerID
					End
					Close SchemeOutletCur
					Deallocate SchemeOutletCur


					/*Delete non scheme Outlet*/
					Delete From #RFAInfo Where IsNull(SchemeOutlet,0) = 2


					/*Non QPS - Start*/
					Declare SchemeCur Cursor For
					Select InvoiceID, Sum(isnull(Amount,0)), Max(SchemeGroup) From #RFAInfo
					Where IsNull(SchemeOutlet, 0) = 0
					Group By InvoiceID
					Open SchemeCur
					Fetch Next From SchemeCur Into @InvoiceID, @Value, @SchemeGroup
					While (@@Fetch_Status = 0)
					Begin
						Select @PromotedQty = PromotedQty, @PromotedValue = PromotedValue, @RebateQty = RebateQty, @RebateValue = RebateValue
						From dbo.mERP_fn_GetPointsSchValue(@SchemeID, @SchemeGroup, @Qty, @Value,@UOM1Qty, @UOM2Qty,0)

						Update #RFAInfo 
						Set PromotedQty = 
							Case InvoiceType
							When 4 Then (-1) * @PromotedQty
							Else @PromotedQty End,
							PromotedValue = 
							Case InvoiceType
							When 4 Then (-1) * @PromotedValue
							Else @PromotedValue End,
						-- CC Added as on 30.07.2010
							RebateQty = Case InvoiceType
							When 4 Then (-1) * (@RebateQty / @Value) * Amount
							Else (@RebateQty / @Value) * Amount
							End,
							RebateValue = Case InvoiceType
							When 4 Then (-1) * (@RebateValue / @Value) * Amount
							Else (@RebateValue / @Value) * Amount
							End,
						-- CC Added as on 30.07.2010

						TotalPoints = @RebateQty, PointsValue = @RebateValue
						Where InvoiceID = @InvoiceID 
						Fetch Next From SchemeCur Into @InvoiceID, @Value, @SchemeGroup
					End
					Close SchemeCur
					Deallocate SchemeCur
					/*Non QPS - End*/


					/*QPS - Start*/
					Declare GroupCur Cursor For
					Select Distinct OutletCode, SchemeGroup From #RFAInfo
					Where IsNull(SchemeOutlet, 0) = 1
					Open GroupCur
					Fetch Next From GroupCur Into  @OutletCode, @SchemeGroup
					While (@@Fetch_Status = 0)
					Begin
						Set @SaleValue = 0

						Declare SchemeCur Cursor For
						Select InvoiceID, Sum(Case InvoiceType
						When 4 Then (-1) * (Amount)
						Else Amount
						End)
						From #RFAInfo
						Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1
						And SchemeGroup = @SchemeGroup
						Group By InvoiceID

						Open SchemeCur
						Fetch Next From SchemeCur Into @InvoiceID, @Value
						While (@@Fetch_Status = 0)
						Begin
							Set @SaleValue = @SaleValue + @Value

							Fetch Next From SchemeCur Into @InvoiceID, @Value
						End
						Close SchemeCur
						Deallocate SchemeCur

						Select @PromotedValue = PromotedValue, @RebateQty = RebateQty, @RebateValue = RebateValue
						From dbo.mERP_fn_GetPointsSchValue(@SchemeID, @SchemeGroup, 0, @SaleValue, 0, 0, 0)

						Update #RFAInfo Set 
						--PromotedValue =  
						PromotedValue = Case InvoiceType
						When 4 Then (-1) * ((SaleValue / @SaleValue) * @PromotedValue)
						Else ((SaleValue / @SaleValue) * @PromotedValue)
						End,
--						Case InvoiceType
--						When 4 Then (-1)* (@PromotedValue/@SaleValue) * Amount
--						Else (@PromotedValue/@SaleValue) * Amount
--						End,
-- 						CC Added as on 23.07.2010
						RebateQty = Case InvoiceType
						When 4 Then (-1) * (@RebateQty / @SaleValue) * Amount
						Else (@RebateQty / @SaleValue) * Amount
						End,
						RebateValue = Case InvoiceType
						When 4 Then (-1) * (@RebateValue / @SaleValue) * Amount
						Else (@RebateValue / @SaleValue) * Amount
						End,
						-- CC Added as on 23.07.2010	
						TotalPoints = (@RebateQty/@SaleValue) * Amount,
						PointsValue = (@RebateValue/@SaleValue) * Amount
						Where IsNull(SchemeOutlet, 0) = 1 and OutletCode = @OutletCode

						Fetch Next From GroupCur Into @OutletCode, @SchemeGroup

					End
					Close GroupCur
					Deallocate GroupCur
					/*QPS - End*/
				End
				/*Apply Invoice based schemes - End*/


				Set @AllotedInvPoints = 0 
				Set @AllotedInvAmount = 0
				Set @InvoicePoints = 0
				Set @InvoiceAmount = 0




				/*Update rebate value - Start*/
				Declare RebateCur Cursor For
					Select Distinct OutletCode
					From #RFAInfo 
					Open RebateCur
				Fetch Next From RebateCur Into @CustomerID
				While (@@Fetch_Status = 0)
				Begin
					Set @RedeemPoints = 0
					Set @RedeemAmount = 0
					Set @AllotedPoints = 0
					Set @AllotedAmount = 0
					/*Outlet wise Points*/
					Select @RedeemPoints = TotalPoints, @RedeemAmount = RedeemValue,
					@AllotedPoints = RedeemedPoints, @AllotedAmount = AmountSpent
					From tbl_mERP_CSRedemption
					Where SchemeID = @SchemeID
					And PayoutID = @PayoutID
					And OutletCode = @CustomerID
					And RFAStatus In (0,1)

					If @AllotedPoints > 0 And @AllotedAmount > 0 --Do update if amount/points alloted to the customer
					Begin
						Declare InvoiceCur Cursor For
						Select Distinct InvoiceID From #RFAInfo
						Where OutletCode = @CustomerID
						Open InvoiceCur
						Fetch Next From InvoiceCur Into @InvoiceID
						While @@Fetch_Status = 0
						Begin
							/*Invoice wise Points*/
							Select @AllotedInvPoints = Case InvoiceType
							When 4 Then (-1) * (@AllotedPoints/@RedeemPoints) * Sum(IsNull(TotalPoints, 0))
							Else (@AllotedPoints/@RedeemPoints) * Sum(IsNull(TotalPoints, 0))
							End,
							@AllotedInvAmount = Case InvoiceType
							When 4 Then (-1) * (@AllotedAmount/@RedeemAmount) * Sum(IsNull(PointsValue, 0))
							Else (@AllotedAmount/@RedeemAmount) * Sum(IsNull(PointsValue, 0))
							End,
							@InvoicePoints = Sum(isnull(TotalPoints,0)),
							@InvoiceAmount = Sum(isnull(PointsValue,0))
							From #RFAInfo
							Where InvoiceID = @InvoiceID 
							Group By InvoiceType

							If @ApplicableOn = 'ITEM' Or @ApplicableOn = 'SPL_CAT'
							Begin
								Declare SKUCur Cursor For
								Select Distinct SKUCode From #RFAInfo
								Where InvoiceID = @InvoiceID
								Open SKUCur
								Fetch Next From SKUCur Into @SKUCode
								While @@Fetch_Status = 0
								Begin
									Update #RFAInfo Set RebateQty = 
									Case InvoiceType
									When 4 Then (1) * (@AllotedInvPoints/@InvoicePoints) * IsNull(TotalPoints, 0)
									Else 
									(@AllotedInvPoints/@InvoicePoints) * IsNull(TotalPoints, 0)
									End,
									RebateValue = Case InvoiceType
									When 4 Then (1) * (@AllotedInvAmount/@InvoiceAmount) * IsNull(PointsValue, 0)
									Else (@AllotedInvAmount/@InvoiceAmount) * IsNull(PointsValue, 0)
									End
									Where InvoiceID = @InvoiceID
									And SKUCode = @SKUCode
									And @InvoicePoints > 0
									And @InvoiceAmount > 0
									Fetch Next From SKUCur Into @SKUCode
								End
								Close SKUCur
								Deallocate SKUCur
							End
							Else If @ApplicableOn = 'INVOICE'
								Update #RFAInfo Set RebateQty = Case InvoiceType
								When 4 Then (1) * @AllotedInvPoints
								Else @AllotedInvPoints
								End,
								RebateValue = Case InvoiceType
								When 4 Then (1) * @AllotedInvAmount
								Else @AllotedInvAmount
								End
								Where InvoiceID = @InvoiceID
							Fetch Next From InvoiceCur Into @InvoiceID
						End
						Close InvoiceCur
						Deallocate InvoiceCur
					End
					Fetch Next From RebateCur Into @CustomerID
				End
				Close RebateCur
				Deallocate RebateCur


				--	Update #RFAInfo Set PromotedValue = Case IsNull(PromotedQty,0)
				--										When 0 Then PromotedValue
				--										Else IsNull(PromotedQty,0) * IsNull(SalePrice,0)
				--										End	

				/*Update rebate value - End*/
				--RebateQty =  (-1) * RebateQty, RebateValue = (-1) * RebateValue,
				Update #RFAInfo Set  SaleQty = (-1) * SaleQty, SaleValue = (-1) * SaleValue
				Where InvoiceType = 4

				Update RFA Set RFASubmissionDate = dbo.StripTimeFromDate(RFAAbs.SubmissionDate)--Cast(Convert(Char(13), SubmissionDate, 103) As nVarchar)
				From tbl_merp_RFaAbstract RFAAbs Inner Join #RFAInfo RFA On RFAAbs.DocumentID = RFA.SchemeID
				Where DocumentID = @Schemeid 
				And ActivityCode = @ActivityCode
				And PayoutFrom = @PayoutFrom
				And PayoutTo = @PayoutTo
				And isNull(RFAAbs.Status,0) <> 5

				If @ApplicableOn = 'ITEM' Or @ApplicableOn = 'SPL_CAT'
				Begin
					If (Select Count(*) From #RFAInfo) >= 1
					Begin
						/*Select Abstract Data*/
						insert into #tmpSchemeOutput(SchemeID,ActivityCode, Description, ApplicablePeriod, RFAPeriod, SalesQty, SaleValue, 
						-- PromotedQty, PromotedValue, RebateQty, RebateValue, SubmissionDate)
						PromotedQty, PromotedValue, RebateQty, RebateValue, SubmissionDate, RFAFrom, RFATo, PayoutID)
						Select 
						SchemeID, @ActivityCode, @ActivityType, 
						"Applicable Period" = Cast(Convert(Char(13), @ActiveFrom, 103) As nVarchar) + N' - ' + Cast(Convert(Char(13), @ActiveTo, 103) As nVarchar),
						"RFA Period" = Cast(Convert(Char(13), @PayoutFrom, 103) As nVarchar) + N' - ' + Cast(Convert(Char(13), @PayoutTo, 103) As nVarchar),
						--@ApplicableOn, 
						Sum(SaleQty), Sum(SaleValue), Sum(PromotedQty), Sum(PromotedValue), Sum(RebateQty), Sum(RebateValue)
						, Max(RFASubmissionDate), @PayoutFrom, @PayoutTo, PayoutID
						From #RFAInfo
						group by SchemeID, PayoutID
					End
				End --If @ApplicableOn = 'ITEM' Or @ApplicableOn = 'SPL_CAT'
				Else
				Begin -- If @ApplicableOn = 'INVOICE'
					If (Select Count(*) From #RFAInfo) >= 1
					Begin
						/*Abstract data*/
						Insert into #tmpSchemeOutput(SchemeID,ActivityCode, Description, ApplicablePeriod, RFAPeriod, SalesQty, SaleValue, 
						--PromotedQty, PromotedValue, RebateQty, RebateValue, SubmissionDate)
						PromotedQty, PromotedValue, RebateQty, RebateValue, SubmissionDate, RFAFrom, RFATo, PayoutID)
						Select SchemeID,
						@ActivityCode, @ActivityType, 
						"Applicable Period" = Cast(Convert(Char(13), @ActiveFrom, 103) As nVarchar) + N' - ' + Cast(Convert(Char(13), @ActiveTo, 103) As nVarchar),
						"RFA Period" = Cast(Convert(Char(13), @PayoutFrom, 103) As nVarchar) + N' - ' + Cast(Convert(Char(13), @PayoutTo, 103) As nVarchar),
						Sum(SaleQty), Sum(SaleValue), Sum(PromotedQty), Sum(Isnull(PromotedValue,0)), 
						Sum(IsNull(RebateQty,0)), Sum(IsNull(RebateValue,0))
						, Max(RFASubmissionDate), @PayoutFrom, @PayoutTo, PayoutID
						From #RFAInfo
						group by SchemeID, PayoutID
					End --If (Select Count(*) From #RFAInfo) >= 1
				End-- If @ApplicableOn = 'INVOICE'

--End 

			End 

		End  -- If Schtype = 'Points'

		Else --If IsNUll(@RFAStatus,0) = 0
		/* If IsNUll(@RFAStatus,0) = 0*/
		 --Select 'RFA No', @SchemeID
		-- Added for RFANo
		Begin

			Select @SchemeType = ST.SchemeType,
			@ActivityCode = SA.ActivityCode,
			@CSSchemeID = SA.CS_RecSchID,
			@ActivityType = SA.Description,
			@ActiveFrom = SA.ActiveFrom,
			@Payoutid = SPP.ID,
			@ActiveTo = SA.ActiveTo,
			@RFAApplicable = sa.RFAApplicable,
			@PayoutFrom = SPP.PayoutPeriodFrom,
			@PayoutTo = SPP.PayoutPeriodTo,
			@ExpiryDate = SA.ExpiryDate,
			@ApplicableOn = Case When SA.ApplicableOn =1 And SA.ItemGroup = 1 Then 'ITEM'
			When SA.ApplicableOn =1 And SA.ItemGroup = 2 Then 'SPL_CAT'
			When SA.ApplicableOn = 2 Then 'INVOICE'
			End,
			@ItemGroup = Itemgroup
			From tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemeType ST, tbl_mERP_SchemePayoutPeriod SPP
			Where SA.SchemeID = @SchemeID
			And IsNull(SA.RFAApplicable, 0) = 0
			And SA.SchemeID = SPP.SchemeID
			And SA.SchemeType = ST.ID
			and ST.SchemeType in ('Points')

			Select @SubmittedStatus = IsnUll(ClaimRFA,0) from tbl_mERP_SchemePayoutPeriod where SchemeID = @SchemeID
			and ID = @Payoutid and PayoutPeriodFrom = @PayoutFrom and PayoutPeriodTo = @PayoutTo

			Select @RedeemDate = dbo.StripTimeFromDate(IsNull(Max(CreationDate), Convert(varchar, '01-01-2099', 103))) From tbl_mERP_CSRedemption 
			Where PayoutID = @PayoutID
			And IsNull(RFAStatus,0) = 0

			If @SchemeType = 'Points'
			Begin

				If @ApplicableOn = 'ITEM' Or @ApplicableOn = 'SPL_CAT'
				Begin --@ApplicableOn = 'ITEM'

					Insert Into #RFAInfo(InvoiceID, OutletCode, RCSID, LineType, Division, SubCategory, MarketSKU,
					SKUCode, UOM, SaleQty, SaleValue, PromotedQty, PromotedValue, RebateQty, RebateValue, TaxCode,
					UOM1Conv, UOM2Conv, SalePrice, InvoiceType, SchemeOutlet, SchemeGroup, SchemeID, PayoutID)
					Select IA.InvoiceID, C.CustomerID, C.RCSOutletID,
					(Case When InvoiceType <> 4 Then 'MAIN'
					Else
					Case When IsNull(IA.Status,0) & 32 <> 0 Then 'Sales Return - Damaged'
					Else 'Sales Return - Saleable'
					End
					End)as LineType,
					Null as Division, Null as SubCategory,
					Null as MarketSKU, ID.Product_Code as SKUCode, Null as UOM, Sum(isnull(ID.Quantity,0)) as SaleQty,
					Sum(isnull(ID.Amount,0)) as SaleValue, 0 as PromotedQty, 0 as PromotedValue, 0 as RebateQty, 0 as RebateValue,
					Max(TaxCode) as Tax, 0 as UOM1Conv, 0 as UOM2Conv, ID.SalePrice as SalePrice, IA.InvoiceType,
					Null as SchemeOutlet, Null as SchemeGroup, 
					@SchemeID as SchemeID, @PayoutID as PayoutID
					From InvoiceAbstract IA, InvoiceDetail ID, Customer C
					Where  
					(Case IA.InvoiceType When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract 
							Where DocumentID = IA.DocumentID And InvoiceType = 1 
							And Isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)--(Select dbo.mERP_fn_GetInvoiceDate(IA.InvoiceID, 1))
							Else dbo.StripTimeFromDate(IA.InvoiceDate)
							End) Between @ActiveFrom And @ActiveTo
						And 
							(Case IA.InvoiceType
							When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID = IA.DocumentID
							And InvoiceType = 1 
							And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID) --(Select dbo.mERP_fn_GetInvoiceDate(IA.InvoiceID, 1))
							Else dbo.StripTimeFromDate(IA.InvoiceDate)
							End) Between @FromDate And @ToDate

					And IA.InvoiceType In (1,3,4)
					And IA.Status & 128 = 0
					And IA.InvoiceID = ID.InvoiceID
					And IsNull(ID.Flagword, 0) = 0
					And IA.CustomerID = C.CustomerID
--					And dbo.StripTimeFromDate(IA.CreationTime) <= @RedeemDate
					And IA.CreationTime <= @RedeemDate
					Group By IA.InvoiceID, IA.DocumentID, C.CustomerID, C.RCSOutletID, ID.Product_Code, IA.InvoiceType, ID.SalePrice, IA.ReferenceNumber, IA.Status
					Order By IA.InvoiceID


					Declare SchemeOutletCur Cursor For
					Select Distinct OutletCode From #RFAInfo 
					Open SchemeOutletCur
					Fetch Next From SchemeOutletCur Into @CustomerID
					While (@@Fetch_Status = 0)			
					Begin
						Select @SchemeOutlet = QPS, @SchemeGroup = GroupID From dbo.mERP_fn_CheckSchemeOutlet(@SchemeID, @CustomerID)
						Update #RFAInfo Set SchemeOutlet = @SchemeOutlet, SchemeGroup = @SchemeGroup 
							Where OutletCode = @CustomerID 

						Update #RFAInfo Set ActiveInRCS = IsNull(TMDValue,N'')
							From Cust_TMD_Master CTM, Cust_TMD_Details CTD	
							Where CTM.TMDID = CTD.TMDID
							And CTD.CustomerID = @CustomerID
							And OutletCode = @CustomerID 
						Fetch Next From SchemeOutletCur Into @CustomerID
					End
					Close SchemeOutletCur
					Deallocate SchemeOutletCur

					/*Delete non scheme Outlet*/
					Delete From #RFAInfo Where IsNull(SchemeOutlet, 0) = 2
					/* Update  SchemeSKU  = 1 For Items which comes in any of the Product 
					Scope of the scheme */
					Update #RFAInfo Set SchemeSKU = 1 
					--Where SKUCode In(Select Product_Code From dbo.mERP_fn_Get_CSProductScope(@SchemeID))
					Where SKUCode In(Select Product_Code From dbo.mERP_fn_Get_CSSku(@SchemeID))

					Delete From #RFAInfo Where IsNull(SchemeSKU, 0) = 0


					/* Update Division , Market sku ,And Sub Category */
					Update RFA Set Division = IC2.Category_Name, SubCategory = IC1.Category_Name, MarketSKU = IC.Category_Name, UOM = U.Description,
					UOM1conv = I.UOM1_Conversion,UOM2conv = I.UOM2_Conversion
					From #RFAInfo RFA,Items I , ItemCategories IC, ItemCategories IC1,ItemCategories IC2,UOM U
					Where RFA.SKUCode = I.Product_Code And
					I.CategoryID = IC.CategoryID And
					IC.ParentID = IC1.CategoryID And
					IC1.ParentID = IC2.CategoryID And
					I.UOM = U.UOM

					/*Delete non scheme SKU*/
					Delete From #RFAInfo Where IsNull(SchemeSKU, 0) = 0

					/*Non QPS - Start*/
					 If @ItemGroup = 1 /*Other than SplCategory scheme(Non QPS) - Start*/
					 Begin
						Declare SKUCur Cursor For
						Select InvoiceID, InvoiceType, SchemeGroup, SKUCode, Sum(SaleQty), Sum(SaleValue),
						-- Sum(SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))),  
						UOM1Conv, UOM2Conv From #RFAInfo
						Where IsNull(SchemeOutlet, 0) = 0
						Group By InvoiceID, InvoiceType, SchemeGroup, SKUCode, UOM1Conv, UOM2Conv, InvoiceType
						Open SKUCur
						Fetch Next From SKUCur Into @InvoiceID, @InvoiceType, @SchemeGroup, @SKUCode, @Qty, @Value, @UOM1, @UOM2
						While (@@Fetch_Status = 0)
						Begin
							Set @UOM1Qty = 0
							Set @UOM2Qty = 0
							Set @SaleValue = 0
							Set @UOM1Qty = IsNull((@Qty/@UOM1), 0)
							Set @UOM2Qty = IsNull((@Qty/@UOM2), 0)
							Set @SaleValue = @Value
							Set @SaleQty = @Qty

							Select @PromotedQty = PromotedQty, @PromotedValue = PromotedValue,
							@RebateQty = RebateQty, @RebateValue = RebateValue, @UOMID = UOM
							From dbo.mERP_fn_GetPointsSchValue(@SchemeID, @SchemeGroup, @Qty, @SaleValue,@UOM1Qty, @UOM2Qty,0)

							Update #RFAInfo Set PromotedQty = Case InvoiceType
							    When 4 Then (-1) * (Case @UOMID When 2 Then @PromotedQty * UOM1Conv
							    When 3 Then @PromotedQty * UOM2Conv
							    Else @PromotedQty End)
							    Else (Case @UOMID When 2 Then @PromotedQty * UOM1Conv
							    When 3 Then @PromotedQty * UOM2Conv
							    Else @PromotedQty End)
							    End,
							PromotedValue = Case InvoiceType
							    When 4 
							    Then (-1) * @PromotedValue
							    Else @PromotedValue End,
							    -- CC Added as on 23.07.2010
							    RebateQty = Case InvoiceType
							    When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty
							    Else (@RebateQty / @SaleQty) * SaleQty
							    End,
							RebateValue = Case InvoiceType
							    When 4 Then (-1) * (@RebateValue / @SaleQty) * SaleQty
							    Else (@RebateValue / @SaleQty) * SaleQty
							    End,
							-- CC Added as on 23.07.2010
							TotalPoints = @RebateQty,
							PointsValue = @RebateValue
							Where InvoiceID = @InvoiceID And SKUCode = @SKUCode 

							Fetch Next From SKUCur Into @InvoiceID, @InvoiceType, @SchemeGroup, @SKUCode, @Qty, @Value, @UOM1, @UOM2
						End
						Close SKUCur
						Deallocate SKUCur

					End /*Other than SplCategory scheme - End*/
					Else If @ItemGroup = 2 /*Spl.Category schemes - Start*/
					Begin
						Declare InvoiceCur Cursor For
						Select Distinct InvoiceID, InvoiceType, SchemeGroup
						From #RFAInfo Where IsNull(SchemeOutlet, 0) = 0
						Open InvoiceCur
						Fetch From InvoiceCur Into @InvoiceID, @InvoiceType, @SchemeGroup
						While (@@Fetch_Status = 0)
						Begin
							Set @UOM1Qty = 0
							Set @UOM2Qty = 0
							Set @SaleValue = 0
							Set @SaleQty = 0
							/*To get cumulative value of items per invoice to apply scheme*/
							Declare SKUCur Cursor For
							Select SKUCode, Sum(SaleQty), 
							Sum(SaleValue), 
							--Sum(SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))), 
							Max(UOM1Conv), Max(UOM2Conv)
							From #RFAInfo
							Where InvoiceID = @InvoiceID
							And InvoiceType = @InvoiceType
							And SchemeGroup = @SchemeGroup
							Group By SKUCode
							Open SKUCur
							Fetch Next From SKUCur Into @SKUCode, @Qty, @Value, @UOM1, @UOM2
							While @@Fetch_Status = 0
							Begin
								Set @UOM1Qty = @UOM1Qty + IsNull((@Qty/@UOM1), 0)
								Set @UOM2Qty = @UOM2Qty + IsNull((@Qty/@UOM2), 0)
								Set @SaleQty = @SaleQty + @Qty
								Set @SaleValue = @SaleValue + @Value
								Fetch Next From SKUCur Into @SKUCode, @Qty, @Value, @UOM1, @UOM2
							End
							Close SKUCur
							Deallocate SKUCur

							Select @PromotedQty = PromotedQty, @PromotedValue = PromotedValue,
							@RebateQty = RebateQty, @RebateValue = RebateValue, @UOMID = UOM
							From dbo.mERP_fn_GetPointsSchValue(@SchemeID, @SchemeGroup, @SaleQty, @SaleValue,@UOM1Qty, @UOM2Qty,1)

							/*Update SKU wise PromotedQty Or PromotedValue*/
							Update #RFAInfo Set PromotedQty = Case InvoiceType
							    When 4 Then (-1)
							     * ((Case @UOMID When 2 Then @PromotedQty * UOM1Conv
							    When 3 Then @PromotedQty * UOM2Conv
							    Else @PromotedQty End)/@SaleQty) * SaleQty
							    Else ((Case @UOMID When 2 Then @PromotedQty * UOM1Conv
							    When 3 Then @PromotedQty * UOM2Conv
							    Else @PromotedQty End)/@SaleQty)
							     * SaleQty
							    End,
		--					PromotedValue = Case InvoiceType
		--					When 4 Then (-1) * (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
		--					Else (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))) End,
							PromotedValue = Case InvoiceType
								When 4 Then (-1) * ((SaleValue / @SaleValue) * @PromotedValue)
								Else ((SaleValue / @SaleValue) * @PromotedValue)
								End,
							-- CC Added as on 23.07.2010
							RebateQty = Case InvoiceType
							    When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty
							    Else (@RebateQty / @SaleQty) * SaleQty
							    End,
							RebateValue = Case InvoiceType
							    When 4 Then (-1) * (@RebateValue / @SaleQty) * SaleQty
							    Else (@RebateValue / @SaleQty) * SaleQty
							    End,
							-- CC Added as on 23.07.2010

							TotalPoints = (@RebateQty / @SaleQty) * SaleQty,
							PointsValue = (@RebateValue / @SaleQty) * SaleQty
							Where InvoiceID = @InvoiceID 
							
							Fetch Next From InvoiceCur Into @InvoiceID, @InvoiceType, @SchemeGroup
						End
						Close InvoiceCur
						Deallocate InvoiceCur


					End 
					/*Spl.Category schemes - End*/
					/*Non QPS - End*/
					/*QPS - Start*/
					If @ItemGroup = 1 /*Other than SplCategory scheme(QPS) - Start*/
					Begin
						Declare OutletCur Cursor for
						Select Distinct OutletCode from #RFAInfo where IsNull(SchemeOutlet, 0) = 1
						Open OutletCur
						Fetch Next from OutletCur Into @OutletCode
						While @@Fetch_Status = 0
						Begin
							Declare SKUCur Cursor For
							Select Distinct SKUCode
							From #RFAInfo 
							--Where IsNull(SchemeOutlet, 0) = 1
							Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1
							Open SKUCur Fetch Next From SKUCur Into @SKUCode
							While @@Fetch_Status = 0
							Begin
								Set @UOM1Qty = 0
								Set @UOM2Qty = 0
								Set @SaleValue = 0
								Set @SaleQty = 0

								Declare QPSSKUCur Cursor For
								Select InvoiceID, SchemeGroup, SKUCode, Sum((Case when Invoicetype = 4 then -1 Else 1 End) * SaleQty), 
								Sum((Case when Invoicetype = 4 then -1 Else 1 End) * SaleValue),
								--Sum(SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))), 
								UOM1Conv,UOM2Conv
								From #RFAInfo
								--Where IsNull(SchemeOutlet, 0) = 1
								Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1
								And SKUCode = @SKUCode
								Group By InvoiceID, SchemeGroup,SKUCode, UOM1Conv, UOM2Conv

								Open QPSSKUCur
								Fetch Next From QPSSKUCur Into @InvoiceID, @SchemeGroup, @SKUCode, @Qty, @Value, @UOM1, @UOM2
								While (@@Fetch_Status = 0)
								Begin
									Set @UOM1Qty = @UOM1Qty + IsNull((@Qty/@UOM1), 0)
									Set @UOM2Qty = @UOM2Qty + IsNull((@Qty/@UOM2), 0)
									Set @SaleQty = @SaleQty + @Qty
									Set @SaleValue = @SaleValue + @Value
									Fetch Next From QPSSKUCur Into @InvoiceID, @SchemeGroup, @SKUCode, @Qty, @Value, @UOM1, @UOM2
								End
								Close QPSSKUCur
								Deallocate QPSSKUCur

								Select @PromotedQty = PromotedQty, @PromotedValue = PromotedValue,
								@RebateQty = RebateQty, @RebateValue = RebateValue, @UOMID = UOM
								From dbo.mERP_fn_GetPointsSchValue(@SchemeID, @SchemeGroup, @SaleQty, @SaleValue,@UOM1Qty, @UOM2Qty,0)

								Update #RFAInfo Set PromotedQty = Case InvoiceType
								When 4 Then (-1) * ((Case @UOMID When 2 Then @PromotedQty * UOM1Conv
								When 3 Then @PromotedQty * UOM2Conv
								Else @PromotedQty End)/@SaleQty) * SaleQty
								Else ((Case @UOMID When 2 Then @PromotedQty * UOM1Conv
								When 3 Then @PromotedQty * UOM2Conv
								Else @PromotedQty End)/@SaleQty) * SaleQty
								End,
		--						PromotedValue = Case InvoiceType
		--						When 4 Then (-1) * (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
		--						Else (@PromotedValue /
		--						@SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
		--						End,
								PromotedValue = Case InvoiceType
								When 4 Then (-1) * ((SaleValue / @SaleValue) * @PromotedValue)
								Else ((SaleValue / @SaleValue) * @PromotedValue)
								End,
								-- CC Added as on 23.07.2010
								RebateQty = Case InvoiceType
								When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty
								Else (@RebateQty / @SaleQty) * SaleQty
								End,
								RebateValue = Case InvoiceType
								When 4 Then (-1) * (@RebateValue / @SaleQty) * SaleQty
								Else (@RebateValue / @SaleQty) * SaleQty
								End,
								-- CC Added as on 23.07.2010
								TotalPoints = ((@RebateQty / @SaleQty) * SaleQty),
								PointsValue = ((@RebateValue / @SaleQty) * SaleQty)
								Where SKUCode = @SKUCode and 
								OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1
								Fetch Next From SKUCur Into @SKUCode
							End
							Close SKUCur
							Deallocate SKUCur
							Fetch Next From OutletCur Into @OutletCode
						End					
						Close OutletCur
						Deallocate OutletCur
					End /*Other than SplCategory scheme(QPS) - End*/
					Else If  @ItemGroup = 2
					Begin /*SplCategory scheme(QPS) - Start*/
						Declare GroupCur Cursor For
						Select Distinct SchemeGroup, OutletCode From #RFAInfo
						Where IsNull(SchemeOutlet, 0) = 1
						Open GroupCur
						
						Fetch Next From GroupCur Into @SchemeGroup,@OutletCode

						While (@@Fetch_Status = 0)
						Begin
							Select @SaleQty = Sum((case when invoicetype =4 then -SaleQty else SaleQty end)), 
				--			@SaleValue = Sum((case when InvoiceType=4 then 
				--			(SaleQty * (SalePrice + (SalePrice * (TaxCode/100))) * -1) else (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))) ) end)), 
							@SaleValue = Sum((Case When Invoicetype = 4 then (SaleValue *-1)
									Else (SaleValue) end)),  

							@UOM1Qty = Sum((case when InvoiceType = 4 then (SaleQty*-1) else (SaleQty) end)/UOM1Conv), 
							@UOM2Qty = Sum((Case When InvoiceType=4 then (SaleQty *-1) else (SaleQty) end)/UOM2Conv)
							From #RFAInfo
							-- Where IsNull(SchemeOutlet, 0) = 1
							Where OutletCode=@OutletCode and IsNull(SchemeOutlet, 0) = 1
							And IsNull(SchemeGroup, 0) = @SchemeGroup

							Select @PromotedQty = PromotedQty, @PromotedValue = PromotedValue, @UOMID = UOM,
							@RebateQty = RebateQty, @RebateValue = RebateValue
							From dbo.mERP_fn_GetPointsSchValue(@SchemeID, @SchemeGroup, @SaleQty, @SaleValue,@UOM1Qty, @UOM2Qty,1)

							If @UOMID = 1 --Or @UOMID = 4
								Update #RFAInfo Set PromotedQty = Case InvoiceType
								When 4 Then (-1) * (@PromotedQty / @SaleQty) * SaleQty
								Else (@PromotedQty / @SaleQty) * SaleQty
								End,
								PromotedValue = 
								Case isnull(TaxOnQty,0) When 0 Then 
									Case InvoiceType
									When 4 Then (-1) * (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
									Else (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
									End
								Else
									Case InvoiceType
									When 4 Then (-1) * (@PromotedValue / @SaleValue) * (SaleQty * ((SaleQty*isnull(TaxCode,0))))
									Else (@PromotedValue / @SaleValue) * (SaleQty * ((SaleQty*isnull(TaxCode,0))))
									End
								End,
								RebateQty = Case InvoiceType
								When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty
								Else (@RebateQty / @SaleQty) * SaleQty
								End,
								RebateValue = Case InvoiceType
								When 4 Then (-1) * (@RebateValue / @SaleQty) * SaleQty
								Else (@RebateValue / @SaleQty) * SaleQty
								End,
								TotalPoints = (@RebateQty / @SaleQty) * SaleQty,
								PointsValue = (@RebateValue / @SaleQty) * SaleQty
								--Where IsNull(SchemeOutlet, 0) = 1
								Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1

							Else If @UOMID = 4
								Update #RFAInfo Set PromotedQty = Case InvoiceType 
								When 4 Then (-1) * (@PromotedQty / @SaleQty) * SaleQty 
								Else (@PromotedQty / @SaleQty) * SaleQty 
								End,
								PromotedValue = 
				--				Case InvoiceType
				--				When 4 Then (-1) * (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
				--				Else (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
				--				End,
								Case InvoiceType
								When 4 Then (-1) * ((SaleValue / @SaleValue) * @PromotedValue)
								Else ((SaleValue / @SaleValue) * @PromotedValue)
								End,
								RebateQty = Case InvoiceType 
								When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty 
								Else (@RebateQty / @SaleQty) * SaleQty 
								End,
								RebateValue = Case InvoiceType 
								When 4 Then (-1) * (@RebateValue / @SaleQty) * SaleQty 
								Else (@RebateValue / @SaleQty) * SaleQty 
								End,
								TotalPoints = (@RebateQty / @SaleQty) * SaleQty,
								PointsValue = (@RebateValue / @SaleQty) * SaleQty
								Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1

				
							Else If @UOMID = 2
								Update #RFAInfo Set PromotedQty = Case InvoiceType
								When 4 Then (-1) * ((@PromotedQty / UOM1Conv) * SaleQty)
								Else ((@PromotedQty / @UOM1Qty) * SaleQty)
								End,
								PromotedValue = 
								Case isnull(TaxOnQty,0) When 0 Then
									Case InvoiceType
									When 4 Then (-
									1) * (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
									Else (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
									End
								Else
									Case InvoiceType
									When 4 Then (-
									1) * (@PromotedValue / @SaleValue) * (SaleQty * ((SaleQty*isnull(TaxCode,0))))
									Else (@PromotedValue / @SaleValue) * (SaleQty * ((SaleQty*isnull(TaxCode,0))))
									End
								End,
								RebateQty = Case InvoiceType
								When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty
								Else (@RebateQty / @SaleQty) * SaleQty
								End,
								RebateValue = Case InvoiceType
								When 4 Then (-1) * (@RebateValue / @SaleQty) * SaleQty
								Else (@RebateValue / @SaleQty) * SaleQty
								End,
								TotalPoints = (@RebateQty / @SaleQty) * SaleQty,
								PointsValue = (@RebateValue / @SaleQty) * SaleQty
								--Where IsNull(SchemeOutlet, 0) = 1
								Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1
				
							Else If @UOMID = 3
								Update #RFAInfo
								 Set PromotedQty = Case InvoiceType
								When 4 Then (-1) * ((@PromotedQty / UOM2Conv) * SaleQty)
								Else ((@PromotedQty / @UOM2Qty) * SaleQty)
								End,
								PromotedValue = 
								Case isnull(TaxOnQty,0) When 0 Then
									Case InvoiceType
									When 4 Then (-1) * (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
									Else (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
									End
								Else
									Case InvoiceType
									When 4 Then (-1) * (@PromotedValue / @SaleValue) * (SaleQty * ((SaleQty*isnull(TaxCode,0))))
									Else (@PromotedValue / @SaleValue) * (SaleQty * ((SaleQty*isnull(TaxCode,0))))
									End
								End,
								RebateQty = Case InvoiceType
								When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty
								Else (@RebateQty / @SaleQty) * SaleQty
								End,
								RebateValue = Case InvoiceType
								When 4 Then (-1) * (@RebateValue / @SaleQty) * SaleQty
								Else (@RebateValue / @SaleQty) * SaleQty
								End,
								TotalPoints = (@RebateQty / @SaleQty) * SaleQty,
								PointsValue = (@RebateValue / @SaleQty) * SaleQty
								--Where IsNull(SchemeOutlet, 0) = 1
								Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1

							Fetch Next From GroupCur Into @SchemeGroup,@OutletCode
						End
						Close GroupCur
						Deallocate GroupCur
					End /*SplCategory scheme(QPS) - End*/
					/*QPS - Start*/

				End /* @ApplicableOn = 'ITEM' */
				/*Apply Item based schemes - End*/

				/*Apply Invoice based schemes - Start*/
				Else If @ApplicableOn = 'INVOICE'
				Begin
					Insert Into #RFAInfo (InvoiceID, InvoiceType, OutletCode, RCSID, RebateQty, RebateValue, Amount, SchemeID, SchemeOutlet, SchemeGroup, PayoutID)
					Select IA.InvoiceID, IA.InvoiceType,
					C.CustomerID as OutletCode,
					IsNull(C.RCSOutletID, '') as RCSID,
					0 as RebateQty,
					0 as RebateValue,
					IA.NetValue as Amount,
					--0 as SchemeID,
					@SchemeID as SchemeID, 
					Null as SchemeOutlet,
					Null as SchemeGroup,
					@PayoutID as PayoutID
					From InvoiceAbstract IA, Customer C
					Where IA.InvoiceType In (1,3,4)
					And (IA.Status & 128)=0
					And IA.CustomerID = C.CustomerID
					And IA.CreationTime <= @RedeemDate
--					And dbo.StripTimeFromDate(IA.CreationTime) <= @RedeemDate
					--And dbo.StripTimeFromDate(IA.InvoiceDate) Between @PayoutFrom And @PayoutTo
					And (Case IA.InvoiceType
						When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID =
						IA.DocumentID
						And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)--(Select dbo.mERP_fn_GetInvoiceDate(IA.InvoiceID, 1))
						Else dbo.StripTimeFromDate(IA.InvoiceDate)
						End) Between @ActiveFrom And @ActiveTo
					And (Case IA.InvoiceType
						When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where 
						DocumentID = IA.DocumentID
						And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID) --(Select dbo.mERP_fn_GetInvoiceDate(IA.InvoiceID, 1))
						Else dbo.StripTimeFromDate(IA.InvoiceDate)
						End) Between @PayoutFrom And @PayoutTo

					Declare SchemeOutletCur Cursor For
					Select Distinct OutletCode From #RFAInfo 
					Open SchemeOutletCur
					Fetch Next From SchemeOutletCur Into @CustomerID
					While (@@Fetch_Status = 0)
					Begin
						Select @SchemeOutlet = QPS, @SchemeGroup = GroupID From dbo.mERP_fn_CheckSchemeOutlet(@SchemeID, @CustomerID)
						Update #RFAInfo Set SchemeOutlet = @SchemeOutlet, SchemeGroup = @SchemeGroup
						Where OutletCode = @CustomerID 
						Fetch Next From SchemeOutletCur Into @CustomerID
					End
					Close SchemeOutletCur
					Deallocate SchemeOutletCur


					/*Delete non scheme Outlet*/
					Delete From #RFAInfo Where IsNull(SchemeOutlet,0) = 2

					/*Non QPS - Start*/
					Declare SchemeCur Cursor For
					Select InvoiceID, Sum(isnull(Amount,0)), Max(SchemeGroup) From #RFAInfo
					Where IsNull(SchemeOutlet, 0) = 0
					Group By InvoiceID
					Open SchemeCur
					Fetch Next From SchemeCur Into @InvoiceID, @Value, @SchemeGroup
					While (@@Fetch_Status = 0)
					Begin

						Select @PromotedQty = PromotedQty, @PromotedValue = PromotedValue, @RebateQty = RebateQty, @RebateValue = RebateValue
						From dbo.mERP_fn_GetPointsSchValue(@SchemeID, @SchemeGroup, @Qty, @Value,@UOM1Qty, @UOM2Qty,0)

						Update #RFAInfo 
						Set PromotedQty = 
							Case InvoiceType
							When 4 Then (-1) * @PromotedQty
							Else @PromotedQty End,
						PromotedValue = 
							Case InvoiceType
							When 4 Then (-1) * @PromotedValue
							Else @PromotedValue End,
		--				-- CC Added as on 23.07.2010
						RebateQty = Case InvoiceType
						When 4 Then (-1) * (@RebateQty / @Value) * Amount
						Else (@RebateQty / @Value) * Amount
						End,
						RebateValue = Case InvoiceType
						When 4 Then (-1) * (@RebateValue / @Value) * Amount
						Else (@RebateValue / @Value) * Amount
						End,
		--				-- CC Added as on 23.07.2010
						TotalPoints = @RebateQty, PointsValue = @RebateValue
						Where InvoiceID = @InvoiceID 
						Fetch Next From SchemeCur Into @InvoiceID, @Value, @SchemeGroup
					End
					Close SchemeCur
					Deallocate SchemeCur
					/*Non QPS - End*/


					/*QPS - Start*/
					Declare GroupCur Cursor For
					Select Distinct OutletCode, SchemeGroup From #RFAInfo
					Where IsNull(SchemeOutlet, 0) = 1
					Open GroupCur
					Fetch Next From GroupCur Into @OutletCode, @SchemeGroup
					While (@@Fetch_Status = 0)
					Begin
						Set @SaleValue = 0

						Declare SchemeCur Cursor For 
						Select InvoiceID, Sum(Case InvoiceType  When 4 Then (-1) * (Amount)
						Else Amount
						End)
						From #RFAInfo
						Where OutletCode = @OutletCode and  IsNull(SchemeOutlet, 0) = 1
						And SchemeGroup = @SchemeGroup
						Group By InvoiceID

						Open SchemeCur
						Fetch Next From SchemeCur Into @InvoiceID, @Value
						While (@@Fetch_Status = 0)
						Begin
							Set @SaleValue = @SaleValue + @Value
							Fetch Next From SchemeCur Into @InvoiceID, @Value
						End
						Close SchemeCur
						Deallocate SchemeCur

						Select @PromotedValue = PromotedValue, @RebateQty = RebateQty, @RebateValue = RebateValue
						From dbo.mERP_fn_GetPointsSchValue(@SchemeID, @SchemeGroup, 0, @SaleValue,0, 0,0)

						Update #RFAInfo Set PromotedValue =
						Case InvoiceType
							When 4 Then (-1) * ((SaleValue / @SaleValue) * @PromotedValue)
							Else ((SaleValue / @SaleValue) * @PromotedValue)
							End,
		--				 =  Case InvoiceType
		--				When 4 Then (-1)* (@PromotedValue/@SaleValue) * Amount
		--				Else (@PromotedValue/@SaleValue) * Amount
		--				End,
						TotalPoints = (@RebateQty/@SaleValue) * Amount,
						PointsValue = (@RebateValue/@SaleValue) * Amount
						Where IsNull(SchemeOutlet, 0) = 1 and OutletCode = @OutletCode
						Fetch Next From GroupCur Into @OutletCode, @SchemeGroup
					End
					Close GroupCur
					Deallocate GroupCur
					/*QPS - End*/
				End
				/*Apply Invoice based schemes - End*/


				Set @AllotedInvPoints = 0 
				Set @AllotedInvAmount = 0
				Set @InvoicePoints = 0
				Set @InvoiceAmount = 0


				/*Update rebate value - Start*/
				Declare RebateCur Cursor For
				Select Distinct OutletCode
				From #RFAInfo 
				Open RebateCur
				Fetch Next From RebateCur Into @CustomerID
				While (@@Fetch_Status = 0)
				Begin
					Set @RedeemPoints = 0
					Set @RedeemAmount = 0
					Set @AllotedPoints = 0
					Set @AllotedAmount = 0
					/*Outlet wise Points*/
					Select @RedeemPoints = TotalPoints, @RedeemAmount = RedeemValue,
					@AllotedPoints = RedeemedPoints, @AllotedAmount = AmountSpent
					From tbl_mERP_CSRedemption
					Where SchemeID = @SchemeID
					And PayoutID = @PayoutID
					And OutletCode = @CustomerID
					And RFAStatus In (0, 1)

					If @AllotedPoints > 0 And @AllotedAmount > 0 --Do update if amount/points alloted to the customer
					Begin
						Declare InvoiceCur Cursor For
						Select Distinct InvoiceID From #RFAInfo
						Where OutletCode = @CustomerID

						Open InvoiceCur
						Fetch Next From InvoiceCur Into @InvoiceID
						While @@Fetch_Status = 0
						Begin

							/*Invoice wise Points*/
							Select @AllotedInvPoints = Case InvoiceType
							When 4 Then (-1) * (@AllotedPoints/@RedeemPoints) * Sum(IsNull(TotalPoints, 0))
							Else (@AllotedPoints/@RedeemPoints) * Sum(IsNull(TotalPoints, 0))
							End,
							@AllotedInvAmount = Case InvoiceType
							When 4 Then (-1) * (@AllotedAmount/@RedeemAmount) * Sum(IsNull(PointsValue, 0))
							Else (@AllotedAmount/@RedeemAmount) * Sum(IsNull(PointsValue, 0))
							End,
							@InvoicePoints = Sum(isnull(TotalPoints,0)),
							@InvoiceAmount = Sum(isnull(PointsValue,0))
							From #RFAInfo
							Where InvoiceID = @InvoiceID 
							Group By InvoiceType

							If @ApplicableOn = 'ITEM' Or @ApplicableOn = 'SPL_CAT'
							Begin
								Declare SKUCur Cursor For
								Select Distinct SKUCode From #RFAInfo
								Where InvoiceID = @InvoiceID
								Open SKUCur
								Fetch Next From SKUCur Into @SKUCode
								While @@Fetch_Status = 0
								Begin
									Update #RFAInfo Set RebateQty = Case InvoiceType
									When 4 Then (-1) * (@AllotedInvPoints/@InvoicePoints) * IsNull(TotalPoints, 0)
									Else (@AllotedInvPoints/@InvoicePoints) * IsNull(TotalPoints, 0)
									End,
									RebateValue = Case InvoiceType
									When 4 Then (-1) * (@AllotedInvAmount/@InvoiceAmount) * IsNull(PointsValue, 0)
									Else (@AllotedInvAmount/@InvoiceAmount) * IsNull(PointsValue, 0)
									End
									Where InvoiceID = @InvoiceID
									And SKUCode = @SKUCode
									And @InvoicePoints > 0
									And @InvoiceAmount > 0
									Fetch Next From SKUCur Into @SKUCode
								End
								Close SKUCur
								Deallocate SKUCur
							End
							Else If @ApplicableOn = 'INVOICE'
								Update #RFAInfo Set RebateQty = Case InvoiceType
								When 4 Then (-1) * @AllotedInvPoints
								Else @AllotedInvPoints
								End,
								RebateValue = Case InvoiceType
								When 4 Then (-1) * @AllotedInvAmount
								Else @AllotedInvAmount
								End
								Where InvoiceID = @InvoiceID
							Fetch Next From InvoiceCur Into @InvoiceID
						End
						Close InvoiceCur
						Deallocate InvoiceCur
					End
					Fetch Next From RebateCur Into @CustomerID
				End
				Close RebateCur
				Deallocate RebateCur
				/*Update rebate value - End*/

				--	Update #RFAInfo Set PromotedValue = Case IsNull(PromotedQty,0)
				--										When 0 Then PromotedValue
				--										Else IsNull(PromotedQty,0) * IsNull(SalePrice,0)
				--										End	

				Update #RFAInfo Set --RebateQty =  (-1) * RebateQty, RebateValue = (-1) * RebateValue,
				SaleQty = (-1) * SaleQty, SaleValue = (-1) * SaleValue
				Where InvoiceType = 4

				Update RFA Set RFASubmissionDate = dbo.StripTimeFromDate(RFAAbs.SubmissionDate) --Cast(Convert(Char(13), SubmissionDate, 103) As nVarchar)
				From tbl_merp_RFaAbstract RFAAbs Inner Join #RFAInfo RFA On RFAAbs.DocumentID = RFA.SchemeID
				Where DocumentID = @Schemeid 
				And ActivityCode = @ActivityCode
				And PayoutFrom = @PayoutFrom
				And PayoutTo = @PayoutTo
				And IsNull(Status,0) <> 5

				If @ApplicableOn = 'ITEM' Or @ApplicableOn = 'SPL_CAT'
				Begin
					If (Select Count(*) From #RFAInfo) >= 1
					Begin
						/*Select Abstract Data*/
						insert into #tmpSchemeOutput(SchemeID,ActivityCode, Description, ApplicablePeriod, RFAPeriod, SalesQty, SaleValue, 
						PromotedQty, PromotedValue, RebateQty, RebateValue, SubmissionDate, PayoutID)
						Select 
						SchemeID, @ActivityCode, @ActivityType, 
						"Applicable Period" = Cast(Convert(Char(13), @ActiveFrom, 103) As nVarchar) + N' - ' + Cast(Convert(Char(13), @ActiveTo, 103) As nVarchar),
						"RFA Period" = Cast(Convert(Char(13), @FromDate, 103) As nVarchar) + N' - ' + Cast(Convert(Char(13), @ToDate, 103) As nVarchar),
						--@ApplicableOn, 
						Sum(SaleQty), Sum(SaleValue), Sum(PromotedQty), Sum(PromotedValue), Sum(RebateQty), Sum(RebateValue)
						, Max(RFASubmissionDate), PayoutID
						From #RFAInfo
						
						group by SchemeID,PayoutID
					End

				End --If @ApplicableOn = 'ITEM' Or @ApplicableOn = 'SPL_CAT'
				Else
				Begin -- If @ApplicableOn = 'INVOICE'

					If (Select Count(*) From #RFAInfo) >= 1
					Begin
						/*Abstract data*/
						Insert into #tmpSchemeOutput(SchemeID,ActivityCode, Description, ApplicablePeriod, RFAPeriod, SalesQty, SaleValue, 
						PromotedQty, PromotedValue, RebateQty, RebateValue, SubmissionDate, PayoutID)
						Select SchemeID,
						@ActivityCode, @ActivityType, 
						"Applicable Period" = Cast(Convert(Char(13), @ActiveFrom, 103) As nVarchar) + N' - ' + Cast(Convert(Char(13), @ActiveTo, 103) As nVarchar),
						"RFA Period" = Cast(Convert(Char(13), @PayoutFrom, 103) As nVarchar) + N' - ' + Cast(Convert(Char(13), @PayoutTo, 103) As nVarchar),
						Sum(SaleQty), Sum(SaleValue), Sum(PromotedQty), Sum(PromotedValue), 
						Sum(RebateQty), Sum(RebateValue)
						, Max(RFASubmissionDate), PayoutID
						From #RFAInfo
						group by SchemeID,PayoutID
					End --If (Select Count(*) From #RFAInfo) >= 1
				End-- If @ApplicableOn = 'INVOICE'
			 End -- Else Begin and End
		End  -- If Schtype = 'Points'


		NextScheme:
		Set @Counter = @Counter + 1
	End --While loop end 

	Select * Into #tmpFinal From #tmpSchemeOutput Order By Description

	/* To Insert Grand Total Row */
	Insert Into #tmpFinal(SchemeID,ActivityCode,SalesQty,SaleValue,PromotedQty,
			    		  PromotedValue,RebateQty,RebateValue)
	Select '1', @GRNTOTAL , Sum(SalesQty),Sum(SaleValue),Sum(PromotedQty),
			Sum(PromotedValue),Sum(RebateQty),Sum(RebateValue)
			From #tmpSchemeoutput


/* To update Null For Zero Value Rows */
	Update #tmpFinal Set 
	SalesQty =  (Case  isNull(SalesQty,0) When 0 Then NULL Else SalesQty End),
	SaleValue = (Case  isNull(SaleValue,0) When 0 Then NULL Else SaleValue End),
	PromotedQty = (Case  isNull(PromotedQty,0) When 0 Then NULL Else PromotedQty End) ,
	PromotedValue = (Case  isNull(PromotedValue,0) When 0 Then NULL Else PromotedValue End),
	RebateQty = (Case  isNull(RebateQty,0) When 0 Then NULL Else RebateQty End),
	RebateValue = (Case  isNull(RebateValue,0) When 0 Then NULL Else RebateValue End)

--	Select * From #tmpFinal Where ActivityCode <> @GRNTOTAL 
--	Union ALL
--	Select * From #tmpFinal Where ActivityCode = @GRNTOTAL

	select cast(schemeID as nvarchar(15)) + Char(15) + ActivityCode  + Char(15) + Cast(IsNull(RFADocID,0) as nVarchar(100)) + Char(15) + cast(PayoutID as nvarchar(15)) 
	+ Char(15) +  Cast(IsNull(RFAID,0) as nVarchar(100)) 
	, ActivityCode, Description, ApplicablePeriod, RFAPeriod, SalesQty As SaleQty, SaleValue, 
			PromotedQty, PromotedValue, RebateQty, RebateValue, SubmissionDate from #tmpFinal
	Where ActivityCode <> @GRNTOTAL

	Union ALL

	select cast(schemeID as nvarchar(15)) + Char(15) + ActivityCode  + Char(15) + Cast(IsNull(RFADocID,0) as nVarchar(100)) + Char(15) + cast(PayoutID as nvarchar(15)) 
	+ Char(15) + Cast(IsNull(RFAID,0) as nVarchar(100)) 
	, ActivityCode, Description, ApplicablePeriod, RFAPeriod, SalesQty As SaleQty, SaleValue, 
			PromotedQty, PromotedValue, RebateQty, RebateValue, SubmissionDate from #tmpFinal
	Where ActivityCode =  @GRNTOTAL

	--select cast(schemeID as nvarchar(15)) + Char(15) + ActivityCode  + Char(15) + Cast(IsNull(RFADocID,0) as nVarchar(100)) + Char(15) + cast(PayoutID as nvarchar(15)) 
	--, ActivityCode, Description, ApplicablePeriod, RFAPeriod, SalesQty As SaleQty, SaleValue, 
	--		PromotedQty, PromotedValue, RebateQty, RebateValue, SubmissionDate from #tmpSchemeOutput


	Drop Table #RFAInfo
	Drop Table #tmpSchemeFinal
	Drop Table #tmpSchemeOutput

	Drop Table #tmpSchemeType
	Drop Table #ActCode
	Drop Table #tmpScheme
	Drop Table #tmpFinal

End -- @SchType = 'Point Scheme'
