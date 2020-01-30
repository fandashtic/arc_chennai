Create Procedure mERP_sp_List_CSDisplay_OutletCapAlloc(@PayoutPeriodID Int)  
As 
Begin
  Declare @ConfigVal Int  
  Set @ConfigVal = 0   
  Select @ConfigVal = IsNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode Like 'DISP_SCH_OLCLS_BUDGET'  
  Declare @tmpChannel Table(CapID Int,ChannelDesc nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
  If @ConfigVal = 0   
    Begin
    If Exists (Select IsNull(OutletType,'') From tbl_mERP_DispSchCapPerOutlet CpO, tbl_merp_SchemePayoutPeriod PP Where CpO.SchemeID=PP.SchemeID And PP.ID = @PayoutPeriodID And CpO.OutletType = N'ALL')  
      Insert into @tmpChannel 
--       Select  (Select CpO.ID From tbl_mERP_DispSchCapPerOutlet CpO, tbl_merp_SchemePayoutPeriod PP Where CpO.SchemeID=PP.SchemeID And PP.ID = @PayoutPeriodID And CpO.OutletType = N'ALL'),
--      ChannelDesc From Customer_Channel Where Active = 1  
	  Select Distinct CpO.ID ,(Case CpO.OutletType When N'ALL' Then ChannelDesc Else CpO.OutletType End)  From tbl_mERP_DispSchCapPerOutlet CpO, 
	  tbl_merp_SchemePayoutPeriod PP,Customer_Channel Where CpO.SchemeID=PP.SchemeID And PP.ID = @PayoutPeriodID   
	  And Customer_Channel.Active = 1	And ChannelDesc = (Case Channel When N'ALL' Then ChannelDesc Else Channel End)

    Else  
      Insert into @tmpChannel  
      Select CpO.ID, IsNull(CpO.OutletType,'') From tbl_mERP_DispSchCapPerOutlet CpO, tbl_merp_SchemePayoutPeriod PP Where CpO.SchemeID=PP.SchemeID And PP.ID= @PayoutPeriodID
    
    Select Cus.CustomerID, Cus.Company_Name,CusChn.ChannelDesc,   
    Case Cus.Active When 0 Then N'No' Else N'Yes' End 'Active', CpO.CapPerOutlet, BPay.AllocatedAmount, CpO.ID  
    From Customer Cus, tbl_mERP_DispSchCapPerOutlet CpO, tbl_mERP_DispSchBudgetPayout BPay, @tmpChannel tmpChn, Customer_Channel CusChn
    Where BPay.PayoutPeriodID = @PayoutPeriodID And  
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
    If Exists (Select IsNull(OutletType,'') From tbl_mERP_DispSchCapPerOutlet CpO, tbl_merp_SchemePayoutPeriod PP Where CpO.SchemeID=PP.SchemeID And PP.ID = @PayoutPeriodID And CpO.OutletType = N'ALL')  
      Insert into @tmpChannel  
--      Select Distinct  (Select CpO.ID From tbl_mERP_DispSchCapPerOutlet CpO, tbl_merp_SchemePayoutPeriod PP Where CpO.SchemeID=PP.SchemeID And PP.ID = @PayoutPeriodID And CpO.OutletType = N'ALL'),  
--      Outlet_Type_Desc From tbl_mERP_OLClass Where Outlet_Type_Active = 1  
	  Select Distinct CpO.ID ,(Case CpO.OutletType When N'ALL' Then Outlet_Type_Desc Else CpO.OutletType End)  From tbl_mERP_DispSchCapPerOutlet CpO, 
	  tbl_merp_SchemePayoutPeriod PP,tbl_mERP_OLClass Where CpO.SchemeID=PP.SchemeID And PP.ID = @PayoutPeriodID   
	  And Outlet_Type_Active = 1	And Channel_Type_Desc = (Case Channel When N'ALL' Then Channel_Type_Desc Else Channel End)

    Else  
      Insert into @tmpChannel  
      Select CpO.ID, IsNull(CpO.OutletType,'') From tbl_mERP_DispSchCapPerOutlet CpO, tbl_merp_SchemePayoutPeriod PP Where CpO.SchemeID=PP.SchemeID And PP.ID= @PayoutPeriodID

    Select Cus.CustomerID, Cus.Company_Name, OLC.Outlet_Type_Desc 'OutletType',   
    Case Cus.Active When 0 Then N'No' Else N'Yes' End 'Active', CpO.CapPerOutlet, BPay.AllocatedAmount, CpO.ID  
    From Customer Cus, tbl_mERP_OLClass OLC, tbl_mERP_OLClassMapping OLM, tbl_mERP_DispSchCapPerOutlet CpO, tbl_mERP_DispSchBudgetPayout BPay, @tmpChannel tmpChn
    Where BPay.PayoutPeriodID = @PayoutPeriodID And  
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
End
