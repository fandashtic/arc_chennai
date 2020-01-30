Create Procedure mERP_spr_LiabilityReport(@FromDate DateTime,@ToDate Datetime)
As
Begin
	Declare @DayClosed Int
	Declare @Month Int
	Declare @Year Int

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
	
	
	Set DateFormat dmy

	Select @Fromdate = dbo.StripTimeFromDate(@Fromdate),@ToDate= dbo.StripTimeFromDate(@ToDate)



	Select @DayClosed = 0
	If (Select isNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') = 1
	Begin
		If ((Select dbo.StripTimeFromDate(LastInventoryUpload) From Setup) >= @ToDate) --DateAdd(d,1,@ToDate)
		Set @DayClosed = 1
	End


	/* Report should be generated only if the last day of the month is Closed */
	If @DayClosed = 0
		GoTo OvernOut

	/* Report should not be executed if DC is running */
	If exists (Select * From tbl_mERP_BackDtSchProcessInfo  where isnull(Active,0)=1)
		GoTo OvernOut	
	
	Select @Month = Month(@ToDate)
	Select @Year = Year(@ToDate)

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
		CustomerID nVarchar(30) collate SQL_Latin1_General_CP1_CI_AS)


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
		[Sales_Qty] Decimal(18,6),[Sales_Value] Decimal(18,6),
		[Promoted_Qty] Decimal(18,6),[Promoted_Value] Decimal(18,6),
		[Rebate_Liab_Qty] Decimal(18,6),[Rebate_Liab_Value] Decimal(18,6))


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



	/* To Insert Pending Trade scheme */
	Insert Into #tmpScheme(SchemeID,PayoutID,QPS,SchemeType,ApplicableOn,ItemGroup,ActiveFrom,ActiveTo,PayoutFrom,PayoutTo)
	Select Distinct SA.SchemeID,SPP.ID,SO.QPS,SA.SchemeType,SA.ApplicableOn,SA.ItemGroup,
	dbo.StripTimeFromDate(SA.ActiveFrom),dbo.StripTimeFromDate(SA.ActiveTo),
	dbo.StripTimeFromDate(SPP.PayoutPeriodFrom),dbo.StripTimeFromDate(SPP.PayoutPeriodTo)
	From tbl_mERP_SchemeAbstract SA, (select Distinct SchemeId, QPS  From tbl_mERP_SchemeOutlet) SO, tbl_mERP_SchemePayoutPeriod SPP  
	Where SA.SchemeID = SO.SchemeID  
	And SA.Active = 1
	And SA.SchemeType In(1,2)
	And SO.QPS In(0 ,1)
	And isNull(SPP.ClaimRFA,0) = 0   
	And isNull(SA.RFAApplicable,0) = 1  
	And SA.SchemeID = SPP.SchemeID  
	And SPP.Active = 1    
	And Year(dbo.StripTimeFromDate(SPP.PayoutPeriodTo)) = @Year
	And Month(dbo.StripTimeFromDate(SPP.PayoutPeriodTo)) = @Month
	And dbo.StripTimeFromDate(SPP.PayoutPeriodTo) <= @ToDate
	Order By SA.SchemeID


	/* To Insert Pending & submitted Points scheme */
	Insert Into #tmpScheme(SchemeID,PayoutID,QPS,SchemeType,ApplicableOn,ItemGroup,ActiveFrom,ActiveTo,PayoutFrom,PayoutTo)
	Select Distinct SA.SchemeID,SPP.ID,SO.QPS,SA.SchemeType,SA.ApplicableOn,SA.ItemGroup,
	dbo.StripTimeFromDate(SA.ActiveFrom),dbo.StripTimeFromDate(SA.ActiveTo),
	dbo.StripTimeFromDate(SPP.PayoutPeriodFrom),dbo.StripTimeFromDate(SPP.PayoutPeriodTo)
	From tbl_mERP_SchemeAbstract SA, (select Distinct SchemeId, QPS  From tbl_mERP_SchemeOutlet) SO, tbl_mERP_SchemePayoutPeriod SPP  
	Where SA.SchemeID = SO.SchemeID  
	And SA.Active = 1
	And SA.SchemeType In(4)
	And SO.QPS In(0 ,1)
	And isNull(SA.RFAApplicable,0) = 1  
	And SA.SchemeID = SPP.SchemeID  
	And SPP.Active = 1
	And Year(dbo.StripTimeFromDate(SPP.PayoutPeriodTo)) = @Year
	And Month(dbo.StripTimeFromDate(SPP.PayoutPeriodTo)) = @Month
	And dbo.StripTimeFromDate(SPP.PayoutPeriodTo) <= @ToDate  
	Order By SA.SchemeID

		
