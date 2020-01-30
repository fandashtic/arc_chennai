CREATE Procedure mERP_sp_view_QPSDataInfo(@SchPayoutLst nVarchar(2000))    
As    
Begin    
  /*Cursor To Split the Scheme and Payout*/    
--Declare @SchPayoutLst nVarchar(2000)    
  Declare @Delimiter Char(1)    
  Set @Delimiter = Char(3)    
  --Set @SchPayoutLst = '145,205145,206145,207'    
  Create table #tmpSchPayout(SchemeID Int, PayoutID Int)    
  Declare @SchPayout nVarchar(25)    
  Declare CurSchPayout Cursor For    
  Select * from dbo.sp_SplitIn2Rows(@SchPayoutLst, @Delimiter)    
  Open CurSchPayout    
  Fetch Next From CurSchPayout Into @SchPayout    
  While(@@Fetch_Status = 0 )    
  Begin    
    Insert into #tmpSchPayout(SchemeID, PayoutID)    
    Select LTRIM(RTRIM(SubString(@SchPayout,1,CharIndex(',',@SchPayout)-1))), LTRIM(RTRIM(SubString(@SchPayout,CharIndex(',',@SchPayout)+1,Len(@SchPayout))))    
    Fetch Next From CurSchPayout Into @SchPayout    
  End    
  Close CurSchPayout    
  Deallocate CurSchPayout    
    
