Create Procedure mERP_sp_get_CSDisplay_CustomerCapPayout(@CustomerID nVarchar(30), @SchemeID Int)
as
Begin
  Declare @ConfigVal Int
  Set @ConfigVal = 0 
  Select @ConfigVal = IsNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode Like 'DISP_SCH_OLCLS_BUDGET'
  Declare @tmpChannel Table(CapID Int, ChannelDesc nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
  If @ConfigVal = 0 
    Begin
    If Exists (Select IsNull(OutletType,'') From tbl_mERP_DispSchCapPerOutlet Where SchemeID = @SchemeID And OutletType = N'ALL')
      Insert into @tmpChannel
--      Select (Select ID From tbl_mERP_DispSchCapPerOutlet Where SchemeID = @SchemeID And OutletType = N'ALL'), 
--      ChannelDesc From Customer_Channel Where Active = 1
		Select ID ,(Case CpO.OutletType When N'ALL' Then ChannelDesc Else CpO.OutletType End) From tbl_mERP_DispSchCapPerOutlet CPO,Customer_Channel
		Where SchemeID = @SchemeID And Active = 1 And ChannelDesc = (Case Channel When N'ALL' Then ChannelDesc Else Channel End)
    Else
      Insert into @tmpChannel
      Select ID, IsNull(OutletType,'') From tbl_mERP_DispSchCapPerOutlet Where SchemeID = @SchemeID

    Select Case Cus.Active When 1 then 'Yes' Else 'No' End, CusChn.ChannelDesc, CpO.CapPerOutlet, CpO.ID
    From Customer Cus, tbl_mERP_DispSchCapPerOutlet CpO, Customer_Channel CusChn, @tmpChannel tmpChn
    Where Cus.CustomerID = @CustomerID and 
     Cus.ChannelType = CusChn.ChannelType And
     CusChn.ChannelDesc = tmpChn.ChannelDesc And
     CpO.ID = tmpChn.CapID And 
     CpO.SchemeID  = @SchemeID 
    End
  Else
    Begin
	If Exists (Select IsNull(OutletType,'') From tbl_mERP_DispSchCapPerOutlet Where SchemeID = @SchemeID And OutletType = N'ALL')
      Insert into @tmpChannel  
--      Select Distinct  (Select CpO.ID From tbl_mERP_DispSchCapPerOutlet CpO Where CpO.SchemeID=@SchemeID And CpO.OutletType = N'ALL'),  
--      Outlet_Type_Desc From tbl_mERP_OLClass Where Outlet_Type_Active = 1  
		Select Distinct CpO.ID ,(Case CpO.OutletType When N'ALL' Then Outlet_Type_Desc Else CpO.OutletType End)  From tbl_mERP_DispSchCapPerOutlet CpO ,
		tbl_mERP_OLClass  Where CpO.SchemeID=@SchemeID 
		And Outlet_Type_Active = 1	And Channel_Type_Desc = (Case Channel When N'ALL' Then Channel_Type_Desc Else Channel End)
    Else  
      Insert into @tmpChannel  
      Select CpO.ID, IsNull(CpO.OutletType,'') From tbl_mERP_DispSchCapPerOutlet CpO Where CpO.SchemeID=@SchemeID

    Select Case Cus.Active When 1 then 'Yes' Else 'No' End, OLC.Outlet_Type_Desc, CpO.CapPerOutlet, CpO.ID
    From Customer Cus, tbl_mERP_OLClass OLC, tbl_mERP_OLClassMapping OLM, tbl_mERP_DispSchCapPerOutlet CpO, @tmpChannel tmpChn
    Where Cus.CustomerID=@CustomerID  And
     Cus.CustomerID = OLM.CustomerID And 
     OLM.OLClassID = OLC.ID	And 
     OLM.Active = 1 And 
     CpO.SchemeID =  @SchemeID And
	 CpO.ID = tmpChn.CapID And 
     OLC.Outlet_Type_Desc = tmpChn.ChannelDesc And 
     OLC.Channel_Type_Desc = Case CpO.Channel When N'ALL' Then OLC.Channel_Type_Desc Else CpO.Channel End And
     OLC.Outlet_Type_Desc = Case CpO.OutletType When N'ALL' Then OLC.Outlet_Type_Desc Else CpO.OutletType End And
     OLC.SubOutlet_Type_Desc = Case CpO.SubOutletType When N'ALL' Then OLC.SubOutlet_Type_Desc Else CpO.SubOutletType End
    Order by Cus.CustomerID, Cus.Company_Name
    End
End
