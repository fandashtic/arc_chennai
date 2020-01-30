
Create Procedure mERP_sp_RFADATA_GetRebateValue(@SchID Int, @PayoutID Int, @SchemeType NVarchar(255), @SchemeStatus NVarchar(255) = 'All')
as
Begin
	Declare @ItemGroup Int 
	Declare @SchIDPattern1 nVarchar(25)
	Declare @SchIDPattern2 nVarchar(25)
	Declare @SchIDPattern3 nVarchar(25)
	Declare @SchIDPattern4 nVarchar(25)
    Declare @ActivityCode nVarchar(510)
    Declare @PayoutFromDate DateTime, @PayoutToDate Datetime
    Declare @QPS Int
    Declare @ApplicableOn Int 
    Declare @TaxConfigCrdtNote Int, @TaxConfigItemFree int, @TaxConfigFlag int 
    Declare @QPSFreeQty Decimal(18,6)
	Declare @IsRFASubmitted Int 
    Declare @SchActiveToDate DateTime 
	Declare @SchExpiryDate DateTime
	Declare @SchExpiryGraceDays int
    Set @QPS = 0
	Set Dateformat DMY 

	Set @SchIDPattern1 = Cast(@SchID as nVarchar(25))
	Set @SchIDPattern2 = Cast(@SchID as nVarchar(25)) + ',%' 
	Set @SchIDPattern3 = '%,'+Cast(@SchID as nVarchar(25))+ ',%' 
	Set @SchIDPattern4 = '%,' + Cast(@SchID as nVarchar(25))

	Select @ItemGroup = ItemGroup, @ActivityCode = ActivityCode, @ApplicableOn = ApplicableOn, @SchActiveToDate = ActiveTo, @SchExpiryDate = ExpiryDate From tbl_merp_SchemeAbstract Where SchemeID = @SchID And active = 1 
    Select @PayoutFromDate = PayoutPeriodFrom, @PayoutToDate= PayoutPeriodTo, @IsRFASubmitted = ClaimRFA from tbl_merp_SchemePayoutPeriod Where ID = @PayoutID 
    Select @QPS = IsNull(QPS,0) From tbl_mERP_SchemeOutlet Where SchemeID = @SchID And IsNull(QPS,0) = 1 Group By IsNull(QPS,0)

	If DateDiff(Day, @SchActiveToDate, @SchExpiryDate) > 0 
		Set @SchExpiryGraceDays =  DateDiff(Day, @SchActiveToDate, @SchExpiryDate)
    Else
		Set @SchExpiryGraceDays = 0 
    

    If @IsRFASubmitted = 1 
    Begin
      Select @TaxConfigFlag = TaxConfig From tbl_mERP_RFAAbstract Where Status & 5 <> 5 and DocumentID = @SchID And PayoutFrom = @PayoutFromDate And PayoutTo = @PayoutToDate Group By TaxConfig
    End
    Else
    Begin 
	  Select @TaxConfigItemFree = IsNull(Flag, 0) From tbl_merp_ConfigAbstract Where ScreenCode = 'RFA01'
	  Select @TaxConfigCrdtNote = IsNull(Flag, 0) From tbl_merp_ConfigAbstract Where ScreenCode = 'RFA02'
    End

    Create table #RFAEntry(
	RFAID nVarchar(25) Collate SQL_Latin1_General_CP1_CI_AS,
	RFAType nVarchar(25) Collate SQL_Latin1_General_CP1_CI_AS,
	InvoiceID Int, InvoiceType Int, Serial int,
	RebateQty Decimal(18,6),
	RebateValue Decimal(18,6),
	RFAStatus nVarchar(25) Collate SQL_Latin1_General_CP1_CI_AS,
	XMLName nVarchar(550) Collate SQL_Latin1_General_CP1_CI_AS Default Null,
	SubmittedDate DateTime,
	XMLID Int,
	XMLStatus nVarchar(25) Collate SQL_Latin1_General_CP1_CI_AS,
	AckDate DateTime,
	CRNoteGenerated nVarchar(25) Collate SQL_Latin1_General_CP1_CI_AS Default 'No',
	BudgetAlocated nVarchar(25) Collate SQL_Latin1_General_CP1_CI_AS Default 'No',
	BudgetValue Decimal(18,6),
	PoinstRedeemed nVarchar(25) Collate SQL_Latin1_General_CP1_CI_AS Default 'No',
	TotalPoints Decimal(18,6),
	RedeemedPoints Decimal(18,6),
	RedeemValue Decimal(18,6),
	AmountSpent Decimal(18,6))

    /*To avoid split batch error*/
    Select InvDt.InvoiceID, InvDT.Product_Code, InvDt.Serial, IsNull(InvDt.Flagword,0) Flagword,  MultipleSchemeID, MultipleSplCatSchemeID, Sum(InvDt.Quantity)  Quantity,
                  IsNull(InvDt.MultipleSchemeDetails, '') MultipleSchemeDetails, IsNull(InvDt.MultipleSplCategorySchDetail, '') MultipleSplCategorySchDetail
	into #tmpInvDetail 
    From InvoiceDetail InvDt, InvoiceAbstract InvAb
	Where InvAb.InvoiceID = InvDt.InvoiceID 
        And InvAb.InvoiceType In (1,3,4)
        And (InvAb.Status & 128) = 0  
        And (Case InvAb.InvoiceType When 3 Then (Select dbo.StripTimeFromDate(Min(I.InvoiceDate)) From InvoiceAbstract I Where I.DocumentID = InvAb.DocumentID
                                                 And I.InvoiceType = 1 And isnull(I.CancelDate,'') <> '' and I.CustomerID = InvAb.CustomerID) 
        Else dbo.StriptimeFromDate(InvAb.InvoiceDate) End) Between @PayoutFromDate and DATEADD(day, @SchExpiryGraceDays, @PayoutToDate)
    Group By InvDt.InvoiceID, InvDT.Product_Code, IsNull(InvDt.Flagword,0), InvDt.Serial, MultipleSchemeID, MultipleSplCatSchemeID, IsNull(InvDt.MultipleSchemeDetails, ''), IsNull(InvDt.MultipleSplCategorySchDetail, '') 
