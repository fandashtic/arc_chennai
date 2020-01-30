Create Procedure mERP_sp_get_CSDisplay_OutletCapAmount(@SchemeID Int, @OutletType nVarchar(50), @CustomerID nVarchar(30))  
As  
Begin  
  Declare @ConfigVal Int  
  Set @ConfigVal = 0   
  Select @ConfigVal = IsNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode Like 'DISP_SCH_OLCLS_BUDGET'  
  If @ConfigVal = 0  
    Begin 
	Declare @tmpChannel Table(CapID Int, ChannelDesc nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
    If Exists (Select IsNull(OutletType,'') From tbl_mERP_DispSchCapPerOutlet Where SchemeID = @SchemeID And OutletType = N'ALL')  
      Insert into @tmpChannel  
--      Select (Select ID From tbl_mERP_DispSchCapPerOutlet Where SchemeID = @SchemeID And OutletType = N'ALL'),   
--      CC.ChannelDesc From Customer_Channel CC, Customer CM Where CC.Active = 1  And CC.ChannelType = CM.ChannelType And CM.CustomerID = @CustomerID
	   Select ID ,(Case CpO.OutletType When N'ALL' Then ChannelDesc Else CpO.OutletType End) From tbl_mERP_DispSchCapPerOutlet CPO,Customer_Channel CC, Customer CM
	   Where SchemeID = @SchemeID And CC.Active = 1  And CC.ChannelType = CM.ChannelType And CM.CustomerID = @CustomerID
	   And ChannelDesc = (Case Channel When N'ALL' Then ChannelDesc Else Channel End)
    Else  
      Insert into @tmpChannel  
      Select CpO.ID, IsNull(OutletType,'') From tbl_mERP_DispSchCapPerOutlet CpO Where CpO.SchemeID = @SchemeID
  
    Select CpO.ID, CpO.CapPerOutlet From tbl_mERP_DispSchCapPerOutlet CpO, Customer_Channel CC, Customer CM, @tmpChannel tmpChn   
    Where CM.CustomerID = @CustomerID And   
    CM.ChannelType = CC.ChannelType And   
    CC.ChannelDesc = tmpChn.ChannelDesc And
    CpO.ID = tmpChn.CapID And 
    CpO.SchemeID = @SchemeID   
    End
  Else  
    Begin
    Select CpO.ID, CpO.CapPerOutlet  
    From Customer Cus, tbl_mERP_OLClass OLC, tbl_mERP_OLClassMapping OLM, tbl_mERP_DispSchCapPerOutlet CpO  
    Where Cus.CustomerID=@CustomerID  And  
     Cus.CustomerID = OLM.CustomerID And   
     OLM.OLClassID = OLC.ID And   
     OLM.Active = 1 And   
     CpO.SchemeID =  @SchemeID And  
     OLC.Channel_Type_Desc = Case CpO.Channel When N'ALL' Then OLC.Channel_Type_Desc Else CpO.Channel End And  
     OLC.Outlet_Type_Desc = Case CpO.OutletType When N'ALL' Then OLC.Outlet_Type_Desc Else CpO.OutletType End And  
     OLC.SubOutlet_Type_Desc = Case CpO.SubOutletType When N'ALL' Then OLC.SubOutlet_Type_Desc Else CpO.SubOutletType End And   
     CpO.OutletType = @OutletType  
    End 
End 
