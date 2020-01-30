Create function mERP_fn_List_CSDisplay_OutletCapCustomer(@SchemeID Int)
Returns @Customer Table (CustomerID nVarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, Company_Name nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
as
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
--      ChannelDesc From Customer_Channel Where Active = 1  
		Select ID ,(Case CpO.OutletType When N'ALL' Then ChannelDesc Else CpO.OutletType End) From tbl_mERP_DispSchCapPerOutlet CPO, Customer_Channel  
		Where SchemeID = @SchemeID   And ChannelDesc = (Case Channel When N'ALL' Then ChannelDesc Else Channel End)
        And Active = 1  
    Else  
      Insert into @tmpChannel  
      Select ID, IsNull(OutletType,'') From tbl_mERP_DispSchCapPerOutlet Where SchemeID = @SchemeID


    Insert into @Customer
    Select Cus.CustomerID, Cus.Company_Name
    From Customer Cus, tbl_mERP_DispSchCapPerOutlet CpO, Customer_Channel CusChn, @tmpChannel tmpChn
    Where Cus.CustomerCategory Not In (4,5) And 
	 Cus.Active =1 And
     Cus.ChannelType = CusChn.ChannelType And
     CusChn.ChannelDesc = tmpChn.ChannelDesc And
     CpO.ID = tmpChn.CapID And 
     CpO.SchemeID  = @SchemeID
    Order By Cus.CustomerID, Cus.Company_Name
    End 
  Else
    Begin
    Insert into @Customer
    Select Cus.CustomerID, Cus.Company_Name
    From Customer Cus, tbl_mERP_OLClass OLC, tbl_mERP_OLClassMapping OLM, tbl_mERP_DispSchCapPerOutlet CpO
    Where Cus.CustomerCategory Not In (4,5) And
     Cus.Active =1 And
	 Cus.CustomerID = OLM.CustomerID And 
     OLM.OLClassID = OLC.ID	And 
     OLM.Active = 1 And 
     CpO.SchemeID =  @SchemeID And
     OLC.Channel_Type_Desc = Case CpO.Channel When N'ALL' Then OLC.Channel_Type_Desc Else CpO.Channel End And
     OLC.Outlet_Type_Desc = Case CpO.OutletType When N'ALL' Then OLC.Outlet_Type_Desc Else CpO.OutletType End And
     OLC.SubOutlet_Type_Desc = Case CpO.SubOutletType When N'ALL' Then OLC.SubOutlet_Type_Desc Else CpO.SubOutletType End
    Order by Cus.CustomerID, Cus.Company_Name
    End 
  Return
End
