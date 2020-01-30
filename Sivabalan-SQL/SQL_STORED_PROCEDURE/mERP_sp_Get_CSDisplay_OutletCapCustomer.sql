Create Procedure mERP_sp_Get_CSDisplay_OutletCapCustomer(@PayoutPeriodID Int, @OltCapIDLst nVarchar(1000), @DSList nVarchar(4000) = Null, @BeatList nVarchar(4000) = Null)  
As  
Begin  
  Declare @UniformFlag as Int 
  Declare @tmpSalesman Table(SalesmanID Int)  
  Declare @tmpBeat Table(BeatID Int)  
  Declare @tmpOutletType Table(OutletTypeID Int)  
  Declare @OutletCapAlloc Table(OutletCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,  
        OutletName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
        OutletType nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
        Active nVarchar(5) COLLATE SQL_Latin1_General_CP1_CI_AS,  
        CapPerOutlet Decimal(18,6), AllocatedAmount Decimal(18,6), CapPerOutletID Int)   
  /*Salesman List*/
  If @DSList = N'%' or @DSList = NULL  
    Insert into @tmpSalesman Select SalesmanID From Salesman Where Active = 1  
  Else  
    Insert into @tmpSalesman Select * from dbo.sp_splitIn2Rows(@DSList, ',')  
  /*Beat List*/
  If @BeatList = N'%' or @BeatList = NULL  
    Insert into @tmpBeat Select BeatID From Beat Where Active = 1   
  Else  
    Insert into @tmpBeat Select * from dbo.sp_splitIn2Rows(@BeatList, ',')  
  /*CapPerOutlet List*/
  Insert into @tmpOutletType Select * from dbo.sp_splitIn2Rows(@OltCapIDLst, ',')  
  
  Select @UniformFlag = IsNull(UniformAllocFlag,0) from tbl_merp_SchemeAbstract 
  Where SchemeID = (Select Top 1 SchemeID From tbl_mERP_SchemePayoutPeriod Where ID = @PayoutPeriodID)

  Declare @ConfigVal Int  
  Set @ConfigVal = 0   
  Select @ConfigVal = IsNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode Like 'DISP_SCH_OLCLS_BUDGET'  
  Declare @tmpChannel Table(CapID Int, ChannelDesc nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
  If @ConfigVal = 0 
    Begin
    If Exists (Select IsNull(OutletType,'') From tbl_mERP_DispSchCapPerOutlet CpO, @tmpOutletType tmpOlt Where CpO.ID = tmpOlt.OutletTypeID And CpO.OutletType = N'ALL')  
      Insert into @tmpChannel  
--      Select (Select ID From tbl_mERP_DispSchCapPerOutlet CpO, @tmpOutletType tmpOlt Where CpO.ID = tmpOlt.OutletTypeID And CpO.OutletType = N'ALL'),   
--      ChannelDesc From Customer_Channel Where Active = 1  
	  Select Distinct CpO.ID ,(Case CpO.OutletType When N'ALL' Then ChannelDesc Else CpO.OutletType End)  From tbl_mERP_DispSchCapPerOutlet CpO, 
	  @tmpOutletType tmpOlt ,Customer_Channel  Where CpO.ID = tmpOlt.OutletTypeID 
	  And Active = 1 And ChannelDesc = (Case Channel When N'ALL' Then ChannelDesc Else Channel End)
    Else  
      Insert into @tmpChannel  
      Select CpO.ID, IsNull(OutletType,'') From tbl_mERP_DispSchCapPerOutlet CpO, @tmpOutletType tmpOlt Where CpO.ID = tmpOlt.OutletTypeID   

        
    Insert into @OutletCapAlloc  
    Select Cus.CustomerID, Cus.Company_Name, CusChn.ChannelDesc,   
    Case Cus.Active When 0 Then N'No' Else N'Yes' End 'Active', CpO.CapPerOutlet, 
    Case @UniformFlag When 0 Then 0 Else CpO.CapPerOutlet End as 'AllocatedAmt', CpO.ID  
    From Customer Cus, tbl_mERP_DispSchCapPerOutlet CpO, Customer_Channel CusChn, @tmpChannel tmpChn  
    Where Cus.Active = 1 And 
     Cus.ChannelType = CusChn.ChannelType And  
     CusChn.ChannelDesc = tmpChn.ChannelDesc And  
     CpO.ID = tmpChn.CapID And   
     CpO.ID in (Select OutletTypeID From @tmpOutletType)  
    Order By CpO.CapPerOutlet, CusChn.ChannelDesc, Cus.Company_Name  
    End    
  Else  
    Begin  
    If Exists (Select IsNull(OutletType,'') From tbl_mERP_DispSchCapPerOutlet CpO, @tmpOutletType tmpOlt Where CpO.ID = tmpOlt.OutletTypeID And CpO.OutletType = N'ALL')  
      Insert into @tmpChannel  
      --Select Distinct (Select ID From tbl_mERP_DispSchCapPerOutlet CpO, @tmpOutletType tmpOlt Where CpO.ID = tmpOlt.OutletTypeID And CpO.OutletType = N'ALL'),   
      --Outlet_Type_Desc From tbl_mERP_OLClass Where Outlet_Type_Active = 1
	  Select Distinct CpO.ID ,(Case CpO.OutletType When N'ALL' Then Outlet_Type_Desc Else CpO.OutletType End)  From tbl_mERP_DispSchCapPerOutlet CpO, 
	  @tmpOutletType tmpOlt ,tbl_mERP_OLClass  Where CpO.ID = tmpOlt.OutletTypeID 
	  And Outlet_Type_Active = 1	And Channel_Type_Desc = (Case Channel When N'ALL' Then Channel_Type_Desc Else Channel End)
    Else  
      Insert into @tmpChannel  
      Select CpO.ID, IsNull(OutletType,'') From tbl_mERP_DispSchCapPerOutlet CpO, @tmpOutletType tmpOlt Where CpO.ID = tmpOlt.OutletTypeID   


	

    Insert into @OutletCapAlloc  
    Select Cus.CustomerID, Cus.Company_Name, OLC.Outlet_Type_Desc 'OutletType',   
    Case Cus.Active When 0 Then N'No' Else N'Yes' End 'Active', CpO.CapPerOutlet, 
    Case @UniformFlag When 0 Then 0 Else CpO.CapPerOutlet End as 'AllocatedAmt', CpO.ID  
    From Customer Cus, tbl_mERP_OLClass OLC, tbl_mERP_OLClassMapping OLM, tbl_mERP_DispSchCapPerOutlet CpO, @tmpChannel tmpChn  
    Where Cus.Active = 1 And 
     Cus.CustomerID = OLM.CustomerID And   
     OLM.OLClassID = OLC.ID And   
     OLM.Active = 1 And   
     CpO.ID = tmpChn.CapID And 
     OLC.Outlet_Type_Desc = tmpChn.ChannelDesc And 
     CpO.ID in (Select OutletTypeID From @tmpOutletType) And  
     OLC.Channel_Type_Desc = Case CpO.Channel When N'ALL' Then OLC.Channel_Type_Desc Else CpO.Channel End And  
     OLC.Outlet_Type_Desc = Case CpO.OutletType When N'ALL' Then OLC.Outlet_Type_Desc Else CpO.OutletType End And  
     OLC.SubOutlet_Type_Desc = Case CpO.SubOutletType When N'ALL' Then OLC.SubOutlet_Type_Desc Else CpO.SubOutletType End  
    Order by CpO.CapPerOutlet, CpO.OutletType, Cus.Company_Name  
    End  
  
--  select * from @OutletCapAlloc  
  
  If (@DSList = N'%' or @DSList = NULL) And (@BeatList = N'%' or @BeatList = NULL)  
    Select Distinct OLTCap.* From @OutletCapAlloc OLTCap 
    Order by OLTCap.CapPerOutlet, OLTCap.OutletType, OLTCap.OutletName
  Else  
    Select Distinct OLTCap.*   
    From @OutletCapAlloc OLTCap, @tmpSalesman tSalesman, @tmpBeat tBeat, Beat_Salesman BS  
    Where OLTCap.OutletCode = BS.CustomerID And   
    tSalesman.SalesmanID = BS.SalesmanID And   
    tBeat.BeatID = BS.BeatID   
	Order By OLTCap.CapPerOutlet, OLTCap.OutletType, OLTCap.OutletName
End  
