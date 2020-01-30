Create  Procedure mERP_sp_Populate_CSQPS_Credits(@SchemeId Int, @PayoutID Int, @ItemGroup Int, @ApplicableOn Int,@SchemeStatus Int)    
As      
Begin      
  Set dateformat dmy      
  Declare @DataCnt Int      
  Declare @AbsRowID Int      
  Select @AbsRowID= IsNull(Max(RowID),0)+1 From tbl_merp_QPSAbsData      
      
  Declare @SchActiveFrom DateTime      
  Declare @SchActiveTo DateTime      
  Declare @SchPayoutFrom DateTime      
  Declare @SchPayoutTo DateTime      
  Declare @ExpiryDate DateTime      
  Declare @CashDisc_Count Int      
  Declare @SchemeDesc nVarchar(550)      
  Declare @VoucherPrefix nVarchar(50)      
  Declare @RFA_Claimable INT      
  Declare @DISPLAY_SCHEME_ACC INT       
  Declare @SECONDARY_SCHEME_ACC INT      
  DECLARE @PRIMARY_SCHEME_ACC INT      
  Declare @PayoutDate nVarchar(100)      
      
  SET @DISPLAY_SCHEME_ACC = 65      
  SET @SECONDARY_SCHEME_ACC = 39      
  SET @PRIMARY_SCHEME_ACC = 112      
  Select @VoucherPrefix = dbo.GetVoucherPrefix('CREDIT NOTE')      
      
      
  Select @SchemeDesc = 'QPS-' + IsNull(Description,'') + N'-'+ CS_RecSchID,       
   @RFA_Claimable = IsNull(RFAApplicable,0)  From tbl_mERP_SchemeAbstract Where SchemeID = @SchemeID      
      
  Select @SchActiveFrom= SchAbs.ActiveFrom, @SchActiveTo = SchAbs.ActiveTo, @ExpiryDate = SchAbs.ExpiryDate,      
         @SchPayoutFrom= SchPP.PAyoutPeriodFrom, @SchPayoutTo = SchPP.PAyoutPeriodTo      
  From tbl_merp_schemeAbstract SchAbs, tbl_merp_schemePayoutPeriod SchPP      
  Where SchAbs.SchemeID = @SchemeId And      
  SchPP.ID = @PayoutID And    
  SchAbs.SchemeID = SchPP.SchemeID      
      
  select @PayoutDate = convert(varchar(100), @SchPayoutFrom, 3)      
  select @PayoutDate = Substring(@PayoutDate, CharIndex('/',@PayoutDate,1)+1, Len(@PayoutDate))      
      
--Select "SchActiveFrom" = @SchActiveFrom, "SchActiveTo" = @SchActiveTo, "SchPayoutFrom"=@SchPayoutFrom, "SchPayoutTo"=@SchPayoutTo, "ExpiryDate"=@ExpiryDate      
--Select @SchemeId SchemeId, @PayoutID PayoutID, @ItemGroup ItemGroup, @ApplicableOn ApplicableOn      
  /*To get Outlet Scope*/      
  Select * into #tmpSchCustomer from dbo.mERP_fn_Get_CSOutletScope(@SchemeId,1)      
  /*To get Product Scope*/      
  Create table #tmpSchProducts(SchemeID Int, Product_Code nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)      
  Insert into #tmpSchProducts       
  Select SchemeID, Product_Code from dbo.mERP_fn_Get_CSProductScope_CrNote(@SchemeId) Group By SchemeID, Product_Code      
    
--Select * from #tmpSchCustomer      
--Select * from #tmpSchProducts      
--select @AbsRowID      
  Declare @InvPrefix nVarchar(10)      
  Select @InvPrefix = Prefix From VoucherPrefix Where TranID = 'INVOICE'      
  IF @ApplicableOn = 2     
  Begin    
    Insert into tbl_merp_QPSDtlData (SchemeID, PayoutID, InvoiceID, BillRef, InvDocRef, CustomerID, CustGroupID, Product_Code,       
        SalesValue, Quantity, SalePrice, TaxPercent, TaxAmount, UOM1Qty, UOM2Qty, QPSAbsDataID,TOQ)      
    Select @SchemeID, @PayoutID, InvAb.InvoiceID, 
    --@InvPrefix + Cast(InvAb.DocumentID as nVarchar),
    Case IsNULL(InvAb.GSTFlag ,0)
	When 0 then @InvPrefix + Cast(InvAb.DocumentID as nVarchar)
	Else
		IsNULL(InvAb.GSTFullDocID,'')
	End,
    Cast(IsNull(InvAb.DocReference,'') as nVarchar(255)) InvDocRef,       
    InvAb.CustomerID, CusMas.GroupID, Invdet.Product_Code,    
    Sum(InvDet.Amount), Sum(InvDet.Quantity),       
    InvDet.SalePrice, Max(InvDet.TaxCode), 
    --(Sum(InvDet.Quantity * InvDet.SalePrice) * (Max(InvDet.TaxCode)/100)), --Sum(InvDet.TaxAmount),       
	(Case Max(Isnull(Invdet.TAXONQTY,0)) When 0 then 
	 (Sum(InvDet.Quantity * InvDet.SalePrice) * (Max(InvDet.TaxCode)/100))
	Else(Sum(InvDet.Quantity) * Max(InvDet.TaxCode)) End),
    Sum(Cast((InvDet.Quantity / IsNull(Itm.UOM1_Conversion,1)) as Decimal (18,6))) UOM1Qty,       
    Sum(Cast((InvDet.Quantity / IsNull(Itm.UOM2_Conversion,1)) as Decimal (18,6))) Uom2Qty, @AbsRowID ,Max(Isnull(Invdet.TAXONQTY,0))   
    From InvoiceAbstract InvAb, #tmpSchCustomer CusMas,       
    InvoiceDetail InvDet, Items Itm      
    Where InvAb.CustomerId=CusMas.CustomerCode      
    And dbo.StripTimeFromDate(InvAb.Invoicedate) Between @SchActiveFrom And @SchActiveTo      
    And dbo.StripTimeFromDate(InvAb.Invoicedate) Between @SchPayoutFrom And @SchPayoutTo      
    And dbo.StripTimeFromDate(InvAb.CreationTime) Between @SchActiveFrom And @ExpiryDate      
    And InvAb.InvoiceId=InvDet.InvoiceId              
    And InvAb.InvoiceType In (1,2,3)              
    And (InvAb.Status & 128)=0      
    And Itm.Product_Code = InvDet.Product_Code      
    And InvDet.FlagWord =0      
 And (Case InvAb.InvoiceType  
   When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID =   
   InvAb.DocumentID  
   And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = InvAb.CustomerID)  
   Else dbo.StripTimeFromDate(InvAb.InvoiceDate)  
   End) Between @SchPayoutFrom And @SchPayoutTo  
    Group by InvAb.InvoiceID, Cast(InvAb.DocumentID as nVarchar), IsNull(InvAb.DocReference,''), CusMas.GroupId, InvAb.InvoiceType,    
    InvAb.CustomerID, Invdet.Product_Code, Invdet.TaxID,InvDet.SalePrice ,IsNULL(InvAb.GSTFlag ,0), IsNULL(InvAb.GSTFullDocID,'')  
  End    
  Else    
  Begin    
    Insert into tbl_merp_QPSDtlData (SchemeID, PayoutID, InvoiceID, BillRef, InvDocRef, CustomerID, CustGroupID, Product_Code,       
    SalesValue, Quantity, SalePrice, TaxPercent, TaxAmount, UOM1Qty, UOM2Qty, QPSAbsDataID,TOQ)      
    Select @SchemeID, @PayoutID, InvAb.InvoiceID,
    --@InvPrefix + Cast(InvAb.DocumentID as nVarchar), 
    Case IsNULL(InvAb.GSTFlag ,0)
	When 0 then @InvPrefix + Cast(InvAb.DocumentID as nVarchar)
	Else
		IsNULL(InvAb.GSTFullDocID,'')
	End,
    Cast(IsNull(InvAb.DocReference,'') as nVarchar(255)) InvDocRef,     
    InvAb.CustomerID, CusMas.GroupID, Invdet.Product_Code,    
    Sum(InvDet.Amount), Sum(InvDet.Quantity),       
    InvDet.SalePrice, Max(InvDet.TaxCode),
	(Case Max(Isnull(Invdet.TAXONQTY,0)) When 0 then 
	 (Sum(InvDet.Quantity * InvDet.SalePrice) * (Max(InvDet.TaxCode)/100))
	Else(Sum(InvDet.Quantity) * Max(InvDet.TaxCode)) End),
	 --Sum(InvDet.TaxAmount),       
    Sum(Cast((InvDet.Quantity / IsNull(Itm.UOM1_Conversion,1)) as Decimal (18,6))) UOM1Qty,       
    Sum(Cast((InvDet.Quantity / IsNull(Itm.UOM2_Conversion,1)) as Decimal (18,6))) Uom2Qty, @AbsRowID ,Max(Isnull(Invdet.TAXONQTY,0))   
  --InvDet.Amount, InvDet.Quantity,       
  --InvDet.SalePrice, InvDet.TaxCode, InvDet.TaxAmount,       
  --Cast((InvDet.Quantity / IsNull(Itm.UOM1_Conversion,1)) as Decimal (18,6)) UOM1Qty,       
  --Cast((InvDet.Quantity / IsNull(Itm.UOM2_Conversion,1)) as Decimal (18,6)) Uom2Qty, @AbsRowID      
    From InvoiceAbstract InvAb, #tmpSchCustomer CusMas,       
    InvoiceDetail InvDet, #tmpSchProducts SchProducts, Items Itm      
    Where InvAb.CustomerId=CusMas.CustomerCode      
    And dbo.StripTimeFromDate(InvAb.Invoicedate) Between @SchActiveFrom And @SchActiveTo      
    And dbo.StripTimeFromDate(InvAb.Invoicedate) Between @SchPayoutFrom And @SchPayoutTo      
    And dbo.StripTimeFromDate(InvAb.CreationTime) Between @SchActiveFrom And @ExpiryDate      
    And InvAb.InvoiceId=InvDet.InvoiceId              
    And InvAb.InvoiceType In (1,2,3)              
    And (InvAb.Status & 128)=0      
    And SchProducts.SchemeID=@SchemeID      
    And InvDet.Product_Code=SchProducts.Product_Code      
    And Itm.Product_Code = InvDet.Product_Code      
    And InvDet.FlagWord =0      
 And (Case InvAb.InvoiceType  
       When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID =   
       InvAb.DocumentID  
       And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = InvAb.CustomerID)  
       Else dbo.StripTimeFromDate(InvAb.InvoiceDate)  
       End) Between @SchPayoutFrom And @SchPayoutTo  
    Group by InvAb.InvoiceID, Cast(InvAb.DocumentID as nVarchar), IsNull(InvAb.DocReference,'') , CusMas.GroupId, InvAb.InvoiceType,  
    InvAb.CustomerID, Invdet.Product_Code, Invdet.TaxID,InvDet.SalePrice,IsNULL(InvAb.GSTFlag ,0), IsNULL(InvAb.GSTFullDocID,'')    
  End    
  Select @DataCnt=@@RowCount    
  
  If @DataCnt > 0       
  Begin      
    IF @ItemGroup = 1 and @ApplicableOn = 1 /*SKU*/  
    Begin  
      Insert into tbl_merp_QPSAbsData(RowID, SchemeID, PayoutID, GroupID, CustomerID, Product_code, SalesValue, Quantity, UOM1Qty, UOM2Qty)      
      Select @AbsRowID, @SchemeID, @PayoutID, CustGroupID, CustomerID, Product_code, Sum(SalesValue), Sum(Quantity), Sum(UOM1Qty), Sum(UOM2Qty)      
      From tbl_merp_QPSDtlData Where QPSAbsDataID = @AbsRowID Group By CustGroupID, CustomerID, Product_code      
    End  
    Else /*Spl Category*/  
    Begin  
      Insert into tbl_merp_QPSAbsData(RowID, SchemeID, PayoutID, GroupID, CustomerID, SalesValue, Quantity, UOM1Qty, UOM2Qty)      
      Select @AbsRowID, @SchemeID, @PayoutID, CustGroupID, CustomerID, Sum(SalesValue), Sum(Quantity), Sum(UOM1Qty), Sum(UOM2Qty)      
      From tbl_merp_QPSDtlData Where QPSAbsDataID = @AbsRowID Group By CustGroupID, CustomerID      
    End  
