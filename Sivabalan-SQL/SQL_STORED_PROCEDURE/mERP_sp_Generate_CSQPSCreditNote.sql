Create Procedure mERP_sp_Generate_CSQPSCreditNote(@TransDate DateTime)
As
Begin
Declare @SchemeId int, @PayoutID Int, @GroupID int, @ApplicableOn Int
Declare @SchActiveFrom DateTime, @SchActiveTo DateTime 
Declare @SchPayoutFrom DateTime, @SchPayoutTo DateTime 
Declare @ItemGroup Int 
Declare @ExpiryDate DateTime
Declare @DAY_CLOSE DateTime 
Declare @GRACEDAYS Int

/*To Check Day Close Date*/
Select @DAY_CLOSE = dbo.StripTimeFromDate(IsNull(LastInventoryUpload, 'Jan 01 1900')) From SetUp

/*To Get Grace Period*/
--Set @GRACEDAYS = 0 
--If IsNull((select Flag from tbl_mErp_ConfigAbstract where ScreenCode like N'CLSDAY01'),0) = 1 
--  BEGIN
--    Select @GRACEDAYS = IsNull([Value],0) from tbl_mErp_ConfigDetail where ScreenCode like N'CLSDAY01' and ControlName Like N'GracePeriod'
--  END
	
Declare CurQPSSchemeLst Cursor For 
Select SchAbs.SchemeID, SchPP.ID, dbo.StripTimeFromDate(SchAbs.ActiveFrom), dbo.MakeDayEnd(SchAbs.ActiveTo), dbo.StripTimeFromDate(SchPP.PayoutPeriodFrom), dbo.MakeDayEnd(SchPP.PayoutPeriodTo), 
IsNull(ItemGroup,0), SchOtl.GroupID, ApplicableOn, dbo.MakeDayEnd(DateAdd(Day,DateDiff(d, dbo.StripTimeFromDate(SchAbs.ActiveTo), dbo.StripTimeFromDate(SchAbs.ExpiryDate)), dbo.StripTimeFromDate(SchPP.PayoutPeriodTo)))
From tbl_mERP_SchemeAbstract SchAbs, tbl_mERP_SchemeOutlet SchOtl, tbl_mERP_SchemePayoutPeriod SchPP
Where SchAbs.SchemeID = SchOtl.SchemeID And 
SchAbs.SchemeType in (1,2) And 
SchAbs.SchemeID = SchPP.SchemeID And
((DateAdd(Day, DateDiff(d, dbo.StripTimeFromDate(SchAbs.ActiveTo), dbo.StripTimeFromDate(SchAbs.ExpiryDate)), dbo.StripTimeFromDate(SchPP.PayoutPeriodTo)) < dbo.StripTimeFromDate(@TransDate)) 
        Or	(dbo.StripTimeFromDate(SchPP.PayoutPeriodTo) <= @DAY_CLOSE)) And
--IsNull(SchAbs.CrNoteRaised,0) = 0 And 
SchOtl.QPS = 1 And SchAbs.Active = 1 And 
SchPP.Active = 1 And SchPP.Status & 128= 0 And SchPP.ClaimRFA = 0
Group by SchAbs.SchemeID, SchPP.ID, SchAbs.ActiveFrom, SchAbs.ActiveTo, SchPP.PayoutPeriodFrom, SchPP.PayoutPeriodTo, SchAbs.ApplicableOn, 
SchAbs.ITemGroup, SchOtl.GroupID, (SchPP.PayoutPeriodTo), SchAbs.ExpiryDate

