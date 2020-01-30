Create Procedure mERP_spr_TradeScheme_Abstract
(
 @FromDate Datetime,
 @ToDate Datetime,
 @RFAStatus nvarchar(10),
 @ActivtiyCode nVarchar(4000),
 @SchemeName nVarchar(4000),
 @Product_Hierarchy nVarchar(50) 
)
As
Begin
	Set Dateformat dmy
	Declare @Counter as Int
	Declare @RowCount as Int
	Declare @SchemeID as Int 
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
	Declare @PayoutID Int
	Declare @InvPrefix nVarchar(10)
	Declare @CustomerID nVarchar(255)
	Declare @SKUCode nVarchar(255)
	Declare @SchemeOutlet nVarchar(255)
	Declare @InvoiceID Int
	Declare @SchemeAmt Decimal(18, 6)
	Declare @SlabID Int
	Declare @SR Int
	Declare @InvoiceRef nVarchar(255)
	Declare @SchemeGroup Int
	Declare @SchemeDetail nVarchar(1000)
	Declare @FlagWord Int
	Declare @Serial Int
	Declare @Amount Decimal(18, 6)
	Declare @SaleQty Decimal(18,6)
	Declare @FreeQty Decimal(18,6)
	Declare @FreeValue Decimal(18,6)
	Declare @PromotedQty Decimal(18,6)
	Declare @PromotedValue Decimal(18,6)
	Declare @SaleValue Decimal(18,6)
	Declare @FreeFlag Int
	Declare @FreeSKUSerial Int
	Declare @TaxCode Decimal(18,6)
	Declare @UOMID Int
	Declare @UOM nVarchar(255)
	Declare @InvRebateValue Decimal(18,6)
	Declare @SRRebateValue Decimal(18,6)
	Declare @BillRef nVarchar(255)
	Declare @WDCode nVarchar(255) 
	Declare @SRNo Int
	Declare @PrevSKUCode nVarchar(255)	
	Declare @WDDest nVarchar(255)
	Declare @InvoiceType Int,@szPayoutID as nVarchar(255)
	Declare @InvSRID Int
	Declare @TaxConfigFlag Int
	Declare @MarginPTR Decimal(18,6)
	Declare @QPS Int
    Declare @NoQPS Int 
	Declare @ItemFree Int	
	Declare @RebFreeQty Decimal(18,6)
	Declare @PayoutPeriod nVarchar(1000)

	Declare @LesserDate DateTime
    Declare @GreaterDate DateTime

	Declare @Delimeter nVarchar(1)
	Set @Delimeter = Char(15) 

	Declare @GRNTOTAL nVarchar(50)    
	--To hold the lastinventoryuploaddate with the format.
	Declare @LastInventoryuploadDate datetime
	Select @LastInventoryuploadDate  = convert(nvarchar(10),lastinventoryupload,103) from Setup
	
    Declare @SkipSRInvScheme as table (SchemeID Int, InvoiceID Int, PayoutFrom DateTime, PayoutTo DateTime)
	declare @CheckRFAPeriod int
	/* Checking for Tax Configuration /
	Flag = 1 Include Tax 
	Flag = 0 Without Tax 
	For Rebate Value calculation for Free Item*/
	Select @TaxConfigFlag = IsNull(Flag, 0) From tbl_merp_ConfigAbstract 
	Where ScreenCode Like 'RFA01'

	/* Based on the RFA Config Changes As on 29.11.2010 for CreditNote we are maintaining separate Flag */
	Declare @CrNoteFlag int	
	Select @CrNoteFlag = IsNull(Flag, 0) From tbl_merp_ConfigAbstract 
	Where ScreenCode Like 'RFA02'
	/* Based on the RFA Config Changes As on 29.11.2010 for CreditNote we are maintaining separate Flag */
	
  	Set @GRNTOTAL = dbo.LookupDictionaryItem(N'Grand Total:', Default)     

	Declare @tmpActivityCode Table (ActivityCode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Declare @tmpScheme Table ([RowID] Int Identity(1,1),SchemeID int,PayoutID Int)

	Create Table #RFAInfo(SR Int Identity , InvoiceID Int, BillRef nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, OutletCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							RCSID nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, ActiveInRCS nVarchar(100) collate SQL_Latin1_General_CP1_CI_AS, LineType nVarchar(50), 
							Division nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS ,
							SubCategory nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, 
							MarketSKU nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, 
							SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							UOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, SaleQty Decimal(18, 6), SaleValue Decimal(18, 6),
							PromotedQty Decimal(18, 6), PromotedValue Decimal(18, 6), FreeBaseUOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							RebateQty Decimal(18, 6), RebateValue Decimal(18, 6), PriceExclTax Decimal(18, 6),
							TaxPercentage Decimal(18,6), TaxAmount Decimal(18, 6), PriceInclTax Decimal(18, 6),
							SchemeDetail nVarchar(1000), Serial Int, Flagword Int, Amount Decimal(18, 6),
							SchemeID Int, SlabID Int, PTR Decimal(18,6), TaxCode Decimal(18,6), BudgetedValue Decimal(18,6), 
							FreeSKUSerial Int,SalePrice Decimal(18,6),  UOM1Conv Decimal(18,6), UOM2Conv Decimal(18,6),
							InvoiceType Int, SchemeOutlet Int, SchemeSKU Int Default(0), SchemeGroup Int, TotalPoints Decimal(18,6), 
							PointsValue Decimal(18,6), ReferenceNumber nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS
							, RFASubmissionDate Datetime )

--	Declare @tmpSchemeoutput Table (Schemeid NVarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS,ActivityCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	Create Table #tmpSchemeoutput(Schemeid NVarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS,ActivityCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
								 Description nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
								 [Applicable Period]	nVarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS,
								 [RFA Period] nVarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS,
								 SaleQty Decimal(18,6),SaleValue Decimal(18,6),PromotedQty Decimal(18,6),
								 PromotedValue Decimal(18,6),RebateQty Decimal(18,6),RebateValue Decimal(18,6),
								 SubmissionDate DateTime)

--	Declare #tmpSKUWiseSales Table (SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, 
	Create Table  #tmpSKUWiseSales (SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, 
	SalesQty Decimal(18,6),SalesValue Decimal(18,6)) 

--	Declare @tmpSubRFAInfo1 Table (SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
	Create Table  #tmpSubRFAInfo1 (SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
								 Flagword Int, SchemeID Int, SaleQty Decimal(18,6), SaleValue Decimal(18,6), 
								 PromotedQty Decimal(18,6), PromotedValue Decimal(18,6), 
								 RebateQty Decimal(18,6), RebateValue Decimal(18,6), 
								 SubmissionDate DateTime)

--	Declare @FreeInfo Table (InvoiceID Int, BillRef nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, 
	Create Table #FreeInfo (InvoiceID Int, BillRef nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, 
		OutletCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
		SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
		RebateQty Decimal(18, 6), 
		RebateValue Decimal(18, 6), PriceExclTax Decimal(18, 6),
		TaxPercentage Decimal(18,6), TaxAmount Decimal(18, 6), PriceInclTax Decimal(18, 6),
		Flagword Int, SchemeOutlet Int, SchemeSKU Int Default(0), SchemeID Int, PayoutID Int, TaxCode Decimal(18, 6), 
		Division nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS ,
		SubCategory nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, 
		MarketSKU nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, 
		UOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS)