--	/* To check whether All QPS Credit Note generated */
	If Exists(Select ID From tbl_mERP_schemePayoutPeriod Where Active=1 and isNull(status,0) <> 128 
		and ID In(Select PayoutID From #tmpScheme	Where QPS = 1 And SchemeType in(1,2)))
	GoTo DropTablenOut
	

	/* Trade Scheme & Points Scheme Begins*/
	Declare ShemeCursor Cursor For
	Select Distinct SchemeID,PayoutID,QPS,SchemeType,ApplicableOn,ItemGroup,ActiveFrom,ActiveTo,PayoutFrom,PayoutTo  From #tmpScheme
	Open ShemeCursor
	Fetch From ShemeCursor Into @SchemeID,@PayoutID,@QPS,@SchemeType,@ApplicableOn,@ItemGroup,@ActiveFrom,@ActiveTo,@PayoutFrom,@PayoutTo
	While @@Fetch_Status = 0
	Begin


		Truncate Table #tmpTradeRFA	
		Truncate Table #RFAInfo

		Truncate Table #tmpSales
		Truncate Table #tmpDivisionWiseSales

		Insert Into #tmpSales
		Select 	ID.Product_Code as SKUCode,
		Sum(( case InvoiceType When 4 Then -1 Else 1 End)  * ID.Quantity ),
		Sum(( case InvoiceType When 4 Then -1 Else 1 End) * ID.SalePrice * ID.Quantity )
		From InvoiceAbstract IA, InvoiceDetail ID, Customer C
		Where IA.InvoiceId = ID.InvoiceId
		And IA.InvoiceType In (1,3,4)        
		And (IA.Status & 128) = 0  
		And IA.CustomerID = C.CustomerID
		And ID.FlagWord = 0
		And (Case IA.InvoiceType
					When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID = 
					IA.DocumentID
					And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)
					Else dbo.StripTimeFromDate(IA.InvoiceDate)
					End) Between @ActiveFrom And @ActiveTo
		And (Case IA.InvoiceType
				When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID = IA.DocumentID
					And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID) 
				Else dbo.StripTimeFromDate(IA.InvoiceDate)
				End) Between @PayoutFrom And @PayoutTo
		Group By ID.Product_Code



		Set @ItemFree = 0
		Select @ItemFree = (Case Max(SlabType) When 1 Then 0 When 2 Then 0 Else 1 End) From tbl_mERP_SchemeSlabDetail Where SchemeID = @SchemeID

		if (@SchemeType = 1 Or @SchemeType = 2) /* Trade Scheme Begins*/
		Begin
			If @QPS = 0 /* Non-QPS Scheme Begins*/
			Begin
				Insert Into #tmpTradeRFA (SchemeID ,PayoutID ,InvoiceID,SKUCode,PromotedQty, PromotedValue,	RebateQty, RebateValue,
				InvoiceType, LineType, SaleQty, SaleValue)
				Select  @SchemeID,@PayoutID,NQD.InvoiceID, NQD.Product_Code,PromotedQty, PromotedValue,
				RebateQty,Case @TaxConfigFlag When 1 Then RebateValue_Tax Else RebateValue End,
				InvoiceType,Case [Type]	When 1 Then 1 Else 0 End,
				SaleQty, SaleValue
				From tbl_merp_NonQPSData NQD, tbl_merp_SchemePayoutPeriod SPP 
				Where NQD.SchemeID = @SchemeID
				And NQD.SchemeID = SPP.SchemeID
				And SPP.ID = @PayoutID
				And dbo.StripTimeFromDate(NQD.OriginalInvDate)  Between	
				dbo.StripTimeFromDate(SPP.PayoutPeriodFrom) And dbo.StripTimeFromDate(SPP.PayoutPeriodTo)
				Order By NQD.InvoiceID, NQD.SchemeID, NQD.Product_Code


				
				/* Remove -ve value due to SR (invoice-SR should be >=0) */