Open CurQPSSchemeLst
Fetch From CurQPSSchemeLst Into  @SchemeId, @PayoutID, @SchActiveFrom, @SchActiveTo, @SchPayoutFrom, @SchPayoutTo, @ItemGroup, @GroupID, @ApplicableOn, @ExpiryDate
While (@@Fetch_Status=0)
Begin
  Set dateformat dmy        
  Declare @bSelCustomers int         
  Declare @IsPer int         
  Declare @Flag int        
  Declare @FromLim decimal(18,6)        
  Declare @ToLim Decimal(18,6)        
  Declare @Discount Decimal(18,6)        
  Declare @PrimaryUOM as Decimal(18,6)  
  Declare @AllAmt Decimal(18,6)        
  Declare @FreeQty Decimal(18,6)        
  Declare @bHasSlabs int        
  Declare @SlabID Int
  Declare @SlabType Int
  Declare @Onward Decimal(18,6)
  Declare @FreeUOM Decimal(18,6)
 --When @ApplicableOn = 1 And @SlabType = 1  ItemBased Amount
 --When @ApplicableOn = 1 And @SlabType = 2  ItemBased Percentage
 --When @ApplicableOn = 1 And @SlabType = 3  ItemBased FreeItem 
 --When @ApplicableOn = 2 And @SlabType = 1  InvoiceBased Amount
 --When @ApplicableOn = 2 And @SlabType = 2  InvoiceBased Percentage
 --When @ApplicableOn = 2 And @SlabType = 3  InvoiceBased FreeItem 
 --When @ApplicableOn = 1 And @SlabType = 1  And @ItemGroup = 2 SplCat ItemBased Amount 
 --When @ApplicableOn = 1 And @SlabType = 2  And @ItemGroup = 2 SplCat ItemBased Percentage
 --When @ApplicableOn = 1 And @SlabType = 3  And @ItemGroup = 2 SplCat ItemBased FreeItem 
 
  Declare @CashDisc_Count INT
  Declare @SKUFree_Count INT