If @SchemeType = 'Trade Scheme'
Begin
	Declare @SchType  int 
	Declare Cur_FreeType Cursor For
	Select Distinct SlabType From tbl_merp_SchemeSlabDetail Where SchemeID = @SchID
	Open Cur_FreeType
	Fetch Next From Cur_FreeType into @SchType 
	While @@Fetch_status = 0
	Begin
	  IF @SchType = 3 /*ITEM FREE*/
	  Begin 
		If @IsRFASubmitted = 0 
		Begin
           Set @TaxConfigFlag = @TaxConfigItemFree 
		End
		Insert into #RFAEntry(RFAType, InvoiceID, InvoiceType, Serial, RebateQty, RebateValue) 
		Select Distinct 'Invoice', IA.InvoiceID, IA.InvoiceType, ID.Serial, ID.Quantity, ID.Quantity * dbo.mERP_fn_GetMarginPTR(ID.Product_Code, IA.InvoiceID, @SchID) 
		  from InvoiceAbstract IA, #tmpInvDetail ID
		  Where IA.InvoiceID = ID.InvoiceID and ID.FlagWord = 1 and 
		  IA.Status & 128 = 0 And IA.InvoiceType in (1,3) and dbo.StriptimeFromDate(IA.InvoiceDate) Between @PayoutFromDate and DATEADD(day, @SchExpiryGraceDays, @PayoutToDate)
		  and (Case @ItemGroup When 1 Then MultipleSchemeID Else MultipleSplCatSchemeID End) Like  Cast(@SchID as nVarchar(10))
		  and (Case @ItemGroup When 1 Then ID.MultipleSchemeDetails Else ID.MultipleSplCategorySchdetail End) <> ''
		Union
		Select Distinct 'Invoice', IA.InvoiceID, IA.InvoiceType, ID.Serial, 0, 
		  -1 * cast(dbo.mERP_fn_RFADATA_GetSchItemVal(@SchID, (dbo.fn_Get_ItemSchemeDetail_SR(IA.InvoiceID, @SchID, ID.Product_Code, @TaxConfigFlag, ID.Serial)),3) as Decimal(18,6))
		  from InvoiceAbstract IA, #tmpInvDetail ID
		  Where IA.InvoiceID = ID.InvoiceID and 
		  IA.Status & 128 = 0 And IA.InvoiceType = 4 and dbo.StriptimeFromDate(IA.InvoiceDate) Between @PayoutFromDate and DATEADD(day, @SchExpiryGraceDays, @PayoutToDate)
		  and  cast(dbo.mERP_fn_RFADATA_GetSchItemVal(@SchID, (Case @ItemGroup When 1 Then ID.MultipleSchemeDetails Else ID.MultipleSplCategorySchDetail End),1) as Int) = @SchID
		  and (Case @ItemGroup When 1 Then ID.MultipleSchemeDetails Else ID.MultipleSplCategorySchdetail End) <> ''

		Insert into #RFAEntry (RFAType, InvoiceID, InvoiceType, Serial, RebateQty, RebateValue)
		Select 'Day Close', InvoiceID, InvoiceType, 1, Sum(RebateQty) RFAQty, Case @TaxConfigFlag When 1 Then Sum(RebateValue_Tax) Else Sum(RebateValue) End from tbl_merp_NonQPSData 
		Where SchemeID = @SchID And dbo.StriptimeFromDate(OriginalInvDate) Between @PayoutFromDate and @PayoutToDate And [Type] in (1 ,2)
		Group By InvoiceID,InvoiceType

		Insert into #RFAEntry (RFAType, InvoiceID, InvoiceType, Serial, RebateQty, RebateValue)
		Select 'Submitted',RFADocID, 0 ,1, Sum(RebateQty) RFAQty, Sum(RebateValue) RFAVAlue 
        From tbl_merp_RFAAbstract 
		Where ActivityCode like @ActivityCode and PayoutFrom >= @PayoutFromDate and PayoutTo <=@PayoutToDate and Status & 5 <> 5
        Group By RFADocID
	  End
	  ELSE /*Amount OR Percentage*/
	  Begin
	    If @IsRFASubmitted = 0 
		Begin
           Set @TaxConfigFlag = @TaxConfigCrdtNote 
		End
		IF @ApplicableOn = 2 
        Begin
          Insert into #RFAEntry (RFAType, InvoiceID, InvoiceType, Serial, RebateQty, RebateValue) 
   		  Select 'Invoice', InvoiceID, InvoiceType, 1, 0, 
             Sum((Case InvoiceType When 4 Then -1 Else 1 End) * Cast(dbo.mERP_fn_RFADATA_GetSchItemVal(@SchID, MultipleSchemeDetails,3) as Decimal(18,6)))
   		  from InvoiceAbstract Where Status & 128 = 0 
   		     and dbo.StriptimeFromDate(InvoiceDate) Between @PayoutFromDate and DATEADD(day, @SchExpiryGraceDays, @PayoutToDate)
   		     and (Replace(InvoiceSchemeID,' ','') Like @SchIDPattern1 OR Replace(InvoiceSchemeID,' ','') Like @SchIDPattern2 OR
   		     Replace(InvoiceSchemeID,' ','') Like @SchIDPattern3 OR Replace(InvoiceSchemeID,' ','') Like @SchIDPattern4)
          Group By InvoiceID, InvoiceType
        End
        Else
        Begin
  		  Insert into #RFAEntry (RFAType, InvoiceID, InvoiceType, Serial, RebateQty, RebateValue) 
		  Select Distinct 'Invoice', IA.InvoiceID, IA.InvoiceType, ID.Serial,0, Cast(dbo.mERP_fn_RFADATA_GetSchItemVal(@SchID, (Case @ItemGroup When 1 Then ID.MultipleSchemeDetails Else ID.MultipleSplCategorySchDetail End),3) as Decimal(18,6))
		  from InvoiceAbstract IA, InvoiceDetail ID
		  Where IA.InvoiceID = ID.InvoiceID and 
		  IA.Status & 128 = 0 And IA.InvoiceType in (1,3) and dbo.StriptimeFromDate(IA.InvoiceDate) Between @PayoutFromDate and DATEADD(day, @SchExpiryGraceDays, @PayoutToDate)
		  and  (Replace((Case @ItemGroup When 1 Then MultipleSchemeID Else MultipleSplCatSchemeID  End),' ','') Like @SchIDPattern1 OR
			   Replace((Case @ItemGroup When 1 Then MultipleSchemeID Else MultipleSplCatSchemeID  End),' ','') Like @SchIDPattern2 OR
			   Replace((Case @ItemGroup When 1 Then MultipleSchemeID Else MultipleSplCatSchemeID  End),' ','') Like @SchIDPattern3 OR
			   Replace((Case @ItemGroup When 1 Then MultipleSchemeID Else MultipleSplCatSchemeID  End),' ','') Like @SchIDPattern4 )
		  Union
		  Select Distinct 'Invoice', IA.InvoiceID, IA.InvoiceType, ID.Serial,0, -1 * Cast(dbo.mERP_fn_RFADATA_GetSchItemVal(@SchID, (Case @ItemGroup When 1 Then ID.MultipleSchemeDetails Else ID.MultipleSplCategorySchDetail End),3) as Decimal(18,6))
		  from InvoiceAbstract IA, InvoiceDetail ID
		  Where IA.InvoiceID = ID.InvoiceID and 
			IA.Status & 128 = 0 And IA.InvoiceType  = 4 and dbo.StriptimeFromDate(IA.InvoiceDate) Between @PayoutFromDate and DATEADD(day, @SchExpiryGraceDays, @PayoutToDate)  
			and  cast(dbo.mERP_fn_RFADATA_GetSchItemVal(@SchID, (Case @ItemGroup When 1 Then ID.MultipleSchemeDetails Else ID.MultipleSplCategorySchDetail End),1) as Int) = @SchID
		End
   
		Insert into #RFAEntry (RFAType, InvoiceID, InvoiceType, Serial, RebateQty, RebateValue) 
		Select 'Day Close', InvoiceID, InvoiceType, 1, 0, Case @TaxConfigFlag When 1 Then Sum(RebateValue_Tax) Else Sum(RebateValue) End from tbl_merp_NonQPSData 
		Where SchemeID = @SchID And dbo.StriptimeFromDate(OriginalInvDate) Between @PayoutFromDate and @PayoutToDate
		Group By InvoiceID,InvoiceType

		Insert into #RFAEntry (RFAID,RFAType, InvoiceID, InvoiceType, Serial, RebateQty, RebateValue)
		Select RFAID,'Submitted',RFADocID,0,1,0, Sum(RebateValue) RFAVAlue 
        From tbl_merp_RFAAbstract 
		Where ActivityCode like @ActivityCode and PayoutFrom = @PayoutFromDate and PayoutTo =@PayoutToDate and Status & 5 <> 5
        Group By RFAID,RFADocID
      End
	  Fetch Next From Cur_FreeType into @SchType 
	End
	Close Cur_FreeType 
	Deallocate Cur_FreeType

    IF @IsRFASubmitted = 1 
    Begin
      Update tmpRFA Set tmpRFA.RFAStatus = Case IsNull(RFA.Status,-1) When 0 Then 'RFA Submitted' When 1 Then 'XML Generated' When 5 Then 'Invalid RFA' When -1 Then 'XML Missing' End, 
             tmpRFA.XMLstatus = Case IsNull(XMLD.Status,-1) When 0 Then 'Ready To Upload' When 128 Then 'Upload to Central' When 129 Then 'Ack Received' When -1 Then 'XML Missing' End
			 ,tmpRFA.RFAID = cast(('RFA' + cast(RFA.RFADocID as Nvarchar)) as Nvarchar),tmpRFA.XMLName = XMLD.XMLDocName,tmpRFA.SubmittedDate = Convert(Nvarchar(10),RFA.SubmissionDate,103) ,tmpRFA.AckDate = Convert(Nvarchar(10),XMLD.AcknowledgeDate,103),tmpRFA.XMLID = XMLD.ID
      From tbl_merp_RFAAbstract RFA
	 Left Outer Join tbl_merp_RFAXMLStatus XMLD On RFA.RFADocID = Cast(Substring(XMLD.RFAID,4,Len(XMLD.RFAID)) as Int)
	 Inner Join  #RFAEntry tmpRFA On RFA.RFADocID = tmpRFA.InvoiceID 
      Where  RFAType = 'Submitted' --and RFA.Status & 5 <> 5 
    End

