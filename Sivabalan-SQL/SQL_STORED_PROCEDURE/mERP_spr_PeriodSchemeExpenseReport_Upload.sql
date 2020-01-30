Create Procedure mERP_spr_PeriodSchemeExpenseReport_Upload(@DateOrMonth as nVarchar(25), @UptoWeek nVarchar(50))
As
Begin
	Set Dateformat DMY

	Declare @Period as nVarchar(8)
	Declare @FromDate as DateTime
	Declare @ToDate as Datetime
	Declare @dtMonth Datetime
	Declare @MonthLastDate Datetime
	Declare @MonthFirstDate Datetime
	Declare @TillDate as Datetime
	Declare @Delimeter as nVarchar(1)
	Declare @Month nVarchar(25)
	Declare @RptDate Datetime
	Declare @LastInvoiceDate Datetime
	Declare @DaycloseDate as DateTime	
	
	Declare @SchemeID Int
	Declare @PayoutID Int
	Declare @QPS Int

	Declare @InvRebateValue Decimal(18,6)
	Declare @SRRebateValue Decimal(18,6)
	Declare @tmpInvoiceId Int
	Declare @TaxConfigFlag Int
	Declare @TaxConfigCrdtNote Int
	Declare @InvoiceID Int
	Declare @BillRef nVarchar(255)

	Declare @SchemeType Int
	Declare @ApplicableOn Int
	Declare @ItemGroup Int
	Declare @ItemFree Int

	Declare @CustomerID nVarchar(255)
	Declare @MarginPTR Decimal(18,6)
	Declare @SKUCode nVarchar(255)
	Declare @InvoiceRef nVarchar(255)

	Declare @RebateValue Decimal(18,6)
	Declare @RebateQty Decimal(18,6)
	Declare @TotRebateQty Decimal(18,6)

	Declare @ActiveFrom Datetime
	Declare @ActiveTo Datetime
	Declare @PayoutFrom Datetime
	Declare @PayoutTo Datetime
	Declare @RedeemDate datetime

	Declare @Qty Decimal(18,6)
	Declare @Value Decimal(18,6)
	Declare @InvoiceType Int
	Declare @UOMID Int
	Declare @PromotedQty Decimal(18,6)
	Declare @UOM1Qty Decimal(18,6)
	Declare @UOM2Qty Decimal(18,6)
	Declare @SaleValue Decimal(18,6)
	Declare @OutletCode nVarchar(255)
	Declare @PromotedValue Decimal(18,6)
	Declare @SaleQty Decimal(18,6)
	Declare @UOM1 Decimal(18,6)
	Declare @UOM2 Decimal(18,6)

	Declare @SchemeOutlet Int
	Declare @SchemeGroup Int	
	
	Set @Delimeter = Char(15)
	Declare @DayClosed int
	
	Declare @Monthint Int
	Declare @Yearint Int
	
	Declare @InvoiceActiveFrom Datetime
	Declare @InvoiceActiveTo Datetime

	Declare @WDCode NVarchar(255)  
	Declare @WDDest NVarchar(255)  
	Declare @CompaniesToUploadCode NVarchar(255)  
	  
	Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload    
	Select Top 1 @WDCode = RegisteredOwner From Setup      
	    
	If @CompaniesToUploadCode='ITC001'    
		Set @WDDest= @WDCode    
	Else    
	Begin    
		Set @WDDest= @WDCode    
		Set @WDCode= @CompaniesToUploadCode    
	End   

	/* Will be given in MM/YYYY Format */
	If @DateOrMonth = '' Or @DateOrMonth = '%'
		Set @Month = Right((Convert(nVarchar(10), @TillDate, 103)),7)
	Else if  Len(@DateOrMonth) > 7
		Set @Month = Right((Convert(nVarchar(10), @TillDate, 103)),7)
	Else if isDate(Cast(('01' + '/' + @DateOrMonth) as nVarchar(15))) = 0
		Set @Month = Right((Convert(nVarchar(10), @TillDate, 103)),7)
	Else
		Set @Month = Cast(@DateOrMonth as nVarchar(7))
		
	Set @DtMonth = cast(Cast('01' + '/' +  @Month as nVarchar(15)) as datetime)
	Select @Period = REPLACE(RIGHT(CONVERT(VARCHAR(11), @DtMonth, 106), 8), ' ', '-')

	set dateformat dmy
	Set @DtMonth = cast(Cast('01' + '/' +  @Month as nVarchar(15)) as datetime)
	Set @FromDate = Convert(nVarchar(10), @DtMonth, 103)
	
	If @UptoWeek = N'Week 1' 
		Begin
			Set @ToDate =  (Select DATEADD(s,-1,(DateAdd(DD, 7,  @FromDate))))
		End
	Else If @UptoWeek =  N'Week 2' 
		Begin
			Set @ToDate =  (Select DATEADD(s,-1,(DateAdd(dd, 14,  @FromDate))))
		End
	Else If @UptoWeek =  N'Week 3' 
		Begin
			Set @ToDate =  (Select DATEADD(s,-1,(DateAdd(dd, 21,  @FromDate))))
		End
	Else If @UptoWeek =  N'Week 4' or @UptoWeek = N'' Or @UptoWeek = N'%' 
		Begin
			Set @ToDate =  (Select DATEADD(s,-1,(DateAdd(MM, +1,  @DtMonth))))
		End
	If @ToDate > Convert(nVarchar(10), Getdate(), 103)
		Begin 
			Set @ToDate = Convert(nVarchar(10), Getdate(), 103)
		End

	Set @MonthLastDate = @ToDate
	Select @MonthFirstDate = @FromDate
	
	Select @Fromdate = dbo.StripTimeFromDate(@Fromdate), @ToDate= dbo.StripTimeFromDate(@ToDate)
	
	Select @Monthint = Month(@ToDate)
	Select @Yearint = Year(@ToDate)
		
	Select @DayClosed = 0
	IF (Select isNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') = 1
	Begin
		IF ((Select dbo.StripTimeFromDate(LastInventoryUpload) From Setup) >= @ToDate)
			Set @DayClosed = 1
	End	

	/* Report should be generated only if the last day of the month is Closed */
	IF @DayClosed = 0
		GoTo OvernOut

	--/* Report should not be executed if DC is running */
	--If exists (Select * From tbl_mERP_BackDtSchProcessInfo  where isnull(Active,0)=1)
	--	GoTo OvernOut

	/* Checking for Tax Configuration /
	Flag = 1 Include Tax 
	Flag = 0 Without Tax 
	For Rebate Value calculation for Free Item*/
	Select @TaxConfigFlag = IsNull(Flag, 0) From tbl_merp_ConfigAbstract 
	Where ScreenCode = 'RFA01'

	/* Tax Config flag for Credit Note */
	Select @TaxConfigCrdtNote = IsNull(Flag, 0) From tbl_merp_ConfigAbstract 
	Where ScreenCode = 'RFA02'

	Create Table #tmpScheme(SchemeID Int,PayoutID Int,QPS Int,SchemeType Int,ApplicableOn Int,ItemGroup Int,
		ActiveFrom Datetime,ActiveTo Datetime,PayoutFrom Datetime,PayoutTo Datetime)

	Create Table #tmpTradeScheme(SchemeID Int,PayoutID Int,QPS Int,SchemeType Int,ApplicableOn Int,ItemGroup Int,
		ActiveFrom Datetime,ActiveTo Datetime,PayoutFrom Datetime,PayoutTo Datetime, ItemFree int)		

	Create Table #tmpSales(SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
		SaleQty Decimal(18,6),SaleValue Decimal(18,6))
	
	Create Table #tmpDivisionWiseSales(Division nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS ,
		SalesQty Decimal(18,6),SalesValue Decimal(18,6))

	Create Table #RFAInfo(InvoiceID Int, OutletCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
		LineType nVarchar(50) collate SQL_Latin1_General_CP1_CI_AS, Division nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS ,
		SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
		UOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, SaleQty Decimal(18, 6), SaleValue Decimal(18, 6),
		PromotedQty Decimal(18, 6), PromotedValue Decimal(18, 6), 
		RebateQty Decimal(18, 6), RebateValue Decimal(18, 6),
		Amount Decimal(18, 6),SchemeID Int, SlabID Int,
		SalePrice Decimal(18,6),  UOM1Conv Decimal(18,6), UOM2Conv Decimal(18,6),
		InvoiceType Int, SchemeOutlet Int, SchemeSKU Int Default(0), SchemeGroup Int, TotalPoints Decimal(18,6), 
		PointsValue Decimal(18,6),TaxCode Decimal(18,6))

	Create Table #tmpTradeRFA(SchemeID Int,PayoutID Int,InvoiceID Int,
		SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
		SaleQty Decimal(18, 6), SaleValue Decimal(18, 6),
		PromotedQty Decimal(18, 6), PromotedValue Decimal(18, 6),
		RebateQty Decimal(18, 6), RebateValue Decimal(18, 6),InvoiceType Int,
		Division nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,LineType Int,
		CustomerID nVarchar(30) collate SQL_Latin1_General_CP1_CI_AS, Applicableon int, ItemFree int)

	Create Table #TmpSchemeItemFree(SchemeID Int, Applicableon int, ItemFree int)		

	/* Scheme Type - 1 Trade Scheme ,Scheme Type - 2 Point Scheme ,Scheme Type - 3 Display Scheme */
	Create table #tmpSchemeSale(SchemeType Int,SchemeID Int,PayoutID Int,QPS Int,
		Division nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,SaleQty Decimal(18,6),SaleValue Decimal(18,6),
		PromotedQty Decimal(18,6),PromotedValue Decimal(18,6),RebateQty Decimal(18,6),RebateValue Decimal(18,6))
	
	Create Table #tmpFinal([SchemeType] Int,[WD Code] nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
		[WD Dest] nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,FromDate Datetime,ToDate Datetime,
		Division nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
		[Activity Code] nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
		[Activity Desc] nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
		[Level] nVarchar(15) collate SQL_Latin1_General_CP1_CI_AS,
		[Scheme Type] nVarchar(50) collate SQL_Latin1_General_CP1_CI_AS,
		QPS nvarchar(10) collate SQL_Latin1_General_CP1_CI_AS,
		[Scheme From] Datetime,[Scheme To] Datetime,[Payout_From] Datetime,[Payout_To] Datetime,
		[Sales Qty] Decimal(18,6),[Sales Value] Decimal(18,6),
		[Promoted Qty] Decimal(18,6),[Promoted Value] Decimal(18,6),
		[Rebate Qty] Decimal(18,6),[Rebate Value] Decimal(18,6), [RFA Applicable] nvarchar(10))

	/* To Insert Pending Trade scheme */
	Insert Into #tmpTradeScheme(SchemeID,PayoutID,QPS,SchemeType,ApplicableOn,ItemGroup,ActiveFrom,ActiveTo,PayoutFrom,PayoutTo)
	Select Distinct SA.SchemeID,0,SO.QPS,SA.SchemeType,
	SA.ApplicableOn,
	--SA.RFAApplicable,
	SA.ItemGroup,
	dbo.StripTimeFromDate(SA.ActiveFrom),dbo.StripTimeFromDate(SA.ActiveTo),
	Null, Null
	--dbo.StripTimeFromDate(SPP.PayoutPeriodFrom),dbo.StripTimeFromDate(SPP.PayoutPeriodTo)
	From tbl_mERP_SchemeAbstract SA  , (select Distinct SchemeId, QPS  From tbl_mERP_SchemeOutlet) SO  --, tbl_mERP_SchemePayoutPeriod SPP  
	Where 
		SA.SchemeID = SO.SchemeID		
		And SA.Active = 1
		And SA.SchemeType In(1,2)	
		And SO.QPS In(0)
		And (SA.ActiveFrom <= @ToDate and SA.ActiveTo >= @FromDate)
	--Order By SA.SchemeID