--  Declare @TransDate DateTime 
  Declare @SchemeDesc nVarChar(1100)
  Declare @CustomerID nVarChar(50)
  Declare @ClaimAmount Decimal(18,6)
  Declare @VoucherPrefix nVarchar(10)
  Declare @RFA_Claimable INT
  Declare @EXPACCID INT 
  Declare @DISPLAY_SCHEME_ACC INT 
  Declare @SECONDARY_SCHEME_ACC INT
  DECLARE @PRIMARY_SCHEME_ACC INT
  Declare @CreditNoteID INT
   
  SET @DISPLAY_SCHEME_ACC = 65
  SET @SECONDARY_SCHEME_ACC = 39
  SET @PRIMARY_SCHEME_ACC = 112

  Declare @SchDesc nVarchar(2000)
  Declare @PayoutDate nVarchar(100)
  Declare @t int
  select @PayoutDate = convert(varchar(100), @SchPayoutFrom, 3)
  select @PayoutDate = Substring(@PayoutDate, CharIndex('/',@PayoutDate,1)+1, Len(@PayoutDate))
   
  Select @VoucherPrefix = dbo.GetVoucherPrefix('CREDIT NOTE')
  Select @SchemeDesc = 'QPS-' + CS_RecSchID + N'-' + IsNull(Description,''), 
		 @RFA_Claimable = IsNull(RFAApplicable,0)  From tbl_mERP_SchemeAbstract Where SchemeID = @SchemeID

  Select @SchDesc = isNull(Description, '') from tbl_mERP_SchemeAbstract Where SchemeID = @SchemeID

  
  Create Table #CusTable(CusCode nvarchar(15)  COLLATE SQL_Latin1_General_CP1_CI_AS,
   CusName nvarchar(150)  COLLATE SQL_Latin1_General_CP1_CI_AS,        
   SalesValue Decimal(18,6) Default(0),   DisAmt Decimal (18,6) Default(0),
   AllottedAmount Decimal(18,6) Default(0), Qty Decimal(18,6) Default(0),
   Product_Code nvarchar(100)  COLLATE SQL_Latin1_General_CP1_CI_AS, 
   SlabID Int, TypeFlag Int, ApplyOn Decimal(18,6) Default 0, UOM1Qty Decimal(18,6)  Default 0, UOM2Qty Decimal(18,6)  Default 0)
  
  /* TypeFlag [Cash Discount - 1, SKU Free 2]*/
  Select * into #tmpCustomer from dbo.mERP_fn_Get_CSOutletScope(@SchemeId,1)
  Create table #tmpSchProducts(SchemeID Int, Product_Code nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)


 
  /* ProductScopeID not used*/
  Insert into #tmpSchProducts 
  Select SchemeID, Product_Code from dbo.mERP_fn_Get_CSProductScope_CrNote(@SchemeId) Group By SchemeID, Product_Code

  
  IF (@ApplicableOn = 2 And @ItemGroup = 1)  /* Invoice Based */
  Begin
    Insert into #CusTable(Cuscode, SalesValue)        
    Select InvAb.CustomerID, Sum(NetValue)        
    From InvoiceAbstract InvAb,  #tmpCustomer
    Where InvAb.CustomerId=#tmpCustomer.CustomerCode
    And dbo.StripTimeFromDate(InvAb.Invoicedate) Between @SchActiveFrom And @SchActiveTo       
    And dbo.StripTimeFromDate(InvAb.Invoicedate) Between @SchPayoutFrom And @SchPayoutTo	
	And dbo.StripTimeFromDate(InvAb.CreationTime) Between @SchActiveFrom And @ExpiryDate
    And InvAb.InvoiceType In (1,2,3)        
    And (InvAb.Status & 128)=0          
    And #tmpCustomer.GroupID=@GroupID    
    Group by InvAb.CustomerId


    Declare SchemeDiscount Cursor For        
    Select SlabID, SlabType, SlabStart, SlabEnd, IsNull(Value,0), IsNull(Onward,0), IsNull(FreeUOM,''),IsNull(Volume,0)
    From tbl_mERP_SchemeSlabDetail Schemes Where SchemeId=@SchemeID  And GroupID = @GroupID
    Open SchemeDiscount        
    Fetch next From SchemeDiscount Into @SlabID, @SlabType, @FromLim, @ToLim, @Discount, @Onward, @FreeUOM, @FreeQty
    While(@@fetch_status=0)        
    Begin        
      IF @SlabType=2		/*Percentage */
      Begin        
        Update #Custable Set DisAmt=(Case @Onward When 0 Then @Discount Else ((Cast(SalesValue/@Onward as Int) * @Onward)*(@Discount /100))End),
		AllottedAmount=(Case @Onward When 0 Then (SalesValue * (@Discount /100)) Else ((Cast(SalesValue/@Onward as Int) * @Onward)*(@Discount /100))End),
		TypeFlag = 1, SlabID = @SlabID
        Where SalesValue >=@FromLim And SalesValue <=@Tolim        
      End        
      Else If @SlabType=1	/*Amount*/
      Begin        
        Update #Custable Set DisAmt= (Case @Onward When 0 Then @Discount Else (Cast(SalesValue/@Onward as Int)*@Discount) End),
			AllottedAmount=(Case @Onward When 0 Then @Discount Else (Cast(SalesValue/@Onward as Int)*@Discount)End), 
			TypeFlag = 1, SlabID = @SlabID        
        Where SalesValue >=@FromLim And SalesValue <=@Tolim        
      End        
      Else If @SlabType=3	/*Free Item */
      Begin        
        Update #Custable Set AllottedAmount=AllottedAmount + (Case @Onward When 0 Then @FreeQty Else (Cast(SalesValue/@Onward as Int) * @FreeQty) End),
		TypeFlag = 2, SlabID = @SlabID        
        Where SalesValue >=@FromLim And SalesValue <=@Tolim          
      End
      Fetch next From SchemeDiscount Into @SlabID, @SlabType, @FromLim, @ToLim, @Discount, @Onward, @FreeUOM, @FreeQty
    End        
    Close SchemeDiscount        
    Deallocate SchemeDiscount 


    /*------------------- Invoiced Based Percentage And Amount --------------------
    -- Insert SchemeID,  Customer, SalesVaue  into the SchemeCustomers
    -- Step 1 [Update Sales Value If Customer Already Exists]
    -- Step 2 [Insert New Customers]*/
--    Update SchCust Set SchCust.AllotedAmount = SchCust.AllotedAmount + Cust.AllottedAmount From SchemeCustomers SchCust, #CusTable Cust
--    Where SchCust.CustomerID = Cust.CusCode And SchCust.SchemeID = @SchemeID And IsNull(Cust.TypeFlag,0) = 1
  