--Select * from #tmpSchPayout  
    
  /*Temp Tables to store the result data*/    
  Create table #tmpAbsQPSData(          
       QPSDataRowID Int,     
       SchemeType  nvarchar(15)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
       ActivityCode  nvarchar(50)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
       ActivityDesc  nvarchar(510)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
       ActiveFrom  DateTime,    
       ActiveTo  DateTime,    
       PayoutFrom  DateTime,    
       PayoutTo  DateTime,    
       Division  nvarchar(510)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
       SubCategory  nvarchar(510)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
       MarketSKU  nvarchar(510)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
       SystemSKU  nvarchar(510)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
       UOM  nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,    
       SaleQty Decimal(18,6) Default(0),    
       SaleValue Decimal(18,6) Default(0),    
       PromotedQty Decimal(18,6) Default(0),    
       PromotedVal Decimal(18,6) Default(0),    
       FreeBaseUOM nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,    
       RebateQty Decimal(18,6) Default(0),    
       RebateVal Decimal(18,6) Default(0),    
       BudgetedQty Decimal(18,6) Default(0),    
       BudgetedValue Decimal(18,6) Default(0),    
       AppOn nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,    
       SubmittedOn nvarchar(25)  COLLATE SQL_Latin1_General_CP1_CI_AS)    
    
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
  Declare @SchemeID Int, @PayoutID Int, @GroupID Int, @SlabType Int, @ApplyOn int, @ItemGrp Int    
  Declare CurSchPayoutGrp Cursor For    
  Select Distinct SchGrp.SchemeID, SchPayout.PayoutID, SchGrp.SubGroupID, SlabDetail.SlabType, SchAbs.ApplicableOn, SchAbs.ItemGroup     
  from tbl_mERP_SchemeSubGroup SchGrp
  inner join #tmpSchPayout SchPayout on SchGrp.SchemeID = SchPayout.SchemeID      
  inner join tbl_merp_SchemeOutlet Outlet on   Outlet.SchemeID = SchPayout.SchemeID      
  left outer join tbl_merp_schemeSlabDetail SlabDetail on   SlabDetail.SchemeID = SchPayout.SchemeID    and   Outlet.GroupID = SlabDetail.GroupID  
  inner join tbl_merp_SchemeAbstract SchAbs    on SchAbs.SchemeID = SchPayout.SchemeID  
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
        Insert into #tmpAbsQPSData(QPSDataRowID, SchemeType, ActivityCode, ActivityDesc, ActiveFrom, ActiveTo, PayoutFrom,PayoutTo, Division, SubCategory, MarketSKU,SystemSKU,     
        UOM, SaleQty, SaleValue, PromotedQty, PromotedVal, RebateQty, RebateVal, BudgetedQty, BudgetedValue, AppOn, SubmittedOn)    
        Select QPSDtl.QPSAbsDataID, SchType.SchemeType, SchAbs.ActivityCode, SchAbs.Description,     
        SchAbs.ActiveFrom, SchAbs.ActiveTo, SchPayout.PayoutPeriodFrom, SchPayout.PayoutPeriodTo,    
        QPSDtl.Division, QPSDtl.SubCategory, QPSDtl.MarketSKU, QPSDtl.Product_Code SystemSKU, QPSDtl.UOM,     
        Sum(QPSDtl.Quantity) SaleQty, Sum(QPSDtl.Quantity * QPSDtl.SalePrice) SaleValue,
        Sum(QPSDtl.Promoted_Qty) PromotedQty, Sum(QPSDtl.Promoted_Val) PromotedVal,    
        Case ISNull(Slabdet.SlabType,0) When 3 Then 0 Else Sum(Rebate_Qty) End RebateQty, 
        Case IsNull(Slabdet.SlabType,0) When 3 Then 0 Else Sum(Rebate_val) End RebateVal, 
        0 BudgetedQty, 0 BudgetedValue, Case SchAbs.ApplicableOn When 1 Then 'Line' when 2 then 'SPL_CAT' End AppOn, Convert(nVarchar(10),QPSAbs.CreationTime,103) SubmittedOn    
        From tbl_merp_QPSAbsData QPSAbs
		inner join tbl_merp_QPSDtlData QPSDtl on  QPSAbs.SchemeID = QPSDtl.SchemeID And  QPSAbs.PayoutID = QPSDtl.PayoutID And QPSAbs.CustomerID = QPSDtl.CustomerID  
        inner join  tbl_Merp_SchemePayoutPeriod SchPayout on SchPayout.ID = QPSAbs.PayoutID     
		inner join tbl_merp_SchemeAbstract SchAbs on  SchPayout.SchemeID = SchAbs.SchemeID     
		inner join tbl_merp_SchemeType SchType on SchAbs.SchemeType = SchType.ID
		left outer join tbl_merp_schemeSlabdetail Slabdet  on IsNull(QPSAbs.SlabID,0) = Slabdet.SlabID    
        Where      
        IsNull(QPSAbs.Product_code,N'') =  Case @ItemGrp When 1 then QPSDtl.Product_code  Else N'' End And 
        QPSAbs.SchemeID = @SchemeID And     
        QPSAbs.PayoutID = @PayoutID And     
        QPSAbs.GroupID = @GroupID And 

        (IsNull(QPSAbs.SlabID,0) > 0  or IsNull(RebateValue,0) > 0 )   
        Group by QPSDtl.QPSAbsDataID, SchType.SchemeType, SchAbs.ActivityCode, SchAbs.Description,     
        SchAbs.ActiveFrom, SchAbs.ActiveTo, SchPayout.PayoutPeriodFrom, SchPayout.PayoutPeriodTo, ISNull(Slabdet.SlabType,0),   
        QPSDtl.Division, QPSDtl.SubCategory, QPSDtl.MarketSKU, QPSDtl.Product_Code, QPSDtl.UOM, --QPSDtl.CustomerID,    
        SchAbs.ApplicableOn, Convert(nVarchar(10),QPSAbs.CreationTime,103)    
          
        /*Dtl data Selection*/    
        Insert into #tmpDtlQPSData(QPSDataRowID, ActivityCode, CompSchemeID, ActivityDesc, ActiveFrom, ActiveTo, BillRef, InvDocRef, OutletCode, OutletName, RCSID, ActiveInRCS, LineType, Division, SubCategory, MarketSKU, SystemSKU, UOM,    
        SaleQty, SaleValue, PromotedQty, PromotedVal, RebateQty, RebateVal, PriceExclTax, TaxPercentage, TaxAmount, PriceInclTax, BudgetedQty, BudgetedValue)    
        Select QPSDtl.QPSAbsDataID, SchAbs.ActivityCode, SchAbs.CS_SchemeId, SchAbs.Description,     
        SchAbs.ActiveFrom, SchAbs.ActiveTo, QPSDtl.BillRef, QPSDtl.InvDocRef, CM.CustomerID OutletCode, CM.Company_name OutletName,     
        IsNull(CM.RCSOutletID, '') as RCSID,    
        --IsNull((Select IsNull(TMDValue,N'') From  Cust_TMD_Master CTM, Cust_TMD_Details CTD Where     
        --      CTD.CustomerID = CM.CustomerID And CTM.TMDID = CTD.TMDID),'') as ActiveInRCS,     
		(Case when IsNull(CM.RCSOutletID,'') <> '' then 'Yes' else 'No' end) as ActiveInRCS,
        'MAIN' LineType, QPSDtl.Division, QPSDtl.SubCategory, QPSDtl.MarketSKU, QPSDtl.Product_code SystemSKU, QPSDtl.UOM,     
        Sum(QPSDtl.Quantity) SaleQty, Sum(QPSDtl.Quantity) * QPSDtl.SalePrice SaleValue,
        Sum(QPSDtl.Promoted_Qty) PromotedQty, Sum(QPSDtl.Promoted_Val) PromotedVal,    
        Case ISNull(Slabdet.SlabType,0) When 3 Then 0 Else Sum(Rebate_Qty) End RebateQty, 
        Case IsNull(Slabdet.SlabType,0) When 3 Then 0 Else Sum(Rebate_val) End RebateVal, 
        QPSDtl.SalePrice PriceExclTax, QPSDtl.TaxPercent TaxPercentage, Sum(TaxAmount) TaxAmount,      
        QPSDtl.SalePrice + (IsNull(QPSDtl.SalePrice,0)* IsNull(QPSDtl.TaxPercent,0)/100) PriceInclTax, 0 BudgetedQty, 0 BudgetedValue    
        From tbl_merp_QPSAbsData QPSAbs
		inner join tbl_merp_QPSDtlData QPSDtl on QPSAbs.SchemeID = QPSDtl.SchemeID And    QPSAbs.PayoutID = QPSDtl.PayoutID And QPSAbs.CustomerID = QPSDtl.CustomerID       
		inner join tbl_merp_SchemeAbstract SchAbs on SchAbs.SchemeID = QPSAbs.SchemeID       
		inner join Customer CM on CM.CustomerID = QPSDtl.CustomerID     
		left outer join tbl_merp_schemeSlabdetail Slabdet    on IsNull(QPSAbs.SlabID,0) = Slabdet.SlabID   
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
        Insert into #tmpAbsQPSData(QPSDataRowID, SchemeType, ActivityCode, ActivityDesc, ActiveFrom, ActiveTo, PayoutFrom, PayoutTo, Division, SubCategory, MarketSKU,     
        SystemSKU, UOM, SaleQty, SaleValue, PromotedQty, PromotedVal, RebateQty, RebateVal, BudgetedQty, BudgetedValue, AppOn, SubmittedOn)     
        Select QPSDtl.QPSAbsDataID,SchType.SchemeType, SchAbs.ActivityCode, SchAbs.Description,     
        SchAbs.ActiveFrom, SchAbs.ActiveTo, SchPayout.PayoutPeriodFrom, SchPayout.PayoutPeriodTo,    
        '' Division, '' SubCategory, '' MarketSKU, '' SystemSKU,  '' UOM,     
        0 SaleQty, 0 SaleValue, 0 PromotedQty, 0 PromotedVal,    
        0 RebateQty, 
        Case IsNull(Slabdet.SlabType,0) When 3 Then 0 Else Sum(Rebate_val) End RebateVal,
        0 BudgetedQty, 0 BudgetedValue, Case SchAbs.ApplicableOn When 1 Then 'Line' when 2 then 'SPL_CAT' End AppOn, Convert(nVarchar(10),QPSAbs.CreationTime,103) SubmittedOn    
        From tbl_merp_QPSAbsData QPSAbs
	inner join  tbl_merp_QPSDtlData QPSDtl on QPSAbs.SchemeID = QPSDtl.SchemeID And QPSAbs.PayoutID = QPSDtl.PayoutID And QPSAbs.CustomerID = QPSDtl.CustomerID  
		inner join tbl_merp_SchemeAbstract SchAbs on SchAbs.SchemeID = QPSAbs.SchemeID   
	inner join tbl_merp_SchemeType SchType on SchAbs.SchemeType = SchType.ID      
	inner join tbl_Merp_SchemePayoutPeriod SchPayout on   SchPayout.SchemeID = SchAbs.SchemeID   and  SchPayout.ID = QPSAbs.PayoutID         
	left outer join tbl_merp_schemeSlabdetail Slabdet    on    IsNull(QPSAbs.SlabID,0) = Slabdet.SlabID   
        Where    
        QPSAbs.SchemeID = @SchemeID And     
        QPSAbs.PayoutID = @PayoutID And     
        QPSAbs.GroupID = @GroupID And 
      
        (IsNull(QPSAbs.SlabID,0) > 0  or IsNull(RebateValue,0) > 0 ) 
        Group by QPSDtl.QPSAbsDataID, SchType.SchemeType, SchAbs.ActivityCode, SchAbs.Description, ISNull(Slabdet.SlabType,0),     
        SchAbs.ActiveFrom, SchAbs.ActiveTo, SchPayout.PayoutPeriodFrom, SchPayout.PayoutPeriodTo,    
        SchAbs.ApplicableOn, Convert(nVarchar(10),QPSAbs.CreationTime,103)     
  
        /*Dtl data Selection*/    
        Insert into #tmpDtlQPSData(QPSDataRowID, ActivityCode, CompSchemeID, ActivityDesc, ActiveFrom, ActiveTo, BillRef, InvDocRef, OutletCode, OutletName, RCSID, ActiveInRCS, LineType, Division, SubCategory, MarketSKU, SystemSKU, UOM,    
        SaleQty, SaleValue, PromotedQty, PromotedVal, RebateQty, RebateVal, PriceExclTax, TaxPercentage, TaxAmount, PriceInclTax, BudgetedQty, BudgetedValue)    
        Select QPSDtl.QPSAbsDataID, SchAbs.ActivityCode, SchAbs.CS_SchemeId, SchAbs.Description,     
        SchAbs.ActiveFrom, SchAbs.ActiveTo, QPSDtl.BillRef, QPSDtl.InvDocRef, CM.CustomerID OutletCode, CM.Company_name OutletName,     
        IsNull(CM.RCSOutletID, '') as RCSID,    
        --IsNull((Select IsNull(TMDValue,N'') From  Cust_TMD_Master CTM, Cust_TMD_Details CTD Where     
        --      CTD.CustomerID = CM.CustomerID And CTM.TMDID = CTD.TMDID),'') as ActiveInRCS,     
		(Case when IsNull(CM.RCSOutletID,'') <> '' then 'Yes' else 'No' end) as ActiveInRCS,
        '' LineType, '' Division, '' SubCategory, '' MarketSKU, '' SystemSKU, '' UOM,     
        0 SaleQty, 0 SaleValue, 0 PromotedQty, 0 PromotedVal, 0 RebateQty,
        Case IsNull(Slabdet.SlabType,0) When 3 Then 0 Else Sum(Rebate_val) End RebateVal, 