--  Select * from tbl_merp_QPSAbsData        
--  Select * from tbl_merp_QPSDtlData      
      
    /*Promoted value Calculations Cursor*/      
    Declare @SlabID Int, @GroupID Int, @SlabType Int      
    Declare @Discount Decimal(18,6)      
    Declare @FreeQty Decimal(18,6)      
    Declare @FromLim decimal(18,6)      
    Declare @ToLim Decimal(18,6)      
    Declare @Onward Decimal(18,6)      
    Declare @PrimaryUOM as Decimal(18,6)      
    Declare @FreeUOM Decimal(18,6)      
           
    Declare SchemeDiscount Cursor For              
    Select SlabID, GroupID, SlabType, UOM, SlabStart, SlabEnd, IsNull(Value,0), IsNull(Onward,0), IsNull(FreeUOM,''),IsNull(Volume,0)      
    From tbl_mERP_SchemeSlabDetail Schemes Where SchemeId=@SchemeID        
    Open SchemeDiscount              
    Fetch next From SchemeDiscount Into @SlabID, @GroupID, @SlabType, @PrimaryUOM, @FromLim, @ToLim, @Discount, @Onward, @FreeUOM, @FreeQty      
    While(@@fetch_status=0)              
    Begin              
      Set @CashDisc_Count = 0       
      If (@ApplicableOn = 2)  /*Invoice Based*/      
      Begin      
        IF @SlabType=2  /*Percentage */      
        Begin              
          Update QPSAbs Set PromotedValue =(Case @Onward When 0 Then QpsDtl.SalesValue Else (Cast(QPSDtl.SalesValue/@Onward as Int) * @Onward)End), SlabID = @SlabID       
          From tbl_merp_QPSAbsData QPSAbs,       
               (Select SchemeID, PayoutID, CustomerID, Sum(Quantity * SalePrice) as 'SalesValue' From tbl_merp_QPSDtlData       
                Where SchemeID = @schemeId And PayoutID = @PayoutID Group By SchemeID, PayoutID, CustomerID) QPSDtl      
          Where QPSAbs.SalesValue >=@FromLim And QPSAbs.SalesValue <=@Tolim and QPSAbs.GroupID = @GroupID And       
          QPSAbs.SchemeID = @schemeId And       
          QPSAbs.PayoutID = @PayoutID And       
          QPSAbs.CustomerID = QPSDtl.CustomerID and       
          QPSAbs.SchemeID = QPSDtl.SchemeID and       
          QPSAbs.PayoutID = QPSDtl.PayoutID    
      
          /*Start of Cr Note Value Generation*/      
          If @SchemeStatus = 2       
          Begin      
            Update tbl_merp_QPSAbsData Set RebateValue=(Case @Onward When 0 Then (SalesValue * (@Discount /100)) Else ((Cast(SalesValue/@Onward as Int) * @Onward)*(@Discount /100))End)      
            Where SalesValue >=@FromLim And SalesValue <=@Tolim and GroupID = @GroupID And       
            SchemeID = @schemeId And PayoutID = @PayoutID       
           
            /*To Update RFA Rebate Val*/      
            Update QPSAbs Set RFARebateValue=(Case @Onward When 0 Then (QpsDtl.SalesValue * (@Discount /100)) Else ((Cast(QPSDtl.SalesValue/@Onward as Int) * @Onward)*(@Discount /100))End)      
            From tbl_merp_QPSAbsData QPSAbs,       
               (Select SchemeID, PayoutID, CustomerID, Sum(Quantity * SalePrice) as 'SalesValue' From tbl_merp_QPSDtlData       
                Where SchemeID = @schemeId And PayoutID = @PayoutID Group By SchemeID, PayoutID, CustomerID) QPSDtl      
            Where QPSAbs.SalesValue >=@FromLim And QPSAbs.SalesValue <=@Tolim and QPSAbs.GroupID = @GroupID And       
            QPSAbs.SchemeID = @schemeId And       
            QPSAbs.PayoutID = @PayoutID And       
            QPSAbs.CustomerID = QPSDtl.CustomerID and       
            QPSAbs.SchemeID = QPSDtl.SchemeID and       
            QPSAbs.PayoutID = QPSDtl.PayoutID      
          End      
          /*End of Cr Note Value Generation*/      
        End              
        Else If @SlabType=1 /*Amount*/      
        Begin              
          Update QPSAbs Set PromotedValue =(Case @Onward When 0 Then QpsDtl.SalesValue Else (Cast(QPSDtl.SalesValue/@Onward as Int) * @Onward)End), SlabID = @SlabID      
          From tbl_merp_QPSAbsData QPSAbs,    
               (Select SchemeID, PayoutID, CustomerID, Sum(Quantity * SalePrice) as 'SalesValue' From tbl_merp_QPSDtlData       
                Where SchemeID = @schemeId And PayoutID = @PayoutID Group By SchemeID, PayoutID, CustomerID) QPSDtl      
          Where QPSAbs.SalesValue >=@FromLim And QPSAbs.SalesValue <=@Tolim and QPSAbs.GroupID = @GroupID And       
          QPSAbs.SchemeID = @schemeId And       
          QPSAbs.PayoutID = @PayoutID And       
          QPSAbs.CustomerID = QPSDtl.CustomerID and       
          QPSAbs.SchemeID = QPSDtl.SchemeID and       
          QPSAbs.PayoutID = QPSDtl.PayoutID    
    
          /*Start of Cr Note Value Generation*/      
          If @SchemeStatus=  2      
          Begin      
            Update tbl_merp_QPSAbsData       
            Set RebateValue=(Case @Onward When 0 Then @Discount Else (Cast(SalesValue/@Onward as Int)*@Discount)End),   
                RFARebateValue=(Case @Onward When 0 Then @Discount Else (Cast(SalesValue/@Onward as Int)*@Discount)End)   
            Where SalesValue >=@FromLim And SalesValue <=@Tolim and GroupID = @GroupID And       
            SchemeID = @schemeId And PayoutID = @PayoutID      
    