/* Removing Point Scheme from Report */

	--/* To Insert Pending & submitted Points scheme */
	--Insert Into #tmpScheme(SchemeID,PayoutID,QPS,SchemeType,ApplicableOn,ItemGroup,ActiveFrom,ActiveTo,PayoutFrom,PayoutTo)
	--Select Distinct SA.SchemeID,SPP.ID,SO.QPS,SA.SchemeType,SA.ApplicableOn,SA.ItemGroup,
	--dbo.StripTimeFromDate(SA.ActiveFrom),dbo.StripTimeFromDate(SA.ActiveTo),
	--dbo.StripTimeFromDate(SPP.PayoutPeriodFrom),dbo.StripTimeFromDate(SPP.PayoutPeriodTo)
	--From tbl_mERP_SchemeAbstract SA, (select Distinct SchemeId, QPS  From tbl_mERP_SchemeOutlet) SO, tbl_mERP_SchemePayoutPeriod SPP  
	--Where SA.SchemeID = SO.SchemeID  
	--And SA.Active = 1
	--And SA.SchemeType In(4)
	--And SO.QPS In(0 ,1)
	----And isNull(SA.RFAApplicable,0) = 1
	--And SA.SchemeID = SPP.SchemeID  
	--And SPP.Active = 1
	--And Year(dbo.StripTimeFromDate(SPP.PayoutPeriodTo)) = @Yearint
	--And Month(dbo.StripTimeFromDate(SPP.PayoutPeriodTo)) = @Monthint
	--And dbo.StripTimeFromDate(SPP.PayoutPeriodTo) <= @ToDate
	--And @ToDate Between SA.ActiveFrom and SA.ActiveTo 
	----And SA.SchemeID in(0)
	----Order By SA.SchemeID
	
	--Select @InvoiceActiveFrom = Min(ActiveFrom) From #tmpScheme
	--Select @InvoiceActiveTo = Max(ActiveTo) From #tmpScheme
		
	--Select InvoiceID,InvoiceType,dbo.StripTimeFromDate(InvoiceDate) InvoiceDate,CustomerID,BillingAddress,ShippingAddress,UserName,GrossValue,
	--	DiscountPercentage,DiscountValue,NetValue,dbo.StripTimeFromDate(CreationTime) CreationTime,[Status],TaxLocation,InvoiceReference,ReferenceNumber,
	--	AdditionalDiscount,Freight,CreditTerm,PaymentDate,DocumentID,NewReference,NewInvoiceReference,OriginalInvoice,
	--	ClientID,Memo1,Memo2,Memo3,MemoLabel1,MemoLabel2,MemoLabel3,Flags,ReferredBy,Balance,SalesmanID,BeatID,PaymentMode,
	--	PaymentDetails,ReturnType,Salesman2,DocReference,AmountRecd,AdjRef,AdjustedAmount,GoodsValue,AddlDiscountValue,
	--	TotalTaxSuffered,TotalTaxApplicable,ProductDiscount,RoundOffAmount,AdjustmentValue,Denominations,ServiceCharge,
	--	BranchCode,CFormNo,DFormNo,CancelDate,VanNumber,TaxOnMRP,DocSerialType,SchemeID,SchemeDiscountPercentage,
	--	SchemeDiscountAmount,ClaimedAmount,ClaimedAlready,ExciseDuty,DiscountBeforeExcise,SalePriceBeforeExcise,
	--	CustomerPoints,VatTaxAmount,SONumber,GroupID,DeliveryStatus,DeliveryDate,InvoiceSchemeID,MultipleSchemeDetails,
	--	TaxDiscountFlag,DSTypeID,AmendReasonID,CancelReasonID,CancelUser,FromStateCode,ToStateCode,GSTIN,GSTFlag,GSTDocID,
	--	GSTFullDocID,AlternateCGCustomerName,SRInvoiceID,SRHH_Reference
	--Into #TmpInvoiceAbstract From InvoiceAbstract
	--Where dbo.StripTimeFromDate(InvoiceDate) Between @InvoiceActiveFrom and  @InvoiceActiveTo	
	
	--Select * Into #TmpInvoiceDetail From InvoiceDetail Where InvoiceID in(Select InvoiceID From #TmpInvoiceAbstract)

