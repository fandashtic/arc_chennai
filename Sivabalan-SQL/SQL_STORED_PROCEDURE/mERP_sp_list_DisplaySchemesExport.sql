Create procedure mERP_sp_list_DisplaySchemesExport(@SCR_MODE INT, @SchemeCode nVarChar(50), 
	@FromDate DateTime, @ToDate DateTime,  @PAYOUT INT = 0, @BUDGET INT = 0)  
As  

Create Table #tempSchDetails (IDs Int Identity(1, 1), SchemeID Int, CSSchID Int, 
		Activity_Code nVarchar(100) Collate SQL_Latin1_General_CP1_CI_AS,
		Description nVarchar(100) Collate SQL_Latin1_General_CP1_CI_AS, 
		ScType nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS, 
		Activity_Type nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS, 
		Status nVarchar(20) Collate SQL_Latin1_General_CP1_CI_AS, 
		Period nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS, 
		[Category Group - Category] nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS, 
		[Pay Frequency] nVarchar(20) Collate SQL_Latin1_General_CP1_CI_AS,
		[Is Budget Overrun] nVarchar(20) Collate SQL_Latin1_General_CP1_CI_AS,
		[PayOut Period] nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS, 
		Budget Decimal(18, 6),
		[Outlet ID] nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS, 
		[Outlet Name] nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS, 
		Channel	nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS, 
		Outlet	nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS, 
		Loyalty	nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS, 
		CapPerOutlet Decimal(18, 6), 
		Allocation Decimal(18, 6),
		PayoutID Int)

  Declare @tmpBudgetPayout Table(SchemeID Int, PayoutPeriodID Int, AllocatedAmount Decimal(18,6), 
	PendingAmount Decimal(18,6))
   /* 0 - ALL
     1 - ALLOCATED
     2 - PARTIAL
     3 - NOT ALLOCATED  */
   IF @BUDGET = 1
     Insert into @tmpBudgetPayout
     Select BP.SchemeID, BP.PayoutPeriodID, Sum(BP.AllocatedAmount) 'AllocatedAmount', Sum(BP.PendingAmount) 'PendingAmount'
     From   tbl_mERP_DispSchBudgetPayout BP, tbl_meRP_SchemePayoutPeriod PP
     Where  BP.SchemeID = PP.SchemeID And BP.PayoutPeriodID = PP.ID And --PP.Status & 128 = 128 And 
     IsNull(PP.Status,0) & 128 = (Case @PAYOUT When 0 Then IsNull(PP.Status,0)&128 When 1 Then 0 When 2 Then 128 End)
     Group By BP.SchemeID, BP.PayoutPeriodID
     Having Sum(IsNull(BP.AllocatedAmount,0)) >= (Select IsNull(Budget,0) From tbl_mErp_SchemeAbstract Where SchemeID = BP.SchemeID)
   Else IF @BUDGET = 2 
     Insert into @tmpBudgetPayout
     Select PP.SchemeID, IsNull(BP.PayoutPeriodID,0), Sum(IsNull(BP.AllocatedAmount,0)) 'AllocatedAmount', Sum(IsNull(BP.PendingAmount,0)) 'PendingAmount'
     From tbl_mERP_DispSchBudgetPayout BP, tbl_meRP_SchemePayoutPeriod PP
     Where BP.SchemeID = PP.SchemeID And BP.PayoutPeriodID = PP.ID And --PP.Status & 128 = 0 And
     IsNull(PP.Status,0) & 128 = (Case @PAYOUT When 0 Then IsNull(PP.Status,0)&128 When 1 Then 0 When 2 Then 128 End)
     Group By PP.SchemeID, IsNull(BP.PayoutPeriodID,0)
     Having Sum(IsNull(BP.AllocatedAmount,0)) < (Select IsNull(Budget,0) From tbl_mErp_SchemeAbstract Where SchemeID = PP.SchemeID) And 
     Sum(IsNull(BP.AllocatedAmount,0)) > 0
   Else If @BUDGET = 3
     Insert into @tmpBudgetPayout
     Select PP.SchemeID, PP.ID, Sum(IsNull(BP.AllocatedAmount,0)) 'AllocatedAmount', Sum(IsNull(BP.PendingAmount,0)) 'PendingAmount'
     From  tbl_mERP_DispSchBudgetPayout BP
	 Right Outer Join tbl_mERP_SchemePayoutPeriod PP On PP.SchemeID = BP.SchemeID  And PP.ID = BP.PayoutPeriodID
     Where PP.Active = Case @SCR_MODE When 0 Then PP.Active Else 1 End 		
       And PP.ID not In (Select IsNull(PayoutPeriodID,0) as 'PayoutPeriodID' From tbl_mERP_DispSchBudgetPayout where SchemeID = PP.SchemeID)
       And IsNull(PP.Status,0) & 128 = (Case @PAYOUT When 0 Then IsNull(PP.Status,0)&128 When 1 Then 0 When 2 Then 128 End)
     Group By PP.SchemeID, PP.ID
     Having Sum(IsNull(BP.AllocatedAmount,0)) = 0
   Else
     Insert into @tmpBudgetPayout
     Select Distinct PP.SchemeID, PP.ID, 0, 0 From tbl_mERP_SchemePayoutPeriod PP, tbl_mERP_DispSchCapPerOutlet CpO
     Where  CpO.SchemeID = PP.SchemeID And --PP.Active = 1 And
	 PP.Active = Case @SCR_MODE When 0 Then PP.Active Else 1 End  and
     IsNull(PP.Status,0) & 128 = (Case @PAYOUT When 0 Then IsNull(PP.Status,0)&128 When 1 Then 0 When 2 Then 128 End)