--            /*To Update RFA Rebate Val(Without tax)*/      
--            Update QPSAbs Set RFARebateValue=(Case @Onward When 0 Then (QpsDtl.SalesValue * @Discount) Else ((Cast(QPSDtl.SalesValue/@Onward as Int) * @Onward)*(@Discount))End)      
--            From tbl_merp_QPSAbsData QPSAbs,       
--               (Select SchemeID, PayoutID, CustomerID, Sum(Quantity * SalePrice) as 'SalesValue' From tbl_merp_QPSDtlData       
--                Where SchemeID = @schemeId And PayoutID = @PayoutID Group By SchemeID, PayoutID, CustomerID) QPSDtl      
--            Where QPSAbs.SalesValue >=@FromLim And QPSAbs.SalesValue <=@Tolim and QPSAbs.GroupID = @GroupID And       
--            QPSAbs.SchemeID = @schemeId And       
--            QPSAbs.PayoutID = @PayoutID And       
--            QPSAbs.CustomerID = QPSDtl.CustomerID and       
--            QPSAbs.SchemeID = QPSDtl.SchemeID and       
--            QPSAbs.PayoutID = QPSDtl.PayoutID      
          End      
          /*End of Cr Note Value Generation*/      
        End              
        Else If @SlabType=3 /*Free Item */      
        Begin              
          Update QPSAbs Set PromotedValue =IsNull(PromotedValue,0) + (Case @Onward When 0 Then QpsDtl.SalesValue Else (Cast(QPSDtl.SalesValue/@Onward as Int) * @Onward)End), SlabID = @SlabID       
          From tbl_merp_QPSAbsData QPSAbs,       
               (Select SchemeID, PayoutID, CustomerID, Sum(Quantity * SalePrice) as 'SalesValue' From tbl_merp_QPSDtlData       
                Where SchemeID = @schemeId And PayoutID = @PayoutID Group By SchemeID, PayoutID, CustomerID) QPSDtl      
          Where QPSAbs.SalesValue >=@FromLim And QPSAbs.SalesValue <=@Tolim and QPSAbs.GroupID = @GroupID And       
          QPSAbs.SchemeID = @schemeId And       
          QPSAbs.PayoutID = @PayoutID And       
          QPSAbs.CustomerID = QPSDtl.CustomerID and       
          QPSAbs.SchemeID = QPSDtl.SchemeID and       
          QPSAbs.PayoutID = QPSDtl.PayoutID    
    
          /*Start of Free SKU Qty Generation*/      
          If @SchemeStatus= 2       
          Begin      
            Update tbl_merp_QPSAbsData       
            Set RebateQuantity= IsNull(RebateQuantity,0) + (Case @Onward When 0 Then @FreeQty Else (Cast(SalesValue/@Onward as Int) * @FreeQty) End)      
           Where SalesValue >=@FromLim And SalesValue <=@Tolim and GroupID = @GroupID And       
            SchemeID = @schemeId And PayoutID = @PayoutID      
          End      
          /*End of Free SKU Qty Generation*/      
        End      
      End      
      Else If (@ApplicableOn = 1)  /*Line */      
      Begin      
        IF @ItemGroup = 2    /*Special Category*/      
        /* --------------- Start of Qty OR Value Consideration --------------- */      
        Begin  /*----Spl Category ----*/      
          IF @PrimaryUOM = 4      
            Update tbl_merp_QPSAbsData Set ApplyOn = SalesValue Where SchemeID = @schemeId And PayoutID = @PayoutID and GroupID = @GroupID      
          Else       
            Update tbl_merp_QPSAbsData Set ApplyOn = (Case @PrimaryUOM When 1 Then Quantity When 2 Then UOM1Qty When 3 Then UOM2Qty End) Where SchemeID = @schemeId And PayoutID = @PayoutID and GroupID = @GroupID      
        End      
        Else         
        Begin  /*----Normal Scheme ----*/      
          IF @PrimaryUOM = 4  /*Value*/      
            Update tbl_merp_QPSAbsData Set ApplyOn = SalesValue       
            Where SchemeID = @schemeId And PayoutID = @PayoutID and GroupID = @GroupID      
          Else      
            Update QPSAbs Set QPSAbs.ApplyOn = QPSDtl.Quantity      
            From tbl_merp_QPSAbsData QPSAbs, (Select QPSDtl.SchemeID, QPSDtl.PayoutID, QPSDtl.CustomerId, QPSDtl.Product_Code, Sum(QPSDtl.Quantity/ (Case @PrimaryUOM When 1 Then 1 When 2 Then IsNull(I.Uom1_conversion,1) When 3 Then IsNull(I.Uom2_conversion,1) End)) as Quantity      
                                              From tbl_merp_QPSDtlData QPSDtl, Items I      
                                              Where QPSDtl.Product_Code = I.Product_Code And --QPSDtl.CustGroupID = @GroupID And       
                                                 QPSDtl.SchemeID = @schemeId And QPSDtl.PayoutID = @PayoutID        
                                              Group by QPSDtl.SchemeID, QPSDtl.PayoutID, QPSDtl.CustomerId, QPSDtl.Product_Code) QPSDtl      
            Where QPSAbs.GroupID = @GroupID And       
            QPSAbs.SchemeID = @schemeId And       
            QPSAbs.PayoutID = @PayoutID And       
            QPSAbs.CustomerID = QPSDtl.CustomerID And       
            QPSAbs.SchemeID = QPSDtl.SchemeID And       
            QPSAbs.PayoutID = QPSDtl.PayoutID And     
            IsNull(QPSAbs.Product_Code,N'') = QPSDtl.Product_Code  
        End      
        /* --------------- End of Qty OR Value Consideration --------------- */      
      
        /* --------------- Falling Slab --------------- */       
        IF (@SlabType=2)     /*--Percentage--*/      
        Begin              
          /*To Update RFA Rebate Val*/    
          Update QPSAbs    
          Set QPSAbs.PromotedQuantity = tmp.PromoQty, QPSAbs.PromotedValue = tmp.PromotedValue, SlabID = @SlabID    
          From tbl_merp_QPSAbsData QPSAbs,     
            (Select DtlData.SchemeID, DtlData.PayoutID, DtlData.CustomerID, (Case @ItemGroup When 1 then DtlData.Product_code  Else N'' End) Product_code,   
             Case @PrimaryUOM When 4 then 0 Else PromoQty End PromoQty,     
             Cast((PromoQty/Case @PrimaryUOM When 4 then OrgSalePrice Else ApplyOn End) * Sum((Case @PrimaryUOM When 1 Then Quantity When 2 Then UOM1Qty When 3 Then UOM2Qty When 4 then Quantity End)*    
             ((Case @PrimaryUOM When 1 Then SalePrice    
               When 2 Then (DtlData.SalePrice * I.UOM1_Conversion)   
               When 3 Then (DtlData.SalePrice * I.UOM2_Conversion)  
               When 4 Then SalePrice End))) as Decimal(18,6)) PromotedValue,   
               (PromoQty/Case @PrimaryUOM When 4 then OrgSalePrice Else ApplyOn End) * Sum(DtlData.TaxAmount) TaxAmount    
               From tbl_merp_QPSDtlData DtlData, Items I,     
              (Select QAbs.SchemeID, QAbs.PayoutID, QAbs.CustomerID, IsNull(QAbs.Product_code,N'') Product_code,  
               /*To Correct the Promoted value, When Discount applied during Invoice*/  
               (Case @Onward When 0 Then (Case @PrimaryUOM When 4 Then Cast(Sum(Qdtl.Quantity * Qdtl.SalePrice) as Decimal(18,6)) Else QAbs.ApplyOn End)   
                             Else (Cast((Case @PrimaryUOM When 4 Then Cast(Sum(Qdtl.Quantity * Qdtl.SalePrice) as Decimal(18,6)) Else QAbs.ApplyOn End)/@Onward as Int) * @Onward)End) PromoQty,   
               QAbs.ApplyOn, Cast(Sum(Qdtl.Quantity * Qdtl.SalePrice) as Decimal(18,6)) OrgSalePrice   
               From tbl_merp_QPSAbsData QAbs, tbl_merp_QPSDtlData QDtl Where     
               QAbs.ApplyOn >= @FromLim And QAbs.ApplyOn <= @Tolim And     
               QAbs.ApplyOn >= (Case @Onward When 0 Then 0 Else @Onward End) And     
               QAbs.GroupID = @GroupID And QAbs.SchemeID = @schemeId And QAbs.PayoutID = @PayoutID And   
               QAbs.SchemeID = QDtl.SchemeID And     
               QAbs.PayoutID = QDtl.PayoutID And     
               QAbs.CustomerID = QDtl.CustomerID And     
               IsNull(QAbs.Product_code,N'') = (Case @ItemGroup When 1 then QDtl.Product_code  Else N'' End)  
               Group By QAbs.SchemeID, QAbs.PayoutID, QAbs.CustomerID, IsNull(QAbs.Product_code,N''), QAbs.ApplyOn) AbsData    
             Where AbsData.SchemeID = DtlData.SchemeID And     
             AbsData.PayoutID = DtlData.PayoutID And     
             AbsData.CustomerID = DtlData.CustomerID And     
             DtlData.Product_code =  I.Product_code And  
             IsNull(AbsData.Product_code,N'') = (Case @ItemGroup When 1 then DtlData.Product_code  Else N'' End)  
             Group By DtlData.SchemeID, DtlData.PayoutID, DtlData.CustomerID, PromoQty, ApplyON,   
                     Case @PrimaryUOM When 4 then OrgSalePrice Else ApplyOn End,   
                     (Case @ItemGroup When 1 then DtlData.Product_code  Else N'' End)  
             Having Sum(ApplyOn)> 0) tmp    
           Where QPSAbs.SchemeID = tmp.SchemeID And     
           QPSAbs.PayoutID = tmp.PayoutID And     
           QPSAbs.CustomerID = tmp.CustomerID And     
           IsNull(QPSAbs.Product_code,N'') = IsNull(tmp.Product_code,N'') And   
           QPSAbs.GroupID = @GroupID And QPSAbs.SchemeID = @schemeId And QPSAbs.PayoutID = @PayoutID And     
           ApplyOn >= @FromLim And ApplyOn <= @Tolim And ApplyOn >= (Case @Onward When 0 Then 0 Else @Onward End)    
     
          /*To Update RFA Rebate Val*/    
          If @SchemeStatus = 2       
          Begin      
            Update QPSAbs    
            Set QPSAbs.RebateValue = (tmp.PromotedValue + tmp.TaxAmount) * (@Discount /100),    
                QPSAbs.RFARebateValue = tmp.PromotedValue * (@Discount /100)      
            From tbl_merp_QPSAbsData QPSAbs,     
              (Select DtlData.SchemeID, DtlData.PayoutID, DtlData.CustomerID, (Case @ItemGroup When 1 then DtlData.Product_code  Else N'' End) Product_code,    
              Cast((PromoQty/Case @PrimaryUOM When 4 then OrgSalePrice Else ApplyOn End) * Sum((Case @PrimaryUOM When 1 Then Quantity When 2 Then UOM1Qty When 3 Then UOM2Qty When 4 then Quantity End)*    
              ((Case @PrimaryUOM When 1 Then SalePrice    
               When 2 Then (DtlData.SalePrice * I.UOM1_Conversion)    
               When 3 Then (DtlData.SalePrice * I.UOM2_Conversion)   
               When 4 Then SalePrice End)))as Decimal(18,6)) PromotedValue,   
              (PromoQty/Case @PrimaryUOM When 4 then OrgSalePrice Else ApplyOn End) * Sum(DtlData.TaxAmount) TaxAmount    
              From tbl_merp_QPSDtlData DtlData, Items I,     
              (Select QAbs.SchemeID, QAbs.PayoutID, QAbs.CustomerID, IsNull(QAbs.Product_code,N'') Product_code,  
               /*To Correct the Promoted value, When Discount applied during Invoice*/  
               (Case @Onward When 0 Then (Case @PrimaryUOM When 4 Then Cast(Sum(Qdtl.Quantity * Qdtl.SalePrice) as Decimal(18,6)) Else QAbs.ApplyOn End)   
                             Else (Cast((Case @PrimaryUOM When 4 Then Cast(Sum(Qdtl.Quantity * Qdtl.SalePrice) as Decimal(18,6)) Else QAbs.ApplyOn End)/@Onward as Int) * @Onward)End) PromoQty,   
               QAbs.ApplyOn, Cast(Sum(Qdtl.Quantity * Qdtl.SalePrice) as Decimal(18,6)) OrgSalePrice  
               From tbl_merp_QPSAbsData QAbs, tbl_merp_QPSDtlData QDtl Where     
               QAbs.ApplyOn >= @FromLim And QAbs.ApplyOn <= @Tolim And     
               QAbs.ApplyOn >= (Case @Onward When 0 Then 0 Else @Onward End) And     
               QAbs.GroupID = @GroupID And QAbs.SchemeID = @schemeId And QAbs.PayoutID = @PayoutID And   
               QAbs.SchemeID = QDtl.SchemeID And     
               QAbs.PayoutID = QDtl.PayoutID And     
               QAbs.CustomerID = QDtl.CustomerID And     
               IsNull(QAbs.Product_code,N'') = (Case @ItemGroup When 1 then QDtl.Product_code  Else N'' End)  
               Group By QAbs.SchemeID, QAbs.PayoutID, QAbs.CustomerID, IsNull(QAbs.Product_code,N''), QAbs.ApplyOn) AbsData    
               Where AbsData.SchemeID = DtlData.SchemeID And     
               AbsData.PayoutID = DtlData.PayoutID And     
               AbsData.CustomerID = DtlData.CustomerID And     
               IsNull(AbsData.Product_code,N'') = (Case @ItemGroup When 1 then DtlData.Product_code  Else N'' End) And  
               DtlData.Product_code =  I.Product_code    
               Group By DtlData.SchemeID, DtlData.PayoutID, DtlData.CustomerID, PromoQty, ApplyOn,   
                        Case @PrimaryUOM When 4 then OrgSalePrice Else ApplyOn End,   
                        Case @ItemGroup When 1 then DtlData.Product_code  Else N'' End  
               Having Sum(ApplyOn)> 0) tmp    
            Where QPSAbs.SchemeID = tmp.SchemeID And     
            QPSAbs.PayoutID = tmp.PayoutID And     
            QPSAbs.CustomerID = tmp.CustomerID And    
            IsNull(QPSAbs.Product_code,N'') =  IsNull(tmp.Product_code,N'') And   
            QPSAbs.GroupID = @GroupID And QPSAbs.SchemeID = @schemeId And QPSAbs.PayoutID = @PayoutID And     
            ApplyOn >= @FromLim And ApplyOn <= @Tolim And ApplyOn >= (Case @Onward When 0 Then 0 Else @Onward End)    
          End      
          /*End of Cr Note Value Generation*/      
        End              
        Else IF (@SlabType=1)  /*-- Amount --*/             
        Begin       
          /*Update Sum of the Value on Abstract*/      
          Update QPSAbs    
          Set QPSAbs.PromotedQuantity = Case @PrimaryUOM When 4 Then 0 Else tmp.PromoQty End,   
              QPSAbs.PromotedValue = tmp.PromotedValue, SlabID = @SlabID    
          From tbl_merp_QPSAbsData QPSAbs,     
            (Select DtlData.SchemeID, DtlData.PayoutID, DtlData.CustomerID,   
             (Case @ItemGroup When 1 then DtlData.Product_code  Else N'' End) Product_code, PromoQty,    
         Sum(((Case @PrimaryUOM When 4 then 1 else (PromoQty/ApplyOn) end) * Case @PrimaryUOM When 1 Then Quantity When 2 Then UOM1Qty When 3 Then UOM2Qty When 4 then Quantity End)*    
                 (Case @PrimaryUOM When 1 Then SalePrice    
                  When 2 Then (DtlData.SalePrice * I.UOM1_Conversion)    
                  When 3 Then (DtlData.SalePrice * I.UOM2_Conversion)     
                  When 4 then SalePrice End)  
                )PromotedValue, (PromoQty/ApplyOn) * Sum(DtlData.TaxAmount) TaxAmount    
             From tbl_merp_QPSDtlData DtlData, Items I,     
              (Select SchemeID, PayoutID, CustomerID, IsNull(Product_Code,N'') Product_Code,  
               (Case @Onward When 0 Then ApplyOn Else (Cast(ApplyOn/@Onward as Int) * @Onward)End) PromoQty,  ApplyOn    
               From tbl_merp_QPSAbsData Where     
               ApplyOn >= @FromLim And ApplyOn <= @Tolim And     
               ApplyOn >= (Case @Onward When 0 Then 0 Else @Onward End) And     
               GroupID = @GroupID And SchemeID = @schemeId And PayoutID = @PayoutID) AbsData    
             Where AbsData.SchemeID = DtlData.SchemeID And     
             AbsData.PayoutID = DtlData.PayoutID And     
             AbsData.CustomerID = DtlData.CustomerID And     
             IsNull(AbsData.Product_code,N'') =  Case @ItemGroup When 1 then DtlData.Product_code  Else N'' End And   
             DtlData.Product_code =  I.Product_code    
             Group By DtlData.SchemeID, DtlData.PayoutID, DtlData.CustomerID, PromoQty, ApplyON,  
             Case @ItemGroup When 1 then DtlData.Product_code  Else N'' End  
             Having Sum(ApplyOn)> 0) tmp    
           Where QPSAbs.SchemeID = tmp.SchemeID And     
           QPSAbs.PayoutID = tmp.PayoutID And     
           QPSAbs.CustomerID = tmp.CustomerID And     
           IsNull(QPSAbs.Product_code,N'') =  IsNull(tmp.Product_code,N'') And  
           QPSAbs.GroupID = @GroupID And QPSAbs.SchemeID = @schemeId And QPSAbs.PayoutID = @PayoutID And     
           ApplyOn >= @FromLim And ApplyOn <= @Tolim And ApplyOn >= (Case @Onward When 0 Then 0 Else @Onward End)    
    
          /*Start of Cr Note Value Generation*/      
          If @SchemeStatus = 2       
          Begin      
            Update tbl_merp_QPSAbsData       
            Set RebateValue=Case @Onward When 0 Then @Discount Else (Cast(ApplyON/@Onward as Int)* @Discount) End      
            --RebateQuantity =Case @Onward When 0 Then ApplyON Else (Cast(ApplyON/@Onward as Int) * @Onward)  End      
            Where ApplyON >=@FromLim And ApplyON <=@Tolim and GroupID = @GroupID And       
            SchemeID = @schemeId And PayoutID = @PayoutID      
    
            /*To Update RFA Rebate Val*/      
            IF @PrimaryUOM = 4  /*Value Based*/  
              Begin  
              Update QPSAbs  
              Set QPSAbs.RFARebateValue =  (Case tmp.PromotedValue When 0 Then 0 Else (tmp.PromotedValue *    
                                  (Case @Onward When 0 Then @Discount Else (Cast(ApplyON/@Onward as Int)* @Discount)/(tmp.PromotedValue + tmp.TaxAmount) End)) End)   
              From tbl_merp_QPSAbsData QPSAbs,     
              (Select DtlData.SchemeID, DtlData.PayoutID, DtlData.CustomerID, (Case @ItemGroup When 1 then DtlData.Product_code  Else N'' End) Product_code,  
               Sum(Quantity* SalePrice) PromotedValue, Sum(DtlData.TaxAmount) TaxAmount    
               From tbl_merp_QPSDtlData DtlData, Items I  
               Where DtlData.Product_code =  I.Product_code    
               Group By DtlData.SchemeID, DtlData.PayoutID, DtlData.CustomerID, (Case @ItemGroup When 1 then DtlData.Product_code  Else N'' End)) tmp    
               Where QPSAbs.SchemeID = tmp.SchemeID And     
               QPSAbs.PayoutID = tmp.PayoutID And     
               QPSAbs.CustomerID = tmp.CustomerID And     
               IsNull(QPSAbs.Product_code,N'') = IsNull(tmp.Product_code,N'') And  
               QPSAbs.GroupID = @GroupID And QPSAbs.SchemeID = @schemeId And QPSAbs.PayoutID = @PayoutID And     
               ApplyOn >= @FromLim And ApplyOn <= @Tolim And ApplyOn >= (Case @Onward When 0 Then 0 Else @Onward End)    
              End  
            Else   
              Begin  
              Update QPSAbs    
              Set QPSAbs.RFARebateValue =  (Case tmp.PromotedValue When 0 Then 0 Else (tmp.PromotedValue *     
                                (Case @Onward When 0 Then @Discount Else (Cast(ApplyON/@Onward as Int)* @Discount)/(tmp.PromotedValue + tmp.TaxAmount) End)) End)  
                  From tbl_merp_QPSAbsData QPSAbs,     
              (Select DtlData.SchemeID, DtlData.PayoutID, DtlData.CustomerID, (Case @ItemGroup When 1 then DtlData.Product_code  Else N'' End)  Product_code,  
              (Sum(((PromoQty/ApplyOn)* Case @PrimaryUOM When 1 Then Quantity When 2 Then UOM1Qty When 3 Then UOM2Qty When 4 then Quantity End)*    
              ((Case @PrimaryUOM When 1 Then SalePrice    
               When 2 Then (DtlData.SalePrice * I.UOM1_Conversion)    
               When 3 Then (DtlData.SalePrice * I.UOM2_Conversion) When 4 Then SalePrice End)))) PromotedValue, (PromoQty/ApplyOn) * Sum(DtlData.TaxAmount) TaxAmount    
              From tbl_merp_QPSDtlData DtlData, Items I,     
              (Select SchemeID, PayoutID, CustomerID,IsNull(Product_code,N'') Product_code,    
               (Case @Onward When 0 Then ApplyOn Else (Cast(ApplyOn/@Onward as Int) * @Onward)End) PromoQty,  ApplyOn    
               From tbl_merp_QPSAbsData Where     
               ApplyOn >= @FromLim And ApplyOn <= @Tolim And     
               ApplyOn >= (Case @Onward When 0 Then 0 Else @Onward End) And     
               GroupID = @GroupID And SchemeID = @schemeId And PayoutID = @PayoutID) AbsData    
               Where AbsData.SchemeID = DtlData.SchemeID And     
               AbsData.PayoutID = DtlData.PayoutID And     
               AbsData.CustomerID = DtlData.CustomerID And     
               IsNull(AbsData.Product_code,N'') = Case @ItemGroup When 1 then DtlData.Product_code  Else N'' End And  
               DtlData.Product_code =  I.Product_code    
               Group By DtlData.SchemeID, DtlData.PayoutID, DtlData.CustomerID, PromoQty, ApplyOn,   
      Case @ItemGroup When 1 then DtlData.Product_code  Else N'' End  
      Having Sum(ApplyOn) > 0) tmp    
               Where QPSAbs.SchemeID = tmp.SchemeID And     
               QPSAbs.PayoutID = tmp.PayoutID And     
               QPSAbs.CustomerID = tmp.CustomerID And    
               IsNull(QPSAbs.Product_code,N'') =  IsNull(tmp.Product_code,N'') And   
               QPSAbs.GroupID = @GroupID And QPSAbs.SchemeID = @schemeId And QPSAbs.PayoutID = @PayoutID And     
               ApplyOn >= @FromLim And ApplyOn <= @Tolim And ApplyOn >= (Case @Onward When 0 Then 0 Else @Onward End)    
              End  
          End      
          /*End of Cr Note Value Generation*/      
        End              
        Else IF (@SlabType=3)  /*-- Item Free --*/      
        Begin              
          IF @ItemGroup = 2       
          Begin  /*----Spl Category ----*/      
            Update QPSAbs       
            Set QPSAbs.PromotedValue = IsNull(QPSAbs.PromotedValue,0) +  Case @PrimaryUOM When 4 Then (Case @Onward When 0 Then QPSDtl.SalesValue Else (Cast(QPSDtl.SalesValue/@Onward as Int) * @Onward)  End) Else 0 End,       
            QPSAbs.PromotedQuantity = IsNull(QPSAbs.PromotedQuantity,0) + (Case @Onward When 0 Then ApplyOn Else  (Cast((ApplyOn/@onward) as Int)* @Onward) End),      
            SlabID = @SlabID     
            From tbl_merp_QPSAbsData QPSAbs, (Select QPSDtl.SchemeID, QPSDtl.PayoutID, QPSDtl.CustomerId,   
                                               Sum(QPSDtl.Quantity * QPSDtl.SalePrice) SalesValue      
                       From tbl_merp_QPSDtlData QPSDtl, Items I      
                                               Where QPSDtl.Product_Code = I.Product_Code And       
                                               QPSDtl.CustGroupID = @GroupID And       
                                               QPSDtl.SchemeID = @schemeId And QPSDtl.PayoutID = @PayoutID      
                                               Group by QPSDtl.SchemeID, QPSDtl.PayoutID, QPSDtl.CustomerId) QPSDtl     
            Where QPSAbs.ApplyOn >= @FromLim And QPSAbs.ApplyOn <= @Tolim And       
            QPSAbs.ApplyOn >= (Case @Onward When 0 Then 0 Else @Onward End) And      
            QPSAbs.GroupID = @GroupID And       
            QPSAbs.SchemeID = @schemeId And       
            QPSAbs.PayoutID = @PayoutID And       
            QPSAbs.CustomerID = QPSDtl.CustomerID And   
            QPSAbs.SchemeID = QPSDtl.SchemeID And       
            QPSAbs.PayoutID = QPSDtl.PayoutID    
            /*Start of Free SKU Qty Generation*/      
            If @SchemeStatus = 2       
            Begin      
              Update tbl_merp_QPSAbsData       
              Set RebateQuantity=  RebateQuantity + (Case @Onward When 0 Then @FreeQty Else  Cast((ApplyOn/@onward) as Int) * @FreeQty End)      
              Where ApplyOn >=@FromLim And ApplyOn <=@Tolim and GroupID = @GroupID And       
              SchemeID = @schemeId And PayoutID = @PayoutID      
            End      
            /*End of Free SKU Qty Generation*/      
          End      
          Else      
          Begin /*----Normal Scheme----*/      
            Update QPSAbs       
            Set QPSAbs.SlabID = @SlabID, QPSAbs.PromotedValue = IsNull(QPSAbs.PromotedValue,0) + Case @PrimaryUOM When 4 then (Case @Onward When 0 Then QPSDtl.SalesValue Else  (Cast((QPSDtl.SalesValue/@onward) as Int)* @Onward) End) Else 0 End,    
            QPSAbs.PromotedQuantity = IsNull(QPSAbs.PromotedQuantity,0) + (Case @PrimaryUOM When 4 then 0 Else (Case @Onward When 0 Then ApplyOn Else  (Cast((ApplyOn/@onward) as Int)* @Onward) End) End)    
            From tbl_merp_QPSAbsData QPSAbs,      
                                    (Select QPSDtl.SchemeID, QPSDtl.PayoutID, QPSDtl.CustomerId, QPSDtl.Product_code,   
                                     Sum(QPSDtl.Quantity * QPSDtl.SalePrice) SalesValue      
                                     From tbl_merp_QPSDtlData QPSDtl, Items I      
                                     Where QPSDtl.Product_Code = I.Product_Code And       
                                         QPSDtl.CustGroupID = @GroupID And       
                                         QPSDtl.SchemeID = @schemeId And QPSDtl.PayoutID = @PayoutID      
                                     Group by QPSDtl.SchemeID, QPSDtl.PayoutID, QPSDtl.CustomerId, QPSDtl.Product_code) QPSDtl      
            Where QPSAbs.ApplyOn >= @FromLim And QPSAbs.ApplyOn <= @Tolim And       
            QPSAbs.ApplyOn >= (Case @Onward When 0 Then 0 Else @Onward End) And      
            QPSAbs.GroupID = @GroupID And       
            QPSAbs.SchemeID = @schemeId And       
            QPSAbs.PayoutID = @PayoutID And       
            QPSAbs.CustomerID = QPSDtl.CustomerID And       
            QPSAbs.SchemeID = QPSDtl.SchemeID And       
            QPSAbs.PayoutID = QPSDtl.PayoutID And     
            IsNull(QPSAbs.Product_code,N'') = QPSDtl.Product_code  
            /*Start of Free SKU Qty Generation*/      
            If @SchemeStatus = 2       
              Begin      
              Update tbl_merp_QPSAbsData       
              Set RebateQuantity =IsNull(RebateQuantity,0) + Case @Onward When 0 Then @FreeQty Else (Cast ((Case @PrimaryUOM When 4 Then QPSAbs.ApplyON  Else QPSDtl.Quantity End) / @Onward as Int) * @FreeQty) End      
              From tbl_merp_QPSAbsData QPSAbs,      
                                    (Select QPSDtl.SchemeID, QPSDtl.PayoutID, QPSDtl.CustomerId, QPSDtl.Product_code, Sum(QPSDtl.Quantity/(Case @PrimaryUOM When 1 Then 1       
                                                                                                        When 2 Then IsNull(I.Uom1_conversion,1)       
                                                                                                        When 3 Then IsNull(I.Uom2_conversion,1) End)) as Quantity      
                                     From tbl_merp_QPSDtlData QPSDtl, Items I      
                                     Where QPSDtl.Product_Code = I.Product_Code And       
                                        --QPSDtl.CustGroupID = @GroupID And       
                                        QPSDtl.SchemeID = @schemeId And QpSDtl.PayoutID = @PayoutID      
                                     Group by QPSDtl.SchemeID, QPSDtl.PayoutID, QPSDtl.CustomerId,QPSDtl.Product_code) QPSDtl      
              Where QPSAbs.ApplyOn >= @FromLim And QPSAbs.ApplyOn <= @Tolim And       
              QPSAbs.GroupID = @GroupID And       
              QPSAbs.SchemeID = @schemeId And       
              QPSAbs.PayoutID = @PayoutID And       
              QPSAbs.CustomerID = QPSDtl.CustomerID And       
              QPSAbs.SchemeID = QPSDtl.SchemeID And       
              QPSAbs.PayoutID = QPSDtl.PayoutID And   
              IsNull(QPSAbs.Product_code,N'') = QPSDtl.Product_code    
            End      
            /*End of Free SKU Qty Generation*/      
          End       