/* Removing Point Scheme from Report */
	
	Select InvoiceID,CustomerID,SchemeID,BillRef,DocID,InvoiceType,Product_Code,[Type],SlabID,InvoiceDate,
		SaleQty,SaleValue,RebateQty,RebateValue,RebateValue_Tax,PromotedQty,PromotedValue,RebateUOM,PromotedUOM,
		PriceExclTax,TaxPercent,TaxAmount,PriceInclTax,Serial,PrimarySerial,FreeSerial,
		dbo.StripTimeFromDate(OriginalInvDate) OriginalInvDate,DayCloseDate,CreationDate,TOQ 
	Into #Tmptbl_merp_NonQPSData
	From tbl_merp_NonQPSData
	Where dbo.StripTimeFromDate(OriginalInvDate) Between @FromDate and @ToDate	
		
	Insert Into #TmpSchemeItemFree(SchemeID, Applicableon, ItemFree)
	Select Sch.SchemeID, Tmp.Applicableon, Case Max(Sch.SlabType) When 1 Then 0 When 2 Then 0 Else 1 End as ItemFree From tbl_mERP_SchemeSlabDetail Sch
	Inner Join #tmpTradeScheme TMP ON SCH.SchemeID = TMP.SchemeID		
	Group By Sch.SchemeID, Tmp.Applicableon		

		
	Insert Into #tmpTradeRFA (SchemeID ,PayoutID ,InvoiceID,SKUCode,PromotedQty, PromotedValue,	RebateQty, RebateValue,
	InvoiceType, LineType, SaleQty, SaleValue)
	Select  SchemeID,0,NQD.InvoiceID, NQD.Product_Code,PromotedQty, PromotedValue,
	RebateQty,Case @TaxConfigFlag When 1 Then RebateValue_Tax Else RebateValue End,
	InvoiceType,Case [Type]	When 1 Then 1 Else 0 End,
	SaleQty, SaleValue
	From #Tmptbl_merp_NonQPSData NQD 
	Where 
	--NQD.SchemeID = @SchemeID
	NQD.SchemeID in(Select SchemeID From #tmpTradeScheme)
	And NQD.OriginalInvDate Between @FromDate and @ToDate
	And NQD.InvoiceType in (1,3)
	--dbo.StripTimeFromDate(SPP.PayoutPeriodFrom) And dbo.StripTimeFromDate(SPP.PayoutPeriodTo)
	--Order By NQD.InvoiceID, NQD.SchemeID, NQD.Product_Code			
	union
	Select  NQD.SchemeID,0,NQD.InvoiceID, NQD.Product_Code,PromotedQty, PromotedValue,
	RebateQty,Case @TaxConfigFlag When 1 Then RebateValue_Tax Else RebateValue End,
	InvoiceType,Case [Type]	When 1 Then 1 Else 0 End,
	SaleQty, SaleValue
	From #Tmptbl_merp_NonQPSData NQD
	Where 
	--NQD.SchemeID = @SchemeID
	NQD.SchemeID in(Select SchemeID From #tmpTradeScheme)
	And NQD.OriginalInvDate Between @FromDate and @ToDate
	And NQD.InvoiceType not in (1,3)
	And dbo.StripTimeFromDate(NQD.OriginalInvDate) 
	<= (select dbo.StripTimeFromDate(activeTo) from tbl_mERP_SchemeAbstract SPP where NQD.SchemeID=SPP.SchemeID)
	
	Order By NQD.InvoiceID, NQD.SchemeID, NQD.Product_Code			
	
	Update RFA Set Division = IC2.Category_Name 
	From  #tmpTradeRFA RFA,Items I , ItemCategories IC, ItemCategories IC1,ItemCategories IC2
	Where RFA.SKUCode = I.Product_Code And
	I.CategoryID = IC.CategoryID And
	IC.ParentID = IC1.CategoryID And
	IC1.ParentID = IC2.CategoryID

	Update #tmpTradeRFA Set SaleQty = isNull(SaleQty,0),SaleValue = isNull(SaleValue,0),
	PromotedQty = isNull(PromotedQty,0),PromotedValue = isNull(PromotedValue,0),
	RebateQty = isNull(RebateQty,0),RebateValue=isNull(RebateValue,0)				

					
	Update #tmpTradeRFA Set Applicableon = 0, ItemFree = 0
	
	Update RFA Set RFA.Applicableon = TMP.Applicableon, RFA.ItemFree = TMP.ItemFree
	From #tmpTradeRFA RFA, #TmpSchemeItemFree TMP
	Where RFA.SchemeID = TMP.SchemeID
	
	Insert Into #tmpSchemeSale(SchemeType,SchemeID,PayoutID,QPS,Division,SaleQty,SaleValue,
	PromotedQty,PromotedValue,RebateQty,RebateValue)
	Select 1,RFA.SchemeID,RFA.PayoutID,1,RFA.Division,Sum(RFA.SaleQty),Sum(RFA.SaleValue),
	Sum(RFA.PromotedQty),Sum(RFA.PromotedValue),Sum(RFA.RebateQty),Sum(RFA.RebateValue)
	From #tmpTradeRFA RFA
	Where 
		RFA.LineType = 1 and (RFA.ApplicableOn = 2 And RFA.ItemFree = 1)
	Group By RFA.SchemeID,RFA.PayoutID,RFA.Division				
	
	Insert Into #tmpSchemeSale(SchemeType,SchemeID,PayoutID,QPS,Division,SaleQty,SaleValue,
	PromotedQty,PromotedValue,RebateQty,RebateValue)
	Select 1,RFA.SchemeID,RFA.PayoutID,1,RFA.Division,Sum(RFA.SaleQty),Sum(RFA.SaleValue),
	Sum(RFA.PromotedQty),Sum(RFA.PromotedValue),Sum(RFA.RebateQty),Sum(RFA.RebateValue)
	From #tmpTradeRFA RFA					
	Where					
		RFA.LineType = 0 and (RFA.ApplicableOn <> 2 or RFA.ItemFree <> 1)
	Group By RFA.SchemeID,RFA.PayoutID,RFA.Division											

