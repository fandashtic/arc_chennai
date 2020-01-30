Create Procedure mERP_sp_GetRFAData(@Schtype Int, @SchemeID Int, @ActCode nVarchar(255), @PayoutID Int, @Mname nVarchar(255) = '')
As
Begin

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
	Declare @InvRebateValue Decimal(18,6)
	Declare @SRRebateValue Decimal(18,6)
	Declare @RedeemDate datetime
	Declare @InvoiceRef nVarchar(255)
	Declare @OutletCode nVarchar(255)
	Declare @InvSRID Int
	Declare @TaxConfigFlag Int
	Declare @MarginPTR Decimal(18,6)
	Declare @QPS Int
	Declare @ItemFree Int
	Declare @QPSSrNo Int
	Declare @TaxConfigCrdtNote Int
	

	
	-- Begin: Gift Voucher 
	Declare @GVPrefix nVarchar(10)
	Declare @ldlm SMALLDATETIME
	Declare @ldtm SMALLDATETIME
	Declare @fdtm SMALLDATETIME
	Declare @refm SMALLINT
	Declare @thisDay TINYINT
	Declare @refd datetime
	Declare @today datetime
	Declare @GVFirstDay int
	Declare @GVFirstMonth int
	Declare @GVFirstYear int
	Declare @GVlastDay int
	Declare @Firstmonth nVarchar(1000)
	Declare @lastmonth nVarchar(1000)
	Declare @GV1Firstmonth nVarchar(1000)
	Declare @GV1lastmonth nVarchar(1000)
	Declare @GSTDocID nVarchar(255)	

	-- End: Gift Voucher 
	--DandD RFA With or without Tax
	Declare @DandDRFATaxFlag int
	Select @DandDRFATaxFlag = isnull(Flag,0) From tbl_merp_ConfigAbstract Where ScreenCode = 'DandDRFATax'


	/* This procedure works on assumption that either an entire scheme will be a QPS scheme 
		or Non QPS scheme */


	/* Checking for Tax Configuration /
	Flag = 1 Include Tax 
	Flag = 0 Without Tax 
	For Rebate Value calculation for Free Item*/
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
	Select @GVPrefix = Prefix  From VoucherPrefix (NoLock) Where TranID = 'GIFT VOUCHER'

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
							PointsValue Decimal(18,6), ReferenceNumber nVarchar(255), LoyaltyID nVarchar(255), CSSchemeID int,[Doc No] nVarchar(500) collate SQL_Latin1_General_CP1_CI_AS,
							SalvageQty Decimal(18,6), SalvageValue Decimal(18,6), DamageDesc nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, 
							DamageDate nVarchar(20) collate SQL_Latin1_General_CP1_CI_AS,
							SchemeFromDate nVarchar(20) collate SQL_Latin1_General_CP1_CI_AS,
							SchemeToDate nVarchar(20) collate SQL_Latin1_General_CP1_CI_AS,DamageOption int,TOQ int)

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
							TaxPercentage Decimal(18,6), TaxAmount Decimal(18, 6), PriceInclTax Decimal(18, 6),BudgetedQty Decimal(18,6),  BudgetedValue Decimal(18,6),InvoiceType Int,[Doc No]  nVarchar(500) collate SQL_Latin1_General_CP1_CI_AS,TOQ int)

	/* Commented On Nov 4 
		Create table #temp( Id int Identity(1,1), Schemetype nVarchar(100), CSSchemeID int, ActivityCode nVarchar(100), 
		ActivityType nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, FirstMonth datetime, 
		LastMonth datetime, GiftVoucherNo NVarchar(255) collate SQL_Latin1_General_CP1_CI_AS)  
	Commented On Nov 4 */

	Create Table #Temp ( ID int Identity(1,1),  DocID nVarchar(255), DocType nVarchar(255),  DocIDNo nVarchar(255), FirstMonth nVarchar(255), LastMonth nVarchar(255), 
	SchemeType  Int, ClaimID Int, ClaimAmount decimal(18,6), LoyaltyID nVarchar(100), MName nVarchar(100)
	,GVYear nVarchar(100))

	Create Table #TempFinal ( ID int Identity(1,1), GVSchemetype nVarchar(100), DocID nVarchar(255), DocType nVarchar(255),  DocIDNo nVarchar(255), FMonth nVarchar(255), LMonth nVarchar(255), 
	SchemeType  Int, ClaimID Int, ClaimAmount decimal(18,6), LoyaltyID nVarchar(100), MName nVarchar(100), GVYear nVarchar(100))

	
	Create Table #tmpSKUWiseSales(SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS ,SalesQty Decimal(18,6),SalesValue Decimal(18,6))


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
					    [Doc No] nVarchar(500) collate SQL_Latin1_General_CP1_CI_AS,TOQ int)

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
						[Doc No] nVarchar(500) collate SQL_Latin1_General_CP1_CI_AS,TOQ int)

	Create Table #tmpSales(SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
						   SaleQty Decimal(18,6),SaleValue Decimal(18,6),
							Flagword Int,InvoiceType Int)

	Create Table #tmpSerial(Serial Int)
	/*SchType = 1 - SP, SchType = 2 - CP, SchType = 3 - Display, SchType = 4 - Points*/
	/*SchType = 6 - Damages, SchType = 7 - Expiry, SchType = 8 - Sampling*/
	/* SchType = 10 Gift Voucher */

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

--select @MonthName = CONVERT(varchar(3), GetDate(), 100) 
--Select @MonthName = CONVERT(varchar(3), @PrevM, 100) 
--Select @Year = datepart(year,getdate())
--Select @Year = datepart(year,@PrevM)

-- End: Gift Voucher 

If @SchType = 10 /*--Gift Voucher - Start*/
Begin
Set DateFormat dmy

	/* Commented on Nov 4
	Insert Into #temp (Schemetype, CSSchemeID, ActivityCode,  ActivityType, GiftVoucherNo)
	Select 'GV' , CreditID, GiftVoucherNo, Loyalty.LoyaltyName, GiftvoucherNo
	From CreditNote Inner join Loyalty On CreditNote.LoyaltyID = Loyalty.LoyaltyID
	where CreditID = @SchemeID And
	IsNull(Flag,0) = 2 
	And isnull(status & 128,0 ) = 0
	*/


	Insert Into #Temp (DocID , DocType , DocIDNo, SchemeType, ClaimAmount, LoyaltyID, MName, GVYear) 
	Select  
	Loyalty.LoyaltyName --+ '-' + @MonthName + '-' + @Year,
	,Loyalty.LoyaltyName --+ '-' + @MonthName + '-' + @Year,
	,GiftVoucherNo,
	'10' as SchemeType
	, Sum(NoteValue-Balance)
	, Loyalty.LoyaltyID
	, CONVERT(varchar(3), dbo.StripTimeFromDate(DocumentDate), 100) 
	, datepart(year,Convert(DateTime,dbo.StripTimeFromDate(DocumentDate)))
	From CreditNote (NoLock) Inner join Loyalty On CreditNote.LoyaltyID = Loyalty.LoyaltyID
	Where IsNull(Flag, 0) = 2
	and IsNull(CreditNote.LoyaltyID,'') = @ActCode
	And Loyalty.LoyaltyID in ('L1','L2','L3')
	and IsNull(ClaimRFA,0) = 0
	and IsNull(Status,0) not in (64,128)
	And DateDiff(d, GetDate(), '01/' + Cast(Month(DATEADD(Month, 1, dbo.StripTimeFromDate(DocumentDate))) as nVarchar(10)) + '/' + Cast(Year(DATEADD(Month, 1, dbo.StripTimeFromDate(DocumentDate))) as nVarchar(10))) <= 0
	--And Convert(Varchar(3), CreditNote.DocumentDate, 100) = IsNull(@MName,'')
	And Convert(Varchar(3), CreditNote.DocumentDate, 100) + '-' + Convert(Varchar(4), CreditNote.DocumentDate,112) = IsNull(@MName,'')
	Group By  CreditNote.LoyaltyID, Loyalty.LoyaltyName, GiftVoucherNo, NoteValue, Loyalty.LoyaltyID
	, CreditNote.DocumentDate


		Declare MyCur Cursor For
		Select DocIDNo from #Temp  Order By ID 
		Open MyCur
		Fetch From MyCur Into @GVDocID
		While @@Fetch_Status = 0
		Begin
			Select @DocDate = DocumentDate From creditNote (NoLock) where IsNull(Flag, 0) = 2
			And GiftVoucherNO = @GVDocID
			and IsNull(ClaimRFA,0) = 0
			and IsNull(Status,0) not in (64,128)

			-- Select @D1 = DateAdd(Month, -1, @DocDate)
			Select @D1 = @DocDate
			Select @D1 = Convert(DateTime, '01/' +  Cast(Month(@D1) as nVarchar) + '/' + Cast(Year(@D1) as nVarchar) , 103)

			Select @D2 = DateAdd(Month, 1, @D1)
			Set @LastDate = Day(DateAdd(Day,-1, @D2))
			SEt @D2 = Cast(@LastDate as nVarchar) + '/' + Cast(Month(@D1) as nVarchar) + '/' + Cast(Year(@D1) as nVarchar)

			Set @Dy = Day(@D1)
			Set @Mth = Month(@D1)
			Set @yr = year (@D1)

			Set @LDy = Day(@D2)
			Set @LMth = Month(@D2)
			Set @LYr = year (@D2)

			Select @Firstmonth = Cast(@Dy as nVarchar(30)) + '/' + Cast(@Mth as nVarchar(30)) + '/' +
								Cast(@yr as nVarchar(30)) 

			Select @Lastmonth  = Cast(@LDy as nVarchar(30)) + '/' + Cast(@LMth as nVarchar(30)) + '/' +
								Cast(@LYr as nVarchar(30)) 

			Update #temp Set FirstMonth = 	@Firstmonth, Lastmonth= @Lastmonth Where DocIDNo = @GVDocID

		
		Fetch Next From MyCur Into @GVDocID
		End
		close  MyCur
		Deallocate Mycur

	/* Commented On Nov 4
	Insert Into #RFAInfo (OutletCode, RebateValue, SchemeOutlet, SchemeSKU,  Flagword, SchemeID) 
		Select CustomerID, NoteValue, 1, 1, 2, @SchemeID From CreditNote 
		Where CreditID = @SchemeID AND IsNull(Flag,0) = 2 And isnull(status & 128,0 ) = 0
	*/

	Insert Into #Temp (DocID , DocType , DocIDNo, SchemeType, ClaimAmount, LoyaltyID, MName, GVYear,FirstMonth,Lastmonth) 
	Select  
	Loyalty.LoyaltyName --+ '-' + @MonthName + '-' + @Year,
	,Loyalty.LoyaltyName --+ '-' + @MonthName + '-' + @Year,
	,GiftVoucherNo,
	'10' as SchemeType
	, Sum(NoteValue-Balance)
	, Loyalty.LoyaltyID
	, CONVERT(varchar(3), dbo.StripTimeFromDate(CLO.CLODate), 100) 
	, datepart(year,Convert(DateTime,dbo.StripTimeFromDate(CLO.CLODate)))
	,CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(CLO.CLODate)-1),CLO.CLODate),103)
	,CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,CLO.CLODate))),DATEADD(mm,1,CLO.CLODate)),103)
	From CreditNote (NoLock) Inner join Loyalty On CreditNote.LoyaltyID = Loyalty.LoyaltyID Inner Join clocrnote CLO ON CreditNote.CreditID=CLO.CreditID
	Where IsNull(Flag, 0) = 1
	and IsNull(CLO.ActivityCode,'') = @ActCode
	And Loyalty.LoyaltyID not in ('L1','L2','L3')
	and IsNull(ClaimRFA,0) = 0
	and IsNull(Status,0) not in (64,128)
	And DateDiff(d, GetDate(), '01/' + Cast(Month(DATEADD(Month, 1, dbo.StripTimeFromDate(CLO.CLODate))) as nVarchar(10)) + '/' + Cast(Year(DATEADD(Month, 1, dbo.StripTimeFromDate(CLO.CLODate))) as nVarchar(10))) <= 0
	--And Convert(Varchar(3), CLO.CLODate, 100) = IsNull(@MName,'')
	And Convert(Varchar(3), CLO.CLODate, 100) + '-' + Convert(Varchar(4), CLO.CLODate,112) = IsNull(@MName,'')
	Group By  CreditNote.LoyaltyID, Loyalty.LoyaltyName, GiftVoucherNo, NoteValue, Loyalty.LoyaltyID
	,CLO.CLODate

	--Select * from #Temp

	Insert Into #TempFinal(GVSchemetype, DocID, DocType, FMonth, LMonth, SchemeType, ClaimAmount, LoyaltyID)
		Select Distinct 'GV', DocID + '-' + MName + '-' + GVyear as ActivityCode, DocType + '-' + MName + '-' + GVyear as Description,  FirstMonth As MonthFirstDay, LastMonth As MonthLastDay, 
		SchemeType, Sum(ClaimAmount), LoyaltyID from #temp
		Where LoyaltyID in ('L1','L2','L3')
		Group By LoyaltyID, DocID, DocType, FirstMonth, LastMonth, SchemeType, MName, GVyear
		union
		Select Distinct 'GV',@ActCode as ActivityCode, 'CLO CreditNote' as Description,  FirstMonth As MonthFirstDay, LastMonth As MonthLastDay, 
		SchemeType, Sum(ClaimAmount), @ActCode from #temp
		Where LoyaltyID not in ('L1','L2','L3')
		Group By LoyaltyID, DocID, DocType, FirstMonth, LastMonth, SchemeType, MName, GVyear

	--Select * from #TempFinal

	Insert Into #RFAInfo (OutletCode,RCSID, RebateValue, SchemeOutlet, SchemeSKU,  Flagword, LoyaltyID, CSSchemeID,BillRef) 
		Select CR.CustomerID, C.RCSOUTLETID,NoteValue-Balance , 1, 1, 2, @ActCode, CreditID,NULL From CreditNote CR(NoLock) ,customer C
		Where LoyaltyID = @ActCode AND IsNull(Flag,0) = 2 And isnull(CR.status & 128,0 ) = 0
		And DateDiff(d, GetDate(), '01/' + Cast(Month(DATEADD(Month, 1, dbo.StripTimeFromDate(CR.DocumentDate))) as nVarchar(10)) + '/' + Cast(Year(DATEADD(Month, 1, dbo.StripTimeFromDate(CR.DocumentDate))) as nVarchar(10))) <= 0
		--And Convert(Varchar(3), CR.DocumentDate, 100) = IsNull(@MName,'')
		And Convert(Varchar(3), CR.DocumentDate, 100) + '-' + Convert(varchar(4), CR.DocumentDate, 112) = IsNull(@MName,'')
		And LoyaltyID in ('L1','L2','L3') and CR.CustomerID=C.Customerid
		union
		Select CreditNote.CustomerID, C.RCSOUTLETID, NoteValue-Balance, 1, 1, 2, @ActCode, CreditNote.CreditID,CLO.RefNumber From CreditNote (NoLock),clocrnote CLO,Customer C
		Where CLO.CreditID =CreditNote.CreditID And CLO.ActivityCode = @ActCode AND IsNull(Flag,0) = 1 And isnull(status & 128,0 ) = 0
		And DateDiff(d, GetDate(), '01/' + Cast(Month(DATEADD(Month, 1, dbo.StripTimeFromDate(CLO.CLODate))) as nVarchar(10)) + '/' + Cast(Year(DATEADD(Month, 1, dbo.StripTimeFromDate(CLO.CLODate))) as nVarchar(10))) <= 0
		--And Convert(Varchar(3), CLO.CLODate, 100) = IsNull(@MName,'')
		And Convert(Varchar(3), CLO.CLODate, 100) + '-' + Convert(Varchar(4), CLO.CLODate,112) = IsNull(@MName,'')
		And LoyaltyID NOT in ('L1','L2','L3') and CreditNote.CustomerID = C.CustomerID

	--Select * from #RFAInfo

If (Select Count(*) From #RFAInfo Where LoyaltyID = @ActCode And IsNull(FlagWord, 0) = 2) >= 1
	Begin
		Select @WDCode as WDCode, @WDDest as WDDest, tmp.GVSchemeType as SchemeType, tmp.DocID as ActivityCode, 
			tmp.DocType as ActivityDesc, tmp.FMonth as ActiveFrom, tmp.LMonth As ActiveTo, 
			tmp.FMonth as PayoutFrom, tmp.LMonth As PayoutTo, 0 as SR,
			Division, SubCategory, MarketSKU, SKUCode, UOM, Sum(SaleQty) as SaleQty,
			Sum(SaleValue) as SaleValue, Sum(PromotedQty) as PromotedQty, Sum(PromotedValue) as PromotedValue, 
			Max(FreeBaseUOM) as FreeBaseUOM, Sum(IsNull(RebateQty,0)) as RebateQty, Sum(IsNull(RebateValue,0)) as RebateValue, 
			'' as BudgetedQty, '' as BudgetedValue
			, @ApplicableOn as AppOn
			From #RFAInfo RFA
			Inner Join #TempFinal tmp On  RFA.LoyaltyID = tmp.LoyaltyID
			where RFA.LoyaltyID = @ActCode
			Group By SKUCode, Division, SubCategory, MarketSKU, UOM, tmp.FMonth, tmp.LMonth
			, tmp.GVSchemeType,  tmp.DocID, tmp.DocType
			Order By SKUCode
	End
	Else
	Begin
			Select @WDCode as WDCode, @WDDest as WDDest, @SchemeType as SchemeType, @ActivityCode as ActivityCode, 
			@ActivityType as ActivityDesc, @ActiveFrom as ActiveFrom, @ActiveTo As ActiveTo, 
			@PayoutFrom as PayoutFrom, @PayoutTo As PayoutTo,0 as SR,Null as Division,Null as SubCategory,Null as MarketSKU,Null as SKUCode,
			Null as UOM,Null as SaleQty,Null as SaleValue,Null as  PromotedQty,Null as PromotedValue,
			Null as FreeBaseUOM,Null as RebateQty,Null as RebateValue,Null as BudgetedQty,Null as BudgetedValue,@ApplicableOn as AppOn 
		End

	
	/* Detail Part */
			Select @WDCode as WDCode, @WDDest as WDDest, 
				tmp.DocID as ActivityCode, #RFAInfo.CSSchemeID as CompSchemeID, tmp.DocType as ActivityDesc, 
				tmp.FMonth as ActiveFrom, tmp.Lmonth As ActiveTo, 0 as SR, BillRef, OutletCode, isNull(Cust.RCSOutletID,'') as 'RCSID',
				ActiveInRCS = (Case when IsNull(Cust.RCSOutletID,'') <> '' then 'Yes' else 'No' end),
				LineType, Division, SubCategory, MarketSKU, SKUCode, UOM, Sum(SaleQty) as SaleQty,
				Sum(SaleValue) as SaleValue, Sum(PromotedQty) as PromotedQty, Sum(PromotedValue) as PromotedValue, Sum(IsNull(RebateQty,0)) as RebateQty, 
				Sum(IsNull(RebateValue,0)) as RebateValue, Max(PriceExclTax) as PriceExclTax, Max(TaxPercentage) as TaxPercentage, Max(TaxAmount) as TaxAmount,
				Max(PriceInclTax) as PriceInclTax,'' as BudgetedQty, '' as BudgetedValue,Cust.Company_Name as 'OutletName' Into #ConDetailGV
				From #RFAInfo , Customer Cust 
				,#TempFinal tmp   
				Where #RFAInfo.LoyaltyID = @ActCode
				And Cust.CustomerID = #RFAInfo.OutletCode 
				And #RFAInfo.LoyaltyID = tmp.LoyaltyID
				And IsNull(FlagWord,0) = 0
				Group By InvoiceId, SKUCode, BillRef, OutletCode, RCSID, ActiveInRCS, LineType, Division, SubCategory, MarketSKU, UOM,Cust.Company_Name
				, tmp.FMonth, tmp.LMonth, #RFAInfo.CSSchemeID , tmp.DocID, tmp.DocType ,Cust.RCSOutletID
				Order By SKUCode


		Insert Into #ConDetailGV Select 
		@WDCode as WDCode, @WDDest as WDDest, 
		tmp.DocID as ActivityCode, #RFAInfo.CSSchemeID as CompSchemeID, tmp.DocType as ActivityDesc, 
		tmp.Fmonth as ActiveFrom, tmp.Lmonth As ActiveTo, 0 as SR, BillRef, OutletCode, isNull(RCSID,''), 
		ActiveInRCS = (Case when IsNull(Cust.RCSOutletID,'') <> '' then 'Yes' else 'No' end),
		LineType, Division, SubCategory, MarketSKU, SKUCode, UOM, Sum(SaleQty) as SaleQty,
		Sum(SaleValue) as SaleValue, Sum(PromotedQty) as PromotedQty, Sum(PromotedValue) as PromotedValue, Sum(IsNull(RebateQty,0)) as RebateQty, 
		Sum(IsNull(RebateValue,0)) as RebateValue, Max(PriceExclTax) as PriceExclTax, Max(TaxPercentage) as TaxPercentage, Max(TaxAmount) as TaxAmount,
		Max(PriceInclTax) as PriceInclTax,'' as BudgetedQty, '' as BudgetedValue,Cust.Company_Name as 'OutletName' --Into #ConDetail
		From #RFAInfo,Customer Cust 
				, #TempFinal tmp 
				Where #RFAInfo.LoyaltyID = @ActCode
				And Cust.CustomerID = #RFAInfo.OutletCode 
				And #RFAInfo.LoyaltyID = tmp.LoyaltyID
				And IsNull(FlagWord,0) = 2
				Group By InvoiceId, SKUCode, BillRef, OutletCode, RCSID, ActiveInRCS, LineType, Division, SubCategory, MarketSKU, UOM,Cust.Company_Name
				, tmp.FMonth, tmp.LMonth, #RFAInfo.CSSchemeID , tmp.DocID, tmp.DocType ,Cust.RCSOutletID
				Order By SKUCode
				If (Select Count(*) From  #ConDetailGV) >= 1 
				Begin
					Select * From #ConDetailGV Order By LineType Desc
				End
				Else
				Begin
					Select  @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, @CSSchemeID as CompSchemeID, @ActivityType as ActivityDesc, 
					@PayoutFrom as ActiveFrom, @PayoutTo As ActiveTo,0 as SR,Null as BillRef,Null as OutletCode,Null as RCSID,Null as  ActiveInRCS,
					Null as LineType,Null as Division,Null as SubCategory,Null as MarketSKU,Null as SKUCode,
					Null as UOM,Null as SaleQty,Null as SaleValue,Null as  PromotedQty,Null as PromotedValue,
					Null as RebateQty,Null as RebateValue,Null as PriceExclTax,Null as TaxAmount,Null as TaxPercentage,
					Null as PriceInclTax,Null as BudgetedQty,Null as BudgetedValue,Null as 'OutletName'
				End
				Drop Table #ConDetailGV	
End
/* End of Schemetype = 10 Gift Voucher */
	
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
			@ExpiryDate = SA.ExpiryDate,	
			@ApplicableOn = Case When SA.ApplicableOn =1 And SA.ItemGroup = 1 Then 'ITEM'
								When SA.ApplicableOn =1 And SA.ItemGroup = 2 Then 'SPL_CAT'	
								When SA.ApplicableOn = 2 Then 'INVOICE'
								End,
			@ItemGroup = Itemgroup
			From tbl_mERP_SchemeAbstract SA(NoLock), tbl_mERP_SchemeType ST(NoLock), tbl_mERP_SchemePayoutPeriod SPP(NoLock)
			Where SA.SchemeID = @SchemeID
			And SA.ActivityCode = @ActCode
			And SA.SchemeType = ST.ID
			And SA.SchemeID = SPP.SchemeID
			And SPP.ID = @PayoutID

			
			
		    Select @QPS = QPS From tbl_mERP_SchemeOutlet (NoLock) Where SchemeID = @SchemeID And QPS = 1
	
			Select @ItemFree = (Case Max(SlabType) When 1 Then 0 When 2 Then 0 Else 1 End) From tbl_mERP_SchemeSlabDetail (NoLock) Where SchemeID = @SchemeID


		/* Table Used to store the Total Sales qty and Volume SKUWise Starts */

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
			From InvoiceAbstract IA(Nolock), InvoiceDetail ID (NoLock), Customer C (NoLock)
			Where IA.InvoiceId = ID.InvoiceId
			And IA.InvoiceType In (1,3,4)        
			And (IA.Status & 128) = 0  
			And IA.CustomerID = C.CustomerID
			And (Case IA.InvoiceType
						When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract (NoLock) Where DocumentID = 
						IA.DocumentID
						And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)
						Else dbo.StripTimeFromDate(IA.InvoiceDate)
						End) Between @ActiveFrom And @ActiveTo
			And (Case IA.InvoiceType
					When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract (NoLock) Where DocumentID = IA.DocumentID
						And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID) 
					Else dbo.StripTimeFromDate(IA.InvoiceDate)
					End) Between @PayoutFrom And @PayoutTo

		


		-- Total Quantity and Total Sales Change
		/* To Insert ProductWise Sales From And To PayoutPeriod */
		Truncate table #tmpSKUWiseSales
		Insert Into #tmpSKUWiseSales(SKUCode,SalesQty,SalesValue)
		Select SKUCode,Sum(Case InvoiceType When 4 Then -1 * SaleQty Else SaleQty End),
		Sum(Case InvoiceType When 4 Then -1 * SaleValue Else SaleValue End) From #tmpSales 
		Where FlagWord = 0 
		Group By SKUCode

	/*  Table Used to store the Total Sales qty and Volume SKUWise Ends*/

	

		/*Percentage Or Amount Scheme*/