--          /*To Update RFA Rebate Val*/      
--          Update AbsData Set AbsData.RFARebateValue=DtlData.SalesValue       
--          From tbl_merp_QPSAbsData AbsData, (Select DtlData.SchemeID, DtlData.PayoutID, DtlData.customerID, (SalePrice * Quantity) 'SalesValue'       
--                                             From tbl_merp_QPSDtlData DtlData, #tmpSchProducts SchProducts      
--                                             Where DtlData.SchemeID = @schemeId And PayoutID = @PayoutID and       
--                            SchProducts.Product_Code = DtlData.Product_Code And SchProducts.SchemeID = DtlData.SchemeID) DtlData      
--          Where AbsData.GroupID = @GroupID And       
--          AbsData.SchemeID = @schemeId And AbsData.PayoutID = @PayoutID And       
--          AbsData.SchemeID = DtlData.SchemeID And       
--          AbsData.PayoutID = DtlData.PayoutID And       
--          AbsData.CustomerID =  DtlData.CustomerID      
        End          
        /* --------------- Falling Slab --------------- */       
      End      
    
            
      /*-----------start Updating Cat/SubCat/div and UOM Value -----------*/       
      Update QPSDetail Set Division = IC2.Category_Name, SubCategory = IC1.Category_Name, MarketSKU = IC.Category_Name, UOM = U.Description      
      From tbl_merp_QPSDtlData QPSDetail,Items I , ItemCategories IC, ItemCategories IC1,ItemCategories IC2,UOM U      
      Where QPSDetail.QPSAbsDataID = @AbsRowID And       
        QPSDetail.Product_Code = I.Product_Code And      
        I.CategoryID = IC.CategoryID And      
        IC.ParentID = IC1.CategoryID And      
        IC1.ParentID = IC2.CategoryID And      
        I.UOM = U.UOM      
      /*-----------End of Updating Cat/SubCat/div and UOM Value -----------*/       
      
      /*------ Start of Updating Promoted Qty and Value on Detail----------*/      
      Declare @SumOfSalesVal Decimal(18,6)      
      Declare @SumOfSalesQty Decimal(18,6)      
      Declare @SumOfPromoVal Decimal(18,6)      
      Declare @SumOfPromoQty Decimal(18,6)      
      Declare @RebateValue Decimal(18,6)      
      Declare @RFARebateValue Decimal(18,6)      
      Declare @RebateQty Decimal(18,6)      
      Declare @CustomerID nVarchar(50)      
      Declare @ApplyON Decimal(18,6)      
      Declare @RowID Int      
      Declare @SumOfUOMQty Decimal(18,6)    
      Declare @Prod_Code nVarchar(30)   
      
    
      Declare Cur_ValUpdate Cursor For      
      Select QPSAbsData.RowID, QPSAbsData.CustomerID, Sum(QPSDtlData.SaleValue) SumOfSalesVal, Sum(QPSAbsData.Quantity), Sum(QPSAbsData.PromotedValue) PromotedValue,Sum(QPSAbsData.PromotedQuantity),       
      Sum(QPSAbsData.RebateValue), Sum(QPSAbsData.RebateQuantity), Sum(QPSAbsData.RFARebateValue), Sum(QPSAbsData.ApplyOn),    
      Case @PrimaryUOM When 1 Then Sum(QPSAbsData.Quantity) When 2 Then Sum(QPSAbsData.UOM1Qty) When 3 Then Sum(QPSAbsData.UOM2Qty) Else 1 End, IsNull(QPSAbsData.Product_code,N'')    
      From tbl_merp_QPSAbsData  QPSAbsData, (Select SchemeId, PayoutID, customerID, (Case @ItemGroup When 1 Then Product_Code else N'' End) Product_Code,   
                                             Sum(SalePrice * quantity) SaleValue From tbl_merp_QPSDtlData Where SchemeID = @SchemeID and PayoutID =@PayoutID And CustGroupID =@GroupID   
                                             Group By SchemeId, PayoutID, customerID, Case @ItemGroup When 1 Then Product_Code else N'' End) QPSDtlData     
      Where QPSAbsData.SchemeID = @SchemeID and QPSAbsData.PayoutID = @PayoutID and QPSAbsData.GroupID = @GroupID    
      and IsNull(QPSAbsData.SlabID,0) = @SlabID and  IsNull(QPSAbsData.SlabID,0) > 0      
      and QPSAbsData.SchemeID = QPSDtlData.SchemeID     
      and QPSAbsData.PayoutID = QPSDtlData.PayoutID     
      and QPSAbsData.CustomerID = QPSDtlData.CustomerID    
      and IsNull(QPSAbsData.Product_Code,N'') = Case @ApplicableOn When 1 Then IsNull(QPSDtlData.Product_Code,N'') Else N'' End  
      Group By QPSAbsData.SchemeID, QPSAbsData.PayoutID, QPSAbsData.CustomerID, QPSAbsData.RowID, IsNull(QPSAbsData.Product_Code,N'')    
         
      Open Cur_ValUpdate      
      Fetch Next from Cur_ValUpdate Into @RowID, @CustomerID, @SumOfSalesVal, @SumOfSalesQty, @SumOfPromoVal, @SumOfPromoQty, @RebateValue, @RebateQty, @RFARebateValue, @ApplyON, @SumOfUOMQty, @Prod_Code      
      While @@Fetch_Status = 0      
      Begin      
        If @ApplicableOn = 1  /* Item or Spl Cat Scheme*/      
        Begin      
          Declare @CustRecCnt Int       
          Select @CustRecCnt = Count(*) From tbl_merp_QPSDtlData Where CustomerID = @CustomerID and QPSAbsDataID = @RowID      
          If @ItemGroup = 2 /*Spl Cat*/      
          Begin      
            If @SlabType = 1 or @SlabType = 2 /*Percentage or Amount*/      
              Begin      
              If @PrimaryUOM = 4       
                Begin 
                --print @SumOfPromoVal
                Update tbl_merp_QPSDtlData    
    Set Promoted_val = Case @SumOfSalesVal When 0 Then 0 Else (@SumOfPromoVal/@SumOfSalesVal) End * (SalePrice * Quantity),  