--/* Points Scheme Starts */

--	Declare ShemeCursor Cursor For
--	Select Distinct SchemeID,PayoutID,QPS,SchemeType,ApplicableOn,ItemGroup,ActiveFrom,ActiveTo,PayoutFrom,PayoutTo  From #tmpScheme
--	Open ShemeCursor
--	Fetch From ShemeCursor Into @SchemeID,@PayoutID,@QPS,@SchemeType,@ApplicableOn,@ItemGroup,@ActiveFrom,@ActiveTo,@PayoutFrom,@PayoutTo
--	While @@Fetch_Status = 0
--	Begin		
--		Truncate Table #RFAInfo
	
--		IF @SchemeType = 4 /*Points Scheme Starts*/
--		Begin
--			Select @RedeemDate = dbo.StripTimeFromDate(Max(CreationDate)) From tbl_mERP_CSRedemption 
--			Where PayoutID = @PayoutID
--			And IsNull(RFAStatus,0) = 1

--			Set @RedeemDate =  (Case when IsNull(@RedeemDate,'') <> '' then @RedeemDate else  '01/01/2099' end)
--			If @ApplicableOn = 1 And (@ItemGroup = 1 Or @ItemGroup = 2)/* Item or spl category scheme*/
--			Begin
--				Insert Into #RFAInfo(InvoiceID, OutletCode, LineType, Division,SKUCode, UOM, SaleQty, SaleValue, 
--									PromotedQty, PromotedValue, RebateQty, RebateValue,
--									UOM1Conv, UOM2Conv, SalePrice, InvoiceType, SchemeOutlet, SchemeGroup)
--				Select IA.InvoiceID, C.CustomerID, 0,Null as Division,
--				ID.Product_Code as SKUCode, Null as UOM, Sum(ID.Quantity) as SaleQty, 
--				Sum(ID.Amount) as SaleValue, 0 as PromotedQty, 0 as PromotedValue, 0 as RebateQty, 0 as RebateValue,
--				0 as UOM1Conv, 0 as UOM2Conv, ID.SalePrice as SalePrice, IA.InvoiceType,
--				Null as SchemeOutlet, Null as SchemeGroup
--				From #TmpInvoiceAbstract IA, #TmpInvoiceDetail ID, Customer C 
--				Where (Case IA.InvoiceType
--						When 3 Then (Select Min(InvoiceDate) From #TmpInvoiceAbstract Where DocumentID = 
--						IA.DocumentID
--						And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)
--						Else IA.InvoiceDate
--						End) Between @ActiveFrom And @ActiveTo
--					And (Case IA.InvoiceType
--						When 3 Then (Select Min(InvoiceDate) From #TmpInvoiceAbstract Where DocumentID = IA.DocumentID
--							And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)
--						Else IA.InvoiceDate 
--						End) Between @PayoutFrom And @PayoutTo
--					And IA.CreationTime <= @RedeemDate
--				And IA.InvoiceType In (1,3,4)
--				And IA.Status & 128 = 0 
--				And IA.InvoiceID = ID.InvoiceID
--				And IsNull(ID.Flagword, 0) = 0
--				And IA.CustomerID = C.CustomerID
--				Group By IA.InvoiceID, C.CustomerID,  ID.Product_Code,
--				IA.InvoiceType, ID.SalePrice
--				Order By IA.InvoiceID

--				Declare SchemeOutletCur Cursor For
--				Select Distinct OutletCode From #RFAInfo
--				Open SchemeOutletCur
--				Fetch Next From SchemeOutletCur Into @CustomerID
--				While (@@Fetch_Status = 0)			
--				Begin
--					Select @SchemeOutlet = QPS, @SchemeGroup = GroupID From dbo.mERP_fn_CheckSchemeOutlet(@SchemeID, @CustomerID)
					
--					Update #RFAInfo Set SchemeOutlet = @SchemeOutlet, SchemeGroup = @SchemeGroup 
--						Where OutletCode = @CustomerID					

--					Fetch Next From SchemeOutletCur Into @CustomerID
--				End
--				Close SchemeOutletCur
--				Deallocate SchemeOutletCur

--				Delete From #RFAInfo Where IsNull(SchemeOutlet, 0) = 2

--				/* Update Division , Market sku ,And Sub Category */
--				Update RFA Set Division = IC2.Category_Name,UOM = U.Description,
--				UOM1conv = I.UOM1_Conversion,UOM2conv = I.UOM2_Conversion
--				From #RFAInfo RFA,Items I , ItemCategories IC, ItemCategories IC1,ItemCategories IC2,UOM U
--				Where RFA.SKUCode = I.Product_Code And
--				I.CategoryID = IC.CategoryID And
--				IC.ParentID = IC1.CategoryID And
--				IC1.ParentID = IC2.CategoryID And
--				I.UOM = U.UOM

--				/* Update  SchemeSKU  = 1 For Items which comes in any of the Product Scope of the scheme */
--				Update #RFAInfo Set SchemeSKU = 1 
--				Where SKUCode In(Select Product_Code From dbo.mERP_fn_Get_CSSku(@SchemeID))

--				Delete From #RFAInfo Where IsNull(SchemeSKU, 0) = 0

--				If @QPS = 0 /*Non QPS Starts*/
--				Begin
--					If @ItemGroup = 1 /*Other than SplCategory scheme(Non QPS) - Start*/
--					Begin						
--						Declare SKUCur Cursor For 
--						Select InvoiceID, InvoiceType, SchemeGroup, SKUCode, Sum(SaleQty), 
--						Sum(SaleValue),UOM1Conv,UOM2Conv
--						From #RFAInfo
--						Where IsNull(SchemeOutlet, 0) = 0
--						Group By InvoiceID, InvoiceType, SchemeGroup, SKUCode, UOM1Conv, UOM2Conv, InvoiceType
--						Open SKUCur
--						Fetch Next From SKUCur Into @InvoiceID, @InvoiceType, @SchemeGroup, @SKUCode, @Qty, @Value, @UOM1, @UOM2
--						While (@@Fetch_Status = 0)
--						Begin
--							Set @UOM1Qty = 0
--							Set @UOM2Qty = 0
--							Set @SaleValue = 0
--							Set @UOM1Qty = IsNull((@Qty/@UOM1), 0)
--							Set @UOM2Qty = IsNull((@Qty/@UOM2), 0)
--							Set @SaleValue = @Value

--							Select @PromotedQty = PromotedQty, @PromotedValue = PromotedValue, 
--							@RebateQty = RebateQty, @RebateValue = RebateValue, @UOMID = UOM
--							From dbo.mERP_fn_GetPointsSchValue(@SchemeID, @SchemeGroup, @Qty, @SaleValue,@UOM1Qty, @UOM2Qty,0)
														