Insert InTo #tempSchDetails (SchemeID , CSSchID , Activity_Code , Description , ScType , Activity_Type , 
	Status , Period , [Category Group - Category] , [Pay Frequency] , [Is Budget Overrun] , [PayOut Period] , 
	Budget , PayoutID)
Select CSAbstract.SchemeID,  
    CSAbstract.CS_RecSchID,  
    CSAbstract.ActivityCode,  
    CSAbstract.Description, 
	CSType.SchemeType, 
	"Activity Type" = Case IsNull(CSAbstract.SchemeStatus,0) When 0 Then 'New' When 1 then 'CR' When 2 Then 'Drop' End,
	"Status" = Case (Select IsNull(ClaimRFA,0) From tbl_merp_SchemePayoutPeriod Where SchemeID = CSAbstract.SchemeID 
		And ID = PP.ID) When 0 Then 'Active' Else 'Expired' End, 
    "Period" = convert(nvarchar(12),CSAbstract.SchemeFrom,103) + N' To '+ convert(nvarchar(12),CSAbstract.SchemeTo,103),
	"Category Group - Category" = '',
	"Pay Frequency" = Case CSAbstract.PayoutFrequency when 0 Then 'Monthly'
		 when 1 Then 'Quarterly'
		 when 2 then 'Half Yearly'
		 when 3 then 'Yearly'
		 when 4 then 'End of Period' End,
	"Is Budget Overrun" = Case CSAbstract.BudgetOverRun When 1 Then 'Yes' Else 'No' End,
    "PayoutPeriod" = convert(nvarchar(12),PP.PayoutPeriodFrom,103) + N' To '+ convert(nvarchar(12),PP.PayoutPeriodTo,103),
	"Budget" = IsNull(CSAbstract.Budget,0),
    PP.ID as 'PayoutPeriodID'
   From tbl_mERP_SchemeAbstract CSAbstract, tbl_mERP_SchemeType CSType, 
	tbl_mERP_SchemePayoutPeriod PP, @tmpBudgetPayout tmpPayout
   Where  
    CSType.ID = 3 
	-- And CSAbstract.ViewDate Between @FromDate And @ToDate
    And  ((@FromDate Between CSAbstract.ViewDate And CSAbstract.SchemeTo)  Or 
          (@ToDate Between CSAbstract.ViewDate And CSAbstract.SchemeTo) Or 
          (CSAbstract.ViewDate Between @FromDate And @ToDate) Or
          (CSAbstract.SchemeTo Between @FromDate And @ToDate))
    And CSType.ID  = CSAbstract.SchemeType 
    And  CSAbstract.CS_RecSchID = Case @SchemeCode When N'%' Then CSAbstract.CS_RecSchID Else @SchemeCode End
    -- And dbo.StripTimeFromDate(CSAbstract.ActiveFrom) <= (Select Top 1 dbo.StripTimeFromDate(Transactiondate) From Setup)
   And dbo.StripTimeFromDate(CSAbstract.ViewDate) <= (Select Top 1 dbo.StripTimeFromDate(Transactiondate) From Setup)
