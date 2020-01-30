Create Procedure [dbo].[mERP_spr_RFAReportDetail_Points]
( @FilterData nvarchar(2000),
  @FromDate Datetime, @ToDate Datetime, @RFA1Status nvarchar(1000),		
  @ActCode nVarchar(255), @SchemeName nVarchar(255),
  @PRODUCT_HIERARCHY nVarchar(255))           
AS    
Begin

    Set Dateformat dmy

    If @Product_Hierarchy = '%' Or @Product_Hierarchy = 'Division'
        Set @Product_Hierarchy = N'Division'
    If @Product_Hierarchy = 'Sub-Category' or @Product_Hierarchy = 'Sub Category' or @Product_Hierarchy = 'Sub_Cat'
        Set @Product_Hierarchy = N'Sub_Category'
    If @Product_Hierarchy = 'MarketSKU' or @Product_Hierarchy = 'Market-SKU' or  @Product_Hierarchy = 'Market SKU'
        Set @Product_Hierarchy = N'Market_SKU' 
    If @Product_Hierarchy = 'System_SKU' or @Product_Hierarchy = 'System-SKU' or @Product_Hierarchy = 'SystemSKU'
        set @Product_Hierarchy = 'System SKU' 


    Declare @SUBTOTAL nVarchar(50)    
    Declare @GRNTOTAL nVarchar(50)    
    Declare @QPSCRDTNOTE nVarchar(50)    

    Set @SUBTOTAL = dbo.LookupDictionaryItem(N'Sub Total:', Default)     
    Set @GRNTOTAL = dbo.LookupDictionaryItem(N'Grand Total:', Default)     

    Declare @Flag Int
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
    Declare @Payoutid as int
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
    Declare @SchemeID Int
    Declare @Pos Int
    Declare @OutletCode nVarchar(255)
    Declare @RFADocID int
    Declare @AbsPayoutID int
    Declare @Delimiter char(1)
    Set @Delimiter = Char(15)

    Declare @TmpScheme Table([RowID] Int Identity(1,1), Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, [Name] nvarchar(2550) COLLATE SQL_Latin1_General_CP1_CI_AS,
        UOM nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, [LineType] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, [SaleQty] Decimal(18,6),
        [SaleValue] Decimal(18,6), PromotedQty Decimal(18,6), PromotedValue Decimal(18,6),
        [TaxPercentage] Decimal(18,6),[TaxAmount] Decimal(18,6), RebateQty Decimal(18,6), RebateValue Decimal(18,6))

    Declare @TmpResult Table([RowID] Int Identity(1,1),Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, [Name] nvarchar(2550) COLLATE SQL_Latin1_General_CP1_CI_AS,
        UOM nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, [LineType] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, [SaleQty] Decimal(18,6),
        [SaleValue] Decimal(18,6), PromotedQty Decimal(18,6), PromotedValue Decimal(18,6),
        [TaxPercentage] Decimal(18,6),[TaxAmount] Decimal(18,6), RebateQty Decimal(18,6), RebateValue Decimal(18,6))	


    Declare @TmpGrandTot Table([RowID] Int Identity(1,1),Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, [Name] nvarchar(2550) COLLATE SQL_Latin1_General_CP1_CI_AS,
        UOM nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, [LineType] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, [SaleQty] Decimal(18,6),
        [SaleValue] Decimal(18,6), PromotedQty Decimal(18,6), PromotedValue Decimal(18,6),
        [TaxPercentage] Decimal(18,6),[TaxAmount] Decimal(18,6), RebateQty Decimal(18,6), RebateValue Decimal(18,6))	


    Declare @RFAID int

    Create table #tmp (Id int identity(1,1), Data nVarchar(100))

    Set @Flag = 0
    Set @ToDate = dbo.StripTimeFromDate(@ToDate)
    Set @FromDate = dbo.StripTimeFromDate(@FromDate)

    Insert Into #tmp(data)
    select * from dbo.sp_splitin2Rows(@FilterData, @Delimiter)


    select @SchemeID = Data from #tmp where ID = 1
    select @ActivityCode = Data from #tmp where ID = 2
    select @RFADocID = Data from #tmp where ID = 3
    Select @AbsPayoutID = Data from #tmp where ID = 4
    Select @RFAID = Data from #tmp where ID = 5 

    Declare @RFAStatus int
    select @RFAStatus = RFAApplicable from tbl_merp_schemeAbstract where SchemeID = @SchemeID

    Create Table #RFAInfo(SR Int Identity , InvoiceID Int, BillRef nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, OutletCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
    RCSID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, ActiveInRCS nVarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS, LineType nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Division nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,SubCategory nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, MarketSKU nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	SKUCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,UOM nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, SaleQty Decimal(18, 6), SaleValue Decimal(18, 6),
    PromotedQty Decimal(18, 6), PromotedValue Decimal(18, 6), FreeBaseUOM nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
    RebateQty Decimal(18, 6), RebateValue Decimal(18, 6), PriceExclTax Decimal(18, 6),
    TaxPercentage Decimal(18,6), TaxAmount Decimal(18, 6), PriceInclTax Decimal(18, 6),
    SchemeDetail nVarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS, Serial Int, Flagword Int, Amount Decimal(18, 6),
    SchemeID Int, SlabID Int, PTR Decimal(18,6), TaxCode Decimal(18,6), BudgetedValue Decimal(18,6),
    FreeSKUSerial Int,SalePrice Decimal(18,6),  UOM1Conv Decimal(18,6), UOM2Conv Decimal(18,6),
    InvoiceType Int, SchemeOutlet Int, SchemeSKU Int Default(0), SchemeGroup Int, TotalPoints Decimal(18,6),
    PointsValue Decimal(18,6), ReferenceNumber nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, Description nVarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS, PayoutID int,TaxOnQty int)


    Begin/*Points Scheme - Start*/

        If Isnull(@RFAStatus,0) = 1
        Begin
            Select @SchemeType = ST.SchemeType,
            @ActivityCode = SA.ActivityCode,
            @CSSchemeID = SA.CS_RecSchID,
            @ActivityType = SA.Description,
            @ActiveFrom = SA.ActiveFrom,
            @ActiveTo = SA.ActiveTo,
            @PayoutFrom = SPP.PayoutPeriodFrom,
            @PayoutTo = SPP.PayoutPeriodTo,
            --@Payoutid = SPP.ID,
            @ExpiryDate = SA.ExpiryDate,
            @ApplicableOn = Case When SA.ApplicableOn =1 And SA.ItemGroup = 1 Then 'ITEM'
                When SA.ApplicableOn =1 And SA.ItemGroup = 2 Then 'SPL_CAT'
                When SA.ApplicableOn = 2 Then 'INVOICE'
                End,
            @ItemGroup = Itemgroup,
            @PayoutID =  SPP.ID
            From tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemeType ST, tbl_mERP_SchemePayoutPeriod SPP
            Where SA.SchemeID = @SchemeID
            And IsNull(SA.RFAApplicable, 0) = 1
            And SA.SchemeID = SPP.SchemeID
            And SA.SchemeType = ST.ID
            And SPP.ID = @AbsPayoutID	
            --	and dbo.stripTimeFromDate(@ToDate) Between dbo.stripTimeFromDate(SPP.PayoutPeriodFrom) and dbo.stripTimeFromDate(SPP.PayoutPeriodTo)
            and dbo.stripTimeFromdate(SPP.PayoutPeriodTo) Between @FromDate And @ToDate
        End
        Else
        Begin
            Select @SchemeType = ST.SchemeType,
            @ActivityCode = SA.ActivityCode,
            @CSSchemeID = SA.CS_RecSchID,
            @ActivityType = SA.Description,
            @ActiveFrom = SA.ActiveFrom,
            @ActiveTo = SA.ActiveTo,
            @PayoutFrom = SPP.PayoutPeriodFrom,
            @PayoutTo = SPP.PayoutPeriodTo,
            @Payoutid = SPP.ID,
            @ExpiryDate = SA.ExpiryDate,
            @ApplicableOn = Case When SA.ApplicableOn =1 And SA.ItemGroup = 1 Then 'ITEM'
                When SA.ApplicableOn =1 And SA.ItemGroup = 2 Then 'SPL_CAT'
                When SA.ApplicableOn = 2 Then 'INVOICE'
                End,
            @ItemGroup = Itemgroup,
            @PayoutID =  SPP.ID
            From tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemeType ST, tbl_mERP_SchemePayoutPeriod SPP
            Where SA.SchemeID = @SchemeID
            And SA.SchemeID = SPP.SchemeID
            And IsNull(SA.RFAApplicable, 0) = 0
        End

        Select @RedeemDate = dbo.StripTimeFromDate(Max(CreationDate)) From tbl_mERP_CSRedemption 
            Where PayoutID = @PayoutID
            And IsNull(RFAStatus,0) = 1

        Set @RedeemDate = (Case when IsNull(@RedeemDate,'') <> '' then @RedeemDate else  '01/01/2099' end)
			
        If IsNull(@RFADocID,0) > 0
        Begin
            If (Select Count(*) From tbl_mERP_RFAAbstract Where RFADocID = @RFADocID And IsNull(Status,0) <> 5 And (AppOn = 'SPL_CAT' Or AppOn = 'ITEM' Or AppOn = 'INVOICE')) > 0
            Begin
                Insert Into @TmpScheme
                Select RD.Division, ( Case @PRODUCT_HIERARCHY 
	                When 'Division' then RD.Division
	                When 'Sub_Category' then RD.SubCategory
	                When 'Market_SKU' then RD.MarketSKU
	                When 'System SKU' then RD.SystemSKU End) As 'Code',
                '' AS 'Name',
                RD.UOM, RD.LineType 'Type', 
                --SaleQty as SaleQty,
                ( Case RD.SaleQty When 0 then null else RD.SaleQty end) As SaleQty, 
        ( Case RD.SaleValue When 0 then null else RD.SaleValue end) As SaleValue, 
                --SaleValue as SaleValue, 
                ( Case RD.PromotedQty When 0 then null Else RD.PromotedQty end) as PromotedQty, 
                ( Case RD.PromotedValue When 0 then null Else RD.PromotedValue end) as PromotedValue, 
                --PromotedValue, Tax_Percentage as TaxPercentage, Tax_Amount as TaxAmount
                ( Case RD.Tax_Percentage When 0 then null Else RD.Tax_Percentage end) as TaxPercentage, 
                ( Case RD.Tax_Amount When 0 then null Else RD.Tax_Amount end) as Tax_Amount, 
                ( Case RD.RebateQty When 0 then null Else RD.RebateQty end) as RebateQty, 
                ( Case RD.RebateValue When 0 then null Else RD.RebateValue end) as RebateValue
                --, RebateQty as RebateQty, RebateValue as RebateValue
                From tbl_mERP_RFAAbstract RA, Customer Cust, tbl_mERP_RFADetail RD
                Where RA.DocumentID = @SchemeID And RA.RFAID = RD.RFAID And IsNull(RA.Status,0) <> 5
                And RA.PayOutFrom = @PayoutFrom And RA.PayOutTo = @PayoutTo 
                --RFAID In (Select RFAID From tbl_mERP_RFAAbstract Where RFADocID = @RFADocID And DocumentID = @SchemeID and RFAID = @RFAID and IsNull(Status,0) <> 5) 
                And RA.ActivityCode = @ActivityCode
                And RD.CustomerID = Cust.CustomerID
                --			Group By Division, SubCategory, MarketSKU, SystemSKU, Description,  UOM, Linetype, SaleQty,
                --			SaleValue, PromotedQty, PromotedValue, RebateQty, Tax_Percentage, Tax_Amount, RebateValue 

                If IsNull(@PRODUCT_HIERARCHY, '') = 'System SKU'
                Begin
                    Update @TmpScheme Set [Name] = I.Description
                    From @TmpScheme sch Inner join Items I
                    On Sch.Code = I.Product_Code	
                End
                Else
                Begin
                    Update @TmpScheme Set [Name] = IC.Description
                    From @TmpScheme sch Inner join ItemCategories IC
                    On Sch.Code = IC.Category_Name
                End
                Goto Common
            End
        End
        Else If @ApplicableOn = 'ITEM' Or @ApplicableOn = 'SPL_CAT'
        Begin --@ApplicableOn = 'ITEM'

            If Isnull(@RFAStatus,0) = 1
            Begin
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
            End
            Else
            Begin
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
		                End) Between @Fromdate And @Todate
                And IA.InvoiceType In (1,3,4)
                And IA.Status & 128 = 0
                And IA.InvoiceID = ID.InvoiceID
                And IsNull(ID.Flagword, 0) = 0
                And IA.CustomerID = C.CustomerID
                And dbo.StripTimeFromDate(IA.CreationTime) <= @RedeemDate
                Group By IA.InvoiceID, IA.DocumentID, C.CustomerID, C.RCSOutletID, ID.Product_Code, IA.InvoiceType, ID.SalePrice, IA.ReferenceNumber, IA.Status,ID.TaxOnQty
                Order By IA.InvoiceID
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

            /* Update Division , Market sku ,And Sub Category */
            If IsNull(@PRODUCT_HIERARCHY,'') = 'Division'
            Begin
                Update RFA Set Division = IC2.Category_Name, Description = IC2.Description  --, SubCategory = IC1.Category_Name, MarketSKU = IC.Category_Name
                , UOM = U.Description,
                UOM1conv = I.UOM1_Conversion,UOM2conv = I.UOM2_Conversion
                From #RFAInfo RFA,Items I , ItemCategories IC, ItemCategories IC1,ItemCategories IC2,UOM U
                Where RFA.SKUCode = I.Product_Code And
                I.CategoryID = IC.CategoryID And
                IC.ParentID = IC1.CategoryID And
                IC1.ParentID = IC2.CategoryID And
                I.UOM = U.UOM
            End
            Else If IsNull(@PRODUCT_HIERARCHY,'') = 'Sub_Category'
            Begin
                Update RFA Set SubCategory = IC1.Category_Name, Description = IC1.Description 
                , UOM = U.Description,
                UOM1conv = I.UOM1_Conversion,UOM2conv = I.UOM2_Conversion
                From #RFAInfo RFA,Items I , ItemCategories IC, ItemCategories IC1,ItemCategories IC2,UOM U
                Where RFA.SKUCode = I.Product_Code And
                I.CategoryID = IC.CategoryID And
                IC.ParentID = IC1.CategoryID And
                IC1.ParentID = IC2.CategoryID And
                I.UOM = U.UOM
            End
            Else If IsNull(@PRODUCT_HIERARCHY,'') = 'Market_SKU'
            Begin
                Update RFA Set MarketSKU = IC.Category_Name, Description = IC.Description 
                , UOM = U.Description,
                UOM1conv = I.UOM1_Conversion,UOM2conv = I.UOM2_Conversion
                From #RFAInfo RFA,Items I , ItemCategories IC, ItemCategories IC1,ItemCategories IC2,UOM U
                Where RFA.SKUCode = I.Product_Code And
                I.CategoryID = IC.CategoryID And
                IC.ParentID = IC1.CategoryID And
                IC1.ParentID = IC2.CategoryID And
                I.UOM = U.UOM
            End
            Else If IsNull(@PRODUCT_HIERARCHY,'') = 'System SKU'
            Begin
                Update RFA Set Description = I.Description 
                , UOM = U.Description,
                UOM1conv = I.UOM1_Conversion,UOM2conv = I.UOM2_Conversion
                From #RFAInfo RFA, Items I , ItemCategories IC, ItemCategories IC1,ItemCategories IC2,UOM U
                Where RFA.SKUCode = I.Product_Code And
                I.CategoryID = IC.CategoryID And
                IC.ParentID = IC1.CategoryID And
                IC1.ParentID = IC2.CategoryID And
                I.UOM = U.UOM
            End

            /*Delete non scheme SKU*/
            Delete From #RFAInfo Where IsNull(SchemeSKU, 0) = 0

            /*Non QPS - Start*/
            If @ItemGroup = 1 /*Other than SplCategory scheme(Non QPS) - Start*/
            Begin
                Declare SKUCur Cursor For
                Select InvoiceID, InvoiceType, SchemeGroup, SKUCode, Sum(SaleQty), 
                Sum(SaleValue),
                --Sum(SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))),  
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
                    --				PromotedValue = Case InvoiceType
                    --				When 4 Then (-1) * (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
                    --				Else (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))) End,

                    PromotedValue = Case InvoiceType
                        When 4 Then (-1) * ((SaleValue / @SaleValue) * @PromotedValue)
                        Else ((SaleValue / @SaleValue) * @PromotedValue)
                        End,
                    --				PromotedValue = Case InvoiceType
                    --					When 4 then (-1) * (@PromotedValue / @SaleValue) * (@SaleValue)	
                    --					Else (@PromotedValue / @SaleValue) * (@SaleValue)	
                    --					End,	
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
                        --Sum(SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))), 
                        Sum((Case when Invoicetype = 4 then -1 Else 1 End) * SaleValue), 
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
                        Where SKUCode = @SKUCode
                        And OutletCode = @OutletCode and IsNull(SchemeOutlet, 0) = 1
							
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
                    @SaleValue = Sum((Case When Invoicetype = 4 then (SaleValue * -1)
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
                        --				PromotedValue = Case InvoiceType
                        --				When 4 Then (-1) * (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100))))
                        --				Else (@PromotedValue / @SaleValue) * (SaleQty * (SalePrice + (SalePrice * (TaxCode/100)))) 
                        --				End,

                        PromotedValue = Case InvoiceType
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
            If Isnull(@RFAStatus,0) = 1
            Begin	
                Insert Into #RFAInfo (InvoiceID, InvoiceType, OutletCode, RCSID, RebateQty, RebateValue, Amount, SchemeID, SchemeOutlet, SchemeGroup, PayoutID)
                Select IA.InvoiceID, IA.InvoiceType,
                C.CustomerID as OutletCode,
                IsNull(C.RCSOutletID, '') as RCSID,
                Null as RebateQty,
                Null as RebateValue,
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
                And dbo.StripTimeFromDate(IA.CreationTime) <= @RedeemDate
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
            End
            Else
            Begin
                Insert Into #RFAInfo (InvoiceID, InvoiceType, OutletCode, RCSID, RebateQty, RebateValue, Amount, SchemeID, SchemeOutlet, SchemeGroup, PayoutID)
                Select IA.InvoiceID, IA.InvoiceType,
                C.CustomerID as OutletCode,
                IsNull(C.RCSOutletID, '') as RCSID,
                Null as RebateQty,
                Null as RebateValue,
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
                And dbo.StripTimeFromDate(IA.CreationTime) <= @RedeemDate
                --And dbo.StripTimeFromDate(IA.InvoiceDate) Between @PayoutFrom And @PayoutTo
                And (Case IA.InvoiceType
                    When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID =
                    IA.DocumentID
                    And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)--(Select dbo.mERP_fn_GetInvoiceDate(IA.InvoiceID, 1))
                    Else dbo.StripTimeFromDate(IA.InvoiceDate)
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
					-- CC Added as on 23.07.2010
                RebateQty = Case InvoiceType
                    When 4 Then (-1) * (@RebateQty / @Value) * Amount
                    Else (@RebateQty / @Value) * Amount
                    End,
                RebateValue = Case InvoiceType
                    When 4 Then (-1) * (@RebateValue / @Value) * Amount
                    Else (@RebateValue / @Value) * Amount
                    End,
						-- CC Added as on 23.07.2010
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
                --			PromotedValue =  Case InvoiceType
                --			When 4 Then (-1)* (@PromotedValue/@SaleValue) * Amount
                --			Else (@PromotedValue/@SaleValue) * Amount
                --			End,
                PromotedValue = Case InvoiceType
                    When 4 Then (-1) * ((SaleValue / @SaleValue) * @PromotedValue)
                    Else ((SaleValue / @SaleValue) * @PromotedValue)
                    End,
                -- CC Added as on 23.07.2010
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
                            Update #RFAInfo Set RebateQty = Case InvoiceType
                                When 4 Then (1) * (@AllotedInvPoints/@InvoicePoints) * IsNull(TotalPoints, 0)
                                Else (@AllotedInvPoints/@InvoicePoints) * IsNull(TotalPoints, 0)
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
            -- RebateQty =  (-1) * RebateQty, RebateValue = (-1) * RebateValue,
        Update #RFAInfo Set 
        SaleQty = (-1) * SaleQty, SaleValue = (-1) * SaleValue
        Where InvoiceType = 4

        Common:
        If @ApplicableOn = 'Invoice' And ((Select Count(*) From #RFAInfo Where FlagWord = 1) <= 0)
        Begin	
            Insert Into @TmpScheme(Division, Code, [Name], UOM, Linetype, SaleQty, SaleValue,PromotedQty,PromotedValue, 
            RebateQty, RebateValue)
            Select '' ,'','','','',Sum(RFA.SaleQty),Sum(RFA.SaleValue),
            Sum(RFA.PromotedQty),Sum(RFA.PromotedValue),
            Sum(RFA.RebateQty),Sum(RFA.RebateValue)
            From   #RFAInfo RFA
        End
        Else If (Select Count(*) From #RFAInfo) >= 1
        Begin
            If @Product_Hierarchy = 'System SKU'
            Begin
                Insert Into @TmpScheme(Division, Code, [Name], UOM, Linetype, SaleQty, SaleValue,PromotedQty,PromotedValue, 
                TaxPercentage, TaxAmount, RebateQty, RebateValue)
                Select RFA.Division, RFA.SKUCode, I.ProductName, RFA.UOM, LineType, Sum(RFA.SaleQty), Sum(RFA.SaleValue),
                Sum(RFA.PromotedQty),Sum(RFA.PromotedValue), Null, Null,
                Sum(RFA.RebateQty),Sum(RFA.RebateValue)
                From   #RFAInfo RFA,Items I
                Where  
                RFA.SchemeID = @SchemeID
                And I.Product_Code = RFA.SKUCode 
                Group By RFA.Division ,RFA.SKUCode,I.ProductName,RFA.UOM,LineType,TaxCode
                Order By RFA.Division,LineType Desc,I.ProductName
            End
            Else IF @Product_Hierarchy = 'Market_SKU'
            Begin
                Insert Into @TmpScheme(Division, Code, [Name], UOM, Linetype, SaleQty, SaleValue,PromotedQty,PromotedValue, 
                TaxPercentage, TaxAmount, RebateQty, RebateValue)
                Select RFA.Division ,IC.CategoryID,RFA.MarketSKU, RFA.UOM, LineType, Sum(RFA.SaleQty),Sum(RFA.SaleValue),
                Sum(RFA.PromotedQty),Sum(RFA.PromotedValue),Null, Null,
                Sum(RFA.RebateQty),Sum(RFA.RebateValue)
                From   #RFAInfo RFA,ItemCategories IC
                Where  
                RFA.SchemeID = @SchemeID
                And IC.Category_Name = RFA.MarketSKU 
                Group By RFA.Division ,RFA.MarketSKU,IC.CategoryID,RFA.UOM,LineType,TaxCode
                Order By RFA.Division,LineType Desc,RFA.MarketSKU
            End		
            Else IF @Product_Hierarchy = 'Sub_Category'
            Begin
                Insert Into @TmpScheme(Division, Code, [Name], UOM, Linetype, SaleQty, SaleValue,PromotedQty,PromotedValue, 
                TaxPercentage, TaxAmount, RebateQty, RebateValue)
                Select RFA.Division ,IC.CategoryID,RFA.SubCategory,RFA.UOM,LineType,Sum(RFA.SaleQty),Sum(RFA.SaleValue),
                Sum(RFA.PromotedQty),Sum(RFA.PromotedValue),Null, Null,
                Sum(RFA.RebateQty),Sum(RFA.RebateValue)
                From   #RFAInfo RFA,ItemCategories IC
                Where  
                RFA.SchemeID = @SchemeID
                And IC.Category_Name = RFA.SubCategory 
                Group By RFA.Division ,RFA.SubCategory,IC.CategoryID,RFA.UOM,LineType,TaxCode
                Order By RFA.Division,LineType Desc,RFA.SubCategory

            End
            Else IF @Product_Hierarchy = 'Division'
            Begin
                Insert Into @TmpScheme(Division, Code, [Name], UOM, Linetype, SaleQty, SaleValue,PromotedQty,PromotedValue, 
                TaxPercentage, TaxAmount, RebateQty, RebateValue)
                Select RFA.Division ,IC.CategoryID,RFA.Division,RFA.UOM,LineType,Sum(RFA.SaleQty),Sum(RFA.SaleValue),
                Sum(RFA.PromotedQty),Sum(RFA.PromotedValue),Null, Null,
                Sum(RFA.RebateQty),Sum(RFA.RebateValue)
                From   #RFAInfo RFA,ItemCategories IC
                Where  
                RFA.SchemeID = @SchemeID
                And IC.Category_Name = RFA.Division 
                Group By RFA.Division ,RFA.Division,IC.CategoryID,RFA.UOM,LineType,TaxCode
                Order By RFA.Division,LineType Desc
            End
        End


	--        Insert Into @TmpScheme(Division, Code, [Name], UOM, Linetype, SaleQty, SaleValue,PromotedQty,PromotedValue, 
	--		 TaxPercentage, TaxAmount, RebateQty, RebateValue)
	--		Select Division, ( Case @PRODUCT_HIERARCHY 
	--								When 'Division' then Division
	--								When 'Sub_Category' then SubCategory
	--								When 'Market_SKU' then MarketSKU
	--								When 'System SKU' then SKUcode End) As 'Code',
	--		Description AS 'Name',
	--		UOM, LineType, SaleQty as SaleQty,
	--		SaleValue as SaleValue, PromotedQty, 
	--		--PromotedValue, 
	--		(Case  isNull(PromotedValue,0) When 0 Then NULL Else PromotedValue End),
	--
	--		TaxPercentage, TaxAmount,
	--		--FreeBaseUOM, 
	--        --RebateQty as RebateQty, Sum(IsNull(RebateValue, 0)) as RebateValue
	--		RebateQty as RebateQty, RebateValue as RebateValue
	--		From #RFAInfo
	--		Group By InvoiceID, OutletCode, RCSID, ActiveInRCS, Division, SubCategory, MarketSKU, SKUCode, UOM, SaleQty,
	--		SaleValue, PromotedQty, PromotedValue,-- FreeBaseUOM,
	--        RebateQty, BillRef, Linetype, TaxPercentage, TaxAmount --,Cust.Company_Name
	--        ,Description, RebateValue
	--
	--	End

	-- Common:


        If Exists(Select * From @TmpScheme Where isNull(Division,'') <> '') 
        Begin
            Declare @Div nVarchar(50)
            Declare Cur_Div Cursor For
            Select Distinct Division From @TmpScheme order by Division 
            Open Cur_Div
            Fetch From Cur_Div Into @Div
            While @@Fetch_Status = 0
            Begin
                Insert Into @TmpResult(Division, Code, [Name], UOM, Linetype, SaleQty, SaleValue,PromotedQty,PromotedValue, 
                TaxPercentage, TaxAmount, RebateQty, RebateValue)
                Select Division, Code, [Name], UOM, Linetype, Sum(SaleQty), Sum(SaleValue),Sum(PromotedQty),Sum(PromotedValue), 
                max(TaxPercentage), Sum(TaxAmount), Sum(RebateQty), Sum(RebateValue) 
                From  @TmpScheme Where Division = @Div 
				group by Division, Code, [Name], UOM, Linetype
                /* Insert SubTotal */
                Insert Into @TmpResult(Division,SaleQty,SaleValue,PromotedQty,
                PromotedValue,Taxamount,RebateQty,RebateValue)
									
                Select @SUBTOTAL, Sum(SaleQty),Sum(SaleValue),Sum(PromotedQty),
                Sum(PromotedValue),Sum(Taxamount),Sum(RebateQty),Sum(RebateValue)
                From  @TmpScheme
                Where Division = @Div 
                Group By Division
					
                Fetch Next From Cur_Div Into @Div
            End
            Close Cur_Div
            Deallocate  Cur_Div

            /* Insert GrandTotal */
            Insert Into @TmpResult(Division,SaleQty,SaleValue,PromotedQty,
            PromotedValue,Taxamount,RebateQty,RebateValue)
            Select @GRNTOTAL , Sum(SaleQty),Sum(SaleValue),Sum(PromotedQty),
            Sum(PromotedValue),Sum(Taxamount),Sum(RebateQty),Sum(RebateValue)
            From @TmpScheme
        End

        If @ApplicableOn = 'INVOICE'
        Begin
            Insert Into @tmpScheme(Division,SaleQty,SaleValue,PromotedQty,
            PromotedValue,Taxamount,RebateQty,RebateValue)
            Select @GRNTOTAL , 
            Sum(SaleQty),Sum(SaleValue),Sum(PromotedQty),
            Sum(PromotedValue),Sum(Taxamount),Sum(RebateQty),Sum(RebateValue)
            From @TmpScheme

            Update @TmpScheme Set 
            SaleQty =  (Case  isNull(SaleQty,0) When 0 Then NULL Else SaleQty End),
            SaleValue = (Case  isNull(SaleValue,0) When 0 Then NULL Else SaleValue End),
            PromotedQty = (Case  isNull(PromotedQty,0) When 0 Then NULL Else PromotedQty End) ,
            PromotedValue = (Case  isNull(PromotedValue,0) When 0 Then NULL Else PromotedValue End),
            TaxAmount = (Case  isNull(TaxAmount,0) When 0 Then NULL Else TaxAmount End),
            RebateQty = (Case  isNull(RebateQty,0) When 0 Then NULL Else RebateQty End),
            RebateValue = (Case  isNull(RebateValue,0) When 0 Then NULL Else RebateValue End)

            Select * from @tmpScheme
        End
        Else
        Begin
            Select Division, Division,  Code, [Name], UOM, LineType As Type, 
            --	SaleQty, SaleValue, PromotedQty, PromotedValue,
            --	TaxPercentage, TaxAmount, RebateQty, RebateValue
            SalesQty =  (Case  isNull(SaleQty,0) When 0 Then NULL Else SaleQty End),
            SaleValue = (Case  isNull(SaleValue,0) When 0 Then NULL Else SaleValue End),
            PromotedQty = (Case  isNull(PromotedQty,0) When 0 Then NULL Else PromotedQty End) ,
            PromotedValue = (Case  isNull(PromotedValue,0) When 0 Then NULL Else PromotedValue End),
            RebateQty = (Case  isNull(RebateQty,0) When 0 Then NULL Else RebateQty End),
            RebateValue = (Case  isNull(RebateValue,0) When 0 Then NULL Else RebateValue End)
            from @TmpResult --group by Division, Division,  Code, [Name], UOM, LineType 
        End

    End
    Drop table #rfaInfo
    Drop table #tmp
	--Drop table @TmpScheme
End