--							Update #RFAInfo Set PromotedQty = Case InvoiceType
--										When 4 Then (-1) * (Case @UOMID When 2 Then @PromotedQty * UOM1Conv
--																		When 3 Then @PromotedQty * UOM2Conv
--																		Else @PromotedQty End)
--										Else (Case @UOMID When 2 Then @PromotedQty * UOM1Conv
--																		When 3 Then @PromotedQty * UOM2Conv
--																		Else @PromotedQty End)
--										End, 
--										PromotedValue = Case InvoiceType 
--										When 4 Then (-1) * @PromotedValue
--										Else @PromotedValue End,
--										TotalPoints = @RebateQty,
--										PointsValue = @RebateValue
--							Where InvoiceID = @InvoiceID And SKUCode = @SKUCode 

--							Fetch Next From SKUCur Into @InvoiceID, @InvoiceType, @SchemeGroup, @SKUCode, @Qty, @Value, @UOM1, @UOM2
--						End
--						Close SKUCur
--						Deallocate SKUCur
					
--					End /*Other than SplCategory scheme - End*/
--					Else If @ItemGroup = 2 /*Spl.Category schemes - Start*/
--					Begin 
--						Declare InvoiceCur Cursor For 
--						Select Distinct InvoiceID, InvoiceType, SchemeGroup
--						From #RFAInfo
--						Where IsNull(SchemeOutlet, 0) = 0
--						Open InvoiceCur
--						Fetch Next From InvoiceCur Into @InvoiceID, @InvoiceType, @SchemeGroup
--						While (@@Fetch_Status = 0)
--						Begin
--							Set @UOM1Qty = 0
--							Set @UOM2Qty = 0
--							Set @SaleValue = 0
--							Set @SaleQty = 0
--							/*To get cumulative value of items per invoice to apply scheme*/
--							Declare SKUCur Cursor For
--								Select SKUCode, Sum(SaleQty), 
--								--Sum(SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))), 
--								Sum(SaleValue),
--								Max(UOM1Conv), Max(UOM2Conv)
--								From #RFAInfo
--								Where InvoiceID = @InvoiceID
--								And InvoiceType = @InvoiceType
--								And SchemeGroup = @SchemeGroup
--								Group By SKUCode
--							Open SKUCur
--							Fetch Next From SKUCur Into @SKUCode, @Qty, @Value, @UOM1, @UOM2
--							While @@Fetch_Status = 0
--							Begin
--								Set @UOM1Qty = @UOM1Qty + IsNull((@Qty/@UOM1), 0)
--								Set @UOM2Qty = @UOM2Qty + IsNull((@Qty/@UOM2), 0)
--								Set @SaleQty = @SaleQty + @Qty
--								Set @SaleValue = @SaleValue + @Value
--								Fetch Next From SKUCur Into @SKUCode, @Qty, @Value, @UOM1, @UOM2
--							End
--							Close SKUCur
--							Deallocate SKUCur

--							Select @PromotedQty = PromotedQty, @PromotedValue = PromotedValue,
--								@RebateQty = RebateQty, @RebateValue = RebateValue, @UOMID = UOM
--								From dbo.mERP_fn_GetPointsSchValue(@SchemeID, @SchemeGroup, @SaleQty, @SaleValue,@UOM1Qty, @UOM2Qty,1)

--							/*Update SKU wise PromotedQty Or PromotedValue*/
--							Update #RFAInfo Set PromotedQty = Case InvoiceType
--											When 4 Then (-1) * ((Case @UOMID When 2 Then @PromotedQty * UOM1Conv
--														When 3 Then @PromotedQty * UOM2Conv
--														Else @PromotedQty End)/@SaleQty) * SaleQty 
--											Else ((Case @UOMID When 2 Then @PromotedQty * UOM1Conv
--														When 3 Then @PromotedQty * UOM2Conv
--														Else @PromotedQty End)/@SaleQty) * SaleQty
--											End,
--								PromotedValue = Case InvoiceType
--											When 4 Then (-1) * ((SaleValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * @PromotedValue)
--											Else ((SaleValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * @PromotedValue)
--										End,
--								TotalPoints = (@RebateQty / @SaleQty) * SaleQty,
--								PointsValue = (@RebateValue / @SaleQty) * SaleQty
--								Where InvoiceID = @InvoiceID

--						Fetch Next From InvoiceCur Into @InvoiceID, @InvoiceType, @SchemeGroup
--						End
--						Close InvoiceCur
--						Deallocate InvoiceCur
--					End /*Spl.Category schemes - End*/
--				End	/*Non QPS Ends*/
--				Else /*QPS Starts*/
--				Begin
--					If @ItemGroup = 1 /*Other than SplCategory scheme(QPS) - Start*/
--					Begin
--						Declare OutletCur Cursor for
--						Select Distinct OutletCode from #RFAInfo where IsNull(SchemeOutlet, 0) = 1
--						Open OutletCur
--						Fetch Next from OutletCur Into @OutletCode
--						While @@Fetch_Status = 0
--						Begin
--							Declare SKUCur Cursor For	
--							Select Distinct SKUCode 
--							From #RFAInfo
--							Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1
--							Open SKUCur
--							Fetch Next From SKUCur Into @SKUCode
--							While @@Fetch_Status = 0
--							Begin
--								Set @UOM1Qty = 0
--								Set @UOM2Qty = 0
--								Set @SaleValue = 0
--								Set @SaleQty = 0
--								Declare QPSSKUCur Cursor For 
--									Select InvoiceID, SchemeGroup, SKUCode, Sum(SaleQty), 
--									--Sum(SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))), 
--									Sum(SaleValue),
--									UOM1Conv,UOM2Conv
--									From #RFAInfo
--									Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1
--									And SKUCode = @SKUCode
--									Group By InvoiceID, SchemeGroup,SKUCode, UOM1Conv, UOM2Conv
--								Open QPSSKUCur
--								Fetch Next From QPSSKUCur Into @InvoiceID, @SchemeGroup, @SKUCode, @Qty, @Value, @UOM1, @UOM2
--								While (@@Fetch_Status = 0)
--								Begin
--									Set @UOM1Qty = @UOM1Qty + IsNull((@Qty/@UOM1), 0)
--									Set @UOM2Qty = @UOM2Qty + IsNull((@Qty/@UOM2), 0)
--									Set @SaleQty = @SaleQty + @Qty
--									Set @SaleValue = @SaleValue + @Value
--									Fetch Next From QPSSKUCur Into @InvoiceID, @SchemeGroup, @SKUCode, @Qty, @Value, @UOM1, @UOM2
--								End
--								Close QPSSKUCur
--								Deallocate QPSSKUCur

--								Select @PromotedQty = PromotedQty, @PromotedValue = PromotedValue,
--										@RebateQty = RebateQty, @RebateValue = RebateValue, @UOMID = UOM
--										From dbo.mERP_fn_GetPointsSchValue(@SchemeID, @SchemeGroup, @SaleQty, @SaleValue,@UOM1Qty, @UOM2Qty,0)
								