--        Case When @SlabType = 3 Then Max(QPSDtl.SalePrice) Else 0 End PriceExclTax, 
--        Case When @SlabType = 3 Then Max(TaxPercent) Else 0 End TaxPercentage, 
--        Case When @SlabType = 3 Then Sum(TaxAmount) Else 0 End TaxAmount,      
--        Case When @SlabType = 3 Then (Max(QPSDtl.SalePrice) + (Max(isNull(QPSDtl.SalePrice,0))*Max(isNull(QPSDtl.TaxPercent,0))/100)) Else 0 End PriceInclTax, 0 BudgetedQty, 0 BudgetedValue    
        0 PriceExclTax, 0 TaxPercentage, 0 TaxAmount, 0 PriceInclTax, 0 BudgetedQty, 0 BudgetedValue    
  From tbl_merp_QPSAbsData QPSAbs
		inner join tbl_merp_QPSDtlData QPSDtl on QPSAbs.SchemeID = QPSDtl.SchemeID And    QPSAbs.PayoutID = QPSDtl.PayoutID And QPSAbs.CustomerID = QPSDtl.CustomerID       
		inner join tbl_merp_SchemeAbstract SchAbs on SchAbs.SchemeID = QPSAbs.SchemeID       
		inner join Customer CM on CM.CustomerID = QPSDtl.CustomerID     
		left outer join tbl_merp_schemeSlabdetail Slabdet    on IsNull(QPSAbs.SlabID,0) = Slabdet.SlabID     
        Where  
        QPSAbs.SchemeID = @SchemeID And     
        QPSAbs.PayoutID = @PayoutID And    
        QPSAbs.GroupID = @GroupID And   
        (IsNull(QPSAbs.SlabID,0) > 0  or IsNull(RebateValue,0) > 0 ) 
        Group by QPSDtl.QPSAbsDataID, SchAbs.ActivityCode, SchAbs.CS_SchemeId, SchAbs.Description, ISNull(Slabdet.SlabType,0),    
        SchAbs.ActiveFrom, SchAbs.ActiveTo, QPSDtl.BillRef, QPSDtl.InvDocRef, CM.CustomerID, CM.Company_name, IsNull(CM.RCSOutletID, ''),
		QPSDtl.Division, QPSDtl.SubCategory, QPSDtl.MarketSKU    
        Order by QPSDtl.QPSAbsDataID, SchAbs.ActivityCode, QPSDtl.Division, QPSDtl.SubCategory, QPSDtl.MarketSKU, QPSDtl.BillRef, CM.CustomerID  
      End    
    Fetch Next from CurSchPayoutGrp into @SchemeID, @PayoutID, @GroupID, @SlabType, @ApplyOn, @ItemGrp    
  End    
  Close CurSchPayoutGrp    
  Deallocate CurSchPayoutGrp    
    
  Select * from #tmpAbsQPSData Order By 1     
  Select * from #tmpDtlQPSData Order By 1     
    
  Drop table #tmpAbsQPSData     
  Drop table #tmpDtlQPSData     
  Drop table #tmpSchPayout    
End