--    And CSAbstract.Active = Case @FILTER WHEN 0 THEN CSAbstract.Active WHEN 1 THEN 1 WHEN 2 THEN 0 END  
    And CSAbstract.SchemeID = PP.SchemeID  
    And CSAbstract.SchemeID = tmpPayout.SchemeID
    And PP.ID = tmpPayout.PayoutPeriodID
    --And IsNull(PP.Active,0) = 1 
	And IsNull(PP.Active,0) = Case @SCR_MODE When 0 Then PP.Active Else 1 End 
    And CSAbstract.Active = Case @SCR_MODE When 0 Then CSAbstract.Active Else 1 End 
   Order by  
    CSAbstract.ActivityCode, PP.ID


--==================================================================================
Declare @Sc1 Int
Declare @Py1 Int
Declare @STabCount Int
Declare @BCount Int
Declare @MinID Int
Declare @ActivityCodeChk nVarchar(256)
Declare @PreActivityCodeChk nVarchar(256)

Set @Sc1 = 0
Set @Py1 = 0
Set @STabCount = 0
Set @BCount = 1
Set @MinID = 0
Set @ActivityCodeChk = ''
Set @PreActivityCodeChk = ''

Create Table #TmpOutlet ([ID] Int Identity(1,1), SchemeID Int, PayoutID Int,
	CustomerID nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS,
	CustomerName nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS, 
	Allocation Decimal(18, 6))

Create Table #TmpChannel ([ID] Int Identity(1,1), SchemeID Int, PayoutID Int,
	Channel nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS,
	Outlet nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS, 
	Loyalty nVarchar(250) Collate SQL_Latin1_General_CP1_CI_AS,
	CapPerOutlet Decimal(18, 6))

  Declare @ConfigVal Int  
  Set @ConfigVal = 0   
  Select @ConfigVal = IsNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode Like 'DISP_SCH_OLCLS_BUDGET'  

  Declare @tmpChannel Table(CapID Int,ChannelDesc nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  


Declare ScDtls Cursor For
Select Distinct SchemeID, PayoutID, Activity_Code From #tempSchDetails 
Open ScDtls 
Fetch From ScDtls InTo @Sc1, @Py1, @ActivityCodeChk 
While @@Fetch_Status = 0
Begin
  Delete From @tmpChannel

  If @ConfigVal = 0   
    Begin
    If Exists (Select IsNull(OutletType,'') From tbl_mERP_DispSchCapPerOutlet CpO, 
		tbl_merp_SchemePayoutPeriod PP Where CpO.SchemeID=PP.SchemeID And PP.ID = @Py1 And 
		CpO.OutletType = N'ALL')  
      Insert into @tmpChannel  
--	  Select (Select CpO.ID From tbl_mERP_DispSchCapPerOutlet CpO, tbl_merp_SchemePayoutPeriod PP 
--	  Where CpO.SchemeID=PP.SchemeID And PP.ID = @Py1 And CpO.OutletType = N'ALL'),
--      ChannelDesc From Customer_Channel Where Active = 1  

	  Select Distinct CpO.ID ,(Case CpO.OutletType When N'ALL' Then ChannelDesc Else CpO.OutletType End)  From tbl_mERP_DispSchCapPerOutlet CpO, 
	  tbl_merp_SchemePayoutPeriod PP,Customer_Channel Where CpO.SchemeID=PP.SchemeID And PP.ID = @Py1   
	  And Customer_Channel.Active = 1	And ChannelDesc = (Case Channel When N'ALL' Then ChannelDesc Else Channel End)

    Else  
      Insert into @tmpChannel  
      Select CpO.ID, IsNull(CpO.OutletType,'') From tbl_mERP_DispSchCapPerOutlet CpO, tbl_merp_SchemePayoutPeriod PP 
		Where CpO.SchemeID=PP.SchemeID And PP.ID= @Py1

	Insert InTo #TmpOutlet (SchemeID , PayoutID ,
	CustomerID , CustomerName, Allocation) 
    
    Select @Sc1, @Py1, Cus.CustomerID, Cus.Company_Name, 
		BPay.AllocatedAmount
    From Customer Cus, tbl_mERP_DispSchCapPerOutlet CpO, tbl_mERP_DispSchBudgetPayout BPay, @tmpChannel tmpChn, Customer_Channel CusChn
    Where BPay.PayoutPeriodID = @Py1 And  
     BPay.PayoutPeriodID in (Select ID from tbl_mERP_SchemePayoutPeriod) And  
     CpO.ID = Bpay.CapPerOutletID And  
     CpO.ID = tmpChn.CapID And 
     CusChn.ChannelDesc = tmpChn.ChannelDesc And 
     CusChn.ChannelType = Cus.ChannelType And
     Cus.CustomerID = BPay.OutletCode  
    Order By CpO.CapPerOutlet, CusChn.ChannelDesc, Cus.Company_Name  
    End
  Else 
    Begin
    If Exists (Select IsNull(OutletType,'') From tbl_mERP_DispSchCapPerOutlet CpO, tbl_merp_SchemePayoutPeriod PP 
		Where CpO.SchemeID=PP.SchemeID And PP.ID = @Py1 And CpO.OutletType = N'ALL')  
      Insert into @tmpChannel  