--								Update #RFAInfo Set PromotedQty = Case InvoiceType
--													When 4 Then (-1) * ((Case @UOMID When 2 Then @PromotedQty * UOM1Conv
--																When 3 Then @PromotedQty * UOM2Conv
--																Else @PromotedQty End)/@SaleQty) * SaleQty 
--													Else ((Case @UOMID When 2 Then @PromotedQty * UOM1Conv
--																When 3 Then @PromotedQty * UOM2Conv
--																Else @PromotedQty End)/@SaleQty) * SaleQty
--													End,
--									PromotedValue = Case InvoiceType
--										When 4 Then (-1) * ((SaleValue /Case @SaleValue When 0 Then 1 Else @SaleValue End) * @PromotedValue)
--										Else ((SaleValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * @PromotedValue)
--										End,

--									TotalPoints = ((@RebateQty / @SaleQty) * SaleQty),
--									PointsValue = ((@RebateValue / @SaleQty) * SaleQty)
--									Where OutletCode=@OutletCode and SKUCode = @SKUCode
--									And IsNull(SchemeOutlet, 0) = 1
--								Fetch Next From SKUCur Into @SKUCode
--							End					
--							Close SKUCur
--							Deallocate SKUCur
--							Fetch Next From OutletCur Into @OutletCode
--						End					
--						Close OutletCur
--						Deallocate OutletCur
--					End /*Other than SplCategory scheme(QPS) - End*/
--					Else If  @ItemGroup = 2
--					Begin /*SplCategory scheme(QPS) - Start*/

--						Declare GroupCur Cursor For
--						Select Distinct SchemeGroup,OutletCode From #RFAInfo
--						Where IsNull(SchemeOutlet, 0) = 1
						
--						Open GroupCur
--						Fetch Next From GroupCur Into @SchemeGroup,@OutletCode
--						While (@@Fetch_Status = 0)
--						Begin
--							Select @SaleQty = Sum( (case when invoicetype =4 then -SaleQty else SaleQty end)), 
--							@SaleValue = Sum((Case When Invoicetype = 4 then (SaleValue * -1) Else (SaleValue) end)),  
--							@UOM1Qty = Sum((case when InvoiceType = 4 then (SaleQty*-1) else (SaleQty) end)/UOM1Conv), 
--							@UOM2Qty = Sum((Case When InvoiceType=4 then (SaleQty *-1) else (SaleQty) end)/UOM2Conv)
--							From #RFAInfo
--							Where OutletCode=@OutletCode and IsNull(SchemeOutlet, 0) = 1
--							And IsNull(SchemeGroup, 0) = @SchemeGroup
							
--							Select @PromotedQty = PromotedQty, @PromotedValue = PromotedValue, @UOMID = UOM,
--							@RebateQty = RebateQty, @RebateValue = RebateValue
--							From dbo.mERP_fn_GetPointsSchValue(@SchemeID, @SchemeGroup, @SaleQty, @SaleValue,@UOM1Qty, @UOM2Qty,1)
							
--							If @UOMID = 1
--								Update #RFAInfo Set PromotedQty = Case @SaleQty When 0 Then 0 Else 
--                                                    (Case InvoiceType 
--													When 4 Then (-1) * (@PromotedQty / @SaleQty) * SaleQty 
--													Else (@PromotedQty / @SaleQty) * SaleQty 
--													End) End,
--													PromotedValue = Case InvoiceType
--													When 4 Then (-1) * (@PromotedValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
--													Else (@PromotedValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))) 
--													End,
--													RebateQty = Case @SaleQty When 0 Then 0 Else
--													(Case InvoiceType 
--													When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty 
--													Else (@RebateQty / @SaleQty) * SaleQty 
--													End) End,
--													RebateValue =  Case @SaleQty When 0 Then 0 Else
--													(Case InvoiceType 
--													When 4 Then (-1) * (RebateValue / @SaleQty) * SaleQty 
--													Else (RebateValue / @SaleQty) * SaleQty 
--													End) End,
--								TotalPoints = Case @SaleQty When 0 Then 0 Else ((@RebateQty / @SaleQty) * SaleQty) End,
--								PointsValue = Case @SaleQty When 0 Then 0 Else ((@RebateValue / @SaleQty) * SaleQty) End
--								Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1

--							Else If @UOMID = 4
--									Update #RFAInfo Set PromotedQty = Case @SaleQty When 0 Then 0 Else 
--									(Case InvoiceType 
--									When 4 Then (-1) * (@PromotedQty / @SaleQty) * SaleQty 
--									Else (@PromotedQty / @SaleQty) * SaleQty 
--									End) End,
--									PromotedValue = Case InvoiceType
--									When 4 Then (-1) * ((SaleValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * @PromotedValue)
--									Else ((SaleValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * @PromotedValue)
--									End,
--									RebateQty = Case @SaleQty When 0 Then 0 Else 
--									(Case InvoiceType 
--									When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty 
--									Else (@RebateQty / @SaleQty) * SaleQty 
--									End) End,
--									RebateValue = Case @SaleQty When 0 Then 0 Else 
--									(Case InvoiceType 
--									When 4 Then (-1) * (RebateValue / @SaleQty) * SaleQty 
--									Else (RebateValue / @SaleQty) * SaleQty 
--									End) End,
--								TotalPoints = Case @SaleQty When 0 Then 0 Else ((@RebateQty / @SaleQty) * SaleQty) End,
--								PointsValue = Case @SaleQty When 0 Then 0 Else ((@RebateValue / @SaleQty) * SaleQty) End
--								Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1
--							Else If @UOMID = 2
--								Update #RFAInfo Set PromotedQty = Case @UOM1Qty When 0 Then 0 Else 
--                                                    (Case InvoiceType
--													When 4 Then (-1) * ((@PromotedQty / UOM1Conv) * SaleQty)
--													Else ((@PromotedQty / @UOM1Qty) * SaleQty) 
--													End) End, 
--													PromotedValue = Case InvoiceType
--													When 4 Then (-1) * (@PromotedValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
--													Else (@PromotedValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))) 
--													End,
--													RebateQty = Case @SaleQty When 0 Then 0 Else
--													(Case InvoiceType 
--													When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty 
--													Else (@RebateQty / @SaleQty) * SaleQty 
--													End) End,
--													RebateValue = Case @SaleQty When 0 Then 0 Else
--													(Case InvoiceType 
--													When 4 Then (-1) * (RebateValue / @SaleQty) * SaleQty 
--													Else (RebateValue / @SaleQty) * SaleQty 
--													End) End,
--								TotalPoints = Case @SaleQty When 0 Then 0 Else ((@RebateQty / @SaleQty) * SaleQty) End,
--								PointsValue = Case @SaleQty When 0 Then 0 Else ((@RebateValue / @SaleQty) * SaleQty) End
--								Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1
--							Else If @UOMID = 3
--								Update #RFAInfo Set PromotedQty = Case @UOM2Qty When 0 Then 0 Else
--													(Case InvoiceType
--													When 4 Then (-1) * ((@PromotedQty / UOM2Conv) * SaleQty)
--													Else ((@PromotedQty / @UOM2Qty) * SaleQty) 
--													End) End, 
--													PromotedValue = Case InvoiceType 
--													When 4 Then (-1) * (@PromotedValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
--													Else (@PromotedValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))) 
--													End,
--													RebateQty = Case @SaleQty When 0 Then 0 Else
--													(Case InvoiceType 
--													When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty 
--													Else (@RebateQty / @SaleQty) * SaleQty 
--													End) End,
--													RebateValue = Case @SaleQty When 0 Then 0 Else
--													(Case InvoiceType 
--													When 4 Then (-1) * (RebateValue / @SaleQty) * SaleQty 
--													Else (RebateValue / @SaleQty) * SaleQty 
--													End) End,
--								TotalPoints = Case @SaleQty When 0 Then 0 Else ((@RebateQty / @SaleQty) * SaleQty) End,
--								PointsValue = Case @SaleQty When 0 Then 0 Else ((@RebateValue / @SaleQty) * SaleQty) End
--								Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1
--							Fetch Next From GroupCur Into @SchemeGroup,@OutletCode
--						End
--						Close GroupCur
--						Deallocate GroupCur