--    Update Cust Set AllottedAmount = 0 From SchemeCustomers SchCust, CusTable Cust
--    Where SchCust.CustomerID = Cust.CusCode And IsNull(Cust.TypeFlag,0) = 1 And SchCust.SchemeID = @SchemeID

    /*-------- Transaction Start --------*/
    Begin Tran 
    Insert into SchemeCustomers
    Select  @SchemeID, Cuscode, AllottedAmount,0 From #CusTable 
    Where AllottedAmount > 0 And TypeFlag = 1
 
    Select @CashDisc_Count = @@ROWCOUNT

    /*------------------ Invoice Based Free Item -----------------------
    -- Insert SchemeID, CustomerID, Product_Code, Quantity, Pending into SchemeCustomerItems -- */
    Insert into  SchemeCustomerItems (SchemeId, GroupID, PayoutID, SlabID, CustomerID,Product_code,Quantity,Pending,Claimed)  
    Select @SchemeID, @GroupID, @PayoutID, Cust.SlabID, Cust.CusCode, FreeSKU.SKUCode, 
	Case IsNull(SlabDet.FreeUOM,0) When 1 Then Sum(Cust.AllottedAmount)
     When 2 Then Sum(Cust.AllottedAmount * IsNull(Items.Uom1_Conversion,1))
     When 3 Then Sum(Cust.AllottedAmount * IsNull(Items.Uom2_Conversion,1))
     Else Sum(Cust.AllottedAmount) End as 'Qty', 
    Case IsNull(SlabDet.FreeUOM,0) When 1 Then Sum(Cust.AllottedAmount)
     When 2 Then Sum(Cust.AllottedAmount * IsNull(Items.Uom1_Conversion,1))
     When 3 Then Sum(Cust.AllottedAmount * IsNull(Items.Uom2_Conversion,1))
     Else Sum(Cust.AllottedAmount) End as 'Pending', 0 'Claimed'
    From #CusTable Cust
	inner join tbl_mERP_SchemeFreeSKU FreeSKU on IsNull(Cust.SlabID,0) = FreeSKU.SlabID   
	inner join tbl_mERP_SchemeSlabDetail SlabDet on SlabDet.SlabID = FreeSKU.SlabID  
	right outer join Items on  Items.Product_Code = FreeSKU.SKUCode   
    Where 
    IsNull(Cust.TypeFlag,0) = 2 And Cust.AllottedAmount > 0
    Group By Cust.CusCode, Cust.SlabID, FreeSKU.SKUCode , IsNull(SlabDet.FreeUOM,0)
    Select @SKUFree_Count = @@ROWCOUNT

    --  SlabType = 1 Or SlabType=2  [i. e. Type Flag 2 ]
    IF @CashDisc_Count > 0 
    Begin 
      -- To Insert Credit Note 
      Declare GenCreditNote Cursor For
      Select CusCode, IsNull(AllottedAmount,0) From #CusTable Where IsNull(TypeFlag,0) = 1 And IsNull(AllottedAmount,0) > 0
      Open GenCreditNote
      Fetch From GenCreditNote Into @CustomerID, @ClaimAmount
      While (@@Fetch_Status = 0)
      Begin
        -- Select * from CreditNote
        Exec sp_insert_CreditNote 0, @CustomerID, @ClaimAmount, @TransDate, @SchemeDesc 
        Select @CreditNoteID = @@Identity
        Update CreditNote Set Flag = 1, DocumentReference = @VoucherPrefix + Cast(DocumentID as nVarchar(10)), PayoutID = @PayoutID
		, Memo = 'CR' + Cast(@CreditNoteID as nVarchar(1000)) + '-' + @PayoutDate + '-' + 'QPS' + '-' + @SchDesc
		Where CreditID = @CreditNoteID
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
	
	    Fetch From GenCreditNote Into @CustomerID, @ClaimAmount
      End 
      Close GenCreditNote
      Deallocate GenCreditNote
    End 
    Update tbl_mERP_SchemePayoutPeriod Set Status = Status | 128 Where SchemeID =  @SchemeID and ID = @PayoutID
    Commit Tran
    /*-------- Transaction End --------*/
  End        
  Else IF (@ApplicableOn=1) -- Item Based 
  Begin         
    IF @ItemGroup = 2  /* Spl Category*/
      Insert into #CusTable(Cuscode,SalesValue,Qty, UOM1Qty, UOM2Qty)      
      Select InvAb.CustomerID,
      Sum(InvDet.Amount),   
      Sum(InvDet.Quantity) Qty, 
      Cast(Sum((InvDet.Quantity / IsNull(Itm.UOM1_Conversion,1))) as Decimal (18,6))UOM1Qty, 
      Cast(Sum((InvDet.Quantity / IsNull(Itm.UOM2_Conversion,1))) as Decimal (18,6)) Uom2Qty
      From InvoiceAbstract InvAb, #tmpCustomer CusMas, 
           InvoiceDetail InvDet, #tmpSchProducts SchProducts, Items Itm
      Where InvAb.CustomerId=CusMas.CustomerCode
       And dbo.StripTimeFromDate(InvAb.Invoicedate) Between @SchActiveFrom And @SchActiveTo
	   And dbo.StripTimeFromDate(InvAb.Invoicedate) Between @SchPayoutFrom And @SchPayoutTo
	   And dbo.StripTimeFromDate(InvAb.CreationTime) Between @SchActiveFrom And @ExpiryDate		
       And InvAb.InvoiceId=InvDet.InvoiceId        
       And InvAb.InvoiceType In (1,2,3)        
       And (InvAb.Status & 128)=0          
       And SchProducts.SchemeID=@SchemeID And CusMas.GroupID = @GroupID
       And InvDet.Product_Code=SchProducts.Product_Code
       And Itm.Product_Code = InvDet.Product_Code
       And InvDet.FlagWord =0        
      Group by InvAb.CustomerId

	Else              /* Normal Schemes*/

	
      Insert into #CusTable(Cuscode,SalesValue,Qty,Product_Code)      
      Select InvAb.CustomerID,       
      Sum(InvDet.Amount),        
      Sum(InvDet.Quantity),
      Invdet.Product_Code    
      From InvoiceAbstract InvAb, #tmpCustomer CusMas, InvoiceDetail InvDet, #tmpSchProducts SchProducts
      Where InvAb.CustomerId=CusMas.CustomerCode
       And dbo.StripTimeFromDate(InvAb.Invoicedate) Between @SchActiveFrom And @SchActiveTo
	   And dbo.StripTimeFromDate(InvAb.Invoicedate) Between @SchPayoutFrom And @SchPayoutTo
	   And dbo.StripTimeFromDate(InvAb.CreationTime) Between @SchActiveFrom And @ExpiryDate		
       And InvAb.InvoiceId=InvDet.InvoiceId        
       And InvAb.InvoiceType In (1,2,3)        
       And (InvAb.Status & 128)=0          
       And SchProducts.SchemeID=@SchemeID  And CusMas.GroupID = @GroupID       
       And InvDet.Product_Code=SchProducts.Product_Code        
       And InvDet.FlagWord =0        
      Group by InvAb.CustomerId,Invdet.Product_Code        


    Declare SchemeDiscount Cursor For        
    Select SlabID, SlabType, UOM, SlabStart, SlabEnd, IsNull(Onward,0), IsNull([Value],0), IsNull(FreeUOM,''), IsNull(Volume,0) From tbl_mERP_SchemeSlabDetail
    Where SchemeId=@SchemeID And GroupID = @GroupID       
        
    Open SchemeDiscount        
          
    Fetch next From SchemeDiscount Into @SlabID, @SlabType, @PrimaryUOM, @FromLim, @ToLim, @Onward, @Discount, @FreeUOM, @FreeQty
    While(@@fetch_status=0)        
    Begin        
      /* --------------- Qty OR Value Consideration --------------- */
      IF @ItemGroup = 2 
      Begin  /*----Spl Category ----*/
        IF @PrimaryUOM = 4
          Update #Custable Set ApplyOn = SalesValue
        Else 
          Update #Custable Set ApplyOn = (Case @PrimaryUOM When 1 Then Qty When 2 Then UOM1Qty When 3 Then UOM2Qty End)
      End
      Else   
      Begin  /*----Normal Scheme ----*/
        IF @PrimaryUOM = 4		/*Value*/
          Update #Custable Set ApplyOn = SalesValue
        Else
          Update CT Set CT.ApplyOn = CT.Qty / (Case @PrimaryUOM When 1 Then 1 When 2 Then IsNull(I.Uom1_conversion,1) When 3 Then IsNull(I.Uom2_conversion,1) End)
        From #Custable CT, Items I Where CT.Product_code = I.Product_Code
      End
       
      /* --------------- Checking Falling Slab --------------- */ 
      IF (@SlabType=2)     /*--Percentage--*/
      Begin        
        Update #Custable Set DisAmt=(Case @Onward When 0 Then @Discount Else ((Cast(SalesValue/@Onward as Int) * @Onward)*(@Discount /100)) End), 
	     AllottedAmount=(Case @Onward When 0 Then (SalesValue * (@Discount /100)) Else ((Cast(SalesValue/@Onward as Int) * @Onward)*(@Discount /100))End), 
         TypeFlag = 1, SlabID = @SlabID 
        Where ApplyOn >= @FromLim And ApplyOn <= @Tolim  
      End        
      Else IF (@SlabType=1)  /*-- Amount --*/       
      Begin 
        Update #Custable Set DisAmt= (Case @Onward When 0 Then @Discount Else ((Cast(ApplyON/@Onward as Int))*@Discount) End),
	AllottedAmount=(Case @Onward When 0 Then @Discount Else ((Cast(ApplyON/@Onward as Int))*@Discount) End), 
	TypeFlag = 1, SlabID = @SlabID
	Where ApplyOn >= @FromLim And ApplyOn <= @Tolim
      End        
      Else IF (@SlabType=3)  /*-- Item Free --*/
      Begin        
        IF @ItemGroup = 2 
        Begin  /*----Spl Category ----*/
          Update #Custable Set AllottedAmount=IsNull(AllottedAmount,0) + Case @Onward When 0 Then @FreeQty 
                                    Else  Cast((ApplyOn/@onward) as Int) * @FreeQty End, 
  	      TypeFlag = 2, SlabID = @SlabID
          Where ApplyOn >= @FromLim And ApplyOn <= @Tolim
        End
        Else
        Begin /*----Normal Scheme----*/
          Update #Custable Set AllottedAmount=IsNull(AllottedAmount,0) + Case @Onward When 0 Then @FreeQty 
                                      Else  Cast(((Case @PrimaryUOM When 1 Then Qty
                                            When 2 Then (Qty / (Select IsNull(Uom1_conversion,1) From Items Where Items.Product_code = #Custable.Product_code))     
                                            When 3 Then (Qty / (Select IsNull(Uom2_conversion,1) From Items Where Items.Product_code = #Custable.Product_code)) 
											When 4 Then ApplyOn End)/@onward) as Int) * @FreeQty End, 
  		  TypeFlag = 2, SlabID = @SlabID
          Where ApplyOn >= @FromLim And ApplyOn <= @Tolim
        End 
      End        

    Fetch next From SchemeDiscount Into @SlabID, @SlabType, @PrimaryUOM, @FromLim, @ToLim, @Onward, @Discount, @FreeUOM, @FreeQty
    End        
    Close SchemeDiscount        
    Deallocate SchemeDiscount        


    /* -------------- Item Based Percentage / Amount -------------------
    -- Insert SchemeID,  Customer, SalesVaue  into the SchemeCustomer
    -- Step 1 [Update Sales Value If Customer Already Exists] 
    -- Step 2 [Update the CusTable Alloted Amount  for Which Already Updated  in Step 1]
    -- Step 3 [Insert New Customers] */
    Update SchCust Set SchCust.AllotedAmount = SchCust.AllotedAmount + Cust.AllottedAmount From SchemeCustomers SchCust, #CusTable Cust
    Where SchCust.CustomerID = Cust.CusCode And SchCust.SchemeID = @SchemeID And IsNull(Cust.TypeFlag,0) = 1
   
--    Update Cust Set AllottedAmount = 0 From SchemeCustomers SchCust, CusTable Cust
--    Where SchCust.CustomerID = Cust.CusCode And IsNull(Cust.TypeFlag,0) = 1 And SchCust.SchemeID = @SchemeID
	
    /*-------- Transaction Start --------*/
    Begin Tran 
    Insert into SchemeCustomers
    Select  @SchemeID, Cuscode, AllottedAmount,0 From #CusTable 
    Where AllottedAmount > 0 And TypeFlag = 1 
    SELECT @CashDisc_Count = @@ROWCOUNT


    /*--------------------- Item Based Free Item -------------------------
    -- Insert SchemeID, CustomerID, Product_Code, Quantity, Pending into SchemeCustomerItems */
    Insert into  SchemeCustomerItems (SchemeId, GroupID, PayoutID, SlabID, CustomerID, Product_code, Quantity, Pending, Claimed)  
    Select @SchemeID, @GroupID, @PayoutID, Cust.SlabID,  Cust.CusCode, FreeSKU.SKUCode, 
    Case IsNull(SlabDet.FreeUOM,0) When 1 Then Sum(Cust.AllottedAmount)
     When 2 Then Sum(Cust.AllottedAmount * IsNull(Items.Uom1_Conversion,1))
     When 3 Then Sum(Cust.AllottedAmount * IsNull(Items.Uom2_Conversion,1))
     Else Sum(Cust.AllottedAmount) End as 'Qty', 
    Case IsNull(SlabDet.FreeUOM,0) When 1 Then Sum(Cust.AllottedAmount)
     When 2 Then Sum(Cust.AllottedAmount * IsNull(Items.Uom1_Conversion,1))
     When 3 Then Sum(Cust.AllottedAmount * IsNull(Items.Uom2_Conversion,1))
     Else Sum(Cust.AllottedAmount) End as 'Pending', 0 'Claimed'
    From #CusTable Cust
	inner join  tbl_mERP_SchemeFreeSKU FreeSKU on IsNull(Cust.SlabID,0) = FreeSKU.SlabID   
	inner join tbl_mERP_SchemeSlabDetail SlabDet on  SlabDet.SlabID = FreeSKU.SlabID   
	right outer join Items on  Items.Product_Code = FreeSKU.SKUCode   
    Where 
     IsNull(Cust.TypeFlag,0) = 2 And IsNull(Cust.AllottedAmount,0) > 0
    Group By Cust.CusCode, Cust.SlabID, FreeSKU.SKUCode, IsNull(SlabDet.FreeUOM,0)
    Select @SKUFree_Count = @@ROWCOUNT

    If @CashDisc_Count > 0 
    Begin
      -- To Insert Credit Note 
      Declare GenItemCreditNote Cursor For
      Select CusCode, IsNull(AllottedAmount,0) From #CusTable Where IsNull(TypeFlag,0) = 1 And IsNull(AllottedAmount,0) > 0
      Open GenItemCreditNote
      Fetch From GenItemCreditNote Into @CustomerID, @ClaimAmount
      While (@@Fetch_Status = 0)
        Begin
        Exec sp_insert_CreditNote 0, @CustomerID, @ClaimAmount, @TransDate, @SchemeDesc 
        Select @CreditNoteID = @@Identity
        Update CreditNote Set Flag = 1, DocumentReference = @VoucherPrefix + Cast(DocumentID as nVarchar(10)), PayoutID = @PayoutID 
		, Memo = 'CR' + Cast(@CreditNoteID as nVarchar(1000)) + '-' + @PayoutDate + '-' + 'QPS' + '-' + @SchDesc
		Where CreditID = @CreditNoteID
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
	
	    Fetch From GenItemCreditNote Into @CustomerID, @ClaimAmount
      End 
      Close GenItemCreditNote
      Deallocate GenItemCreditNote
    End
    Update tbl_mERP_SchemePayoutPeriod Set Status = Status | 128 Where SchemeID =  @SchemeID and ID = @PayoutID
    Commit Tran 
    /*-------- Transaction End --------*/
  End
 
  Drop table #tmpCustomer
  Drop Table #tmpSchProducts
  Drop table #CusTable 
  Fetch From CurQPSSchemeLst Into @SchemeId, @PayoutID, @SchActiveFrom, @SchActiveTo, @SchPayoutFrom, @SchPayoutTo, @ItemGroup, @GroupID, @ApplicableOn, @ExpiryDate
End 
Close CurQPSSchemeLst
Deallocate CurQPSSchemeLst
End