--Select * from #RFAEntry
    IF @QPS = 1 
    Begin
        If @IsRFASubmitted = 0 
        Begin
        Set @TaxConfigFlag = Case @SchType When 3 Then @TaxConfigItemFree Else @TaxConfigCrdtNote End	
        End
		If  @SchType = 3  /*Insert Free Item adjusted in Invoice for QPS Scheme start */
		  Begin
		  Insert into #RFAEntry(RFAType, InvoiceID, InvoiceType, Serial, RebateQty, RebateValue) 
		  Select 'QPS Value', InvoiceID, InvoiceType, 1, Sum(RebateQty), Sum(RebateValue)
		  From (
			  Select SCI.SchemeID, SCI.PayoutID, IA.InvoiceID, SCI.Product_Code, Sum(SCI.Quantity) RebateQty,
			  Sum(SCI.Quantity) * (dbo.mERP_fn_GetMarginPTR(SCI.Product_Code,Cast(IA.InvoiceID as Int), @SchID)+ (Case @TaxConfigFlag When 1 Then (dbo.mERP_fn_GetMarginPTR(SCI.Product_Code,Cast(IA.InvoiceID as Int), @SchID) * Max(TaxCode)/100) Else 0 End)) RebateValue,
			   IA.InvoiceType
			  From InvoiceAbstract IA, InvoiceDetail ID, SchemeCustomerItems SCI
			  Where IA.InvoiceID = ID.InvoiceID
					And IA.InvoiceID = Cast(SCI.InvoiceRef as Int)
					And IA.CustomerID = SCI.CustomerID
					And ID.SchemeID = SCI.SchemeID
					And ID.Product_Code = SCI.Product_Code
					And IsNull(ID.Flagword, 0) = 1
					And SCI.SchemeID = @SchID 
					And SCI.PayoutID = @PayoutID
					And SCI.IsInvoiced = 1
					And SCI.Claimed = 1
			  Group By SCI.SchemeID, SCI.PayoutID, IA.InvoiceID, SCI.Product_Code, IA.InvoiceType
			  Union
			  Select SCI.SchemeID, SCI.PayoutID, IA.InvoiceID, SCI.Product_Code, Sum(SCI.Quantity) RebateQty,
					Sum(SCI.Quantity) * (dbo.mERP_fn_GetMarginPTR(SCI.Product_Code,Cast(IA.InvoiceID as Int), @SchID)+ (Case @TaxConfigFlag When 1 Then (dbo.mERP_fn_GetMarginPTR(SCI.Product_Code,Cast(IA.InvoiceID as Int), @SchID) * Max(TaxCode)/100) Else 0 End)) RebateValue,
					IA.InvoiceType
			  From InvoiceAbstract IA, InvoiceDetail ID, SchemeCustomerItems SCI
			  Where IA.InvoiceID = ID.InvoiceID
				And IA.InvoiceID = Cast(SCI.InvoiceRef as Int)
				And IA.CustomerID = SCI.CustomerID
				And ID.SchemeID = SCI.SchemeID
				And ID.Product_Code = SCI.Product_Code
				And IsNull(ID.Flagword, 0) = 1
				And SCI.SchemeID = @SchID 
				And SCI.PayoutID = @PayoutID
				And SCI.IsInvoiced = 0
				And SCI.Claimed = 0
				Group By SCI.SchemeID, SCI.PayoutID, IA.InvoiceID, SCI.Product_Code, IA.InvoiceType
			)A
		  Group by InvoiceID, InvoiceType
		  End
		  Else 
		  Begin
			Insert into #RFAEntry(RFAType, InvoiceID, InvoiceType, Serial, RebateQty, RebateValue) 
			Select 'QPS Value',1,1,1, Sum(IsNull(Quantity,0)), (case @TaxConfigFlag When 1 Then Sum(IsNull(Rebate_Val,0)) Else Sum(IsNull(RFARebate_Val,0)) End) 
			From tbl_mERP_QPSDtlData Where SchemeID = @SchID And PayoutID = @PayoutID
			And (isNull(Rebate_Qty,0) > 0 Or isNull(Rebate_Val,0) > 0 Or IsNull(RFARebate_Val,0) > 0)
			Group By SchemeID,PayoutID,Division
		  End