--					End /*SplCategory scheme(QPS) - End*/
--				End/*QPS Ends*/
--			End /* Item Spl Points scheme ends here */
--			Else If @ApplicableOn = 2 /* Invoice based Point scheme */
--			Begin
--				Insert Into #RFAInfo (InvoiceID, InvoiceType,  OutletCode, RebateQty, RebateValue, Amount, SchemeID, SchemeOutlet, SchemeGroup) 
--				Select IA.InvoiceID, IA.InvoiceType,C.CustomerID,0 as RebateQty,0 as RebateValue,IA.NetValue as Amount,
--				0 as SchemeID,Null as SchemeOutlet,Null as SchemeGroup
--				From #TmpInvoiceAbstract IA, Customer C
--				Where IA.InvoiceType In (1,3,4)        
--				And (IA.Status & 128)=0  
--				And IA.CustomerID = C.CustomerID
--				And (Case IA.InvoiceType
--					When 3 Then (Select Min(InvoiceDate) From #TmpInvoiceAbstract Where DocumentID = 
--					IA.DocumentID
--					And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)--(Select dbo.mERP_fn_GetInvoiceDate(IA.InvoiceID, 1))
--					Else IA.InvoiceDate
--					End) Between @ActiveFrom And @ActiveTo
--				And (Case IA.InvoiceType
--					When 3 Then (Select Min(InvoiceDate) From #TmpInvoiceAbstract Where DocumentID = IA.DocumentID
--					And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID) --(Select dbo.mERP_fn_GetInvoiceDate(IA.InvoiceID, 1))
--					Else IA.InvoiceDate
--					End) Between @PayoutFrom And @PayoutTo
--				And IA.CreationTime <= @RedeemDate

--				Declare SchemeOutletCur Cursor For
--				Select Distinct OutletCode From #RFAInfo
--				Open SchemeOutletCur
--				Fetch Next From SchemeOutletCur Into @CustomerID
--				While (@@Fetch_Status = 0)			
--				Begin
--					Select @SchemeOutlet = QPS, @SchemeGroup = GroupID From dbo.mERP_fn_CheckSchemeOutlet(@SchemeID, @CustomerID)
--					Update #RFAInfo Set SchemeOutlet = @SchemeOutlet, SchemeGroup = @SchemeGroup 
--					Where OutletCode = @CustomerID
--					Fetch Next From SchemeOutletCur Into @CustomerID
--				End
--				Close SchemeOutletCur
--				Deallocate SchemeOutletCur
		
--				/*Delete non scheme Outlet*/
--				Delete From #RFAInfo Where IsNull(SchemeOutlet,0) = 2

--				If @QPS = 0
--				Begin
--					/* Non Qps starts*/
--					Declare SchemeCur Cursor For 
--					Select InvoiceID, Sum(Amount), 
--					Max(SchemeGroup) 
--					From #RFAInfo 
--					Where IsNull(SchemeOutlet, 0) = 0
--					Group By InvoiceID
--					Open SchemeCur
--					Fetch Next From SchemeCur Into @InvoiceID, @Value, @SchemeGroup
--					While (@@Fetch_Status = 0)
--					Begin
--						Select @PromotedQty = PromotedQty, @PromotedValue = PromotedValue, @RebateQty = RebateQty, @RebateValue = RebateValue
--								From dbo.mERP_fn_GetPointsSchValue(@SchemeID, @SchemeGroup, @Qty, @Value,@UOM1Qty, @UOM2Qty,0)
--						Update #RFAInfo Set PromotedQty = Case InvoiceType 
--															When 4 Then (-1) * @PromotedQty
--															Else @PromotedQty End, 
--											PromotedValue = 
--															Case InvoiceType
--															When 4 Then (-1) * @PromotedValue
--															Else @PromotedValue End,
--								TotalPoints = @RebateQty, PointsValue = @RebateValue
--								Where InvoiceID = @InvoiceID

--					Fetch Next From SchemeCur Into @InvoiceID, @Value, @SchemeGroup
--					End
--					Close SchemeCur
--					Deallocate SchemeCur
--					/*Non QPS - End*/
--				End

--				/*QPS - Start*/
--				If @QPS = 1
--				Begin
--					Declare GroupCur Cursor For
--					Select Distinct OutletCode, SchemeGroup From #RFAInfo
--					Where IsNull(SchemeOutlet, 0) = 1
--					Open GroupCur
--					Fetch Next From GroupCur Into @OutletCode, @SchemeGroup
--					While (@@Fetch_Status = 0)
--					Begin

--						Set @SaleValue = 0
--						Declare SchemeCur Cursor For 
--							Select InvoiceID, Sum(Case InvoiceType 
--												When 4 Then (-1) * (Amount)
--												Else Amount
--												End)
--								From #RFAInfo 
--								Where OutletCode = @OutletCode and  IsNull(SchemeOutlet, 0) = 1
--								And SchemeGroup = @SchemeGroup
--								Group By InvoiceID
--						Open SchemeCur
--						Fetch Next From SchemeCur Into @InvoiceID, @Value
--						While (@@Fetch_Status = 0)
--						Begin
--							Set @SaleValue = @SaleValue + @Value
				
--						Fetch Next From SchemeCur Into @InvoiceID, @Value
--						End
--						Close SchemeCur
--						Deallocate SchemeCur

--						Select @PromotedValue = PromotedValue, @RebateQty = RebateQty, @RebateValue = RebateValue
--								From dbo.mERP_fn_GetPointsSchValue(@SchemeID, @SchemeGroup, 0, @SaleValue,0, 0,0)