--	Declare @tmpPayout Table (SchemeID Int,PayoutID Int)
	Create Table #tmpPayout (SchemeID Int,PayoutID Int)

--	Declare @tmpSKU Table (skucode nvarchar(255) collate SQL_Latin1_General_CP1_CI_AS)
	Create Table #tmpSKU (skucode nvarchar(255) collate SQL_Latin1_General_CP1_CI_AS)

--	Declare @tmpTotSales Table (ActivityCode nVarchar(500) collate SQL_Latin1_General_CP1_CI_AS, 
	Create Table #tmpTotSales (ActivityCode nVarchar(500) collate SQL_Latin1_General_CP1_CI_AS, 
	[RFA Period] nVarchar(500) collate SQL_Latin1_General_CP1_CI_AS,TotQty Decimal(18,6),TotValue Decimal(18,6))

--	Declare @tmpLesGrtDate Table (SchemeID Int, PADateFrom Datetime, PADateTo Datetime)
	Create Table  #tmpLesGrtDate (SchemeID Int, PADateFrom Datetime, PADateTo Datetime,ActiveFrom Datetime,ActiveTo Datetime)

	/* Table Used to store the Total Sales qty and Volume SKUWise Starts */
--	Declare @tmpSales Table (SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
	Create Table #tmpSales (SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							   SaleQty Decimal(18,6),SaleValue Decimal(18,6),
								Flagword Int,InvoiceType Int)

	Set @ToDate = dbo.StripTimeFromDate(@ToDate)
	Set @FromDate = dbo.StripTimeFromDate(@FromDate)

	If @RFAStatus = 'Yes'
		Set @RFAStatus = 1
	Else
		Set @RFAStatus = 0
	
	If @ActivtiyCode = '%'
		Insert Into @tmpActivityCode
		Select Distinct ActivityCode From tbl_mERP_SchemeAbstract Where RFAApplicable = @RFAStatus
		And Active = 1
	Else
		Insert Into @tmpActivityCode
		Select Distinct ActivityCode From tbl_mERP_SchemeAbstract
		Where ActivityCode In (Select * From dbo.sp_SplitIn2Rows(@ActivtiyCode,@Delimeter))
		And RFAApplicable = @RFAStatus
		And Active = 1

	If @RFAStatus = 1 
	Begin
		If @Schemename = '%' 
			Insert Into @tmpScheme
			Select Distinct SA.SchemeID,SPP.ID From tbl_mERP_SchemeAbstract SA,tbl_mERP_SchemePayoutPeriod SPP
			Where SA.SchemeType In(1,2)
			And ActivityCode In (Select * From @tmpActivityCode)
			And SA.SchemeID = SPP.SchemeID
			And SPP.PayoutPeriodTo Between @FromDate And @ToDate
			And SA.Active = 1 And SPP.Active = 1

			
		Else
			Insert Into @tmpScheme
			Select Distinct SA.Schemeid,SPP.ID  From tbl_mERP_SchemeAbstract SA,tbl_mERP_SchemePayoutPeriod SPP
			Where SchemeType In(1,2) and Description In (Select * From Dbo.sp_SplitIn2Rows(@SchemeName,@Delimeter))
			And SA.SchemeID = SPP.SchemeID
			And ActivityCode In (Select * From @tmpActivityCode)
			And SPP.PayoutPeriodTo Between @FromDate And @ToDate
			And SA.Active = 1 And SPP.Active = 1
	End
	Else
	Begin	
		If @Schemename = '%' 
			Insert Into @tmpScheme
			Select Distinct SchemeID,0 From tbl_mERP_SchemeAbstract 
			Where SchemeType In(1,2)
			And ActivityCode In (Select * From @tmpActivityCode)
			And Active = 1 and Isnull(RFAApplicable,0) = @RFAStatus
			and (dbo.striptimefromdate(ActiveFrom) <= @ToDate or dbo.striptimefromdate(ActiveTo) >= @ToDate)
		Else
			Insert Into @tmpScheme
			Select Distinct Schemeid,0 From tbl_mERP_SchemeAbstract
			Where SchemeType In(1,2) and Description In (Select * From Dbo.sp_SplitIn2Rows(@SchemeName,@Delimeter))
			And ActivityCode In (Select * From @tmpActivityCode)
			And Active = 1 and Isnull(RFAApplicable,0) = @RFAStatus
			and (dbo.striptimefromdate(ActiveFrom) <= @ToDate or dbo.striptimefromdate(ActiveTo) >= @ToDate)
	End
			
	Set @RowCount = (Select max([RowID]) from @tmpScheme)
	Set @counter = 1 
	

	
	While @Counter <= @RowCount
	Begin

		Set @SchemeID = 0
		Set @PayoutID = 0
	
		Select @SchemeID = Schemeid,@PayoutID = PayoutID from @tmpScheme Where [RowID] = @Counter
		Delete #tmpSKU

		If  @RFAStatus  = 1 
			Select @SchemeType = SA.SchemeType,
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
			@ItemGroup = Itemgroup
			From tbl_mERP_SchemeAbstract SA,  tbl_mERP_SchemePayoutPeriod SPP
			Where SA.SchemeID = @SchemeID
			And SA.SchemeID = SPP.SchemeID
			And SPP.ID = @PayoutID and Sa.RFAApplicable = @RFAStatus
		Else
			Select @SchemeType = SA.SchemeType,
			@ActivityCode = SA.ActivityCode, 
			@CSSchemeID = SA.CS_RecSchID,
			@ActivityType = SA.Description,
			@ActiveFrom = SA.ActiveFrom, 
			@ActiveTo = SA.ActiveTo, 
			@PayoutFrom = @FromDate, 
			@PayoutTo = @ToDate,
			@ExpiryDate = SA.ExpiryDate,	
			@ApplicableOn = Case When SA.ApplicableOn =1 And SA.ItemGroup = 1 Then 'ITEM'
								When SA.ApplicableOn =1 And SA.ItemGroup = 2 Then 'SPL_CAT'	
								When SA.ApplicableOn = 2 Then 'INVOICE'
								End,
			@ItemGroup = Itemgroup
			From tbl_mERP_SchemeAbstract SA
			Where SA.SchemeID = @SchemeID and Sa.RFAApplicable = @RFAStatus
			

		Insert Into #tmpLesGrtDate  Values (@SchemeID, @ActiveFrom, @ActiveTo, @ActiveFrom, @ActiveTo)
		Insert Into #tmpLesGrtDate  Values (@SchemeID, @PayoutFrom, @PayoutTo, @ActiveFrom, @ActiveTo) 
		Insert Into #tmpLesGrtDate 	
		Select @SchemeID, Min(InvoiceDate), Max(InvoiceDate), @ActiveFrom, @ActiveTo from InvoiceAbstract where InvoiceID In 
		(Select IsNull(InvoiceRef,'') from SChemeCustomerItems where SchemeID = @SchemeID and payoutid = @payoutID 
		and Claimed = 1 and IsInvoiced = 1 and IsNull(InvoiceRef,'') <> '' and IsNull(InvoiceRef,'') Not Like '%,%' )
		and IsNull(Status,0) & 128 = 0

	Insert Into #tmpLesGrtDate 
	Select @SchemeID, Min(InvoiceDate), Max(InvoiceDate), @ActiveFrom, @ActiveTo from InvoiceAbstract IA where 
	IA.InvoiceType = 3 And 
	(Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID = 
					IA.DocumentID
					And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)
					Between @ActiveFrom And @ActiveTo 
		And 
			(Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID = 
					IA.DocumentID
					And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)
			Between @PayoutFrom And @PayoutTo


		Set @Counter = @Counter + 1 
	End

	Select @LesserDate = dbo.StripTimeFromDate(Min(PADateFrom)) From #tmpLesGrtDate 
	Select @GreaterDate = dbo.StripTimeFromDate(Max(PADateTo)) From #tmpLesGrtDate 

	Select @ActiveFrom = dbo.StripTimeFromDate(Min(ActiveFrom)) From #tmpLesGrtDate 
	Select @ActiveTo = dbo.StripTimeFromDate(Max(ActiveTo)) From #tmpLesGrtDate 
	

	

	

	
	DECLARE @sql NvARCHAR(4000)
	Select InvoiceID,InvoiceType,InvoiceDate,CustomerID,BillingAddress,ShippingAddress,UserName,GrossValue,DiscountPercentage
	,DiscountValue,NetValue,CreationTime,Status,TaxLocation,InvoiceReference,ReferenceNumber,AdditionalDiscount,Freight
	,CreditTerm,PaymentDate,DocumentID,NewReference,NewInvoiceReference,OriginalInvoice,ClientID,Memo1,Memo2,Memo3
	,MemoLabel1,MemoLabel2,MemoLabel3,Flags,ReferredBy,Balance,SalesmanID,BeatID,PaymentMode,PaymentDetails,ReturnType
	,Salesman2,DocReference,AmountRecd,AdjRef,AdjustedAmount,GoodsValue,AddlDiscountValue,TotalTaxSuffered
	,TotalTaxApplicable,ProductDiscount,RoundOffAmount,AdjustmentValue,Denominations,ServiceCharge,BranchCode,CFormNo
	,DFormNo,CancelDate,VanNumber,TaxOnMRP,DocSerialType,SchemeID,SchemeDiscountPercentage,SchemeDiscountAmount
	,ClaimedAmount,ClaimedAlready,ExciseDuty,DiscountBeforeExcise,SalePriceBeforeExcise,CustomerPoints,VatTaxAmount
	,SONumber,GroupID,DeliveryStatus,DeliveryDate,InvoiceSchemeID,MultipleSchemeDetails  
	Into [#TmpTSRInvAbs] From InvoiceAbstract where 1=2

	SET IDENTITY_INSERT dbo.#TmpTSRInvAbs ON
	sET @sql = 'Insert Into [#TmpTSRInvAbs] (InvoiceID,InvoiceType,InvoiceDate,CustomerID,BillingAddress,ShippingAddress
	,UserName,GrossValue,DiscountPercentage,DiscountValue,NetValue,CreationTime,Status,TaxLocation,InvoiceReference,ReferenceNumber,AdditionalDiscount,Freight
	,CreditTerm,PaymentDate,DocumentID,NewReference,NewInvoiceReference,OriginalInvoice,ClientID,Memo1,Memo2,Memo3,MemoLabel1,MemoLabel2,MemoLabel3,Flags
	,ReferredBy,Balance,SalesmanID,BeatID,PaymentMode,PaymentDetails,ReturnType,Salesman2,DocReference,AmountRecd,AdjRef
	,AdjustedAmount,GoodsValue,AddlDiscountValue,TotalTaxSuffered,TotalTaxApplicable,ProductDiscount,RoundOffAmount,AdjustmentValue,Denominations,ServiceCharge
	,BranchCode,CFormNo,DFormNo,CancelDate,VanNumber,TaxOnMRP,DocSerialType,SchemeID,SchemeDiscountPercentage,SchemeDiscountAmount,ClaimedAmount,ClaimedAlready
	,ExciseDuty,DiscountBeforeExcise,SalePriceBeforeExcise,CustomerPoints,VatTaxAmount,SONumber,GroupID,DeliveryStatus,DeliveryDate,InvoiceSchemeID,MultipleSchemeDetails) 
	select InvoiceID,InvoiceType,InvoiceDate,CustomerID,BillingAddress,ShippingAddress,UserName,GrossValue,DiscountPercentage,DiscountValue,NetValue,CreationTime,Status
	,TaxLocation,InvoiceReference,ReferenceNumber,AdditionalDiscount,Freight,CreditTerm,PaymentDate,DocumentID,NewReference,NewInvoiceReference,OriginalInvoice,ClientID
	,Memo1,Memo2,Memo3,MemoLabel1,MemoLabel2,MemoLabel3,Flags,ReferredBy,Balance,SalesmanID,BeatID,PaymentMode,PaymentDetails,ReturnType,Salesman2,DocReference,AmountRecd
	,AdjRef,AdjustedAmount,GoodsValue,AddlDiscountValue,TotalTaxSuffered,TotalTaxApplicable,ProductDiscount,RoundOffAmount,AdjustmentValue,Denominations,ServiceCharge,BranchCode
	,CFormNo,DFormNo,CancelDate,VanNumber,TaxOnMRP,DocSerialType,SchemeID,SchemeDiscountPercentage,SchemeDiscountAmount,ClaimedAmount,ClaimedAlready,ExciseDuty,DiscountBeforeExcise
	,SalePriceBeforeExcise,CustomerPoints,VatTaxAmount,SONumber,GroupID,DeliveryStatus,DeliveryDate,InvoiceSchemeID,MultipleSchemeDetails  From InvoiceAbstract 
	Where dbo.StripTimeFromDate(InvoiceDate) Between '''+  CAST(@LesserDate as Varchar)+ ''' And   ''' + CAST(@GreaterDate as Varchar) + '''And InvoiceType In (1,3,4)'

	If @LastInventoryuploadDate is not null
		SET @sql =  @sql + ' And dbo.StripTimeFromDate(InvoiceDate) <= ''' + cast(@LastInventoryuploadDate as varchar) + ''''

	Exec Sp_ExecuteSQL @Sql
	SET IDENTITY_INSERT dbo.#TmpTSRInvAbs OFF

	
	Select invd.* Into #TmpTSRInvDtl From InvoiceDetail invd,  #TmpTSRInvAbs inva 
	Where invd.InvoiceID = inva.InvoiceID 

		Truncate Table #tmpSales 
	
	
		Insert Into #tmpSales
		Select 	ID.Product_Code as SKUCode,
				Case ID.FlagWord
					When 0 Then ID.Quantity 
					Else 0 End	as SaleQty,
				Case ID.FlagWord
					When 0 Then ID.SalePrice * ID.Quantity 
					Else 0 End	as SaleValue,
				ID.FlagWord,
				InvoiceType
				From #TmpTSRInvAbs IA, #TmpTSRInvDtl ID, Customer C
				Where IA.InvoiceId = ID.InvoiceId
				And IA.InvoiceType In (1,3,4)        
				And (IA.Status & 128) = 0  
				And IA.CustomerID = C.CustomerID
				And (Case IA.InvoiceType
							When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From #TmpTSRInvAbs Where DocumentID = 
							IA.DocumentID
							And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)
							Else dbo.StripTimeFromDate(IA.InvoiceDate)
							End) Between @ActiveFrom And @ActiveTo
				And (Case IA.InvoiceType
						When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From #TmpTSRInvAbs Where DocumentID = IA.DocumentID
							And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID) 
						Else dbo.StripTimeFromDate(IA.InvoiceDate)
						End) Between @LesserDate And @GreaterDate

	


	Set @Counter = 1

	
	While @Counter <= @RowCount
	Begin
		Set @SchemeID = 0
		Set @PayoutID = 0
		
		Select @SchemeID = Schemeid,@PayoutID = PayoutID from @tmpScheme Where [RowID] = @Counter
		Delete #tmpSKU

		If  @RFAStatus  = 1 
			Select @SchemeType = SA.SchemeType,
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
			@ItemGroup = Itemgroup
			From tbl_mERP_SchemeAbstract SA,  tbl_mERP_SchemePayoutPeriod SPP
			Where SA.SchemeID = @SchemeID
			And SA.SchemeID = SPP.SchemeID
			And SPP.ID = @PayoutID
			
		Else
			Select @SchemeType = SA.SchemeType,
			@ActivityCode = SA.ActivityCode, 
			@CSSchemeID = SA.CS_RecSchID,
			@ActivityType = SA.Description,
			@ActiveFrom = SA.ActiveFrom, 
			@ActiveTo = SA.ActiveTo, 
			@PayoutFrom = @FromDate, 
			@PayoutTo = @ToDate,
			@ExpiryDate = SA.ExpiryDate,	
			@ApplicableOn = Case When SA.ApplicableOn =1 And SA.ItemGroup = 1 Then 'ITEM'
								When SA.ApplicableOn =1 And SA.ItemGroup = 2 Then 'SPL_CAT'	
								When SA.ApplicableOn = 2 Then 'INVOICE'
								End,
			@ItemGroup = Itemgroup
			From tbl_mERP_SchemeAbstract SA
			Where SA.SchemeID = @SchemeID

		Select @PayoutPeriod = Cast(Convert(Char(11), @PayoutFrom, 103) As nVarchar) + N'- ' + Cast(Convert(Char(11), @PayoutTo, 103) As nVarchar)
		
		If  @RFAStatus  = 1 
			Insert Into #tmpPayout
			Select @SchemeID,@PayoutID
		Else
			Insert Into #tmpPayout
			Select @SchemeID,ID From tbl_mERP_SchemePayoutPeriod Where 
			SchemeID = @SchemeID And Active = 1

--		--	Truncate Table #tmpSales 
--		Delete #tmpSales 
--	
--		Insert Into #tmpSales
--		Select 	ID.Product_Code as SKUCode,
--				Case ID.FlagWord
--					When 0 Then ID.Quantity 
--					Else 0 End	as SaleQty,
--				Case ID.FlagWord
--					When 0 Then ID.SalePrice * ID.Quantity 
--					Else 0 End	as SaleValue,
--				ID.FlagWord,
--				InvoiceType
--				From #TmpTSRInvAbs IA, #TmpTSRInvDtl ID, Customer C
--				Where IA.InvoiceId = ID.InvoiceId
--				And IA.InvoiceType In (1,3,4)        
--				And (IA.Status & 128) = 0  
--				And IA.CustomerID = C.CustomerID
--				And (Case IA.InvoiceType
--							When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From #TmpTSRInvAbs Where DocumentID = 
--							IA.DocumentID
--							And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)
--							Else dbo.StripTimeFromDate(IA.InvoiceDate)
--							End) Between @ActiveFrom And @ActiveTo
--				And (Case IA.InvoiceType
--						When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From #TmpTSRInvAbs Where DocumentID = IA.DocumentID
--							And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID) 
--						Else dbo.StripTimeFromDate(IA.InvoiceDate)
--						End) Between @PayoutFrom And @PayoutTo

		
		/* To Insert ProductWise Sales From And To PayoutPeriod */
		Delete #tmpSKUWiseSales
		Insert Into #tmpSKUWiseSales
		Select SKUCode,Sum(Case InvoiceType When 4 Then -1 * SaleQty Else SaleQty End),
		Sum(Case InvoiceType When 4 Then -1 * SaleValue Else SaleValue End) From #tmpSales  
		Where FlagWord = 0
		Group By SKUCode

		/* For schemes which are already submitted take it directly from RFAAbstract & RFADetail table */
		If  @RFAStatus  = 1
		Begin
			If Exists (Select Top 1 * From tbl_mERP_SchemePayoutPeriod Where SchemeID = @SchemeID And ID = @PayoutID And ClaimRFA = 1 ) 
			Begin
				If Exists (Select Top 1 * From tbl_mERP_RFAAbstract Where DocumentID = @SchemeID And PayOutFrom = @PayoutFrom And PayOutTo = @PayoutTo And isNull(Status,0) <> 5) 
				Begin
						Insert Into #tmpSchemeoutput(SchemeID,ActivityCode, Description, [Applicable Period], [RFA Period],
									 SaleQty, SaleValue,PromotedQty, PromotedValue, RebateQty, RebateValue, SubmissionDate)
						Select Cast(@SchemeID as nVarchar(100)) + '|'+ Cast(@PayoutID as nVarchar(100)) ,@ActivityCode, @ActivityType, 
						Cast(Convert(Char(11), @ActiveFrom, 103) As nVarchar) + N'- ' + Cast(Convert(Char(11), @ActiveTo, 103) As nVarchar),
						Cast(Convert(Char(11), @PayoutFrom, 103) As nVarchar) + N'- ' + Cast(Convert(Char(11), @PayoutTo, 103) As nVarchar),
						Sum(RFA_DT.SaleQty), Sum(RFA_DT.SaleValue), Sum(RFA_DT.PromotedQty), Sum(RFA_DT.PromotedValue), Sum(RFA_DT.RebateQty), Sum(RFA_DT.RebateValue),
						Max(RFA_ABS.SubmissionDate)
						From tbl_mERP_RFAAbstract RFA_ABS, tbl_mERP_RFADetail RFA_DT
						Where RFA_ABS.DocumentID = @SchemeID 
                          And RFA_ABS.RFAID = RFA_DT.RFAID
						  And isNull(RFA_ABS.Status,0) <> 5 
						  And RFA_ABS.PayOutFrom = @PayoutFrom 
						  And RFA_ABS.PayOutTo = @PayoutTo 

						Insert Into #tmpSKU 
						select Distinct  SystemSKU from tbl_mERP_RFAAbstract
						Where DocumentID = @SchemeID And isNull(Status,0) <> 5 And PayOutFrom = @PayoutFrom And PayOutTo = @PayoutTo 

						GoTo NextScheme1
				End
			End	
		End 

		Set @QPS = -1 

		Select @QPS = Max(IsNull(QPS, 0)) From tbl_mERP_SchemeOutlet 
		Where SchemeID = @SchemeID
		And IsNull(QPS, 0) = 0 


        /*To Get the Invoice and SR Entries having Value greater than Sales Value*/
        Declare @tmpInvoiceID int
        Declare SRCursor Cursor For
		Select InvoiceID, Sum(RebateValue) from tbl_merp_NonQPSData Where InvoiceType = 4 and SchemeID = @SchemeID and OriginalInvDate Between @PayoutFrom And @PayoutTo Group By InvoiceID
		Open SRCursor
		Fetch Next From SRCursor Into @InvoiceID, @SRRebateValue
		While (@@Fetch_Status = 0)
		Begin

			/*Invoice Rebate value*/
			--Finding respective invoiceid
			Declare @SRInvoiceID Int
			Declare @SRGSTFlag Int
			Declare @GSTFullDocID nVarChar(255)
			Set @InvRebateValue = 0
			Select @SRInvoiceID =  Isnull(SRInvoiceID,0) from InvoiceAbstract where Status & 128 = 0 and InvoiceType=4 and InvoiceID = @InvoiceID
			If @SRInvoiceID > 0
			 Select @SRGSTFlag = Isnull(GSTFlag,0),@GSTFullDocID= GSTFullDocID  from InvoiceAbstract where InvoiceId = @SRInvoiceID
			If ((Isnull(@SRInvoiceID,0) = 0 ) or (Isnull(@SRGSTFlag,0) = 0))
			Begin
				Select @BillRef = isnull(ReferenceNumber,'') from InvoiceAbstract where Status & 128 = 0 and invoicetype=4 and Invoiceid = @InvoiceID 
				If isnumeric(@BillRef) = 0
					Set @tmpInvoiceID = ( Select Top 1 InvoiceId from InvoiceAbstract where Status & 128 = 0 and DocumentId= ( select top 1 cast(ISnull(REVERSE(left(reverse(ReferenceNumber),PATINDEX(N'%[^0-9]%',Reverse(ReferenceNumber))-1)),0) as Integer) 
											  from InvoiceAbstract where invoicetype=4 and Invoiceid = @InvoiceID and isnull(referencenumber,'') <> '' and isnumeric(referencenumber) = 0 ) 
																															   order by invoiceid desc) 
				Else
					Set @tmpInvoiceID = ( Select Top 1 InvoiceId from InvoiceAbstract where Status & 128 = 0 and DocumentId =  (Select ReferenceNumber from InvoiceAbstract where invoicetype=4 and Invoiceid = @InvoiceID and isnull(referencenumber,'') <> ''  ) order by invoiceid desc) 
			End
			Else
			Begin
				Set  @tmpInvoiceID = (Select Top 1 InvoiceId from InvoiceAbstract where Status & 128 = 0 and GSTFullDocID = @GSTFullDocID Order by InvoiceID Desc)
			End
			--Check if original invoice exist in that period.
			If Isnull(@tmpInvoiceid,0) <> 0
				Select @InvRebateValue = Sum(RebateValue) From tbl_merp_nonqpsdata Where InvoiceType<>4 and isnull([Type],0)=0 and schemeid=@SchemeId and Invoiceid = @tmpInvoiceId

            If (@InvRebateValue + @SRRebateValue) < 0 
            Begin
			  Insert into @SkipSRInvScheme(SchemeID, InvoiceID, PayoutFrom, PayoutTo) Values (@SchemeID, @InvoiceID, @PayoutFrom, @PayoutTo )
			  Insert into @SkipSRInvScheme(SchemeID, InvoiceID, PayoutFrom, PayoutTo) Values (@SchemeID, @tmpInvoiceID, @PayoutFrom, @PayoutTo )
			End
			Fetch Next From SRCursor Into @InvoiceID, @SRRebateValue
		End
		Close SRCursor	
		Deallocate SRCursor
        /**/

		
		

		If @QPS = 0
		Begin 
			If @ApplicableOn = 'ITEM' Or @ApplicableOn = 'SPL_CAT'
			Begin/*Trade - Item based schemes - Start*/ 


				Insert Into #tmpSKU
				Select Distinct Product_code From [tbl_merp_NonQPSData] 
				Where SchemeID = @SchemeID And 
				[Type] = 0 

				Insert Into #tmpSchemeoutput(SchemeID,ActivityCode, Description, [Applicable Period], [RFA Period], 
					SaleQty, SaleValue, PromotedQty, PromotedValue, RebateQty, RebateValue, SubmissionDate)

				Select SchemeID, 
				ActivityCode, ActivityType, 
				ActiveFrom,
				PayoutFrom, 
				Sum(SaleQty), Sum(SaleValue), Sum(PromotedQty), Sum(PromotedValue), Sum(RebateQty), 
				Sum(RebateValue), empty 
				From (
						Select "SchemeID" = Cast(@SchemeID as nVarchar(1000)) + '|'+ Cast(@PayoutID as nVarchar(1000)) , 
						"ActivityCode" = @ActivityCode, "ActivityType" = @ActivityType, 
						"ActiveFrom" = Cast(Convert(Char(11), @ActiveFrom, 103) As nVarchar) + N'- ' + Cast(Convert(Char(11), @ActiveTo, 103) As nVarchar),
						"PayoutFrom" = Cast(Convert(Char(11), @PayoutFrom, 103) As nVarchar) + N'- ' + Cast(Convert(Char(11), @PayoutTo, 103) As nVarchar), 
						"SaleQty" = IsNull(SaleQty, 0), 
						"SaleValue" = IsNull(SaleValue, 0), 
						"PromotedQty" = IsNull(PromotedQty, 0), 
						"PromotedValue" = IsNull(PromotedValue, 0), 
						"RebateQty" = IsNull(RebateQty, 0), 
						"RebateValue" = Case @TaxConfigFlag When 1 Then 
											IsNull(RebateValue_Tax, 0)
										Else 
											IsNull(RebateValue, 0) 
										End , "empty" = NULL 
						From [tbl_merp_NonQPSData] 
						Where SchemeID = @SchemeID And 
						[Type] <> 1 And 
						OriginalInvDate Between @ActiveFrom And @ActiveTo And 
						OriginalInvDate Between @PayoutFrom And @PayoutTo And 
                        InvoiceID Not in (Select Distinct InvoiceID From @SkipSRInvScheme Where SchemeID = @SchemeID And PayoutFrom = @PayoutFrom And PayoutTo = @PayoutTo)
					) As Als 
				Group by SchemeID, ActivityCode, ActivityType, ActiveFrom, PayoutFrom,empty
			End/*Trade - Item based schemes - End*/ 
			Else If @ApplicableOn = 'INVOICE'
			Begin/*Trade - Invoice based schemes - Start*/ 
				Insert Into #tmpSchemeoutput(SchemeID,ActivityCode, Description, [Applicable Period], [RFA Period], 
					SaleQty, SaleValue, PromotedQty, PromotedValue, RebateQty, RebateValue, SubmissionDate)
				Select 
				SchemeID, 
				ActivityCode, ActivityType, 
				ActiveFrom,
				PayoutFrom, 
				Sum(SaleQty), Sum(SaleValue), Sum(PromotedQty), Sum(PromotedValue), Sum(RebateQty), 
				Sum(RebateValue), empty 
				From (
						Select 
						"SchemeID" =  Cast(@SchemeID as nVarchar(1000)) + '|'+ Cast(@PayoutID as nVarchar(1000)) , 
						"ActivityCode" = @ActivityCode, "ActivityType" = @ActivityType, 
						"ActiveFrom" = Cast(Convert(Char(11), @ActiveFrom, 103) As nVarchar) + N'- ' + Cast(Convert(Char(11), @ActiveTo, 103) As nVarchar),
						"PayoutFrom" = Cast(Convert(Char(11), @PayoutFrom, 103) As nVarchar) + N'- ' + Cast(Convert(Char(11), @PayoutTo, 103) As nVarchar), 
						"SaleQty" = IsNull(SaleQty, 0), 
						"SaleValue" = IsNull(SaleValue, 0), 
						"PromotedQty" = IsNull(PromotedQty, 0), 
						"PromotedValue" = IsNull(PromotedValue, 0), 
						"RebateQty" = IsNull(RebateQty, 0), 
						"RebateValue" = Case @TaxConfigFlag When 1 Then 
											IsNull(RebateValue_Tax, 0) 
										Else 
											IsNull(RebateValue, 0) 
										End,  "empty" = NULL 
						From [tbl_merp_NonQPSData] 
						Where SchemeID = @SchemeID And 
						OriginalInvDate Between @ActiveFrom And @ActiveTo And 
						OriginalInvDate Between @PayoutFrom And @PayoutTo And
                        InvoiceID Not in (Select Distinct InvoiceID From @SkipSRInvScheme Where SchemeID = @SchemeID And PayoutFrom = @PayoutFrom And PayoutTo = @PayoutTo)
					) As Als 
				Group by SchemeID, ActivityCode, ActivityType, ActiveFrom, PayoutFrom, empty
			End	/*Trade - Invoice based schemes - End*/ 
		End

		Select @QPS = Max(IsNull(QPS, 0)) From tbl_mERP_SchemeOutlet 
		Where SchemeID = @SchemeID
		And IsNull(QPS, 0) = 1 

		Declare @Free Int
		Select @Free = (case Max(SlabType) When 3 Then 1 Else 0 End) From tbl_merp_schemeslabdetail Where SchemeID = @SchemeID

		If @QPS = 1
		Begin
		--==================QPS scheme Begins=====================================================
			Declare @RebValForFreeItem As Decimal(18, 6)
		--	Truncate Table #FreeInfo
			Delete #FreeInfo
			set @CheckRFAPeriod =0
			if @RFAStatus = 1 
				Begin
				If Exists(Select * From tbl_mERP_QPSDtlData Where SchemeID = @SchemeID And PayoutID = @PayoutID )
					set @CheckRFAPeriod = 1
				else
					set @CheckRFAPeriod = 0
				End
			else
				Begin
				If Exists(Select * From tbl_mERP_QPSDtlData Where SchemeID = @SchemeID )
					set @CheckRFAPeriod = 1
				else
					set @CheckRFAPeriod = 0
				End
				
			
			If (@CheckRFAPeriod =1)
			Begin
				/*Free Qty scheme*/
				Declare OffTakeSKUCur Cursor For
				Select CustomerID, Product_Code, InvoiceRef 
				From SchemeCustomerItems SchmCustItm,#tmpPayout Payout
				Where SchmCustItm.SchemeID = Payout.SchemeID
				And SchmCustItm.PayoutID = Payout.PayoutID
				And IsInvoiced = 1 And Claimed =1 
				Open OffTakeSKUCur
				Fetch Next From OffTakeSKUCur Into @CustomerID, @SKUCode, @InvoiceRef
				While @@Fetch_Status = 0
				Begin
					Set @MarginPTR = 0
					Select @MarginPTR = dbo.mERP_fn_GetMarginPTR(@SKUCode,Cast(@InvoiceRef as Int), @SchemeID)

					Insert Into #FreeInfo(InvoiceID, BillRef, OutletCode, SKUCode, RebateQty, RebateValue, SchemeOutlet, 
					SchemeSKU, SchemeID, PayoutID, PriceExclTax, TaxPercentage, TaxAmount, PriceInclTax,
					TaxCode, Flagword)

					Select IA.InvoiceID, @InvPrefix + Cast(IA.DocumentID as nVarchar) as BillRef, 
					IA.CustomerID, @SKUCode, Sum(Quantity),
					--Rebate Value
					Sum(Quantity) * (@MarginPTR + (Case @TaxConfigFlag When 1 Then (@MarginPTR * Max(TaxCode)/100) Else 0 End)),
					--Rebate Value
					1, 1, @SchemeID, @PayoutID, @MarginPTR, Max(ID.TaxCode), 
					(Sum(ID.Quantity) * (@MarginPTR * (Max(ID.TaxCode) / 100))), @MarginPTR + (@MarginPTR * (Max(ID.TaxCode) / 100)),
					Max(ID.TaxCode), 1
					From #TmpTSRInvAbs IA, #TmpTSRInvDtl ID 
					Where IA.InvoiceID = ID.InvoiceID
					And IA.InvoiceID = Cast(@InvoiceRef as Int)
					And IA.CustomerID = @CustomerID
					And ID.SchemeID = @SchemeID
					And ID.Product_Code = @SKUCode
					And IsNull(Flagword, 0) = 1
					Group By IA.InvoiceID, IA.DocumentID, IA.CustomerID, ID.Serial 

					Fetch Next From OffTakeSKUCur Into @CustomerID, @SKUCode, @InvoiceRef
				End
				Close OffTakeSKUCur
				Deallocate OffTakeSKUCur


				/* Update Division , Market sku ,And Sub Category */
				Update RFA Set Division = IC2.Category_Name, SubCategory = IC1.Category_Name, MarketSKU = IC.Category_Name, UOM = U.Description
				From #FreeInfo RFA,Items I , ItemCategories IC, ItemCategories IC1,ItemCategories IC2,UOM U
				Where RFA.SKUCode = I.Product_Code And
				I.CategoryID = IC.CategoryID And
				IC.ParentID = IC1.CategoryID And
				IC1.ParentID = IC2.CategoryID And
				I.UOM = U.UOM

			
				Select  @RebValForFreeItem = Sum(IsNull(RebateValue, 0)) ,@RebFreeQty  = Sum(isNull(RebateQty,0)) From #FreeInfo 

				if @RFAStatus = 1 
				Begin
					If @RebFreeQty > 0 /* Free Item Scheme */
					Begin
							Insert Into #tmpSchemeoutput(SchemeID, ActivityCode, Description, [Applicable Period], 
							[RFA Period], SaleQty, SaleValue, 
							PromotedQty, PromotedValue, RebateQty, RebateValue)
							Select Cast(@SchemeID as nVarchar(1000)) + '|'+ Cast(@PayoutID as nVarchar(1000)), @ActivityCode, @ActivityType, 
							Cast(Convert(Char(11), @ActiveFrom, 103) As nVarchar) + N'- ' + Cast(Convert(Char(11), @ActiveTo, 103) As nVarchar),
							Cast(Convert(Char(11), @PayoutFrom, 103) As nVarchar) + N'- ' + Cast(Convert(Char(11), @PayoutTo, 103) As nVarchar),
							Sum(qpsd.Quantity), Sum(qpsd.Quantity*qpsd.SalePrice), Sum(qpsd.Promoted_Qty), Sum(qpsd.Promoted_Val), 
							@RebFreeQty, @RebValForFreeItem
							From tbl_mERP_QPSDtlData qpsd, tbl_mERP_QPSAbsData qpsa  
							Where qpsa.SchemeID = @SchemeID 
							And qpsa.PayoutID = @PayoutID 
							And qpsd.SchemeID = qpsa.SchemeID 
							And qpsd.PayoutID = qpsa.PayoutID 
							And qpsd.CustomerID = qpsa.CustomerID
							And qpsd.Product_code = (Case When @ApplicableOn = 'ITEM' then Isnull(qpsa.Product_Code,'') Else qpsd.Product_code End)
							And qpsd.CustomerID In(Select OutletCode From #FreeInfo)
							And (qpsd.Rebate_Val > 0 OR qpsd.RFARebate_Val > 0 Or qpsd.Rebate_Qty > 0 or qpsa.SlabID > 0)
 					End
					Else
					Begin

						Insert Into #tmpSchemeoutput(SchemeID, ActivityCode, Description, [Applicable Period], 
								[RFA Period], SaleQty, SaleValue, 
								PromotedQty, PromotedValue, RebateQty, RebateValue)
							Select Cast(@SchemeID as nVarchar(1000)) + '|'+ Cast(@PayoutID as nVarchar(1000)), @ActivityCode, @ActivityType, 
							Cast(Convert(Char(11), @ActiveFrom, 103) As nVarchar) + N'- ' + Cast(Convert(Char(11), @ActiveTo, 103) As nVarchar),
							Cast(Convert(Char(11), @PayoutFrom, 103) As nVarchar) + N'- ' + Cast(Convert(Char(11), @PayoutTo, 103) As nVarchar),
							Sum(qpsd.Quantity), Sum(qpsd.Quantity*qpsd.SalePrice), Sum(qpsd.Promoted_Qty), Sum(qpsd.Promoted_Val), 
							0,
							--(Case @TaxConfigFlag When 1 Then Sum(qpsd.Rebate_Val) Else Sum(qpsd.RFARebate_Val) End )
							(Case @CrNoteFlag When 1 Then Sum(qpsd.Rebate_Val) Else Sum(qpsd.RFARebate_Val) End )
							From tbl_mERP_QPSDtlData qpsd, tbl_mERP_QPSAbsData qpsa  
							Where qpsa.SchemeID = @SchemeID 
							And qpsa.PayoutID = @PayoutID 
							And qpsd.SchemeID = qpsa.SchemeID 
							And qpsd.PayoutID = qpsa.PayoutID 
							And qpsd.CustomerID = qpsa.CustomerID
							And qpsd.Product_code = Case When @ApplicableOn = 'ITEM' then Isnull(qpsa.Product_Code,'') Else qpsd.Product_code End
							And (qpsd.Rebate_Val > 0 OR qpsd.RFARebate_Val > 0 Or qpsd.Rebate_Qty > 0 or qpsa.SlabID > 0)
					End
				End
				else -- RFANonapplicable
				Begin
					If @RebFreeQty > 0 /* Free Item Scheme */
					Begin
							Insert Into #tmpSchemeoutput(SchemeID, ActivityCode, Description, [Applicable Period], 
							[RFA Period], SaleQty, SaleValue, 
							PromotedQty, PromotedValue, RebateQty, RebateValue)
							Select Cast(@SchemeID as nVarchar(1000)) + '|'+ Cast(@PayoutID as nVarchar(1000)), @ActivityCode, @ActivityType, 
							Cast(Convert(Char(11), @ActiveFrom, 103) As nVarchar) + N'- ' + Cast(Convert(Char(11), @ActiveTo, 103) As nVarchar),
							Cast(Convert(Char(11), @PayoutFrom, 103) As nVarchar) + N'- ' + Cast(Convert(Char(11), @PayoutTo, 103) As nVarchar),
							Sum(qpsd.Quantity), Sum(qpsd.Quantity*qpsd.SalePrice), Sum(qpsd.Promoted_Qty), Sum(qpsd.Promoted_Val), 
							@RebFreeQty, @RebValForFreeItem
							From tbl_mERP_QPSDtlData qpsd, tbl_mERP_QPSAbsData qpsa  
							Where qpsa.SchemeID = @SchemeID 
							And qpsa.PayoutID in( select id from tbl_merp_schemePayoutperiod where schemeid=@schemeid and Payoutperiodto between @fromdate and @todate)
							And qpsd.SchemeID = qpsa.SchemeID 
							And qpsd.PayoutID in( select id from tbl_merp_schemePayoutperiod where schemeid=@schemeid and Payoutperiodto between @fromdate and @todate)
							And qpsd.CustomerID = qpsa.CustomerID
							And qpsd.Product_code = (Case When @ApplicableOn = 'ITEM' then Isnull(qpsa.Product_Code,'') Else qpsd.Product_code End)
							And qpsd.CustomerID In(Select OutletCode From #FreeInfo)
							And (qpsd.Rebate_Val > 0 OR qpsd.RFARebate_Val > 0 Or qpsd.Rebate_Qty > 0 or qpsa.SlabID > 0)
 					End
					Else
					Begin

						Insert Into #tmpSchemeoutput(SchemeID, ActivityCode, Description, [Applicable Period], 
								[RFA Period], SaleQty, SaleValue, 
								PromotedQty, PromotedValue, RebateQty, RebateValue)
							Select Cast(@SchemeID as nVarchar(1000)) + '|'+ Cast(@PayoutID as nVarchar(1000)), @ActivityCode, @ActivityType, 
							Cast(Convert(Char(11), @ActiveFrom, 103) As nVarchar) + N'- ' + Cast(Convert(Char(11), @ActiveTo, 103) As nVarchar),
							Cast(Convert(Char(11), @PayoutFrom, 103) As nVarchar) + N'- ' + Cast(Convert(Char(11), @PayoutTo, 103) As nVarchar),
							Sum(qpsd.Quantity), Sum(qpsd.Quantity*qpsd.SalePrice), Sum(qpsd.Promoted_Qty), Sum(qpsd.Promoted_Val), 
							0,
							--(Case @TaxConfigFlag When 1 Then Sum(qpsd.Rebate_Val) Else Sum(qpsd.RFARebate_Val) End )
							(Case @CrNoteFlag When 1 Then Sum(qpsd.Rebate_Val) Else Sum(qpsd.RFARebate_Val) End )
							From tbl_mERP_QPSDtlData qpsd, tbl_mERP_QPSAbsData qpsa  
							Where qpsa.SchemeID = @SchemeID 
							And qpsa.PayoutID in( select id from tbl_merp_schemePayoutperiod where schemeid=@schemeid and Payoutperiodto between @fromdate and @todate)
							And qpsd.SchemeID = qpsa.SchemeID 
							And qpsd.PayoutID in( select id from tbl_merp_schemePayoutperiod where schemeid=@schemeid and Payoutperiodto between @fromdate and @todate)
							And qpsd.CustomerID = qpsa.CustomerID
							And qpsd.Product_code = Case When @ApplicableOn = 'ITEM' then Isnull(qpsa.Product_Code,'') Else qpsd.Product_code End
							And (qpsd.Rebate_Val > 0 OR qpsd.RFARebate_Val > 0 Or qpsd.Rebate_Qty > 0 or qpsa.SlabID > 0)
					End
				End
				Set @RebValForFreeItem = 0
				Set @RebFreeQty = 0 


				/* In case of free item scheme only free item adjusted customer's invoice details has to be considered */
				IF  @Free = 1
				Begin
					if (@RFAStatus = 1)
						Insert Into #tmpSKU
						Select Distinct Product_Code From tbl_mERP_QPSDtlData Where SchemeID = @SchemeID and PayoutID = @PayoutID
						--And (Rebate_Val > 0 OR RFARebate_Val > 0 Or Rebate_Qty > 0) 
						And CustomerID In(Select OutletCode From #FreeInfo)
					else
						Insert Into #tmpSKU
						Select Distinct Product_Code From tbl_mERP_QPSDtlData Where SchemeID = @SchemeID and PayoutID in( select id from tbl_merp_schemePayoutperiod where schemeid=@schemeid and Payoutperiodto between @fromdate and @todate)
						--And (Rebate_Val > 0 OR RFARebate_Val > 0 Or Rebate_Qty > 0) 
						And CustomerID In(Select OutletCode From #FreeInfo)
				End
				Else
				Begin
					if (@RFAStatus = 1 )
						Insert Into #tmpSKU
						Select Distinct Product_Code From tbl_mERP_QPSDtlData Where SchemeID = @SchemeID and PayoutID = @PayoutID
						--And (Rebate_Val > 0 OR RFARebate_Val > 0 Or Rebate_Qty > 0) 
					else
						Insert Into #tmpSKU
						Select Distinct Product_Code From tbl_mERP_QPSDtlData Where SchemeID = @SchemeID and Payoutid in( select id from tbl_merp_schemePayoutperiod where schemeid=@schemeid and Payoutperiodto between @fromdate and @todate)
						--And (Rebate_Val > 0 OR RFARebate_Val > 0 Or Rebate_Qty > 0) 
					
				End

				Delete From #tmpSchemeoutput Where  IsNull(RebateQty, 0) = 0 And IsNull(RebateValue, 0) = 0 
				and SubmissionDate Is Null

		
			End
		End
	
		NextScheme:	

		If Exists (Select Top 1 * from #tmpSKUWiseSales) 
		Begin
			Update #tmpSchemeoutput Set 
			SaleQty = (Select Sum(SalesQty) From #tmpSKUWiseSales Where SKUCode In(Select Distinct SkuCode From #tmpSKU))
			,SaleValue = (Select Sum(SalesValue) From #tmpSKUWiseSales Where SKUCode In(Select Distinct SkuCode From #tmpSKU))
			Where ActivityCode = @ActivityCode And [RFA Period] = @PayoutPeriod 	
		End
		NextScheme1:
		Set @Counter =  @Counter + 1
		Delete #tmpSKUWiseSales
		Truncate Table #RFAInfo
		Delete #tmpPayout
		Delete #tmpSKU
	End /* Loop For Schemes */



	Select "Schemeid" = Schemeid, "ActivityCode" = ActivityCode , "Description" = Description, 
	"Applicable Period" = [Applicable Period], "RFA Period" = [RFA Period],
	"SaleQty" = Max(IsNull(SaleQty, 0)), "SaleValue" = Max(IsNull(SaleValue, 0)), 
	"PromotedQty" = Sum(IsNull(PromotedQty, 0)), "PromotedValue" = Sum(IsNull(PromotedValue, 0)), 
	"RebateQty" = Sum(IsNull(RebateQty, 0)), "RebateValue" = Sum(IsNull(RebateValue, 0)),
	"SubmissionDate" = SubmissionDate  Into #tmpFinal 
	From #tmpSchemeoutput 
    Group By Schemeid, ActivityCode , Description , [Applicable Period], [RFA Period], SubmissionDate
	Order By Description

	Delete #tmpTotSales
	Insert  Into #tmpTotSales
	Select ActivityCode,[RFA Period],Max(SaleQty),Max(SaleValue)
	From #tmpSchemeoutput
	Group By ActivityCode,[RFA Period]

	/* To Insert Grand Total Row */
	Insert Into #tmpFinal(SchemeID,ActivityCode,SaleQty,SaleValue,PromotedQty,
			    		  PromotedValue,RebateQty,RebateValue)
	Select '-1|-1',@GRNTOTAL , 
		(Select Sum(TotQty) From #tmpTotSales),
		(Select Sum(TotValue) From #tmpTotSales),
			Sum(PromotedQty),
			Sum(PromotedValue),Sum(RebateQty),Sum(RebateValue)
			From #tmpSchemeoutput

	/* To update Null For Zero Value Rows */
	Update #tmpFinal Set 
	SaleQty =  (Case  isNull(SaleQty,0) When 0 Then NULL Else SaleQty End),
	SaleValue = (Case  isNull(SaleValue,0) When 0 Then NULL Else SaleValue End),
	PromotedQty = (Case  isNull(PromotedQty,0) When 0 Then NULL Else PromotedQty End) ,
	PromotedValue = (Case  isNull(PromotedValue,0) When 0 Then NULL Else PromotedValue End),
	RebateQty = (Case  isNull(RebateQty,0) When 0 Then NULL Else RebateQty End),
	RebateValue = (Case  isNull(RebateValue,0) When 0 Then NULL Else RebateValue End)

	Select * From #tmpFinal Where ActivityCode <> @GRNTOTAL 
	Union ALL
	Select * From #tmpFinal Where ActivityCode = @GRNTOTAL
	
	Drop Table #RFAInfo
	Drop Table #tmpFinal
	Drop Table #TmpTSRInvAbs
	Drop Table #TmpTSRInvDtl
	Drop Table #tmpSchemeoutput
	Drop Table #tmpSKUWiseSales
	Drop Table #tmpSubRFAInfo1
	Drop Table #FreeInfo
	Drop Table #tmpPayout
	Drop Table #tmpSKU
	Drop Table #tmpTotSales
	Drop Table #tmpLesGrtDate
	Drop Table #tmpSales

End /*Procedure End */	