--                    Rebate_val = Propotion done with respect to promo value    
                    Rebate_val =  (Case @SumOfPromoVal when 0 then 0 Else (((Case @SumOfSalesVal When 0 Then 0 Else (@SumOfPromoVal/@SumOfSalesVal) End) *  (SalePrice * Quantity))/@SumOfPromoVal) end) * @RebateValue,     
                    RFARebate_Val =(Case @SumOfPromoVal when 0 then 0 Else (((Case @SumOfSalesVal When 0 Then 0 Else (@SumOfPromoVal/@SumOfSalesVal) End) * (SalePrice * Quantity))/@SumOfPromoVal) end)* @RFARebateValue    
                Where CustomerID = @CustomerID and SchemeID = @SchemeId and PayoutID = @PayoutID and QPSAbsDataID = @RowID      
                End       
              Else      
                Begin     
				
                Update QPSDtlData       
                /*As per ITC Suggestion proportionated Promoted Qty is Converted as Base UOM Qty*/      
                Set Promoted_qty = ((Quantity/@SumOfSalesQty)*((@SumOfSalesQty/@SumOfUOMQty)*@SumOfPromoQty)),      
                Promoted_Val = ((Quantity/@SumOfSalesQty)*((@SumOfSalesQty/@SumOfUOMQty)*@SumOfPromoQty)) * (SalePrice),      
                Promoted_UOM = IsNull(@PrimaryUOM,0),      
                --Rebate_val = Propotion done with respect to promo value    
    Rebate_val = ((Case @SumOfPromoVal When 0 Then 0 Else (((Quantity/@SumOfSalesQty)*((@SumOfSalesQty/@SumOfUOMQty)*@SumOfPromoQty)) * (SalePrice))/ @SumOfPromoVal End)* @RebateValue),  
                Rebate_UOM = IsNull(@FreeUOM,0),       
                RFARebate_Val = ((Case @SumOfPromoVal When 0 Then 0 Else (((Quantity/@SumOfSalesQty)*((@SumOfSalesQty/@SumOfUOMQty)*@SumOfPromoQty)) * (SalePrice))/@SumOfPromoVal End) * @RFARebateValue)    
                From tbl_merp_QPSDtlData QPSDtlData, Items      
                Where QPSDtlData.Product_code = Items.Product_code and       
                CustomerID = @CustomerID and QPSDtlData.SchemeID = @SchemeId and PayoutID = @PayoutID and QPSAbsDataID = @RowID      
                End       
              End      
            Else if @SlabType = 3      
              Begin      
              If @PrimaryUOM = 4       
                Begin      
                Update tbl_merp_QPSDtlData      
    Set Promoted_val = (Case @SumOfSalesVal When 0 Then 0 Else (@SumOfPromoVal/@SumOfSalesVal) End) * (SalePrice * Quantity),      
                Rebate_qty =  (((@SumOfPromoQty/@SumOfSalesQty) * Quantity)/@SumOfPromoQty)* @RebateQty,      
                Rebate_val =  ((((@SumOfPromoQty/@SumOfSalesQty) * Quantity)/@SumOfPromoQty)* @RebateQty) * (SalePrice + ( SalePrice * (TaxPercent/100))),      
                Rebate_UOM = IsNull(@FreeUOM,0)       
                Where CustomerID = @CustomerID and SchemeID = @SchemeId and PayoutID = @PayoutID and QPSAbsDataID = @RowID      
                End      
              Else      
                Begin      
                Update QPSDtlData      
                /*As per ITC Suggestion proportionated Promoted Qty is Converted as Base UOM Qty*/      
                Set Promoted_qty = ((Quantity/@SumOfSalesQty)*((@SumOfSalesQty/@SumOfUOMQty)*@SumOfPromoQty)),      
                Promoted_Val = ((Quantity/@SumOfSalesQty)*((@SumOfSalesQty/@SumOfUOMQty)*@SumOfPromoQty)) * (SalePrice),      
                Promoted_UOM = IsNull(@PrimaryUOM,0),      
                Rebate_qty =  (((@SumOfPromoQty/@SumOfSalesQty) * Quantity)/@SumOfPromoQty)* @RebateQty,      --                Rebate_val =  ((((@SumOfPromoQty/@SumOfSalesQty) * Quantity)/@SumOfPromoQty)* @RebateQty)* (SalePrice + ( SalePrice * (TaxPercent/100))),      
                Rebate_UOM = IsNull(@FreeUOM,0)      
                From tbl_merp_QPSDtlData QPSDtlData, Items      
                Where QPSDtlData.Product_code = Items.Product_code and       
                CustomerID = @CustomerID and QPSDtlData.SchemeID = @SchemeId and PayoutID = @PayoutID and QPSAbsDataID = @RowID      
                End      
              End      
          End      
          Else If @ItemGroup = 1 /*Normal Sch*/      
            Begin      
            If @SlabType = 1 or @SlabType = 2 /*Percentage or Amount*/      
              Begin       
              If @PrimaryUOM = 4       
                Begin      
                Update tbl_merp_QPSDtlData    
    Set Promoted_val = (Case @SumOfSalesVal When 0 Then 0 Else (@SumOfPromoVal/@SumOfSalesVal) End) * (SalePrice * Quantity),    
                --Rebate_val = Propotion done with respect to promo value    
    Rebate_val = (Case @SumOfPromoVal When 0 Then 0 Else ((@SumOfPromoVal/@SumOfSalesVal) * (SalePrice * Quantity))/@SumOfPromoVal End) * @RebateValue,     
    RFARebate_Val = (Case @SumOfPromoVal When 0 Then 0 Else ((@SumOfPromoVal/@SumOfSalesVal) * (SalePrice * Quantity))/@SumOfPromoVal End) * @RFARebateValue    
                Where CustomerID = @CustomerID and SchemeID = @SchemeId and PayoutID = @PayoutID and QPSAbsDataID = @RowID and Product_code = @Prod_code     
                End       
              Else    
                Begin     
                Update QPSDtlData        
                /*As per ITC Suggestion proportionated Promoted Qty is Converted as Base UOM Qty*/      
                Set Promoted_val = ((Quantity/@SumOfSalesQty)*((@SumOfSalesQty/@SumOfUOMQty)*@SumOfPromoQty)) * (SalePrice),      
                Promoted_qty = ((Quantity/@SumOfSalesQty)*((@SumOfSalesQty/@SumOfUOMQty)*@SumOfPromoQty)),        
                Promoted_UOM = IsNull(@PrimaryUOM,0),       
                --Rebate_val = Propotion done with respect to promo value    
                Rebate_val = (Case @SumOfPromoVal When 0 Then 0 Else (((Quantity/@SumOfSalesQty)*((@SumOfSalesQty/@SumOfUOMQty)*@SumOfPromoQty)) * (SalePrice)) / @SumOfPromoVal End)  * @RebateValue,     
                RFARebate_Val =  (Case @SumOfPromoVal When 0 Then 0 Else (((Quantity/@SumOfSalesQty)*((@SumOfSalesQty/@SumOfUOMQty)*@SumOfPromoQty)) * (SalePrice))/@SumOfPromoVal End) * @RFARebateValue      
                From tbl_merp_QPSDtlData QPSDtlData, Items      
                Where QPSDtlData.Product_code = Items.Product_code and CustomerID = @CustomerID and QPSDtlData.SchemeID = @SchemeId and PayoutID = @PayoutID and QPSAbsDataID = @RowID  and QPSDtlData.Product_code = @Prod_code    
                End    
              End      
            Else if @SlabType = 3 /*Item Free*/      
              Begin       
              If @PrimaryUOM = 4       
                Begin      
                Update tbl_merp_QPSDtlData      
                Set Promoted_val = (Case @SumOfSalesVal When 0 Then 0 Else (@SumOfPromoVal/@SumOfSalesVal) End) * (SalePrice * Quantity),      
                Rebate_Qty = (Case @SumOfPromoVal When 0 Then 0 Else ((Case @SumOfSalesVal When 0 Then 0 Else (@SumOfPromoVal/@SumOfSalesVal) End) * (SalePrice * Quantity))/@SumOfPromoVal End)* @RebateQty,     
                Rebate_val =  ((Case @SumOfPromoVal When 0 Then 0 Else((@SumOfPromoQty/@SumOfSalesQty) * Quantity)/@SumOfPromoVal End)* @RebateQty) * (SalePrice + ( SalePrice * (TaxPercent/100))),      
                Rebate_UOM = IsNull(@FreeUOM,0)       
                Where CustomerID = @CustomerID and SchemeID = @SchemeId and PayoutID = @PayoutID and QPSAbsDataID = @RowID and Product_code = @Prod_code     
                End    
              Else       
                Begin    
                Update QPSDtlData       
                /*As per ITC Suggestion proportionated Promoted Qty is Converted as Base UOM Qty*/        
                Set Promoted_qty = ((Quantity/@SumOfSalesQty)*((@SumOfSalesQty/@SumOfUOMQty)*@SumOfPromoQty)),       
                Promoted_val = ((Quantity/@SumOfSalesQty)*((@SumOfSalesQty/@SumOfUOMQty)*@SumOfPromoQty)) * (SalePrice),      
                Promoted_UOM = IsNull(@PrimaryUOM,0),      
                Rebate_qty = (((@SumOfPromoQty/@SumOfSalesQty) * Quantity)/@SumOfPromoQty)* @RebateQty,       
              --Rebate_qty = (((Quantity/@SumOfSalesQty)*((@SumOfSalesQty/@SumOfUOMQty)*@SumOfPromoQty))/@SumOfSalesQty) * @RebateQty,      
              --Rebate_val = Case @CustRecCnt When 0 then 0 else ((@RebateQty/@CustRecCnt) * (SalePrice + (SalePrice * (TaxPercent/100)))) End,      
                Rebate_UOM = IsNull(@FreeUOM,0)       
                From tbl_merp_QPSDtlData QPSDtlData, Items      
                Where QPSDtlData.CustomerID = @CustomerID And QPSDtlData.Product_code = Items.Product_code and QPSDtlData.SchemeID = @SchemeId and PayoutID = @PayoutID and QPSAbsDataID = @RowID and QPSDtlData.Product_code = @Prod_code     
                End     
              End    
            End    
        End      
        Else if (@ApplicableOn = 2)  /*Invoice Based*/  
        Begin  
          If (@PrimaryUOM = 4)  
          Begin  
            If (@SlabType=1 or @SlabType=2) /*Amount or Percentage*/  
            Begin    
              Update tbl_merp_QPSDtlData  
              Set Promoted_val = (Case @SumOfSalesVal When 0 Then 0 Else (@SumOfPromoVal/@SumOfSalesVal) End) * (SalePrice * Quantity),  
         Rebate_val = (Case @SumOfPromoVal When 0 Then 0 Else ((Case @SumOfSalesVal When 0 Then 0 Else (@SumOfPromoVal/@SumOfSalesVal) End) * (SalePrice * Quantity))/@SumOfPromoVal End) * @RebateValue,   
                    RFARebate_Val = (Case @SumOfPromoVal When 0 then 0 Else ((Case @SumOfSalesVal When 0 Then 0 Else (@SumOfPromoVal/@SumOfSalesVal) End) * (SalePrice * Quantity))/@SumOfPromoVal End) * @RFARebateValue  
                Where CustomerID = @CustomerID and SchemeID = @SchemeId and PayoutID = @PayoutID and QPSAbsDataID = @RowID    
            End     
            Else If @SlabType=3 /* Free SKU*/  
            Begin  
              Update tbl_merp_QPSDtlData  
              Set Promoted_val = (Case @SumOfSalesVal When 0 Then 0 Else (@SumOfPromoVal/@SumOfSalesVal) End) * (SalePrice * Quantity),  
                    Rebate_qty = (Case @SumOfPromoVal When 0 Then 0 Else ((Case @SumOfSalesVal When 0 Then 0 Else (@SumOfPromoVal/@SumOfSalesVal) End) * (SalePrice * Quantity))/@SumOfPromoVal End) * @RebateQty  
                Where CustomerID = @CustomerID and SchemeID = @SchemeId and PayoutID = @PayoutID and QPSAbsDataID = @RowID    
            End  
          End  
        End  
        Fetch Next from Cur_ValUpdate Into @RowID, @CustomerID, @SumOfSalesVal, @SumOfSalesQty, @SumOfPromoVal, @SumOfPromoQty, @RebateValue, @RebateQty, @RFARebateValue, @ApplyON, @SumOfUOMQty, @Prod_Code      
      End      
      Close Cur_ValUpdate      
      Deallocate Cur_ValUpdate      
      /*------  End of Updating Promoted Qty and Value ----------------*/      
      Fetch next From SchemeDiscount Into @SlabID, @GroupID, @SlabType, @PrimaryUOM, @FromLim, @ToLim, @Discount, @Onward, @FreeUOM, @FreeQty      
    End              
    Close SchemeDiscount              
    Deallocate SchemeDiscount      
  End      
  
  Declare @SchSlabType INT  
  Declare CurSchSlabType Cursor For  
  Select Distinct SlabType From tbl_mERP_SchemeSlabDetail Where SchemeId=@SchemeID   
  Open CurSchSlabType  
  Fetch Next From CurSchSlabType into @SchSlabType  
  While (@@Fetch_Status) = 0  
  Begin  
    If @Schemestatus = 2       
    Begin      
      If (@SchSlabType=1 or @SchSlabType=2)      
        Begin      
        /*Insert Record for each Payout Customer*/      
        Insert into SchemeCustomers      
        Select  @SchemeID, CustomerID, Sum(RebateValue), 0 From tbl_merp_QPSAbsData       
        Where IsNull(RebateValue,0) > 0 And       
        SchemeID = @SchemeID And       
        PayoutID = @PayoutID        
        Group By CustomerID  
        Select @CashDisc_Count = @@RowCount      
        End        
      Else if @SchSlabType=3      
        Begin      
        Insert into  SchemeCustomerItems (SchemeId, GroupID, PayoutID, SlabID, CustomerID,Product_code,Quantity,Pending,Claimed)        
        Select @SchemeID, @GroupID, @PayoutID, IsNull(QPSAbs.SlabID,0), QPSAbs.CustomerID, FreeSKU.SKUCode,       
          Case IsNull(SlabDet.FreeUOM,0) When 1 Then Sum(QPSAbs.RebateQuantity)      
            When 2 Then Sum(QPSAbs.RebateQuantity * IsNull(Items.Uom1_Conversion,1))      
            When 3 Then Sum(QPSAbs.RebateQuantity * IsNull(Items.Uom2_Conversion,1))      
            Else Sum(QPSAbs.RebateQuantity) End as 'Qty',       
          Case IsNull(SlabDet.FreeUOM,0) When 1 Then Sum(QPSAbs.RebateQuantity)      
            When 2 Then Sum(QPSAbs.RebateQuantity * IsNull(Items.Uom1_Conversion,1))      
            When 3 Then Sum(QPSAbs.RebateQuantity * IsNull(Items.Uom2_Conversion,1))      
            Else Sum(QPSAbs.RebateQuantity) End as 'Pending', 0 'Claimed'      
        From tbl_merp_QPSAbsData QPSAbs
		inner join tbl_mERP_SchemeFreeSKU FreeSKU on IsNull(QPSAbs.SlabID,0) = FreeSKU.SlabID      
		inner join tbl_mERP_SchemeSlabDetail SlabDet on  SlabDet.SlabID = FreeSKU.SlabID  and  QPSAbs.SchemeID = SlabDet.SchemeID And QPSAbs.GroupID = SlabDet.GroupID  
		left outer join Items on Items.Product_Code = FreeSKU.SKUCode   
        Where         
        QPSAbs.RebateQuantity > 0 And       
      
	    
        QPSAbs.SchemeID = @SchemeID And       
        QPSAbs.PayoutID = @PayoutID        
        Group By QPSAbs.CustomerID, QPSAbs.SlabID, FreeSKU.SKUCode , IsNull(SlabDet.FreeUOM,0)      
        End      
  