--						Update #RFAInfo Set 
--						PromotedValue = Case InvoiceType
--						When 4 Then (-1) * ((SaleValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * @PromotedValue)
--						Else ((SaleValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * @PromotedValue)
--						End,
--						TotalPoints = (@RebateQty/Case @SaleValue When 0 Then 1 Else @SaleValue End) * Amount,
--						PointsValue = (@RebateValue/Case @SaleValue When 0 Then 1 Else @SaleValue End) * Amount
--						Where IsNull(SchemeOutlet, 0) = 1 and OutletCode = @OutletCode

--						Fetch Next From GroupCur Into @OutletCode, @SchemeGroup
--					End
--					Close GroupCur
--					Deallocate GroupCur
--				/*QPS - End*/
--				End
--			End /* Invoice Based Points scheme ends */
			
--			--Select * From #RFAInfo
--			Update #RFAInfo Set RebateQty =  (-1) * RebateQty, RebateValue = (-1) * RebateValue,
--			SaleQty = (-1) * SaleQty, SaleValue = (-1) * SaleValue, 
--			TotalPoints =(-1)* TotalPoints , PointsValue =  (-1)* PointsValue
--			Where InvoiceType = 4

--			Insert Into #tmpSchemeSale(SchemeType,SchemeID,PayoutID,QPS,Division,SaleQty,SaleValue,
--			PromotedQty,PromotedValue,RebateQty,RebateValue)
--			Select 2,@SchemeID,@PayoutID,1,Division,Sum(isNull(SaleQty,0)),Sum(isNull(SaleValue,0)),
--			Sum(isNull(PromotedQty,0)),Sum(isNull(PromotedValue,0)),Sum(isNull(TotalPoints,0)),Sum(isNull(PointsValue,0))
--			From #RFAInfo Where SchemeOutlet = @QPS
--			--Where (isNull(TotalPoints,0) > 0 Or isNull(PointsValue,0) > 0)
--			Group By Division
--		End/*Points Scheme Ends*/
--		Fetch Next From ShemeCursor Into @SchemeID,@PayoutID,@QPS,@SchemeType,@ApplicableOn,@ItemGroup,@ActiveFrom,@ActiveTo,@PayoutFrom,@PayoutTo
--	End
--	Close ShemeCursor
--	Deallocate ShemeCursor

--	/* Points Scheme Ends */
	
	
	/* Trade Scheme And Display Scheme */
	Insert Into #tmpFinal([SchemeType],[WD Code],[WD Dest],FromDate,ToDate,Division,[Activity Code],[Activity Desc],
	[Level],[Scheme Type],QPS,[Scheme From],[Scheme To],[Payout_From],[Payout_To],[Sales Qty],[Sales Value],
	[Promoted Qty],[Promoted Value],[Rebate Qty],[Rebate Value], [RFA Applicable])
	Select SS.SchemeType,@WDCode,@WDDest,@FromDate ,@ToDate,Division,SA.ActivityCode,cast(SA.Description as nvarchar(255)),
	(Case SS.SchemeType When 1 Then N'Item' When 2 Then N'Item' When 3 Then N'Outlet' End),
	(Case SA.SchemeType When 1 Then N'SP' When 2 Then N'CP' When 3 Then N'Display'  When 4 Then N'Points' End),
	(Case SS.SchemeType When 3 Then '' Else (Case isNull(QPS,0) When 1 Then 'MAIN' End) End),
	 ActiveFrom,ActiveTo,Null,Null,
	 --PayoutPeriodFrom,PayoutPeriodTo,
	(Case SS.SchemeType When 3 Then NULL Else Max(isNull(SaleQty,0)) End),
	(Case SS.SchemeType When 3 Then NULL Else Max(isNull(SaleValue,0)) End),
	(Case SS.SchemeType When 3 Then NULL Else Sum(isNull(PromotedQty,0)) End),
	(Case SS.SchemeType When 3 Then NULL Else Sum(isNull(PromotedValue,0)) End),
	(Case SS.SchemeType When 3 Then NULL Else Sum(isNull(RebateQty,0)) End),
	(Case SS.SchemeType When 3 Then Null Else Sum(isNull(RebateValue,0)) End),
	Case When isnull(SA.RFAApplicable,0) = 1 Then 'Yes' Else 'No' End
	From #tmpSchemeSale SS ,tbl_mERP_SchemeAbstract SA--,tbl_mERP_SchemePayoutperiod SPP
	Where SS.SchemeType In(1)
	And SS.SchemeID = SA.SchemeID
	--And SA.SchemeID = SPP.SchemeID
	--And SS.PayoutID = SPP.ID
	Group By SS.SchemeType,Division,SA.ActivityCode,SA.Description,SA.SchemeType,ActiveFrom,ActiveTo, --PayoutPeriodFrom,PayoutPeriodTo,
	SS.QPS, SA.RFAApplicable
	Union/* Points Scheme */
	Select SS.SchemeType,@WDCode,@WDDest,@FromDate ,@ToDate,Division,SA.ActivityCode,cast(SA.Description as nvarchar(255)),
	(Case SS.SchemeType When 1 Then N'Item' When 2 Then N'Item' When 3 Then N'Outlet' End),
	(Case SA.SchemeType When 1 Then N'SP' When 2 Then N'CP' When 3 Then N'Display'  When 4 Then N'Points' End),
	(Case SS.SchemeType When 3 Then '' Else (Case isNull(QPS,0) When 1 Then 'MAIN' End) End),
	 ActiveFrom,ActiveTo,Null,Null,
	 --PayoutPeriodFrom,PayoutPeriodTo,
	(Case SS.SchemeType When 3 Then NULL Else Sum(isNull(SaleQty,0)) End),
	(Case SS.SchemeType When 3 Then NULL Else Sum(isNull(SaleValue,0)) End),
	(Case SS.SchemeType When 3 Then NULL Else Sum(isNull(PromotedQty,0)) End),
	(Case SS.SchemeType When 3 Then NULL Else Sum(isNull(PromotedValue,0)) End),
	(Case SS.SchemeType When 3 Then NULL Else Sum(isNull(RebateQty,0)) End),Sum(isNull(RebateValue,0)),
	Case When isnull(SA.RFAApplicable,0) = 1 Then 'Yes' Else 'No' End
	From #tmpSchemeSale SS ,tbl_mERP_SchemeAbstract SA,tbl_mERP_SchemePayoutperiod SPP
	Where SS.SchemeType In(2)
	And SS.SchemeID = SA.SchemeID
	And SA.SchemeID = SPP.SchemeID
	And SS.PayoutID = SPP.ID
	Group By SS.SchemeType,Division,SA.ActivityCode,SA.Description,SA.SchemeType,ActiveFrom,ActiveTo, --PayoutPeriodFrom,PayoutPeriodTo, 
	SS.QPS, SA.RFAApplicable	
	
	Select [SchemeType],[WD Code],[WD Dest],FromDate,ToDate,Division as Category,[Activity Code],[RFA Applicable],
		[Scheme Type],[Scheme From],[Scheme To], --[Sales Qty],[Sales Value],
		[Promoted Qty],[Promoted Value],
		[Rebate Qty],[Rebate Value]
	From #tmpFinal
	--Where [Promoted Qty] > 0 or [Promoted Value] > 0 or [Rebate Qty] > 0 or [Rebate Value] > 0
	Order by SchemeType, [Activity Code], Division	
	

	Drop Table #tmpScheme
	Drop Table #tmpTradeScheme
	Drop Table #TmpSchemeItemFree 
	Drop Table #tmpTradeRFA
	Drop Table #tmpSchemeSale
	Drop Table #tmpSales
	Drop Table #tmpDivisionWiseSales
	Drop Table #RFAInfo
	Drop Table #tmpFinal
	--Drop Table #TmpInvoiceAbstract
	--Drop Table #TmpInvoiceDetail 
	Drop Table #Tmptbl_merp_NonQPSData
	
OvernOut:
End