--      Select RFAType, Sum(RebateQty) RFAQty, Sum(RebateValue) RFAVAlue From #RFAEntry Group By RFAType
        Select RFAType, Sum(RebateQty) RFAQty,  Sum(RebateValue) RFAVAlue,RFAID, IsNull(XMLName,'') XMLName, SubmittedDate, IsNull(XMLStatus,'') XMLStatus,AckDate ,XMLID
         From #RFAEntry Group By RFAID,RFAType, IsNull(XMLName,''), IsNull(XMLStatus,'') ,SubmittedDate,AckDate,XMLID
    End
    Else
    Begin
      Select RFAType, Sum(RebateQty) RFAQty,  Sum(RebateValue) RFAVAlue,RFAID, IsNull(XMLName,'') XMLName, SubmittedDate, IsNull(XMLStatus,'') XMLStatus,AckDate ,XMLID
      From #RFAEntry Group By RFAID,RFAType, IsNull(XMLName,''), IsNull(XMLStatus,'') ,SubmittedDate,AckDate,XMLID
    End 
End
Else If @SchemeType = 'Display Scheme'
Begin
    IF @IsRFASubmitted = 1 
    Begin
		set dateformat dmy
		Insert into #RFAEntry (InvoiceID,BudgetValue,RebateValue)
		Select RFADocID,Sum(Isnull(BudgetedValue,0)),Sum(Isnull(RebateValue,0)) RFAVAlue 
		From tbl_merp_RFAAbstract 
		Where ActivityCode like @ActivityCode and PayoutFrom >= @PayoutFromDate and PayoutTo <=@PayoutToDate and Status & 5 <> 5
		Group By RFAID,RFADocID

		Update tmpRFA Set tmpRFA.CRNoteGenerated = 'Yes',tmpRFA.BudgetAlocated = 'Yes',tmpRFA.RFAType = 'Submitted', tmpRFA.RFAStatus = Case IsNull(RFA.Status,-1) When 0 Then 'RFA Submitted' When 1 Then 'XML Generated' When 5 Then 'Invalid RFA' When -1 Then 'XML Missing' End, 
			 tmpRFA.XMLstatus = Case IsNull(XMLD.Status,-1) When 0 Then 'Ready To Upload' When 128 Then 'Upload to Central' When 129 Then 'Ack Received' When -1 Then 'XML Missing' End
			 ,tmpRFA.RFAID = cast(('RFA' + cast(RFA.RFADocID as Nvarchar)) as Nvarchar),tmpRFA.XMLName = XMLD.XMLDocName,tmpRFA.SubmittedDate = Convert(Nvarchar(10),RFA.SubmissionDate,103) ,tmpRFA.AckDate = Convert(Nvarchar(10),XMLD.AcknowledgeDate,103),tmpRFA.XMLID = XMLD.ID
		From tbl_merp_RFAAbstract RFA
		Left Outer Join tbl_merp_RFAXMLStatus XMLD On RFA.RFADocID = Cast(Substring(XMLD.RFAID,4,Len(XMLD.RFAID)) as Int)
		Inner Join #RFAEntry tmpRFA On RFA.RFADocID = tmpRFA.InvoiceID
		--and RFA.Status & 5 <> 5 
    End
	Else if @IsRFASubmitted = 0
    Begin
		If Exists(select * from tbl_mERP_DispSchBudgetPayout Where payoutperiodid  = @PayoutID)
		Begin
			If (select Distinct Isnull(CRNoteRaised,0) From tbl_mERP_DispSchBudgetPayout Where payoutperiodid  = @PayoutID) = 0
			Begin
				Insert Into #RFAEntry (BudgetAlocated,RFAType,RebateValue) Values('Yes','Pending',0)
				Update #RFAEntry Set BudgetValue = (select Sum(Isnull(AllocatedAmount,0)) from tbl_mERP_DispSchBudgetPayout Where payoutperiodid  = @PayoutID)
			End
			Else If (select Distinct Isnull(CRNoteRaised,0) From tbl_mERP_DispSchBudgetPayout Where payoutperiodid  = @PayoutID) > 0
			Begin
				Insert Into #RFAEntry (BudgetAlocated,RFAType,RebateValue,CRNoteGenerated ) Values('Yes','Pending',0,'Yes')
				Update #RFAEntry Set BudgetValue = (select Sum(Isnull(AllocatedAmount,0)) from tbl_mERP_DispSchBudgetPayout Where payoutperiodid  = @PayoutID)
				Update #RFAEntry Set RebateValue = (select Sum(Isnull(AllocatedAmount,0) - Isnull(PendingAmount,0)) from tbl_mERP_DispSchBudgetPayout Where payoutperiodid  = @PayoutID)
			End

		End     
    End

      Select RFAType,BudgetAlocated, CRNoteGenerated,   Sum(BudgetValue) BudgetValue,Sum(RebateValue) RFAVAlue, RFAID, IsNull(XMLName,'') XMLName, SubmittedDate, IsNull(XMLStatus,'') XMLStatus,AckDate ,XMLID
      From #RFAEntry Group By RFAID,RFAType, IsNull(XMLName,''), IsNull(XMLStatus,'') ,SubmittedDate,AckDate,XMLID,BudgetAlocated, CRNoteGenerated