--		Declare OffTakeCur Cursor For
--			Select CustomerID, (NoteValue - Balance) as RebateValue, @CrNotePrefix + Cast(DocumentID as nVarchar) From CreditNote 
--				Where PayoutID = @PayoutID
--				And Balance = 0
--		Open OffTakeCur
--		Fetch Next From OffTakeCur Into @CustomerID, @RebateValue, @CreditRef
--		While @@Fetch_Status = 0
--		Begin
--			Set @BillRef = ''
--			Declare InvCursor Cursor For
--				Select Distinct DocumentID, AdjRef 
--					From InvoiceAbstract IA, InvoiceDetail ID
--				Where IA.InvoiceId = ID.InvoiceId
--				And IA.InvoiceType In (1,3)        
--				And (IA.Status & 128) = 0  
--				And IA.CustomerID = @CustomerID
--				And dbo.StripTimeFromDate(IA.InvoiceDate) > @PayoutTo
--				And IsNull(AdjRef, '') <> ''
--			Open InvCursor
--			Fetch Next From InvCursor Into @InvoiceID, @AdjRef
--			While @@Fetch_Status = 0
--			Begin
--				If Exists (Select * From dbo.sp_SplitIn2Rows(@AdjRef, ',') Where LTrim(ItemValue) = @CreditRef)
--				Begin
--					If IsNull(@BillRef, '') = ''
--						Set @BillRef = @InvPrefix + Cast(@InvoiceID as nVarchar)
--					Else
--						Set @BillRef = @BillRef + '|' + @InvPrefix + Cast(@InvoiceID as nVarchar)
--				End
--				Fetch Next From InvCursor Into @InvoiceID, @AdjRef
--			End
--			Close InvCursor
--			Deallocate InvCursor
--
--			Insert Into #RFAInfo (OutletCode, BillRef, RebateValue, SchemeOutlet, SchemeSKU, SchemeID) 
--					Values (@CustomerID, @BillRef, @RebateValue, 1, 1, @SchemeID)
--			Fetch Next From OffTakeCur Into @CustomerID, @RebateValue, @CreditRef
--		End
--		Close OffTakeCur
--		Deallocate OffTakeCur

--		Insert Into #RFAInfo (OutletCode, RebateValue, SchemeOutlet, SchemeSKU, SchemeID) 
--		Select CustomerID, NoteValue, 1, 1, @SchemeID From CreditNote 
--		Where PayoutID = @PayoutID and IsNull(Status,0) & 64 = 0 

		
		
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
				
					Insert Into #RFAInfo(InvoiceID, BillRef,OutletCode, SKUCode,RebateQty, RebateValue, SchemeOutlet, SchemeSKU, SchemeID,
							PriceExclTax, TaxPercentage, TaxAmount, PriceInclTax,LineType,[Doc No],TOQ)
					Select IA.InvoiceID,
					Case IsNULL(IA.GSTFlag ,0)
					When 0 then @InvPrefix + Cast(IA.DocumentID as nVarchar)
					Else
						IsNULL(IA.GSTFullDocID,'')
					End as BillRef, 
					IA.CustomerID, @SKUCode,Sum(Quantity),

						Sum(Quantity) * (@MarginPTR + (Case @TaxConfigFlag When 1 Then (Case Max(Isnull(ID.TAXONQTY,0)) when 0 then  (@MarginPTR * Max(TaxCode)/100) Else Max(TaxCode) End) Else 0 End)),
						 1, 1, @SchemeID, @MarginPTR, Max(ID.TaxCode), 
						(case Max(Isnull(ID.TAXONQTY,0)) when 0 then 
						(Sum(ID.Quantity) * (@MarginPTR * (Max(ID.TaxCode) / 100))) Else (Sum(ID.Quantity) * Max(ID.TaxCode)) End),
						 (case Max(Isnull(ID.TAXONQTY,0)) when 0 then 
						@MarginPTR + (@MarginPTR * (Max(ID.TaxCode) / 100)) Else (@MarginPTR + Max(ID.TaxCode)) End) ,'Free',
					    IA.DocReference,Max(Isnull(ID.TAXONQTY,0))
						From InvoiceAbstract IA (NoLock), InvoiceDetail ID (NoLock) 
						Where IA.InvoiceID = ID.InvoiceID
						And IA.InvoiceID = Cast(@InvoiceRef as Int)
						And IA.CustomerID = @CustomerID
						And ID.SchemeID = @SchemeID
						And ID.Product_Code = @SKUCode
						And IsNull(Flagword, 0) = 1
						Group By IA.InvoiceID,IA.DocumentID,IA.CustomerID,IA.DocReference,IA.GSTFlag,IA.GSTFullDocID
					Fetch Next From OffTakeSKUCur Into @CustomerID, @SKUCode, @InvoiceRef
				End
				Close OffTakeSKUCur
				Deallocate OffTakeSKUCur
				