/* For SCh Min Qty - FITC-4413 start: */  
  If Exists(select * from tbl_merp_schemeAbstract Where SchemeID = @SchemeID And Isnull(IsMinQty,0)=1)  
  Begin  
   Declare @Tmp_CustomerID as Nvarchar(255)  
   Declare Cur_Cust Cursor for   
   select Distinct CustomerID from tbl_mERP_QPSDtlData Where SchemeId = @SchemeID And payoutID = @PayoutID  
   Open Cur_Cust  
   Fetch from Cur_Cust into @Tmp_CustomerID  
   While @@fetch_status =0  
    Begin   
      Declare @QPSMinstatus as Table(QPSMinstatus Int)   
      Delete From @QPSMinstatus  
      Insert Into @QPSMinstatus  
      Exec sp_GetQPSValidation @SchemeID,@PayoutID,@Tmp_CustomerID  
       
      If (Select Top 1 QPSMinstatus From @QPSMinstatus) = 0  
      Begin  
		 Update tbl_mERP_QPSDtlData Set Promoted_Qty = 0,Promoted_Val = 0,Rebate_Qty = 0,Rebate_Val = 0, RFARebate_Val = 0,Promoted_UOM = Null,Rebate_UOM = Null Where SchemeId = @SchemeID And payoutID = @PayoutID And CustomerID = @Tmp_CustomerID  
		 Update tbl_mERP_QPSAbsData Set SlabID  = Null,PromotedQuantity = 0,PromotedValue= 0,RebateQuantity = 0,RebateValue = 0, RFARebateValue = 0 Where SchemeId = @SchemeID And payoutID = @PayoutID And CustomerID = @Tmp_CustomerID  
	     
		 Delete from SchemeCustomerItems Where SchemeId = @SchemeID And payoutID = @PayoutID And CustomerID = @Tmp_CustomerID  
      End  
    Fetch Next from Cur_Cust into @Tmp_CustomerID  
    End  
   Close Cur_Cust  
   Deallocate Cur_Cust  
  End  
