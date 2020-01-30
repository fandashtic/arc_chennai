Create Procedure mERP_spr_Non_RFA_Scheme_Expense_Report_Upload
(
 @FromDate Datetime,
 @ToDate Datetime,
 @ActivtiyCode nVarchar(4000),
 @SchemeName nVarchar(4000)
) As
	Begin
	Declare @RFAStatus as int
	Declare @SchemeDet nVarchar(255)
	Declare @Delimeter nVarchar(1)
--	Declare @Counter as Int
	Declare @PayoutID Int
--	Declare @ExpiryDate DateTime
	Declare @ItemGroup Int
	Declare @PayoutPeriod nVarchar(1000)
--	Declare @RowCount as Int
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
	Set @Delimeter = Char(15) 
	Declare @Description nVarchar(255)
	Declare @ApplicablePeriod	nVarchar(255)
	Declare @RFAPeriod nVarchar(255)
	Declare @CompaniesToUploadCode as [nvarchar](255) 
	Declare @WDDestCode as [nvarchar](255) 
	Declare @WDCode nVarchar(255) 
	Declare @DayClosed as int
	Declare @MonthToDate as DateTime
	Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload        
	Select Top 1 @WDCode = RegisteredOwner From Setup          
	Set @FromDate = dbo.StripTimeFromDate(@FromDate)
	Set @ToDate = dbo.StripTimeFromDate(@ToDate)
	Declare @Product_Hierarchy as nvarchar(255)
	Set Dateformat dmy
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
	Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload        
	Select Top 1 @WDCode = RegisteredOwner From Setup          
	Declare @SQty as Decimal(18,6)
	Declare @SValue as Decimal(18,6)
	Declare @SRQty as Decimal(18,6)
	Declare @SRValue as Decimal(18,6)
	Declare @Qty as Decimal(18,6)
	Declare @Value as Decimal(18,6)
	Declare @Code as Nvarchar(255)
   
	If @CompaniesToUploadCode='ITC001'        
		Set @WDDestCode= @WDCode        
	Else        
	Begin        
		Set @WDDestCode= @WDCode        
		Set @WDCode= @CompaniesToUploadCode        
	End 
	Set @Delimeter = Char(15) 

CREATE TABLE [dbo].[#tmpFinalData](
			[WD Code] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[WD Dest] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[FromDate] [datetime] NULL,
			[ToDate] [datetime] NULL,
			[ActivityCode] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[Description] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[Applicable Period] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[RFA Period] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[Division] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[Code] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[Name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[UOM] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[Type] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[SaleQty] [decimal](18, 6) NULL,
			[SaleValue] [decimal](18, 6) NULL,
			[PromotedQty] [decimal](18, 6) NULL,
			[PromotedValue] [decimal](18, 6) NULL,
			[TaxPercentage] [decimal](18, 6) NULL,
			[TaxAmount] [decimal](18, 6) NULL,
			[RebateQty] [decimal](18, 6) NULL,
			[RebateValue] [decimal](18, 6) NULL,
			QPS Int 
		) 
	Create table #ValidateTable (ID Int Identity , ActivityCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
								 ApplicablePeriod nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
								 RFAPeriod nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
								 SchemeID Int ,PayoutID Int)

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
	
	If @CompaniesToUploadCode='ITC001'        
		Set @WDDestCode= @WDCode        
	Else        
	Begin        
		Set @WDDestCode= @WDCode        
		Set @WDCode= @CompaniesToUploadCode        
	End 	
	
	select @MonthToDate = convert(datetime, dateadd(d, -1, dateadd(m, 1, @FromDate )), 103)

	Select @DayClosed = 0
	If (Select isNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') = 1
	Begin
		If ((Select dbo.StripTimeFromDate(LastInventoryUpload) From Setup) >= dbo.StripTimeFromDate(@MonthToDate))
		Set @DayClosed = 1
	End
	
CREATE TABLE [dbo].[#TmpTSRInvAbs](
	[InvoiceID] [int] ,
	[InvoiceType] [int] NOT NULL,
	[InvoiceDate] [datetime] NULL,
	[CustomerID] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BillingAddress] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ShippingAddress] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UserName] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GrossValue] [decimal](18, 6) NULL,
	[DiscountPercentage] [decimal](18, 6) NULL,
	[DiscountValue] [decimal](18, 6) NULL,
	[NetValue] [decimal](18, 6) NULL,
	[CreationTime] [datetime] NULL,
	[Status] [int] NULL,
	[TaxLocation] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[InvoiceReference] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReferenceNumber] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AdditionalDiscount] [decimal](18, 6) NULL,
	[Freight] [decimal](18, 6) NULL,
	[CreditTerm] [int] NULL,
	[PaymentDate] [datetime] NULL,
	[DocumentID] [int] NULL,
	[NewReference] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NewInvoiceReference] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OriginalInvoice] [int] NULL,
	[ClientID] [int] NULL,
	[Memo1] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Memo2] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Memo3] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MemoLabel1] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MemoLabel2] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MemoLabel3] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Flags] [int] NULL,
	[ReferredBy] [int] NULL,
	[Balance] [decimal](18, 6) NULL,
	[SalesmanID] [int] NULL,
	[BeatID] [int] NULL,
	[PaymentMode] [int] NULL,
	[PaymentDetails] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReturnType] [int] NULL,
	[Salesman2] [int] NULL,
	[DocReference] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AmountRecd] [decimal](18, 6) NULL,
	[AdjRef] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AdjustedAmount] [decimal](18, 6) NULL,
	[GoodsValue] [decimal](18, 6) NULL,
	[AddlDiscountValue] [decimal](18, 6) NULL,
	[TotalTaxSuffered] [decimal](18, 6) NULL,
	[TotalTaxApplicable] [decimal](18, 6) NULL,
	[ProductDiscount] [decimal](18, 6) NULL,
	[RoundOffAmount] [decimal](18, 6) NULL,
	[AdjustmentValue] [decimal](18, 6) NULL,
	[Denominations] [nvarchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ServiceCharge] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BranchCode] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CFormNo] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DFormNo] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CancelDate] [datetime] NULL,
	[VanNumber] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TaxOnMRP] [int] NULL,
	[DocSerialType] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemeID] [int] NULL,
	[SchemeDiscountPercentage] [decimal](18, 6) NULL,
	[SchemeDiscountAmount] [decimal](18, 6) NULL,
	[ClaimedAmount] [decimal](18, 6) NULL,
	[ClaimedAlready] [int] NULL,
	[ExciseDuty] [decimal](18, 6) NULL,
	[DiscountBeforeExcise] [int] NULL,
	[SalePriceBeforeExcise] [int] NULL,
	[CustomerPoints] [decimal](18, 6) NULL,
	[VatTaxAmount] [decimal](18, 6) NULL,
	[SONumber] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GroupID] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DeliveryStatus] [int] NULL,
	[DeliveryDate] [datetime] NULL,
	[InvoiceSchemeID] [nvarchar](510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MultipleSchemeDetails] [nvarchar](2550) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)

CREATE CLUSTERED INDEX IDX_C_TmpTSRInvAbs_InvoiceID_Upload ON #TmpTSRInvAbs(InvoiceID)
	
CREATE TABLE [dbo].[#TmpTSRInvDtl](
	[InvoiceID] [int] NOT NULL,
	[Product_Code] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Batch_Code] [int] NULL,
	[Batch_Number] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Quantity] [decimal](18, 6) NULL,
	[SalePrice] [decimal](18, 6) NULL,
	[TaxCode] [decimal](18, 6) NULL,
	[DiscountPercentage] [decimal](18, 6) NULL,
	[DiscountValue] [decimal](18, 6) NULL,
	[Amount] [decimal](18, 6) NULL,
	[PurchasePrice] [decimal](18, 6) NULL,
	[STPayable] [decimal](18, 6) NULL,
	[FlagWord] [int] NULL,
	[SaleID] [int] NULL,
	[PTR] [decimal](18, 6) NULL,
	[PTS] [decimal](18, 6) NULL,
	[MRP] [decimal](18, 6) NULL,
	[TaxID] [int] NULL,
	[CSTPayable] [decimal](18, 6) NULL,
	[TaxCode2] [decimal](18, 6) NULL,
	[TaxSuffered] [decimal](18, 6) NULL,
	[TaxSuffered2] [decimal](18, 6) NULL,
	[ReasonID] [int] NULL,
	[UOM] [int] NULL,
	[UOMQty] [decimal](18, 6) NULL,
	[UOMPrice] [decimal](18, 6) NULL,
	[ComboID] [int] NULL,
	[Serial] [int] NULL,
	[FreeSerial] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SPLCATSerial] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SpecialCategoryScheme] [int] NULL,
	[SCHEMEID] [int] NULL,
	[SPLCATSCHEMEID] [int] NULL,
	[SCHEMEDISCPERCENT] [decimal](18, 6) NULL,
	[SCHEMEDISCAMOUNT] [decimal](18, 6) NULL,
	[SPLCATDISCPERCENT] [decimal](18, 6) NULL,
	[SPLCATDISCAMOUNT] [decimal](18, 6) NULL,
	[ExciseDuty] [decimal](18, 6) NULL,
	[SalePriceBeforeExciseAmount] [decimal](18, 6) NULL,
	[ExciseID] [int] NULL,
	[salesstaffid] [int] NULL,
	[TaxSuffApplicableOn] [int] NULL,
	[TaxSuffPartOff] [decimal](18, 6) NULL,
	[Vat] [int] NULL,
	[CollectTaxSuffered] [int] NULL,
	[TaxAmount] [decimal](18, 6) NULL,
	[TaxSuffAmount] [decimal](18, 6) NULL,
	[STCredit] [decimal](18, 6) NULL,
	[TaxApplicableOn] [int] NULL,
	[TaxPartOff] [decimal](18, 6) NULL,
	[OtherCG_Item] [int] NULL,
	[SplCatCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[QuotationID] [int] NULL,
	[MultipleSchemeID] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MultipleSplCatSchemeID] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TotSchemeAmount] [decimal](18, 6) NULL,
	[MultipleSchemeDetails] [nvarchar](2550) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MultipleSplCategorySchDetail] [nvarchar](2550) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MultipleRebateID] [nvarchar](2550) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MultipleRebateDet] [nvarchar](2550) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RebateRate] [decimal](18, 6) NULL,
	[GroupID] [int] NULL,
	[TAXONQTY] [int] Default 0
	) ON [PRIMARY]
CREATE NonCLUSTERED INDEX IDX_NonC_TmpTSRInvDtl_InvoiceID_Upload ON #TmpTSRInvDtl(InvoiceID)
	
	--To hold the lastinventoryuploaddate with the format.
--	Declare @tmpScheme Table ([RowID] Int Identity(1,1),SchemeID int,PayoutID Int)
--	Declare @tmpActivityCode Table (ActivityCode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
--
--	Declare @TmpSchememaster Table (Schemeid NVarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS,ActivityCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
--								 Description nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
--								 ApplicablePeriod	nVarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS,
--								 RFAPeriod nVarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS
--								 )
--    Declare @SkipSRInvScheme as table (SchemeID Int, InvoiceID Int, PayoutFrom DateTime, PayoutTo DateTime)

	Declare @tmpLesGrtDate Table (SchemeID Int, PADateFrom Datetime, PADateTo Datetime)
	Declare @tmpSKU Table (skucode nvarchar(255) collate SQL_Latin1_General_CP1_CI_AS)
--	Declare @tmpPayout Table (SchemeID Int,PayoutID Int,PayoutPeriodFrom DateTime,PayoutPeriodTo DateTime)
	
	if object_id('tempdb..#tmpPayout1') is not null
	Drop table #tmpPayout1

	Create Table #tmpPayout1(SchemeID Int,PayoutID Int,PayoutPeriodFrom DateTime,PayoutPeriodTo DateTime)


	Create Table #tmpScheme([RowID] Int Identity(1,1),SchemeID int,PayoutID Int)

	Create Table #tmpActivityCode(ActivityCode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

--	Create Table #TmpSchememaster(Schemeid NVarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS,ActivityCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
--								 Description nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
--								 ApplicablePeriod	nVarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS,
--								 RFAPeriod nVarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS
--								 )
	Create Table #TmpSchememaster(Schemeid int,PayoutId int,ActivityCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
								 Description nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
								 ApplicablePeriod	nVarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS,
								 RFAPeriod nVarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS
								 )	
								 
	Create Table #tmpFinalSchList(RowID Int Identity(1,1),Schemeid int,PayoutId int,ActivityCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
								 Description nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
								 ApplicablePeriod	nVarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS,
								 RFAPeriod nVarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS
								 ,InvCnt Int Default(0)
								 )
								 
	Create Table #SkipSRInvScheme(SchemeID Int, InvoiceID Int, PayoutFrom DateTime, PayoutTo DateTime)


    --Create Table #tmpLesGrtDate(SchemeID Int, PADateFrom Datetime, PADateTo Datetime)

	--Create Table #tmpSKU(skucode nvarchar(255) collate SQL_Latin1_General_CP1_CI_AS)

	--Create Table #tmpPayout(SchemeID Int,PayoutID Int,PayoutPeriodFrom DateTime,PayoutPeriodTo DateTime)


	Set @RFAStatus = 0
	If @ActivtiyCode = '%'
		Insert Into #tmpActivityCode
		Select Distinct ActivityCode From tbl_mERP_SchemeAbstract Where RFAApplicable = @RFAStatus
		And Active = 1
	Else
		Insert Into #tmpActivityCode
		Select Distinct ActivityCode From tbl_mERP_SchemeAbstract
		Where ActivityCode In (Select * From dbo.sp_SplitIn2Rows(@ActivtiyCode,@Delimeter))
		And RFAApplicable = @RFAStatus
		And Active = 1

/* Report should be generated only if the last day of the month is Closed */
If @DayClosed = 0
    Goto OvernOut1