--			Update #RFAInfo Set ActiveInRCS = IsNull(TMDValue,N'') 
--						From Cust_TMD_Master CTM, Cust_TMD_Details CTD	
--						Where CTM.TMDID = CTD.TMDID
--						And CTD.CustomerID = #RFAInfo.OutletCode
--						And OutletCode = @CustomerID

			Update #RFAInfo Set RCSID = IsNull(C.RCSOutletID,''),
			ActiveInRCS = (Case when IsNull(C.RCSOutletID,'') <> '' then 'Yes' else 'No' end)
			From  Customer C
			Where  C.CustomerID = #RFAInfo.OutletCode 

			Update RFA Set Division = IC2.Category_Name, SubCategory = IC1.Category_Name, MarketSKU = IC.Category_Name, UOM = U.Description
				From #RFAInfo RFA,Items I , ItemCategories IC, ItemCategories IC1,ItemCategories IC2,UOM U
				Where RFA.SKUCode = I.Product_Code And
				I.CategoryID = IC.CategoryID And
				IC.ParentID = IC1.CategoryID And
				IC1.ParentID = IC2.CategoryID And
				I.UOM = U.UOM
			End

									
			If @ApplicableOn = N'ITEM'  Or @ApplicableOn = 'SPL_CAT'
			Begin
				If @ItemFree = 0 /* Offtake Percentage or Amount Scheme Starts*/
				Begin
					If (Select Count(*) From tbl_mERP_QPSDtlData (NoLock) Where SchemeID = @SchemeID And PayoutID = @PayoutID) >= 1
					Begin
						/* Abstract Data */
						
						Insert Into #tmpRFAAbs
						Select @WDCode as WDCode, @WDDest as WDDest, @SchemeType as SchemeType, @ActivityCode as ActivityCode, 
							@ActivityType as ActivityDesc, @ActiveFrom as ActiveFrom, @ActiveTo As ActiveTo, 
							@PayoutFrom as PayoutFrom, @PayoutTo As PayoutTo, 0 as SR,
							QD.Division, QD.SubCategory, QD.MarketSKU, QD.Product_Code as SKUCode, QD.UOM, Sum(QD.Quantity) as SaleQty,
							Sum(QD.Quantity*QD.SalePrice) as SaleValue, Sum(QD.Promoted_Qty) as PromotedQty, Sum(QD.Promoted_Val) as PromotedValue, 
							'' as FreeBaseUOM, Sum(IsNull(Rebate_Qty,0)) as RebateQty, 
                           (case @TaxConfigCrdtNote When 1 Then Sum(IsNull(Rebate_Val,0)) Else Sum(IsNull(RFARebate_Val,0)) End) as RebateValue, 
							0 as BudgetedQty, 0 as BudgetedValue, @ApplicableOn as AppOn
						From tbl_mERP_QPSDtlData QD (NoLock), tbl_mERP_QPSAbsData QA (NoLock)
						Where QA.SchemeID = @SchemeID
							And QA.PayoutID = @PayoutID
                            And QA.SchemeID = QD.SchemeID
                            And QA.PayoutID = QD.PayoutID
                            And QA.CustomerID = QD.CustomerID							
                            And QD.Product_Code = Case When @ApplicableOn = N'ITEM' Then IsNull(QA.Product_code,'') Else  QD.Product_Code End 
							And ((isNull(QD.Rebate_Qty,0) > 0 Or isNull(QD.Rebate_Val,0) > 0 Or IsNull(QD.RFARebate_Val,0) > 0) or IsNull(QA.SlabID,0) > 0 ) 
						Group By QD.Product_Code, QD.Division, QD.SubCategory, QD.MarketSKU, QD.UOM
							--Order By Product_Code
						UNION
						Select @WDCode as WDCode, @WDDest as WDDest, @SchemeType as SchemeType, @ActivityCode as ActivityCode, 
						    @ActivityType as ActivityDesc, @ActiveFrom as ActiveFrom, @ActiveTo As ActiveTo, 
						    @PayoutFrom as PayoutFrom, @PayoutTo As PayoutTo,Null as SR,Null as Division,Null as SubCategory,Null as MarketSKU,Null as SKUCode,
						    Null as UOM,Null as SaleQty,Null as SaleValue,Null as  PromotedQty,Null as PromotedValue,
						    Null as FreeBaseUOM,Null as RebateQty,Null as RebateValue,Null as BudgetedQty,Null as BudgetedValue,@ApplicableOn as AppOn 
						From tbl_mERP_QPSDtlData QD(NoLock)
						Where QD.SchemeID = @SchemeID
							And QD.PayoutID = @PayoutID
							And (isNull(QD.Rebate_Qty,0) = 0 Or isNull(QD.Rebate_Val,0) = 0 Or IsNull(QD.RFARebate_Val,0) = 0)
    					Group By QD.Product_Code, QD.Division, QD.SubCategory, QD.MarketSKU, QD.UOM
						Order By QD.Product_Code
							
						/* Detail Data */
						Insert Into #tmpRFADet
						Select @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, @CSSchemeID as CompSchemeID, @ActivityType as ActivityDesc, 
							@PayoutFrom as ActiveFrom, @PayoutTo As ActiveTo, 0 as SR, BillRef, QPSDt.CustomerID as OutletCode, 
							IsNull(Cust.RCSOutletID, '') as RCSID,

							--isNull((Select IsNull(TMDValue,N'') From  Cust_TMD_Master CTM, Cust_TMD_Details CTD Where 
							--CTD.CustomerID = QPSDt.CustomerID And CTM.TMDID = CTD.TMDID),'') as ActiveInRCS, 
							(Case when IsNull(Cust.RCSOutletID,'') <> '' then 'Yes' else 'No' end) as ActiveInRCS,

							'QPS' as LineType, QPSDt.Division, QPSDt.SubCategory, QPSDt.MarketSKU, QPSDt.Product_Code as SKUCode, QPSDt.UOM, Sum(QPSDt.Quantity) as SaleQty,
							Sum(QPSDt.Quantity*QPSDt.SalePrice) as SaleValue, Sum(QPSDt.Promoted_Qty) as PromotedQty, Sum(QPSDt.Promoted_Val) as PromotedValue, Sum(IsNull(QPSDt.Rebate_Qty,0)) as RebateQty, 
							(case @TaxConfigCrdtNote When 1 Then Sum(IsNull(QPSDt.Rebate_Val,0)) Else Sum(IsNull(QPSDt.RFARebate_Val,0)) End) as RebateValue,
							Max(QPSDt.SalePrice) as PriceExclTax, Max(isNull(QPSDt.TaxPercent,0)) as TaxPercentage, Sum(isNull(QPSDt.TaxAmount,0)) as TaxAmount,
							(Case Max(QPSDt.TOQ) When 0 Then 
							(Max(QPSDt.SalePrice) + (Max(isNull(QPSDt.SalePrice,0))* Max(isNull(QPSDt.TaxPercent,0))/100)) Else
							 Max(QPSDt.SalePrice) + Max(isNull(QPSDt.TaxPercent,0)) End )
								as  'PriceInclTax',0 as BudgetedQty, 0 as BudgetedValue,
							Cust.Company_Name as 'OutletName',InvDocRef, --Into #ConDetail
							Max(QPSDt.TOQ)
						From tbl_mERP_QPSDtlData QPSDt(NoLock),Customer Cust(NoLock), tbl_mERP_QPSAbsData QPSAb(NoLock)
						Where QPSAb.SchemeID = @SchemeID And QPSAb.PayoutID = @PayoutID
                            And QPSDt.SchemeID = QPSAb.SchemeID 
                            And QPSDt.PayoutID = QPSAb.PayoutID 
                            And QPSDt.CustomerID = QPSAb.CustomerID 							
                            And QPSDt.Product_Code = Case When @ApplicableOn = N'ITEM' Then IsNull(QPSAb.Product_code,'') Else  QPSDt.Product_Code End 
							And ((isNull(Rebate_Qty,0) > 0 Or isNull(Rebate_Val,0) > 0 Or IsNull(RFARebate_Val,0) > 0) OR  IsNull(QPSAb.SlabID,0) > 0 )
							And Cust.CustomerID = QPSDt.CustomerID 
						Group By InvoiceId, QPSDt.Product_Code, BillRef, QPSDt.CustomerID,Cust.RCSOutletID,  QPSDt.Division, QPSDt.SubCategory, QPSDt.MarketSKU, QPSDt.UOM,Cust.Company_Name,QPSDt.InvDocRef
							--Order By Product_Code
						UNION
						Select @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, @CSSchemeID as CompSchemeID, @ActivityType as ActivityDesc, 
							@PayoutFrom as ActiveFrom, @PayoutTo As ActiveTo,Null as SR,Null as BillRef,Null as OutletCode,Null as RCSID,Null as  ActiveInRCS,
							Null as LineType,Null as Division,Null as SubCategory,Null as MarketSKU,Null as SKUCode,
							Null as UOM,Null as SaleQty,Null as SaleValue,Null as  PromotedQty,Null as PromotedValue,
							Null as RebateQty,Null as RebateValue,Null as PriceExclTax,Null as TaxAmount,Null as TaxPercentage,
							Null as PriceInclTax,Null as BudgetedQty,Null as BudgetedValue,Null as 'OutletName',Null as 'Doc No',Max(Isnull(TOQ,0))
						From tbl_mERP_QPSDtlData QPSDt(NoLock),Customer Cust(NoLock)
						Where QPSDt.SchemeID = @SchemeID And QPSDt.PayoutID = @PayoutID 
								And (isNull(Rebate_Qty,0) = 0 Or isNull(Rebate_Val,0) = 0 Or IsNull(RFARebate_Val,0) = 0)
								And Cust.CustomerID = QPSDt.CustomerID 
						Group By InvoiceId, QPSDt.Product_Code, BillRef, QPSDt.CustomerID,Cust.RCSOutletID,  QPSDt.Division, QPSDt.SubCategory, QPSDt.MarketSKU, QPSDt.UOM,Cust.Company_Name
						Order By QPSDt.Product_Code
						
					End
					Else
					Begin
						Insert Into #tmpRFAAbs
						Select @WDCode as WDCode, @WDDest as WDDest, @SchemeType as SchemeType, @ActivityCode as ActivityCode, 
						@ActivityType as ActivityDesc, @ActiveFrom as ActiveFrom, @ActiveTo As ActiveTo, 
						@PayoutFrom as PayoutFrom, @PayoutTo As PayoutTo,Null as SR,Null as Division,Null as SubCategory,Null as MarketSKU,Null as SKUCode,
						Null as UOM,Null as SaleQty,Null as SaleValue,Null as  PromotedQty,Null as PromotedValue,
						Null as FreeBaseUOM,Null as RebateQty,Null as RebateValue,Null as BudgetedQty,Null as BudgetedValue,@ApplicableOn as AppOn 

						Insert Into #tmpRFADet
						Select @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, @CSSchemeID as CompSchemeID, @ActivityType as ActivityDesc, 
						@PayoutFrom as ActiveFrom, @PayoutTo As ActiveTo,Null as SR,Null as BillRef,Null as OutletCode,Null as RCSID,Null as  ActiveInRCS,
						Null as LineType,Null as Division,Null as SubCategory,Null as MarketSKU,Null as SKUCode,
						Null as UOM,Null as SaleQty,Null as SaleValue,Null as  PromotedQty,Null as PromotedValue,
						Null as RebateQty,Null as RebateValue,Null as PriceExclTax,Null as TaxAmount,Null as TaxPercentage,
						Null as PriceInclTax,Null as BudgetedQty,Null as BudgetedValue,Null as 'OutletName',Null as 'Doc No',NULL as TOQ
					End
				End/* Offtake Percentage or Amount Scheme Starts*/
			Else If @ItemFree = 1 
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
					Select Distinct SKUCode From  #RFAInfo
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
						From #RFAInfo
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
						Max(TaxPercentage) , Sum(TaxAmount) , Sum(PriceInclTax) ,0 ,  Sum(BudgetedValue) , InvoiceType,[Doc No],Max(TOQ)
						From #RFAInfo
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
					And CustomerID In(Select OutletCode From #RFAInfo)
					And (isNull(Rebate_Qty,0) > 0 Or isNull(Rebate_Val,0) > 0 Or IsNull(RFARebate_Val,0) > 0)

					
					Declare @TotRebateQty Decimal(18,6)

					Declare RebateVal Cursor For 
					Select Distinct OutletCode,Sum(RebateValue),Sum(RebateQty) From  #RFAInfo
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
							And CustomerID In(Select OutletCode From #RFAInfo)
							Group By Product_Code, Division, SubCategory, MarketSKU, UOM
							Order By Product_Code



						Insert Into #RFADetail 
							Select  @SRNo, 0, InvoiceID, SchemeId, BillRef , QPS.CustomerID ,
									IsNull(Cust.RCSOutletID, '') as RCSID,
									(Case when IsNull(Cust.RCSOutletID,'') <>  '' then 'Yes' else 'No' end) as ActiveInRCS ,
									--isNull((Select IsNull(TMDValue,N'') From  Cust_TMD_Master CTM, Cust_TMD_Details CTD Where 
									--CTD.CustomerID = QPS.CustomerID And CTM.TMDID = CTD.TMDID),'') as ActiveInRCS, 
									'QPS' , Division ,
									SubCategory , MarketSKU , Product_Code ,
									UOM , Sum(Quantity) ,Sum(Quantity*SalePrice) ,
									Sum(Promoted_Qty) , Sum(Promoted_Val) ,Sum(Rebate_Qty) ,
									(case @TaxConfigFlag When 1 Then Sum(IsNull(Rebate_Val,0)) Else Sum(IsNull(RFARebate_Val,0)) End) as RebateValue, 
									Sum(SalePrice) as 'PriceExclTax',
									Max(isNull(TaxPercent,0)) as TaxPercentage, Sum(isNull(TaxAmount,0)) as TaxAmount,
									(Case Max(TOQ) When 0 Then
									(Max(SalePrice) + (Max(isNull(SalePrice,0))*Max(isNull(TaxPercent,0))/100))
									Else (Max(isNull(SalePrice,0)) + Max(isNull(TaxPercent,0))) End) as  'PriceInclTax' ,0 , 0, 1,InvDocRef,Max(QPS.TOQ)
									From #tmptbl_mERP_QPSDtlData QPS,Customer Cust(NoLock)
									Where 
									QPS.SchemeID = @SchemeID
									And PayoutID = @PayoutID
									And (isNull(Rebate_Qty,0) > 0 Or isNull(Rebate_Val,0) > 0 Or IsNull(RFARebate_Val,0) > 0)
									And Product_Code = @SKUCode
									And isNull(QPS.Quantity,0) <> 0
									And QPS.CustomerID In(Select OutletCode From #RFAInfo)
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
					Max(TaxPercentage) , Sum(TaxAmount) , Sum(PriceInclTax) ,0 ,  Sum(BudgetedValue) , InvoiceType,[Doc No],Max(TOQ)
					From #RFAInfo
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
						Cust.Company_Name as 'OutletName' ,[Doc No],Isnull(TOQ,0)
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
					Null as PriceInclTax,Null as BudgetedQty,Null as BudgetedValue,Null as 'OutletName',Null as 'Doc No',Null as TOQ
				End
			End /*Offtake - Free Item Based Scheme  End*/
			End /*Offtake - Item Based Scheme  End*/
			Else If  @ApplicableOn = 'Invoice'  /*Offtake - Invoice Based Scheme  starts*/
			Begin
				If @ItemFree = 0
				Begin
					Insert Into #RFAInfo(InvoiceID,SchemeID, BillRef,OutletCode,RCSID,ActiveInRCS,LineType,RebateValue,[Doc No])
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
				If (Select Count(*) From #RFAInfo Where SchemeID = @SchemeID) >= 1 
				Begin
					Insert Into #tmpRFAAbs
					Select  @WDCode as WDCode, @WDDest as WDDest, @SchemeType as SchemeType, @ActivityCode as ActivityCode, 
							@ActivityType as ActivityDesc, @ActiveFrom as ActiveFrom, @ActiveTo As ActiveTo, 
							@PayoutFrom as PayoutFrom, @PayoutTo As PayoutTo, 0 as SR,
							Division, SubCategory, MarketSKU, SKUCode, UOM, Sum(SaleQty) as SaleQty,
							Sum(SaleValue) as SaleValue, Sum(PromotedQty) As PromotedQty, Sum(PromotedValue) As PromotedValue, 
							Max(FreeBaseUOM), Sum(RebateQty) as RebateQty, Sum(IsNull(RebateValue, 0)) as RebateValue, 
							0 as BudgetedQty, 0 as BudgetedValue, @ApplicableOn as AppOn
							From #RFAInfo
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
							0 as BudgetedQty, 0 as BudgetedValue,Cust.Company_Name as 'OutletName',[Doc No],Isnull(TOQ,0) as TOQ
							From #RFAInfo,Customer Cust (NoLock)  
							Where SchemeID = @SchemeID
							And Cust.CustomerID = #RFAInfo.OutletCode 
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
						   Null as PriceInclTax,Null as BudgetedQty,Null as BudgetedValue,Null as 'OutletName',Null as 'Doc No',Null as TOQ
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
		

		Truncate table #RFAInfo
		Truncate table #RFAAbstract
		Truncate table #RFADetail
		
		If @QPS = 0  /* Non QPS Scheme starts here */
		Begin
			/*Populate RFA data from tbl_merp_NonQPSData*/
			Insert Into #RFAInfo (Serial, InvoiceID, BillRef, SKUCode, UOM, FreeBaseUOM, PromotedQty, PromotedValue,
						RebateQty, RebateValue, PriceExclTax, TaxPercentage, TaxAmount, PriceInclTax, SchemeID, SlabID, 
						InvoiceType, LineType, Flagword, OutletCode, [Doc No], SaleQty, SaleValue, FreeSKUSerial,TOQ
						)
					Select  NQD.PrimarySerial, NQD.InvoiceID, NQD.BillRef,NQD.Product_Code, (Select Description From UOM (NoLock) Where UOM = PromotedUOM) , 
					(Select Description From UOM Where UOM = RebateUOM), PromotedQty, PromotedValue,
				    RebateQty,  
					Case @TaxConfigFlag When 1 Then RebateValue_Tax Else RebateValue End,
					PriceExclTax, TaxPercent, TaxAmount, PriceInclTax, NQD.SchemeID, NQD.SlabID, InvoiceType,
					Case [Type]
						When 0 Then 'MAIN'
						When 1 Then 'Free'
						When 2 Then 'Sales Return - Saleable'
						When 3 Then 'Sales Return - Damaged' 
						End,
					Case [Type]
						When 1 Then 1
						Else 0 End,
					CustomerID, DocID, SaleQty, SaleValue, NQD.FreeSerial,Isnull(NQD.TOQ,0)
				From tbl_merp_NonQPSData NQD (NoLock), tbl_merp_SchemePayoutPeriod SPP (NoLock)
				Where NQD.SchemeID = @SchemeID
				And NQD.SchemeID = SPP.SchemeID
				And SPP.ID = @PayoutID
				And dbo.StripTimeFromDate(NQD.OriginalInvDate)  Between	
					dbo.StripTimeFromDate(SPP.PayoutPeriodFrom) And dbo.StripTimeFromDate(SPP.PayoutPeriodTo)
				Order By NQD.InvoiceID, NQD.SchemeID, NQD.Product_Code

--			Update #RFAInfo Set RCSID = isNull(RCSOutletID,''), ActiveInRCS = IsNull(TMDValue,N'') 
--				From Cust_TMD_Master CTM, Cust_TMD_Details CTD,Customer C
--				Where CTM.TMDID = CTD.TMDID
--				And CTD.CustomerID = C.CustomerID

			Update #RFAInfo Set RCSID = IsNull(C.RCSOutletID,'')
			, ActiveInRCS = (Case when IsNull(C.RCSOutletID,'') <> '' then 'Yes' else 'No' end)
			From  Customer C(NoLock)
			Where  C.CustomerID = #RFAInfo.OutletCode 
		
			Update RFA Set Division = IC2.Category_Name, SubCategory = IC1.Category_Name, MarketSKU = IC.Category_Name, UOM = U.Description
			From  #RFAInfo RFA,Items I(NoLock) , ItemCategories IC(NoLock), ItemCategories IC1(NoLock),ItemCategories IC2(NoLock),UOM U(NoLock)
				Where RFA.SKUCode = I.Product_Code And
				I.CategoryID = IC.CategoryID And
				IC.ParentID = IC1.CategoryID And
				IC1.ParentID = IC2.CategoryID And
				I.UOM = U.UOM

			

			If @ItemGroup = 1 And @ItemFree = 1
			Begin
				
				/*Serial No. for Detail data*/
				If @QPSSrNo > 0 
					Set @SRNo = @QPSSrNo+1	
				Else
					Set @SRNo = 1
				
				Declare FreeItem Cursor For 
					Select Distinct SKUCode, InvoiceID, FreeSKUSerial, Serial 
						From #RFAInfo
						Where IsNull(FlagWord, 0) = 0
						And SchemeID = @SchemeID
						And FreeSKUSerial > 0
						And InvoiceType <> 4

					Union 

					Select Distinct SKUCode, InvoiceID, FreeSKUSerial, Serial 
						From #RFAInfo
						Where IsNull(FlagWord, 0) = 0
						And SchemeID = @SchemeID
						And InvoiceType = 4


				Open FreeItem
				Fetch Next From FreeItem Into @SKUCode,@InvoiceId, @FreeSKUSerial, @Serial
				While (@@Fetch_Status = 0)
				Begin
					If @PrevSKUCode <> @SKUCode
						Set @SRNo = @SRNo + 1

					Insert Into #RFADetail
						Select  @SRNo, 0, InvoiceID, SchemeId, BillRef , OutletCode ,
								RCSID , ActiveInRCS, LineType , Division ,
								SubCategory , MarketSKU , SKUCode ,
								UOM , Sum(SaleQty) ,Sum(SaleValue) ,
								Sum(PromotedQty) , Sum(PromotedValue) ,Sum(RebateQty) , Sum(RebateValue) , Sum(PriceExclTax),
								Max(TaxPercentage) , Sum(TaxAmount) , Sum(PriceInclTax) ,0 , Sum(BudgetedValue), InvoiceType,[Doc No],Max(Isnull(TOQ,0))
								From #RFAInfo
								Where InvoiceID = @InvoiceId
								And SchemeID = @SchemeID
								And SKUCode = @SKUCode 
								And IsNull(FlagWord, 0) = 0
								Group By InvoiceID, SchemeId, BillRef , OutletCode ,
								RCSID , ActiveInRCS, LineType , Division ,
								SubCategory , MarketSKU , SKUCode ,
								UOM, InvoiceType,[Doc No]
						Union ALL

						Select @SRNo, 1, InvoiceID, SchemeId, BillRef , OutletCode ,
								RCSID , ActiveInRCS, LineType , Division ,
								SubCategory , MarketSKU , SKUCode ,
								UOM , SaleQty , SaleValue ,
								PromotedQty , PromotedValue ,RebateQty , RebateValue , PriceExclTax ,
								TaxPercentage , TaxAmount , PriceInclTax ,0 ,  BudgetedValue , InvoiceType,[Doc No],TOQ
								From #RFAInfo
								Where InvoiceID = @InvoiceId
								And IsNull(FlagWord, 0) = 1
								And Serial = @FreeSKUSerial

					Set @PrevSKUCode = @SKUCode
					Fetch Next From FreeItem Into @SKUCode, @InvoiceId, @FreeSKUSerial, @Serial
				End
				Close FreeItem
				Deallocate FreeItem

				/*Serial No. for Abstract data*/
				If @QPSSrNo > 0 
					Set @SRNo = @QPSSrNo
				Else
					Set @SRNo = 0
				Declare PrimaryItem Cursor For 
				Select Distinct SKUCode
				From #RFAInfo
				Where IsNull(FlagWord, 0) = 0
				And SchemeID = @SchemeID
				Open PrimaryItem 
				Fetch Next From PrimaryItem Into @SKUCode
				While (@@Fetch_Status = 0)
				Begin
					Set @SRNo = @SRNo + 1
					Insert Into #RFAAbstract Select @SRNo,	Division, SubCategory, MarketSKU, SKUCode, UOM, Sum(IsNull(SaleQty,0)) as SaleQty,
						Sum(IsNull(SaleValue,0)) as SaleValue, Sum(IsNull(PromotedQty,0)) as PromotedQty, Sum(IsNull(PromotedValue,0)) as PromotedValue, 
						Max(IsNull(FreeBaseUOM,'')) as FreeBaseUOM, Sum(IsNull(RebateQty,0)) as RebateQty, Sum(IsNull(RebateValue,0)) as RebateValue, 
						0 as BudgetedQty, 0 as BudgetedValue
						From #RFAInfo
						Where IsNull(FlagWord, 0) = 0
						And SchemeID = @SchemeID
						And SKUCode = @SKUCode
						Group By SKUCode, Division, SubCategory, MarketSKU, UOM
						Order By SKUCode
					Fetch Next From PrimaryItem Into @SKUCode
				End
				Close PrimaryItem
				Deallocate PrimaryItem
			End	/*@ItemGroup = 1 And @ItemFree = 1*/

			/*Populate Abstract data*/
			If  @ApplicableOn = 'Invoice'
			Begin
				Insert Into #tmpRFAAbs
					Select  @WDCode , @WDDest, @SchemeType, @ActivityCode, @ActivityType, @ActiveFrom, @ActiveTo,
						@PayoutFrom, @PayoutTo, Serial, Division, SubCategory, MarketSKU,
						SKUCode, UOM, Sum(SaleQty), Sum(SaleValue), Sum(PromotedQty), Sum(PromotedValue),
						Max(FreeBaseUOM),  Sum(RebateQty), Sum(RebateValue),
						Null As BudgetedQty, Null As BudgetedValue, @ApplicableOn 
					From #RFAInfo
					Group By Division, SubCategory, MarketSKU,SKUCode, UOM, Serial
					Order By IsNull(SKUCode, '')
			End
			Else
			Begin
				If (Select Count(*) From #RFAAbstract) >=  1 --Item based free qty scheme
					Insert Into #tmpRFAAbs
						Select @WDCode as WDCode, @WDDest as WDDest, @SchemeType as SchemeType, @ActivityCode as ActivityCode, 
						@ActivityType as ActivityDesc, @ActiveFrom as ActiveFrom, @ActiveTo As ActiveTo, 
						@PayoutFrom as PayoutFrom, @PayoutTo As PayoutTo, *, @ApplicableOn as AppOn
						From #RFAAbstract	
				Else
					Insert Into #tmpRFAAbs
						Select  @WDCode , @WDDest, @SchemeType, @ActivityCode, @ActivityType, @ActiveFrom, @ActiveTo,
							@PayoutFrom, @PayoutTo, Serial, Division, SubCategory, MarketSKU,
							SKUCode, UOM, Sum(SaleQty), Sum(SaleValue), Sum(PromotedQty), Sum(PromotedValue),
							Max(FreeBaseUOM),  Sum(RebateQty), Sum(RebateValue),
							Null As BudgetedQty, Null As BudgetedValue, @ApplicableOn 
						From #RFAInfo
						Where Flagword = 0
						Group By Division, SubCategory, MarketSKU,SKUCode, UOM, Serial
						Order By SKUCode
			End



			/*Populate Detail data*/
			If  @ApplicableOn = 'SPL_CAT' 
			Begin
				If @ItemFree = 1
				Begin
					Insert Into #tmpRFADet
						Select @WDCode , @WDDest, @ActivityCode, @CSSchemeID, @ActivityType,  @PayoutFrom, @PayoutTo,
							Serial, BillRef, OutletCode, RCSID, ActiveInRCS, 
							LineType, Division, SubCategory, MarketSKU, SKUCode,
							UOM, SaleQty, SaleValue, PromotedQty, PromotedValue,
							RebateQty, RebateValue,
							PriceExclTax, TaxPercentage, TaxAmount, PriceInclTax, 
							Null As BudgetedQty, Null As BudgetedValue,(Select Company_Name From Customer (NoLock) Where CustomerID = OutletCode),
							[Doc No],TOQ
						From #RFAInfo 
						Where LineType <>  'MAIN' 
						And LineType <> 'Free'
						Order By SKUCode
					Insert Into #tmpRFADet
						Select @WDCode , @WDDest, @ActivityCode, @CSSchemeID, @ActivityType,  @PayoutFrom, @PayoutTo,
							Serial, BillRef, OutletCode, RCSID,ActiveInRCS, 
							LineType, Division, SubCategory, MarketSKU, SKUCode,
							UOM, SaleQty, SaleValue, PromotedQty, PromotedValue,
							RebateQty, RebateValue,
							PriceExclTax, TaxPercentage, TaxAmount, PriceInclTax, 
							Null As BudgetedQty, Null As BudgetedValue,(Select Company_Name From Customer (NoLock) Where CustomerID = OutletCode),
							[Doc No],TOQ
						From #RFAInfo 
						Where LineType = 'MAIN' 
						Order By SKUCode
					Insert Into #tmpRFADet
						Select @WDCode , @WDDest, @ActivityCode, @CSSchemeID, @ActivityType,  @PayoutFrom, @PayoutTo,
							Serial, BillRef, OutletCode, RCSID, ActiveInRCS, 
							LineType, Division, SubCategory, MarketSKU, SKUCode,
							UOM, SaleQty, SaleValue, PromotedQty, PromotedValue,
							RebateQty, RebateValue,
							PriceExclTax, TaxPercentage, TaxAmount, PriceInclTax, 
							Null As BudgetedQty, Null As BudgetedValue,(Select Company_Name From Customer (NoLock) Where CustomerID = OutletCode),
							[Doc No],TOQ
						From #RFAInfo 
						Where LineType = 'Free'
						Order By SKUCode 
				End
				Else 
					Insert Into #tmpRFADet
						Select @WDCode , @WDDest, @ActivityCode, @CSSchemeID, @ActivityType,  @PayoutFrom, @PayoutTo,
							Serial, BillRef, OutletCode, RCSID, ActiveInRCS, 
							LineType, Division, SubCategory, MarketSKU, SKUCode,
							UOM, SaleQty, SaleValue, PromotedQty, PromotedValue,
							RebateQty, RebateValue,
							PriceExclTax, TaxPercentage, TaxAmount, PriceInclTax, 
							Null As BudgetedQty, Null As BudgetedValue,(Select Company_Name From Customer (NoLock) Where CustomerID = OutletCode),
							[Doc No],TOQ
						From #RFAInfo Order By SKUCode
			End		
			Else 
			Begin
				If ((Select Count(*) From #RFADetail) > 0) --Item based free qty scheme
					Insert Into #tmpRFADet
						Select @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, @CSSchemeID as CompSchemeID, @ActivityType as ActivityDesc, 
							@PayoutFrom as ActiveFrom, @PayoutTo As ActiveTo, SR, BillRef, OutletCode,
							RCSID, ActiveInRCS, LineType , Division ,
							SubCategory , MarketSKU , SKUCode ,
							UOM , SaleQty , SaleValue ,
							PromotedQty, 
							PromotedValue ,RebateQty , RebateValue , PriceExclTax ,
							TaxPercentage , TaxAmount , PriceInclTax ,BudgetedQty ,  BudgetedValue,Cust.Company_Name as 'OutletName' ,[Doc No],TOQ
							From #RFADetail,Customer Cust (NoLock) 
							Where Cust.CustomerID = #RFADetail.OutletCode 
									
				Else
					Insert Into #tmpRFADet
						Select @WDCode , @WDDest, @ActivityCode, @CSSchemeID, @ActivityType,  @PayoutFrom, @PayoutTo,
							Serial, BillRef, OutletCode, RCSID, ActiveInRCS, 
							LineType, Division, SubCategory, MarketSKU, SKUCode,
							UOM, SaleQty, SaleValue, PromotedQty, PromotedValue,
							RebateQty, RebateValue,
							PriceExclTax, TaxPercentage, TaxAmount, PriceInclTax, 
							Null As BudgetedQty, Null As BudgetedValue,(Select Company_Name From Customer (NoLock) Where CustomerID = OutletCode),
							[Doc No],TOQ
						From #RFAInfo Order By SR
			End

			/*The following values restricted for Primary items in detail data*/
			If @ItemFree = 1
				Update #tmpRFADet Set RebateQty = 0, RebateValue = 0, PriceExclTax =0,TaxAmount =0, PriceInclTax = 0  
					Where LineType = 'MAIN'

			/* Tax amount for primary item need not be shown for any type of scheme in the detail frame*/
			Update #tmpRFADet Set TaxAmount = 0 Where LineType = 'MAIN'


			--SR value will be set to Itembased Free items scheme only. 
			--This is to identify the Detail of an abstract data
			--#RFAAbstract and #RFADetail tables will hav value for Itembased Free items scheme only
			If ((Select Count(*) From #RFAAbstract) = 0) 
				Update #tmpRFAAbs Set SR = 0

			If ((Select Count(*) From #RFADetail) = 0) 
				Update #tmpRFADet Set SR = 0

		End /* Non QPS Scheme ends here */

	
----		If @QPS = 0  /* Non QPS Scheme starts here */
----		Begin
----
----			
----			If @ApplicableOn = 'ITEM' Or @ApplicableOn = 'SPL_CAT'
----			Begin/*Trade - Item based schemes - Start*/ 
----				/*Select scheme products*/
----
----				Insert Into #RFAInfo(InvoiceId, BillRef, OutletCode, RCSID, LineType, Division, SubCategory, MarketSKU,
----									 SKUCode, UOM, SaleQty, SaleValue, PromotedQty, PromotedValue, FreeBaseUOM, RebateQty,
----									 RebateValue, PriceExclTax, TaxPercentage, TaxAmount, PriceInclTax, SchemeDetail,
----									 Serial, Flagword, Amount, SchemeID, SlabID, PTR, TaxCode, BudgetedValue, FreeSKUSerial,
----									 SalePrice, InvoiceType, ReferenceNumber,[Doc No]) 
----				Select IA.InvoiceID, 
----				@InvPrefix + Cast(IA.DocumentID as nVarchar) as BillRef, 
----				C.CustomerID as OutletCode,
----				IsNull(C.RCSOutletID, '') as RCSID,
----				(Case When InvoiceType <> 4 Then
----							Case IsNull(ID.Flagword, 0) 
----								When 1 then 'Free'
----								Else 'MAIN' 
----								End 
----				Else
----					Case When IA.Status & 32 <> 0 Then 'Sales Return - Damaged'
----					Else 'Sales Return - Saleable'
----					End
----				End)
----				as LineType,
----				'' as Division,
----				'' as SubCategory,
----				'' as MarketSKU,
----				ID.Product_Code as SKUCode,
----				'' as UOM,
----				Case ID.FlagWord
----					When 0 Then ID.Quantity 
----					Else 0 End	as SaleQty,
----				Case ID.FlagWord
----					When 0 Then ID.SalePrice * ID.Quantity 
----					Else 0 End	as SaleValue,
----				Null as PromotedQty,
----				Null as PromotedValue,
----				Null as FreeBaseUOM,
----				Case ID.FlagWord
----					When 1 Then ID.Quantity
----					Else 0 End as RebateQty,
----				Null as RebateValue,
----				Null as PriceExclTax,
----				ID.TaxCode as TaxPercentage,
----				Null as TaxAmount,
----				Null as PriceInclTax,
----				Case InvoiceType When 4 Then
----					dbo.fn_Get_SchemeItemPerc_SR(ID.InvoiceID,@SchemeID,ID.Product_Code)
----				Else
----					Case @ItemGroup 
----						When 1 Then IsNull(ID.MultipleSchemeDetails, '') 
----						When 2 Then IsNull(ID.MultipleSplCategorySchDetail, '') 
----					End 
----				End as SchemeDetail,
----				ID.Serial,
----				ID.FlagWord,
----				Case ID.FlagWord
----					When 1 Then	ID.Quantity * (dbo.mERP_fn_GetMarginPTR(ID.Product_Code,ID.InvoiceID, @SchemeID) + (Case @TaxConfigFlag When 1 Then (dbo.mERP_fn_GetMarginPTR(ID.Product_Code,ID.InvoiceID, @SchemeID) * (ID.TaxCode/100)) Else 0 End))
----					Else 0 End as Amount,
----				0 as SchemeID,
----				0 as SlabID,
----				Case ID.FlagWord
----					When 1 Then dbo.mERP_fn_GetMarginPTR(ID.Product_Code,ID.InvoiceID, @SchemeID)
----					Else ID.PTR End as PTR,
----				ID.TaxCode as TaxCode,
----				0 as BudgetedValue,
----				0 as FreeSKUSerial,
----				ID.SalePrice as SalePrice,
----				IA.InvoiceType,
----				IA.ReferenceNumber,
----				IA.DocReference
----				From InvoiceAbstract IA, InvoiceDetail ID, Customer C
----				Where IA.InvoiceId = ID.InvoiceId
----				And IA.InvoiceType In (1,3,4)        
----				And (IA.Status & 128) = 0  
----				And IA.CustomerID = C.CustomerID
----				And (Case IA.InvoiceType
----							When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID = 
----							IA.DocumentID
----							And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)
----							--(Select dbo.mERP_fn_GetInvoiceDate(IA.InvoiceID, 1))
----							Else dbo.StripTimeFromDate(IA.InvoiceDate)
----							End) Between @ActiveFrom And @ActiveTo
----				And (Case IA.InvoiceType
----						When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID = IA.DocumentID
----							And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID) --(Select dbo.mERP_fn_GetInvoiceDate(IA.InvoiceID, 1))
----						Else dbo.StripTimeFromDate(IA.InvoiceDate)
----						End) Between @PayoutFrom And @PayoutTo
----	--			And (Case IA.InvoiceType
----	--					When 1 Then dbo.StripTimeFromDate(IA.CreationTime) 
----	--					When 3 Then dbo.StripTimeFromDate(IA.CreationTime) 
----	--					When 4 Then @ActiveTo
----	--					End) <= @ExpiryDate
----
----				
----				Update R1 Set TaxCode = (Select Max(TaxCode) From #RFAInfo Where InvoiceID = R1.InvoiceID And Serial = R1.Serial)
----				From #RFAInfo R1
----
----					
----
----				Declare SchemeOutletCur Cursor For
----				Select Distinct OutletCode From #RFAInfo
----				Open SchemeOutletCur
----				Fetch Next From SchemeOutletCur Into @CustomerID
----				While (@@Fetch_Status = 0)			
----				Begin
----					Select @SchemeOutlet = 0, @SchemeGroup = GroupID From dbo.mERP_fn_CheckTradeSchemeOutlet(@SchemeID, @CustomerID)
----					Update #RFAInfo Set SchemeOutlet = @SchemeOutlet, SchemeGroup = @SchemeGroup 
----						Where OutletCode = @CustomerID
----					Update #RFAInfo Set ActiveInRCS = IsNull(TMDValue,N'') 
----						From Cust_TMD_Master CTM, Cust_TMD_Details CTD	
----						Where CTM.TMDID = CTD.TMDID
----						And CTD.CustomerID = @CustomerID
----						And OutletCode = @CustomerID
----					Fetch Next From SchemeOutletCur Into @CustomerID
----				End
----				Close SchemeOutletCur
----				Deallocate SchemeOutletCur
----
----				/*Delete non scheme Outlet*/
----				Delete From #RFAInfo Where IsNull(SchemeOutlet, 0) = 2
----		
----				
----				
----
----				/*Update SKU Category Levels and UOM - Start*/
----	--			Declare UpdateLevelCur Cursor For 
----	--				Select Distinct Top 40 SKUCode From #RFAInfo Order By skucode Asc
----	--			Open UpdateLevelCur
----	--			Fetch Next From UpdateLevelCur Into @SKUCode
----	--			While (@@Fetch_Status = 0)
----	--			Begin
----	--				Select @MarketSKU = Category_Name, @MarketSKUID = CategoryID, @SubCatID = ParentID  
----	--					From ItemCategories Where CategoryID = (Select CategoryID From Items Where Product_Code = @SKUCode ) 		
----	--				Select @SubCategory = Category_Name, @DivID = ParentID From ItemCategories Where CategoryID = @SubCatID
----	--				Select @Divison = Category_Name From ItemCategories Where CategoryID = @DivID
----	--				Select @UOM = Description From UOM Where UOM = (Select UOM From Items Where Product_Code = @SKUCode)
----	--
----	--				Update #RFAInfo Set Division = @Divison, SubCategory = @SubCategory, MarketSKU = @MarketSKU, UOM = @UOM--,
----	--				SchemeSKU = (Select dbo.mERP_fn_CheckSchemeSKU(@SchemeID, @SKUCode, @Divison, @SubCategory, @MarketSKU)) 
----	--				Where SKUCode = @SKUCode 
----	--				Fetch Next From UpdateLevelCur Into @SKUCode
----	--			End
----	--			Close UpdateLevelCur
----	--			Deallocate UpdateLevelCur
----				
----				/*Update SKU Category Levels and UOM - End*/
----
----
----				/* Update  SchemeSKU  = 1 For Items which comes in any of the Product Scope of the scheme */
------				Update #RFAInfo Set SchemeSKU = 1 
------				Where SKUCode In(Select Product_Code From dbo.mERP_fn_Get_CSSku(@SchemeID))
----
----				
------				Update #RFAInfo Set SchemeSKU = 1 
------				Where SKUCode In(Select SKUCode From dbo.mERP_Fn_List_CSFreeSKU(@SchemeID))
----
------				Delete From #RFAInfo Where IsNull(SchemeSKU, 0) = 0 
----
----				/* Update Division , Market sku ,And Sub Category */
----				Update RFA Set Division = IC2.Category_Name, SubCategory = IC1.Category_Name, MarketSKU = IC.Category_Name, UOM = U.Description
----				From #RFAInfo RFA,Items I , ItemCategories IC, ItemCategories IC1,ItemCategories IC2,UOM U
----				Where RFA.SKUCode = I.Product_Code And
----				I.CategoryID = IC.CategoryID And
----				IC.ParentID = IC1.CategoryID And
----				IC1.ParentID = IC2.CategoryID And
----				I.UOM = U.UOM
----
----				/*Delete non scheme SKU*/
------				Delete From #RFAInfo Where IsNull(SchemeSKU, 0) = 0 
----
----
----				/*Update Rebate Value - Start*/
----				Declare UpdateRebateCur Cursor For
----					Select Distinct InvoiceID, IsNull(SchemeDetail, ''), Serial, FlagWord, Sum(Amount) 
----						From #RFAInfo	
----						Where SchemeOutlet = 0
----						Group By InvoiceID, IsNull(SchemeDetail, ''), Serial, FlagWord
----				Open UpdateRebateCur	
----				Fetch Next From UpdateRebateCur Into @InvoiceID, @SchemeDetail, @Serial, @FlagWord, @Amount
----				While (@@Fetch_Status = 0)
----				Begin
----					Set @SchemeAmt = 0
----					Set @SlabID = 0
----					If @FlagWord = 1	
----					Begin
----						/*Update Scheme cost of Free Qty of given scheme*/
----						If ((Select Count(*) From dbo.mERP_fn_GetInvSchemeDetail(@InvoiceID, @SchemeDetail, @FlagWord, 0, 0) Where SchemeID = @SchemeID) > 0)			
----						Begin
----							If (Select Count(*) From #RFAInfo Where InvoiceID = @InvoiceID And Serial = @Serial) > 1 
----								Select Top 1 @SR =  SR From #RFAInfo Where InvoiceID = @InvoiceID And Serial = @Serial
----							Else
----								Set @SR = 0
----							If @SR = 0
----								/*Update Tax info only for Free qty schemes*/
----								Update #RFAInfo Set RebateValue = @Amount, PriceExclTax = PTR, TaxPercentage = TaxCode, TaxAmount = RebateQty * (PTR * (TaxCode / 100)), PriceInclTax =  PTR + (PTR * (TaxCode / 100))
----									Where InvoiceID = @InvoiceID  And Serial = @Serial 
----							Else 
----								Update #RFAInfo Set RebateValue = @Amount, PriceExclTax = PTR, TaxPercentage = TaxCode, TaxAmount = RebateQty * (PTR * (TaxCode / 100)), PriceInclTax =  PTR + (PTR * (TaxCode / 100))
----									Where InvoiceID = @InvoiceID  And Serial = @Serial And SR = @SR
----
----							Update #RFAInfo Set SchemeID = @SchemeID Where InvoiceID = @InvoiceID  And Serial = @Serial 
----						End
----						Else 
----							Update #RFAInfo Set RebateValue = 0, RebateQty = 0
----								Where InvoiceID = @InvoiceID  And Serial = @Serial 
----					End
----					Else
----					Begin
----
----						/*Check for FreeQty slab*/
----						/*This is just to chk whehter given FreeQty scheme applied for this primary item*/
----						Set @SlabID = (Select dbo.mERP_fn_CheckPrimarySKU(@InvoiceID, @SchemeID, @Serial))
----						If (@SlabID > 0)
----						Begin
----							Update #RFAInfo Set SchemeID = @SchemeID, SlabID = @SlabID, PriceExclTax = PTR, TaxPercentage = TaxCode, TaxAmount = (PTR * (TaxCode / 100)), PriceInclTax =  PTR + (PTR * (TaxCode / 100))
----	    						Where InvoiceID = @InvoiceID And Serial = @Serial
----
----						End
----						If IsNull(@SchemeDetail, '') <> ''
----						Begin
----
----							/*Scheme cost for Amt Or Per scheme*/
----							Select @SchemeAmt = SchAmt ,@SlabID = SlabID From dbo.mERP_fn_GetInvSchemeDetail(@InvoiceID, @SchemeDetail, @FlagWord, 0, 0)
----								Where SchemeID = @SchemeID
----							If @SchemeAmt > 0	
----							Begin
----								If (Select Count(*) From #RFAInfo Where InvoiceID = @InvoiceID And Serial = @Serial) > 1 
----									Select Top 1 @SR =  SR From #RFAInfo Where InvoiceID = @InvoiceID And Serial = @Serial
----								Else
----									Set @SR = 0
----								If @SR = 0
----									Update #RFAInfo Set RebateValue = @SchemeAmt, SlabID = @SlabID Where InvoiceID = @InvoiceID And Serial = @Serial
----								Else
----									Update #RFAInfo Set RebateValue = @SchemeAmt, SlabID = @SlabID 
----									Where InvoiceID = @InvoiceID And Serial = @Serial And SR = @SR
----
----								Update #RFAInfo Set SchemeID = @SchemeID Where InvoiceID = @InvoiceID  And Serial = @Serial 
----							End
----						End
----					End
----					Fetch Next From UpdateRebateCur Into @InvoiceID, @SchemeDetail, @Serial, @FlagWord, @Amount
----				End
----				Close UpdateRebateCur
----				Deallocate UpdateRebateCur
----				/*Update Rebate Value - End*/
----
----				If @ItemGroup = 2 --And @FreeFlag = 1
----				Begin
----					Declare UpdateFreeInfoCur Cursor For
----						Select InvoiceID, Sum(SaleQty)  From #RFAInfo
----							Where SchemeID = @SchemeID
----							And IsNull(FlagWord, 0) = 0
----							And SchemeOutlet = 0
----							Group By InvoiceId
----					Open UpdateFreeInfoCur
----					Fetch Next From UpdateFreeInfoCur Into @InvoiceID, @SaleQty
----					While (@@Fetch_Status = 0)
----					Begin
----						Select @FreeQty = Sum(RebateQty), @FreeValue = Sum(RebateValue) From #RFAInfo Where InvoiceID  = @InvoiceID And IsNull(Flagword, 0) = 1
----						If @FreeQty > 0
----						Begin
----							Set @FreeFlag = 1
----							Update #RFAInfo Set RebateQty =  (@FreeQty/@SaleQty) * SaleQty, RebateValue = (@FreeValue/@SaleQty) * SaleQty Where InvoiceID = @InvoiceID And IsNull(Flagword, 0) = 0
----						End
----						Fetch Next From UpdateFreeInfoCur Into @InvoiceID, @SaleQty
----					End
----					Close UpdateFreeInfoCur
----					Deallocate UpdateFreeInfoCur
----					Update #RFAInfo Set RebateQty = (-1) * RebateQty, RebateValue = (-1) * RebateValue Where InvoiceType = 4
----				End
----				Else
----				Begin
----					/*Update FreeQty Info of a Primary SKU - Start*/	
----					/*Done separately to get cumulative value of PrimarySKU*/
----					Declare UpdateFreeInfoCur Cursor For
----						Select InvoiceID, SKUCode, Min(Serial), Sum(SaleQty), Sum(SalePrice), Max(TaxCode) From #RFAInfo
----							Where SchemeID = @SchemeID
----							And IsNull(FlagWord, 0) = 0
----							And SchemeOutlet = 0
----							Group By InvoiceId, SKUCode, IsNull(FlagWord, 0)
----					Open UpdateFreeInfoCur
----					Fetch Next From UpdateFreeInfoCur Into @InvoiceID, @SKUCode, @Serial, @SaleQty, @SaleValue, @TaxCode
----					While (@@Fetch_Status = 0)
----					Begin
----						Select @FreeSKUSerial = FreeSKUSerial, @UOM = FreeUOM, @FreeQty = FreeQty, @FreeValue = FreeValue From dbo.mERP_fn_GetFreeSKUInfo(@InvoiceID, @SchemeID, @Serial,@ItemGroup,@TaxConfigFlag)
----						If IsNull(@UOM, '') <> ''
----						Begin
----							Set @FreeFlag = 1
----							Select Top 1 @SR =  SR From #RFAInfo Where InvoiceID = @InvoiceID And Serial = @Serial
----							
----							Update #RFAInfo Set FreeSKUSerial = @FreeSKUSerial, FreeBaseUOM = @UOM, RebateQty = @FreeQty, RebateValue = Case @FreeQty 
----																																		When 0 Then @FreeValue 
----																																		Else @FreeQty * @FreeValue	
----																																		End
----								Where InvoiceID = @InvoiceID And SR = @SR  And SchemeID = @SchemeID
----
----						End
----						Fetch Next From UpdateFreeInfoCur Into @InvoiceID, @SKUCode, @Serial, @SaleQty, @SaleValue, @TaxCode
----					End
----					Close UpdateFreeInfoCur
----					Deallocate UpdateFreeInfoCur
----					/*Update FreeQty Info of a Primary SKU - End*/	
----				End
----
----				
----
----				/*Promoted Value Update - Start */
----				/*Promoted Qty For SplCategory Scheme*/
----				If @ItemGroup = 2
----				Begin
----					Declare @PrimaryUOM Int 
----					Declare @SKUList nVarchar(2000)
----					Declare @QTYList nVarchar(2000)
----					Declare @PriceList nVarchar(2000)
----					Declare @TotalQty Decimal(18, 6)
----					Declare @TotalValue Decimal(18, 6)
----						
----					Declare InvoiceCur Cursor For
----						Select Distinct InvoiceID, Max(SlabID) From #RFAInfo 
----						Where SchemeID = @SchemeID 
----						And SchemeOutlet = 0
----						Group By InvoiceID 
----					Open InvoiceCur
----					Fetch Next From InvoiceCur Into @invoiceID, @SlabID
----					While @@Fetch_Status = 0
----					Begin
----						Set @SKUList = ''				
----						Set @QTYList = ''				
----						Set @PriceList = ''
----						Set @TotalQty	= 0	
----						Set @TotalValue	= 0	
----						/*Get Promoted Qty*/
----						Declare SKUCur Cursor For
----							Select  SKUCode, SaleQty, SaleQty * SalePrice   From #RFAInfo  --SaleQty * (SalePrice + (SalePrice * (TaxCode /100)))  From #RFAInfo 
----							Where InvoiceID = @invoiceID And SchemeId = @SchemeID And  IsNull(Flagword, 0) = 0 
----						Open SKUCur
----						Fetch Next From SKUCur Into @SKUCode, @SaleQty, @SaleValue
----						While @@Fetch_Status = 0
----						Begin
----							If @SKUList = ''
----								Set @SKUList = @SKUCode
----							Else
----								Set @SKUList = @SKUList + '|' + @SKUCode 
----
----							If @QTYList = ''
----								Set @QTYList = Cast(@SaleQty as nVarchar)
----							Else
----								Set @QTYList = @QTYList + '|' + Cast(@SaleQty as nVarchar)
----
----							If @PriceList = ''
----								Set @PriceList = Cast(@SaleValue as nVarchar)
----							Else
----								Set @PriceList = @PriceList + '|' + Cast(@SaleValue as nVarchar)
----
----
----							Set @TotalQty = @TotalQty + @SaleQty
----							Set @TotalValue = @TotalValue + @SaleValue
----
----							Fetch Next From SKUCur Into @SKUCode, @SaleQty, @SaleValue
----						End			
----						Close SKUCur
----						Deallocate SKUCur
----
----						
----						Select @PromotedQty = PromotedQty , @PromotedValue = PromotedValue, @UOMID = UOM From 
----								dbo.mERP_fn_GetPromotedQty('', @SchemeId, @SlabID, 0, 0, @SKUList, @QTYList, @PriceList)
----
----						If IsNull(@SKUList, '') <> ''
----						Begin
----							/*SKU wise Promoted Qty*/
----							Declare SKUCur Cursor For
----								Select Distinct SKUCode From #RFAInfo 
----								Where InvoiceID = @InvoiceID And SchemeID = @SchemeID And IsNull(Flagword, 0) = 0 
----							Open SKUCur
----							Fetch Next From SKUCur Into @SKUCode
----							While @@Fetch_Status = 0
----							Begin
----								If @UOMID = 4
----									Update #RFAInfo Set PromotedValue = (@PromotedValue/@TotalValue) * (SaleQty * SalePrice )
----											Where InvoiceID = @InvoiceID And SchemeID = @SchemeID And SKUCode = @SKUCode
----								Else
----									Update #RFAInfo Set PromotedQty = (@PromotedQty/@TotalQty) * SaleQty, PromotedValue = SalePrice * ((@PromotedQty/@TotalQty) * SaleQty)
----											Where InvoiceID = @InvoiceID And SchemeID = @SchemeID And SKUCode = @SKUCode
----
----								Fetch Next From SKUCur Into @SKUCode
----							End			
----							Close SKUCur
----							Deallocate SKUCur
----						End
----						Fetch Next From InvoiceCur Into @invoiceID, @SlabID
----					End			
----					Close InvoiceCur
----					Deallocate InvoiceCur
----
----					Update #RFAInfo Set PromotedQty = SaleQty, PromotedValue = SaleQty * SalePrice
----							 Where InvoiceType = 4
----
----				End
----				Else /*Promoted Qty Other schemes*/
----				Begin
----					Declare PromotedQty Cursor For 
----						Select InvoiceID, SKUCode, Min(Serial) ,Min(SR)
----						From #RFAInfo
----						Where SchemeID = @SchemeID
----						And IsNull(FlagWord,0) = 0
----						And SchemeOutlet = 0
----						Group By InvoiceId, SKUCode 
----						Order By SKUCode
----					Open PromotedQty
----					Fetch Next From PromotedQty Into @invoiceID, @SKUCode, @Serial,@SR
----					While @@Fetch_Status = 0
----					Begin
----						Select @SlabId = Max(IsNull(SlabID,0)), @SaleQty = Sum(SaleQty), 
----							@SaleValue = Sum(SalePrice * SaleQty ) 
----							--@SaleValue = Sum((SalePrice * SaleQty ) + ((SalePrice * SaleQty) * TaxCode/100)) 
----							From #RFAInfo 
----							Where InvoiceID = @InvoiceId And SchemeID = @SchemeID And SKUCode = @SKUCode
----						If @ItemGroup = 1
----						Begin
----							Select @PromotedValue = PromotedValue, @PromotedQty = PromotedQty, @UOM = UOM From dbo.mERP_fn_GetPromotedQty(@SKUCode, @SchemeId, @SlabID, @SaleQty, @SaleValue, '', '', '')
----							If IsNull(@PromotedQty,0) = 0 
----								Update #RFAInfo Set PromotedValue = @PromotedValue, PromotedQty = @PromotedQty Where InvoiceID = @InvoiceID And SchemeID = @SchemeID And SKUCode = @SKUCode And Serial =  @Serial And SR = @SR	
----							Else 
----							Begin
----								Update #RFAInfo Set PromotedValue = (@PromotedQty * SalePrice), PromotedQty = @PromotedQty Where InvoiceID = @InvoiceID And SchemeID = @SchemeID And SKUCode = @SKUCode And Serial = @Serial And  SR = @SR
----							End
----						End
----						Fetch Next From PromotedQty Into @invoiceID, @SKUCode, @Serial,@SR
----					End
----					Close PromotedQty
----					Deallocate PromotedQty	
----					/*Update for SalesReturn*/
----
----					Update #RFAInfo Set PromotedQty = SaleQty, PromotedValue = SaleQty * SalePrice,
----							RebateQty = (-1) * RebateQty, RebateValue = (-1) * RebateValue 
----							Where InvoiceType = 4
----				End
----				/*Promoted Value Update - End */
----
----			/*Remove entry if Rebate value comes in (-)ve*/
----			Declare SRCursor Cursor For
----			Select Distinct InvoiceID, BillRef From #RFAInfo Where InvoiceType = 1 And FlagWord = 0
----			Open SRCursor
----			Fetch Next From SRCursor Into @InvoiceID, @BillRef
----			While (@@Fetch_Status = 0)
----			Begin
----				Set @InvRebateValue = 0
----				Set @SRRebateValue = 0
----
----				/*Invoice Rebate value*/
----				Select @InvRebateValue = Sum(RebateValue) From #RFAInfo Where InvoiceID = @InvoiceID
----				/*Sales Return Rebate value against the invoice*/
----				Select @SRRebateValue = Sum(RebateValue) From #RFAInfo Where ReferenceNumber = @BillRef
----
----				If (@InvRebateValue + @SRRebateValue) < = 0 
----				Begin
----					Delete From #RFAInfo Where InvoiceID = @InvoiceID Or ReferenceNumber = @BillRef
----					--Select * From #RFAInfo Where InvoiceID = @InvoiceID Or ReferenceNumber = @BillRef
----				End
----				Fetch Next From SRCursor Into @InvoiceID, @BillRef
----			End
----			Close SRCursor	
----			Deallocate SRCursor
----
----			Update #RFAInfo Set SaleQty = (-1) * SaleQty, SaleValue = (-1) * SaleValue, 
----						PromotedQty = (-1) * PromotedQty, PromotedValue = (-1) * PromotedValue	
----						Where InvoiceType = 4
----
----			
----			/*Check for FreeQty Scheme*/
----			/*To Select Primary and its Free item in sequence - Start*/
----			If @ItemGroup = 1 And @FreeFlag = 1
----			Begin
----				
----				/*Serial No. for Detail data*/
----				If @QPSSrNo > 0 
----					Set @SRNo = @QPSSrNo+1	
----				Else
----					Set @SRNo = 1
----
----
----				
----				Declare FreeItem Cursor For 
----					Select Distinct SKUCode, InvoiceID, FreeSKUSerial, Serial 
----						From #RFAInfo
----						Where IsNull(FlagWord, 0) = 0
----						And SchemeID = @SchemeID
----						And FreeSKUSerial > 0
----						And InvoiceType <> 4
----
----					Union 
----
----					Select Distinct SKUCode, InvoiceID, FreeSKUSerial, Serial 
----						From #RFAInfo
----						Where IsNull(FlagWord, 0) = 0
----						And SchemeID = @SchemeID
----						And InvoiceType = 4
----
----
----				Open FreeItem
----				Fetch Next From FreeItem Into @SKUCode,@InvoiceId, @FreeSKUSerial, @Serial
----				While (@@Fetch_Status = 0)
----				Begin
----					If @PrevSKUCode <> @SKUCode
----						Set @SRNo = @SRNo + 1
----
----			
----					Insert Into #RFADetail 
----						Select  @SRNo, 0, InvoiceID, SchemeId, BillRef , OutletCode ,
----								RCSID , ActiveInRCS, LineType , Division ,
----								SubCategory , MarketSKU , SKUCode ,
----								UOM , Sum(SaleQty) ,Sum(SaleValue) ,
----								Sum(PromotedQty) , Sum(PromotedValue) ,Sum(RebateQty) , Sum(RebateValue) , Sum(PriceExclTax),
----								Max(TaxPercentage) , Sum(TaxAmount) , Sum(PriceInclTax) ,0 , Sum(BudgetedValue), InvoiceType,[Doc No]
----								From #RFAInfo
----								Where InvoiceID = @InvoiceId
----								And SchemeID = @SchemeID
----								And SKUCode = @SKUCode 
----								And IsNull(FlagWord, 0) = 0
----								Group By InvoiceID, SchemeId, BillRef , OutletCode ,
----								RCSID , ActiveInRCS, LineType , Division ,
----								SubCategory , MarketSKU , SKUCode ,
----								UOM, InvoiceType,[Doc No]
----
----						Union ALL
----
----						Select @SRNo, 1, InvoiceID, SchemeId, BillRef , OutletCode ,
----								RCSID , ActiveInRCS, LineType , Division ,
----								SubCategory , MarketSKU , SKUCode ,
----								UOM , SaleQty , SaleValue ,
----								PromotedQty , PromotedValue ,RebateQty , RebateValue , PriceExclTax ,
----								TaxPercentage , TaxAmount , PriceInclTax ,0 ,  BudgetedValue , InvoiceType,[Doc No]
----								From #RFAInfo
----								Where InvoiceID = @InvoiceId
----								And IsNull(FlagWord, 0) = 1
----								And Serial = @FreeSKUSerial
----
----					Set @PrevSKUCode = @SKUCode
----					Fetch Next From FreeItem Into @SKUCode, @InvoiceId, @FreeSKUSerial, @Serial
----				End
----				Close FreeItem
----				Deallocate FreeItem
----
----
----
----				/*Serial No. for Abstract data*/
----				If @QPSSrNo > 0 
----					Set @SRNo = @QPSSrNo
----				Else
----					Set @SRNo = 0
----				Declare PrimaryItem Cursor For 
----				Select Distinct SKUCode
----				From #RFAInfo
----				Where IsNull(FlagWord, 0) = 0
----				And SchemeID = @SchemeID
----				Open PrimaryItem 
----				Fetch Next From PrimaryItem Into @SKUCode
----				While (@@Fetch_Status = 0)
----				Begin
----					Set @SRNo = @SRNo + 1
----					Insert Into #RFAAbstract Select @SRNo,	Division, SubCategory, MarketSKU, SKUCode, UOM, Sum(IsNull(SaleQty,0)) as SaleQty,
----						Sum(IsNull(SaleValue,0)) as SaleValue, Sum(IsNull(PromotedQty,0)) as PromotedQty, Sum(IsNull(PromotedValue,0)) as PromotedValue, 
----						Max(IsNull(FreeBaseUOM,'')) as FreeBaseUOM, Sum(IsNull(RebateQty,0)) as RebateQty, Sum(IsNull(RebateValue,0)) as RebateValue, 
----						0 as BudgetedQty, 0 as BudgetedValue
----						From #RFAInfo
----						Where IsNull(FlagWord, 0) = 0
----						And SchemeID = @SchemeID
----						And SKUCode = @SKUCode
----						Group By SKUCode, Division, SubCategory, MarketSKU, UOM
----						Order By SKUCode
----					Fetch Next From PrimaryItem Into @SKUCode
----				End
----				Close PrimaryItem
----				Deallocate PrimaryItem
----					If (Select Count(*) From #RFAAbstract) >=  1 
----					Begin
----				
----						Insert Into #tmpRFAAbs
----						Select @WDCode as WDCode, @WDDest as WDDest, @SchemeType as SchemeType, @ActivityCode as ActivityCode, 
----						@ActivityType as ActivityDesc, @ActiveFrom as ActiveFrom, @ActiveTo As ActiveTo, 
----						@PayoutFrom as PayoutFrom, @PayoutTo As PayoutTo, *, @ApplicableOn as AppOn
----						From #RFAAbstract	
----					End
----					Else
----					Begin
----						Insert Into #tmpRFAAbs
----						Select @WDCode as WDCode, @WDDest as WDDest, @SchemeType as SchemeType, @ActivityCode as ActivityCode, 
----						@ActivityType as ActivityDesc, @ActiveFrom as ActiveFrom, @ActiveTo As ActiveTo, 
----						@PayoutFrom as PayoutFrom, @PayoutTo As PayoutTo,Null as SR,Null as Division,Null as SubCategory,Null as MarketSKU,Null as SKUCode,
----						Null as UOM,Null as SaleQty,Null as SaleValue,Null as  PromotedQty,Null as PromotedValue,
----						Null as FreeBaseUOM,Null as RebateQty,Null as RebateValue,Null as BudgetedQty,Null as BudgetedValue,@ApplicableOn as AppOn 
----					End
----
----
----					/*For FreeQty schemes RebateValue and RebateQty should not be shown in bottom frame*/
----					If @FreeFlag = 1
----						Update #RFADetail Set RebateQty = 0, RebateValue = 0, PriceExclTax =0,TaxAmount =0, PriceInclTax = 0  
----							Where IsNull(Flagword, 0) = 0 
----							And InvoiceType <> 4
----
----
----					
----					If (Select Count(*) From #RFADetail) >= 1
----					Begin
----						Insert Into #tmpRFADet
----						Select @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, @CSSchemeID as CompSchemeID, @ActivityType as ActivityDesc, 
----							@PayoutFrom as ActiveFrom, @PayoutTo As ActiveTo, SR, BillRef, OutletCode,
----							RCSID, ActiveInRCS, LineType , Division ,
----							SubCategory , MarketSKU , SKUCode ,
----							UOM , SaleQty , SaleValue ,
----							PromotedQty, 
----							PromotedValue ,RebateQty , RebateValue , PriceExclTax ,
----							TaxPercentage , TaxAmount , PriceInclTax ,BudgetedQty ,  BudgetedValue,Cust.Company_Name as 'OutletName' ,[Doc No]
----							From #RFADetail,Customer Cust 
----							Where Cust.CustomerID = #RFADetail.OutletCode  
----					End
----					Else
----					Begin
----						Insert Into #tmpRFADet
----						Select @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, @CSSchemeID as CompSchemeID, @ActivityType as ActivityDesc, 
----						@PayoutFrom as ActiveFrom, @PayoutTo As ActiveTo,Null as SR,Null as BillRef,Null as OutletCode,Null as RCSID,Null as  ActiveInRCS,
----						Null as LineType,Null as Division,Null as SubCategory,Null as MarketSKU,Null as SKUCode,
----						Null as UOM,Null as SaleQty,Null as SaleValue,Null as  PromotedQty,Null as PromotedValue,
----						Null as RebateQty,Null as RebateValue,Null as PriceExclTax,Null as TaxAmount,Null as TaxPercentage,
----						Null as PriceInclTax,Null as BudgetedQty,Null as BudgetedValue,Null as 'OutletName',Null as 'Doc No'
----					End
----				End
----				/*To Select Primary and its Free item in sequence - End*/
----				Else
----				Begin
----					/*Abstract data*/
----					If (Select Count(*) From #RFAInfo Where SchemeID = @SchemeID And IsNull(FlagWord, 0) = 0) >= 1
----					Begin
----							Insert Into #tmpRFAAbs
----							Select  @WDCode as WDCode, @WDDest as WDDest, @SchemeType as SchemeType, @ActivityCode as ActivityCode, 
----							@ActivityType as ActivityDesc, @ActiveFrom as ActiveFrom, @ActiveTo As ActiveTo, 
----							@PayoutFrom as PayoutFrom, @PayoutTo As PayoutTo, 0 as SR,
----							Division, SubCategory, MarketSKU, RFA.SKUCode, UOM, Sum(SaleQty) as SaleQty,
----							Sum(SaleValue) as SaleValue, Sum(PromotedQty) as PromotedQty, Sum(PromotedValue) as PromotedValue,
----							'' as FreeBaseUOM, Sum(IsNull(RebateQty,0)) as RebateQty, Sum(IsNull(RebateValue,0)) as RebateValue, 
----							0,0,@ApplicableOn							
----							From #RFAInfo RFA 
----							Where IsNull(FlagWord, 0) = 0
----							And SchemeID = @SchemeID
----							Group By RFA.SKUCode, Division, SubCategory, MarketSKU, UOM
----							Order By RFA.SKUCode
----							
----					End
----					Else
----					Begin
----						Insert Into #tmpRFAAbs
----						Select @WDCode as WDCode, @WDDest as WDDest, @SchemeType as SchemeType, @ActivityCode as ActivityCode, 
----						@ActivityType as ActivityDesc, @ActiveFrom as ActiveFrom, @ActiveTo As ActiveTo, 
----						@PayoutFrom as PayoutFrom, @PayoutTo As PayoutTo,Null as SR,Null as Division,Null as SubCategory,Null as MarketSKU,Null as SKUCode,
----						Null as UOM,Null as SaleQty,Null as SaleValue,Null as  PromotedQty,Null as PromotedValue,
----						Null as FreeBaseUOM,Null as RebateQty,Null as RebateValue,Null as BudgetedQty,Null as BudgetedValue,@ApplicableOn as AppOn 
----					End
----
----					/*Detail data*/
----					If @FreeFlag = 1 /*RebateValue and RebateQty should not be shown in bottom frame*/
----						Update #RFAInfo Set RebateQty = 0, RebateValue = 0, PriceExclTax =0,  TaxAmount =0, PriceInclTax = 0  
----							Where IsNull(Flagword, 0) = 0 
----							And InvoiceType <> 4
----					Select @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, @CSSchemeID as CompSchemeID, @ActivityType as ActivityDesc, 
----							@PayoutFrom as ActiveFrom, @PayoutTo As ActiveTo, 0 as SR, BillRef, OutletCode, RCSID, ActiveInRCS, LineType, Division, SubCategory, MarketSKU, SKUCode, UOM, Sum(SaleQty) as SaleQty,
----							Sum(SaleValue) as SaleValue, Sum(PromotedQty) as PromotedQty, Sum(PromotedValue) as PromotedValue, Sum(IsNull(RebateQty,0)) as RebateQty, 
----							Sum(IsNull(RebateValue,0)) as RebateValue, Max(PriceExclTax) as PriceExclTax, Max(TaxPercentage) as TaxPercentage, Max(TaxAmount) as TaxAmount,
----							Max(PriceInclTax) PriceInclTax,0 as BudgetedQty, 0 as BudgetedValue,Cust.Company_Name as 'OutletName' ,[Doc No] Into #ConDetail
----							From #RFAInfo,Customer Cust   
----							Where SchemeID = @SchemeID
----							And Cust.CustomerID = #RFAInfo.OutletCode 
----							And IsNull(FlagWord,0) = 0
----							Group By InvoiceId, SKUCode, BillRef, OutletCode, RCSID, ActiveInRCS, LineType, Division, SubCategory, MarketSKU, UOM,Cust.Company_Name,[Doc No]
----							Order By SKUCode
----					Insert Into #ConDetail Select @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, @CSSchemeID as CompSchemeID, @ActivityType as ActivityDesc, 
----							@PayoutFrom as ActiveFrom, @PayoutTo As ActiveTo, 0 as SR, BillRef, OutletCode, RCSID, ActiveInRCS, LineType, Division, SubCategory, MarketSKU, SKUCode, UOM, Sum(SaleQty) as SaleQty,
----							Sum(SaleValue) as SaleValue, Sum(PromotedQty) as PromotedQty, Sum(PromotedValue) as PromotedValue, Sum(IsNull(RebateQty,0)) as RebateQty, 
----							Sum(IsNull(RebateValue,0)) as RebateValue, Max(PriceExclTax) as PriceExclTax, Max(TaxPercentage) as TaxPercentage, Max(TaxAmount) as TaxAmount,
----							Max(PriceInclTax) PriceInclTax,0 as BudgetedQty, 0 as BudgetedValue,Cust.Company_Name as 'OutletName' ,[Doc No] --Into #ConDetail
----							From #RFAInfo,Customer Cust   
----							Where SchemeID = @SchemeID
----							And Cust.CustomerID = #RFAInfo.OutletCode 
----							And IsNull(FlagWord,0) = 1
----							Group By InvoiceId, SKUCode, BillRef, OutletCode, RCSID, ActiveInRCS, LineType, Division, SubCategory, MarketSKU, UOM,Cust.Company_Name,[Doc No]
----							Order By SKUCode
----				If (Select Count(*) From  #ConDetail) >= 1 
----					Begin
----						Insert Into #tmpRFADet
----						Select * From #ConDetail Order By LineType Desc
----					End
----					Else
----					Begin
----						Insert Into #tmpRFADet
----						Select @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, @CSSchemeID as CompSchemeID, @ActivityType as ActivityDesc, 
----						@PayoutFrom as ActiveFrom, @PayoutTo As ActiveTo,Null as SR,Null as BillRef,Null as OutletCode,Null as RCSID,Null as  ActiveInRCS,
----						Null as LineType,Null as Division,Null as SubCategory,Null as MarketSKU,Null as SKUCode,
----						Null as UOM,Null as SaleQty,Null as SaleValue,Null as  PromotedQty,Null as PromotedValue,
----						Null as RebateQty,Null as RebateValue,Null as PriceExclTax,Null as TaxAmount,Null as TaxPercentage,
----						Null as PriceInclTax,Null as BudgetedQty,Null as BudgetedValue,Null as 'OutletName',Null as 'Doc No'
----					End
----					Drop Table #ConDetail
----				End
----
----			End/*Trade - Item based schemes - End*/ 
----			Else If @ApplicableOn = 'INVOICE'
----			Begin/*Trade - Invoice based schemes - Start*/ 
----
----				
----				/*Invoice based Amt/Per*/
----				Insert Into #RFAInfo(InvoiceID, InvoiceType, BillRef, OutletCode, RCSID, SchemeDetail, Flagword, 
----						    RebateValue, SchemeID, ReferenceNumber,[Doc No]) 
----					Select IA.InvoiceID, IA.InvoiceType,
----					@InvPrefix + Cast(IA.DocumentID as nVarchar) as BillRef, 
----					C.CustomerID as OutletCode,
----					IsNull(C.RCSOutletID, '') as RCSID,
----					Case InvoiceType When 4 Then
----						dbo.fn_Get_SchInvItemFreePerc_SR(IA.InvoiceID,@SchemeID)
----					Else
----						IsNull(IA.MultipleSchemeDetails, '') End as SchemeDetail,
----					0 as FlagWord,
----					0 as RebateValue,
----					0 as SchemeID,
----					IA.ReferenceNumber,
----					IA.DocReference
----					From InvoiceAbstract IA, Customer C
----					Where IA.CustomerID = C.CustomerID
----					And IA.InvoiceType In (1,3,4)        
----					And (IA.Status & 128)=0  
----					And (Case IA.InvoiceType
----						When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID = 
----						IA.DocumentID
----						And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)--(Select dbo.mERP_fn_GetInvoiceDate(IA.InvoiceID, 1))
----						Else dbo.StripTimeFromDate(IA.InvoiceDate)
----						End) Between @ActiveFrom And @ActiveTo
----					And (Case IA.InvoiceType
----						When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID = IA.DocumentID
----							And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID) --(Select dbo.mERP_fn_GetInvoiceDate(IA.InvoiceID, 1))
----						Else dbo.StripTimeFromDate(IA.InvoiceDate)
----						End) Between @PayoutFrom And @PayoutTo
----	--				And (Case IA.InvoiceType
----	--					When 3 Then dbo.StripTimeFromDate(IA.CreationTime)
----	--					When 1 Then dbo.StripTimeFromDate(IA.CreationTime)
----	--					When 4 Then @ActiveTo
----	--					End) <= @ExpiryDate
----					And IsNull(IA.MultipleSchemeDetails, 0) <> ''
----
----
----
----				/*Invoice based Free qty*/
----				Insert Into #RFAInfo (InvoiceID, InvoiceType, BillRef, OutletCode, RCSID, SchemeDetail, 
----				Serial, Flagword, RebateQty, Amount, SchemeID, SKUCode, ReferenceNumber, TaxPercentage, 
----				TaxAmount,LineType,PriceInclTax,PriceExclTax,[Doc No]) 
----					Select IA.InvoiceID, IA.InvoiceType,
----					@InvPrefix + Cast(IA.DocumentID as nVarchar) as BillRef, 
----					C.CustomerID as OutletCode,
----					IsNull(C.RCSOutletID, '') as RCSID,
----					IsNull(ID.MultipleSchemeDetails, '') as SchemeDetail,
----					ID.Serial,
----					IsNull(ID.Flagword, 0),
----					Case ID.Flagword
----						When 1 Then (Case IA.InvoiceType When 4 Then (-1) * ID.Quantity Else ID.Quantity End)	
----						Else 0 End, 
----					ID.Quantity * (dbo.mERP_fn_GetMarginPTR(ID.Product_Code,ID.InvoiceID, @SchemeID) + (dbo.mERP_fn_GetMarginPTR(ID.Product_Code,ID.InvoiceID, @SchemeID) * (Case @TaxConfigFlag When 1 Then (ID.TaxCode/100) Else 0 End))) as RebateValue,
----					0 as SchemeID, ID.Product_Code,IA.ReferenceNumber,
----					ID.TaxCode ,
----					(ID.Quantity * (dbo.mERP_fn_GetMarginPTR(ID.Product_Code,ID.InvoiceID, @SchemeID) * (TaxCode / 100))) As TaxAmount ,'Free',
----					dbo.mERP_fn_GetMarginPTR(ID.Product_Code,ID.InvoiceID, @SchemeID) + (dbo.mERP_fn_GetMarginPTR(ID.Product_Code,ID.InvoiceID, @SchemeID) * (ID.TaxCode/100)) ,
----					dbo.mERP_fn_GetMarginPTR(ID.Product_Code,ID.InvoiceID, @SchemeID),IA.DocReference
----					From InvoiceAbstract IA, InvoiceDetail ID, Customer C
----					Where IA.InvoiceId = ID.InvoiceId
----					And IA.InvoiceType In (1,3,4)        
----					And (IA.Status & 128)=0  
----					And IA.CustomerID = C.CustomerID
----					And (Case IA.InvoiceType
----						When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID = 
----						IA.DocumentID
----						And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)--(Select dbo.mERP_fn_GetInvoiceDate(IA.InvoiceID, 1))
----						Else dbo.StripTimeFromDate(IA.InvoiceDate)
----						End) Between @ActiveFrom And @ActiveTo
----					And (Case IA.InvoiceType
----						When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID = IA.DocumentID
----							And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID) --(Select dbo.mERP_fn_GetInvoiceDate(IA.InvoiceID, 1))
----						Else dbo.StripTimeFromDate(IA.InvoiceDate)
----						End) Between @PayoutFrom And @PayoutTo				
----	--				And (Case IA.InvoiceType 
----	--					When 3 Then dbo.StripTimeFromDate(IA.CreationTime) 
----	--					When 1 Then dbo.StripTimeFromDate(IA.CreationTime) 
----	--					When 4 Then @ActiveTo
----	--					End) <= @ExpiryDate
----					And ID.Flagword = 1
----					And IsNull(IA.MultipleSchemeDetails, 0) <> ''
----
----
----
----			
----				Declare SchemeOutletCur Cursor For
----					Select Distinct OutletCode From #RFAInfo
----				Open SchemeOutletCur
----				Fetch Next From SchemeOutletCur Into @CustomerID
----				While (@@Fetch_Status = 0)			
----				Begin
----					Select @SchemeOutlet = 0, @SchemeGroup = GroupID From dbo.mERP_fn_CheckTradeSchemeOutlet(@SchemeID, @CustomerID)
----					Update #RFAInfo Set SchemeOutlet = @SchemeOutlet, SchemeGroup = @SchemeGroup 
----						Where OutletCode = @CustomerID
----					Update #RFAInfo Set ActiveInRCS = IsNull(TMDValue,N'') 
----						From Cust_TMD_Master CTM, Cust_TMD_Details CTD	
----						Where CTM.TMDID = CTD.TMDID
----						And CTD.CustomerID = @CustomerID
----						And OutletCode = @CustomerID
----					Fetch Next From SchemeOutletCur Into @CustomerID
----				End
----				Close SchemeOutletCur
----				Deallocate SchemeOutletCur
----
----				/*Delete non scheme Outlet*/
----				Delete From #RFAInfo Where IsNull(SchemeOutlet, 0) = 2
----
----				/*Update SKU Category Levels and UOM - Start*/
----				Declare UpdateLevelCur Cursor For 
----					Select Distinct SKUCode From #RFAInfo
----				Open UpdateLevelCur
----				Fetch Next From UpdateLevelCur Into @SKUCode
----				While (@@Fetch_Status = 0)
----				Begin
----					Select @MarketSKU = Category_Name, @MarketSKUID = CategoryID, @SubCatID = ParentID  
----						From ItemCategories Where CategoryID = (Select CategoryID From Items Where Product_Code = @SKUCode ) 		
----					Select @SubCategory = Category_Name, @DivID = ParentID From ItemCategories Where CategoryID = @SubCatID
----					Select @Divison = Category_Name From ItemCategories Where CategoryID = @DivID
----					Select @UOM = Description From UOM Where UOM = (Select UOM From Items Where Product_Code = @SKUCode)
----
----					Update #RFAInfo Set Division = @Divison, SubCategory = @SubCategory, MarketSKU = @MarketSKU, UOM = @UOM
----						Where SKUCode = @SKUCode
----					Update #RFAInfo Set FreeBaseUOM = (Select UOM.Description From UOM, Items Where Items.Product_Code = @SKUCode And Items.UOM = UOM.UOM)
----						Where SKUCode = @SKUCode
----					Fetch Next From UpdateLevelCur Into @SKUCode
----				End
----				Close UpdateLevelCur
----				Deallocate UpdateLevelCur
----				/*Update SKU Category Levels and UOM - End*/
----
----				
----				
----				Declare UpdateRebateCur Cursor For
----				Select InvoiceID, InvoiceType, SchemeDetail, Serial, Amount, FlagWord, SchemeOutlet, SR  
----				From #RFAInfo	
----				Where SchemeOutlet = 0
----				Open UpdateRebateCur	
----				Fetch Next From UpdateRebateCur Into @InvoiceID, @InvoiceType, @SchemeDetail, @Serial, @Amount, @FlagWord, @SchemeOutlet, @InvSRID 
----				While (@@Fetch_Status = 0)
----				Begin		
----					If @FlagWord = 1
----					Begin
----						If ((Select Count(*) From dbo.mERP_fn_GetInvSchemeDetail(@InvoiceID, @SchemeDetail, @FlagWord, 0, 0) Where SchemeID = @SchemeID) > 0)			
----						Begin
----							Update #RFAInfo Set RebateValue = Case @InvoiceType 
----																When 4 Then (-1) * @Amount
----																Else @Amount 
----																End, 
----															SchemeID = @SchemeID 
----								Where InvoiceID = @InvoiceID And Serial = @Serial And SR = @InvSRID And FlagWord = @FlagWord
----						End
----						Else 
----							Update #RFAInfo Set RebateValue = 0 
----								Where InvoiceID = @InvoiceID And Serial = @Serial
----					End
----					Else
----					Begin
----						Set @SchemeAmt = 0
----						Select @SchemeAmt = IsNull(SchAmt,0) From dbo.mERP_fn_GetInvSchemeDetail(@InvoiceID, @SchemeDetail, @FlagWord, 0, 0)
----								Where SchemeID = @SchemeID
----						If @SchemeAmt > 0
----							Update #RFAInfo Set RebateValue  = Case @InvoiceType 
----																When 4 Then (-1) * @SchemeAmt
----																Else @SchemeAmt 
----																End, SchemeID = @SchemeID  
----								Where InvoiceID = @InvoiceID And Isnull(Serial, 0) = 0
----					End
----					Fetch Next From UpdateRebateCur Into @InvoiceID, @InvoiceType, @SchemeDetail, @Serial, @Amount, @FlagWord, @SchemeOutlet, @InvSRID 
----				End
----				Close UpdateRebateCur
----				Deallocate UpdateRebateCur 
----
----
----				
----				/*Remove entry if Rebate value comes in (-)ve*/
----				Declare SRCursor Cursor For
----					Select Distinct InvoiceID, BillRef From #RFAInfo Where InvoiceType = 1 And FlagWord = 0
----				Open SRCursor
----				Fetch Next From SRCursor Into @InvoiceID, @BillRef
----				While (@@Fetch_Status = 0)
----				Begin
----					Set @InvRebateValue = 0
----					Set @SRRebateValue = 0
----
----					/*Invoice Rebate value*/
----					Select @InvRebateValue = Sum(RebateValue) From #RFAInfo Where InvoiceID = @InvoiceID
----					/*Sales Return Rebate value against the invoice*/
----					Select @SRRebateValue = Sum(RebateValue) From #RFAInfo Where ReferenceNumber = @BillRef
----
----					If (@InvRebateValue + @SRRebateValue) < = 0 
----					Begin
----						Delete From #RFAInfo Where InvoiceID = @InvoiceID Or ReferenceNumber = @BillRef
----						--Select * From #RFAInfo Where InvoiceID = @InvoiceID Or ReferenceNumber = @BillRef
----					End
----					Fetch Next From SRCursor Into @InvoiceID, @BillRef
----				End
----				Close SRCursor	
----				Deallocate SRCursor
----
----				
----
----				/*Abstract data*/
----				If (Select Count(*) From #RFAInfo Where SchemeID = @SchemeID) >= 1 
----				Begin
----					Insert Into #tmpRFAAbs
----					Select  @WDCode as WDCode, @WDDest as WDDest, @SchemeType as SchemeType, @ActivityCode as ActivityCode, 
----							@ActivityType as ActivityDesc, @ActiveFrom as ActiveFrom, @ActiveTo As ActiveTo, 
----							@PayoutFrom as PayoutFrom, @PayoutTo As PayoutTo, 0 as SR,
----							Division, SubCategory, MarketSKU, SKUCode, UOM, Sum(SaleQty) as SaleQty,
----							Sum(SaleValue) as SaleValue, Sum(PromotedQty) As PromotedQty, Sum(PromotedValue) As PromotedValue, 
----							FreeBaseUOM, Sum(RebateQty) as RebateQty, Sum(IsNull(RebateValue, 0)) as RebateValue, 
----							0 as BudgetedQty, 0 as BudgetedValue, @ApplicableOn as AppOn
----							From #RFAInfo
----							Where SchemeID = @SchemeID
----							Group By SchemeID, Division, SubCategory, MarketSKU, SKUCode, UOM, 
----							FreeBaseUOM
----							Order By SKUCode
----
----					
----					/*Detail data*/
----					Insert Into #tmpRFADet
----					Select  @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, 
----							@CSSchemeID as CompSchemeID, @ActivityType as ActivityDesc, 
----							@PayoutFrom as ActiveFrom, @PayoutTo As ActiveTo, 0 as SR,
----							BillRef, OutletCode, RCSID, ActiveInRCS, LineType as LineType, 
----							Division, SubCategory, MarketSKU, SKUCode, UOM, Sum(SaleQty) as SaleQty,
----							Sum(SaleValue) as SaleValue, Sum(PromotedQty) As PromotedQty,Sum(PromotedValue) As PromotedValue, 
----							Sum(RebateQty) as RebateQty, Sum(IsNull(RebateValue, 0)) as RebateValue, 
----							IsNull(PriceExclTax, 0) as PriceExclTax, IsNull(TaxPercentage,0) as TaxPercentage, 
----							IsNull(TaxAmount,0) as TaxAmount, IsNull(PriceInclTax,0) as PriceInclTax,
----							0 as BudgetedQty, 0 as BudgetedValue,Cust.Company_Name as 'OutletName',[Doc No]
----							From #RFAInfo,Customer Cust   
----							Where SchemeID = @SchemeID
----							And Cust.CustomerID = #RFAInfo.OutletCode 
----							Group By SchemeID, InvoiceID, OutletCode, RCSID, ActiveInRCS, Division, SubCategory, MarketSKU, SKUCode, UOM,
----							FreeBaseUOM, BillRef ,LineType,
----							PriceExclTax, TaxPercentage, TaxAmount, PriceInclTax,Cust.Company_Name,[Doc No]
----							Order By SKUCode
----				End
----				Else
----				Begin
----					Insert Into #tmpRFAAbs
----					Select @WDCode as WDCode, @WDDest as WDDest, @SchemeType as SchemeType, @ActivityCode as ActivityCode, 
----						   @ActivityType as ActivityDesc, @ActiveFrom as ActiveFrom, @ActiveTo As ActiveTo,
----						   @PayoutFrom as PayoutFrom, @PayoutTo As PayoutTo,Null as SR,Null as Division,Null as SubCategory,
----						   Null as MarketSKU,Null as SKUCode,Null as UOM,Null as SaleQty,Null as SaleValue,
----						   Null as  PromotedQty,Null as PromotedValue,Null as FreeBaseUOM,Null as RebateQty,
----						   Null as RebateValue,Null as BudgetedQty,Null as BudgetedValue,@ApplicableOn as AppOn 
----
----					Insert Into #tmpRFADet
----					Select @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, @CSSchemeID as CompSchemeID,
----						   @ActivityType as ActivityDesc,@PayoutFrom as ActiveFrom, @PayoutTo As ActiveTo,Null as SR,
----						   Null as BillRef,Null as OutletCode,Null as RCSID,Null as  ActiveInRCS,Null as LineType,
----						   Null as Division,Null as SubCategory,Null as MarketSKU,Null as SKUCode,Null as UOM,
----						   Null as SaleQty,Null as SaleValue,Null as  PromotedQty,Null as PromotedValue,Null as RebateQty,
----						   Null as RebateValue,Null as PriceExclTax,Null as TaxAmount,Null as TaxPercentage,
----						   Null as PriceInclTax,Null as BudgetedQty,Null as BudgetedValue,Null as 'OutletName',Null as 'Doc No'	
----				End
----
----				
----			End	/*Trade - Invoice based schemes - End*/ 
----		End /* Non QPS Scheme ends here */

	
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
						Null as PriceInclTax, Null as BudgetedQty, Null as BudgetedValue,Null as 'OutletName',Null as 'Doc No',Null as 'SR', Null as TOQ
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
						TaxAmount,PriceInclTax,0,0,OutletName,[Doc No],TOQ From #tmpRFADet
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
					TaxAmount,PriceInclTax,0,0,OutletName,[Doc No],TOQ From #tmpRFADet
					Where (isNull(Division,'') <> '' Or isNull(RebateValue,0) <> 0)
					And SKUCode Not In(Select SKUCode From #tmpFinalAbs)
					And SKUCode Not In(Select SKUCode From #tmpFinalDet)
					
					Update #tmpFinalAbs Set SaleQty = (Select Sum(SalesQty) From #tmpSKUWiseSales Where SKUCode = #tmpFinalAbs.SKUCode),
					SaleValue = (Select Sum(SalesValue) From #tmpSKUWiseSales Where SKUCode = #tmpFinalAbs.SKUCode)
	
					Select * from #tmpFinalAbs
					Select * from #tmpFinalDet
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


				Update #tmpFinalAbs Set SaleQty = (Select Sum(SalesQty) From #tmpSKUWiseSales Where SKUCode = #tmpFinalAbs.SKUCode),
				SaleValue = (Select Sum(SalesValue) From #tmpSKUWiseSales Where SKUCode = #tmpFinalAbs.SKUCode)

				
				
			
				Select * from #tmpFinalAbs

				Select * from #tmpRFADet	
				Where (isNull(Division,'') <> '' Or isNull(RebateValue,0) <> 0)
			End
		End
		Else
		Begin
				/*Abstract Data*/
			Select  @WDCode as WDCode, @WDDest as WDDest, @SchemeType as SchemeType, @ActivityCode as ActivityCode,
						@ActivityType as ActivityDesc, @ActiveFrom as ActiveFrom, @ActiveTo As ActiveTo, 
						@PayoutFrom as PayoutFrom, @PayoutTo as PayoutTo, Null as Division, Null as SubCategory,
						Null as MarketSKU, Null as SKUCode, Null as UOM, Null as SaleQty, Null as SaleValue,
						Null as PromotedQty, Null as PromotedValue, Null as FreeBaseUOM, Null as RebateQty, 
						Null as RebateValue, Null as BudgetedQty, Null as BudgetedValue, @ApplicableOn as AppOn,Null as SR
					
					
			/*Detail data*/
			Select  @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, @CSSchemeID As CompSchemeID,
						@ActivityType as ActivityDesc, @PayoutFrom as ActiveFrom, @PayoutTo As ActiveTo, Null as BillRef,
						Null as OutletCode, Null as RCSID, Null as ActiveInRCS, Null as LineType, Null as Division, Null as SubCategory, Null as MarketSKU,
						Null as SKUCode, Null as UOM, Null as SaleQty, Null as SaleValue, Null as PromotedQty, Null as PromotedValue,
						Null as RebateQty, Null as RebateValue, Null as PriceExclTax, Null as TaxPercentage, Null as TaxAmount,
						Null as PriceInclTax, Null as BudgetedQty, Null as BudgetedValue,Null as 'OutletName',Null as 'Doc No'	,Null as SR, Null as TOQ
		End
	End
	End /*--SP Trade Scheme - End*/

	Else If @SchType = 3 /*Display Scheme - Start*/
	Begin
			Select @SchemeType = ST.SchemeType,
			@ActivityCode = SA.ActivityCode, 
			@CSSchemeID = SA.CS_RecSchID,
			@ActivityType = SA.Description,
			@ActiveFrom = SA.ActiveFrom, 
			@ActiveTo = SA.ActiveTo, 
			@PayoutFrom = SPP.PayoutPeriodFrom,
			@PayoutTo = SPP.PayoutPeriodTo,
			@ExpiryDate = SA.ExpiryDate
			From tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemeType ST, tbl_mERP_SchemePayoutPeriod SPP
			Where SA.SchemeID = @SchemeID
			And IsNull(SA.RFAApplicable, 0) = 1
			And SA.SchemeID = SPP.SchemeID
			And SA.SchemeType = ST.ID		
			And SPP.ID = @PayoutID

		Insert Into #RFAInfo(OutletCode, RCSID, RebateValue,BudgetedValue)
			Select DBP.OutletCode, C.RCSOutletID, (DBP.AllocatedAmount - DBP.PendingAmount) ,DBP.AllocatedAmount 
				From tbl_mERP_DispSchBudgetPayout DBP(NoLock), Customer C(NoLock), tbl_mERP_SchemePayoutPeriod SPP(NoLock)
				Where SPP.SchemeID = @SchemeID
				And SPP.ID = @PayoutID
				And SPP.SchemeID = DBP.SchemeID
				And SPP.ID = DBP.PayoutPeriodID
				And DBP.OutletCode = C.CustomerID
				And IsNull(DBP.CrNoteRaised, 0) = 1

		Declare SchemeOutletCur Cursor For
			Select Distinct OutletCode From #RFAInfo
		Open SchemeOutletCur
		Fetch Next From SchemeOutletCur Into @CustomerID
		While (@@Fetch_Status = 0)			
		Begin
			
--			Update #RFAInfo Set ActiveInRCS = IsNull(TMDValue,N'') 
--				From Cust_TMD_Master CTM, Cust_TMD_Details CTD	
--				Where CTM.TMDID = CTD.TMDID
--				And CTD.CustomerID = @CustomerID
--				And OutletCode = @CustomerID

			Update #RFAInfo 
				Set ActiveInRCS = (Case when IsNull(C.RCSOutletID,'') <> '' then 'Yes' else 'No' end)
			From  Customer C(NoLock)
			Where  C.CustomerID = #RFAInfo.OutletCode
			And #RFAInfo.OutletCode = @CustomerID

			Fetch Next From SchemeOutletCur Into @CustomerID
		End
		Close SchemeOutletCur
		Deallocate SchemeOutletCur

		If (Select Count(*) From #RFAInfo) >= 1
		Begin
			/*PayoutPeriod wise*/
			Select  @WDCode as WDCode, @WDDest as WDDest, @SchemeType as SchemeType, @ActivityCode as ActivityCode,
						@ActivityType as ActivityDesc, @ActiveFrom as ActiveFrom, @ActiveTo As ActiveTo, 
						@PayoutFrom as PayoutFrom, @PayoutTo as PayoutTo, Null as Division, Null as SubCategory,
						Null as MarketSKU, Null as SKUCode, Null as UOM, Null as SaleQty, Null as SaleValue,
						Null as PromotedQty, Null as PromotedValue, Null as FreeBaseUOM, Null as RebateQty, 
						sum(RebateValue) as RebateValue, Null as BudgetedQty, Sum(BudgetedValue) as BudgetedValue, 'Outlet' as AppOn
					From #RFAInfo
					
			/*Customer wise*/
			Select  @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, @CSSchemeID As CompSchemeID,
						@ActivityType as ActivityDesc, @PayoutFrom as ActiveFrom, @PayoutTo As ActiveTo, Null as BillRef,
						OutletCode, RCSID, ActiveInRCS, Null as LineType, Null as Division, Null as SubCategory, Null as MarketSKU,
						Null as SKUCode, Null as UOM, Null as SaleQty, Null as SaleValue, Null as PromotedQty, Null as PromotedValue,
						Null as RebateQty, RebateValue as RebateValue, Null as PriceExclTax, Null as TaxPercentage, Null as TaxAmount,
						Null as PriceInclTax, Null as BudgetedQty, BudgetedValue,Cust.Company_Name as 'OutletName'
					From #RFAInfo,Customer Cust   
					Where Cust.CustomerID = #RFAInfo.OutletCode 
		End
		Else
		Begin
				/*PayoutPeriod wise*/
			Select  @WDCode as WDCode, @WDDest as WDDest, @SchemeType as SchemeType, @ActivityCode as ActivityCode,
						@ActivityType as ActivityDesc, @ActiveFrom as ActiveFrom, @ActiveTo As ActiveTo, 
						@PayoutFrom as PayoutFrom, @PayoutTo as PayoutTo, Null as Division, Null as SubCategory,
						Null as MarketSKU, Null as SKUCode, Null as UOM, Null as SaleQty, Null as SaleValue,
						Null as PromotedQty, Null as PromotedValue, Null as FreeBaseUOM, Null as RebateQty, 
						Null as RebateValue, Null as BudgetedQty, Null as BudgetedValue, 'Outlet' as AppOn
					
					
			/*Customer wise*/
			Select  @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, @CSSchemeID As CompSchemeID,
						@ActivityType as ActivityDesc, @PayoutFrom as ActiveFrom, @PayoutTo As ActiveTo, Null as BillRef,
						Null as OutletCode, Null as RCSID,Null as ActiveInRCS, Null as LineType, Null as Division, Null as SubCategory, Null as MarketSKU,
						Null as SKUCode, Null as UOM, Null as SaleQty, Null as SaleValue, Null as PromotedQty, Null as PromotedValue,
						Null as RebateQty, Null as RebateValue, Null as PriceExclTax, Null as TaxPercentage, Null as TaxAmount,
						Null as PriceInclTax, Null as BudgetedQty, Null as BudgetedValue,Null as 'OutletName'
					
		End
	End
	/*Display Scheme - End*/
	Else If @SchType = 4 
	Begin/*Points Scheme - Start*/
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
			@ItemGroup = Itemgroup
			From tbl_mERP_SchemeAbstract SA (NoLock), tbl_mERP_SchemeType ST (NoLock), tbl_mERP_SchemePayoutPeriod SPP (NoLock)
			Where SA.SchemeID = @SchemeID
				And IsNull(SA.RFAApplicable, 0) = 1
				And SA.SchemeID = SPP.SchemeID
				And SA.SchemeType = ST.ID		
				And SPP.ID = @PayoutID

		Select @RedeemDate = dbo.StripTimeFromDate(Max(CreationDate)) From tbl_mERP_CSRedemption (NoLock)
			Where PayoutID = @PayoutID
			And IsNull(RFAStatus,0) = 1

		If @ApplicableOn = 'ITEM' Or @ApplicableOn = 'SPL_CAT'
		Begin --@ApplicableOn = 'ITEM' 
			Insert Into #RFAInfo(InvoiceID, BillRef, OutletCode, RCSID, LineType, Division, SubCategory, MarketSKU,
				 SKUCode, UOM, SaleQty, SaleValue, PromotedQty, PromotedValue, RebateQty, RebateValue, TaxCode,
				 UOM1Conv, UOM2Conv, SalePrice, InvoiceType, SchemeOutlet, SchemeGroup, ReferenceNumber,[Doc No],TOQ)
			Select IA.InvoiceID, 
			--@InvPrefix + Cast(IA.DocumentID as nVarchar) as BillRef,
			Case IsNULL(IA.GSTFlag ,0)
			When 0 then @InvPrefix + Cast(IA.DocumentID as nVarchar)
			Else
				IsNULL(IA.GSTFullDocID,'')
			End as BillRef,
				C.CustomerID, C.RCSOutletID, 
				-- 'MAIN' as LineType, 
				(Case When InvoiceType <> 4 Then 'MAIN' 
				Else
					Case When IsNull(IA.Status,0) & 32 <> 0 Then 'Sales Return - Damaged'
					Else 'Sales Return - Saleable'
					End
				End)
				as LineType,
				Null as Division, Null as SubCategory,
				Null as MarketSKU, ID.Product_Code as SKUCode, Null as UOM, Sum(ID.Quantity) as SaleQty, 
				Sum(ID.Amount) as SaleValue, 0 as PromotedQty, 0 as PromotedValue, 0 as RebateQty, 0 as RebateValue,
				Max(TaxCode) as Tax, 0 as UOM1Conv, 0 as UOM2Conv, ID.SalePrice as SalePrice, IA.InvoiceType,
				Null as SchemeOutlet, Null as SchemeGroup, IA.ReferenceNumber,IA.DocReference,Max(ID.TAXONQTY)
				From InvoiceAbstract IA (NoLock), InvoiceDetail ID (NoLock), Customer C (NoLock)
				Where (Case IA.InvoiceType
						When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract (NoLock) Where DocumentID = 
						IA.DocumentID
						And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)--(Select dbo.mERP_fn_GetInvoiceDate(IA.InvoiceID, 1))
						Else dbo.StripTimeFromDate(IA.InvoiceDate)
						End) Between @ActiveFrom And @ActiveTo
					And (Case IA.InvoiceType
						When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract (NoLock) Where DocumentID = IA.DocumentID
							And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID) --(Select dbo.mERP_fn_GetInvoiceDate(IA.InvoiceID, 1))
						Else dbo.StripTimeFromDate(IA.InvoiceDate)
						End) Between @PayoutFrom And @PayoutTo
					And dbo.StripTimeFromDate(IA.CreationTime) <= @RedeemDate
				And IA.InvoiceType In (1,3,4)
				And IA.Status & 128 = 0 
				And IA.InvoiceID = ID.InvoiceID
				And IsNull(ID.Flagword, 0) = 0
				And IA.CustomerID = C.CustomerID
				Group By IA.InvoiceID, IA.DocumentID, C.CustomerID, C.RCSOutletID, ID.Product_Code,
				IA.InvoiceType, ID.SalePrice, IA.ReferenceNumber, IA.Status,IA.DocReference,IA.GSTFlag,IA.GSTFullDocID
				Order By IA.InvoiceID

			Declare SchemeOutletCur Cursor For
				Select Distinct OutletCode From #RFAInfo
			Open SchemeOutletCur
			Fetch Next From SchemeOutletCur Into @CustomerID
			While (@@Fetch_Status = 0)			
			Begin
				Select @SchemeOutlet = QPS, @SchemeGroup = GroupID From dbo.mERP_fn_CheckSchemeOutlet(@SchemeID, @CustomerID)
				--Set @SchemeOutlet = 0
				Update #RFAInfo Set SchemeOutlet = @SchemeOutlet, SchemeGroup = @SchemeGroup 
					Where OutletCode = @CustomerID
				
--				Update #RFAInfo Set ActiveInRCS = IsNull(TMDValue,N'')
--					From Cust_TMD_Master CTM, Cust_TMD_Details CTD	
--					Where CTM.TMDID = CTD.TMDID
--					And CTD.CustomerID = @CustomerID
--					And OutletCode = @CustomerID
				
			Update #RFAInfo 
					Set ActiveInRCS = (Case when IsNull(C.RCSOutletID,'') <> '' then 'Yes' else 'No' end)
				From  Customer C(NoLock)
				Where  C.CustomerID = #RFAInfo.OutletCode
				And #RFAInfo.OutletCode = @CustomerID

				Fetch Next From SchemeOutletCur Into @CustomerID
			End
			Close SchemeOutletCur
			Deallocate SchemeOutletCur

			/*Delete non scheme Outlet*/
			Delete From #RFAInfo Where IsNull(SchemeOutlet, 0) = 2

					

--			/*Update SKU wise data*/
--			Declare UpdateLevelCur Cursor For 
--				Select Distinct SKUCode From #RFAInfo
--			Open UpdateLevelCur
--			Fetch Next From UpdateLevelCur Into @SKUCode
--			While (@@Fetch_Status = 0)
--			Begin
--				Select @MarketSKU = Category_Name, @MarketSKUID = CategoryID, @SubCatID = ParentID  
--					From ItemCategories Where CategoryID = (Select CategoryID From Items Where Product_Code = @SKUCode ) 		
--				Select @SubCategory = Category_Name, @DivID = ParentID From ItemCategories Where CategoryID = @SubCatID
--				Select @Divison = Category_Name From ItemCategories Where CategoryID = @DivID
--				Select @UOM = Description From UOM Where UOM = (Select UOM From Items Where Product_Code = @SKUCode)
--
--				Update #RFAInfo Set Division = @Divison, SubCategory = @SubCategory, MarketSKU = @MarketSKU, UOM = @UOM,
--					UOM1conv = (Select UOM1_Conversion From Items Where Product_Code = @SKUCode), 
--					UOM2conv = (Select UOM2_Conversion From Items Where Product_Code = @SKUCode),
--					SchemeSKU = (Select dbo.mERP_fn_CheckSchemeSKU(@SchemeID, @SKUCode, @Divison, @SubCategory, @MarketSKU))
--					Where SKUCode = @SKUCode 
--
--				Fetch Next From UpdateLevelCur Into @SKUCode
--			End
--			Close UpdateLevelCur
--			Deallocate UpdateLevelCur

			/* Update  SchemeSKU  = 1 For Items which comes in any of the Product Scope of the scheme */
			Update #RFAInfo Set SchemeSKU = 1 
			Where SKUCode In(Select Product_Code From dbo.mERP_fn_Get_CSSku(@SchemeID))

			Delete From #RFAInfo Where IsNull(SchemeSKU, 0) = 0 

			/* Update Division , Market sku ,And Sub Category */
			Update RFA Set Division = IC2.Category_Name, SubCategory = IC1.Category_Name, MarketSKU = IC.Category_Name, UOM = U.Description,
			UOM1conv = I.UOM1_Conversion,UOM2conv = I.UOM2_Conversion
			From #RFAInfo RFA,Items I(NoLock) , ItemCategories IC(NoLock), ItemCategories IC1(NoLock),ItemCategories IC2(NoLock),UOM U(NoLock)
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
					--Sum(SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))),  
					Sum(SaleValue),
					UOM1Conv,UOM2Conv
					From #RFAInfo
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
											When 4 Then (-1) * @PromotedValue
											Else @PromotedValue End,
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
					From #RFAInfo
					Where IsNull(SchemeOutlet, 0) = 0
				Open InvoiceCur
				Fetch Next From InvoiceCur Into @InvoiceID, @InvoiceType, @SchemeGroup
				While (@@Fetch_Status = 0)
				Begin
					Set @UOM1Qty = 0
					Set @UOM2Qty = 0
					Set @SaleValue = 0
					Set @SaleQty = 0
					/*To get cumulative value of items per invoice to apply scheme*/
					Declare SKUCur Cursor For
						Select SKUCode, Sum(SaleQty), 
						--Sum(SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))), 
						Sum(SaleValue),
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
									When 4 Then (-1) * ((Case @UOMID When 2 Then @PromotedQty * UOM1Conv
												When 3 Then @PromotedQty * UOM2Conv
												Else @PromotedQty End)/@SaleQty) * SaleQty 
									Else ((Case @UOMID When 2 Then @PromotedQty * UOM1Conv
												When 3 Then @PromotedQty * UOM2Conv
												Else @PromotedQty End)/@SaleQty) * SaleQty
									End,
--						PromotedValue = Case InvoiceType
--									When 4 Then (-1) * (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
--									Else (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))) End,
						PromotedValue = Case InvoiceType
									When 4 Then (-1) * ((SaleValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * @PromotedValue)
									Else ((SaleValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * @PromotedValue)
								End,
						TotalPoints = (@RebateQty / @SaleQty) * SaleQty,
						PointsValue = (@RebateValue / @SaleQty) * SaleQty
						Where InvoiceID = @InvoiceID

				Fetch Next From InvoiceCur Into @InvoiceID, @InvoiceType, @SchemeGroup
				End
				Close InvoiceCur
				Deallocate InvoiceCur
			End /*Spl.Category schemes - End*/
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
					Open SKUCur
					Fetch Next From SKUCur Into @SKUCode
					While @@Fetch_Status = 0
					Begin
						Set @UOM1Qty = 0
						Set @UOM2Qty = 0
						Set @SaleValue = 0
						Set @SaleQty = 0
						Declare QPSSKUCur Cursor For 
							Select InvoiceID, SchemeGroup, SKUCode, Sum(SaleQty), 
							--Sum(SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))), 
							Sum(SaleValue),
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
--											PromotedValue = isNull(SaleValue,0),
							PromotedValue = Case InvoiceType
								When 4 Then (-1) * ((SaleValue /Case @SaleValue When 0 Then 1 Else @SaleValue End) * @PromotedValue)
								Else ((SaleValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * @PromotedValue)
								End,

							TotalPoints = ((@RebateQty / @SaleQty) * SaleQty),
							PointsValue = ((@RebateValue / @SaleQty) * SaleQty)
							Where OutletCode=@OutletCode and SKUCode = @SKUCode
							And IsNull(SchemeOutlet, 0) = 1
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
					Select Distinct SchemeGroup,OutletCode From #RFAInfo
					Where IsNull(SchemeOutlet, 0) = 1
				
				Open GroupCur
				Fetch Next From GroupCur Into @SchemeGroup,@OutletCode
				While (@@Fetch_Status = 0)
				Begin
					Select @SaleQty = Sum( (case when invoicetype =4 then -SaleQty else SaleQty end)), 
					-- @SaleValue = Sum((case when InvoiceType=4 then (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))) * -1) else (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))) ) end)), 
						@SaleValue = Sum((Case When Invoicetype = 4 then (SaleValue * -1)
								Else (SaleValue) end)),  
					@UOM1Qty = Sum((case when InvoiceType = 4 then (SaleQty*-1) else (SaleQty) end)/UOM1Conv), @UOM2Qty = Sum((Case When InvoiceType=4 then (SaleQty *-1) else (SaleQty) end)/UOM2Conv)
							From #RFAInfo
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
											PromotedValue = Case InvoiceType
											When 4 Then (-1) * (@PromotedValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
											Else (@PromotedValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))) 
											End,
											RebateQty = Case InvoiceType 
											When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty 
											Else (@RebateQty / @SaleQty) * SaleQty 
											End,
											RebateValue = Case InvoiceType 
											When 4 Then (-1) * (RebateValue / @SaleQty) * SaleQty 
											Else (RebateValue / @SaleQty) * SaleQty 
											End,
						TotalPoints = (@RebateQty / @SaleQty) * SaleQty,
						PointsValue = (@RebateValue / @SaleQty) * SaleQty
						Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1

					Else If @UOMID = 4
							Update #RFAInfo Set PromotedQty = Case InvoiceType 
							When 4 Then (-1) * (@PromotedQty / @SaleQty) * SaleQty 
							Else (@PromotedQty / @SaleQty) * SaleQty 
							End,
							PromotedValue = Case InvoiceType
							When 4 Then (-1) * ((SaleValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * @PromotedValue)
							Else ((SaleValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * @PromotedValue)
							End,
							RebateQty = Case InvoiceType 
							When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty 
							Else (@RebateQty / @SaleQty) * SaleQty 
							End,
							RebateValue = Case InvoiceType 
							When 4 Then (-1) * (RebateValue / @SaleQty) * SaleQty 
							Else (RebateValue / @SaleQty) * SaleQty 
							End,
						TotalPoints = (@RebateQty / @SaleQty) * SaleQty,
						PointsValue = (@RebateValue / @SaleQty) * SaleQty
						Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1
					Else If @UOMID = 2
						Update #RFAInfo Set PromotedQty = Case InvoiceType
											When 4 Then (-1) * ((@PromotedQty / UOM1Conv) * SaleQty)
											Else ((@PromotedQty / @UOM1Qty) * SaleQty) 
											End, 
											PromotedValue = Case InvoiceType
											When 4 Then (-1) * (@PromotedValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
											Else (@PromotedValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))) 
											End,
											RebateQty = Case InvoiceType 
											When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty 
											Else (@RebateQty / @SaleQty) * SaleQty 
											End,
											RebateValue = Case InvoiceType 
											When 4 Then (-1) * (RebateValue / @SaleQty) * SaleQty 
											Else (RebateValue / @SaleQty) * SaleQty 
											End,
						TotalPoints = (@RebateQty / @SaleQty) * SaleQty,
						PointsValue = (@RebateValue / @SaleQty) * SaleQty
						Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1
					Else If @UOMID = 3
						Update #RFAInfo Set PromotedQty = Case InvoiceType
											When 4 Then (-1) * ((@PromotedQty / UOM2Conv) * SaleQty)
											Else ((@PromotedQty / @UOM2Qty) * SaleQty) 
											End, 
											PromotedValue = Case InvoiceType 
											When 4 Then (-1) * (@PromotedValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
											Else (@PromotedValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))) 
											End,
											RebateQty = Case InvoiceType 
											When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty 
											Else (@RebateQty / @SaleQty) * SaleQty 
											End,
											RebateValue = Case InvoiceType 
											When 4 Then (-1) * (RebateValue / @SaleQty) * SaleQty 
											Else (RebateValue / @SaleQty) * SaleQty 
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
		End /*@ApplicableOn = 'ITEM'*/
		/*Apply Item based schemes - End*/
		/*Apply Invoice based schemes - Start*/
		Else If @ApplicableOn = 'INVOICE'
		Begin
			Insert Into #RFAInfo (InvoiceID, InvoiceType, BillRef, OutletCode, RCSID, RebateQty, RebateValue, Amount, SchemeID, SchemeOutlet, SchemeGroup,[Doc No]) 
				Select IA.InvoiceID, IA.InvoiceType,
				--@InvPrefix + Cast(IA.DocumentID as nVarchar) as BillRef, 
				Case IsNULL(IA.GSTFlag ,0)
				When 0 then @InvPrefix + Cast(IA.DocumentID as nVarchar)
				Else
					IsNULL(IA.GSTFullDocID,'')
				End as BillRef,
				C.CustomerID as OutletCode,
				IsNull(C.RCSOutletID, '') as RCSID,
				0 as RebateQty,
				0 as RebateValue,
				IA.NetValue as Amount,
				0 as SchemeID,
				Null as SchemeOutlet,
				Null as SchemeGroup,
				IA.DocReference
		From InvoiceAbstract IA (NoLock), Customer C (NoLock)
				Where IA.InvoiceType In (1,3,4)        
				And (IA.Status & 128)=0  
				And IA.CustomerID = C.CustomerID
				--And dbo.StripTimeFromDate(IA.InvoiceDate) Between @PayoutFrom And @PayoutTo
				And (Case IA.InvoiceType
						When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract (NoLock) Where DocumentID = 
						IA.DocumentID
						And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)--(Select dbo.mERP_fn_GetInvoiceDate(IA.InvoiceID, 1))
						Else dbo.StripTimeFromDate(IA.InvoiceDate)
						End) Between @ActiveFrom And @ActiveTo
				And (Case IA.InvoiceType
					When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract (NoLock) Where DocumentID = IA.DocumentID
						And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID) --(Select dbo.mERP_fn_GetInvoiceDate(IA.InvoiceID, 1))
					Else dbo.StripTimeFromDate(IA.InvoiceDate)
					End) Between @PayoutFrom And @PayoutTo
				And dbo.StripTimeFromDate(IA.CreationTime) <= @RedeemDate