/* For SCh Min Qty - FITC-4413 End: */  
  
      If @CashDisc_Count > 0       
        Begin       
        -- To Insert Credit Note       
        Declare @CustID nVarchar(50)      
        Declare @ClaimAmount Decimal(18,6)      
        Declare @CreditNoteID Int      
        Declare @EXPACCID INT       
        Declare @TransDate DateTime       
        Select @TransDate = GetDate()      
        Declare GenCreditNote Cursor For      
        Select CustomerID, Sum(IsNull(RebateValue,0)) From tbl_merp_QPSAbsData       
        Where IsNull(RebateValue,0) > 0 And   
            SchemeID = @SchemeID And       
            PayoutID = @PayoutID   
        Group By CustomerID   
        Open GenCreditNote      
        Fetch From GenCreditNote Into @CustID, @ClaimAmount      
        While (@@Fetch_Status = 0)      
          Begin      
          -- Select * from CreditNote     
          Exec sp_insert_CreditNote 0, @CustID, @ClaimAmount, @TransDate, @SchemeDesc       
          Select @CreditNoteID = @@Identity      
          Update CreditNote Set Flag = 1, DocumentReference = @VoucherPrefix + Cast(DocumentID as nVarchar(10)), PayoutID = @PayoutID      
           , Memo = 'CR' + Cast(DocumentID as nVarchar(10)) + '-' + @PayoutDate + '-' + @SchemeDesc      
          Where CreditID = @CreditNoteID      
         
			--FRITFITC-678-Auto Adjust Credit Notes
			--Type : 2 = QPS Scheme Credit Note DataPost to CrNoteDSType Table 
			exec sp_CrNoteDSType_DataPost @CreditNoteID,2 
	          
          --FA Updation       
          IF @RFA_Claimable = 1      
            Begin      
              SET @EXPACCID = @SECONDARY_SCHEME_ACC      
            End       
          Else      
            Begin      
              SET @EXPACCID = @PRIMARY_SCHEME_ACC      
            End       
          -- Master Updation      
          Exec sp_acc_master_addaccount 5, @EXPACCID, '', @CreditNoteID      
          -- Journal Updation      
          Exec sp_acc_gj_creditnote @CreditNoteID      
      
          Fetch From GenCreditNote Into @CustID, @ClaimAmount      
     End       
        Close GenCreditNote      
        Deallocate GenCreditNote      
        End       
      End      
    Else /*Capture the Credits Generated Already*/      
      Begin      
      /*-----------Start of Updating Free Qty / CrNote Value ---------*/      
      If (@SchSlabType=1 or @SchSlabType=2) and @ItemGroup = 2       
        Begin      
        Update tmpAbs Set tmpAbs.RebateValue = CN.NoteValue       
        From tbl_merp_QPSAbsData tmpAbs, (select CustomerID, PayoutID, Sum(NoteValue) as NoteValue From CreditNote Where IsNull(Status,0) & 64 = 0 Group By CustomerID, PayoutID) CN      
        Where tmpAbs.PayoutID = @PayoutID and       
           tmpAbs.PayoutID = CN.PayoutID and      
           tmpAbs.CustomerID = CN.CustomerID        
        End       
      Else if @SchSlabType=3 and @ItemGroup = 2      
        Begin      
        Update tmpAbs Set tmpAbs.RebateQuantity = FreeSKU.Quantity      
        From tbl_merp_QPSAbsData tmpAbs, (select CustomerID, SlabID, PayoutID, Sum(Quantity) as Quantity From SchemeCustomerItems Group By CustomerID, SlabID, PayoutID) FreeSKU      
        Where tmpAbs.PayoutID = @PayoutID and       
           tmpAbs.PayoutID = FreeSKU.PayoutID and      
           tmpAbs.CustomerID = FreeSKU.CustomerID and       
           tmpAbs.SlabID = FreeSKU.SlabID        
        End      
      End   
  Fetch Next From CurSchSlabType into @SchSlabType  
  End     
  Close CurSchSlabType  
  Deallocate CurSchSlabType  
  /*-----------End of To Update Free Qty / CrNote Value -----------*/    
  
  If @SchemeStatus = 2       
  Begin      
    Update tbl_mERP_SchemePayoutPeriod Set Status = Status | 128 Where SchemeID =  @SchemeID and ID = @PayoutID      
    Select @@RowCount    
  End    
  Drop table #tmpSchCustomer      
  Drop table #tmpSchProducts     
End
