Create Procedure mERP_spr_TradeScheme_Detail 
(
 @SchemeDet nVarchar(255),
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
	Declare @CrdtNoteVal Decimal(18,6)
	Declare @InvSRID Int 
	Declare @TaxConfigFlag Int 
	Declare @MarginPTR Decimal(18,6)
	Declare @QPS Int
	Declare @ItemFree Int 
	Declare @Type nVarchar(50)
	Declare @IsRFAClaimed nVarchar(5)
	Declare @SalQty Decimal(18,6)
	Declare @SalValue Decimal(18,6)
	Declare @SRSalQty Decimal(18,6)
	Declare @SRSalValue Decimal(18,6)
	
	Declare @LesserDate DateTime
    Declare @GreaterDate DateTime

	Declare @SUBTOTAL nVarchar(50)    
	Declare @GRNTOTAL nVarchar(50)    
	Declare @QPSCRDTNOTE nVarchar(50)    
  
	Set @IsRFAClaimed = dbo.LookupDictionaryItem(N'No', Default)

	Set @SUBTOTAL = dbo.LookupDictionaryItem(N'Sub Total:', Default)     
	Set @GRNTOTAL = dbo.LookupDictionaryItem(N'Grand Total:', Default)     
	Set @QPSCRDTNOTE = dbo.LookupDictionaryItem(N'QPS Credit Note', Default)     
	
	Declare @Delimeter nVarchar(1)
	Set @Delimeter = Char(15) 

	Set @ToDate = dbo.StripTimeFromDate(@ToDate)
	Set @FromDate = dbo.StripTimeFromDate(@FromDate)

    Declare @SkipSRInvScheme as table (SchemeID Int, InvoiceID Int, PayoutFrom DateTime, PayoutTo DateTime)

	Create Table #RFAInfo(SR Int Identity , InvoiceID Int, BillRef nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, OutletCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							RCSID nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, ActiveInRCS nVarchar(100) collate SQL_Latin1_General_CP1_CI_AS, LineType nVarchar(50), Division nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS ,
							SubCategory nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, MarketSKU nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							UOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, SaleQty Decimal(18, 6), SaleValue Decimal(18, 6),
							PromotedQty Decimal(18, 6), PromotedValue Decimal(18, 6), FreeBaseUOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							RebateQty Decimal(18, 6), RebateValue Decimal(18, 6), PriceExclTax Decimal(18, 6),
							TaxPercentage Decimal(18,6), TaxAmount Decimal(18, 6), PriceInclTax Decimal(18, 6),
							SchemeDetail nVarchar(1000), Serial Int, Flagword Int, Amount Decimal(18, 6),
							SchemeID Int, SlabID Int, PTR Decimal(18,6), TaxCode Decimal(18,6), BudgetedValue Decimal(18,6), 
							FreeSKUSerial Int,SalePrice Decimal(18,6),  UOM1Conv Decimal(18,6), UOM2Conv Decimal(18,6),
							InvoiceType Int, SchemeOutlet Int, SchemeSKU Int Default(0), SchemeGroup Int, TotalPoints Decimal(18,6), 
							PointsValue Decimal(18,6), ReferenceNumber nVarchar(50) collate SQL_Latin1_General_CP1_CI_AS
							, RFASubmissionDate Datetime )

	Create Table #tmpSchemeoutput(Division nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS ,
								  [Code] nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
								  [Name] nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, 
								  UOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
								  [Type] nVarchar(100) collate SQL_Latin1_General_CP1_CI_AS,
								  SaleQty Decimal(18, 6), SaleValue Decimal(18, 6),
								  PromotedQty Decimal(18, 6), PromotedValue Decimal(18, 6), 
								  TaxPercentage Decimal(18,6), TaxAmount Decimal(18, 6),
								  RebateQty Decimal(18, 6), RebateValue Decimal(18, 6)
								 )

	Create Table #tmpAllSchemeoutput(Division nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS ,
								  [Code] nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
								  [Name] nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, 
								  UOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
								  [Type] nVarchar(100) collate SQL_Latin1_General_CP1_CI_AS,
								  SaleQty Decimal(18, 6), SaleValue Decimal(18, 6),
								  PromotedQty Decimal(18, 6), PromotedValue Decimal(18, 6), 
								  TaxPercentage Decimal(18,6), TaxAmount Decimal(18, 6),
								  RebateQty Decimal(18, 6), RebateValue Decimal(18, 6)
								 )

	Create Table #tmpFinal(Division nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS ,
								  [Code] nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
								  [Name] nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, 
								  UOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
								  [Type] nVarchar(100) collate SQL_Latin1_General_CP1_CI_AS,
								  SaleQty Decimal(18, 6), SaleValue Decimal(18, 6),
								  PromotedQty Decimal(18, 6), PromotedValue Decimal(18, 6), 
								  TaxPercentage Decimal(18,6), TaxAmount Decimal(18, 6),
								  RebateQty Decimal(18, 6), RebateValue Decimal(18, 6)
								 )
									
	Create Table #FreeInfo(InvoiceID Int, BillRef nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, 
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

	Create Table #tmpPayout(SchemeID Int,PayoutID Int)

	Create Table #tmpCustomerID(CustomerID nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS)

	Create Table #tmpSKUWiseSales(SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
					Division nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS ,
					SubCategory nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, 
					MarketSKU nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, 
					SalesQty Decimal(18,6),SalesValue Decimal(18,6), TaxCode Decimal(18, 6), 
					UOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS) 

	Create Table #tmpSRSKUWiseSales(SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
					Division nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS ,
					SubCategory nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, 
					MarketSKU nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, 
					SalesQty Decimal(18,6),SalesValue Decimal(18,6), ReturnType Int, TaxCode Decimal(18, 6), 
					UOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS) 

	Create Table #tmpSKUWiseSales_2(SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
					Division nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS ,
					SubCategory nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, 
					MarketSKU nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, 
					SalesQty Decimal(18,6),SalesValue Decimal(18,6), TaxCode Decimal(18, 6), 
					UOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS) 

	Create Table #tmpSRSKUWiseSales_2(SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
					Division nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS ,
					SubCategory nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, 
					MarketSKU nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, 
					SalesQty Decimal(18,6),SalesValue Decimal(18,6), ReturnType Int, TaxCode Decimal(18, 6), 
					UOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS) 

	Create Table #tmpSKU(skucode nvarchar(255) collate SQL_Latin1_General_CP1_CI_AS)

	Create Table #tmpLesGrtDate(SchemeID Int, PADateFrom Datetime, PADateTo Datetime)

	/* Table Used to store the Total Sales qty and Volume SKUWise Starts */
	Create Table #tmpSales(SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						   SaleQty Decimal(18,6),SaleValue Decimal(18,6),
							Flagword Int,InvoiceType Int, ReturnType Int, TaxCode Decimal(18, 6))

	--To hold the lastinventoryuploaddate with the format.
	Declare @LastInventoryuploadDate datetime
	Select @LastInventoryuploadDate  = convert(nvarchar(10),lastinventoryupload,103) from Setup

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
	
	If @RFAStatus = 'Yes'
		Set @RFAStatus = 1
	Else
		Set @RFAStatus = 0

	If @Product_Hierarchy = '%' Or @Product_Hierarchy = 'Division'
		Set @Product_Hierarchy = N'Division'
	If @Product_Hierarchy = 'Sub-Category' or @Product_Hierarchy = 'Sub Category' or @Product_Hierarchy = 'Sub_Cat'
		Set @Product_Hierarchy = N'Sub_Category'
	If @Product_Hierarchy = 'MarketSKU' or @Product_Hierarchy = 'Market-SKU' or  @Product_Hierarchy = 'Market SKU'
		Set @Product_Hierarchy = N'Market_SKU' 
	If @Product_Hierarchy = 'System_SKU' or @Product_Hierarchy = 'System-SKU' or @Product_Hierarchy = 'SystemSKU'
		set @Product_Hierarchy = 'System SKU' 

	Select @SchemeID = Substring(@SchemeDet,1,CharIndex('|',@SchemeDet)-1)
	
	/* To chk whether the passed scheme is valid */	
	If @SchemeID <=0 
	GoTo OverNOut
	
	Select @szPayoutID = Substring(@SchemeDet,CharIndex('|',@SchemeDet)+1,Len(@SchemeDet))
	
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
		@ItemGroup = Itemgroup,
		@PayoutID =  SPP.ID
		From tbl_mERP_SchemeAbstract SA,  tbl_mERP_SchemePayoutPeriod SPP
		Where SA.SchemeID = @SchemeID
		And SA.SchemeID = SPP.SchemeID
		And SPP.PayoutPeriodTo Between @FromDate And @ToDate
		And SPP.ID = Cast(@szPayoutID as Int)
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
			
	Insert Into #tmpLesGrtDate Values (@SchemeID, @ActiveFrom, @ActiveTo)
	Insert Into #tmpLesGrtDate Values (@SchemeID, @PayoutFrom, @PayoutTo) 
	Insert Into #tmpLesGrtDate 	
	Select @SchemeID, Min(InvoiceDate), Max(InvoiceDate) from InvoiceAbstract where InvoiceID In 
	(Select IsNull(InvoiceRef,'') from SChemeCustomerItems where SchemeID = @SchemeID and payoutid = @payoutID 
	and IsNull(Claimed,0) = 1 and isNull(IsInvoiced,0) = 1 and IsNull(InvoiceRef,'') <> '' and IsNull(InvoiceRef,'') Not Like '%,%' )
	and IsNull(Status,0) & 128 = 0

	Insert Into #tmpLesGrtDate 
	Select @SchemeID, Min(InvoiceDate), Max(InvoiceDate) from InvoiceAbstract IA where 
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
		

	Select @LesserDate = dbo.StripTimeFromDate(Min(PADateFrom)) From #tmpLesGrtDate 
	Select @GreaterDate = dbo.StripTimeFromDate(Max(PADateTo)) From #tmpLesGrtDate 


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
		SET @sql =  @sql + ' And dbo.StripTimeFromDate(InvoiceDate) <= ''' + cast(@LastInventoryuploadDate as Varchar) + ''''

	Exec Sp_ExecuteSQL @Sql
	SET IDENTITY_INSERT dbo.#TmpTSRInvAbs OFF


	Select * Into #TmpTSRInvDtl From InvoiceDetail 
	Where InvoiceID In (Select InvoiceID From #TmpTSRInvAbs)
	--=============================================================

	If  @RFAStatus  = 1 
		Insert Into #tmpPayout
		Select @SchemeID,@szPayoutID
	Else		
		Insert Into #tmpPayout
		Select @SchemeID,* From dbo.sp_SplitIn2Rows(@szPayoutID,',')

	Truncate Table #tmpSales

	Insert Into #tmpSales
	Select 	ID.Product_Code as SKUCode, 
		Case ID.FlagWord
			When 0 Then Sum(ID.Quantity) 
			Else 0 End	as SaleQty,
		Case ID.FlagWord
			When 0 Then Sum(ID.SalePrice * ID.Quantity) 
			Else 0 End	as SaleValue,
		ID.FlagWord,
		IA.InvoiceType, 
		Case IA.InvoiceType When 4 Then (Case When (IA.Status & 32) = 0 Then 1 Else 2 End) Else 0 End,
		Max(ID.TaxCode)
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
				End) Between @PayoutFrom And @PayoutTo
	Group By ID.Product_Code, ID.FlagWord, ID.Serial, IA.InvoiceType, IA.Status, ID.InvoiceID
		
	-- Total Quantity and Total Sales Change
	/* To Insert ProductWise Sales From And To PayoutPeriod */
	Truncate table #tmpSKUWiseSales
	Insert Into #tmpSKUWiseSales(SKUCode,SalesQty,SalesValue, TaxCode)
	Select SKUCode,Sum(Case InvoiceType When 4 Then -1 * SaleQty Else SaleQty End),
	Sum(Case InvoiceType When 4 Then -1 * SaleValue Else SaleValue End), 
	TaxCode 
	From #tmpSales 
	Where FlagWord = 0 And
	InvoiceType <> 4
	Group By SKUCode, TaxCode 

	/* Total sales for Sales SalesReturn*/
	Truncate table #tmpSRSKUWiseSales
	Insert Into #tmpSRSKUWiseSales(SKUCode,SalesQty,SalesValue, ReturnType, TaxCode)
	Select SKUCode,Sum(Case InvoiceType When 4 Then -1 * SaleQty Else SaleQty End),
	Sum(Case InvoiceType When 4 Then -1 * SaleValue Else SaleValue End), ReturnType, 
	TaxCode 
	From #tmpSales 
	Where FlagWord = 0 And
	InvoiceType = 4
	Group By SKUCode, ReturnType, TaxCode 

	Update RFA Set Division = IC2.Category_Name, SubCategory = IC1.Category_Name, MarketSKU = IC.Category_Name, 
	UOM = U.Description 
	From #tmpSKUWiseSales RFA,Items I , ItemCategories IC, ItemCategories IC1,ItemCategories IC2, 
	UOM U 
	Where RFA.SKUCode = I.Product_Code And
	I.CategoryID = IC.CategoryID And
	IC.ParentID = IC1.CategoryID And
	IC1.ParentID = IC2.CategoryID And 
	I.UOM = U.UOM 
	
	Update RFA Set Division = IC2.Category_Name, SubCategory = IC1.Category_Name, MarketSKU = IC.Category_Name, 
	UOM = U.Description 
	From #tmpSRSKUWiseSales RFA,Items I , ItemCategories IC, ItemCategories IC1,ItemCategories IC2, 
	UOM U 
	Where RFA.SKUCode = I.Product_Code And
	I.CategoryID = IC.CategoryID And
	IC.ParentID = IC1.CategoryID And
	IC1.ParentID = IC2.CategoryID And 
	I.UOM = U.UOM 

	/*  Table Used to store the Total Sales qty and Volume SKUWise Ends*/

	/* ForFor schemes which are already submitted take it directly from RFAAbstract & RFADetail table */
	If  @RFAStatus  = 1
	Begin
		If (Select Count(*) From tbl_mERP_SchemePayoutPeriod Where SchemeID = @SchemeID And ID = @PayoutID And ClaimRFA = 1 ) >= 1 
		Begin	
			If (Select Count(*) From tbl_mERP_RFAAbstract Where DocumentID = @SchemeID And PayOutFrom = @PayoutFrom And PayOutTo = @PayoutTo And isNull(Status,0) <> 5) >= 1 
			Begin
					Truncate Table #tmpSchemeoutput
					Set @IsRFAClaimed = dbo.LookupDictionaryItem(N'Yes', Default)

					Insert Into #RFAInfo(SchemeID, Division,SubCategory,MarketSKU,SKUCode,UOM,LineType,SaleQty,SaleValue,
								PromotedQty , PromotedValue , TaxCode,TaxAmount,RebateQty,RebateValue)
					Select @SchemeID, RD.Division ,RD.SubCategory,RD.MarketSKU,RD.SystemSKU,RD.UOM, 
						   Case LineType When N'QPS' Then N'MAIN' Else LineType End,RD.SaleQty,RD.SaleValue,
						   RD.PromotedQty,RD.PromotedValue, isNull(RD.Tax_Percentage,0),
						   (Case LineType When N'MAIN' Then (Case Isnull(RD.TOQ,0) When 0 Then (RD.PromotedValue * isNull(RD.Tax_Percentage,0)/100 ) Else ( RD.PromotedQty * isNull(RD.Tax_Percentage,0)) End)
										  When N'Sales Return - Damaged' Then (Case Isnull(RD.TOQ,0) When 0 Then (RD.PromotedValue * isNull(RD.Tax_Percentage,0)/100 ) Else ( RD.PromotedQty * isNull(RD.Tax_Percentage,0)) End)
										  When N'Sales Return - Saleable' Then (Case Isnull(RD.TOQ,0) When 0 Then (RD.PromotedValue * isNull(RD.Tax_Percentage,0)/100 ) Else ( RD.PromotedQty * isNull(RD.Tax_Percentage,0)) End)
										  When N'QPS' Then (Case Isnull(RD.TOQ,0) When 0 Then (RD.PromotedValue * isNull(RD.Tax_Percentage,0)/100 ) Else ( RD.PromotedQty * isNull(RD.Tax_Percentage,0)) End) Else RD.Tax_Amount End),
							RD.RebateQty,RD.RebateValue
					From   tbl_mERP_RFAAbstract RA,tbl_mERP_RFADetail RD --,ItemCategories IC
					Where RA.DocumentID = @SchemeID And isNull(Status,0) <> 5 And PayOutFrom = @PayoutFrom And PayOutTo = @PayoutTo 
					And RA.RFAID = RD.RFAID And isNull(RD.BillRef,'') <> '' 
					--And IC.Category_Name = RD.MarketSKU 
								
					/* To Insert Credit Note Records */
					Set @CrdtNoteVal = 0 
					Select @CrdtNoteVal = Sum(RD.RebateValue) From tbl_mERP_RFAAbstract RA,tbl_mERP_RFADetail RD 
					Where RA.DocumentID = @SchemeID And PayOutFrom = @PayoutFrom And PayOutTo = @PayoutTo 
					And RA.RFAID = RD.RFAID And isNull(Status,0) <> 5 
					And isNull(BillRef,'') =  '' And isNull(RD.SystemSKU,'') = ''
										
		
					GoTo OverNOut
			End
		End
	End 

	Set @QPS = -1 

	Select @QPS = Max(IsNull(QPS, 0)) From tbl_mERP_SchemeOutlet 
	Where SchemeID = @SchemeID
		And IsNull(QPS, 0) = 0 


	  /*To remove the SR Entries having Value greater than Sales Value*/
		Declare @tmpInvoiceID int
		Declare SRCursor Cursor For
		Select InvoiceID, Sum(RebateValue) from tbl_merp_NonQPSData Where InvoiceType = 4 and SchemeID = @SchemeID  and OriginalInvDate Between @PayoutFrom And @PayoutTo Group By InvoiceID
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
					Set @tmpInvoiceID = ( Select Top 1 InvoiceId from InvoiceAbstract where Status & 128 = 0 and DocumentId= (Select ReferenceNumber from InvoiceAbstract where invoicetype=4 and Invoiceid = @InvoiceID and isnull(referencenumber,'') <> ''  ) order by invoiceid desc) 
			End
			Else
			Begin
				Set  @tmpInvoiceID = (Select Top 1 InvoiceId from InvoiceAbstract where Status & 128 = 0 and GSTFullDocID = @GSTFullDocID Order by InvoiceID Desc)
			End					
			--Check if original invoice exist in that period.
			if Isnull(@tmpInvoiceid,0) <> 0
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
        /*End of removing the SR Entries having Value greater than Sales Value*/


	If @QPS = 0
	Begin 
		If @ApplicableOn = 'ITEM' Or @ApplicableOn = 'SPL_CAT'
		Begin/*Trade - Item based schemes - Start*/ 
				/*Select scheme products*/

	Insert InTo #RFAInfo (LineType, Division, SubCategory, MarketSKU, SKUCode, UOM, SaleQty, SaleValue, 
				PromotedQty, PromotedValue,  RebateQty , RebateValue, TaxAmount, FlagWord, SchemeID, TaxCode)
			Select Case [Type] When 0 Then 'MAIN' When 1 Then 'Free' When 2 Then 'Sales Return - Saleable' 
					When 3 Then 'Sales Return - Damaged' End, 
				'', '', '', Product_Code, '', 
				IsNull(SaleQty, 0), IsNull(SaleValue, 0), IsNull(PromotedQty, 0), 
				IsNull(PromotedValue, 0), 
				dbo.mERP_fn_ToGetRebateVal_ITC(IsNull(RebateQty, 0), [Type], SlabID), 
				Case @TaxConfigFlag When 1 Then 
					dbo.mERP_fn_ToGetRebateVal_ITC(IsNull(RebateValue_Tax, 0), [Type], SlabID)
				Else
					dbo.mERP_fn_ToGetRebateVal_ITC(IsNull(RebateValue, 0), [Type], SlabID)
				End, 
				--IsNull(TaxAmount, 0), 

                IsNull((Case  When InvoiceType = 4 and ([Type] = 0 Or [Type] = 2 Or [Type] = 3) Then (Case (IsNull(TOQ,0)) When 0 Then (PromotedValue * isNull(TaxPercent,0)/100 ) Else (IsNull(PromotedQty, 0) * isNull(TaxPercent,0)) End )
                                  When InvoiceType = 1  and ([Type] = 0 Or [Type] = 2) Then (Case (Isnull(TOQ,0)) When 0 then (PromotedValue * isNull(TaxPercent,0)/100 ) Else (IsNull(PromotedQty, 0) * isNull(TaxPercent,0)) End )
                               When InvoiceType = 3 and ([Type] = 0 Or [Type] = 2) Then (Case (Isnull(TOQ,0)) When 0 Then  (PromotedValue * isNull(TaxPercent,0)/100 ) Else (IsNull(PromotedQty, 0) * isNull(TaxPercent,0)) End )
                 Else TaxAmount End),0) as TaxAmount,

				Case [Type] When 1 Then 1 Else 0 End, SchemeID, TaxPercent 
			From tbl_merp_NonQPSData 
			Where SchemeID = @SchemeID And 
				OriginalInvDate Between @ActiveFrom And @ActiveTo And 
				OriginalInvDate Between @PayoutFrom And @PayoutTo And 
				InvoiceID Not in (Select Distinct InvoiceID From @SkipSRInvScheme Where SchemeID = @SchemeID And PayoutFrom = @PayoutFrom And PayoutTo = @PayoutTo)



			Update RFA Set Division = IC2.Category_Name, SubCategory = IC1.Category_Name, 
				MarketSKU = IC.Category_Name, UOM = U.Description
			From #RFAInfo RFA,Items I , ItemCategories IC, ItemCategories IC1,ItemCategories IC2,UOM U
			Where RFA.SKUCode = I.Product_Code And
				I.CategoryID = IC.CategoryID And
				IC.ParentID = IC1.CategoryID And
				IC1.ParentID = IC2.CategoryID And
				I.UOM = U.UOM

			--Delete From #RFAInfo Where IsNull(RebateQty, 0) = 0 And IsNull(RebateValue, 0) = 0 

			GoTo OverNOut 
		End/*Trade - Item based schemes - End*/ 
		Else If @ApplicableOn = 'INVOICE'
		Begin
			Insert InTo #RFAInfo (LineType, Division, SubCategory, MarketSKU, SKUCode, UOM, SaleQty, SaleValue, 
				PromotedQty, PromotedValue,  RebateQty , RebateValue, TaxAmount, FlagWord, SchemeID, TaxCode)
			Select Case [Type] When 0 Then 'MAIN' When 1 Then 'Free' When 2 Then 'Sales Return - Saleable' 
					When 3 Then  'Sales Return - Damaged' End, 
				'', '', '', Product_Code, '', 
				IsNull(SaleQty, 0), IsNull(SaleValue, 0), IsNull(PromotedQty, 0), 
				IsNull(PromotedValue, 0), 
				dbo.mERP_fn_ToGetRebateVal_ITC(IsNull(RebateQty, 0), [Type], SlabID), 
				Case @TaxConfigFlag When 1 Then 
					dbo.mERP_fn_ToGetRebateVal_ITC(IsNull(RebateValue_Tax, 0), [Type], SlabID) 
				Else
					dbo.mERP_fn_ToGetRebateVal_ITC(IsNull(RebateValue, 0), [Type], SlabID) 
				End, 
				IsNull(TaxAmount, 0), 
				Case [Type] When 1 Then 1 Else 0 End, SchemeID, TaxPercent 
			From tbl_merp_NonQPSData 
			Where SchemeID = @SchemeID And 
				OriginalInvDate Between @ActiveFrom And @ActiveTo And 
				OriginalInvDate Between @PayoutFrom And @PayoutTo And 
				InvoiceID Not in (Select Distinct InvoiceID From @SkipSRInvScheme Where SchemeID = @SchemeID And PayoutFrom = @PayoutFrom And PayoutTo = @PayoutTo)

			Update RFA Set Division = IC2.Category_Name, SubCategory = IC1.Category_Name, 
				MarketSKU = IC.Category_Name, UOM = U.Description
			From #RFAInfo RFA,Items I , ItemCategories IC, ItemCategories IC1,ItemCategories IC2,UOM U
			Where RFA.SKUCode = I.Product_Code And
				I.CategoryID = IC.CategoryID And
				IC.ParentID = IC1.CategoryID And
				IC1.ParentID = IC2.CategoryID And
				I.UOM = U.UOM

			--Delete From #RFAInfo Where IsNull(RebateQty, 0) = 0 And IsNull(RebateValue, 0) = 0 

			GoTo OverNOut 
		End	/*Trade - Invoice based schemes - End*/ 

		OverNOut:

		Insert Into #tmpSKU
		Select Distinct SKUCode From #RFAInfo
		Where IsNull(FlagWord, 0) = 0 
		And SchemeID = @SchemeID

		If @ApplicableOn = 'Invoice' And ((Select Count(*) From #RFAInfo Where (FlagWord = 1 or IsNull(RebateQty, 0)  > 0) And SchemeID = @SchemeID) <= 0)
		Begin
			If (select count(*) from #RFAInfo Where SchemeID = @SchemeID) > 0
			Begin
				Insert Into #tmpSchemeoutput
				Select '' ,'','','','',NULL,NULL,
					   NULL,NULL,NULL,NULL,
					   NULL,Sum(RFA.RebateValue)
				From   #RFAInfo RFA
				Where RFA.SchemeID = @SchemeID
			End
		End
		Else
		Begin
			If @Product_Hierarchy = 'System SKU'
			Begin
				
				Insert Into #tmpSchemeoutput
				Select RFA.Division ,RFA.SKUCode,I.ProductName,RFA.UOM,LineType,Sum(RFA.SaleQty),Sum(RFA.SaleValue),
					   Sum(RFA.PromotedQty),Sum(RFA.PromotedValue),isNull(RFA.TaxCode,0),Sum(RFA.TaxAmount),
					   Sum(RFA.RebateQty),Sum(RFA.RebateValue)
				From   #RFAInfo RFA
				Left Outer Join Items I On RFA.SKUCode = I.Product_Code  
				Where  RFA.SchemeID = @SchemeID
				Group By RFA.Division ,RFA.SKUCode,I.ProductName,RFA.UOM,LineType,TaxCode
				Order By RFA.Division,LineType Desc,I.ProductName

			End
			Else IF @Product_Hierarchy = 'Market_SKU'
			Begin

				Insert Into #tmpSchemeoutput
				Select RFA.Division ,IC.CategoryID,RFA.MarketSKU,RFA.UOM,LineType,Sum(RFA.SaleQty),Sum(RFA.SaleValue),
					   Sum(RFA.PromotedQty),Sum(RFA.PromotedValue),isNull(RFA.TaxCode,0),Sum(RFA.TaxAmount),
					   Sum(RFA.RebateQty),Sum(RFA.RebateValue)
				From   #RFAInfo RFA
				Left Outer Join ItemCategories IC On RFA.MarketSKU = IC.Category_Name   
				Where  
				RFA.SchemeID = @SchemeID
				Group By RFA.Division ,RFA.MarketSKU,IC.CategoryID,RFA.UOM,LineType,TaxCode
				Order By RFA.Division,LineType Desc,RFA.MarketSKU
			End
			Else IF @Product_Hierarchy = 'Sub_Category'
			Begin

				Insert Into #tmpSchemeoutput
				Select RFA.Division ,IC.CategoryID,RFA.SubCategory,RFA.UOM,LineType,Sum(RFA.SaleQty),Sum(RFA.SaleValue),
					   Sum(RFA.PromotedQty),Sum(RFA.PromotedValue),isNull(RFA.TaxCode,0),Sum(RFA.TaxAmount),
					   Sum(RFA.RebateQty),Sum(RFA.RebateValue)
				From   #RFAInfo RFA
				Left Outer Join ItemCategories IC On RFA.SubCategory = IC.Category_Name  
				Where  
				RFA.SchemeID = @SchemeID
				Group By RFA.Division ,RFA.SubCategory,IC.CategoryID,RFA.UOM,LineType,TaxCode
				Order By RFA.Division,LineType Desc,RFA.SubCategory

			End
			Else IF @Product_Hierarchy = 'Division'
			Begin
				Insert Into #tmpSchemeoutput
				Select RFA.Division ,IC.CategoryID,RFA.Division,RFA.UOM,LineType,Sum(RFA.SaleQty),Sum(RFA.SaleValue),
					   Sum(RFA.PromotedQty),Sum(RFA.PromotedValue),isNull(RFA.TaxCode,0),Sum(RFA.TaxAmount),
					   Sum(RFA.RebateQty),Sum(RFA.RebateValue)
				From   #RFAInfo RFA
				Left Outer Join ItemCategories IC On RFA.Division = IC.Category_Name  
				Where  
				RFA.SchemeID = @SchemeID
				Group By RFA.Division ,RFA.Division,IC.CategoryID,RFA.UOM,LineType,TaxCode
				Order By RFA.Division,LineType Desc

			End
		End
	End

	Select @QPS = Max(IsNull(QPS, 0)) From tbl_mERP_SchemeOutlet 
	Where SchemeID = @SchemeID
		And IsNull(QPS, 0) = 1 

	If @QPS = 1 And @IsRFAClaimed <> 'Yes' 
	Begin
		Declare @Free Int
		Select @Free = (case Max(SlabType) When 3 Then 1 Else 0 End) From tbl_merp_schemeslabdetail Where SchemeID = @SchemeID

		--==================QPS scheme Begins=====================================================
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
				IA.CustomerID, @SKUCode, Sum(Quantity) ,
				Sum(Quantity) * (@MarginPTR + (Case @TaxConfigFlag When 1 Then (Case Max(Isnull(ID.TAXONQTY,0)) When 0 Then (@MarginPTR * Max(TaxCode)/100) Else Max(TaxCode) End) Else 0 End)),
				1, 1, @SchemeID, @PayoutID, @MarginPTR, Max(ID.TaxCode), (Case Max(Isnull(ID.TAXONQTY,0)) When 0 Then (Sum(ID.Quantity) * (@MarginPTR * (Max(ID.TaxCode) / 100))) Else (Sum(ID.Quantity) * Max(ID.TaxCode)) End),
               (Case Max(Isnull(ID.TAXONQTY,0))When 0 Then  (@MarginPTR + (@MarginPTR * (Max(ID.TaxCode) / 100)) )Else @MarginPTR + (Max(ID.TaxCode)) End),
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

		Select @ItemFree = (Case Max(SlabType) When 1 Then 0 When 2 Then 0 Else 1 End) 
		From tbl_mERP_SchemeSlabDetail Where SchemeID = @SchemeID

		/* In case of free item scheme only the customer details for whom the 
		Free Item is adjusted in Invoice Should come */
		Truncate Table #tmpCustomerID
		If @ItemFree = 1 
			Insert Into #tmpCustomerID
			Select Distinct OutletCode From #FreeInfo
		Else
			Insert Into #tmpCustomerID
			Select CustomerID From Customer

		If Exists(Select * From tbl_mERP_QPSDtlData Where SchemeID = @SchemeID And PayoutID = @PayoutID )
		Begin
			If @ApplicableOn = 'Invoice' And @ItemFree = 0
			Begin
				Insert Into #tmpSchemeoutput(Division, [Code], [Name], UOM, [Type], SaleQty, SaleValue,
					PromotedQty, PromotedValue, TaxPercentage, TaxAmount, RebateQty, RebateValue)
				Select "Division" = NULL, "Code" = NULL, "Name" = NULL, "UOM" = NULL, "Type" = NULL, 
					"SaleQty" = NULL, "SaleValue" = NULL, "PromotedQty" = NULL, "PromotedValue" = NULL, 
					"TaxPercentage" = NULL, "TaxAmount" = NULL, "RebateQty" = isNull(Sum(qpsd.Rebate_Qty),0), 
					"RebateValue" = Case @CrNoteFlag When 1 Then isNull(Sum(qpsd.Rebate_Val),0) Else isNull(Sum(qpsd.RFARebate_Val),0) End 
				From tbl_mERP_QPSDtlData qpsd 
				Where SchemeID = @SchemeID 
					And PayoutID = @PayoutID 
					And (isNull(qpsd.Rebate_Val,0) > 0 OR isNull(qpsd.RFARebate_Val,0) > 0 Or isNull(qpsd.Rebate_Qty,0) > 0) 
			End
			Else
			Begin
				If @Product_Hierarchy = 'System SKU'
				Begin
					If @ApplicableOn <> 'Invoice'
					Begin			
						Insert Into #tmpSchemeoutput(Division, [Code], [Name], UOM, [Type], SaleQty, SaleValue,
										PromotedQty, PromotedValue, TaxPercentage, TaxAmount, RebateQty, RebateValue)
						Select "Division" = IC2.Category_Name, "Code" = qpsd.Product_Code, "Name" = I.ProductName, 
							"UOM" = qpsd.UOM, "Type" = 'MAIN', 
							"SaleQty" = Sum(qpsd.Quantity), "SaleValue" = Sum(qpsd.Quantity*qpsd.SalePrice), 
							"PromotedQty" = Sum(qpsd.Promoted_Qty), "PromotedValue" = Sum(qpsd.Promoted_Val), 
							"TaxPercentage" = qpsd.TaxPercent, 
							"TaxAmount" = (Case Max(Isnull(qpsd.TOQ,0)) When 0 Then (Sum((IsNull(qpsd.Promoted_Val, 0) * IsNull(qpsd.TaxPercent, 0)) / 100)) Else
										   (Sum(qpsd.Promoted_Qty) * IsNull(qpsd.TaxPercent, 0)) End), 
							"RebateQty" = Case When Sum(qpsd.Rebate_Qty) > 0 Then 0 Else Sum(qpsd.Rebate_Qty) End, 
							"RebateValue" = Case When Sum(qpsd.Rebate_Qty) > 0 Then 
								0 Else Case @CrNoteFlag When 1 Then Sum(qpsd.Rebate_Val) Else Sum(qpsd.RFARebate_Val) End End
						From tbl_mERP_QPSDtlData qpsd, Items I,#tmpCustomerID C,ItemCategories IC,ItemCategories IC1,ItemCategories IC2
						Where qpsd.Product_Code = I.Product_Code 
							And qpsd.SchemeID = @SchemeID 
							And qpsd.PayoutID = @PayoutID 
							And qpsd.Quantity > 0 
							And C.CustomerID = qpsd.CustomerID
							And I.CategoryID = IC.CategoryID 
							And	IC.ParentID = IC1.CategoryID 
							And IC1.ParentID = IC2.CategoryID
						Group By IC2.Category_Name, qpsd.Product_Code, I.ProductName, qpsd.UOM, qpsd.TaxPercent
						Order By IC2.Category_Name, I.ProductName

				
					End

					---	Credit note generated for item based Amount free scheme (credit note generated before FSU)
					If @ItemFree = 0
					Begin
						Set @CrdtNoteVal = 0 
						Select @CrdtNoteVal = Case @CrNoteFlag When 1 Then Sum(qpsd.Rebate_Val) Else Sum(qpsd.RFARebate_Val) End  
						From tbl_mERP_QPSDtlData qpsd 
						Where SchemeID = @SchemeID 
							And PayoutID = @PayoutID 
							And (qpsd.Rebate_Val > 0 OR qpsd.RFARebate_Val > 0 Or qpsd.Rebate_Qty > 0) 
							And qpsd.QPSAbsDataId Not In (2) And qpsd.Division = 'QPS Credit Note'
					End 

					Insert Into #tmpSchemeoutput(Division, [Code], [Name], UOM, [Type], SaleQty, SaleValue,
									PromotedQty, PromotedValue, TaxPercentage, TaxAmount, RebateQty, RebateValue)
					Select fif.Division, fif.SKUCode, I.ProductName, fif.UOM, 'Free', 0, 0, 0, 0, fif.TaxPercentage,
						Sum(fif.TaxAmount), Sum(fif.RebateQty), sum(fif.RebateValue)
					From #FreeInfo fif , Items I
					Where fif.SKUCode = I.Product_Code 
					Group By fif.Division, fif.SKUCode, I.ProductName, fif.UOM, 
						fif.TaxPercentage

				End
				Else IF @Product_Hierarchy = 'Market_SKU'
				Begin
					If @ApplicableOn <> 'Invoice'
					Begin
						Insert Into #tmpSchemeoutput(Division, [Code], [Name], UOM, [Type], SaleQty, SaleValue,
										PromotedQty, PromotedValue, TaxPercentage, TaxAmount, RebateQty, RebateValue)
						Select "Division" = IC2.Category_Name, "Code" = IC.CategoryID, "Name" = IC.Category_Name, 
							"UOM" = qpsd.UOM, "Type" = 'MAIN', 
							"SaleQty" = Sum(qpsd.Quantity), "SaleValue" = Sum(qpsd.Quantity*qpsd.SalePrice), 
							"PromotedQty" = Sum(qpsd.Promoted_Qty), "PromotedValue" = Sum(qpsd.Promoted_Val), 
							"TaxPercentage" = qpsd.TaxPercent, 
							"TaxAmount" = (Case Max(Isnull(qpsd.TOQ,0)) When 0 Then (Sum((IsNull(qpsd.Promoted_Val, 0) * IsNull(qpsd.TaxPercent, 0)) / 100))
										   Else (Sum(qpsd.Promoted_Qty) * IsNull(qpsd.TaxPercent, 0))  End )	, 
							"RebateQty" = Case When Sum(qpsd.Rebate_Qty) > 0 Then 0 Else Sum(qpsd.Rebate_Qty) end, 
							"RebateValue" = Case When Sum(qpsd.Rebate_Qty) > 0 Then 0 Else 
						--Case @TaxConfigFlag When 1 Then Sum(qpsd.Rebate_Val) Else Sum(qpsd.RFARebate_Val) End End
							Case @CrNoteFlag When 1 Then Sum(qpsd.Rebate_Val) Else Sum(qpsd.RFARebate_Val) End End
						From tbl_mERP_QPSDtlData qpsd, Items I,#tmpCustomerID C,ItemCategories IC,ItemCategories IC1,ItemCategories IC2
						Where qpsd.Product_Code = I.Product_Code
							And qpsd.SchemeID = @SchemeID 
							And qpsd.PayoutID = @PayoutID 
							And qpsd.Quantity > 0 
							And C.CustomerID = qpsd.CustomerID
							And I.CategoryID = IC.CategoryID 
							And	IC.ParentID = IC1.CategoryID 
							And IC1.ParentID = IC2.CategoryID
						Group By IC2.Category_Name, IC.Category_Name, IC.CategoryID, qpsd.UOM, qpsd.TaxPercent
						Order By IC2.Category_Name, IC.Category_Name
					End

					---	Credit note generated for item based Amount free scheme (credit note generated before FSU)
					If @ItemFree = 0
					Begin
						Set @CrdtNoteVal = 0 
						Select @CrdtNoteVal = Case @CrNoteFlag When 1 Then Sum(qpsd.Rebate_Val) Else Sum(qpsd.RFARebate_Val) End  
						From tbl_mERP_QPSDtlData qpsd 
						Where SchemeID = @SchemeID 
							And PayoutID = @PayoutID 
							And (qpsd.Rebate_Val > 0 OR qpsd.RFARebate_Val > 0 Or qpsd.Rebate_Qty > 0) 
							And qpsd.QPSAbsDataId Not In (2) And qpsd.Division = 'QPS Credit Note'

					End 

					Insert Into #tmpSchemeoutput(Division, [Code], [Name], UOM, [Type], SaleQty, SaleValue,
									PromotedQty, PromotedValue, TaxPercentage, TaxAmount, RebateQty, RebateValue)
					Select fif.Division, I.CategoryID, fif.MarketSKU, fif.UOM, 'Free', 0, 0, 0, 0, fif.TaxPercentage,
						Sum(fif.TaxAmount), Sum(fif.RebateQty), sum(fif.RebateValue)
					From #FreeInfo fif , ItemCategories I

					Where fif.MarketSKU = I.Category_Name 
					Group By fif.Division, I.CategoryID, fif.MarketSKU, fif.UOM, 
					fif.TaxPercentage

				End
				Else IF @Product_Hierarchy = 'Sub_Category'
				Begin
					If @ApplicableOn <> 'Invoice'
					Begin
						Insert Into #tmpSchemeoutput(Division, [Code], [Name], UOM, [Type], SaleQty, SaleValue,
										PromotedQty, PromotedValue, TaxPercentage, TaxAmount, RebateQty, RebateValue)
						Select "Division" = IC2.Category_Name, "Code" = IC1.CategoryID, "Name" = IC1.Category_Name, 
							"UOM" = qpsd.UOM, "Type" = 'MAIN', 
							"SaleQty" = Sum(qpsd.Quantity), "SaleValue" = Sum(qpsd.Quantity*qpsd.SalePrice), 
							"PromotedQty" = Sum(qpsd.Promoted_Qty), "PromotedValue" = Sum(qpsd.Promoted_Val), 
							"TaxPercentage" = qpsd.TaxPercent, 
							"TaxAmount" = (Case Max(Isnull(qpsd.TOQ,0)) When 0 Then (Sum((IsNull(qpsd.Promoted_Val, 0) * IsNull(qpsd.TaxPercent, 0)) / 100)) Else 
										    (Sum(qpsd.Promoted_Qty) * IsNull(qpsd.TaxPercent, 0) ) End)	, 
							"RebateQty" = Case When Sum(qpsd.Rebate_Qty) > 0 Then 0 Else Sum(qpsd.Rebate_Qty) End, 
							"RebateValue" = Case When Sum(qpsd.Rebate_Qty) > 0 Then 0 Else 
						--Case @TaxConfigFlag When 1 Then Sum(qpsd.Rebate_Val) Else Sum(qpsd.RFARebate_Val) End End 
							Case @CrNoteFlag When 1 Then Sum(qpsd.Rebate_Val) Else Sum(qpsd.RFARebate_Val) End End 
						From tbl_mERP_QPSDtlData qpsd, Items I,#tmpCustomerID C,ItemCategories IC,ItemCategories IC1,ItemCategories IC2
						Where qpsd.Product_Code = I.Product_Code
							And qpsd.SchemeID = @SchemeID 
							And qpsd.PayoutID = @PayoutID 
							And qpsd.Quantity > 0 
							--And (qpsd.Rebate_Val > 0 OR qpsd.RFARebate_Val > 0 Or qpsd.Rebate_Qty > 0) 
							--And qpsd.QPSAbsDataId Not In (2)
							--And qpsd.Rebate_Qty = 0
							And C.CustomerID = qpsd.CustomerID
							And I.CategoryID = IC.CategoryID 
							And	IC.ParentID = IC1.CategoryID 
							And IC1.ParentID = IC2.CategoryID
						Group By IC2.Category_Name, IC1.Category_Name, IC1.CategoryID, qpsd.UOM, qpsd.TaxPercent 
						Order By IC2.Category_Name, IC1.Category_Name
					End


					---	Credit note generated for item based Amount free scheme (credit note generated before FSU)
					If @ItemFree = 0
					Begin
						Set @CrdtNoteVal = 0 
						Select @CrdtNoteVal = Case @CrNoteFlag When 1 Then Sum(qpsd.Rebate_Val) Else Sum(qpsd.RFARebate_Val) End  
						From tbl_mERP_QPSDtlData qpsd 
						Where SchemeID = @SchemeID 
							And PayoutID = @PayoutID 
							And (qpsd.Rebate_Val > 0 OR qpsd.RFARebate_Val > 0 Or qpsd.Rebate_Qty > 0) 
							And qpsd.QPSAbsDataId Not In (2) And qpsd.Division = 'QPS Credit Note'

					End 
					Insert Into #tmpSchemeoutput(Division, [Code], [Name], UOM, [Type], SaleQty, SaleValue,
									PromotedQty, PromotedValue, TaxPercentage, TaxAmount, RebateQty, RebateValue)
					Select fif.Division, I.CategoryID, fif.SubCategory, fif.UOM, 'Free', 0, 0, 0, 0, fif.TaxPercentage,
						Sum(fif.TaxAmount), Sum(fif.RebateQty), sum(fif.RebateValue)
					From #FreeInfo fif , ItemCategories I

					Where fif.SubCategory = I.Category_Name 
					Group By fif.Division, I.CategoryID, fif.SubCategory, fif.UOM, 
					fif.TaxPercentage


				End
				Else IF @Product_Hierarchy = 'Division'
				Begin
					If @ApplicableOn <> 'Invoice'
					Begin
						Insert Into #tmpSchemeoutput(Division, [Code], [Name], UOM, [Type], SaleQty, SaleValue,
										PromotedQty, PromotedValue, TaxPercentage, TaxAmount, RebateQty, RebateValue)
						Select "Division" = IC2.Category_Name, "Code" = IC2.CategoryID, "Name" = IC2.Category_Name, 
							"UOM" = qpsd.UOM, "Type" = 'MAIN', 
							"SaleQty" = Sum(qpsd.Quantity), "SaleValue" = Sum(qpsd.Quantity*qpsd.SalePrice), 
							"PromotedQty" = Sum(qpsd.Promoted_Qty), "PromotedValue" = Sum(qpsd.Promoted_Val), 
							"TaxPercentage" = qpsd.TaxPercent, 
							"TaxAmount" = (Case Max(Isnull(qpsd.TOQ,0)) When 0 Then (Sum((IsNull(qpsd.Promoted_Val, 0) * IsNull(qpsd.TaxPercent, 0)) / 100))
										   Else (Sum(qpsd.Quantity) * IsNull(qpsd.TaxPercent, 0) ) End ), 
							"RebateQty" = Case When Sum(qpsd.Rebate_Qty) > 0 Then 0 Else Sum(qpsd.Rebate_Qty) End, 
							"RebateValue" = Case When Sum(qpsd.Rebate_Qty) > 0 Then 0 Else 
							--Case @TaxConfigFlag When 1 Then Sum(qpsd.Rebate_Val) Else Sum(qpsd.RFARebate_Val) End End 
							Case @CrNoteFlag When 1 Then Sum(qpsd.Rebate_Val) Else Sum(qpsd.RFARebate_Val) End End 
						From tbl_mERP_QPSDtlData qpsd, Items I,#tmpCustomerID C,ItemCategories IC,ItemCategories IC1,ItemCategories IC2
						Where qpsd.Product_Code = I.Product_Code
							And qpsd.SchemeID = @SchemeID 
							And qpsd.PayoutID = @PayoutID 
							And qpsd.Quantity > 0 
							And C.CustomerID = qpsd.CustomerID
							And I.CategoryID = IC.CategoryID 
							And	IC.ParentID = IC1.CategoryID 
							And IC1.ParentID = IC2.CategoryID
						Group By IC2.Category_Name, IC2.CategoryID, qpsd.UOM, qpsd.TaxPercent 
						Order By IC2.Category_Name
					End 

					---	Credit note generated for item based Amount free scheme (credit note generated before FSU)
					If @ItemFree = 0
					Begin
						Set @CrdtNoteVal = 0 
						Select @CrdtNoteVal = Case @CrNoteFlag When 1 Then Sum(qpsd.Rebate_Val) Else Sum(qpsd.RFARebate_Val) End  
						From tbl_mERP_QPSDtlData qpsd 
						Where SchemeID = @SchemeID 
							And PayoutID = @PayoutID 
							And (qpsd.Rebate_Val > 0 OR qpsd.RFARebate_Val > 0 Or qpsd.Rebate_Qty > 0) 
							And qpsd.QPSAbsDataId Not In (2) And qpsd.Division = 'QPS Credit Note'

					End 
					Insert Into #tmpSchemeoutput(Division, [Code], [Name], UOM, [Type], SaleQty, SaleValue,
									PromotedQty, PromotedValue, TaxPercentage, TaxAmount, RebateQty, RebateValue)
					Select fif.Division, I.CategoryID, fif.Division, fif.UOM, 'Free', 0, 0, 0, 0, fif.TaxPercentage,
					Sum(fif.TaxAmount), Sum(fif.RebateQty), sum(fif.RebateValue)
					From #FreeInfo fif , ItemCategories I
					Where fif.Division = I.Category_Name 
					Group By fif.Division, I.CategoryID, fif.Division, fif.UOM , fif.TaxPercentage
				End
			End
		End
		IF  @Free = 1
		Begin
			Insert Into #tmpSKU
			Select Distinct Product_Code From tbl_mERP_QPSDtlData Where SchemeID = @SchemeID and PayoutID = @PayoutID
			--And (Rebate_Val > 0 OR RFARebate_Val > 0 Or Rebate_Qty > 0) 
			And CustomerID In(Select OutletCode From #FreeInfo)
			
		End
		Else
		Begin
			Insert Into #tmpSKU
			Select Distinct Product_Code From tbl_mERP_QPSDtlData Where SchemeID = @SchemeID and PayoutID = @PayoutID
			--And (Rebate_Val > 0 OR RFARebate_Val > 0 Or Rebate_Qty > 0) 
		End
	End
--==================QPS scheme End=====================================================

	Insert Into #tmpAllSchemeoutput
	Select Division,Code,Name,UOM,Type,Sum(SaleQty),Sum(SaleValue),Sum(PromotedQty),Sum(PromotedValue),
	TaxPercentage,Sum(TaxAmount),Sum(RebateQty),Sum(RebateValue)
	From #tmpSchemeoutput
	Group By Division,Code,Name,UOM,Type,TaxPercentage	

	Delete From #tmpSKUWiseSales Where SKUCode Not In(Select Distinct IsNull(SkuCode, '') From #tmpSKU)
	Delete From #tmpSRSKUWiseSales Where SKUCode Not In(Select Distinct IsNull(SkuCode, '') From #tmpSKU)

	Insert Into #tmpSKUWiseSales_2
	Select * From #tmpSKUWiseSales

	Insert Into #tmpSRSKUWiseSales_2
	Select * From #tmpSRSKUWiseSales

	If (Select Count(*) From #tmpSKUWiseSales) > 0 and @IsRFAClaimed <> 'Yes'
	Begin
		If @ApplicableOn = 'Item' Or  @ApplicableOn = 'SPL_CAT'	
		Begin
			If @Product_Hierarchy = 'Division'
			Begin
				Update Schmoutput	
				Set SaleQty = (Select  Sum(SalesQty) From #tmpSKUWiseSales Where Division = Schmoutput.Name And 
					TaxCode = Schmoutput.TaxPercentage) , 
				SaleValue = (Select  Sum(SalesValue) From #tmpSKUWiseSales Where Division = Schmoutput.Name And 
					TaxCode = Schmoutput.TaxPercentage)
				From #tmpAllSchemeoutput Schmoutput
				Where Schmoutput.Type = 'MAIN'
					
				/* SR Item Salable */
				Update Schmoutput	
				Set SaleQty = (Select  Sum(IsNull(SalesQty, 0)) From #tmpSRSKUWiseSales Where Division = Schmoutput.Name 
					And ReturnType = 1 And TaxCode = Schmoutput.TaxPercentage) , 
				SaleValue = (Select  Sum(IsNull(SalesValue, 0)) From #tmpSRSKUWiseSales Where Division = Schmoutput.Name 
					And ReturnType = 1 And TaxCode = Schmoutput.TaxPercentage)
				From #tmpAllSchemeoutput Schmoutput
				Where Schmoutput.Type like 'Sales Return - Saleable'

				/* SR Item Damages */
				Update Schmoutput	
				Set SaleQty = (Select  Sum(IsNull(SalesQty, 0)) From #tmpSRSKUWiseSales Where Division = Schmoutput.Name 
					And ReturnType = 2 And TaxCode = Schmoutput.TaxPercentage) , 
				SaleValue = (Select  Sum(IsNull(SalesValue, 0)) From #tmpSRSKUWiseSales Where Division = Schmoutput.Name 
					And ReturnType = 2 And TaxCode = Schmoutput.TaxPercentage)
				From #tmpAllSchemeoutput Schmoutput
				Where Schmoutput.Type like 'Sales Return - Damaged' 

				-- Delete Scheme Main items
				Delete From #tmpSKUWiseSales_2
				From #tmpSKUWiseSales_2, #tmpAllSchemeoutput 
				Where #tmpSKUWiseSales_2.Division = #tmpAllSchemeoutput.Name And 
					#tmpSKUWiseSales_2.TaxCode = #tmpAllSchemeoutput.TaxPercentage 
				
				-- Delete scheme sales Return salable 
				Delete From #tmpSRSKUWiseSales_2 
				From #tmpSRSKUWiseSales_2, #tmpAllSchemeoutput 
				Where #tmpSRSKUWiseSales_2.Division = #tmpAllSchemeoutput.Name And 
					#tmpSRSKUWiseSales_2.ReturnType = 1 And 
					#tmpSRSKUWiseSales_2.TaxCode = #tmpAllSchemeoutput.TaxPercentage

				-- Delete scheme sales Return Damages
				Delete From #tmpSRSKUWiseSales_2 
				From #tmpSRSKUWiseSales_2, #tmpAllSchemeoutput 
				Where #tmpSRSKUWiseSales_2.Division = #tmpAllSchemeoutput.Name And 
					#tmpSRSKUWiseSales_2.ReturnType = 2 And 
					#tmpSRSKUWiseSales_2.TaxCode = #tmpAllSchemeoutput.TaxPercentage

				/* Insert non scheme Main Items */ 
				Insert Into #tmpAllSchemeoutput 
				Select Division, (Select CategoryID From ItemCategories Where Category_Name = Division), 
				Division, UOM, 'MAIN', Sum(SalesQty), Sum(SalesValue), 0, 0, TaxCode, 0, 0, 0 
				From #tmpSKUWiseSales_2  
				Group By Division, UOM, TaxCode

				-- Insert non Scheme Sales Return Salable
				Insert Into #tmpAllSchemeoutput 
				Select Division, (Select CategoryID From ItemCategories Where Category_Name = Division), 
				Division, UOM, 'Sales Return - Saleable', Sum(SalesQty), Sum(SalesValue), 0, 0, TaxCode, 0, 0, 0 
				From #tmpSRSKUWiseSales_2  
				Where ReturnType = 1 
				Group By Division, UOM, TaxCode

				-- Insert non Scheme Sales Return Damages
				Insert Into #tmpAllSchemeoutput 
				Select Division, (Select CategoryID From ItemCategories Where Category_Name = Division), 
				Division, UOM, 'Sales Return - Damaged', Sum(SalesQty), Sum(SalesValue), 0, 0, TaxCode, 0, 0, 0 
				From #tmpSRSKUWiseSales_2  
				Where ReturnType = 2  
				Group By Division, UOM, TaxCode

			End
			Else IF @Product_Hierarchy = 'Sub_Category'
			Begin
				Update Schmoutput	
				Set SaleQty = (Select  Sum(SalesQty) From #tmpSKUWiseSales Where SubCategory = Schmoutput.Name 
					And TaxCode = Schmoutput.TaxPercentage) , 
				SaleValue = (Select  Sum(SalesValue) From #tmpSKUWiseSales Where SubCategory = Schmoutput.Name 
					And TaxCode = Schmoutput.TaxPercentage)
				From #tmpAllSchemeoutput Schmoutput
				Where Schmoutput.Type = 'MAIN'

				/* SR Item Salable */
				Update Schmoutput	
				Set SaleQty = (Select  Sum(IsNull(SalesQty, 0)) From #tmpSRSKUWiseSales Where SubCategory = Schmoutput.Name 
					And ReturnType = 1 And TaxCode = Schmoutput.TaxPercentage) , 
				SaleValue = (Select  Sum(IsNull(SalesValue, 0)) From #tmpSRSKUWiseSales Where SubCategory = Schmoutput.Name 
					And ReturnType = 1 And TaxCode = Schmoutput.TaxPercentage)
				From #tmpAllSchemeoutput Schmoutput
				Where Schmoutput.Type like 'Sales Return - Saleable'

				/* SR Item Damages */
				Update Schmoutput	
				Set SaleQty = (Select  Sum(IsNull(SalesQty, 0)) From #tmpSRSKUWiseSales Where SubCategory = Schmoutput.Name 
					And ReturnType = 2 And TaxCode = Schmoutput.TaxPercentage) , 
				SaleValue = (Select  Sum(IsNull(SalesValue, 0)) From #tmpSRSKUWiseSales Where SubCategory = Schmoutput.Name 
					And ReturnType = 2 And TaxCode = Schmoutput.TaxPercentage)
				From #tmpAllSchemeoutput Schmoutput
				Where Schmoutput.Type like 'Sales Return - Damaged' 


				-- Delete Scheme Main items
				Delete From #tmpSKUWiseSales_2 
				From #tmpSKUWiseSales_2, #tmpAllSchemeoutput 
				Where #tmpSKUWiseSales_2.SubCategory = #tmpAllSchemeoutput.Name And 
					#tmpSKUWiseSales_2.TaxCode = #tmpAllSchemeoutput.TaxPercentage 
					
				-- Delete scheme sales Return salable 
				Delete From #tmpSRSKUWiseSales_2 
				From #tmpSRSKUWiseSales_2, #tmpAllSchemeoutput 
				Where #tmpSRSKUWiseSales_2.SubCategory = #tmpAllSchemeoutput.Name And 
					#tmpSRSKUWiseSales_2.ReturnType = 1 And 
					#tmpSRSKUWiseSales_2.TaxCode = #tmpAllSchemeoutput.TaxPercentage

				-- Delete scheme sales Return Damages
				Delete From #tmpSRSKUWiseSales_2 
				From #tmpSRSKUWiseSales_2, #tmpAllSchemeoutput 
				Where #tmpSRSKUWiseSales_2.SubCategory = #tmpAllSchemeoutput.Name And 
					#tmpSRSKUWiseSales_2.ReturnType = 2 And 
					#tmpSRSKUWiseSales_2.TaxCode = #tmpAllSchemeoutput.TaxPercentage

				/* Insert non scheme Main Items */ 
				Insert Into #tmpAllSchemeoutput 
				Select Division, (Select CategoryID From ItemCategories Where Category_Name = SubCategory), 
				SubCategory, UOM, 'MAIN', Sum(SalesQty), Sum(SalesValue), 0, 0, TaxCode, 0, 0, 0 
				From #tmpSKUWiseSales_2  
				Group By Division, SubCategory, UOM, TaxCode

				-- Insert non Scheme Sales Return Salable
				Insert Into #tmpAllSchemeoutput 
				Select Division, (Select CategoryID From ItemCategories Where Category_Name = SubCategory), 
				SubCategory, UOM, 'Sales Return - Saleable', Sum(SalesQty), Sum(SalesValue), 0, 0, TaxCode, 0, 0, 0 
				From #tmpSRSKUWiseSales_2  
				Where ReturnType = 1 
				Group By Division, SubCategory, UOM, TaxCode

				-- Insert non Scheme Sales Return Damages
				Insert Into #tmpAllSchemeoutput 
				Select Division, (Select CategoryID From ItemCategories Where Category_Name = SubCategory), 
				SubCategory, UOM, 'Sales Return - Damaged', Sum(SalesQty), Sum(SalesValue), 0, 0, TaxCode, 0, 0, 0 
				From #tmpSRSKUWiseSales_2  
				Where ReturnType = 2  
				Group By Division, SubCategory, UOM, TaxCode
			End
			Else IF @Product_Hierarchy = 'Market_SKU'
			Begin
				Update Schmoutput	
				Set SaleQty = (Select  Sum(SalesQty) From #tmpSKUWiseSales Where MarketSKU = Schmoutput.Name And 
					TaxCode = Schmoutput.TaxPercentage) , 
				SaleValue = (Select  Sum(SalesValue) From #tmpSKUWiseSales Where MarketSKU = Schmoutput.Name And 
					TaxCode = Schmoutput.TaxPercentage)
				From #tmpAllSchemeoutput Schmoutput
				Where Schmoutput.Type = 'MAIN'

				/* SR Item Salable */
				Update Schmoutput	
				Set SaleQty = (Select  Sum(IsNull(SalesQty, 0)) From #tmpSRSKUWiseSales Where MarketSKU = Schmoutput.Name 
					And ReturnType = 1 And TaxCode = Schmoutput.TaxPercentage) , 
				SaleValue = (Select  Sum(IsNull(SalesValue, 0)) From #tmpSRSKUWiseSales Where MarketSKU = Schmoutput.Name 
					And ReturnType = 1 And TaxCode = Schmoutput.TaxPercentage)
				From #tmpAllSchemeoutput Schmoutput
				Where Schmoutput.Type like 'Sales Return - Saleable'

				/* SR Item Damages */
				Update Schmoutput	
				Set SaleQty = (Select  Sum(IsNull(SalesQty, 0)) From #tmpSRSKUWiseSales Where MarketSKU = Schmoutput.Name 
					And ReturnType = 2 And TaxCode = Schmoutput.TaxPercentage) , 
				SaleValue = (Select  Sum(IsNull(SalesValue, 0)) From #tmpSRSKUWiseSales Where MarketSKU = Schmoutput.Name 
					And ReturnType = 2 And TaxCode = Schmoutput.TaxPercentage)
				From #tmpAllSchemeoutput Schmoutput
				Where Schmoutput.Type like 'Sales Return - Damaged' 

				-- Delete Scheme Main items
				Delete From #tmpSKUWiseSales_2 
				From #tmpSKUWiseSales_2, #tmpAllSchemeoutput 
				Where #tmpSKUWiseSales_2.MarketSKU = #tmpAllSchemeoutput.Name And 
					#tmpSKUWiseSales_2.TaxCode = #tmpAllSchemeoutput.TaxPercentage 
				
				-- Delete scheme sales Return salable 
				Delete From #tmpSRSKUWiseSales_2 
				From #tmpSRSKUWiseSales_2, #tmpAllSchemeoutput 
				Where #tmpSRSKUWiseSales_2.MarketSKU = #tmpAllSchemeoutput.Name And 
					#tmpSRSKUWiseSales_2.ReturnType = 1 And 
					#tmpSRSKUWiseSales_2.TaxCode = #tmpAllSchemeoutput.TaxPercentage

				-- Delete scheme sales Return Damages
				Delete From #tmpSRSKUWiseSales_2 
				From #tmpSRSKUWiseSales_2, #tmpAllSchemeoutput 
				Where #tmpSRSKUWiseSales_2.MarketSKU = #tmpAllSchemeoutput.Name And 
					#tmpSRSKUWiseSales_2.ReturnType = 2 And 
					#tmpSRSKUWiseSales_2.TaxCode = #tmpAllSchemeoutput.TaxPercentage

				/* Insert non scheme Main Items */ 
				Insert Into #tmpAllSchemeoutput 
				Select Division, (Select CategoryID From ItemCategories Where Category_Name = MarketSKU), 
				MarketSKU, UOM, 'MAIN', Sum(SalesQty), Sum(SalesValue), 0, 0, TaxCode, 0, 0, 0 
				From #tmpSKUWiseSales_2  
				Group By Division, MarketSKU, UOM, TaxCode

				-- Insert non Scheme Sales Return Salable
				Insert Into #tmpAllSchemeoutput 
				Select Division, (Select CategoryID From ItemCategories Where Category_Name = MarketSKU), 
				MarketSKU, UOM, 'Sales Return - Saleable', Sum(SalesQty), Sum(SalesValue), 0, 0, TaxCode, 0, 0, 0 
				From #tmpSRSKUWiseSales_2  
				Where ReturnType = 1 
				Group By Division, MarketSKU, UOM, TaxCode

				-- Insert non Scheme Sales Return Damages
				Insert Into #tmpAllSchemeoutput 
				Select Division, (Select CategoryID From ItemCategories Where Category_Name = MarketSKU), 
				MarketSKU, UOM, 'Sales Return - Damaged', Sum(SalesQty), Sum(SalesValue), 0, 0, TaxCode, 0, 0, 0 
				From #tmpSRSKUWiseSales_2  
				Where ReturnType = 2  
				Group By Division, MarketSKU, UOM, TaxCode
			End
			Else IF @Product_Hierarchy = 'System SKU'
			Begin
				Update Schmoutput	
				Set SaleQty = (Select  Sum(SalesQty) From #tmpSKUWiseSales Where SKUCode = Schmoutput.Code And 
					TaxCode = Schmoutput.TaxPercentage) , 
				SaleValue = (Select  Sum(SalesValue) From #tmpSKUWiseSales Where SKUCode = Schmoutput.Code And 
					TaxCode = Schmoutput.TaxPercentage)
				From #tmpAllSchemeoutput Schmoutput
				Where Schmoutput.Type = 'MAIN'

				/* SR Item Salable */
				Update Schmoutput	
				Set SaleQty = (Select  Sum(IsNull(SalesQty, 0)) From #tmpSRSKUWiseSales Where SKUCode = Schmoutput.Code 
					And ReturnType = 1 And TaxCode = Schmoutput.TaxPercentage) , 
				SaleValue = (Select  Sum(IsNull(SalesValue, 0)) From #tmpSRSKUWiseSales Where SKUCode = Schmoutput.Code 
					And ReturnType = 1 And TaxCode = Schmoutput.TaxPercentage)
				From #tmpAllSchemeoutput Schmoutput
				Where Schmoutput.Type like 'Sales Return - Saleable'

				/* SR Item Damages */
				Update Schmoutput	
				Set SaleQty = (Select  Sum(IsNull(SalesQty, 0)) From #tmpSRSKUWiseSales Where SKUCode = Schmoutput.Code 
					And ReturnType = 2 And TaxCode = Schmoutput.TaxPercentage) , 
				SaleValue = (Select  Sum(IsNull(SalesValue, 0)) From #tmpSRSKUWiseSales Where SKUCode = Schmoutput.Code 
					And ReturnType = 2 And TaxCode = Schmoutput.TaxPercentage)
				From #tmpAllSchemeoutput Schmoutput
				Where Schmoutput.Type like 'Sales Return - Damaged' 

				-- Delete Scheme Main items
				Delete From #tmpSKUWiseSales_2
				From #tmpSKUWiseSales_2, #tmpAllSchemeoutput 
				Where #tmpSKUWiseSales_2.SKUCode = #tmpAllSchemeoutput.Code And 
					#tmpSKUWiseSales_2.TaxCode = #tmpAllSchemeoutput.TaxPercentage 

				-- Delete scheme sales Return salable 
				Delete From #tmpSRSKUWiseSales_2 
				From #tmpSRSKUWiseSales_2, #tmpAllSchemeoutput 
				Where #tmpSRSKUWiseSales_2.SKUCode = #tmpAllSchemeoutput.Code And 
					#tmpSRSKUWiseSales_2.ReturnType = 1 And 
					#tmpSRSKUWiseSales_2.TaxCode = #tmpAllSchemeoutput.TaxPercentage

				-- Delete scheme sales Return Damages
				Delete From #tmpSRSKUWiseSales_2 
				From #tmpSRSKUWiseSales_2, #tmpAllSchemeoutput 
				Where #tmpSRSKUWiseSales_2.SKUCode = #tmpAllSchemeoutput.Code And 
					#tmpSRSKUWiseSales_2.ReturnType = 2 And 
					#tmpSRSKUWiseSales_2.TaxCode = #tmpAllSchemeoutput.TaxPercentage


				/* Insert non scheme Main Items */ 
				Insert Into #tmpAllSchemeoutput 
				Select Division, SKUCode, 
				(Select ProductName From Items Where Product_Code = SKUCode),
				UOM, 'MAIN', Sum(SalesQty), Sum(SalesValue), 0, 0, TaxCode, 0, 0, 0 
				From #tmpSKUWiseSales_2  
				Group By Division, SKUCode, UOM, TaxCode

				-- Insert non Scheme Sales Return Salable
				Insert Into #tmpAllSchemeoutput 
				Select Division, SKUCode, 
				(Select ProductName From Items Where Product_Code = SKUCode),
				UOM, 'Sales Return - Saleable', Sum(SalesQty), Sum(SalesValue), 0, 0, TaxCode, 0, 0, 0 
				From #tmpSRSKUWiseSales_2  
				Where ReturnType = 1 
				Group By Division, SKUCode, UOM, TaxCode

				-- Insert non Scheme Sales Return Damages
				Insert Into #tmpAllSchemeoutput 
				Select Division, SKUCode, 
				(Select ProductName From Items Where Product_Code = SKUCode), 
				UOM, 'Sales Return - Damaged', Sum(SalesQty), Sum(SalesValue), 0, 0, TaxCode, 0, 0, 0 
				From #tmpSRSKUWiseSales_2  
				Where ReturnType = 2  
				Group By Division, SKUCode, UOM, TaxCode
			End
		End
	End

	If Exists(Select * From #tmpAllSchemeoutput Where isNull(Division,'') <> '') 
	Begin
		Declare @Div nVarchar(50)

		Set @SalQty = 0
		Set @SalValue = 0
		Set @SRSalQty = 0
		Set @SRSalValue = 0
			
		Declare Cur_Div Cursor For
		Select Distinct  Division From #tmpAllSchemeoutput Order By Division
		Open Cur_Div
		Fetch From Cur_Div Into @Div --,@Type
		While @@Fetch_Status = 0
		Begin
			Insert Into #tmpFinal
			Select * From  #tmpAllSchemeoutput Where isNull(Division,'') = isNull(@Div,'')

			If @IsRFAClaimed <> 'Yes'
			Begin	
				/*If there is only free item in the division then dont show the Sales Qty And SalesValue */
				If  Exists(Select * From #tmpAllSchemeoutput Where Type = 'MAIN' And Division = @Div )
					Select @SalQty = Sum(SalesQty) ,@SalValue = Sum(SalesValue) From #tmpSKUWiseSales 
					Where Division = @Div
				Else
					Select @SalQty = 0 ,@SalValue = 0

				Select @SRSalQty = Sum(SalesQty) ,@SRSalValue = Sum(SalesValue)From #tmpSRSKUWiseSales 
				Where Division = @Div
					
				/* Insert SubTotal */
				Insert Into #tmpFinal(Division,SaleQty,SaleValue,PromotedQty,
									  PromotedValue,Taxamount,RebateQty,RebateValue)
				Select @SUBTOTAL, isNull(@SalQty,0) + isNull(@SRSalQty,0) ,isNull(@SalValue,0) + isNull(@SRSalValue,0)
				,Sum(PromotedQty),Sum(PromotedValue),Sum(Taxamount),Sum(RebateQty),Sum(RebateValue)
				From  #tmpAllSchemeoutput
				Where Division = @Div 
				Group By Division
			End
			Else If @IsRFAClaimed = 'Yes'
			Begin
					/* Insert SubTotal */
				Insert Into #tmpFinal(Division,SaleQty,SaleValue,PromotedQty,
								  PromotedValue,Taxamount,RebateQty,RebateValue)
								  	
				Select @SUBTOTAL, Sum(SaleQty),Sum(SaleValue),Sum(PromotedQty),
				Sum(PromotedValue),Sum(Taxamount),Sum(RebateQty),Sum(RebateValue)
				From  #tmpAllSchemeoutput
				Where Division = @Div 
				Group By Division	
			End
			Fetch Next From Cur_Div Into @Div 
		End
		Close Cur_Div
		Deallocate  Cur_Div

		/* Insert GrandTotal */
		If @IsRFAClaimed <> 'Yes'
			Insert Into #tmpFinal(Division,SaleQty,SaleValue,PromotedQty,
		    			  PromotedValue,Taxamount,RebateQty,RebateValue)
			Select @GRNTOTAL , 
			(Select Sum(SaleQty) From #tmpFinal Where Division = @SUBTOTAL)  ,
			(Select Sum(SaleValue) From #tmpFinal Where Division = @SUBTOTAL)  ,
			Sum(PromotedQty),
			Sum(PromotedValue),Sum(Taxamount),Sum(RebateQty),Sum(RebateValue)
			From #tmpAllSchemeoutput	
		Else If @IsRFAClaimed = 'Yes'
			/* Insert GrandTotal */
			Insert Into #tmpFinal(Division,SaleQty,SaleValue,PromotedQty,
		    			  PromotedValue,Taxamount,RebateQty,RebateValue)
			Select @GRNTOTAL , Sum(SaleQty),Sum(SaleValue),Sum(PromotedQty),
			Sum(PromotedValue),Sum(Taxamount),Sum(RebateQty),Sum(RebateValue)
			From #tmpAllSchemeoutput
	End

	If @ApplicableOn = 'Invoice' And ((Select Count(*) From #RFAInfo Where (FlagWord = 1 or IsNull(RebateQty, 0)  > 0) And SchemeID = @SchemeID) <= 0) 
								 And ((Select Count (*) From #tmpFinal Where IsNull(RebateQty, 0) > 0) <= 0)
	Begin
		If @CrdtNoteVal > 0 
		Insert Into #tmpAllSchemeoutput(Division,RebateValue)
		Select @QPSCRDTNOTE,@CrdtNoteVal

		Select 1,* From #tmpAllSchemeoutput
	End
	Else
	Begin
		If @CrdtNoteVal > 0 
		Insert Into #tmpFinal(Division,RebateValue)
		Select @QPSCRDTNOTE,@CrdtNoteVal

		Update #tmpFinal Set 
			SaleQty =  (Case  isNull(SaleQty,0) When 0 Then NULL Else SaleQty End),
			SaleValue = (Case  isNull(SaleValue,0) When 0 Then NULL Else SaleValue End),
			PromotedQty = (Case  isNull(PromotedQty,0) When 0 Then NULL Else PromotedQty End) ,
			PromotedValue = (Case  isNull(PromotedValue,0) When 0 Then NULL Else PromotedValue End),
			TaxPercentage =  (Case  isNull(TaxPercentage,0) When 0 Then NULL Else TaxPercentage End),
			TaxAmount = (Case  isNull(TaxAmount,0) When 0 Then NULL Else TaxAmount End),
			RebateQty = (Case  isNull(RebateQty,0) When 0 Then NULL Else RebateQty End),
			RebateValue = (Case  isNull(RebateValue,0) When 0 Then NULL Else RebateValue End)

		Select 1,* From  #tmpFinal
		
	End

	Drop Table #RFAInfo
	Drop Table #tmpSchemeoutput
	Drop Table #tmpPayout
	Drop Table #tmpFinal	
	Drop Table #FreeInfo
	Drop Table #tmpCustomerID
	Drop Table #tmpAllSchemeoutput
	Drop Table #tmpSKU	
	Drop Table #tmpSales
	Drop Table #tmpSKUWiseSales
	Drop Table #tmpSRSKUWiseSales
	Drop Table #tmpSKUWiseSales_2
	Drop Table #tmpSRSKUWiseSales_2
	Drop Table #TmpTSRInvAbs
	Drop Table #TmpTSRInvDtl
	Drop Table #tmpLesGrtDate 	
End /* End Of Procedure */