--	  Select Distinct (Select CpO.ID From tbl_mERP_DispSchCapPerOutlet CpO, tbl_merp_SchemePayoutPeriod PP 
--		Where CpO.SchemeID=PP.SchemeID And PP.ID = @Py1 And CpO.OutletType = N'ALL'),  
--      Outlet_Type_Desc From tbl_mERP_OLClass Where Outlet_Type_Active = 1  

	  Select Distinct CpO.ID ,(Case CpO.OutletType When N'ALL' Then Outlet_Type_Desc Else CpO.OutletType End)  From tbl_mERP_DispSchCapPerOutlet CpO, 
	  tbl_merp_SchemePayoutPeriod PP,tbl_mERP_OLClass Where CpO.SchemeID=PP.SchemeID And PP.ID = @Py1   
	  And Outlet_Type_Active = 1	And Channel_Type_Desc = (Case Channel When N'ALL' Then Channel_Type_Desc Else Channel End)

    Else  
      Insert into @tmpChannel  
      Select CpO.ID, IsNull(CpO.OutletType,'') From tbl_mERP_DispSchCapPerOutlet CpO, 
	tbl_merp_SchemePayoutPeriod PP Where CpO.SchemeID=PP.SchemeID And PP.ID= @Py1

	Insert InTo #TmpOutlet (SchemeID , PayoutID ,
	CustomerID , CustomerName, Allocation) 

    Select @Sc1, @Py1, Cus.CustomerID, Cus.Company_Name, 
		BPay.AllocatedAmount   
    From Customer Cus, tbl_mERP_OLClass OLC, tbl_mERP_OLClassMapping OLM, tbl_mERP_DispSchCapPerOutlet CpO, 
		tbl_mERP_DispSchBudgetPayout BPay, @tmpChannel tmpChn
    Where BPay.PayoutPeriodID = @Py1 And  
     BPay.PayoutPeriodID in (Select ID from tbl_mERP_SchemePayoutPeriod) And
	 Cus.CustomerID = BPay.OutletCode And
     Cus.CustomerID = OLM.CustomerID And   
     OLM.OLClassID = OLC.ID And   
     OLM.Active = 1 And   
     CpO.ID = tmpChn.CapID And 
     OLC.Outlet_Type_Desc = tmpChn.ChannelDesc And 
     OLC.Channel_Type_Desc = Case CpO.Channel When N'ALL' Then OLC.Channel_Type_Desc Else CpO.Channel End And  
     OLC.Outlet_Type_Desc = Case CpO.OutletType When N'ALL' Then OLC.Outlet_Type_Desc Else CpO.OutletType End And  
     OLC.SubOutlet_Type_Desc = Case CpO.SubOutletType When N'ALL' Then OLC.SubOutlet_Type_Desc Else CpO.SubOutletType End  
    Order by CpO.CapPerOutlet, OLC.Outlet_Type_Desc, Cus.Company_Name  
    End
	

	Select @STabCount = Count(SchemeID) From #tempSchDetails 
	Where SchemeID = @Sc1 And PayoutID = @Py1
	
	Select @MinID = Min(IDs) From #tempSchDetails
	Where SchemeID = @Sc1 And PayoutID = @Py1

	If @ActivityCodeChk = @PreActivityCodeChk
	Begin
		Update #tempSchDetails Set Activity_Code = Null, Description = Null, ScType = Null, Activity_Type = Null, 
		Status = Null, Period = Null, [Category Group - Category] = Null, [Pay Frequency] = Null, [Is Budget Overrun] = Null
		Where IDs = @MinID 
	End

	While @BCount <= @STabCount 
	Begin
		Update 	#tempSchDetails Set [Outlet ID] = (Select CustomerID From #TmpOutlet Where ID = @BCount), 
			[Outlet Name]  = (Select CustomerName From #TmpOutlet Where ID = @BCount), 
			Allocation = (Select Allocation From #TmpOutlet Where ID = @BCount)
		Where IDs = @MinID

		Select Top 1 @MinID = IDs From #tempSchDetails
		Where IDs > @MinID And SchemeID = @Sc1 And PayoutID = @Py1
		Order By IDs
	
		Set @BCount = @BCount + 1		
	End
	
	Insert InTo #tempSchDetails (SchemeID, PayoutID, [Outlet ID], [Outlet Name], Allocation)
	Select SchemeID , PayoutID ,
		CustomerID , CustomerName, Allocation From #TmpOutlet
	Where ID >=  @BCount 

	Truncate Table #TmpOutlet
	Set @STabCount = 0
	Set @BCount = 1
	Set @MinID = 0

--===================================================================================
--  Channel

Insert InTo #TmpChannel (SchemeID , PayoutID ,
	Channel , Outlet , Loyalty , CapPerOutlet )
Select @Sc1, @Py1, IsNull((Select Top 1 Right(Channel_Type_Code, 2) From tbl_merp_olclass 
	Where Channel_Type_Desc = Channel), '') + '~' + Channel , 
	 IsNull((Select Top 1 Right(Outlet_Type_Code, 2) From tbl_merp_olclass 
	Where Outlet_Type_Desc = OutletType), '') + '~' + OutletType , 
	 IsNull((Select Top 1 Right(SubOutlet_Type_Code, 2) From tbl_merp_olclass 
	Where SubOutlet_Type_Desc = SubOutletType), '') + '~' + SubOutletType ,
	CapPerOutlet from tbl_mERP_DispSchCapPerOutlet
Where SchemeID = @Sc1
Order by Channel,CapPerOutlet

	Select @STabCount = Count(SchemeID) From #tempSchDetails 
	Where SchemeID = @Sc1 And PayoutID = @Py1
	
	Select @MinID = Min(IDs) From #tempSchDetails
	Where SchemeID = @Sc1 And PayoutID = @Py1

	While @BCount <= @STabCount 
	Begin

		Update 	#tempSchDetails Set Channel = (Select Channel From #TmpChannel Where ID = @BCount), 
			Outlet  = (Select Outlet From #TmpChannel Where ID = @BCount), 
			Loyalty = (Select Loyalty From #TmpChannel Where ID = @BCount),
			CapPerOutlet = (Select CapPerOutlet From #TmpChannel Where ID = @BCount)
		Where IDs = @MinID

		Select Top 1 @MinID = IDs From #tempSchDetails
		Where IDs > @MinID And SchemeID = @Sc1 And PayoutID = @Py1
		Order By IDs
	
		Set @BCount = @BCount + 1		
	End
	
	Insert InTo #tempSchDetails (SchemeID, PayoutID, Channel, Outlet, Loyalty, CapPerOutlet)
	Select SchemeID , PayoutID , Channel, Outlet, Loyalty, CapPerOutlet From #TmpChannel
	Where ID >=  @BCount 

	Truncate Table #TmpChannel
	Set @STabCount = 0
	Set @BCount = 1
	Set @MinID = 0


Insert InTo #tempSchDetails (SchemeID, PayoutID, Allocation)
Select @Sc1 , @Py1, (Select Sum(Allocation) From #tempSchDetails
						Where SchemeID = @Sc1 And PayoutID = @Py1)

Set @PreActivityCodeChk = @ActivityCodeChk 

Fetch Next From ScDtls InTo @Sc1, @Py1, @ActivityCodeChk

End
Close ScDtls
DeAllocate ScDtls


Select "RowCount" = Count(*) From #tempSchDetails

Select SchemeID, PayoutID, "Activity Code" = Activity_Code, 
	"Description" = Description , "Type" = ScType , "Activity Type" = Activity_Type, 
	"Status" = Status, "Period" = Period , "Category Group - Category" = [Category Group - Category], 
	"Pay Frequency" = [Pay Frequency], "Is Budget Overrun" = [Is Budget Overrun], 
	"PayOut Period" = [PayOut Period], "Budget" = Budget , 
	"Channel" = Channel + '~' + Outlet + '~' + Loyalty + '~' + Cast(CapPerOutlet As nVarchar), 
	"Outlet ID" = [Outlet ID], 
	"Outlet Name" = [Outlet Name], 
	"Allocation" = Allocation 
From #tempSchDetails
Order By SchemeID, PayoutID, IDs

Drop Table #TmpOutlet
Drop Table #tempSchDetails
Drop Table #TmpChannel
