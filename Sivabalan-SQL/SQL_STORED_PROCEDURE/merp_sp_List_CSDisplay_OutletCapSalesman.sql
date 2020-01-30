Create Procedure merp_sp_List_CSDisplay_OutletCapSalesman(@OUTLETCAPID INT)
As
Begin
Declare @ConfigVal Int
Set @ConfigVal = 0 
Select @ConfigVal = IsNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode Like 'DISP_SCH_OLCLS_BUDGET'
If @ConfigVal = 0 
  Begin
  Declare @tmpChannel Table(ChannelDesc nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
  If (Select IsNull(OutletType,'') From tbl_mERP_DispSchCapPerOutlet Where ID = @OUTLETCAPID) = N'ALL'
    Insert into @tmpChannel
    Select ChannelDesc From Customer_Channel Where Active = 1
  Else
    Insert into @tmpChannel
    Select IsNull(OutletType,'') From tbl_mERP_DispSchCapPerOutlet Where ID = @OUTLETCAPID

  Select Distinct Sm.SalesmanID , Sm.Salesman_Name From 
  Salesman Sm, Beat_salesman BtSm, Customer C, Customer_Channel CC, tbl_mERP_DispSchCapPerOutlet CpO, @tmpChannel tmpChn
  Where Sm.SalesmanID = BtSm.SalesmanID And 
   C.CustomerID = BtSm.CustomerID And
   CC.ChannelType = C.ChannelType And 
   CC.ChannelDesc = tmpChn.ChannelDesc And 
   CpO.ID = @OUTLETCAPID 
  Order by 2
  End
Else
  Begin
    Select Distinct Sm.SalesmanID , Sm.Salesman_Name  
    From Salesman Sm, Beat_salesman BtSm, Customer Cus, tbl_mERP_OLClass OLC, tbl_mERP_OLClassMapping OLM, tbl_mERP_DispSchCapPerOutlet CpO
    Where Sm.SalesmanID = BtSm.SalesmanID And 
     Cus.CustomerID = BtSm.CustomerID And
     Cus.CustomerID = OLM.CustomerID And 
     OLM.OLClassID = OLC.ID	And 
     OLM.Active = 1 And 
     CpO.ID = @OUTLETCAPID And 
     OLC.Channel_Type_Desc = Case CpO.Channel When N'ALL' Then OLC.Channel_Type_Desc Else CpO.Channel End And
     OLC.Outlet_Type_Desc = Case CpO.OutletType When N'ALL' Then OLC.Outlet_Type_Desc Else CpO.OutletType End And
     OLC.SubOutlet_Type_Desc = Case CpO.SubOutletType When N'ALL' Then OLC.SubOutlet_Type_Desc Else CpO.SubOutletType End
    Order by 2
  End
End