--				And (Case IA.InvoiceType
--					When 3 Then dbo.StripTimeFromDate(IA.CreationTime)
--					When 1 Then dbo.StripTimeFromDate(IA.CreationTime)
--					When 4 Then @ActiveTo
--					End) <= @ExpiryDate


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
				Select InvoiceID, Sum(Amount), 
					Max(SchemeGroup) 
					From #RFAInfo 
					Where IsNull(SchemeOutlet, 0) = 0
					Group By InvoiceID
			Open SchemeCur
			Fetch Next From SchemeCur Into @InvoiceID, @Value, @SchemeGroup
			While (@@Fetch_Status = 0)
			Begin
				Select @PromotedQty = PromotedQty, @PromotedValue = PromotedValue, @RebateQty = RebateQty, @RebateValue = RebateValue
						From dbo.mERP_fn_GetPointsSchValue(@SchemeID, @SchemeGroup, @Qty, @Value,@UOM1Qty, @UOM2Qty,0)
				Update #RFAInfo Set PromotedQty = Case InvoiceType 
													When 4 Then (-1) * @PromotedQty
													Else @PromotedQty End, 
									PromotedValue = 
													Case InvoiceType
													When 4 Then (-1) * @PromotedValue
													Else @PromotedValue End,
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
					Select InvoiceID, Sum(Case InvoiceType 
										When 4 Then (-1) * (Amount)
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


				Update #RFAInfo Set 
--					PromotedValue =  Case InvoiceType
--												When 4 Then (-1)* (@PromotedValue/@SaleValue) * Amount
--												Else (@PromotedValue/@SaleValue) * Amount
--												End,
					PromotedValue = Case InvoiceType
							When 4 Then (-1) * ((SaleValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * @PromotedValue)
							Else ((SaleValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * @PromotedValue)
							End,
						TotalPoints = (@RebateQty/Case @SaleValue When 0 Then 1 Else @SaleValue End) * Amount,
						PointsValue = (@RebateValue/Case @SaleValue When 0 Then 1 Else @SaleValue End) * Amount
						Where IsNull(SchemeOutlet, 0) = 1 and OutletCode = @OutletCode

				Fetch Next From GroupCur Into @OutletCode, @SchemeGroup
			End
			Close GroupCur
			Deallocate GroupCur
			/*QPS - End*/
		End
		/*Apply Invoice based schemes - End*/

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
				From tbl_mERP_CSRedemption (NoLock)
				Where SchemeID = @SchemeID
				And PayoutID = @PayoutID
				And OutletCode = @CustomerID
				And RFAStatus = 1


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
							@InvoicePoints = Sum(TotalPoints),
							@InvoiceAmount = Sum(PointsValue)
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


--		Update #RFAInfo Set PromotedValue = Case IsNull(PromotedQty,0)
--										When 0 Then PromotedValue
--										Else IsNull(PromotedQty,0) * IsNull(SalePrice,0)
--										End	

		Update #RFAInfo Set RebateQty =  (-1) * RebateQty, RebateValue = (-1) * RebateValue,
							SaleQty = (-1) * SaleQty, SaleValue = (-1) * SaleValue
							Where InvoiceType = 4

		If @ApplicableOn = 'ITEM' Or @ApplicableOn = 'SPL_CAT'
		Begin

			If (Select Count(*) From #RFAInfo) >= 1
			Begin
				/*Select Abstract Data*/
				Select @WDCode as WDCode, @WDDest as WDDest, @SchemeType as SchemeType, @ActivityCode as ActivityCode, @ActivityType as ActivityDesc, @ActiveFrom as ActiveFrom, 
					@ActiveTo as ActiveTo, @PayoutFrom PayoutFrom, @PayoutTo as PayoutTo, Division, SubCategory,
					MarketSKU, SKUCode, UOM, Sum(SaleQty) as SaleQty, Sum(SaleValue) as SaleValue, Sum(PromotedQty) as PromotedQty,
					Sum(PromotedValue) as PromotedValue, FreeBaseUOM, Sum(RebateQty) as RebateQty, Sum(RebateValue) as RebateValue,
					0 as BudgetedQty, 0 as BudgetedValue, @ApplicableOn as AppOn
					From #RFAInfo
					Group By Division, SubCategory,	MarketSKU, SKUCode, UOM, FreeBaseUOM
					Order By SKUCode
				/*Select Detail Data*/
				Select  @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, @CSSchemeID as CompSchemeID, @ActivityType as ActivityDesc, 
					@PayoutFrom as ActiveFrom, @PayoutTo as ActiveTo, BillRef, OutletCode, RCSID, ActiveInRCS, LineType, --'MAIN' as LineType,
					Division, SubCategory, MarketSKU, SKUCode, UOM, Sum(SaleQty) as SaleQty, Sum(SaleValue) as SaleValue,
					Sum(PromotedQty) as PromotedQty, Sum(PromotedValue) as PromotedValue, Sum(RebateQty) as RebateQty,
					Sum(RebateValue) as RebateValue, 0 as PriceExclTax, Max(TaxCode) as TaxPercentage, 0 as TaxAmount, 0 as PriceInclTax,
					0 as BudgetedQty, 0 as BudgetedValue,Cust.Company_Name as 'OutletName',[Doc No],Max(Isnull(TOQ,0)) as TOQ
					From #RFAInfo,Customer Cust(NoLock)   
					Where Cust.CustomerID = #RFAInfo.OutletCode 
					Group By BillRef, OutletCode, RCSID, ActiveInRCS, Division, SubCategory, MarketSKU, SKUCode, UOM, LineType,Cust.Company_Name,[Doc No]
					Order By SKUCode		
			End
			Else
			Begin
				/*Abstract Data*/
				Select  @WDCode as WDCode, @WDDest as WDDest, @SchemeType as SchemeType, @ActivityCode as ActivityCode,
							@ActivityType as ActivityDesc, @ActiveFrom as ActiveFrom, @ActiveTo As ActiveTo, 
							@PayoutFrom as PayoutFrom, @PayoutTo as PayoutTo, Null as Division, Null as SubCategory,
							Null as MarketSKU, Null as SKUCode, Null as UOM, Null as SaleQty, Null as SaleValue,
							Null as PromotedQty, Null as PromotedValue, Null as FreeBaseUOM, Null as RebateQty, 
							Null as RebateValue, Null as BudgetedQty, Null as BudgetedValue, @ApplicableOn as AppOn
						
						
				/*Detail data*/
				Select  @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, @CSSchemeID As CompSchemeID,
							@ActivityType as ActivityDesc, @PayoutFrom as ActiveFrom, @PayoutTo As ActiveTo, Null as BillRef,
							Null as OutletCode, Null as RCSID, Null as ActiveInRCS, Null as LineType, Null as Division, Null as SubCategory, Null as MarketSKU,
							Null as SKUCode, Null as UOM, Null as SaleQty, Null as SaleValue, Null as PromotedQty, Null as PromotedValue,
							Null as RebateQty, Null as RebateValue, Null as PriceExclTax, Null as TaxPercentage, Null as TaxAmount,
							Null as PriceInclTax, Null as BudgetedQty, Null as BudgetedValue,Null as 'OutletName',Null as 'Doc No',Null as TOQ
			End
		End
		Else
		Begin
			If (Select Count(*) From #RFAInfo) >= 1
			Begin
				/*Abstract data*/
				Select  @WDCode as WDCode, @WDDest as WDDest, @SchemeType as SchemeType, @ActivityCode as ActivityCode, 
						@ActivityType as ActivityDesc, @ActiveFrom as ActiveFrom, @ActiveTo As ActiveTo, 
						@PayoutFrom as PayoutFrom, @PayoutTo As PayoutTo, 0 as SR,
						Division, SubCategory, MarketSKU, SKUCode, UOM, SaleQty as SaleQty,
						SaleValue as SaleValue, PromotedQty, Sum(IsNull(PromotedValue,0)) as PromotedValue, 
						FreeBaseUOM, Sum(IsNull(RebateQty,0)) as RebateQty, Sum(IsNull(RebateValue, 0)) as RebateValue, 
						0 as BudgetedQty, 0 as BudgetedValue, @ApplicableOn as AppOn
						From #RFAInfo
						Group By Division, SubCategory, MarketSKU, SKUCode, UOM, SaleQty,
						SaleValue, PromotedQty, FreeBaseUOM
				/*Detail data*/
				Select  @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, 
						@CSSchemeID as CompSchemeID, @ActivityType as ActivityDesc, 
						--@ActiveFrom as ActiveFrom, @ActiveTo As ActiveTo, 
						@PayoutFrom as ActiveFrom, @PayoutTo As ActiveTo, 0 as SR,
						BillRef, OutletCode, RCSID, ActiveInRCS, '' as LineType, 
						Division, SubCategory, MarketSKU, SKUCode, UOM, SaleQty as SaleQty,
						SaleValue as SaleValue, PromotedQty, PromotedValue, 
						FreeBaseUOM, RebateQty as RebateQty, Sum(IsNull(RebateValue, 0)) as RebateValue, 
						'' as PriceExclTax, Max(TaxPercentage) as TaxPercentage, '' as TaxAmount, '' as PriceInclTax,
						'' as BudgetedQty, '' as BudgetedValue,Cust.Company_Name as 'OutletName',[Doc No],Max(Isnull(TOQ,0)) AS TOQ
						From #RFAInfo,Customer Cust   
						Where Cust.CustomerID = #RFAInfo.OutletCode 
						Group By InvoiceID, OutletCode, RCSID, ActiveInRCS, Division, SubCategory, MarketSKU, SKUCode, UOM, SaleQty,
						SaleValue, PromotedQty, PromotedValue, FreeBaseUOM, RebateQty, BillRef ,Cust.Company_Name,[Doc No]
			End
			Else
			Begin
				/*Abstract Data*/
				Select  @WDCode as WDCode, @WDDest as WDDest, @SchemeType as SchemeType, @ActivityCode as ActivityCode,
							@ActivityType as ActivityDesc, @ActiveFrom as ActiveFrom, @ActiveTo As ActiveTo, 
							@PayoutFrom as PayoutFrom, @PayoutTo as PayoutTo,0 as SR, Null as Division, Null as SubCategory,
							Null as MarketSKU, Null as SKUCode, Null as UOM, Null as SaleQty, Null as SaleValue,
							Null as PromotedQty, Null as PromotedValue, Null as FreeBaseUOM, Null as RebateQty, 
							Null as RebateValue, Null as BudgetedQty, Null as BudgetedValue, @ApplicableOn as AppOn
						
						
				/*Detail data*/
				Select  @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, @CSSchemeID As CompSchemeID,
							@ActivityType as ActivityDesc, @PayoutFrom as ActiveFrom, @PayoutTo As ActiveTo,0 as SR, Null as BillRef,
							Null as OutletCode,Null as RCSID,Null as ActiveInRCS, Null as LineType, Null as Division, Null as SubCategory, Null as MarketSKU,
							Null as SKUCode, Null as UOM, Null as SaleQty, Null as SaleValue, Null as PromotedQty, Null as PromotedValue,
							Null as RebateQty, Null as RebateValue, Null as PriceExclTax, Null as TaxPercentage, Null as TaxAmount,
							Null as PriceInclTax, Null as BudgetedQty, Null as BudgetedValue,Null as 'OutletName',Null as 'Doc No',Null as TOQ
			End
		End
	End/*Points Scheme - End*/
	Else If @SchType = 6 Or @SchType = 7 Or @SchType = 8/*Damages (Or) Expiry (Or) Sampling - Start*/
	Begin

		Declare @ClaimType Int

		Set @ClaimID = @SchemeID

		If @SchType = 6 
		Begin
			Select @ClaimType = ClaimType, @ActivityCode = @ActCode,  --@ClaimsPrefix + Cast(DocumentID as nVarchar),
				@ActivityType = Case ClaimType 
							When 1 Then 'Expiry' 
							When 2 Then 'Damages' 
							When 3 Then 'Sampling' 
							End 
				From ClaimsNote(NoLock) Where ClaimID = @ClaimID And ClaimType In (2)

			Insert Into #RFAInfo(BillRef, Serial, SKUCode, SaleQty, SaleValue, SchemeID, SchemeDetail , SalvageQty, SalvageValue, 
				DamageDesc, DamageDate,SchemeFromDate,SchemeToDate,RebateValue,DamageOption) 
				Select '' as BillRef, 
				CD.Serial as Serial, 
				CD.Product_Code, 
				CD.Quantity, 
				--CD.Quantity * (CD.Rate + CD.Rate * (CD.TaxSuffPercent/100)) as SaleValue ,
				(select Case When @DandDRFATaxFlag = 0 Then Max(ddd.UOMTotalAmount) - Max(ddd.UOMTaxAmount) Else Max(ddd.UOMTotalAmount) End
						From DandDAbstract dda, DandDDetail ddd 
				where dda.ID=ddd.ID and dda.ClaimID=CN.ClaimID and ddd.product_Code=cd.Product_Code),
				CN.ClaimType as SchemeID,
				CD.Batch_Code as SchemeDetail, 
				0,0,
--				(Select SUM(IsNull(ddd.SalvageQuantity, 0)) From DandDAbstract dda, DandDDetail ddd 
--					Where dda.ID = ddd.ID And dda.ClaimID = CN.ClaimID And ddd.Product_Code = cd.Product_Code), 
--				(Select SUM(IsNull(ddd.SalvageValue, 0)) From DandDAbstract dda, DandDDetail ddd 
--					Where dda.ID = ddd.ID And dda.ClaimID = CN.ClaimID And ddd.Product_Code = cd.Product_Code), 
--				IsNull((Select 'Damages' + MAX(dda.Remarks) + ' From ' + MAX(IsNull(dda.FromMonth, '')) + ' To ' + MAX(IsNull(dda.ToMonth, ''))  
--								From DandDAbstract dda Where dda.ClaimID = CN.ClaimID), ''), 
				IsNull((Select 'Damages' + MAX(dda.RemarksDescription)  
								From DandDAbstract dda Where dda.ClaimID = CN.ClaimID), ''), 
--				IsNull((Select CONVERT(nVarchar(30), MAX(dda.ClaimDate), 103) 
--								From DandDAbstract dda Where dda.ClaimID = CN.ClaimID), '') ,				
				IsNull((Select CONVERT(nVarchar(30), MAX(dda.DestroyedDate), 103) 
								From DandDAbstract dda Where dda.ClaimID = CN.ClaimID), '') ,
				IsNull((Select case Max(dda.OptSelection) when 1 then CONVERT(nVarchar(30), MAX(dda.DayCloseDate), 103) Else CONVERT(nVarchar(30), MAX(dda.FromDate), 103) End
								From DandDAbstract dda Where dda.ClaimID = CN.ClaimID), '') ,
				IsNull((Select case Max(dda.OptSelection) when 1 then CONVERT(nVarchar(30), MAX(dda.DayCloseDate), 103) Else CONVERT(nVarchar(30), MAX(dda.ToDate), 103) End
								From DandDAbstract dda Where dda.ClaimID = CN.ClaimID), '') ,
			   (select Case When @DandDRFATaxFlag = 0 Then (Max(ddd.UOMTotalAmount) - Max(ddd.UOMTaxAmount))- Max(ddd.SalvageUOMValue) Else Max(ddd.UOMTotalAmount) - Max(ddd.SalvageUOMValue) End
						From DandDAbstract dda, DandDDetail ddd 
				where dda.ID=ddd.ID and dda.ClaimID=CN.ClaimID and ddd.product_Code=cd.Product_Code),
				(select Max(dda.OptSelection) From DandDAbstract dda where dda.ClaimID=CN.ClaimID )
				From ClaimsNote CN (NoLock), ClaimsDetail CD (NoLock)
				Where CN.ClaimID = @ClaimID
				And CN.ClaimID = CD.ClaimID
				And IsNull(CN.Status, 0) <= 1
				And IsNull(CN.ClaimRFA, 0) = 0
				And CN.ClaimType In(2) /*3 - Sampling, 1 - Expiry, 2 - Damages*/


				Declare @BatchCode int
				Declare @PCode nvarchar(256)
				Declare @SalesValue Decimal(18,6)
				Declare @SalesQty Decimal(18,6)
				Declare @RebateVal Decimal(18,6)
				Declare UpdateSalesValue Cursor For Select Distinct SKUCode,SchemeDetail,SaleValue,SaleQty,RebateValue from #RFAInfo
				Open UpdateSalesValue
				Fetch from UpdateSalesValue into @PCode,@BatchCode,@SalesValue,@SalesQty,@RebateVal
				While @@fetch_status=0
				BEGIN
					update R set Salevalue=T.SalValue From
					(Select (isnull(@SalesValue,0)/Sum(isnull(SaleQty,0)))*@SalesQty as SalValue,@BatchCode as BatchCode from #RFAInfo 
					where SKUCode=@PCode) T,#RFAInfo R
					Where T.BatchCode=R.SchemeDetail

					update R set RebateValue=T.RebateValue From
					(Select (isnull(@RebateVal,0)/Sum(isnull(SaleQty,0)))*@SalesQty as RebateValue,@BatchCode as BatchCode from #RFAInfo 
					where SKUCode=@PCode) T,#RFAInfo R
					Where T.BatchCode=R.SchemeDetail
					
					Fetch Next from UpdateSalesValue into @PCode,@BatchCode,@SalesValue,@SalesQty,@RebateVal
				END
				Close UpdateSalesValue
				Deallocate UpdateSalesValue

		End
		Else
		Begin
			Select @ClaimType = ClaimType, @ActivityCode = @ClaimsPrefix + Cast(DocumentID as nVarchar),
				@ActivityType = Case ClaimType 
							When 1 Then 'Expiry' 
							When 2 Then 'Damages' 
							When 3 Then 'Sampling' 
							End 
				From ClaimsNote(NoLock) Where ClaimID = @ClaimID And ClaimType In (1, 3)

			Insert Into #RFAInfo(BillRef, Serial, SKUCode, SaleQty, SaleValue, SchemeID, SchemeDetail) 
				Select '' as BillRef, 
				CD.Serial as Serial, 
				CD.Product_Code, 
				CD.Quantity, 
				CD.Quantity * (CD.Rate + CD.Rate * (CD.TaxSuffPercent/100)) as SaleValue ,
				CN.ClaimType as SchemeID,
				CD.Batch_Code as SchemeDetail
				From ClaimsNote CN (NoLock), ClaimsDetail CD(NoLock)
				Where CN.ClaimID = @ClaimID
				And CN.ClaimID = CD.ClaimID
				And IsNull(CN.Status, 0) <= 1
				And IsNull(CN.ClaimRFA, 0) = 0
				And CN.ClaimType In(1,3) /*3 - Sampling, 1 - Expiry, 2 - Damages*/
		End 
	


		
			/*Update SKU Category Levels and UOM - Start*/
			Declare UpdateLevelCur Cursor For 
				Select Distinct SKUCode From #RFAInfo
			Open UpdateLevelCur
			Fetch Next From UpdateLevelCur Into @SKUCode
			While (@@Fetch_Status = 0)
			Begin
				Select  @MarketSKU = Category_Name, @MarketSKUID = CategoryID, @SubCatID = ParentID  
				From ItemCategories(NoLock) Where CategoryID = (Select CategoryID From Items (NoLock) Where Product_Code = @SKUCode ) 		
				Select @SubCategory = Category_Name, @DivID = ParentID From ItemCategories (NoLock) Where CategoryID = @SubCatID
				Select @Divison = Category_Name From ItemCategories (NoLock) Where CategoryID = @DivID

				Select @UOM = Description From UOM (NoLock) Where UOM = (Select UOM From Items (NoLock) Where Product_Code = @SKUCode)
			
				Update #RFAInfo Set LineType = 'MAIN', Division = @Divison, SubCategory = @SubCategory, MarketSKU = @MarketSKU, UOM = @UOM 
				Where SKUCode = @SKUCode 

				Fetch Next From UpdateLevelCur Into @SKUCode
			End
			Close UpdateLevelCur
			Deallocate UpdateLevelCur

			
			/*Update SKU Category Levels and UOM - End*/
			Declare UpdateCur Cursor For
			Select Serial, SKUCode, SaleQty, SchemeDetail From #RFAInfo
			Open UpdateCur
			Fetch Next From UpdateCur Into @Serial, @SKUCode, @SaleQty, @SchemeDetail
			While (@@Fetch_Status = 0)
			Begin
				Select @Damage = Damage, @DocType = DocType, @DocID = DocID, 
					@PTR = Case @ActivityType 
						When 'Damages'	Then PTS
						Else PTR 
						End, 
					@TaxCode = IsNull(TaxSuffPercent, 0) 
					From Batch_Products BP(NoLock), ClaimsNote CN(NoLock), ClaimsDetail CD(NoLock)
					Where CN.ClaimID = @ClaimID
					And CN.ClaimID = CD.ClaimID
					And CD.Batch_Code = BP.Batch_Code
					And CD.Product_Code = @SKUCode
					Order By BP.Batch_Code Desc

				If @DocType = 1 And @Damage = 2 /*Damage from SR*/
				Begin
					Select @CustomerID = C.CustomerId, @RCSID = C.RCSOutletID, 
					--@DocumentID = IA.DocumentID 
					@GSTDocID = Case IsNULL(IA.GSTFlag ,0)
					When 0 then @InvPrefix + Cast(IA.DocumentID as nVarchar)
					Else
						IsNULL(IA.GSTFullDocID,'')
					End   
						From InvoiceAbstract IA (NoLock), Customer C (NoLock)
						Where IA.InvoiceID = @DocID
						And IA.CustomerID = C.CustomerID
					Update #RFAInfo Set OutletCode = @CustomerID,
						RCSID = @RCSID, 
						--BillRef = @InvPrefix + Cast(@DocumentID as nVarchar)  
						BillRef = @GSTDocID  
						Where SKUCode = @SKUCode And Serial = @Serial

			
--					Update #RFAInfo Set ActiveInRCS = IsNull(TMDValue,N'') 
--						From Cust_TMD_Master CTM, Cust_TMD_Details CTD	
--						Where CTM.TMDID = CTD.TMDID
--						And CTD.CustomerID = @CustomerID
--						And OutletCode = @CustomerID
			
					Update #RFAInfo 
						Set ActiveInRCS = (Case when IsNull(C.RCSOutletID,'') <> '' then 'Yes' else 'No' end)
					From  Customer C(NoLock)
					Where  C.CustomerID = #RFAInfo.OutletCode
					And #RFAInfo.OutletCode = @CustomerID
				End
				Else If @DocType = 2 And @Damage = 1 /*Damage from StkAdj*/
				Begin
					Select @DocumentID = DocumentID From StockAdjustmentAbstract (NoLock) Where AdjustmentID = @DocID
					Update #RFAInfo Set BillRef = @StkPrefix + Cast(@DocumentID as nVarchar) Where SKUCode = @SKUCode And Serial = @Serial
				End

				If @SchType = 7
					Select   @PTR = Max(IsNull(PTR, 0)), @TaxCode = Max(IsNull(TaxSuffered,0)) 
						From Batch_Products BP(NoLock), ClaimsNote CN(NoLock), ClaimsDetail CD(NoLock)
						Where CN.ClaimID =  @ClaimID
						And CD.Product_Code = @SKUCode
						And CD.Batch_Code = BP.Batch_Code
						And CD.Product_Code = BP.Product_Code
				Else If @SchType = 8
				Begin
					Select  @PTR = Max(IsNull(PTR, 0)), @TaxCode = Max(IsNull(TaxSuffPercent,0)) 
							From ClaimsNote CN(NoLock), ClaimsDetail CD(NoLock), Batch_Products BP(NoLock)
							Where CN.ClaimID = @ClaimID
							And CN.ClaimID = CD.ClaimID
							And CD.Product_Code = @SKUCode
							And CD.Product_Code = BP.Product_Code
							--And CD.PurchasePrice = BP.PurchasePrice
							And CD.Batch = BP.Batch_Number
					End

				
				--Update #RFAInfo Set PriceExclTax = @PTR, TaxPercentage = @TaxCode, TaxAmount = SaleQty*@PTR * (@TaxCode / 100),
				  Update #RFAInfo Set PriceExclTax = @PTR, TaxPercentage = @TaxCode,
						PriceInclTax = @PTR + (@PTR * (@TaxCode / 100)) Where SKUCode = @SKUCode And Serial = @Serial

				Fetch Next From UpdateCur Into @Serial, @SKUCode, @SaleQty, @SchemeDetail
			End
			Close UpdateCur
			Deallocate UpdateCur

			/* Update taxamount for each row */
			Update #RFAInfo Set TaxAmount = SaleQty * PriceExclTax * (TaxPercentage / 100)

	
				Create Table #TmpSalvageDetails(Product_code nvarchar(256) collate SQL_Latin1_General_CP1_CI_AS,SalvageQty decimal(18,6),SalvageValue decimal(18,6),UOM int)
				Insert into #TmpSalvageDetails(Product_code,SalvageQty,SalvageValue,UOM)
				Select distinct DD.Product_code,max(DD.SalvageQuantity),Max(DD.SalvageValue),Max(SalvageUOM) from DandDDetail DD, DandDAbstract DA where 
				DA.ID=DD.ID and DA.ClaimID=@ClaimID
				Group by DD.Product_code
				
--				
--				Declare @Product_code nvarchar(256)
--				Declare @SalvageQty Decimal(18,6)
--				Declare @SalvageValue Decimal(18,6)
--				Declare @SUOM int
--				Declare UpdateSalesValue Cursor For Select Product_code,SalvageQty,SalvageValue,UOM from #TmpSalvageDetails
--				Open UpdateSalesValue
--				Fetch from UpdateSalesValue into @Product_code,@SalvageQty,@SalvageValue,@SUOM
--				While @@fetch_status=0
--				BEGIN
--					update #TmpSalvageDetails set SalvageQty=Dbo.FN_Get_BaseUOMQty_DandDRFA(@Product_code,@SUOM,@SalvageQty)
--					where product_code=@Product_code
--					update #TmpSalvageDetails set SalvageValue=Dbo.FN_Get_BaseUOMQty_DandDRFA(@Product_code,@SUOM,@SalvageValue)
--					where product_code=@Product_code
--					Fetch Next from UpdateSalesValue into @Product_code,@SalvageQty,@SalvageValue,@SUOM
--				END
--				Close UpdateSalesValue
--				Deallocate UpdateSalesValue
				

					
			/*Abstract Data*/
			if @SchType = 6
			BEGIN

				Select  @WDCode as WDCode,  @WDDest as WDDest, Case @ActivityType 
																	When 'Expiry' Then 'Damages' 
																	Else 'Damages' End as SchemeType, @ActivityCode as ActivityCode,
						Case @ActivityType 
							When 'Expiry' Then 'Damages' 
							Else DamageDesc End as ActivityDesc, 
						Case @ActivityType When 'Damages' Then SchemeFromDate End as ActiveFrom, 
						Case @ActivityType When 'Damages' Then SchemeToDate End as ActiveTo, 
						Case @ActivityType When 'Damages' Then DamageDate End as PayoutFrom,
						Case @ActivityType When 'Damages' Then DamageDate End as PayoutTo, 
						Division, SubCategory, MarketSKU, SKUCode, #RFAInfo.UOM,Sum(SaleQty) as SaleQty, 
						Sum(SaleValue) as SaleValue, max(IsNull(T.SalvageQty, 0)) As SalvageQty, 
						max(IsNull(T.SalvageValue, 0)) As SalvageValue, 						
						Null as PromotedQty, Null as PromotedValue, Null as FreeBaseUOM,
						Null as RebateQty, sum(isnull(RebateValue,0)) as RebateValue, Null as BudgetedQty, Null as BudgetedValue, Null as AppOn,
						Case Max(DamageOption) when 1 then 'Day Close Date' Else 'Month Selection' End as DamageOption
					From #RFAInfo,#TmpSalvageDetails T
					Where T.Product_code =#RFAInfo.SKUCode
					Group By Division, SubCategory, MarketSKU, SKUCode, #RFAInfo.UOM, DamageDesc, DamageDate, SchemeFromDate,SchemeToDate
					Order by Division, SubCategory, MarketSKU, SKUCode, #RFAInfo.UOM, DamageDesc, DamageDate, SchemeFromDate,SchemeToDate  
			END
			Else
			BEGIN
				Select  @WDCode as WDCode,  @WDDest as WDDest, Case @ActivityType 
																When 'Expiry' Then 'Damages' 
																Else 'Damages' End as SchemeType, @ActivityCode as ActivityCode,
					Case @ActivityType 
						When 'Expiry' Then 'Damages' 
						Else DamageDesc End as ActivityDesc, 
					Case @ActivityType When 'Damages' Then DamageDate End as ActiveFrom, 
					Case @ActivityType When 'Damages' Then DamageDate End as ActiveTo, 
					Case @ActivityType When 'Damages' Then DamageDate End as PayoutFrom,
					Case @ActivityType When 'Damages' Then DamageDate End as PayoutTo, 
					Division, SubCategory, MarketSKU, SKUCode, UOM, Sum(SaleQty) as SaleQty, 
					Sum(SaleValue) as SaleValue, Sum(IsNull(SalvageQty, 0)) As SalvageQty, 
					Sum(IsNull(SalvageValue, 0)) As SalvageValue, Null as PromotedQty, Null as PromotedValue, Null as FreeBaseUOM,
					Null as RebateQty, Null as RebateValue, Null as BudgetedQty, Null as BudgetedValue, Null as AppOn
				From #RFAInfo
				Group By Division, SubCategory, MarketSKU, SKUCode, UOM, DamageDesc, DamageDate  
			END

			Drop Table #TmpSalvageDetails
			/* Damage*/
			if @SchType = 6
			BEGIN
				Select  NULL as WDCode, NULL as WDDest, NULL as ActivityCode, Null as CompSchemeID,
					NULL as ActivityDesc, Null as ActiveFrom, Null as ActiveTo, NULL as BillRef, NULL as OutletCode, 
					NULL as RCSId, NULL as ActiveInRCS, NULL as LineType, NULL as Division, NULL as SubCategory, NULL as MarketSKU, 
					NULL as SKUCode, NULL as UOM, NULL as SaleQty, 
					NULL as SaleValue, Null as PromotedQty, Null as PromotedValue, Null as RebateQty,
					Null as RebateValue, NULL as PriceExclTax, NULL as TaxPercentage, 
					NULL as TaxAmount, NULL as PriceInclTax, Null as BudgetedQty, Null as BudgetedValue,
					NULL as OutletName
			END
			ELSE
			BEGIN
				/*Detail Data*/
				Select  @WDCode as WDCode, @WDDest as WDDest, @ActivityCode as ActivityCode, Null as CompSchemeID,
					Case @ActivityType 
						When 'Expiry' Then 'Damages' 
						Else @ActivityType End as ActivityDesc, Null as ActiveFrom, Null as ActiveTo, BillRef, OutletCode, 
					RCSId, ActiveInRCS, LineType, Division, SubCategory, MarketSKU, SKUCode, UOM, Sum(SaleQty) as SaleQty, 
					Sum(SaleValue) as SaleValue, Null as PromotedQty, Null as PromotedValue, Null as RebateQty,
					Null as RebateValue, Max(PriceExclTax) as PriceExclTax, Max(TaxPercentage) as TaxPercentage, 
					Sum(TaxAmount) as TaxAmount, Max(PriceInclTax) as PriceInclTax, Null as BudgetedQty, Null as BudgetedValue,
					Cust.Company_Name as 'OutletName'
				From #RFAInfo, Customer Cust   
				Where Cust.CustomerID = #RFAInfo.OutletCode 
				Group by BillRef, OutletCode, RCSId, ActiveInRCS, LineType, Division, SubCategory, MarketSKU, SKUCode, UOM,Cust.Company_Name
			END
	End	

	/*Damages (Or) Expiry (Or) Sampling - End*/
	Drop Table #RFAInfo
	Drop Table #RFADetail
	Drop Table #RFAAbstract
	Drop table #temp
	Drop table #tmpRFAAbs
	Drop table #tmpRFADet
	Drop table #tmpFinalAbs
	Drop table #tmpFinalDet
	Drop table #tmpSKUWiseSales
	Drop table #TempFinal
	Drop table #tmpSales
	Drop table #tmpSerial
End