Else If @DayClosed = 1
	Begin	
		If @Schemename = '%' 
			Insert Into #tmpScheme
			Select Distinct SchemeID,0 From tbl_mERP_SchemeAbstract 
			Where SchemeType In(1,2)
			And ActivityCode In (Select * From #tmpActivityCode)
			And Active = 1 and Isnull(RFAApplicable,0) = @RFAStatus
--			and (dbo.striptimefromdate(ActiveFrom) <= dbo.striptimefromdate(@ToDate)or dbo.striptimefromdate(ActiveTo) >= dbo.striptimefromdate(dbo.striptimefromdate(@ToDate)))
--			And schemeId in(select Distinct  SchemeId from tbl_Merp_Schemepayoutperiod Where  dbo.striptimefromdate(@ToDate) Between dbo.striptimefromdate(PayoutPeriodFrom) and dbo.striptimefromdate(PayoutPeriodTo))
		Else
			Insert Into #tmpScheme
			Select Distinct Schemeid,0 From tbl_mERP_SchemeAbstract
			Where SchemeType In(1,2) and Description In (Select * From Dbo.sp_SplitIn2Rows(@SchemeName,@Delimeter))
			And ActivityCode In (Select * From #tmpActivityCode)
			And Active = 1 and Isnull(RFAApplicable,0) = @RFAStatus
--			and (dbo.striptimefromdate(ActiveFrom) <= dbo.striptimefromdate(@ToDate) or dbo.striptimefromdate(ActiveTo) >= dbo.striptimefromdate(dbo.striptimefromdate(@ToDate)))
--			And schemeId in(select Distinct  SchemeId from tbl_Merp_Schemepayoutperiod Where  dbo.striptimefromdate(@ToDate) Between dbo.striptimefromdate(PayoutPeriodFrom) and dbo.striptimefromdate(PayoutPeriodTo))
	End
--	Set @RowCount = (Select max([RowID]) from #tmpScheme)
--	Set @counter = 1 

--	While @Counter <= @RowCount
--	Begin
--		Set @SchemeID = 0
--		Set @PayoutID = 0
--		Select @SchemeID = Schemeid,@PayoutID = PayoutID from #tmpScheme Where [RowID] = @Counter
--
--			Select @SchemeType = SA.SchemeType,
--			@ActivityCode = SA.ActivityCode, 
--			@CSSchemeID = SA.CS_RecSchID,
--			@ActivityType = SA.Description,
--			@ActiveFrom = SA.ActiveFrom, 
--			@ActiveTo = SA.ActiveTo, 
--			@PayoutFrom = @FromDate, 
--			@PayoutTo = @ToDate,
--			@ExpiryDate = dbo.striptimefromdate(SA.ExpiryDate),	
--			@ApplicableOn = Case When SA.ApplicableOn =1 And SA.ItemGroup = 1 Then 'ITEM'
--								When SA.ApplicableOn =1 And SA.ItemGroup = 2 Then 'SPL_CAT'	
--								When SA.ApplicableOn = 2 Then 'INVOICE'
--								End,
--			@ItemGroup = Itemgroup
--			From tbl_mERP_SchemeAbstract SA
--			Where SA.SchemeID = @SchemeID and Sa.RFAApplicable = @RFAStatus
--			
--
--		Insert Into @tmpLesGrtDate Values (@SchemeID, @ActiveFrom, @ActiveTo)
--		Insert Into @tmpLesGrtDate Values (@SchemeID, @PayoutFrom, @PayoutTo) 
--		Insert Into @tmpLesGrtDate 	
--		Select @SchemeID, Min(InvoiceDate), Max(InvoiceDate) from InvoiceAbstract where InvoiceID In 
--		(Select IsNull(InvoiceRef,'') from SChemeCustomerItems where SchemeID = @SchemeID and payoutid = @payoutID 
--		and Claimed = 1 and IsInvoiced = 1 and IsNull(InvoiceRef,'') <> '' and IsNull(InvoiceRef,'') Not Like '%,%' )
--		and IsNull(Status,0) & 128 = 0
--
--		Set @Counter = @Counter + 1 
--	End

--	Set @Counter = 1
--	While @Counter <= @RowCount
--	Begin
--		Set @SchemeID = 0
--		Set @PayoutID = 0
--		
--		Select @SchemeID = Schemeid,@PayoutID = PayoutID from #tmpScheme Where [RowID] = @Counter
--		Delete @tmpSKU
--
--
--			Select @SchemeType = SA.SchemeType,
--			@ActivityCode = SA.ActivityCode, 
--			@CSSchemeID = SA.CS_RecSchID,
--			@ActivityType = SA.Description,
--			@ActiveFrom = SA.ActiveFrom, 
--			@ActiveTo = SA.ActiveTo, 
--			@PayoutFrom = @FromDate, 
--			@PayoutTo = @ToDate,
--			@ExpiryDate = SA.ExpiryDate,	
--			@ApplicableOn = Case When SA.ApplicableOn =1 And SA.ItemGroup = 1 Then 'ITEM'
--								When SA.ApplicableOn =1 And SA.ItemGroup = 2 Then 'SPL_CAT'	
--								When SA.ApplicableOn = 2 Then 'INVOICE'
--								End,
--			@ItemGroup = Itemgroup
--			From tbl_mERP_SchemeAbstract SA
--			Where SA.SchemeID = @SchemeID
--
--		Select @PayoutPeriod = Cast(Convert(Char(11), @PayoutFrom, 103) As nVarchar) + N'- ' + Cast(Convert(Char(11), @PayoutTo, 103) As nVarchar)
--				Delete @tmpPayout
--				Insert Into @tmpPayout
--				Select SchemeID,ID,PayoutPeriodFrom,PayoutPeriodTo From tbl_mERP_SchemePayoutPeriod
--				Where schemeid = @SchemeID
--				and schemeid in(select distinct schemeid from tbl_mERP_SchemeOutlet Where isnull(QPS,0) = 1 ) and Active = 1
----				and  PayoutPeriodFrom >= @FromDate and PayoutPeriodTo <= @ToDate  and isnull(Status,0) <> 0  
--				and  PayoutPeriodTo Between @Fromdate and @Todate
--                -- and isnull(Status,0) <> 0  
--							
--				Declare @QPSSchemeID int
--				Declare @QPSPayoutID int
--				Declare @QPSPayoutPeriodFrom DateTime
--				Declare @QPSPayoutPeriodTo DateTime
--
--				Declare @clu_0 Cursor 
--				Set @clu_0 = Cursor for
--				Select Schemeid,PayoutID,PayoutPeriodFrom,PayoutPeriodTo from @tmpPayout
--				Open @clu_0
--				Fetch Next from @clu_0 into @QPSSchemeID,@QPSPayoutID,@QPSPayoutPeriodFrom,@QPSPayoutPeriodTo
--				While @@fetch_status =0
--					Begin
--
--						
--						Insert Into #TmpSchememaster(SchemeID, ActivityCode, Description, ApplicablePeriod,RFAPeriod)
--						Select Cast(@QPSSchemeID as nVarchar(1000)) + '|'+ Cast(@QPSPayoutID as nVarchar(1000)), @ActivityCode, @ActivityType, 
--						Cast(Convert(Char(11), @ActiveFrom, 103) As nVarchar) + N'- ' + Cast(Convert(Char(11), @ActiveTo, 103) As nVarchar),
--						Cast(Convert(Char(11), @QPSPayoutPeriodFrom, 103) As nVarchar) + N'- ' + Cast(Convert(Char(11), @QPSPayoutPeriodTo, 103) As nVarchar)
--						--Where @SchemeID in (select Distinct SchemeID from tbl_mERP_QPSDtlData )
--						Fetch Next from @clu_0 into @QPSSchemeID,@QPSPayoutID,@QPSPayoutPeriodFrom,@QPSPayoutPeriodTo
--					End
--				Close @clu_0
--				Deallocate @clu_0
--
--				Insert Into #TmpSchememaster(SchemeID, ActivityCode, Description, [ApplicablePeriod],[RFAPeriod])
--				Select Cast(@SchemeID as nVarchar(1000)) + '|'+ Cast(@PayoutID as nVarchar(1000)), @ActivityCode, @ActivityType, 
--							Cast(Convert(Char(11), @ActiveFrom, 103) As nVarchar) + N'- ' + Cast(Convert(Char(11), @ActiveTo, 103) As nVarchar),
--							Cast(Convert(Char(11), @PayoutFrom, 103) As nVarchar) + N'- ' + Cast(Convert(Char(11), @PayoutTo, 103) As nVarchar)
--				Where @SchemeID in (select Distinct SchemeID	from tbl_merp_NonQPSData where dbo.striptimefromdate(Invoicedate) between @FromDate and @ToDate)
--
--		Set @Counter = @Counter + 1 
--	End
				Truncate Table #tmpPayout1
				Insert Into #tmpPayout1
				Select SchemeID,ID,PayoutPeriodFrom,PayoutPeriodTo From tbl_mERP_SchemePayoutPeriod
				Where schemeid in (select Schemeid from #tmpScheme) 
				and schemeid in(select distinct schemeid from tbl_mERP_SchemeOutlet Where isnull(QPS,0) = 1 ) and Active = 1
				and  PayoutPeriodTo Between @Fromdate and @Todate and isnull(Status,0) <> 0  
				
				
				
				Insert Into #TmpSchememaster(SchemeID,PayoutID, ActivityCode, Description, ApplicablePeriod,RFAPeriod) 
				Select #tmpPayout1.Schemeid ,#tmpPayout1.PayoutID,
						 SA.ActivityCode, SA.Description, 
						Cast(Convert(Char(11), SA.ActiveFrom, 103) As nVarchar) + N'- ' + Cast(Convert(Char(11), SA.ActiveTo, 103) As nVarchar),
						Cast(Convert(Char(11), #tmpPayout1.PayoutPeriodFrom, 103) As nVarchar) + N'- ' + Cast(Convert(Char(11), #tmpPayout1.PayoutPeriodTo, 103) As nVarchar)
						From #tmpPayout1,tbl_mERP_SchemeAbstract SA
						Where #tmpPayout1.SchemeID in (select Distinct SchemeID from tbl_mERP_QPSDtlData )
						And #tmpPayout1.SchemeID = SA.SchemeID
			
				Select Distinct SchemeID Into #NonQpsSchemes from tbl_merp_NonQPSData where dbo.striptimefromdate(Invoicedate) between @FromDate and @ToDate
				
				Insert Into #TmpSchememaster(SchemeID,PayoutID, ActivityCode, Description, [ApplicablePeriod],[RFAPeriod])
				Select SA.SchemeID ,#tmpScheme.PayoutID,		
						  SA.ActivityCode, SA.Description, 
							Cast(Convert(Char(11), SA.ActiveFrom, 103) As nVarchar) + N'- ' + Cast(Convert(Char(11), SA.ActiveTo, 103) As nVarchar),
							Cast(Convert(Char(11), @FromDate, 103) As nVarchar) + N'- ' + Cast(Convert(Char(11), @ToDate, 103) As nVarchar)
				From tbl_mERP_SchemeAbstract SA,#tmpScheme,#NonQpsSchemes NQ
				Where SA.SchemeID = NQ.SchemeID 
				--Where SA.SchemeID in (select Distinct SchemeID	from tbl_merp_NonQPSData where dbo.striptimefromdate(Invoicedate) between @FromDate and @ToDate)
				And SA.SchemeID = #tmpScheme.SchemeID
				
				Set @IsRFAClaimed = dbo.LookupDictionaryItem(N'No', Default)

				Set @SUBTOTAL = dbo.LookupDictionaryItem(N'Sub Total:', Default)     
				Set @GRNTOTAL = dbo.LookupDictionaryItem(N'Grand Total:', Default)     
				Set @QPSCRDTNOTE = dbo.LookupDictionaryItem(N'QPS Credit Note', Default)     
				Select @LastInventoryuploadDate  = convert(nvarchar(10),lastinventoryupload,103) from Setup
				Select @TaxConfigFlag = IsNull(Flag, 0) From tbl_merp_ConfigAbstract 
				Where ScreenCode Like 'RFA01'
				
				Declare @CrNoteFlag int	
				Select @CrNoteFlag = IsNull(Flag, 0) From tbl_merp_ConfigAbstract 
				Where ScreenCode Like 'RFA02'

				Set @RFAStatus = 0
				set @Product_Hierarchy = 'System SKU' 

--*************************************************************************************************
Begin

/* Report should be Send only if the QPS is generated for the all payout */
--*************************************************************************************************
	
--	Declare @tSchID as Nvarchar(255)
--	Declare @tPayID as Nvarchar(255)
	Declare @tSchID as int
	Declare @tPayID as int
	Declare @tSchPayID as Nvarchar(255)
	Declare @QPSGenStatus as Int
	Declare @NewCur Cursor 
	Set @QPSGenStatus = 0
	Set @NewCur = Cursor for
	Select Schemeid,PayoutID from #TmpSchememaster
	Open @NewCur
	Fetch Next from @NewCur into @tSchID,@tPayID
	While @@fetch_status =0
		Begin
--			Select @tSchID = Substring(@tSchPayID,1,CharIndex('|',@tSchPayID)-1)
--			Select @tPayID = Substring(@tSchPayID,CharIndex('|',@tSchPayID)+1,Len(@tSchPayID))
			If Exists (select top 1 * from tbl_mERP_SchemeOutlet Where schemeid = @tSchID and QPS = 1) and isnull(@tPayID,0) <> 0
				Begin
					If Exists (select Top 1 * from tbl_mERP_SchemePayoutPeriod Where schemeid = @tSchID and Id = @tPayID and isnull(Status,0) = 0)
						Begin
							Set @QPSGenStatus = 1
							If Not Exists (select Top 1 * from tbl_merp_QPSdtldata where schemeid = @tSchID and payoutid = @tPayID)
								Begin
									Set @QPSGenStatus = 1
								End
						End
			End
			Fetch Next from @NewCur into @tSchID,@tPayID
		End
	Close @NewCur
	Deallocate @NewCur

	If @QPSGenStatus = 1 
		Goto OvernOut1
	Else


--Optim4Cur_6

Declare @RowID Int
Declare @InvFDt DateTime
Declare @InvTDt DateTime

Select @InvFDt = (Select Min(ActiveFrom) from tbl_mERP_SchemeAbstract SA Join #TmpSchememaster TSA On TSA.Schemeid = SA.SchemeID)
Select @InvTDt = (Select Max(ActiveTo) from tbl_mERP_SchemeAbstract SA Join #TmpSchememaster TSA On TSA.Schemeid = SA.SchemeID)

If OBJECT_ID('tempdb..#tbl_merp_NonQPSData') is not null
	Drop Table #tbl_merp_NonQPSData

Select NQ.* Into #tbl_merp_NonQPSData 
From tbl_merp_NonQPSData NQ
Join (Select Distinct Schemeid From #TmpSchememaster) TSA On TSA.Schemeid = NQ.SchemeID 
And OriginalInvDate Between @InvFDt And @InvTDt 
And OriginalInvDate Between @FromDate And @ToDate 

If OBJECT_ID('tempdb..#fnRebateValCalc') is not null
	Drop Table #fnRebateValCalc

Select SlabID = SSD.SlabID, ItemFree= Case Max(SlabType) When 1 Then 0 When 2 Then 0 Else 1 End    
Into #fnRebateValCalc
From tbl_mERP_SchemeSlabDetail SSD
Join #tbl_merp_NonQPSData NQD On NQD.SlabID = SSD.SlabID 
Group By SSD.SlabID 

Select InvoiceID = IA.InvoiceID, InvoiceDate = IA.InvoiceDate, Status = IA.Status, DocumentID= IA.DocumentID ,
InvoiceType = IA.InvoiceType, CancelDate  = IA.CancelDate, CustomerID = IA.CustomerID, Type1InvDt=IA.InvoiceDate
Into #InvAbs4Dt from InvoiceAbstract IA 
Where IA.InvoiceType = 1
And dbo.StripDateFromTime(InvoiceDate) between dbo.StripDateFromTime(@InvFDt) and dbo.StripDateFromTime(@InvTDt)
And dbo.StripDateFromTime(InvoiceDate) between dbo.StripDateFromTime(@FromDate) and dbo.StripDateFromTime(@ToDate)

Insert Into #tmpFinalSchList (SchemeID,PayoutID,ActivityCode,Description,ApplicablePeriod,RFAPeriod)
Select Distinct SchemeID,PayoutID,ActivityCode,Description,ApplicablePeriod,RFAPeriod From #TmpSchememaster 

Declare Cur_6Opt Cursor For
Select RowID, SchemeID,PayoutID,ActivityCode,Description,ApplicablePeriod,RFAPeriod From #tmpFinalSchList

Open Cur_6Opt
Fetch From Cur_6Opt Into @RowID,@SchemeID,@PayoutID,@ActivityCode,@Description,@ApplicablePeriod,@RFAPeriod
While @@Fetch_Status = 0
Begin

	Select	@ActiveFrom = SA.ActiveFrom, @ActiveTo = SA.ActiveTo, 
				@PayoutFrom = @FromDate, @PayoutTo = @ToDate
	From tbl_mERP_SchemeAbstract SA Where SA.SchemeID = @SchemeID
	
	Insert Into #tmpLesGrtDate Values (@SchemeID, @ActiveFrom, @ActiveTo)
	Insert Into #tmpLesGrtDate Values (@SchemeID, @PayoutFrom, @PayoutTo) 
	
	Insert Into #tmpLesGrtDate 	
	Select @SchemeID, Min(InvoiceDate), Max(InvoiceDate) 
	From InvoiceAbstract IA
	Join SChemeCustomerItems SCI On Cast(SCI.InvoiceRef as Int) = IA.InvoiceID  And SCI.SchemeID = @SchemeID and SCI.PayoutID = @payoutID 
	and IsNull(SCI.Claimed,0) = 1 and isNull(SCI.IsInvoiced,0) = 1 and IsNull(SCI.InvoiceRef,'') <> '' and IsNull(SCI.InvoiceRef,'') Not Like '%,%' 
	Where IsNull(IA.Status,0) & 128 = 0	
	
	Insert Into #tmpLesGrtDate 
	Select @SchemeID, Min(IA3.InvoiceDate), Max(IA3.InvoiceDate) 
	From InvoiceAbstract IA3 
	Join #InvAbs4Dt IA1 On IA1.DocumentID = IA3.DocumentID and IA1.InvoiceType = 1
	And isnull(IA1.CancelDate,'') <> '' And IA1.CustomerID  = IA3.CustomerID
	And IA1.InvoiceDate Between @ActiveFrom And @ActiveTo 
	And IA1.InvoiceDate Between @PayoutFrom And @PayoutTo	
	where IA3.InvoiceType = 3
	
	If @PayoutID > 0
	Insert Into #tmpLesGrtDate 
	Select @SchemeID,SPP.PayoutPeriodFrom,SPP.PayoutPeriodTo 
	From tbl_mERP_SchemePayoutPeriod SPP 
	Where SPP.ID  = @PayoutID
	
	Fetch Next From Cur_6Opt Into @RowID,@SchemeID,@PayoutID,@ActivityCode,@Description,@ApplicablePeriod,@RFAPeriod
End
Close Cur_6Opt
Deallocate  Cur_6Opt
	
	Select @LesserDate = dbo.StripTimeFromDate(Min(PADateFrom)) From #tmpLesGrtDate
	Select @GreaterDate = dbo.StripTimeFromDate(Max(PADateTo)) From #tmpLesGrtDate

	Set @GreaterDate = DateAdd(ss,59,@GreaterDate)
	Set @GreaterDate = DateAdd(mi,59,@GreaterDate)
	Set @GreaterDate = DateAdd(hh,23,@GreaterDate)

	Insert into  #TmpTSRInvAbs
	Select InvoiceID,InvoiceType,InvoiceDate,CustomerID,BillingAddress,ShippingAddress,UserName,GrossValue,DiscountPercentage
	,DiscountValue,NetValue,CreationTime,Status,TaxLocation,InvoiceReference,ReferenceNumber,AdditionalDiscount,Freight
	,CreditTerm,PaymentDate,DocumentID,NewReference,NewInvoiceReference,OriginalInvoice,ClientID,Memo1,Memo2,Memo3
	,MemoLabel1,MemoLabel2,MemoLabel3,Flags,ReferredBy,Balance,SalesmanID,BeatID,PaymentMode,PaymentDetails,ReturnType
	,Salesman2,DocReference,AmountRecd,AdjRef,AdjustedAmount,GoodsValue,AddlDiscountValue,TotalTaxSuffered
	,TotalTaxApplicable,ProductDiscount,RoundOffAmount,AdjustmentValue,Denominations,ServiceCharge,BranchCode,CFormNo
	,DFormNo,CancelDate,VanNumber,TaxOnMRP,DocSerialType,SchemeID,SchemeDiscountPercentage,SchemeDiscountAmount
	,ClaimedAmount,ClaimedAlready,ExciseDuty,DiscountBeforeExcise,SalePriceBeforeExcise,CustomerPoints,VatTaxAmount
	,SONumber,GroupID,DeliveryStatus,DeliveryDate,InvoiceSchemeID,MultipleSchemeDetails  
	 From InvoiceAbstract
	--Where dbo.StripTimeFromDate(InvoiceDate) Between @LesserDate And  @GreaterDate And InvoiceType In (1,3,4)
	Where InvoiceDate Between @LesserDate And  @GreaterDate And InvoiceType In (1,3,4)

	Insert Into #TmpTSRInvDtl	
	Select [InvoiceID],[Product_Code],	[Batch_Code],[Batch_Number],[Quantity] ,[SalePrice],[TaxCode],[DiscountPercentage] ,
	[DiscountValue] ,[Amount] ,[PurchasePrice],[STPayable],	[FlagWord],	[SaleID],[PTR],[PTS],[MRP],[TaxID],[CSTPayable],[TaxCode2],
	[TaxSuffered],[TaxSuffered2],[ReasonID],[UOM],[UOMQty],[UOMPrice],[ComboID],[Serial],[FreeSerial],[SPLCATSerial],[SpecialCategoryScheme] ,
	[SCHEMEID] ,[SPLCATSCHEMEID],[SCHEMEDISCPERCENT],[SCHEMEDISCAMOUNT],[SPLCATDISCPERCENT],[SPLCATDISCAMOUNT],	[ExciseDuty],[SalePriceBeforeExciseAmount],
	[ExciseID] ,[salesstaffid] ,[TaxSuffApplicableOn],[TaxSuffPartOff],[Vat] ,[CollectTaxSuffered],[TaxAmount],[TaxSuffAmount],[STCredit],[TaxApplicableOn],
	[TaxPartOff],[OtherCG_Item],[SplCatCode],[QuotationID],[MultipleSchemeID],[MultipleSplCatSchemeID],[TotSchemeAmount],[MultipleSchemeDetails],
	[MultipleSplCategorySchDetail],[MultipleRebateID],[MultipleRebateDet],[RebateRate],[GroupID],[TAXONQTY] From InvoiceDetail 
	Where InvoiceID In (Select InvoiceID From #TmpTSRInvAbs)

--Optim4Cur_6

Declare Cur_6 Cursor For
--Select Distinct SchemeID,ActivityCode,Description,ApplicablePeriod,RFAPeriod From #TmpSchememaster 
Select Distinct SchemeID,PayoutID,ActivityCode,Description,ApplicablePeriod,RFAPeriod From #TmpSchememaster 
Open Cur_6
--Fetch From Cur_6 Into @SchemeDet,@ActivityCode,@Description,@ApplicablePeriod,@RFAPeriod
Fetch From Cur_6 Into @SchemeID,@PayoutID,@ActivityCode,@Description,@ApplicablePeriod,@RFAPeriod	
While @@Fetch_Status = 0
Begin
--*************************************************************************************************
Begin
	--Truncate table #TmpTSRInvDtl
	--Truncate table #TmpTSRInvAbs
  
--	Set @IsRFAClaimed = dbo.LookupDictionaryItem(N'No', Default)
--
--	Set @SUBTOTAL = dbo.LookupDictionaryItem(N'Sub Total:', Default)     
--	Set @GRNTOTAL = dbo.LookupDictionaryItem(N'Grand Total:', Default)     
--	Set @QPSCRDTNOTE = dbo.LookupDictionaryItem(N'QPS Credit Note', Default)     
--	
--	Select @LastInventoryuploadDate  = convert(nvarchar(10),lastinventoryupload,103) from Setup
--
--	/* Checking for Tax Configuration /
--	For Rebate Value calculation for Free Item*/
--	Select @TaxConfigFlag = IsNull(Flag, 0) From tbl_merp_ConfigAbstract 
--	Where ScreenCode Like 'RFA01'
--
--	/* Based on the RFA Config Changes As on 29.11.2010 for CreditNote we are maintaining separate Flag */
--	Declare @CrNoteFlag int	
--	Select @CrNoteFlag = IsNull(Flag, 0) From tbl_merp_ConfigAbstract 
--	Where ScreenCode Like 'RFA02'
--
--	/* Based on the RFA Config Changes As on 29.11.2010 for CreditNote we are maintaining separate Flag */
--	Set @RFAStatus = 0
--	set @Product_Hierarchy = 'System SKU' 
--	Select @SchemeID = Substring(@SchemeDet,1,CharIndex('|',@SchemeDet)-1)
--	Select @PayoutID = Substring(@SchemeDet,CharIndex('|',@SchemeDet)+1,Len(@SchemeDet))

	/* To chk whether the passed scheme is valid */	
	If @SchemeID <=0 
	GoTo OverNOut
	
	--Select @szPayoutID = Substring(@SchemeDet,CharIndex('|',@SchemeDet)+1,Len(@SchemeDet))
	select @szPayoutID = @PayoutID
	
		Select @SchemeType = SA.SchemeType,
		@ActivityCode = SA.ActivityCode, 
		@CSSchemeID = SA.CS_RecSchID,
		@ActivityType = SA.Description,
		@ActiveFrom = SA.ActiveFrom, 
		@ActiveTo = SA.ActiveTo, 
		@PayoutFrom = @FromDate, 
		@PayoutTo = @ToDate,
--		@ExpiryDate = SA.ExpiryDate,	
		@ApplicableOn = Case When SA.ApplicableOn =1 And SA.ItemGroup = 1 Then 'ITEM'
							When SA.ApplicableOn =1 And SA.ItemGroup = 2 Then 'SPL_CAT'	
							When SA.ApplicableOn = 2 Then 'INVOICE'
							End,
		@ItemGroup = Itemgroup
		From tbl_mERP_SchemeAbstract SA
		Where SA.SchemeID = @SchemeID
			
	--Insert Into #tmpLesGrtDate Values (@SchemeID, @ActiveFrom, @ActiveTo)
	--Insert Into #tmpLesGrtDate Values (@SchemeID, @PayoutFrom, @PayoutTo) 
	--Insert Into #tmpLesGrtDate 	
	--Select @SchemeID, Min(InvoiceDate), Max(InvoiceDate) from InvoiceAbstract where InvoiceID In 
	--(Select IsNull(InvoiceRef,'') from SChemeCustomerItems where SchemeID = @SchemeID and payoutid = @payoutID 
	--and IsNull(Claimed,0) = 1 and isNull(IsInvoiced,0) = 1 and IsNull(InvoiceRef,'') <> '' and IsNull(InvoiceRef,'') Not Like '%,%' )
	--and IsNull(Status,0) & 128 = 0

	--Insert Into #tmpLesGrtDate 
	--Select @SchemeID, Min(InvoiceDate), Max(InvoiceDate) from InvoiceAbstract IA where 
	--IA.InvoiceType = 3 And 
	--(Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID = 
	--				IA.DocumentID
	--				And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)
	--				Between @ActiveFrom And @ActiveTo 
	--	And 
	--		(Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID = 
	--				IA.DocumentID
	--				And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)
	--		Between @PayoutFrom And @PayoutTo



--	If @szPayoutID > 0
--		Begin
--			Select @LesserDate = (select Top 1 PayoutPeriodFrom From tbl_mERP_SchemePayoutPeriod Where Id = @szPayoutID)
--			Select @GreaterDate = (Select Top 1 PayoutPeriodTo From tbl_mERP_SchemePayoutPeriod Where Id = @szPayoutID)
--		End
--	Else
--		Begin
--			Select @LesserDate = dbo.StripTimeFromDate(Min(PADateFrom)) From #tmpLesGrtDate 
--			Select @GreaterDate = dbo.StripTimeFromDate(Max(PADateTo)) From #tmpLesGrtDate 
----			Select @LesserDate = dbo.StripTimeFromDate(Max(PADateFrom)) From #tmpLesGrtDate 
----			Select @GreaterDate = dbo.StripTimeFromDate(Min(PADateTo)) From #tmpLesGrtDate 
--		End

--Set @GreaterDate = DateAdd(ss,59,@GreaterDate)
--Set @GreaterDate = DateAdd(mi,59,@GreaterDate)
--Set @GreaterDate = DateAdd(hh,23,@GreaterDate)

--	DECLARE @sql NvARCHAR(4000)
	--Insert into  #TmpTSRInvAbs
	--Select InvoiceID,InvoiceType,InvoiceDate,CustomerID,BillingAddress,ShippingAddress,UserName,GrossValue,DiscountPercentage
	--,DiscountValue,NetValue,CreationTime,Status,TaxLocation,InvoiceReference,ReferenceNumber,AdditionalDiscount,Freight
	--,CreditTerm,PaymentDate,DocumentID,NewReference,NewInvoiceReference,OriginalInvoice,ClientID,Memo1,Memo2,Memo3
	--,MemoLabel1,MemoLabel2,MemoLabel3,Flags,ReferredBy,Balance,SalesmanID,BeatID,PaymentMode,PaymentDetails,ReturnType
	--,Salesman2,DocReference,AmountRecd,AdjRef,AdjustedAmount,GoodsValue,AddlDiscountValue,TotalTaxSuffered
	--,TotalTaxApplicable,ProductDiscount,RoundOffAmount,AdjustmentValue,Denominations,ServiceCharge,BranchCode,CFormNo
	--,DFormNo,CancelDate,VanNumber,TaxOnMRP,DocSerialType,SchemeID,SchemeDiscountPercentage,SchemeDiscountAmount
	--,ClaimedAmount,ClaimedAlready,ExciseDuty,DiscountBeforeExcise,SalePriceBeforeExcise,CustomerPoints,VatTaxAmount
	--,SONumber,GroupID,DeliveryStatus,DeliveryDate,InvoiceSchemeID,MultipleSchemeDetails  
	-- From InvoiceAbstract --where 1=2
	----Where dbo.StripTimeFromDate(InvoiceDate) Between @LesserDate And  @GreaterDate And InvoiceType In (1,3,4)
	--Where InvoiceDate Between @LesserDate And  @GreaterDate And InvoiceType In (1,3,4)

/*
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
*/
	--Insert Into #TmpTSRInvDtl	
	--Select [InvoiceID],[Product_Code],	[Batch_Code],[Batch_Number],[Quantity] ,[SalePrice],[TaxCode],[DiscountPercentage] ,
	--[DiscountValue] ,[Amount] ,[PurchasePrice],[STPayable],	[FlagWord],	[SaleID],[PTR],[PTS],[MRP],[TaxID],[CSTPayable],[TaxCode2],
	--[TaxSuffered],[TaxSuffered2],[ReasonID],[UOM],[UOMQty],[UOMPrice],[ComboID],[Serial],[FreeSerial],[SPLCATSerial],[SpecialCategoryScheme] ,
	--[SCHEMEID] ,[SPLCATSCHEMEID],[SCHEMEDISCPERCENT],[SCHEMEDISCAMOUNT],[SPLCATDISCPERCENT],[SPLCATDISCAMOUNT],	[ExciseDuty],[SalePriceBeforeExciseAmount],
	--[ExciseID] ,[salesstaffid] ,[TaxSuffApplicableOn],[TaxSuffPartOff],[Vat] ,[CollectTaxSuffered],[TaxAmount],[TaxSuffAmount],[STCredit],[TaxApplicableOn],
	--[TaxPartOff],[OtherCG_Item],[SplCatCode],[QuotationID],[MultipleSchemeID],[MultipleSplCatSchemeID],[TotSchemeAmount],[MultipleSchemeDetails],
	--[MultipleSplCategorySchDetail],[MultipleRebateID],[MultipleRebateDet],[RebateRate],[GroupID],[TAXONQTY] From InvoiceDetail 
	--Where InvoiceID In (Select InvoiceID From #TmpTSRInvAbs)
	--=============================================================
	Insert Into #tmpPayout
	Select @SchemeID,* From dbo.sp_SplitIn2Rows(@szPayoutID,',')

	Declare @szInvFrom as Nvarchar(255)
	Declare @szInvTo as Nvarchar(255)
	Declare @InvFrom as DateTime
	Declare @InvTo as DateTime
	Select @szInvFrom = Substring(@RFAPeriod,1,CharIndex(' - ',@RFAPeriod)-1)
	Select @szInvTo = Substring(@RFAPeriod,CharIndex(' - ',@RFAPeriod)+3,Len(@RFAPeriod))

	Set @InvFrom = dbo.StripTimeFromDate(@szInvFrom)
	Set @InvTo =  dbo.StripTimeFromDate(@szInvTo)

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
		And IA.InvoiceDate Between @InvFrom and @InvTo
		And (Case IA.InvoiceType
				When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From #TmpTSRInvAbs Where DocumentID = 
				IA.DocumentID And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)
				Else dbo.StripTimeFromDate(IA.InvoiceDate)
				End) Between @ActiveFrom And @ActiveTo
		And (Case IA.InvoiceType
				When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From #TmpTSRInvAbs Where DocumentID = IA.DocumentID
				And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID) 
				Else dbo.StripTimeFromDate(IA.InvoiceDate)
				End) Between @PayoutFrom And @PayoutTo
	Group By ID.Product_Code, ID.FlagWord, ID.Serial, IA.InvoiceType, IA.Status, ID.InvoiceID

	
	if (select count(*) from #tmpSales) = 0
	Goto NoScheme	
	
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

		Set @QPS = -1 
		Select @QPS = Max(IsNull(QPS, 0)) From tbl_mERP_SchemeOutlet 
		Where SchemeID = @SchemeID And IsNull(QPS, 0) = 0 

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
					from InvoiceAbstract where  Invoiceid = @InvoiceID And invoicetype=4 And isnull(referencenumber,'') <> '' and isnumeric(referencenumber) = 0 ) 
					order by invoiceid desc) 
				Else
					Set @tmpInvoiceID = ( Select Top 1 InvoiceId from InvoiceAbstract where Status & 128 = 0 and DocumentId= (Select ReferenceNumber from InvoiceAbstract where  Invoiceid = @InvoiceID And invoicetype=4 and isnull(referencenumber,'') <> ''  ) order by invoiceid desc) 
			End
			Else
			Begin
				Set  @tmpInvoiceID = (Select Top 1 InvoiceId from InvoiceAbstract where Status & 128 = 0 and GSTFullDocID = @GSTFullDocID Order by InvoiceID Desc)
			End
			--Check if original invoice exist in that period.
			if Isnull(@tmpInvoiceid,0) <> 0				
				Select @InvRebateValue = Sum(RebateValue) From tbl_merp_nonqpsdata Where Invoiceid = @tmpInvoiceId And schemeid=@SchemeId And InvoiceType<>4 and isnull([Type],0)=0 

			If (@InvRebateValue + @SRRebateValue) < 0 
			Begin
			  Insert into #SkipSRInvScheme(SchemeID, InvoiceID, PayoutFrom, PayoutTo) Values (@SchemeID, @InvoiceID, @PayoutFrom, @PayoutTo )
			  Insert into #SkipSRInvScheme(SchemeID, InvoiceID, PayoutFrom, PayoutTo) Values (@SchemeID, @tmpInvoiceID, @PayoutFrom, @PayoutTo )
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
				--dbo.mERP_fn_ToGetRebateVal_ITC(IsNull(RebateQty, 0), [Type], SlabID), 
				Case When FN.ItemFree = 1 And [Type] = 0 Then 0 Else IsNull(RebateQty, 0) End,				
				Case When FN.ItemFree = 1 And [Type] = 0 Then 0 Else (Case @TaxConfigFlag When 1 Then IsNull(RebateValue_Tax, 0) Else IsNull(RebateValue, 0) End) End,				
				--Case @TaxConfigFlag When 1 Then 
				--	dbo.mERP_fn_ToGetRebateVal_ITC(IsNull(RebateValue_Tax, 0), [Type], SlabID)
				--Else
				--	dbo.mERP_fn_ToGetRebateVal_ITC(IsNull(RebateValue, 0), [Type], SlabID)
				--End, 
				--IsNull(TaxAmount, 0), 

--                IsNull((Case  When InvoiceType = 4 and ([Type] = 0 Or [Type] = 2 Or [Type] = 3) Then (PromotedValue * isNull(TaxPercent,0)/100 ) 
--                                  When InvoiceType = 1  and ([Type] = 0 Or [Type] = 2) Then (PromotedValue * isNull(TaxPercent,0)/100 ) 
--                               When InvoiceType = 3 and ([Type] = 0 Or [Type] = 2) Then (PromotedValue * isNull(TaxPercent,0)/100 ) 
--                 Else TaxAmount End),0) as TaxAmount,
				IsNull((Case  When InvoiceType = 4 and [Type] IN (0,2,3) Then (Case Isnull(TOQ,0) When 0 Then (PromotedValue * isNull(TaxPercent,0)/100 ) Else (IsNull(PromotedQty, 0) * isNull(TaxPercent,0))  End)
                                  When InvoiceType = 1  and [Type] IN (0,2) Then (Case Isnull(TOQ,0) When 0 Then (PromotedValue * isNull(TaxPercent,0)/100 ) Else (IsNull(PromotedQty, 0) * isNull(TaxPercent,0))  End)
                               When InvoiceType = 3 and [Type] IN(0,2) Then (Case Isnull(TOQ,0) When 0 Then (PromotedValue * isNull(TaxPercent,0)/100 )  Else (IsNull(PromotedQty, 0) * isNull(TaxPercent,0))  End)
                 Else TaxAmount End),0) as TaxAmount,				
				Case [Type] When 1 Then 1 Else 0 End, SchemeID, TaxPercent 
			From #tbl_merp_NonQPSData  NQD
			Left Join  #fnRebateValCalc FN On FN.SlabID = NQD.SlabID 
			Where SchemeID = @SchemeID And 
				OriginalInvDate Between @ActiveFrom And @ActiveTo And 
				OriginalInvDate Between @PayoutFrom And @PayoutTo And 
				InvoiceID Not in (Select Distinct InvoiceID From #SkipSRInvScheme Where SchemeID = @SchemeID And PayoutFrom = @PayoutFrom And PayoutTo = @PayoutTo)

			Update RFA Set Division = IC2.Category_Name, SubCategory = IC1.Category_Name, 
				MarketSKU = IC.Category_Name, UOM = U.Description
			From #RFAInfo RFA,Items I , ItemCategories IC, ItemCategories IC1,ItemCategories IC2,UOM U
			Where RFA.SKUCode = I.Product_Code And
				I.CategoryID = IC.CategoryID And
				IC.ParentID = IC1.CategoryID And
				IC1.ParentID = IC2.CategoryID And
				I.UOM = U.UOM

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
				--dbo.mERP_fn_ToGetRebateVal_ITC(IsNull(RebateQty, 0), [Type], SlabID), 
				Case When FN.ItemFree = 1 And [Type] = 0 Then 0 Else IsNull(RebateQty, 0) End,				
				Case When FN.ItemFree = 1 And [Type] = 0 Then 0 Else (Case @TaxConfigFlag When 1 Then IsNull(RebateValue_Tax, 0) Else IsNull(RebateValue, 0) End) End,				
				--Case @TaxConfigFlag When 1 Then 
				--	dbo.mERP_fn_ToGetRebateVal_ITC(IsNull(RebateValue_Tax, 0), [Type], SlabID) 
				--Else
				--	dbo.mERP_fn_ToGetRebateVal_ITC(IsNull(RebateValue, 0), [Type], SlabID) 
				--End, 
				IsNull(TaxAmount, 0), 
				Case [Type] When 1 Then 1 Else 0 End, SchemeID, TaxPercent 
			From #tbl_merp_NonQPSData  NQD
			Left Join  #fnRebateValCalc FN On FN.SlabID = NQD.SlabID 
			Where SchemeID = @SchemeID And 
				OriginalInvDate Between @ActiveFrom And @ActiveTo And 
				OriginalInvDate Between @PayoutFrom And @PayoutTo And 
				InvoiceID Not in (Select Distinct InvoiceID From #SkipSRInvScheme Where SchemeID = @SchemeID And PayoutFrom = @PayoutFrom And PayoutTo = @PayoutTo)
				
			Update RFA Set Division = IC2.Category_Name, SubCategory = IC1.Category_Name, 
				MarketSKU = IC.Category_Name, UOM = U.Description
			From #RFAInfo RFA,Items I , ItemCategories IC, ItemCategories IC1,ItemCategories IC2,UOM U
			Where RFA.SKUCode = I.Product_Code And
				I.CategoryID = IC.CategoryID And
				IC.ParentID = IC1.CategoryID And
				IC1.ParentID = IC2.CategoryID And
				I.UOM = U.UOM

			GoTo OverNOut 
		End	/*Trade - Invoice based schemes - End*/ 

		OverNOut:

		Insert Into #tmpSKU
		Select Distinct SKUCode From #RFAInfo Where IsNull(FlagWord, 0) = 0 And SchemeID = @SchemeID

		If @payoutid = 0
		Begin
			If @Product_Hierarchy = 'System SKU'
			Begin
				Insert Into #tmpSchemeoutput
				Select RFA.Division ,RFA.SKUCode,I.ProductName,RFA.UOM,LineType,Sum(RFA.SaleQty),Sum(RFA.SaleValue),
					   Sum(RFA.PromotedQty),Sum(RFA.PromotedValue),isNull(RFA.TaxCode,0),Sum(RFA.TaxAmount),
					   Sum(RFA.RebateQty),Sum(RFA.RebateValue)
				From   #RFAInfo RFA
				Left Outer Join Items I On RFA.SKUCode = I.Product_Code  
				Where  
				RFA.SchemeID = @SchemeID
				
				Group By RFA.Division ,RFA.SKUCode,I.ProductName,RFA.UOM,LineType,TaxCode
				Order By RFA.Division,LineType Desc,I.ProductName
			End
		End
	End

	Select @QPS = Max(IsNull(QPS, 0)) From tbl_mERP_SchemeOutlet Where SchemeID = @SchemeID And IsNull(QPS, 0) = 1 

	If @QPS = 1 --And @IsRFAClaimed <> 'Yes' 
	Begin
		Declare @Free Int
		Select @Free = (case Max(SlabType) When 3 Then 1 Else 0 End) From tbl_merp_schemeslabdetail Where SchemeID = @SchemeID
		--==================QPS scheme Begins=====================================================
-- If A Invoice having More than One item applied QPS Scheme then That all Items are Listed in the Report.(Before Only one Item Listed)
	Truncate table #tmpSKU
	Insert into #tmpSKU Select Distinct Product_code From tbl_merp_QPSdtldata Where  SchemeID =  @SchemeID

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
				Sum(Quantity) * (@MarginPTR + (Case @TaxConfigFlag When 1 Then (Case  Max(Isnull(ID.TAXONQTY,0)) When 0 then (@MarginPTR * Max(TaxCode)/100) Else (Sum(ID.Quantity) * Max(ID.TaxCode)) End ) Else 0 End)),
				1, 1, @SchemeID, @PayoutID, @MarginPTR, Max(ID.TaxCode), 
				(Case Max(Isnull(ID.TAXONQTY,0)) When 0 Then (Sum(ID.Quantity) * (@MarginPTR * (Max(ID.TaxCode) / 100))) Else (Sum(ID.Quantity) * Max(ID.TaxCode)) End ),
				(Case Max(Isnull(ID.TAXONQTY,0)) When 0 Then @MarginPTR + (@MarginPTR * (Max(ID.TaxCode) / 100)) Else @MarginPTR + Max(ID.TaxCode) End ),
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
		If Exists(Select Top 1 * From tbl_mERP_QPSDtlData Where SchemeID = @SchemeID And PayoutID = @PayoutID )
		Begin
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
							"TaxAmount" = (Case Max(qpsd.TOQ) When 0 Then Sum((IsNull(qpsd.Promoted_Val, 0) * IsNull(qpsd.TaxPercent, 0)) / 100) Else (Sum(qpsd.Promoted_Qty) * IsNull(qpsd.TaxPercent, 0)) End ), 
							"RebateQty" = Case When Sum(qpsd.Rebate_Qty) > 0 Then 0 Else Sum(qpsd.Rebate_Qty) End, 
							"RebateValue" = Case When Sum(qpsd.Rebate_Qty) > 0 Then 
								0 Else Case @CrNoteFlag When 1 Then Sum(qpsd.Rebate_Val) Else Sum(qpsd.RFARebate_Val) End End
						From tbl_mERP_QPSDtlData qpsd, Items I,#tmpCustomerID C,ItemCategories IC,ItemCategories IC1,ItemCategories IC2
						Where qpsd.SchemeID = @SchemeID 
							And qpsd.PayoutID = @PayoutID 
							And qpsd.Product_Code = I.Product_Code				
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
			End
		End
	End
--==================QPS scheme End=====================================================
	Insert Into #tmpAllSchemeoutput
	Select Division,Code,Name,UOM,Type,Sum(SaleQty),Sum(SaleValue),Sum(PromotedQty),Sum(PromotedValue),
	TaxPercentage,Sum(TaxAmount),Sum(RebateQty),Sum(RebateValue)
	From #tmpSchemeoutput
	Group By Division,Code,Name,UOM,Type,TaxPercentage	

	Delete From #tmpSKUWiseSales Where SKUCode Not In(Select Distinct IsNull(SkuCode, '') From #tmpSKU)
-- If The Sales Return is validated  QPS & Non QPS

	If (select Distinct Top 1 payoutId From #ValidateTable) = 0 and @QPS = 1
		Begin
			Truncate table #tmpSKU
		End

	Delete From #tmpSRSKUWiseSales Where SKUCode Not In(Select Distinct IsNull(SkuCode, '') From #tmpSKU)

--	Insert Into #tmpSKUWiseSales_2
--	Select * From #tmpSKUWiseSales

	Insert Into #tmpSRSKUWiseSales_2
	Select * From #tmpSRSKUWiseSales 
	If (Select Count(*) From #tmpSKUWiseSales) > 0 and @IsRFAClaimed <> 'Yes'
	Begin
		If @ApplicableOn = 'Item' Or  @ApplicableOn = 'SPL_CAT'	
		Begin
		If @Payoutid = 0
			Begin
			IF @Product_Hierarchy = 'System SKU'
			Begin
--				Update Schmoutput	
--				Set SaleQty = (Select  Sum(SalesQty) From #tmpSKUWiseSales Where SKUCode = Schmoutput.Code And 
--					TaxCode = Schmoutput.TaxPercentage) , 
--				SaleValue = (Select  Sum(SalesValue) From #tmpSKUWiseSales Where SKUCode = Schmoutput.Code And 
--					TaxCode = Schmoutput.TaxPercentage)
--				From #tmpAllSchemeoutput Schmoutput
--				Where Schmoutput.Type = 'MAIN'

				/* SR Item Salable */
--				Update Schmoutput	
--				Set SaleQty = (Select  Sum(IsNull(SalesQty, 0)) From #tmpSRSKUWiseSales Where SKUCode = Schmoutput.Code 
--					And ReturnType = 1 And TaxCode = Schmoutput.TaxPercentage) , 
--				SaleValue = (Select  Sum(IsNull(SalesValue, 0)) From #tmpSRSKUWiseSales Where SKUCode = Schmoutput.Code 
--					And ReturnType = 1 And TaxCode = Schmoutput.TaxPercentage)
--				From #tmpAllSchemeoutput Schmoutput
--				Where Schmoutput.Type like 'Sales Return - Saleable'

				/* SR Item Damages */
--				Update Schmoutput	
--				Set SaleQty = (Select  Sum(IsNull(SalesQty, 0)) From #tmpSRSKUWiseSales Where SKUCode = Schmoutput.Code 
--					And ReturnType = 2 And TaxCode = Schmoutput.TaxPercentage) , 
--				SaleValue = (Select  Sum(IsNull(SalesValue, 0)) From #tmpSRSKUWiseSales Where SKUCode = Schmoutput.Code 
--					And ReturnType = 2 And TaxCode = Schmoutput.TaxPercentage)
--				From #tmpAllSchemeoutput Schmoutput
--				Where Schmoutput.Type like 'Sales Return - Damaged'

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

				delete from #tmpSRSKUWiseSales_2

				/* Insert non scheme Main Items */ 
				Insert Into #tmpAllSchemeoutput 
				Select Division, SKUCode, 
				(Select ProductName From Items Where Product_Code = SKUCode),
				UOM, 'MAIN', Sum(SalesQty), Sum(SalesValue), 0, 0, TaxCode, 0, 0, 0 
				From #tmpSKUWiseSales_2  
				Group By Division, SKUCode, UOM, TaxCode

--			if Exists (select top 1 * from #tmpAllSchemeoutput Where [Type] like '%MAIN%')
--			Begin
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
--			End
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
--*********************************************************************************************************************************************
-- If The overall sales Qty is displayed from Invoice table. Handled sale Return Also.
if (select Distinct SlabType from tbl_mERP_SchemeSlabDetail Where schemeid = @schemeid) in (2,3)
Begin
	Declare @cur_9 Cursor 
	Set @cur_9 = Cursor for
	Select Code from #tmpFinal Where [Type] = 'MAIN'
	Open @cur_9
	Fetch Next from @cur_9 into @code
	While @@fetch_status =0
		Begin
			Set @SQty = 0
			Set @SValue = 0
			select @SQty = Sum(D.Quantity), @SValue = sum(D.Quantity * D.SalePrice) From #TmpTSRInvDtl D, #TmpTSRInvAbs A Where  D.Product_Code = @code and A.InvoiceType  in (1,3) and (A.Status & 128) = 0 and D.InvoiceId = A.InvoiceId And A.Invoicedate Between @InvFrom and @InvTo
				Begin
					Update #tmpFinal set SaleQty = @SQty, SaleValue = @SValue Where Code = @code and [Type] Like '%MAIN%'
				End

			Fetch Next from @cur_9 into @code
		End
	Close @cur_9
	Deallocate @cur_9
--	Update T Set T.SaleQty = M.Qty,T.SaleValue =  M.Svalue From
--	(Select D.Product_Code AS Product_Code ,Sum(Isnull(D.Quantity,0)) As Qty,Isnull(sum(D.Quantity * D.SalePrice),0) as Svalue From 
--	 #TmpTSRInvDtl D, #TmpTSRInvAbs A,#tmpFinal T where A.Invoicedate Between @InvFrom and @InvTo And  A.InvoiceType  in (1,3) and (A.Status & 128) = 0 
--	and D.InvoiceId = A.InvoiceId And  D.Product_Code IN (Select Distinct  Code from #tmpFinal Where [Type] = 'MAIN') 
--	Group by D.Product_Code) AS M,#tmpFinal AS T		
--	Where T.[Type] Like '%MAIN%' And  T.Code  = M.Product_Code	
End

		Insert into #tmpFinaldata ([WD Code],[WD Dest],FromDate,ToDate,ActivityCode,Description,[Applicable Period],[RFA Period],Division,
		Code,Name,UOM,Type,SaleQty,SaleValue,PromotedQty,PromotedValue,TaxPercentage,TaxAmount,RebateQty,RebateValue)
		select @WDCode,@WDDestCode,@FromDate,@ToDate,@ActivityCode,@Description,@ApplicablePeriod,@RFAPeriod,Division,
		Code,Name,UOM,Type,SaleQty,SaleValue,PromotedQty,PromotedValue,TaxPercentage,TaxAmount,RebateQty,RebateValue from #tmpFinal
		Where Division not in ('Grand Total:','Sub Total:')

if Not Exists(select Top 1 * from tbl_mERP_SchemeSlabDetail Where schemeid = @Schemeid and SlabType in (3,2))
	Begin
				Set @SQty = 0
				Set @SValue = 0
				Set @SRQty = 0
				Set @SRValue = 0
				Set @Qty = 0
				Set @Value = 0

		Declare @cur_8 Cursor 
		Set @cur_8 = Cursor for
		Select Code from #tmpFinaldata Where [Type] = 'MAIN'
		Open @cur_8
		Fetch Next from @cur_8 into @code
		While @@fetch_status =0
			Begin
				Set @SQty = 0
				Set @SValue = 0
				Set @SRQty = 0
				Set @SRValue = 0
				Set @Qty = 0
				Set @Value = 0
				select @SQty = Sum(D.Quantity), @SValue = sum(D.Quantity * D.SalePrice) From #TmpTSRInvDtl D, #TmpTSRInvAbs A Where  D.Product_Code = @code and A.InvoiceType  in (1,3) and (A.Status & 128) = 0 and D.InvoiceId = A.InvoiceId And A.Invoicedate Between @InvFrom and @InvTo
				select @SRQty = Sum(D.Quantity), @SRValue = sum(D.Quantity * D.SalePrice) From #TmpTSRInvDtl D, #TmpTSRInvAbs A Where  D.Product_Code = @code and A.InvoiceType  in (4) and (A.Status & 128) = 0 and D.InvoiceId = A.InvoiceId And A.Invoicedate Between @InvFrom and @InvTo
				SElect  @Qty = @SQty - @SRQty
				SElect @Value = @SValue - @SRValue
				If Not Exists (select top 1 * from #tmpFinaldata where [Type] Like '%Sales Return%' and Code = @code)
					Begin
						Update #tmpFinaldata set SaleQty = @Qty, SaleValue = @Value Where Code = @code and [Type] Like '%MAIN%'
					End
				Else
					Begin
						Update #tmpFinaldata set SaleQty = @SQty, SaleValue = @SValue Where Code = @code and [Type] Like '%MAIN%'
					End

				Fetch Next from @cur_8 into @code
			End
		Close @cur_8
		Deallocate @cur_8
	
--		Create Table #tmpQtySaleValue (
--		Code nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
--		SQty  Decimal(18,6),
--		SValue  Decimal(18,6),
--		SRQty  Decimal(18,6),
--		SRValue  Decimal(18,6) )
--		
--		Insert into #tmpQtySaleValue ([Code],SQty,SValue)
--		select D.Product_Code, Sum(D.Quantity), sum(D.Quantity * D.SalePrice) From #TmpTSRInvDtl D,#TmpTSRInvAbs A
--		Where A.Invoicedate Between @InvFrom and @InvTo And A.InvoiceType  in (1,3) and (A.Status & 128) = 0 and
--			  D.InvoiceId = A.InvoiceId And D.Product_Code in (Select Code from #tmpFinaldata Where [Type] = 'MAIN')
--		Group by  D.Product_Code
--		 
--		Insert into #tmpQtySaleValue ([Code],SRQty,SRValue)	
--		select D.Product_Code, Sum(D.Quantity), sum(D.Quantity * D.SalePrice) From #TmpTSRInvDtl D,#TmpTSRInvAbs A 
--		Where A.Invoicedate Between @InvFrom and @InvTo  and A.InvoiceType  in (4) and (A.Status & 128) = 0 and
--			  D.InvoiceId = A.InvoiceId And  D.Product_Code in (Select Code from #tmpFinaldata Where [Type] = 'MAIN')
--		Group by  D.Product_Code
--		
--		Update F set F.SaleQty = Abs(S.SQty - S.SRQty), F.SaleValue = Abs(S.SValue - S.SRValue) From #tmpFinaldata F, #tmpQtySaleValue S
--		Where F.Code = S.Code and F.[Type] Like '%MAIN%'
--		
--		Drop Table #tmpQtySaleValue
	End
--*********************************************************************************************************************************************
	End
End
	Delete From #RFAInfo
	Delete From #tmpSchemeoutput
	Delete From #tmpPayout
	Delete From #tmpFinal	
	Delete From #FreeInfo
	Delete From #tmpCustomerID
	Delete From #tmpAllSchemeoutput
	Delete From #tmpSKU	
	Delete From #tmpSales
	Delete From #tmpSKUWiseSales
	Delete From #tmpSRSKUWiseSales
	Delete From #tmpSKUWiseSales_2
	Delete From #tmpSRSKUWiseSales_2
--	Delete From #tmpLesGrtDate 
End /* End Of Procedure */	

If Not Exists (select Top 1 * from #ValidateTable Where ActivityCode = @ActivityCode and ApplicablePeriod = @ApplicablePeriod and RFAPeriod = @RFAPeriod and SchemeID = @schemeID and PayoutID = @szPayoutID)
--If Not Exists (select * from #tmpFinaldata Where ActivityCode = @ActivityCode and [Applicable Period] = @ApplicablePeriod and [RFA Period] = @RFAPeriod)
Begin
	Declare @Schtype as int
	Declare @ClaimsPrefix nVarchar(10)
	Declare @StkPrefix  nVarchar(10)
	Declare @CrNotePrefix  nVarchar(10)
	Declare @RebateQty Decimal(18,6)
	Declare @RebateValue Decimal(18,6)
	Declare @QPSSrNo Int
	Declare @TaxConfigCrdtNote Int
	
	Set @Schtype = 1
	Select @TaxConfigFlag = IsNull(Flag, 0) From tbl_merp_ConfigAbstract (NoLock)
	Where ScreenCode = 'RFA01'

	/* Tax Config flag for Credit Note */
	Select @TaxConfigCrdtNote = IsNull(Flag, 0) From tbl_merp_ConfigAbstract (NoLock)
	Where ScreenCode = 'RFA02'
	

	Set @FreeFlag = 0
	Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload  (NoLock)
	Select Top 1 @WDCode = RegisteredOwner From Setup (NoLock)
	If @CompaniesToUploadCode = N'ITC001'
		Set @WDDest= @WDCode  
	Else  
	Begin  
		Set @WDDest= @WDCode  
		Set @WDCode= @CompaniesToUploadCode  
	End   

	Select @InvPrefix = Prefix From VoucherPrefix (NoLock) Where TranID = 'INVOICE'
	Select @ClaimsPrefix = Prefix From VoucherPrefix (NoLock) Where TranID = 'CLAIMS NOTE'
	Select @StkPrefix = Prefix From VoucherPrefix (NoLock) Where TranID = 'STOCK ADJUSTMENT'	
	Select @CrNotePrefix = Prefix From VoucherPrefix (NoLock) Where TranID = 'CREDIT NOTE'	

	Create Table #RFAInfoTemp(SR Int Identity , InvoiceID Int, BillRef nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, OutletCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
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
							PointsValue Decimal(18,6), ReferenceNumber nVarchar(255), LoyaltyID nVarchar(255), CSSchemeID int,[Doc No] nVarchar(500) collate SQL_Latin1_General_CP1_CI_AS)

	Create Table #RFAAbstract (SR Int, Division nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							SubCategory nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, MarketSKU nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							UOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, SaleQty Decimal(18, 6), SaleValue Decimal(18, 6),
							PromotedQty Decimal(18, 6), PromotedValue Decimal(18, 6), FreeBaseUOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							RebateQty Decimal(18, 6), RebateValue Decimal(18, 6),BudgetedQty Decimal(18,6),  
							BudgetedValue Decimal(18,6))

	Create Table #RFADetail	(SR Int, Flagword Int, InvoiceID Int, SchemeID Int, BillRef nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, OutletCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							RCSID nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, ActiveInRCS nVarchar(100) collate SQL_Latin1_General_CP1_CI_AS, LineType nVarchar(50) collate SQL_Latin1_General_CP1_CI_AS, Division nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							SubCategory nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, MarketSKU nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							UOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, SaleQty Decimal(18, 6), SaleValue Decimal(18, 6),
							PromotedQty Decimal(18, 6), PromotedValue Decimal(18, 6),RebateQty Decimal(18, 6), RebateValue Decimal(18, 6), PriceExclTax Decimal(18, 6),
							TaxPercentage Decimal(18,6), TaxAmount Decimal(18, 6), PriceInclTax Decimal(18, 6),BudgetedQty Decimal(18,6),  BudgetedValue Decimal(18,6),InvoiceType Int,[Doc No]  nVarchar(500) collate SQL_Latin1_General_CP1_CI_AS)

	Create Table #Temp ( ID int Identity(1,1),  DocID nVarchar(255), DocType nVarchar(255),  DocIDNo nVarchar(255), FirstMonth nVarchar(255), LastMonth nVarchar(255), 
	SchemeType  Int, ClaimID Int, ClaimAmount decimal(18,6), LoyaltyID nVarchar(100), MName nVarchar(100)
	,GVYear nVarchar(100))

	Create Table #TempFinal ( ID int Identity(1,1), GVSchemetype nVarchar(100), DocID nVarchar(255), DocType nVarchar(255),  DocIDNo nVarchar(255), FMonth nVarchar(255), LMonth nVarchar(255), 
	SchemeType  Int, ClaimID Int, ClaimAmount decimal(18,6), LoyaltyID nVarchar(100), MName nVarchar(100), GVYear nVarchar(100))

	
	Create Table #tmpSKUWiseSalesTemp(SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS ,SalesQty Decimal(18,6),SalesValue Decimal(18,6))


	Create Table #tmpRFAAbs(WDCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							WDDest nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							SchemeType nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							ActivityCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							ActivityDesc nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							ActiveFrom nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							ActiveTo nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							PayoutFrom nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							PayoutTo nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							SR Int,Division nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							SubCategory nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							MarketSKU nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							UOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							SaleQty Decimal(18,6),SaleValue Decimal(18,6),
							PromotedQty Decimal(18,6),PromotedValue Decimal(18,6),
							FreeBaseUOM nVarchar(50) collate SQL_Latin1_General_CP1_CI_AS,
							RebateQty Decimal(18,6),RebateValue Decimal(18,6),BudgetedQty Decimal(18,6),
							BudgetedValue Decimal(18,6),AppOn nVarchar(50) collate SQL_Latin1_General_CP1_CI_AS)

	Create Table #tmpRFADet(WDCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						WDDest nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						ActivityCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						CompSchemeID Int,ActivityDesc nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						ActiveFrom nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						ActiveTo nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						SR Int,BillRef nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						OutletCode nVarchar(500) collate SQL_Latin1_General_CP1_CI_AS,
						RCSID nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						ActiveInRCS nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						LineType nVarchar(25) collate SQL_Latin1_General_CP1_CI_AS,
						Division nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						SubCategory nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						MarketSKU nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						UOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						SaleQty Decimal(18,6),SaleValue Decimal(18,6),
						PromotedQty Decimal(18,6),PromotedValue Decimal(18,6),
						RebateQty Decimal(18,6),RebateValue Decimal(18,6),
						PriceExclTax Decimal(18,6),TaxPercentage Decimal(18,6),TaxAmount Decimal(18,6),
						PriceInclTax Decimal(18,6),BudgetedQty Decimal(18,6),
						BudgetedValue Decimal(18,6),OutletName nVarchar(500) collate SQL_Latin1_General_CP1_CI_AS,
					    [Doc No] nVarchar(500) collate SQL_Latin1_General_CP1_CI_AS)

	Create Table #tmpFinalAbs(WDCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							WDDest nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							SchemeType nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							ActivityCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							ActivityDesc nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							ActiveFrom nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							ActiveTo nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							PayoutFrom nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							PayoutTo nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							SR Int,Division nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							SubCategory nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							MarketSKU nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							UOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
							SaleQty Decimal(18,6),SaleValue Decimal(18,6),
							PromotedQty Decimal(18,6),PromotedValue Decimal(18,6),
							FreeBaseUOM nVarchar(50) collate SQL_Latin1_General_CP1_CI_AS,
							RebateQty Decimal(18,6),RebateValue Decimal(18,6),BudgetedQty Decimal(18,6),
							BudgetedValue Decimal(18,6),AppOn nVarchar(50) collate SQL_Latin1_General_CP1_CI_AS)

	Create Table #tmpFinalDet(WDCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						WDDest nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						ActivityCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						CompSchemeID Int,ActivityDesc nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						ActiveFrom nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						ActiveTo nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						SR Int,BillRef nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						OutletCode nVarchar(500) collate SQL_Latin1_General_CP1_CI_AS,
						RCSID nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						ActiveInRCS nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						LineType nVarchar(25) collate SQL_Latin1_General_CP1_CI_AS,
						Division nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						SubCategory nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						MarketSKU nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						UOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						SaleQty Decimal(18,6),SaleValue Decimal(18,6),
						PromotedQty Decimal(18,6),PromotedValue Decimal(18,6),
						RebateQty Decimal(18,6),RebateValue Decimal(18,6),
						PriceExclTax Decimal(18,6),TaxPercentage Decimal(18,6),TaxAmount Decimal(18,6),
						PriceInclTax Decimal(18,6),BudgetedQty Decimal(18,6),
						BudgetedValue Decimal(18,6),OutletName nVarchar(500)  collate SQL_Latin1_General_CP1_CI_AS,
						[Doc No] nVarchar(500) collate SQL_Latin1_General_CP1_CI_AS)

	Create Table #tmpSalesTemp(SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						   SaleQty Decimal(18,6),SaleValue Decimal(18,6),
							Flagword Int,InvoiceType Int)

	Create Table #tmpSerial(Serial Int)

	Declare @D1 DateTime
	Declare @D2 DateTime
	Declare @LastDate as Int
	Declare @Dy int
	Declare @Mth int
	Declare @Yr int
	Declare @LDy int
	Declare @LMth int
	Declare @LYr int
	Declare @GVDocID nVarchar(1000)
	Declare @DocDate datetime
	Declare @MonthName nVarchar(10)
	Declare @Year nVarchar(10)
	Declare @PrevM datetime

Select @PrevM = DateAdd(m, -1, GetDate())

	If @SchType = 1 /*--SP Trade Scheme - Start*/
	Begin	

		/*Offtake scheme - Start*/	
		Select @SchemeType = ST.SchemeType,
			@ActivityCode = SA.ActivityCode, 
			@CSSchemeID = SA.CS_RecSchID,
			@ActivityType = SA.Description,
			@ActiveFrom = SA.ActiveFrom, 
			@ActiveTo = SA.ActiveTo, 
			@PayoutFrom = SPP.PayoutPeriodFrom, 
			@PayoutTo = SPP.PayoutPeriodTo,
--			@ExpiryDate = SA.ExpiryDate,	
			@ApplicableOn = Case When SA.ApplicableOn =1 And SA.ItemGroup = 1 Then 'ITEM'
								When SA.ApplicableOn =1 And SA.ItemGroup = 2 Then 'SPL_CAT'	
								When SA.ApplicableOn = 2 Then 'INVOICE'
								End,
			@ItemGroup = Itemgroup
			From tbl_mERP_SchemeAbstract SA(NoLock), tbl_mERP_SchemeType ST(NoLock), tbl_mERP_SchemePayoutPeriod SPP(NoLock)
			Where SA.SchemeID = @SchemeID
			And SA.ActivityCode = @ActivityCode
			And SA.SchemeType = ST.ID
			And SA.SchemeID = SPP.SchemeID
			And SPP.ID = @PayoutID

			
			
		    Select @QPS = QPS From tbl_mERP_SchemeOutlet (NoLock) Where SchemeID = @SchemeID And QPS = 1
	
			Select @ItemFree = (Case Max(SlabType) When 1 Then 0 When 2 Then 0 Else 1 End) From tbl_mERP_SchemeSlabDetail (NoLock) Where SchemeID = @SchemeID


		/* Table Used to store the Total Sales qty and Volume SKUWise Starts */

		Insert Into #tmpSalesTemp
		Select 	ID.Product_Code as SKUCode,
			Case ID.FlagWord
				When 0 Then ID.Quantity 
				Else 0 End	as SaleQty,
			Case ID.FlagWord
				When 0 Then ID.SalePrice * ID.Quantity 
				Else 0 End	as SaleValue,
			ID.FlagWord,
			InvoiceType
			From #TmpTSRInvAbs IA, #TmpTSRInvDtl ID, Customer C (NoLock)
			--From InvoiceAbstract IA(Nolock), InvoiceDetail ID (NoLock), Customer C (NoLock)
			Where IA.InvoiceId = ID.InvoiceId
			And IA.InvoiceType In (1,3,4)        
			And (IA.Status & 128) = 0  
			And IA.CustomerID = C.CustomerID
			And (Case IA.InvoiceType
						When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From #TmpTSRInvAbs --(NoLock) 
						Where DocumentID = 	IA.DocumentID
						And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)
						Else dbo.StripTimeFromDate(IA.InvoiceDate)
						End) Between @ActiveFrom And @ActiveTo
			And (Case IA.InvoiceType
					When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From #TmpTSRInvAbs --(NoLock) 
					Where DocumentID = IA.DocumentID
					And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID) 
					Else dbo.StripTimeFromDate(IA.InvoiceDate)
					End) Between @PayoutFrom And @PayoutTo

		-- Total Quantity and Total Sales Change
		/* To Insert ProductWise Sales From And To PayoutPeriod */
		Truncate table #tmpSKUWiseSalesTemp
		Insert Into #tmpSKUWiseSalesTemp(SKUCode,SalesQty,SalesValue)
		Select SKUCode,Sum(Case InvoiceType When 4 Then -1 * SaleQty Else SaleQty End),
		Sum(Case InvoiceType When 4 Then -1 * SaleValue Else SaleValue End) From #tmpSalesTemp 
		Where FlagWord = 0 
		Group By SKUCode

		
		/* Explore QPS Scheme */
		If @QPS = 1 /*Offtake scheme - starts*/
		Begin
			
			If @ItemFree = 1 
			Begin
				/* To Insert the Free Item */
				/*Free Qty scheme*/
				Declare OffTakeSKUCur Cursor For
				Select Distinct CustomerID, Product_Code, InvoiceRef 
				From SchemeCustomerItems (NoLock)
				Where SchemeID = @SchemeID 
				And PayoutID = @PayoutID
				And IsInvoiced = 1
				And Claimed = 1
				Open OffTakeSKUCur
				Fetch Next From OffTakeSKUCur Into @CustomerID, @SKUCode, @InvoiceRef
				While @@Fetch_Status = 0
				Begin
					Set @MarginPTR = 0
					Select @MarginPTR = dbo.mERP_fn_GetMarginPTR(@SKUCode,Cast(@InvoiceRef as Int), @SchemeID)

					Insert Into #RFAInfoTemp(InvoiceID, BillRef,OutletCode, SKUCode,RebateQty, RebateValue, SchemeOutlet, SchemeSKU, SchemeID,
							PriceExclTax, TaxPercentage, TaxAmount, PriceInclTax,LineType,[Doc No])
					Select IA.InvoiceID, @InvPrefix + Cast(IA.DocumentID as nVarchar) as BillRef, IA.CustomerID, @SKUCode,Sum(Quantity),
						Sum(Quantity) * (@MarginPTR + (Case @TaxConfigFlag When 1 Then (case Max(TAXONQTY) When 0 Then (@MarginPTR * Max(TaxCode)/100) Else  Max(TaxCode) End) Else 0 End)),
						 1, 1, @SchemeID, @MarginPTR, Max(ID.TaxCode), 
						(Case Max(ID.TAXONQTY) When 0 Then (Sum(ID.Quantity) * (@MarginPTR * (Max(ID.TaxCode) / 100))) Else (Sum(ID.Quantity) * Max(ID.TaxCode)) End ),
						(Case Max(ID.TAXONQTY) When 0 Then  @MarginPTR + (@MarginPTR * (Max(ID.TaxCode) / 100)) Else (@MarginPTR + Max(ID.TaxCode)) End ),'Free',
					    IA.DocReference
					    From #TmpTSRInvAbs IA, #TmpTSRInvDtl ID
						--From InvoiceAbstract IA (NoLock), InvoiceDetail ID (NoLock) 
						Where IA.InvoiceID = ID.InvoiceID
						And IA.InvoiceID = Cast(@InvoiceRef as Int)
						And IA.CustomerID = @CustomerID
						And ID.SchemeID = @SchemeID
						And ID.Product_Code = @SKUCode
						And IsNull(Flagword, 0) = 1
						Group By IA.InvoiceID,IA.DocumentID,IA.CustomerID,IA.DocReference
					Fetch Next From OffTakeSKUCur Into @CustomerID, @SKUCode, @InvoiceRef
				End
				Close OffTakeSKUCur
				Deallocate OffTakeSKUCur

			Update #RFAInfoTemp Set RCSID = IsNull(C.RCSOutletID,''),
			ActiveInRCS = (Case when IsNull(C.RCSOutletID,'') <> '' then 'Yes' else 'No' end)
			From  Customer C
			Where  C.CustomerID = #RFAInfoTemp.OutletCode 

			Update RFA Set Division = IC2.Category_Name, SubCategory = IC1.Category_Name, MarketSKU = IC.Category_Name, UOM = U.Description
				From #RFAInfoTemp RFA,Items I , ItemCategories IC, ItemCategories IC1,ItemCategories IC2,UOM U
				Where RFA.SKUCode = I.Product_Code And
				I.CategoryID = IC.CategoryID And
				IC.ParentID = IC1.CategoryID And
				IC1.ParentID = IC2.CategoryID And
				I.UOM = U.UOM
			End
			
			If @ApplicableOn = N'ITEM'  Or @ApplicableOn = 'SPL_CAT'

			Begin /*Offtake - Free Item Based Scheme  Starts*/
				If Exists(Select * from tbl_mERP_QPSDtlData (NoLock) Where Schemeid = @SchemeID and payoutid = @PayoutID And QPSAbsDataID = 2 
						  And isNull(Promoted_Qty,0) = 0 And isNull(Promoted_Val,0) = 0 And isNull(UOM1Qty,0) = 0 And isNull(UOM2Qty,0) = 0)
				Begin
					/* In case Of free item scheme for the previously generated Free item before Phase II fsu data correction
					   will be done and the records will be posted in the new table - tbl_mERP_QPSDtlData , if some free items
					   for some customers are adjusted after the Phase II fsu then those records will not be there in the new table.
					   Hence in case of free item schemes for which free item generated before phase II it is correct to get the
					   details from SchemeCustomerItems */
	
					/*Serial No. for Abstract data*/
					Set @SRNo = 0
					Declare PrimaryItem Cursor For 
					Select Distinct SKUCode From  #RFAInfoTemp
					Where SchemeID = @SchemeID 

					Open PrimaryItem 
					Fetch Next From PrimaryItem Into @SKUCode
					While (@@Fetch_Status = 0)
					Begin
						If @ApplicableOn = 'SPL_CAT'
							Set @SRNo = 0
						Else
							Set @SRNo = @SRNo + 1

						Insert Into #RFAAbstract Select @SRNo,	Division, SubCategory, MarketSKU, SKUCode, UOM, 
						Sum(SaleQty) , Sum(SaleValue) ,Sum(PromotedQty) ,Sum(PromotedValue),
						'' as FreeBaseUOM, Sum(RebateQty) , Sum(RebateValue),
						0 as BudgetedQty, 0 as BudgetedValue
						From #RFAInfoTemp
						Where SchemeID = @SchemeID
						And SKUCode = @SKUCode
						Group By SKUCode, Division, SubCategory, MarketSKU, UOM
						Order By SKUCode

						Insert Into #RFADetail 
						Select @SRNo, 1, InvoiceID, SchemeId, BillRef , OutletCode ,
						RCSID , ActiveInRCS, LineType , Division ,
						SubCategory , MarketSKU , SKUCode ,
						UOM , Sum(SaleQty) , Sum(SaleValue) ,
						Sum(PromotedQty) ,Sum(PromotedValue) ,Sum(RebateQty) , Sum(RebateValue) , Sum(PriceExclTax) ,
						Max(TaxPercentage) , Sum(TaxAmount) , Sum(PriceInclTax) ,0 ,  Sum(BudgetedValue) , InvoiceType,[Doc No]
						From #RFAInfoTemp
						Where SchemeID = @SchemeID
						And SKUCode = @SKUCode
						Group By 
						InvoiceID, SchemeId, BillRef , OutletCode ,
						RCSID , ActiveInRCS, LineType , Division ,
						SubCategory , MarketSKU , SKUCode ,
						UOM ,InvoiceType,[Doc No]

						Fetch Next From PrimaryItem Into @SKUCode
					End
					Close PrimaryItem
					Deallocate PrimaryItem
					
					/* Serial  number not required for special category scheme  because if serial number is there for spl
					category scheme then free item is shown twice in RFA Screen*/
					If @ApplicableOn = 'SPL_CAT'
					Set @SRNo = 0

					Set @QPSSrNo = @SRNo

				End
				Else
				Begin
					/* Only the Free Item adjustded details should come */
					/* To Update the RFARebate value for the Primary Row */
					Select * Into #tmptbl_mERP_QPSDtlData From tbl_mERP_QPSDtlData (NoLock) 
					Where SchemeID = @SchemeID
					And PayoutID = @PayoutID
					And CustomerID In(Select OutletCode From #RFAInfoTemp)
					And (isNull(Rebate_Qty,0) > 0 Or isNull(Rebate_Val,0) > 0 Or IsNull(RFARebate_Val,0) > 0)

					Declare @TotRebateQty Decimal(18,6)

					Declare RebateVal Cursor For 
					Select Distinct OutletCode,Sum(RebateValue),Sum(RebateQty) From  #RFAInfoTemp
					Where SchemeID = @SchemeID 
					Group By OutletCode
					Open RebateVal 
					Fetch Next From RebateVal Into @CustomerID,@RebateValue,@RebateQty
					While (@@Fetch_Status = 0)
					Begin
				
						Select @TotRebateQty = Sum(Rebate_Qty)  
						From #tmptbl_mERP_QPSDtlData RFA
						Where CustomerID = @CustomerID And   isNull(Quantity,0) <> 0
										
						Update #tmptbl_mERP_QPSDtlData Set Rebate_Qty = (Rebate_Qty/@TotRebateQty)*@RebateQty
						Where CustomerID = @CustomerID And   isNull(Quantity,0) <> 0
						
						Update #tmptbl_mERP_QPSDtlData Set RFARebate_Val = (Rebate_Qty * @RebateValue)/@RebateQty,
						Rebate_Val = (Rebate_Qty * @RebateValue)/@RebateQty
						Where CustomerID = @CustomerID And   isNull(Quantity,0) <> 0

						Fetch Next From RebateVal Into @CustomerID,@RebateValue,@RebateQty
					End
					Close RebateVal
					Deallocate RebateVal

					/*Serial No. for Abstract data*/
					Set @SRNo = 0
					Declare PrimaryItem Cursor For 
					Select Distinct Product_Code From  tbl_mERP_QPSDtlData (NoLock)
					Where SchemeID = @SchemeID And PayoutID = @PayoutID

					Open PrimaryItem 
					Fetch Next From PrimaryItem Into @SKUCode
					While (@@Fetch_Status = 0)
					Begin
						If @ApplicableOn = 'SPL_CAT'
							Set @SRNo = 0
						Else
							Set @SRNo = @SRNo + 1

						Insert Into #RFAAbstract Select @SRNo,	Division, SubCategory, MarketSKU, Product_Code, UOM, Sum(IsNull(Quantity,0)) as SaleQty,
							Sum(IsNull(SalesValue,0)) as SaleValue, Sum(IsNull(Promoted_Qty,0)) as PromotedQty, Sum(IsNull(Promoted_Val,0)) as PromotedValue, 
							'' as FreeBaseUOM, Sum(IsNull(Rebate_Qty,0)) as RebateQty, 
							(case @TaxConfigFlag When 1 Then Sum(IsNull(Rebate_Val,0)) Else Sum(IsNull(RFARebate_Val,0)) End) as RebateValue, 
							0 as BudgetedQty, 0 as BudgetedValue
							From #tmptbl_mERP_QPSDtlData
							Where SchemeID = @SchemeID
							And PayoutID = @PayoutID
							And Product_Code = @SKUCode
							And (isNull(Rebate_Qty,0) > 0 Or isNull(Rebate_Val,0) > 0 Or IsNull(RFARebate_Val,0) > 0)
							And CustomerID In(Select OutletCode From #RFAInfoTemp)
							Group By Product_Code, Division, SubCategory, MarketSKU, UOM
							Order By Product_Code

						Insert Into #RFADetail 
							Select  @SRNo, 0, InvoiceID, SchemeId, BillRef , QPS.CustomerID ,
									IsNull(Cust.RCSOutletID, '') as RCSID,
									(Case when IsNull(Cust.RCSOutletID,'') <>  '' then 'Yes' else 'No' end) as ActiveInRCS ,
									'QPS' , Division ,
									SubCategory , MarketSKU , Product_Code ,
									UOM , Sum(Quantity) ,Sum(Quantity*SalePrice) ,
									Sum(Promoted_Qty) , Sum(Promoted_Val) ,Sum(Rebate_Qty) ,
									(case @TaxConfigFlag When 1 Then Sum(IsNull(Rebate_Val,0)) Else Sum(IsNull(RFARebate_Val,0)) End) as RebateValue, 
									Sum(SalePrice) as 'PriceExclTax',
									Max(isNull(TaxPercent,0)) as TaxPercentage, Sum(isNull(TaxAmount,0)) as TaxAmount,
									(Case Max(Isnull(QPS.TOQ,0)) When 0 then (Max(SalePrice) + (Max(isNull(SalePrice,0))*Max(isNull(TaxPercent,0))/100)) Else (Max(SalePrice) + Max(isNull(TaxPercent,0))) End )  as  'PriceInclTax',0 , 0, 1,InvDocRef
									From #tmptbl_mERP_QPSDtlData QPS,Customer Cust(NoLock)
									Where 
									QPS.SchemeID = @SchemeID
									And PayoutID = @PayoutID
									And (isNull(Rebate_Qty,0) > 0 Or isNull(Rebate_Val,0) > 0 Or IsNull(RFARebate_Val,0) > 0)
									And Product_Code = @SKUCode
									And isNull(QPS.Quantity,0) <> 0
									And QPS.CustomerID In(Select OutletCode From #RFAInfoTemp)
									And Cust.CustomerID = QPS.CustomerID 
									Group By InvoiceID, SchemeId, BillRef , QPS.CustomerID ,
									Division ,SubCategory , MarketSKU , Product_Code ,
									UOM,Cust.RCSOutletID,InvDocRef

						Fetch Next From PrimaryItem Into @SKUCode
					End
					Close PrimaryItem
					Deallocate PrimaryItem
					
				/* Serial  number not required for special category scheme  because if serial number is there for spl
					category scheme then free item is shown twice in RFA Screen*/
				If @ApplicableOn = 'SPL_CAT'
				Set @SRNo = 0

				Set @QPSSrNo = @SRNo

				/* To Insert Free Item at the End */				
				Insert Into #RFADetail 
				Select @SRNo, 1, InvoiceID, SchemeId, BillRef , OutletCode ,
					RCSID , ActiveInRCS, LineType , Division ,
					SubCategory , MarketSKU , SKUCode ,
					UOM , Sum(SaleQty) , Sum(SaleValue) ,
					Sum(PromotedQty) ,Sum(PromotedValue) ,Sum(RebateQty) , Sum(RebateValue) , Sum(PriceExclTax) ,
					Max(TaxPercentage) , Sum(TaxAmount) , Sum(PriceInclTax) ,0 ,  Sum(BudgetedValue) , InvoiceType,[Doc No]
					From #RFAInfoTemp
					Group By 
					InvoiceID, SchemeId, BillRef , OutletCode ,
					RCSID , ActiveInRCS, LineType , Division ,
					SubCategory , MarketSKU , SKUCode ,
					UOM ,InvoiceType,[Doc No]

				Drop Table #tmptbl_mERP_QPSDtlData

			End
			If (Select Count(*) From #RFAAbstract) >=  1 
			Begin
				Insert Into #tmpRFAAbs
				Select @WDCode as WDCode, @WDDest as WDDest, @SchemeType as SchemeType, @ActivityCode as ActivityCode, 
				@ActivityType as ActivityDesc, @ActiveFrom as ActiveFrom, @ActiveTo As ActiveTo, 
				@PayoutFrom as PayoutFrom, @PayoutTo As PayoutTo, *, @ApplicableOn as AppOn
				From #RFAAbstract	
			End
			Else
			Begin
				Insert Into #tmpRFAAbs
				Select @WDCode as WDCode, @WDDest as WDDest, @SchemeType as SchemeType, @ActivityCode as ActivityCode, 
				@ActivityType as ActivityDesc, @ActiveFrom as ActiveFrom, @ActiveTo As ActiveTo, 
				@PayoutFrom as PayoutFrom, @PayoutTo As PayoutTo,Null as SR,Null as Division,Null as SubCategory,Null as MarketSKU,Null as SKUCode,
				Null as UOM,Null as SaleQty,Null as SaleValue,Null as  PromotedQty,Null as PromotedValue,
				Null as FreeBaseUOM,Null as RebateQty,Null as RebateValue,Null as BudgetedQty,Null as BudgetedValue,@ApplicableOn as AppOn
			End

				/*For FreeQty schemes RebateValue and RebateQty should not be shown in bottom frame*/
				
				Update #RFADetail Set RebateQty = 0, RebateValue = 0, PriceExclTax =0,TaxAmount =0, PriceInclTax = 0  
				Where IsNull(Flagword, 0) = 0 
				And InvoiceType <> 4
				If (Select Count(*) From #RFADetail) >= 1
				Begin
					Insert Into #tmpRFADet
					Select @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, @CSSchemeID as CompSchemeID, @ActivityType as ActivityDesc, 
						@PayoutFrom as ActiveFrom, @PayoutTo As ActiveTo, SR, BillRef, OutletCode,
						RCSID, ActiveInRCS, LineType , Division ,
						SubCategory , MarketSKU , SKUCode ,
						UOM , SaleQty , SaleValue ,
						PromotedQty, 
						PromotedValue ,RebateQty , RebateValue , PriceExclTax ,
						TaxPercentage , TaxAmount , PriceInclTax ,BudgetedQty ,  BudgetedValue,
						Cust.Company_Name as 'OutletName' ,[Doc No]
						From #RFADetail,Customer Cust (NoLock)
						Where Cust.CustomerID = #RFADetail.OutletCode  
				End
				Else
				Begin
					Insert Into #tmpRFADet
					Select @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, @CSSchemeID as CompSchemeID, @ActivityType as ActivityDesc, 
					@PayoutFrom as ActiveFrom, @PayoutTo As ActiveTo,Null as SR,Null as BillRef,Null as OutletCode,Null as RCSID,Null as  ActiveInRCS,
					Null as LineType,Null as Division,Null as SubCategory,Null as MarketSKU,Null as SKUCode,
					Null as UOM,Null as SaleQty,Null as SaleValue,Null as  PromotedQty,Null as PromotedValue,
					Null as RebateQty,Null as RebateValue,Null as PriceExclTax,Null as TaxAmount,Null as TaxPercentage,
					Null as PriceInclTax,Null as BudgetedQty,Null as BudgetedValue,Null as 'OutletName',Null as 'Doc No'
				End
			End /*Offtake - Free Item Based Scheme  End*/
			End /*Offtake - Item Based Scheme  End*/
			Else If  @ApplicableOn = 'Invoice'  /*Offtake - Invoice Based Scheme  starts*/
			Begin
				If @ItemFree = 0
				Begin
					Insert Into #RFAInfoTemp(InvoiceID,SchemeID, BillRef,OutletCode,RCSID,ActiveInRCS,LineType,RebateValue,[Doc No])
					Select  InvoiceID, SchemeId, BillRef , QPS.CustomerID ,
							IsNull(Cust.RCSOutletID, '') as RCSID,
							--isNull((Select IsNull(TMDValue,N'') From  Cust_TMD_Master CTM, Cust_TMD_Details CTD Where 
							--CTD.CustomerID = QPS.CustomerID And CTM.TMDID = CTD.TMDID),'') as ActiveInRCS, 
							(Case when IsNull(Cust.RCSOutletID,'') <>  '' then 'Yes' else 'No' end),
							'QPS' , (case @TaxConfigCrdtNote When 1 Then Sum(IsNull(Rebate_Val,0)) Else Sum(IsNull(RFARebate_Val,0)) End) as RebateValue ,
							InvDocRef
							From tbl_mERP_QPSDtlData QPS (NoLock),Customer Cust (NoLock)
							Where 
							QPS.SchemeID = @SchemeID
							And PayoutID = @PayoutID
							And (isNull(Rebate_Qty,0) > 0 Or isNull(Rebate_Val,0) > 0 Or IsNull(RFARebate_Val,0) > 0)
							And Cust.CustomerID = QPS.CustomerID 
							Group By InvoiceID, SchemeId, BillRef , QPS.CustomerID ,Cust.RCSOutletID,InvDocRef
				End
		
				/*Abstract data*/ 
				If (Select Count(*) From #RFAInfoTemp Where SchemeID = @SchemeID) >= 1 
				Begin
					Insert Into #tmpRFAAbs
					Select  @WDCode as WDCode, @WDDest as WDDest, @SchemeType as SchemeType, @ActivityCode as ActivityCode, 
							@ActivityType as ActivityDesc, @ActiveFrom as ActiveFrom, @ActiveTo As ActiveTo, 
							@PayoutFrom as PayoutFrom, @PayoutTo As PayoutTo, 0 as SR,
							Division, SubCategory, MarketSKU, SKUCode, UOM, Sum(SaleQty) as SaleQty,
							Sum(SaleValue) as SaleValue, Sum(PromotedQty) As PromotedQty, Sum(PromotedValue) As PromotedValue, 
							Max(FreeBaseUOM), Sum(RebateQty) as RebateQty, Sum(IsNull(RebateValue, 0)) as RebateValue, 
							0 as BudgetedQty, 0 as BudgetedValue, @ApplicableOn as AppOn
							From #RFAInfoTemp
							Where SchemeID = @SchemeID
							Group By SchemeID, Division, SubCategory, MarketSKU, SKUCode, UOM,FreeBaseUOM
							Order By SKUCode

					/*Detail data*/

					Insert Into #tmpRFADet
					Select  @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, 
							@CSSchemeID as CompSchemeID, @ActivityType as ActivityDesc, 
							@PayoutFrom as ActiveFrom, @PayoutTo As ActiveTo, 0 as SR,
							BillRef, OutletCode, RCSID, ActiveInRCS, (case when isNull(LineType,'') ='Free' then 'Free' else '' end) as LineType, 
							Division, SubCategory, MarketSKU, SKUCode, UOM, Sum(SaleQty) as SaleQty,
							Sum(SaleValue) as SaleValue, Sum(PromotedQty) As PromotedQty,Sum(PromotedValue) As PromotedValue, 
							Sum(RebateQty) as RebateQty, Sum(IsNull(RebateValue, 0)) as RebateValue, 
							IsNull(PriceExclTax, 0) as PriceExclTax, IsNull(TaxPercentage,0) as TaxPercentage, 
							sum(IsNull(TaxAmount,0)) as TaxAmount, IsNull(PriceInclTax,0) as PriceInclTax,
							0 as BudgetedQty, 0 as BudgetedValue,Cust.Company_Name as 'OutletName',[Doc No]
							From #RFAInfoTemp,Customer Cust (NoLock)  
							Where SchemeID = @SchemeID
							And Cust.CustomerID = #RFAInfoTemp.OutletCode 
							Group By SchemeID, InvoiceID, OutletCode, RCSID, ActiveInRCS, Division, SubCategory, MarketSKU, SKUCode, UOM,
							FreeBaseUOM, BillRef ,
							PriceExclTax, TaxPercentage, TaxAmount, PriceInclTax,LineType,Cust.Company_Name,[Doc No]
							Order By SKUCode
				End
				Else
				Begin
					Insert Into #tmpRFAAbs
					Select @WDCode as WDCode, @WDDest as WDDest, @SchemeType as SchemeType, @ActivityCode as ActivityCode, 
						   @ActivityType as ActivityDesc, @ActiveFrom as ActiveFrom, @ActiveTo As ActiveTo,
						   @PayoutFrom as PayoutFrom, @PayoutTo As PayoutTo,Null as SR,Null as Division,Null as SubCategory,
						   Null as MarketSKU,Null as SKUCode,Null as UOM,Null as SaleQty,Null as SaleValue,
						   Null as  PromotedQty,Null as PromotedValue,Null as FreeBaseUOM,Null as RebateQty,
						   Null as RebateValue,Null as BudgetedQty,Null as BudgetedValue,@ApplicableOn as AppOn 

					Insert Into #tmpRFADet
					Select @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, @CSSchemeID as CompSchemeID,
						   @ActivityType as ActivityDesc,@PayoutFrom as ActiveFrom, @PayoutTo As ActiveTo,Null as SR,
						   Null as BillRef,Null as OutletCode,Null as RCSID,Null as  ActiveInRCS,Null as LineType,
						   Null as Division,Null as SubCategory,Null as MarketSKU,Null as SKUCode,Null as UOM,
						   Null as SaleQty,Null as SaleValue,Null as  PromotedQty,Null as PromotedValue,Null as RebateQty,
						   Null as RebateValue,Null as PriceExclTax,Null as TaxAmount,Null as TaxPercentage,
						   Null as PriceInclTax,Null as BudgetedQty,Null as BudgetedValue,Null as 'OutletName',Null as 'Doc No'	
				End
			End	/*Offtake - Invoice Based Scheme  starts*/	
		End	/*Offtake scheme - End*/

		Select @QPS = 2
		Select @QPS = isNull(QPS,0) From tbl_mERP_SchemeOutlet (NoLock) Where SchemeID = @SchemeID And isNull(QPS,0) = 0
		
		Update #tmpRFAAbs Set Division = '' Where Division = 'QPS Credit Note'
		Update #tmpRFADet Set Division = '' Where Division = 'QPS Credit Note'

		/* After Schemes applied there is possibility of changing the Category mapping , hence
		Division,SubCategory and MarketSKU updated based on the current mapping */

		Update RFA Set Division = IC2.Category_Name, SubCategory = IC1.Category_Name, 
		MarketSKU = IC.Category_Name
		From #tmpRFAAbs RFA,Items I(NoLock) , ItemCategories IC(NoLock), ItemCategories IC1(NoLock),ItemCategories IC2(NoLock)
		Where 
		isNull(RFA.SKUCode,'') <> '' And
		isNull(RFA.Division,'') <> '' And
		RFA.SKUCode = I.Product_Code And
		I.CategoryID = IC.CategoryID And
		IC.ParentID = IC1.CategoryID And
		IC1.ParentID = IC2.CategoryID 

		Update RFA Set Division = IC2.Category_Name, SubCategory = IC1.Category_Name, 
		MarketSKU = IC.Category_Name
		From #tmpRFADet RFA,Items I , ItemCategories IC, ItemCategories IC1,ItemCategories IC2
		Where 
		isNull(RFA.SKUCode,'') <> '' And
		isNull(RFA.Division,'') <> '' And
		RFA.SKUCode = I.Product_Code And
		I.CategoryID = IC.CategoryID And
		IC.ParentID = IC1.CategoryID And
		IC1.ParentID = IC2.CategoryID 
		

		Truncate table #RFAInfoTemp
		Truncate table #RFAAbstract
		Truncate table #RFADetail
		
		/*  To Select QPS And Non Qps Together */
	If @ApplicableOn = 'Invoice'
	Begin	
		If Exists(Select * From #tmpRFAAbs Where (isNull(Division,'') <> '' Or isNull(RebateValue,0) <> 0))
		Begin	
			Select WDCode,WDDest,SchemeType,ActivityCode,ActivityDesc,ActiveFrom,ActiveTo,PayoutFrom,PayoutTo,
			SR,Division,SubCategory,MarketSKU,SKUCode,UOM,Sum(SaleQty) as SaleQty,
			Sum(SaleValue) as SaleValue,Sum(PromotedQty) as PromotedQty,Sum(PromotedValue)  as PromotedValue, 
			Max(isNull(FreeBaseUOM,'')) as FreeBaseUOM , Sum(RebateQty) as RebateQty,Sum(RebateValue) as Rebatevalue,
			0 as BudgetedQty,0 as BudgetedValue,AppOn from #tmpRFAAbs
			Where (isNull(Division,'') <> '' Or isNull(RebateValue,0) <> 0)
			Group By 
			WDCode,WDDest,SchemeType,ActivityCode,ActivityDesc,ActiveFrom,ActiveTo,PayoutFrom,PayoutTo,
			SR,Division,SubCategory,MarketSKU,SKUCode,UOM,AppOn

			Select * from #tmpRFADet	
			Where (isNull(Division,'') <> '' Or isNull(RebateValue,0) <> 0)
		End
		Else
		Begin
			/*Abstract Data*/
			Select  @WDCode as WDCode, @WDDest as WDDest, @SchemeType as SchemeType, @ActivityCode as ActivityCode,
						@ActivityType as ActivityDesc, @ActiveFrom as ActiveFrom, @ActiveTo As ActiveTo, 
						@PayoutFrom as PayoutFrom, @PayoutTo as PayoutTo, Null as Division, Null as SubCategory,
						Null as MarketSKU, Null as SKUCode, Null as UOM, Null as SaleQty, Null as SaleValue,
						Null as PromotedQty, Null as PromotedValue, Null as FreeBaseUOM, Null as RebateQty, 
						Null as RebateValue, Null as BudgetedQty, Null as BudgetedValue, @ApplicableOn as AppOn,NULL as 'SR' 
					
			/*Detail data*/
			Select  @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, @CSSchemeID As CompSchemeID,
						@ActivityType as ActivityDesc, @PayoutFrom as ActiveFrom, @PayoutTo As ActiveTo, Null as BillRef,
						Null as OutletCode, Null as RCSID, Null as ActiveInRCS, Null as LineType, Null as Division, Null as SubCategory, Null as MarketSKU,
						Null as SKUCode, Null as UOM, Null as SaleQty, Null as SaleValue, Null as PromotedQty, Null as PromotedValue,
						Null as RebateQty, Null as RebateValue, Null as PriceExclTax, Null as TaxPercentage, Null as TaxAmount,
						Null as PriceInclTax, Null as BudgetedQty, Null as BudgetedValue,Null as 'OutletName',Null as 'Doc No',Null as 'SR'
		End
	End
	Else
	Begin
		If Exists(Select * From #tmpRFAAbs Where (isNull(Division,'') <> '' Or isNull(RebateValue,0) <> 0))
		Begin	

			Delete From #tmpRFAAbs Where isNull(Division,'') = '' And isNull(RebateValue,0) = 0
			Delete From #tmpFinalDet Where isNull(Division,'') = '' And isNull(RebateValue,0) = 0

			If @ItemGroup = 1 And @ItemFree = 1
			Begin
					
					Set @SRNo = 0
					Declare  CurProdCode Cursor For
					Select Distinct SKUCode From #tmpRFAAbs
					Open CurProdCode
					Fetch From CurProdCode Into @SKUCode
					While @@Fetch_Status = 0 
					Begin
						Set @SRNo = @SRNo + 1	

						Truncate Table #tmpSerial
						Insert Into #tmpSerial
						Select SR From #tmpRFAAbs Where SKUCode = @SKUCode

						/* To Insert Abstract Data */
						Insert Into #tmpFinalAbs
						Select WDCode, WDDest,SchemeType, ActivityCode,ActivityDesc,ActiveFrom,ActiveTo,
						PayoutFrom,PayoutTo,@SRNo,Division,SubCategory,MarketSKU,SKUCode,UOM,0,0,
						Sum(PromotedQty),Sum(PromotedValue),Max(FreeBaseUOM),Sum(RebateQty),Sum(RebateValue),0,0,AppOn 
						From #tmpRFAAbs Where SKUCode = @SKUCode
						And (isNull(Division,'') <> '' Or isNull(RebateValue,0) <> 0)
						Group By 
						WDCode, WDDest,SchemeType, ActivityCode,ActivityDesc,ActiveFrom,ActiveTo,
						PayoutFrom,PayoutTo,Division,SubCategory,MarketSKU,SKUCode,UOM,AppOn	

						Insert Into #tmpFinalDet
						Select WDCode, WDDest,ActivityCode,CompSchemeID,ActivityDesc,ActiveFrom,ActiveTo,@SRNo,
						BillRef,OutletCode,RCSID,ActiveInRCS,LineType,Division,SubCategory,MarketSKU,SKUCode,UOM,
						SaleQty,SaleValue,PromotedQty,PromotedValue,RebateQty,RebateValue,PriceExclTax,TaxPercentage,
						TaxAmount,PriceInclTax,0,0,OutletName,[Doc No] From #tmpRFADet
						Where (isNull(Division,'') <> '' Or isNull(RebateValue,0) <> 0)
						And SR In(Select Serial From #tmpSerial)


						Fetch From CurProdCode Into @SKUCode
					End
					Close CurProdCode
					Deallocate CurProdCode

					Insert Into #tmpFinalDet
					Select WDCode, WDDest,ActivityCode,CompSchemeID,ActivityDesc,ActiveFrom,ActiveTo,@SRNo,
					BillRef,OutletCode,RCSID,ActiveInRCS,LineType,Division,SubCategory,MarketSKU,SKUCode,UOM,
					SaleQty,SaleValue,PromotedQty,PromotedValue,RebateQty,RebateValue,PriceExclTax,TaxPercentage,
					TaxAmount,PriceInclTax,0,0,OutletName,[Doc No] From #tmpRFADet
					Where (isNull(Division,'') <> '' Or isNull(RebateValue,0) <> 0)
					And SKUCode Not In(Select SKUCode From #tmpFinalAbs)
					And SKUCode Not In(Select SKUCode From #tmpFinalDet)
					
					Update #tmpFinalAbs Set SaleQty = (Select Sum(SalesQty) From #tmpSKUWiseSalesTemp Where SKUCode = #tmpFinalAbs.SKUCode),
					SaleValue = (Select Sum(SalesValue) From #tmpSKUWiseSalesTemp Where SKUCode = #tmpFinalAbs.SKUCode)

			End
			Else
			Begin
				Insert Into #tmpFinalAbs
				Select WDCode, WDDest,SchemeType, ActivityCode,ActivityDesc,ActiveFrom,ActiveTo,
				PayoutFrom,PayoutTo,SR,Division,SubCategory,MarketSKU,SKUCode,isNull(UOM,''),0,0,
				Sum(PromotedQty),Sum(PromotedValue),isNull(FreeBaseUOM,''),Sum(RebateQty),Sum(RebateValue),0,0,AppOn 
				From #tmpRFAAbs
				Where (isNull(Division,'') <> '' Or isNull(RebateValue,0) <> 0)
				Group By 
				WDCode, WDDest,SchemeType, ActivityCode,ActivityDesc,ActiveFrom,ActiveTo,
				PayoutFrom,PayoutTo,SR,Division,SubCategory,MarketSKU,SKUCode,isNull(UOM,''),isNull(FreeBaseUOM,''),AppOn
				Update #tmpFinalAbs Set SaleQty = (Select Sum(SalesQty) From #tmpSKUWiseSalesTemp Where SKUCode = #tmpFinalAbs.SKUCode),
				SaleValue = (Select Sum(SalesValue) From #tmpSKUWiseSalesTemp Where SKUCode = #tmpFinalAbs.SKUCode)

				Insert into #tmpFinaldata ([WD Code],[WD Dest],FromDate,ToDate,ActivityCode,Description,[Applicable Period],[RFA Period],Division,
				Code,Name,UOM,Type,SaleQty,SaleValue,PromotedQty,PromotedValue,TaxPercentage,TaxAmount,RebateQty,RebateValue )
				select @WDCode,@WDDestCode,@FromDate,@ToDate,@ActivityCode,@Description,@ApplicablePeriod,@RFAPeriod,Division,
				SKUCode,Null,UOM,LineType,Sum(SaleQty),Sum(SaleValue),Sum(PromotedQty),Sum(PromotedValue),Sum(TaxPercentage),Sum(TaxAmount),Sum(RebateQty),Sum(RebateValue) from #tmpRFADet
				Group By Division,SKUCode,UOM,LineType
			End
		End
	End 
		
if (select Distinct SlabType from tbl_mERP_SchemeSlabDetail Where schemeid = @schemeid) in (2,3)
Begin
	--Declare @cur_10 Cursor 
	--Set @cur_10 = Cursor for
	--Select Code from #tmpFinaldata Where [Type] = 'MAIN'
	--Open @cur_10
	--Fetch Next from @cur_10 into @code
	--While @@fetch_status =0
	--	Begin
	--		Set @SQty = 0
	--		Set @SValue = 0
	--		select @SQty = Sum(D.Quantity), @SValue = sum(D.Quantity * D.SalePrice) From #TmpTSRInvDtl D, #TmpTSRInvAbs A Where  D.Product_Code = @code and A.InvoiceType  in (1,3) and (A.Status & 128) = 0 and D.InvoiceId = A.InvoiceId And A.Invoicedate Between @InvFrom and @InvTo
	--			Begin
	--				Update #tmpFinaldata set SaleQty = @SQty, SaleValue = @SValue Where Code = @code and [Type] Like '%MAIN%'
	--			End

	--		Fetch Next from @cur_10 into @code
	--	End
	--Close @cur_10
	--Deallocate @cur_10
	--Start Optim4@cur_10
	If OBJECT_ID('tempdb..#tmpSQtySVal')  Is Not Null
		Drop Table #tmpSQtySVal 
	
	Select Product_Code=D.Product_Code, SQty = Sum(D.Quantity), SValue = sum(D.Quantity * D.SalePrice) into #tmpSQtySVal 
	From #TmpTSRInvDtl D, #TmpTSRInvAbs A , (Select Distinct Code=Code From #tmpFinaldata Where [Type] = 'MAIN') FD
	Where A.InvoiceType  in (1,3) and (A.Status & 128) = 0 and D.InvoiceId = A.InvoiceId And A.Invoicedate Between @InvFrom and @InvTo 
	And D.Product_Code = FD.Code 
	Group by D.Product_Code
	
	Update FD Set SaleQty = TSS.SQty, SaleValue =TSS.SValue From #tmpFinaldata FD,#tmpSQtySVal TSS 
	Where FD.Code = TSS.Product_Code and FD.[Type]  Like '%MAIN%'
	
	--End Optim4@cur_10	
--	Update T Set T.SaleQty = M.Qty,T.SaleValue =  M.Svalue From
--	(Select D.Product_Code AS Product_Code ,Sum(Isnull(D.Quantity,0)) As Qty,Isnull(sum(D.Quantity * D.SalePrice),0) as Svalue From 
--	 #TmpTSRInvDtl D, #TmpTSRInvAbs A,#tmpFinal T where A.Invoicedate Between @InvFrom and @InvTo And  A.InvoiceType  in (1,3) and (A.Status & 128) = 0 
--	and D.InvoiceId = A.InvoiceId And  D.Product_Code IN (Select Distinct  Code from #tmpFinal Where [Type] = 'MAIN') 
--	Group by D.Product_Code) AS M,#tmpFinal AS T		
--	Where T.[Type] Like '%MAIN%' And  T.Code  = M.Product_Code
	
End

	Drop Table #RFAInfoTemp
	Drop Table #RFADetail
	Drop Table #RFAAbstract
	Drop table #temp
	Drop table #tmpRFAAbs
	Drop table #tmpRFADet
	Drop table #tmpFinalAbs
	Drop table #tmpFinalDet
	Drop table #tmpSKUWiseSalesTemp
	Drop table #TempFinal
	Drop table #tmpSalesTemp
	Drop table #tmpSerial
End
--********************************************************************************************
Begin    
  Create table #tmpSchPayout(SchemeID Int, PayoutID Int)    
    Insert into #tmpSchPayout(SchemeID, PayoutID)  
		select   @SchemeID, @PayoutID
		
  /*Temp Tables to store the result data*/    
  --Create table #tmpAbsQPSData(          
  --     QPSDataRowID Int,     
  --     SchemeType  nvarchar(15)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
  --     ActivityCode  nvarchar(50)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
  --     ActivityDesc  nvarchar(510)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
  --     ActiveFrom  DateTime,    
  --     ActiveTo  DateTime,    
  --     PayoutFrom  DateTime,    
  --     PayoutTo  DateTime,    
  --     Division  nvarchar(510)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
  --     SubCategory  nvarchar(510)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
  --     MarketSKU  nvarchar(510)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
  --     SystemSKU  nvarchar(510)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
  --     UOM  nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
  --     SaleQty Decimal(18,6) Default(0),    
  --     SaleValue Decimal(18,6) Default(0),    
  --     PromotedQty Decimal(18,6) Default(0),    
  --     PromotedVal Decimal(18,6) Default(0),    
  --     FreeBaseUOM nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,    
  --     RebateQty Decimal(18,6) Default(0),    
  --     RebateVal Decimal(18,6) Default(0),    
  --     BudgetedQty Decimal(18,6) Default(0),    
  --     BudgetedValue Decimal(18,6) Default(0),    
  --     AppOn nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,    
  --     SubmittedOn nvarchar(25)  COLLATE SQL_Latin1_General_CP1_CI_AS)    
    
  Create table #tmpDtlQPSData(    
       QPSDataRowID Int,      
       ActivityCode nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
       CompSchemeID nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
       ActivityDesc nvarchar(510)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
       ActiveFrom DateTime,    
       ActiveTo DateTime,    
       BillRef nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,   
       InvDocRef nvarchar(510)  COLLATE SQL_Latin1_General_CP1_CI_AS,   
       OutletCode nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
       OutletName nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
       RCSID nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
       ActiveInRCS nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
       LineType nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
       Division nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
       SubCategory nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
       MarketSKU nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
       SystemSKU nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
       UOM nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
       SaleQty Decimal(18,6) Default(0),     
       SaleValue Decimal(18,6) Default(0),    
       PromotedQty Decimal(18,6) Default(0),    
       PromotedVal Decimal(18,6) Default(0),    
       RebateQty Decimal(18,6) Default(0),    
       RebateVal Decimal(18,6) Default(0),   
       PriceExclTax Decimal(18,6) Default(0),    
       TaxPercentage Decimal(18,6) Default(0),    
       TaxAmount Decimal(18,6) Default(0),    
       PriceInclTax Decimal(18,6) Default(0),    
       BudgetedQty Decimal(18,6) Default(0),    
       BudgetedValue Decimal(18,6) Default(0))    
   
  /*Cursor to get the SlabType by group, Payout, Scheme wise*/    
  
  Declare  @GroupID Int, @SlabType Int, @ApplyOn int, @ItemGrp Int 
  Declare @Claimed as int
  Declare @Inv_Ref as Nvarchar(255)
   
  Declare CurSchPayoutGrp Cursor For    
  Select Distinct SchGrp.SchemeID
  , SchPayout.PayoutID
  , SchGrp.SubGroupID
  , SlabDetail.SlabType
  , SchAbs.ApplicableOn
  , SchAbs.ItemGroup     
  from tbl_mERP_SchemeSubGroup SchGrp
  Inner Join #tmpSchPayout SchPayout On  SchGrp.SchemeID = SchPayout.SchemeID
  Inner Join  tbl_merp_SchemeAbstract SchAbs On SchAbs.SchemeID = SchPayout.SchemeID 
  Inner Join tbl_merp_SchemeOutlet Outlet On Outlet.SchemeID = SchPayout.SchemeID 
  Left Outer Join  tbl_merp_schemeSlabDetail SlabDetail On SlabDetail.SchemeID = SchPayout.SchemeID and Outlet.GroupID = SlabDetail.GroupID      
  Where
  ---SchGrp.SchemeID = 145 and     
  SchGrp.SubGroupID = Outlet.GroupID and     
  Outlet.QPS = 1 
  
  Open CurSchPayoutGrp    
  Fetch Next from CurSchPayoutGrp into @SchemeID, @PayoutID, @GroupID, @SlabType, @ApplyOn, @ItemGrp    
  While @@Fetch_Status = 0     
  Begin    
    --If @ApplyOn = Line And @ItemGrp = Spl.Category  Or @ItemGrp = Direct  
      If @ApplyOn = 1 And (@ItemGrp = 2 Or @ItemGrp = 1)     
      Begin    
        /*Abs data Selection*/  
        --Insert into #tmpAbsQPSData(QPSDataRowID, SchemeType, ActivityCode, ActivityDesc, ActiveFrom, ActiveTo, PayoutFrom,PayoutTo, Division, SubCategory, MarketSKU,SystemSKU,     
        --UOM, SaleQty, SaleValue, PromotedQty, PromotedVal, RebateQty, RebateVal, BudgetedQty, BudgetedValue, AppOn, SubmittedOn)    
        --Select QPSDtl.QPSAbsDataID, SchType.SchemeType, SchAbs.ActivityCode, SchAbs.Description,     
        --SchAbs.ActiveFrom, SchAbs.ActiveTo, SchPayout.PayoutPeriodFrom, SchPayout.PayoutPeriodTo,    
        --QPSDtl.Division, QPSDtl.SubCategory, QPSDtl.MarketSKU, QPSDtl.Product_Code SystemSKU, QPSDtl.UOM,     
        --Sum(QPSDtl.Quantity) SaleQty, Sum(QPSDtl.Quantity * QPSDtl.SalePrice) SaleValue,
        --Sum(QPSDtl.Promoted_Qty) PromotedQty, Sum(QPSDtl.Promoted_Val) PromotedVal,    
        --Case ISNull(Slabdet.SlabType,0) When 3 Then 0 Else Sum(Rebate_Qty) End RebateQty, 
        --Case IsNull(Slabdet.SlabType,0) When 3 Then 0 Else Sum(Rebate_val) End RebateVal, 
        --0 BudgetedQty, 0 BudgetedValue, Case SchAbs.ApplicableOn When 1 Then 'Line' when 2 then 'SPL_CAT' End AppOn, Convert(nVarchar(10),QPSAbs.CreationTime,103) SubmittedOn    
        --From tbl_merp_QPSAbsData QPSAbs, tbl_merp_QPSDtlData QPSDtl, tbl_merp_SchemeType SchType, tbl_merp_SchemeAbstract SchAbs, tbl_Merp_SchemePayoutPeriod SchPayout, tbl_merp_schemeSlabdetail Slabdet    
        --Where SchAbs.SchemeID = QPSAbs.SchemeID And     
        --SchAbs.SchemeType = SchType.ID And     
        --SchPayout.SchemeID = SchAbs.SchemeID And     
        --SchPayout.ID = QPSAbs.PayoutID And     
        --QPSAbs.SchemeID = QPSDtl.SchemeID And     
        --QPSAbs.PayoutID = QPSDtl.PayoutID And     
        --QPSAbs.CustomerID = QPSDtl.CustomerID And  
        --IsNull(QPSAbs.Product_code,N'') =  Case @ItemGrp When 1 then QPSDtl.Product_code  Else N'' End And 
        --QPSAbs.SchemeID = @SchemeID And     
        --QPSAbs.PayoutID = @PayoutID And     
        --QPSAbs.GroupID = @GroupID And 
        --IsNull(QPSAbs.SlabID,0) *= Slabdet.SlabID And  
        --(IsNull(QPSAbs.SlabID,0) > 0  or IsNull(RebateValue,0) > 0 )   
        --Group by QPSDtl.QPSAbsDataID, SchType.SchemeType, SchAbs.ActivityCode, SchAbs.Description,     
        --SchAbs.ActiveFrom, SchAbs.ActiveTo, SchPayout.PayoutPeriodFrom, SchPayout.PayoutPeriodTo, ISNull(Slabdet.SlabType,0),   
        --QPSDtl.Division, QPSDtl.SubCategory, QPSDtl.MarketSKU, QPSDtl.Product_Code, QPSDtl.UOM, --QPSDtl.CustomerID,    
        --SchAbs.ApplicableOn, Convert(nVarchar(10),QPSAbs.CreationTime,103)    
          
        /*Dtl data Selection*/    
        Insert into #tmpDtlQPSData(QPSDataRowID, ActivityCode, CompSchemeID, ActivityDesc, ActiveFrom, ActiveTo, BillRef, InvDocRef, OutletCode, OutletName, RCSID, ActiveInRCS, LineType, Division, SubCategory, MarketSKU, SystemSKU, UOM,    
        SaleQty, SaleValue, PromotedQty, PromotedVal, RebateQty, RebateVal, PriceExclTax, TaxPercentage, TaxAmount, PriceInclTax, BudgetedQty, BudgetedValue)    
        Select QPSDtl.QPSAbsDataID, SchAbs.ActivityCode, SchAbs.CS_SchemeId, SchAbs.Description,     
        SchAbs.ActiveFrom, SchAbs.ActiveTo, QPSDtl.BillRef, QPSDtl.InvDocRef, CM.CustomerID OutletCode, CM.Company_name OutletName,     
        IsNull(CM.RCSOutletID, '') as RCSID,    
		(Case when IsNull(CM.RCSOutletID,'') <> '' then 'Yes' else 'No' end) as ActiveInRCS,
        'MAIN' LineType, QPSDtl.Division, QPSDtl.SubCategory, QPSDtl.MarketSKU, QPSDtl.Product_code SystemSKU, QPSDtl.UOM,     
        Sum(QPSDtl.Quantity) SaleQty, Sum(QPSDtl.Quantity) * QPSDtl.SalePrice SaleValue,
        Sum(QPSDtl.Promoted_Qty) PromotedQty, Sum(QPSDtl.Promoted_Val) PromotedVal,    
        Case ISNull(Slabdet.SlabType,0) When 3 Then 0 Else Sum(Rebate_Qty) End RebateQty, 
        Case IsNull(Slabdet.SlabType,0) When 3 Then 0 Else Sum(Rebate_val) End RebateVal, 
        QPSDtl.SalePrice PriceExclTax, QPSDtl.TaxPercent TaxPercentage, Sum(TaxAmount) TaxAmount,      
        (Case Max(IsNull(QPSDtl.TOQ,0)) When 0 then QPSDtl.SalePrice + (IsNull(QPSDtl.SalePrice,0)* IsNull(QPSDtl.TaxPercent,0)/100) Else (QPSDtl.SalePrice +  IsNull(QPSDtl.TaxPercent,0)) End) PriceInclTax,
		 0 BudgetedQty, 0 BudgetedValue  
        From tbl_merp_QPSAbsData QPSAbs
		Inner Join tbl_merp_QPSDtlData QPSDtl On QPSAbs.SchemeID = QPSDtl.SchemeID  And QPSAbs.PayoutID = QPSDtl.PayoutID And  QPSAbs.CustomerID = QPSDtl.CustomerID
		Inner Join tbl_merp_SchemeAbstract SchAbs On     SchAbs.SchemeID = QPSAbs.SchemeID 
		Inner join Customer CM On CM.CustomerID = QPSDtl.CustomerID 
		Left Outer join  tbl_merp_schemeSlabdetail Slabdet   On IsNull(QPSAbs.SlabID,0) = Slabdet.SlabID
        Where 
        IsNull(QPSAbs.Product_code,N'') =  Case @ItemGrp When 1 then QPSDtl.Product_code  Else N'' End And 
        QPSAbs.SchemeID = @SchemeID And     
        QPSAbs.PayoutID = @PayoutID And   
        QPSAbs.GroupID = @GroupID And    
        (IsNull(QPSAbs.SlabID,0) > 0  or IsNull(RebateValue,0) > 0 ) 
        Group by QPSDtl.QPSAbsDataID, SchAbs.ActivityCode, SchAbs.CS_SchemeId, SchAbs.Description,     
        SchAbs.ActiveFrom, SchAbs.ActiveTo, QPSDtl.BillRef, QPSDtl.InvDocRef, CM.CustomerID, CM.Company_name,   
        QPSDtl.SalePrice, QPSDtl.TaxPercent, ISNull(Slabdet.SlabType,0),   
        QPSDtl.Division, QPSDtl.SubCategory, QPSDtl.MarketSKU, QPSDtl.UOM, QPSDtl.Product_code, IsNull(CM.RCSOutletID, '')    
        Order by QPSDtl.QPSAbsDataID, SchAbs.ActivityCode, QPSDtl.Division, QPSDtl.SubCategory, QPSDtl.MarketSKU, QPSDtl.BillRef, CM.CustomerID  
      End     
      Else    
      --If @ApplyOn = Line or Invoice And @ItemGrp = Invoice  
      Begin    
        --Insert into #tmpAbsQPSData(QPSDataRowID, SchemeType, ActivityCode, ActivityDesc, ActiveFrom, ActiveTo, PayoutFrom, PayoutTo, Division, SubCategory, MarketSKU,     
        --SystemSKU, UOM, SaleQty, SaleValue, PromotedQty, PromotedVal, RebateQty, RebateVal, BudgetedQty, BudgetedValue, AppOn, SubmittedOn)     
        --Select QPSDtl.QPSAbsDataID,SchType.SchemeType, SchAbs.ActivityCode, SchAbs.Description,     
        --SchAbs.ActiveFrom, SchAbs.ActiveTo, SchPayout.PayoutPeriodFrom, SchPayout.PayoutPeriodTo,    
        --'' Division, '' SubCategory, '' MarketSKU, '' SystemSKU,  '' UOM,     
        --0 SaleQty, 0 SaleValue, 0 PromotedQty, 0 PromotedVal,    
        --0 RebateQty, 
        --Case IsNull(Slabdet.SlabType,0) When 3 Then 0 Else Sum(Rebate_val) End RebateVal,
        --0 BudgetedQty, 0 BudgetedValue, Case SchAbs.ApplicableOn When 1 Then 'Line' when 2 then 'SPL_CAT' End AppOn, Convert(nVarchar(10),QPSAbs.CreationTime,103) SubmittedOn    
        --From tbl_merp_QPSAbsData QPSAbs, tbl_merp_QPSDtlData QPSDtl, tbl_merp_SchemeType SchType, tbl_merp_SchemeAbstract SchAbs, tbl_Merp_SchemePayoutPeriod SchPayout, tbl_merp_schemeSlabdetail Slabdet    
        --Where SchAbs.SchemeID = QPSAbs.SchemeID And     
        --SchAbs.SchemeType = SchType.ID And     
        --SchPayout.SchemeID = SchAbs.SchemeID And     
        --SchPayout.ID = QPSAbs.PayoutID And     
        --QPSAbs.SchemeID = QPSDtl.SchemeID And     
        --QPSAbs.PayoutID = QPSDtl.PayoutID And     
        --QPSAbs.CustomerID = QPSDtl.CustomerID And     
        --QPSAbs.SchemeID = @SchemeID And     
        --QPSAbs.PayoutID = @PayoutID And     
        --QPSAbs.GroupID = @GroupID And 
        --IsNull(QPSAbs.SlabID,0) *= Slabdet.SlabID And 
        --(IsNull(QPSAbs.SlabID,0) > 0  or IsNull(RebateValue,0) > 0 ) 
        --Group by QPSDtl.QPSAbsDataID, SchType.SchemeType, SchAbs.ActivityCode, SchAbs.Description, ISNull(Slabdet.SlabType,0),     
        --SchAbs.ActiveFrom, SchAbs.ActiveTo, SchPayout.PayoutPeriodFrom, SchPayout.PayoutPeriodTo,    
        --SchAbs.ApplicableOn, Convert(nVarchar(10),QPSAbs.CreationTime,103)     
  
        /*Dtl data Selection*/    
        Insert into #tmpDtlQPSData(QPSDataRowID, ActivityCode, CompSchemeID, ActivityDesc, ActiveFrom, ActiveTo, BillRef, InvDocRef, OutletCode, OutletName, RCSID, ActiveInRCS, LineType, Division, SubCategory, MarketSKU, SystemSKU, UOM,    
        SaleQty, SaleValue, PromotedQty, PromotedVal, RebateQty, RebateVal, PriceExclTax, TaxPercentage, TaxAmount, PriceInclTax, BudgetedQty, BudgetedValue)    
        Select QPSDtl.QPSAbsDataID, SchAbs.ActivityCode, SchAbs.CS_SchemeId, SchAbs.Description,     
        SchAbs.ActiveFrom, SchAbs.ActiveTo, QPSDtl.BillRef, QPSDtl.InvDocRef, CM.CustomerID OutletCode, CM.Company_name OutletName,     
        IsNull(CM.RCSOutletID, '') as RCSID,    
		(Case when IsNull(CM.RCSOutletID,'') <> '' then 'Yes' else 'No' end) as ActiveInRCS,
        '' LineType, '' Division, '' SubCategory, '' MarketSKU, '' SystemSKU, '' UOM,     
        0 SaleQty, 0 SaleValue, 0 PromotedQty, 0 PromotedVal, 0 RebateQty,
        Case IsNull(Slabdet.SlabType,0) When 3 Then 0 Else Sum(Rebate_val) End RebateVal, 
        0 PriceExclTax, 0 TaxPercentage, 0 TaxAmount, 0 PriceInclTax, 0 BudgetedQty, 0 BudgetedValue    
        From tbl_merp_QPSAbsData QPSAbs
		Inner Join tbl_merp_QPSDtlData QPSDtl On QPSAbs.SchemeID = QPSDtl.SchemeID And QPSAbs.PayoutID = QPSDtl.PayoutID And QPSAbs.CustomerID = QPSDtl.CustomerID
		inner Join tbl_merp_SchemeAbstract SchAbs On SchAbs.SchemeID = QPSAbs.SchemeID 
		Inner Join Customer CM On CM.CustomerID = QPSDtl.CustomerID 
		Left Outer Join tbl_merp_schemeSlabdetail Slabdet  On IsNull(QPSAbs.SlabID,0) = Slabdet.SlabID
        Where 
        QPSAbs.SchemeID = @SchemeID And     
        QPSAbs.PayoutID = @PayoutID And    
        QPSAbs.GroupID = @GroupID And   
        (IsNull(QPSAbs.SlabID,0) > 0  or IsNull(RebateValue,0) > 0 ) 
        Group by QPSDtl.QPSAbsDataID, SchAbs.ActivityCode, SchAbs.CS_SchemeId, SchAbs.Description, ISNull(Slabdet.SlabType,0),    
        SchAbs.ActiveFrom, SchAbs.ActiveTo, QPSDtl.BillRef, QPSDtl.InvDocRef, CM.CustomerID, CM.Company_name, IsNull(CM.RCSOutletID, '')    
        Order by QPSDtl.QPSAbsDataID, SchAbs.ActivityCode, QPSDtl.BillRef, CM.CustomerID  
      End    
    Fetch Next from CurSchPayoutGrp into @SchemeID, @PayoutID, @GroupID, @SlabType, @ApplyOn, @ItemGrp    
  End    
  Close CurSchPayoutGrp    
  Deallocate CurSchPayoutGrp    

select top 1 @Claimed = isnull(Claimed,0), @Inv_Ref = isnull(InvoiceRef,0) from SchemeCustomerItems where schemeid = @schemeid and payoutid = @payoutid
if @Claimed = 0 and @Inv_Ref = 0 
 Begin
	Declare @SystemSKU as nvarchar(255)
	set @SystemSKU  = (select Top 1 Product_Code from SchemeCustomerItems where schemeid = @schemeid)

    Update #tmpDtlQPSData set RebateQty = (select sum(RebateQuantity) from tbl_merp_QPSAbsData Where schemeid = @schemeid and payoutid = @payoutid Group by payoutid) 
	Update #tmpDtlQPSData set RebateQty = (RebateQty *
	(select Case IsNull(FreeUOM,0) When 3 Then (select UOM2_Conversion from items where Product_Code = @SystemSKU)  
	When 2 Then (select UOM1_Conversion from items where Product_Code = @SystemSKU) 
	Else (select ConversionUnit from items where Product_Code = @SystemSKU) 
	End from tbl_merp_schemeSlabdetail where schemeid = @schemeid and GroupId = 1))

	Update #tmpDtlQPSData set RebateVal = (Select (((select sum(RebateQuantity) from tbl_merp_QPSAbsData Where schemeid = @schemeid and payoutid = @payoutid Group by payoutid) * (select Case IsNull(FreeUOM,0) When 3 Then (select UOM2_Conversion from items where Product_Code = @SystemSKU)  
	When 2 Then (select UOM1_Conversion from items where Product_Code = @SystemSKU) 
	Else (select ConversionUnit from items where Product_Code = @SystemSKU) 
	End from tbl_merp_schemeSlabdetail where schemeid = @schemeid and GroupId = 1))  * (Select Top 1 PTR from Items where Product_Code = @SystemSKU))  from tbl_merp_QPSAbsData Where schemeid = @schemeid and payoutid = @payoutid Group by payoutid)  
 End
	Insert into #tmpFinaldata ([WD Code],[WD Dest],FromDate,ToDate,ActivityCode,Description,[Applicable Period],[RFA Period],Division,
	Code,Name,UOM,Type,SaleQty,SaleValue,PromotedQty,PromotedValue,TaxPercentage,TaxAmount,RebateQty,RebateValue)
	select Top 1 @WDCode,@WDDestCode,@FromDate,@ToDate,@ActivityCode,@Description,@ApplicablePeriod,@RFAPeriod,Division,
	SystemSKU,Null,UOM,Null,SaleQty,SaleValue,PromotedQty,PromotedVal,TaxPercentage,TaxAmount,RebateQty,RebateVal from #tmpDtlQPSData
	Group By Division,SystemSKU,UOM,SaleQty,SaleValue,PromotedQty,PromotedVal,TaxPercentage,TaxAmount,RebateQty,RebateVal

--  Drop table #tmpAbsQPSData     
  Drop table #tmpDtlQPSData     
  Drop table #tmpSchPayout  

End

Insert into #ValidateTable (ActivityCode,ApplicablePeriod,RFAPeriod,SchemeID,PayoutID)
select @ActivityCode,@ApplicablePeriod,@RFAPeriod,@Schemeid,@szPayoutID from #tmpFinaldata Where ActivityCode = @ActivityCode and [Applicable Period] = @ApplicablePeriod and [RFA Period] = @RFAPeriod
NoScheme:
--*************************************************************************************************
--Fetch Next From Cur_6 Into @SchemeDet,@ActivityCode,@Description,@ApplicablePeriod,@RFAPeriod
Fetch From Cur_6 Into @SchemeID,@PayoutID,@ActivityCode,@Description,@ApplicablePeriod,@RFAPeriod
End
End
Close Cur_6
Deallocate  Cur_6

Update #tmpFinaldata set [Type] = 'MAIN' Where [Type] = 'QPS'
Update #tmpFinaldata set [Type] = 'MAIN' Where [Type] is Null
Update T set T.Name = T1.CNT From #tmpFinaldata T , (select Distinct Product_Code,ProductName CNT from Items) T1 Where T1.Product_Code = T.Code
Update #tmpFinaldata set RebateQty = Null Where isnull(RebateQty,0) = 0 
Update #tmpFinaldata set RebateValue = Null Where isnull(RebateValue,0)=0 
Update #tmpFinalData set Taxpercentage=null,TaxAmount=null where isnull(taxpercentage,0) = 0
-- For Over all sales Qty, Value Updated from Over all sales.





Update B set B.QPS = 1 From #tmpFinaldata B,(select Top 1 Code,RebateQty From #tmpFinaldata Where [Type] = 'Free') A
Where A.Code = B.Code and A.RebateQty =B.RebateQty

Update B set B.QPS = 2 From #tmpFinaldata B,(select Top 1 Code,SaleQty,SaleValue From #tmpFinaldata Where [Type] = 'MAIN') A
Where A.Code = B.Code and A.SaleQty =B.SaleQty AND A.SaleValue =B.SaleValue

Update B set B.QPS = 3 From #tmpFinaldata B,(select Top 1 Code,SaleQty,SaleValue,PromotedQty,PromotedValue,RebateQty,RebatevALUE From #tmpFinaldata Where [Type] = 'MAIN') A
Where A.Code = B.Code and A.SaleQty =B.SaleQty AND A.SaleValue =B.SaleValue AND A.PromotedQty =B.PromotedQty AND A.PromotedValue =B.PromotedValue
and isnull(A.RebateQty, 0) <> 0 OR  isnull(A.RebatevALUE, 0) <> 0


	select [WD Code] WdCode,[WD Code],[WD Dest],FromDate [From Date],ToDate [To Date],ActivityCode,Description,left([Applicable Period],10) [Applicable From Date],Right([Applicable Period],11) [Applicable To Date],Left([RFA Period],10) [RFA From Date],Right([RFA Period],11) [RFA To Date],Division,Code,Name,UOM,Type,
	Max(SaleQty) SaleQty,Max(SaleValue) SaleValue,Max(PromotedQty) PromotedQty,Max(PromotedValue) PromotedValue,Max(TaxPercentage) TaxPercentage,Max(TaxAmount) TaxAmount,Max(RebateQty) RebateQty,Max(RebateValue) RebateValue,QPS Into #TempOutputtable
	from #tmpFinaldata Group by [WD Code],[WD Code],[WD Dest],FromDate ,ToDate,ActivityCode,Description,Code,[Applicable Period],[RFA Period],Division,Code,Name,isnull(TaxPercentage,0),UOM,Type,QPS 
	Order by ActivityCode,[RFA From Date],[RFA To Date]--,Type 

--Create Table #tempSumSQtySvalue 
--(
--	[Product_Code] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
--	[Quantity] [decimal](18, 6) NULL,
--	[SalePrice] [decimal](18, 6) NULL,
--	FinInvFromDate  DateTime NULL,
--	FinInvToDate  DateTime NULL
--)
--
--insert into #tempSumSQtySvalue([Product_Code],[Quantity],[SalePrice])
--select B.Code, Sum(D.Quantity), sum(D.Quantity * D.SalePrice) From #TmpTSRInvDtl D, #TmpTSRInvAbs A ,#TempOutputtable B
--Where  D.Product_Code = B.Code and A.InvoiceType  in (1,3) and (A.Status & 128) = 0 and D.InvoiceId = A.InvoiceId 
--And A.Invoicedate Between cast (B.[RFA From Date] as DateTime) and Cast(B.[RFA To Date]  as DateTime) Group by  B.Code
--
--
--Update S set S.FinInvFromDate = cast (T.[RFA From Date] as DateTime),S.FinInvToDate = Cast(T.[RFA To Date]  as DateTime) From #TempOutputtable T,#tempSumSQtySvalue S
--Where T.Code = S.Product_Code
--
--
--Update T set T.SaleQty = S.Quantity,T.SaleValue = S.[SalePrice] From #TempOutputtable T,#tempSumSQtySvalue S
--Where T.Code = S.Product_Code And [Type] Like '%MAIN%' And  T.[RFA From Date] = S.FinInvFromDate and T.[RFA To Date] = S.FinInvToDate
--
--Drop table #tempSumSQtySvalue
--


Begin
	Declare @cur_11 Cursor 
	Declare @FinInvFromDate as DateTime
	Declare @FinInvToDate as DateTime
	Set @cur_11 = Cursor for
	Select Code,cast([RFA From Date] as DateTime),Cast([RFA To Date]  as DateTime) from #TempOutputtable Where [Type] = 'MAIN'
	Open @cur_11
	Fetch Next from @cur_11 into @code,@FinInvFromDate,@FinInvToDate
	While @@fetch_status =0
		Begin
			Set @SQty = 0
			Set @SValue = 0
			select @SQty = Sum(D.Quantity), @SValue = sum(D.Quantity * D.SalePrice) From #TmpTSRInvDtl D, #TmpTSRInvAbs A 
			Where  D.Product_Code = @code and A.InvoiceType  in (1,3) and (A.Status & 128) = 0 and D.InvoiceId = A.InvoiceId 
			--And A.Invoicedate Between dbo.StripTimeFromDate(@FinInvFromDate) and dbo.StripTimeFromDate(@FinInvToDate)
			And A.Invoicedate Between @FinInvFromDate and @FinInvToDate
				Begin
					Update #TempOutputtable set SaleQty = @SQty, SaleValue = @SValue Where Code = @code and [Type] Like '%MAIN%' and [RFA From Date] = @FinInvFromDate and [RFA To Date] = @FinInvToDate
				End

			Fetch Next from @cur_11 into @code,@FinInvFromDate,@FinInvToDate
		End
	Close @cur_11
	Deallocate @cur_11
End	

	select 1,[WD Code],[WD Dest],[From Date],[To Date],ActivityCode,Description,[Applicable From Date],[Applicable To Date],[RFA From Date],[RFA To Date],Division,Code,Name,UOM,Type,
	SaleQty,SaleValue,PromotedQty,PromotedValue,TaxPercentage,TaxAmount,RebateQty,RebateValue From #TempOutputtable

Outside:
	Drop Index #TmpTSRInvAbs.IDX_C_TmpTSRInvAbs_InvoiceID_Upload
	Drop Index #TmpTSRInvDtl.IDX_NonC_TmpTSRInvDtl_InvoiceID_Upload
	Drop table #TempOutputtable
	Drop table #tmpFinaldata
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
	Drop table #ValidateTable

	Drop Table #tmpScheme
	Drop Table #tmpActivityCode
	Drop Table #TmpSchememaster
	Drop Table #SkipSRInvScheme
End

OvernOut1:

--***************************************************************************************