--				Declare SRCursor Cursor For
--				Select Distinct InvoiceID From #tmpTradeRFA Where InvoiceType = 4 
--				Open SRCursor
--				Fetch Next From SRCursor Into @InvoiceID
--				While (@@Fetch_Status = 0)
--				Begin
--					Set @InvRebateValue = 0
--					Set @SRRebateValue = 0
--
--					/*Sales Return Rebate value against the invoice*/
--					Select @SRRebateValue = Sum(RebateValue) From #tmpTradeRFA Where InvoiceType=4 and invoiceid=@InvoiceID and schemeid=@SchemeId
--					
--					/*Invoice Rebate value*/
--					--Finding respective invoiceid
--					Select @BillRef = isnull(ReferenceNumber,'') from InvoiceAbstract where invoicetype=4 and Invoiceid = @InvoiceID 
--					If isnumeric(@BillRef) = 0
--						Set @tmpInvoiceID = ( Select Top 1 InvoiceId from InvoiceAbstract where Status & 128 = 0 and DocumentId= ( select top 1 cast(ISnull(REVERSE(left(reverse(ReferenceNumber),PATINDEX(N'%[^0-9]%',Reverse(ReferenceNumber))-1)),0) as Integer) from InvoiceAbstract where invoicetype=4 and Invoiceid = @InvoiceID and isnull(referencenumber,'') <> '' and isnumeric(referencenumber) = 0 ) order by invoiceid desc) 
--					Else
--						Set @tmpInvoiceID = ( Select Top 1 InvoiceId from InvoiceAbstract where Status & 128 = 0 and DocumentId =  (Select ReferenceNumber from InvoiceAbstract where invoicetype=4 and Invoiceid = @InvoiceID and isnull(referencenumber,'') <> ''  ) order by invoiceid desc) 
--					--Check if original invoice exist in that period.
--					--If we dont have original invoice for the given period for that sales return then remove that sales return entry
--					if @tmpInvoiceid <> 0
--						Select @InvRebateValue = Sum(RebateValue) From tbl_merp_nonqpsdata Where InvoiceType<>4 and isnull([Type],0)=0 and schemeid=@SchemeId and Invoiceid = @tmpInvoiceId
--					else 
--						Delete From #tmpTradeRFA Where InvoiceID = @InvoiceID 
--					
--					--if sales-salesreturn having -ve value for non free item schemes
--					if ((@InvRebateValue + @SRRebateValue) < 0 )
--					Begin 
--						Delete From #tmpTradeRFA Where InvoiceID in ( @InvoiceID , @tmpInvoiceId) --and Flagword = 0
--						--Select * From #tmpTradeRFA Where InvoiceID = @InvoiceID Or ReferenceNumber = @BillRef
--					end
--					Fetch Next From SRCursor Into @InvoiceID
--				End
--				Close SRCursor	
--				Deallocate SRCursor	
--				/* Sales return Ends Here */
--



		 
				
				Update RFA Set Division = IC2.Category_Name 
				From  #tmpTradeRFA RFA,Items I , ItemCategories IC, ItemCategories IC1,ItemCategories IC2
				Where RFA.SKUCode = I.Product_Code And
				I.CategoryID = IC.CategoryID And
				IC.ParentID = IC1.CategoryID And
				IC1.ParentID = IC2.CategoryID

				Update #tmpTradeRFA Set SaleQty = isNull(SaleQty,0),SaleValue = isNull(SaleValue,0),
				PromotedQty = isNull(PromotedQty,0),PromotedValue = isNull(PromotedValue,0),
				RebateQty = isNull(RebateQty,0),RebateValue=isNull(RebateValue,0)

				If @ApplicableOn = 2 And @ItemFree = 1
					Insert Into #tmpSchemeSale(SchemeType,SchemeID,PayoutID,QPS,Division,SaleQty,SaleValue,
					PromotedQty,PromotedValue,RebateQty,RebateValue)
					Select 1,SchemeID,PayoutID,1,Division,Sum(SaleQty),Sum(SaleValue),
					Sum(PromotedQty),Sum(PromotedValue),Sum(RebateQty),Sum(RebateValue)
					From #tmpTradeRFA Where SchemeID = @SchemeID And PayoutID = @PayoutID
					And LineType = 1
					Group By SchemeID,PayoutID,Division
				Else
					Insert Into #tmpSchemeSale(SchemeType,SchemeID,PayoutID,QPS,Division,SaleQty,SaleValue,
					PromotedQty,PromotedValue,RebateQty,RebateValue)
					Select 1,SchemeID,PayoutID,1,Division,Sum(SaleQty),Sum(SaleValue),
					Sum(PromotedQty),Sum(PromotedValue),Sum(RebateQty),Sum(RebateValue)
					From #tmpTradeRFA Where SchemeID = @SchemeID And PayoutID = @PayoutID
					And LineType = 0
					Group By SchemeID,PayoutID,Division

			End /* Non-QPS Scheme Ends */
			Else If @QPS = 1 /* QPS Scheme Starts */
			Begin
				If @ItemFree = 1 /*Insert Free Item adjusted in Invoice for QPS Scheme start */
				Begin
					Declare OffTakeSKUCur Cursor For
					Select Distinct CustomerID, Product_Code, InvoiceRef 
					From SchemeCustomerItems 
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
					
						Insert Into #tmpTradeRFA (SchemeID ,PayoutID ,InvoiceID,CustomerID,SKUCode,RebateQty, RebateValue,
								InvoiceType, LineType)
						Select @SchemeID,@PayoutID,IA.InvoiceID, IA.CustomerID, @SKUCode,Sum(Quantity),
							Sum(Quantity) * (@MarginPTR + (Case @TaxConfigFlag When 1 Then (@MarginPTR * Max(TaxCode)/100) Else 0 End)),
							IA.InvoiceType,1
							From InvoiceAbstract IA, InvoiceDetail ID 
							Where IA.InvoiceID = ID.InvoiceID
							And IA.InvoiceID = Cast(@InvoiceRef as Int)
							And IA.CustomerID = @CustomerID
							And ID.SchemeID = @SchemeID
							And ID.Product_Code = @SKUCode
							And IsNull(Flagword, 0) = 1
							Group By IA.InvoiceID,IA.InvoiceType,IA.CustomerID
						Fetch Next From OffTakeSKUCur Into @CustomerID, @SKUCode, @InvoiceRef
					End
					Close OffTakeSKUCur
					Deallocate OffTakeSKUCur

					 /*Insert Free Item Not adjusted in Invoice for QPS Scheme start */
					If @ItemFree = 1
					Begin
						Declare OffTakeSKUCur Cursor For
						Select Distinct CustomerID
						From SchemeCustomerItems
						Where SchemeID = @SchemeID 
						And PayoutID = @PayoutID
						And IsInvoiced = 0
						Open OffTakeSKUCur
						Fetch Next From OffTakeSKUCur Into @CustomerID
						While @@Fetch_Status = 0
						Begin
							
							Insert Into #tmpTradeRFA (SchemeID ,PayoutID ,CustomerID,SKUCode,RebateQty, RebateValue,LineType)
							Select Top 1 @SchemeID,@PayoutID, @CustomerID, SCI.Product_Code,Sum(SCI.Quantity),
							Sum(SCI.Quantity) * (I.PTR + (Case @TaxConfigFlag When 1 Then (I.PTR * (Case isNull(C.Locality,0) When 1 Then isNull(T.Percentage,0) When 2 Then isNull(CST_Percentage,0) Else 0 End)/100.) Else 0 End)),
							1
							From SchemeCustomerItems SCI 
							Inner Join Customer C On C.CustomerID = SCI.CustomerID
							Inner Join Items I On SCI.Product_Code = I.Product_Code
							Left Outer Join Tax T On I.Sale_Tax = T.Tax_Code
							Where SCI.SchemeID = @SchemeID 
							And SCI.PayoutID = @PayoutID
							And SCI.IsInvoiced = 0
							And SCI.CustomerID = @CustomerID
							Group By SCI.Product_Code,I.PTR,C.Locality,T.Percentage,T.CST_Percentage
							Fetch Next From OffTakeSKUCur Into @CustomerID
						End
						Close OffTakeSKUCur
						Deallocate OffTakeSKUCur
					End
					 /*Insert Free Item Not adjusted in Invoice for QPS Scheme start */

					Update RFA Set Division = IC2.Category_Name
					From #tmpTradeRFA RFA,Items I , ItemCategories IC, ItemCategories IC1,ItemCategories IC2
					Where RFA.SKUCode = I.Product_Code And
					I.CategoryID = IC.CategoryID And
					IC.ParentID = IC1.CategoryID And
					IC1.ParentID = IC2.CategoryID 
					
				End /*Insert Free Item adjusted in Invoice for QPS Scheme end */

				If @ApplicableOn = 1  And (@ItemGroup = 1 Or @ItemGroup = 2) /* QPS Item Or Spl category scheme start*/
				Begin
					If @ItemFree = 0 /* Offtake Percentage or Amount Scheme Starts*/
					Begin
						Insert Into #tmpSchemeSale(SchemeType,SchemeID,PayoutID,QPS,Division,SaleQty,SaleValue,
						PromotedQty,PromotedValue,RebateQty,RebateValue)
						Select 1,SchemeID,PayoutID,1,Division,
						Sum(IsNull(Quantity,0)),Sum(IsNull(SalesValue,0)), Sum(IsNull(Promoted_Qty,0)), Sum(IsNull(Promoted_Val,0)), 
						Sum(IsNull(Rebate_Qty,0)), (case @TaxConfigCrdtNote When 1 Then Sum(IsNull(Rebate_Val,0)) Else Sum(IsNull(RFARebate_Val,0)) End) 
						From tbl_mERP_QPSDtlData Where SchemeID = @SchemeID And PayoutID = @PayoutID
						And (isNull(Rebate_Qty,0) > 0 Or isNull(Rebate_Val,0) > 0 Or IsNull(RFARebate_Val,0) > 0)
						Group By SchemeID,PayoutID,Division
					End
					If @ItemFree = 1 /* Offtake Free Scheme */
					Begin
						/* Only the Free Item adjustded details should come */
						/* To Update the RFARebate value for the Primary Row */
						Select * Into #tmptbl_mERP_QPSDtlData From tbl_mERP_QPSDtlData
						Where SchemeID = @SchemeID
						And PayoutID = @PayoutID
						And CustomerID In(Select CustomerID From #tmpTradeRFA)
						And (isNull(Rebate_Qty,0) > 0 Or isNull(Rebate_Val,0) > 0 Or IsNull(RFARebate_Val,0) > 0)

						Declare RebateVal Cursor For 
						Select Distinct CustomerID,Sum(RebateValue),Sum(RebateQty) From  #tmpTradeRFA
						Where SchemeID = @SchemeID 
						Group By CustomerID
						Open RebateVal 
						Fetch Next From RebateVal Into @CustomerID,@RebateValue,@RebateQty
						While (@@Fetch_Status = 0)
						Begin
					
							Select @TotRebateQty = Sum(Rebate_Qty)  
							From #tmptbl_mERP_QPSDtlData RFA
							Where CustomerID = @CustomerID And   isNull(Quantity,0) <> 0

												
							Update #tmptbl_mERP_QPSDtlData Set Rebate_Qty = (Rebate_Qty/@TotRebateQty)*@RebateQty
							Where CustomerID = @CustomerID And isNull(Quantity,0) <> 0
							
							Update #tmptbl_mERP_QPSDtlData Set RFARebate_Val = (Rebate_Qty * @RebateValue)/@RebateQty,
							Rebate_Val = (Rebate_Qty * @RebateValue)/@RebateQty
							Where CustomerID = @CustomerID And isNull(Quantity,0) <> 0
							

							Fetch Next From RebateVal Into @CustomerID,@RebateValue,@RebateQty
						End
						Close RebateVal
						Deallocate RebateVal

					Insert Into #tmpSchemeSale(SchemeType,SchemeID,PayoutID,QPS,Division,SaleQty,SaleValue,
					PromotedQty,PromotedValue,RebateQty,RebateValue)
					Select 1,SchemeID,PayoutID,1,Division,
					Sum(IsNull(Quantity,0)),Sum(IsNull(SalesValue,0)), Sum(IsNull(Promoted_Qty,0)), Sum(IsNull(Promoted_Val,0)), 
					Sum(IsNull(Rebate_Qty,0)), (case @TaxConfigCrdtNote When 1 Then Sum(IsNull(Rebate_Val,0)) Else Sum(IsNull(RFARebate_Val,0)) End) 
					From #tmptbl_mERP_QPSDtlData Where SchemeID = @SchemeID And PayoutID = @PayoutID
					And (isNull(Rebate_Qty,0) > 0 Or isNull(Rebate_Val,0) > 0 Or IsNull(RFARebate_Val,0) > 0)
					Group By SchemeID,PayoutID,Division

					Drop Table #tmptbl_mERP_QPSDtlData

					End
				End/* QPS Item Or Spl category scheme end*/
				Else If @ApplicableOn = 2 /* QPS Invoice Scheme Starts */
				Begin
					If @ItemFree = 0 
					Begin
						Insert Into #tmpSchemeSale(SchemeType,SchemeID,PayoutID,QPS,RebateValue)
						Select 1,SchemeID,PayoutID,1,
						(case @TaxConfigCrdtNote When 1 Then Sum(IsNull(Rebate_Val,0)) Else Sum(IsNull(RFARebate_Val,0)) End) 
						From tbl_mERP_QPSDtlData Where SchemeID = @SchemeID And PayoutID = @PayoutID
						And (isNull(Rebate_Qty,0) > 0 Or isNull(Rebate_Val,0) > 0 Or IsNull(RFARebate_Val,0) > 0)
						Group By SchemeID,PayoutID
					End
					Else If @ItemFree = 1
					Begin
						Insert Into #tmpSchemeSale(SchemeType,SchemeID,PayoutID,QPS,Division,SaleQty,SaleValue,
						PromotedQty,PromotedValue,RebateQty,RebateValue)
						Select 1,SchemeID,PayoutID,1,Division,Sum(SaleQty),Sum(SaleValue),
						Sum(PromotedQty),Sum(PromotedValue),Sum(RebateQty),Sum(RebateValue)
						From #tmpTradeRFA Where SchemeID = @SchemeID And PayoutID = @PayoutID
						Group By SchemeID,PayoutID,Division
					End
				End /* QPS Invoice Scheme Ends */
			End /* QPS Scheme Ends */

			If Not (@ApplicableOn = 2 And @ItemFree = 1)
			Begin
				/* Sale_Qty & Sale_value Updation in Progress Begins*/
				Delete From #tmpSales Where SKUCode Not In
				(Select Product_Code From 
				tbl_mERP_QPSDtlData Where SchemeID = @SchemeID And PayoutID = @PayoutID
				And (isNull(Rebate_Qty,0) > 0 Or isNull(Rebate_Val,0) > 0 Or IsNull(RFARebate_Val,0) > 0)
				Union
				Select Product_Code 
				From tbl_merp_NonQPSData NQD, tbl_merp_SchemePayoutPeriod SPP 
				Where NQD.SchemeID = @SchemeID
				And NQD.SchemeID = SPP.SchemeID
				And SPP.ID = @PayoutID
                And NQD.SlabID > 0
				And dbo.StripTimeFromDate(NQD.OriginalInvDate)  Between	
				dbo.StripTimeFromDate(SPP.PayoutPeriodFrom) And dbo.StripTimeFromDate(SPP.PayoutPeriodTo)
				)

				Insert Into #tmpDivisionWiseSales(Division,SalesQty,SalesValue)
				Select IC2.Category_Name,Sum(SaleQty),
				Sum(SaleValue) From #tmpSales ,Items I,
				ItemCategories IC, ItemCategories IC1,ItemCategories IC2
				Where #tmpSales.SKUCode = I.Product_Code And
				I.CategoryID = IC.CategoryID And
				IC.ParentID = IC1.CategoryID And
				IC1.ParentID = IC2.CategoryID 
				Group By IC2.Category_Name

				Update Sales Set Sales.SaleQty =Div.SalesQty ,Sales.SaleValue =Div.SalesValue 
				From #tmpSchemeSale Sales, #tmpDivisionWiseSales Div
				Where 
				Sales.SchemeID = @SchemeID
				And Sales.PayoutID = @PayoutID
				And Sales.Division = Div.Division
				And isNull(Sales.Division,'') <> ''
				/* Sale_Qty & Sale_value Updation in Progress Ends*/
			End

		End /* Trade Scheme Ends*/
		Else If @SchemeType = 4 /*Points Scheme Starts*/
		Begin

			Select @RedeemDate = dbo.StripTimeFromDate(Max(CreationDate)) From tbl_mERP_CSRedemption 
			Where PayoutID = @PayoutID
			And IsNull(RFAStatus,0) = 1

			Set @RedeemDate =  (Case when IsNull(@RedeemDate,'') <> '' then @RedeemDate else  '01/01/2099' end)
			If @ApplicableOn = 1 And (@ItemGroup = 1 Or @ItemGroup = 2)/* Item or spl category scheme*/
			Begin
				Insert Into #RFAInfo(InvoiceID, OutletCode, LineType, Division,SKUCode, UOM, SaleQty, SaleValue, 
									PromotedQty, PromotedValue, RebateQty, RebateValue,
									UOM1Conv, UOM2Conv, SalePrice, InvoiceType, SchemeOutlet, SchemeGroup)
				Select IA.InvoiceID, C.CustomerID, 0,Null as Division,
				ID.Product_Code as SKUCode, Null as UOM, Sum(ID.Quantity) as SaleQty, 
				Sum(ID.Amount) as SaleValue, 0 as PromotedQty, 0 as PromotedValue, 0 as RebateQty, 0 as RebateValue,
				0 as UOM1Conv, 0 as UOM2Conv, ID.SalePrice as SalePrice, IA.InvoiceType,
				Null as SchemeOutlet, Null as SchemeGroup
				From InvoiceAbstract IA, InvoiceDetail ID, Customer C 
				Where (Case IA.InvoiceType
						When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID = 
						IA.DocumentID
						And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)
						Else dbo.StripTimeFromDate(IA.InvoiceDate)
						End) Between @ActiveFrom And @ActiveTo
					And (Case IA.InvoiceType
						When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID = IA.DocumentID
							And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)
						Else dbo.StripTimeFromDate(IA.InvoiceDate) 
						End) Between @PayoutFrom And @PayoutTo
					And dbo.StripTimeFromDate(IA.CreationTime) <= @RedeemDate
				And IA.InvoiceType In (1,3,4)
				And IA.Status & 128 = 0 
				And IA.InvoiceID = ID.InvoiceID
				And IsNull(ID.Flagword, 0) = 0
				And IA.CustomerID = C.CustomerID
				Group By IA.InvoiceID, C.CustomerID,  ID.Product_Code,
				IA.InvoiceType, ID.SalePrice
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
					

					Fetch Next From SchemeOutletCur Into @CustomerID
				End
				Close SchemeOutletCur
				Deallocate SchemeOutletCur


				Delete From #RFAInfo Where IsNull(SchemeOutlet, 0) = 2


				/* Update Division , Market sku ,And Sub Category */
				Update RFA Set Division = IC2.Category_Name,UOM = U.Description,
				UOM1conv = I.UOM1_Conversion,UOM2conv = I.UOM2_Conversion
				From #RFAInfo RFA,Items I , ItemCategories IC, ItemCategories IC1,ItemCategories IC2,UOM U
				Where RFA.SKUCode = I.Product_Code And
				I.CategoryID = IC.CategoryID And
				IC.ParentID = IC1.CategoryID And
				IC1.ParentID = IC2.CategoryID And
				I.UOM = U.UOM
				


				/* Update  SchemeSKU  = 1 For Items which comes in any of the Product Scope of the scheme */
				Update #RFAInfo Set SchemeSKU = 1 
				Where SKUCode In(Select Product_Code From dbo.mERP_fn_Get_CSSku(@SchemeID))




				Delete From #RFAInfo Where IsNull(SchemeSKU, 0) = 0 



				If @QPS = 0 /*Non QPS Starts*/
				Begin
					If @ItemGroup = 1 /*Other than SplCategory scheme(Non QPS) - Start*/
					Begin
						
						Declare SKUCur Cursor For 
						Select InvoiceID, InvoiceType, SchemeGroup, SKUCode, Sum(SaleQty), 
						Sum(SaleValue),UOM1Conv,UOM2Conv
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
				End	/*Non QPS Ends*/
				Else /*QPS Starts*/
				Begin
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
							@SaleValue = Sum((Case When Invoicetype = 4 then (SaleValue * -1) Else (SaleValue) end)),  
							@UOM1Qty = Sum((case when InvoiceType = 4 then (SaleQty*-1) else (SaleQty) end)/UOM1Conv), 
							@UOM2Qty = Sum((Case When InvoiceType=4 then (SaleQty *-1) else (SaleQty) end)/UOM2Conv)
							From #RFAInfo
							Where OutletCode=@OutletCode and IsNull(SchemeOutlet, 0) = 1
							And IsNull(SchemeGroup, 0) = @SchemeGroup
							
							Select @PromotedQty = PromotedQty, @PromotedValue = PromotedValue, @UOMID = UOM,
							@RebateQty = RebateQty, @RebateValue = RebateValue
							From dbo.mERP_fn_GetPointsSchValue(@SchemeID, @SchemeGroup, @SaleQty, @SaleValue,@UOM1Qty, @UOM2Qty,1)
							
							If @UOMID = 1
								Update #RFAInfo Set PromotedQty = Case @SaleQty When 0 Then 0 Else 
                                                    (Case InvoiceType 
													When 4 Then (-1) * (@PromotedQty / @SaleQty) * SaleQty 
													Else (@PromotedQty / @SaleQty) * SaleQty 
													End) End,
													PromotedValue = Case InvoiceType
													When 4 Then (-1) * (@PromotedValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
													Else (@PromotedValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))) 
													End,
													RebateQty = Case @SaleQty When 0 Then 0 Else
													(Case InvoiceType 
													When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty 
													Else (@RebateQty / @SaleQty) * SaleQty 
													End) End,
													RebateValue =  Case @SaleQty When 0 Then 0 Else
													(Case InvoiceType 
													When 4 Then (-1) * (RebateValue / @SaleQty) * SaleQty 
													Else (RebateValue / @SaleQty) * SaleQty 
													End) End,
								TotalPoints = Case @SaleQty When 0 Then 0 Else ((@RebateQty / @SaleQty) * SaleQty) End,
								PointsValue = Case @SaleQty When 0 Then 0 Else ((@RebateValue / @SaleQty) * SaleQty) End
								Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1

							Else If @UOMID = 4
									Update #RFAInfo Set PromotedQty = Case @SaleQty When 0 Then 0 Else 
									(Case InvoiceType 
									When 4 Then (-1) * (@PromotedQty / @SaleQty) * SaleQty 
									Else (@PromotedQty / @SaleQty) * SaleQty 
									End) End,
									PromotedValue = Case InvoiceType
									When 4 Then (-1) * ((SaleValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * @PromotedValue)
									Else ((SaleValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * @PromotedValue)
									End,
									RebateQty = Case @SaleQty When 0 Then 0 Else 
									(Case InvoiceType 
									When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty 
									Else (@RebateQty / @SaleQty) * SaleQty 
									End) End,
									RebateValue = Case @SaleQty When 0 Then 0 Else 
									(Case InvoiceType 
									When 4 Then (-1) * (RebateValue / @SaleQty) * SaleQty 
									Else (RebateValue / @SaleQty) * SaleQty 
									End) End,
								TotalPoints = Case @SaleQty When 0 Then 0 Else ((@RebateQty / @SaleQty) * SaleQty) End,
								PointsValue = Case @SaleQty When 0 Then 0 Else ((@RebateValue / @SaleQty) * SaleQty) End
								Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1
							Else If @UOMID = 2
								Update #RFAInfo Set PromotedQty = Case @UOM1Qty When 0 Then 0 Else 
                                                    (Case InvoiceType
													When 4 Then (-1) * ((@PromotedQty / UOM1Conv) * SaleQty)
													Else ((@PromotedQty / @UOM1Qty) * SaleQty) 
													End) End, 
													PromotedValue = Case InvoiceType
													When 4 Then (-1) * (@PromotedValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
													Else (@PromotedValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))) 
													End,
													RebateQty = Case @SaleQty When 0 Then 0 Else
													(Case InvoiceType 
													When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty 
													Else (@RebateQty / @SaleQty) * SaleQty 
													End) End,
													RebateValue = Case @SaleQty When 0 Then 0 Else
													(Case InvoiceType 
													When 4 Then (-1) * (RebateValue / @SaleQty) * SaleQty 
													Else (RebateValue / @SaleQty) * SaleQty 
													End) End,
								TotalPoints = Case @SaleQty When 0 Then 0 Else ((@RebateQty / @SaleQty) * SaleQty) End,
								PointsValue = Case @SaleQty When 0 Then 0 Else ((@RebateValue / @SaleQty) * SaleQty) End
								Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1
							Else If @UOMID = 3
								Update #RFAInfo Set PromotedQty = Case @UOM2Qty When 0 Then 0 Else
													(Case InvoiceType
													When 4 Then (-1) * ((@PromotedQty / UOM2Conv) * SaleQty)
													Else ((@PromotedQty / @UOM2Qty) * SaleQty) 
													End) End, 
													PromotedValue = Case InvoiceType 
													When 4 Then (-1) * (@PromotedValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
													Else (@PromotedValue / Case @SaleValue When 0 Then 1 Else @SaleValue End) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))) 
													End,
													RebateQty = Case @SaleQty When 0 Then 0 Else
													(Case InvoiceType 
													When 4 Then (-1) * (@RebateQty / @SaleQty) * SaleQty 
													Else (@RebateQty / @SaleQty) * SaleQty 
													End) End,
													RebateValue = Case @SaleQty When 0 Then 0 Else
													(Case InvoiceType 
													When 4 Then (-1) * (RebateValue / @SaleQty) * SaleQty 
													Else (RebateValue / @SaleQty) * SaleQty 
													End) End,
								TotalPoints = Case @SaleQty When 0 Then 0 Else ((@RebateQty / @SaleQty) * SaleQty) End,
								PointsValue = Case @SaleQty When 0 Then 0 Else ((@RebateValue / @SaleQty) * SaleQty) End
								Where OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1
							Fetch Next From GroupCur Into @SchemeGroup,@OutletCode
						End
						Close GroupCur
						Deallocate GroupCur

					End /*SplCategory scheme(QPS) - End*/
				End/*QPS Ends*/
			End /* Item Spl Points scheme ends here */
			Else If @ApplicableOn = 2 /* Invoice based Point scheme */
			Begin
				Insert Into #RFAInfo (InvoiceID, InvoiceType,  OutletCode, RebateQty, RebateValue, Amount, SchemeID, SchemeOutlet, SchemeGroup) 
				Select IA.InvoiceID, IA.InvoiceType,C.CustomerID,0 as RebateQty,0 as RebateValue,IA.NetValue as Amount,
				0 as SchemeID,Null as SchemeOutlet,Null as SchemeGroup
				From InvoiceAbstract IA, Customer C
				Where IA.InvoiceType In (1,3,4)        
				And (IA.Status & 128)=0  
				And IA.CustomerID = C.CustomerID
				And (Case IA.InvoiceType
					When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID = 
					IA.DocumentID
					And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)--(Select dbo.mERP_fn_GetInvoiceDate(IA.InvoiceID, 1))
					Else dbo.StripTimeFromDate(IA.InvoiceDate)
					End) Between @ActiveFrom And @ActiveTo
				And (Case IA.InvoiceType
					When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID = IA.DocumentID
					And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID) --(Select dbo.mERP_fn_GetInvoiceDate(IA.InvoiceID, 1))
					Else dbo.StripTimeFromDate(IA.InvoiceDate)
					End) Between @PayoutFrom And @PayoutTo
				And dbo.StripTimeFromDate(IA.CreationTime) <= @RedeemDate

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

				If @QPS = 0
				Begin
					/* Non Qps starts*/
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
				End

				/*QPS - Start*/
				If @QPS = 1
				Begin
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
			End /* Invoice Based Points scheme ends */
			--Select * From #RFAInfo
			Update #RFAInfo Set RebateQty =  (-1) * RebateQty, RebateValue = (-1) * RebateValue,
			SaleQty = (-1) * SaleQty, SaleValue = (-1) * SaleValue, 
			TotalPoints =(-1)* TotalPoints , PointsValue =  (-1)* PointsValue
			Where InvoiceType = 4



			Insert Into #tmpSchemeSale(SchemeType,SchemeID,PayoutID,QPS,Division,SaleQty,SaleValue,
			PromotedQty,PromotedValue,RebateQty,RebateValue)
			Select 2,@SchemeID,@PayoutID,1,Division,Sum(isNull(SaleQty,0)),Sum(isNull(SaleValue,0)),
			Sum(isNull(PromotedQty,0)),Sum(isNull(PromotedValue,0)),Sum(isNull(TotalPoints,0)),Sum(isNull(PointsValue,0))
			From #RFAInfo Where SchemeOutlet = @QPS
			--Where (isNull(TotalPoints,0) > 0 Or isNull(PointsValue,0) > 0)
			Group By Division
		End/*Points Scheme Ends*/
		Fetch Next From ShemeCursor Into @SchemeID,@PayoutID,@QPS,@SchemeType,@ApplicableOn,@ItemGroup,@ActiveFrom,@ActiveTo,@PayoutFrom,@PayoutTo
	End
	Close ShemeCursor
	Deallocate ShemeCursor
	/* Trade Scheme & Points Scheme Ends*/

	
	/* To Insert Trade Schemes Which are submitted Begins*/
	Truncate Table #tmpScheme
	Insert Into #tmpScheme(SchemeID,PayoutID,QPS,SchemeType,ApplicableOn,ItemGroup,ActiveFrom,ActiveTo,PayoutFrom,PayoutTo)
	Select Distinct SA.SchemeID,SPP.ID,1,SA.SchemeType,SA.ApplicableOn,SA.ItemGroup,
	dbo.StripTimeFromDate(SA.ActiveFrom),dbo.StripTimeFromDate(SA.ActiveTo),
	dbo.StripTimeFromDate(SPP.PayoutPeriodFrom),dbo.StripTimeFromDate(SPP.PayoutPeriodTo)
	From tbl_mERP_SchemeAbstract SA,  tbl_mERP_SchemePayoutPeriod SPP  
	Where SA.Active = 1
	And SA.SchemeType In(1,2)
	And isNull(SPP.ClaimRFA,0) = 1
	And isNull(SA.RFAApplicable,0) = 1  
	And SA.SchemeID = SPP.SchemeID  
	And SPP.Active = 1    
	And Year(dbo.StripTimeFromDate(SPP.PayoutPeriodTo)) = @Year
	And Month(dbo.StripTimeFromDate(SPP.PayoutPeriodTo)) = @Month
	And dbo.StripTimeFromDate(SPP.PayoutPeriodTo) <= @ToDate  
	Order By SA.SchemeID

	Insert Into #tmpSchemeSale(SchemeType,SchemeID,PayoutID,QPS,Division,SaleQty,SaleValue,
	PromotedQty,PromotedValue,RebateQty,RebateValue)
	Select (Case RFA.SchemeType When N'SP' Then 1 When N'CP' Then 1 When N'Points' Then 2 End),
	SchemeID,PayoutID,1,RFA.Division,Sum(isNull(RFA.SaleQty,0)),Sum(isNull(RFA.SaleValue,0)),
	Sum(isNull(RFA.PromotedQty,0)),Sum(isNull(RFA.PromotedValue,0)),Sum(isNull(RFA.RebateQty,0)),
	Sum(isNull(RFA.RebateValue,0))
	From #tmpScheme [Scheme] , tbl_mERP_RFAAbstract RFA
	Where [Scheme].SchemeID = RFA.DocumentID
	And RFA.PayOutFrom = [Scheme].PayoutFrom 
	And RFA.PayOutTo = [Scheme].PayoutTo 
	And isNull(RFA.Status,0) <> 5
	And RFA.SchemeType in(N'SP',N'CP')
	And (Abs(isNull(RFA.RebateQty,0)) > 0 Or Abs(isNull(RFA.RebateValue,0)) > 0)
	Group By RFA.SchemeType,SchemeID,PayoutID,RFA.Division
	/* To Insert Trade Schemes Which are submitted Ends*/

	/* Display Scheme Starts */
	Truncate Table #tmpScheme
	Insert Into #tmpScheme(SchemeID,PayoutID,SchemeType,ActiveFrom,ActiveTo,PayoutFrom,PayoutTo)
	Select Distinct SA.SchemeID,SPP.ID,SA.SchemeType,
	dbo.StripTimeFromDate(SA.ActiveFrom),dbo.StripTimeFromDate(SA.ActiveTo),
	dbo.StripTimeFromDate(SPP.PayoutPeriodFrom),dbo.StripTimeFromDate(SPP.PayoutPeriodTo)
	From tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemePayoutPeriod SPP  
	Where SA.SchemeID = SPP.SchemeID  
	And SA.Active = 1
	And SA.SchemeType In(3)
	--And isNull(SPP.ClaimRFA,0) = 0   
	And isNull(SA.RFAApplicable,0) = 1  
	And SA.SchemeID = SPP.SchemeID  
	And SPP.Active = 1    
	And Year(dbo.StripTimeFromDate(SPP.PayoutPeriodTo)) = @Year
	And Month(dbo.StripTimeFromDate(SPP.PayoutPeriodTo)) = @Month
	And dbo.StripTimeFromDate(SPP.PayoutPeriodTo) <= @ToDate  
	Order By SA.SchemeID


	/*If Display scheme exists*/
	If (Select Count(SchemeID) From #tmpScheme Where SchemeType = 3)>= 1
	Begin
		Insert Into #tmpSchemeSale(SchemeType,SchemeID,PayoutID,RebateValue)
		Select 3,[Scheme].SchemeID,PayoutID,SA.Budget
		From #tmpScheme [Scheme] , tbl_mERP_SchemeAbstract SA
		Where [Scheme].SchemeID = SA.SchemeID
		And [Scheme].SchemeType = 3
		
	End
	/* Display Scheme Ends */


	/* Trade Scheme And Display Scheme */
	Insert Into #tmpFinal([SchemeType],[WD Code],[WD Dest],FromDate,ToDate,Division,[Activity Code],[Activity Desc],
	[Level],[Scheme Type],QPS,[Scheme From],[Scheme To],[Payout_From],[Payout_To],[Sales_Qty],[Sales_Value],
	[Promoted_Qty],[Promoted_Value],[Rebate_Liab_Qty],[Rebate_Liab_Value])
	Select SS.SchemeType,@WDCode,@WDDest,@FromDate ,@ToDate,Division,SA.ActivityCode,cast(SA.Description as nvarchar(255)),
	(Case SS.SchemeType When 1 Then N'Item' When 2 Then N'Item' When 3 Then N'Outlet' End),
	(Case SA.SchemeType When 1 Then N'SP' When 2 Then N'CP' When 3 Then N'Display'  When 4 Then N'Points' End),
	(Case SS.SchemeType When 3 Then '' Else (Case isNull(QPS,0) When 1 Then 'MAIN' End) End),
	 ActiveFrom,ActiveTo,PayoutPeriodFrom,PayoutPeriodTo,
	(Case SS.SchemeType When 3 Then NULL Else Max(isNull(SaleQty,0)) End),
	(Case SS.SchemeType When 3 Then NULL Else Max(isNull(SaleValue,0)) End),
	(Case SS.SchemeType When 3 Then NULL Else Sum(isNull(PromotedQty,0)) End),
	(Case SS.SchemeType When 3 Then NULL Else Sum(isNull(PromotedValue,0)) End),
	(Case SS.SchemeType When 3 Then NULL Else Sum(isNull(RebateQty,0)) End),
	(Case SS.SchemeType When 3 Then SA.budget Else Sum(isNull(RebateValue,0)) End)
	From #tmpSchemeSale SS ,tbl_mERP_SchemeAbstract SA,tbl_mERP_SchemePayoutperiod SPP
	Where SS.SchemeType In(1,3)
	And SS.SchemeID = SA.SchemeID
	And SA.SchemeID = SPP.SchemeID
	And SS.PayoutID = SPP.ID
	Group By SS.SchemeType,Division,SA.ActivityCode,SA.Description,SA.SchemeType,ActiveFrom,ActiveTo,PayoutPeriodFrom,PayoutPeriodTo,
	SS.QPS,SA.budget
	Union/* Points Scheme */
	Select SS.SchemeType,@WDCode,@WDDest,@FromDate ,@ToDate,Division,SA.ActivityCode,cast(SA.Description as nvarchar(255)),
	(Case SS.SchemeType When 1 Then N'Item' When 2 Then N'Item' When 3 Then N'Outlet' End),
	(Case SA.SchemeType When 1 Then N'SP' When 2 Then N'CP' When 3 Then N'Display'  When 4 Then N'Points' End),
	(Case SS.SchemeType When 3 Then '' Else (Case isNull(QPS,0) When 1 Then 'MAIN' End) End),
	 ActiveFrom,ActiveTo,PayoutPeriodFrom,PayoutPeriodTo,
	(Case SS.SchemeType When 3 Then NULL Else Sum(isNull(SaleQty,0)) End),
	(Case SS.SchemeType When 3 Then NULL Else Sum(isNull(SaleValue,0)) End),
	(Case SS.SchemeType When 3 Then NULL Else Sum(isNull(PromotedQty,0)) End),
	(Case SS.SchemeType When 3 Then NULL Else Sum(isNull(PromotedValue,0)) End),
	(Case SS.SchemeType When 3 Then NULL Else Sum(isNull(RebateQty,0)) End),Sum(isNull(RebateValue,0))
	From #tmpSchemeSale SS ,tbl_mERP_SchemeAbstract SA,tbl_mERP_SchemePayoutperiod SPP
	Where SS.SchemeType In(2)
	And SS.SchemeID = SA.SchemeID
	And SA.SchemeID = SPP.SchemeID
	And SS.PayoutID = SPP.ID
	Group By SS.SchemeType,Division,SA.ActivityCode,SA.Description,SA.SchemeType,ActiveFrom,ActiveTo,PayoutPeriodFrom,PayoutPeriodTo, 
	SS.QPS
	Union
	/* Loyalty Begins*/
	Select 4,@WDCode,@WDDest,@FromDate ,@ToDate,'',Loyalty.LoyaltyName,Loyalty.LoyaltyName,
	N'Outlet' as 'Level',N'GV' as 'Scheme Type','',@FromDate ,@ToDate,@FromDate ,@ToDate,
	NULL,NULL,NULL,NULL,NULL,Sum(isNull(NoteValue,0))
	From CreditNote Inner join Loyalty On CreditNote.LoyaltyID = Loyalty.LoyaltyID
	Where IsNull(Flag, 0) = 2
	--and IsNull(ClaimRFA,0) = 0
	and IsNull(Status,0) not in (64,128)
	And DocumentDate Between @FromDate And @ToDate
	Group By Loyalty.LoyaltyName
	/*Loyalty Ends*/


	Select * From #tmpFinal
	Order by SchemeType,[Activity Code],QPS,Division

DropTablenOut:

	Drop Table #tmpScheme
	Drop Table #tmpTradeRFA
	Drop Table #tmpSchemeSale
	Drop Table #tmpSales
	Drop Table #tmpDivisionWiseSales
	Drop Table #RFAInfo
	Drop Table #tmpFinal
OvernOut:
End