End

Else If @SchemeType = 'Point Scheme'
Begin
    IF @IsRFASubmitted = 1 
    Begin	
		set dateformat dmy
		Insert into #RFAEntry (InvoiceID,RebateQty,RebateValue)
		Select Isnull(RFADocID,Null),0,Isnull(Sum(RebateValue),0) RFAVAlue 
		From tbl_merp_RFAAbstract 
		Where ActivityCode like @ActivityCode and PayoutFrom >= @PayoutFromDate and PayoutTo <=@PayoutToDate and Status & 5 <> 5
		Group By RFADocID

		Update T Set T.RFAType = 'Submitted', T.PoinstRedeemed = 'Yes' ,
		T.TotalPoints= Isnull(T1.TotalPoints,0), T.RedeemValue =  (Isnull(T1.RedeemValue,0)) ,
		T.RedeemedPoints =  (Isnull(T1.RedeemedPoints,0)),T.AmountSpent = (Isnull(T1.AmountSpent,0)) 
		From (select PayoutID,Sum(Isnull(TotalPoints,0)) TotalPoints, Sum(Isnull(RedeemValue,0)) RedeemValue,Sum(Isnull(RedeemedPoints,0)) RedeemedPoints,Sum(Isnull(AmountSpent,0)) AmountSpent 
		From tbl_mERP_CSRedemption Where PayoutID = @PayoutID
		Group By PayoutID) T1, #RFAEntry T Where T1.PayoutID = @PayoutID

		Update tmpRFA Set tmpRFA.RFAStatus = Case IsNull(RFA.Status,-1) When 0 Then 'RFA Submitted' When 1 Then 'XML Generated' When 5 Then 'Invalid RFA' When -1 Then 'XML Missing' End, 
		tmpRFA.XMLstatus = Case IsNull(XMLD.Status,-1) When 0 Then 'Ready To Upload' When 128 Then 'Upload to Central' When 129 Then 'Ack Received' When -1 Then 'XML Not Generated' End
		,tmpRFA.RFAID = cast(('RFA' + cast(RFA.RFADocID as Nvarchar)) as Nvarchar),tmpRFA.XMLName = XMLD.XMLDocName,tmpRFA.SubmittedDate = Convert(Nvarchar(10),RFA.SubmissionDate,103) ,tmpRFA.AckDate = Convert(Nvarchar(10),XMLD.AcknowledgeDate,103),tmpRFA.XMLID = XMLD.ID
		From tbl_merp_RFAAbstract RFA
		Left Outer Join  tbl_merp_RFAXMLStatus XMLD On RFA.RFADocID = Cast(Substring(XMLD.RFAID,4,Len(XMLD.RFAID)) as Int)
		Inner Join  #RFAEntry tmpRFA On RFA.RFADocID = tmpRFA.InvoiceID
		--and RFA.Status & 5 <> 5 
    End
	Else
    Begin
		set dateformat dmy
		Insert into #RFAEntry (InvoiceID,RebateQty,RebateValue)
		Select Isnull(RFADocID,Null),0,Isnull(Sum(RebateValue),0) RFAVAlue 
		From tbl_merp_RFAAbstract 
		Where ActivityCode like @ActivityCode and PayoutFrom >= @PayoutFromDate and PayoutTo <=@PayoutToDate and Status & 5 <> 5
		Group By RFADocID
		Insert into #RFAEntry (RFAType,PoinstRedeemed,TotalPoints,RedeemValue,RedeemedPoints,AmountSpent)
		select 'Pending','No',Sum(Isnull(TotalPoints,0)) TotalPoints, Sum(Isnull(RedeemValue,0)) RedeemValue,Sum(Isnull(RedeemedPoints,0)) RedeemedPoints,Sum(Isnull(AmountSpent,0)) AmountSpent 
		From tbl_mERP_CSRedemption Where PayoutID = @PayoutID
		Group By PayoutID
    End

      Select RFAType,PoinstRedeemed,TotalPoints,RedeemValue,RedeemedPoints,AmountSpent,Sum(RebateValue) RFAVAlue,RFAID, IsNull(XMLName,'') XMLName, SubmittedDate, IsNull(XMLStatus,'') XMLStatus,AckDate ,XMLID
      From #RFAEntry Group By RFAID,RFAType, IsNull(XMLName,''), IsNull(XMLStatus,'') ,SubmittedDate,AckDate,XMLID,PoinstRedeemed,TotalPoints,RedeemValue,RedeemedPoints,AmountSpent

End
	Drop table #RFAEntry
	Drop table #tmpInvDetail 
End
