Create Procedure merp_sp_List_CSDisplay_OutletCapBeat(@OUTLETCAPID INT, @SALESMANLIST nVarchar(4000)=Null)
As
Begin
Declare @tmpSalesman Table(SalesmanID Int)
If @SALESMANLIST = '%' or @SALESMANLIST = NULL
  Insert into @tmpSalesman Select SalesmanID From Salesman Where Active = 1
Else
  Insert into @tmpSalesman Select * from dbo.sp_splitIn2Rows(@SALESMANLIST, ',')

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

  Select Distinct Bt.BeatID, Bt.Description From 
  Beat Bt, Beat_salesman BtSm, Customer C, Customer_Channel CC, tbl_mERP_DispSchCapPerOutlet CpO, @tmpSalesman TmpSm, @tmpChannel tmpChn
  Where Bt.BeatID = BtSm.BeatID And 
   C.CustomerID = BtSm.CustomerID And
   CC.ChannelType = C.ChannelType And 
   CC.ChannelDesc = tmpChn.ChannelDesc And 
   CpO.ID = @OUTLETCAPID And
   BtSm.SalesmanID = TmpSm.SalesmanID
  Order by 2
  End
Else
   Select Distinct Bt.BeatID, Bt.Description  
    From Beat Bt, Beat_salesman BtSm, Customer Cus, tbl_mERP_OLClass OLC, tbl_mERP_OLClassMapping OLM, tbl_mERP_DispSchCapPerOutlet CpO, @tmpSalesman TmpSm
    Where Bt.BeatID = BtSm.BeatID And 
     Cus.CustomerID = BtSm.CustomerID And
     Cus.CustomerID = OLM.CustomerID And 
     OLM.OLClassID = OLC.ID	And 
     OLM.Active = 1 And 
     CpO.ID = @OUTLETCAPID And 
     BtSm.SalesmanID = TmpSm.SalesmanID And
     OLC.Channel_Type_Desc = Case CpO.Channel When N'ALL' Then OLC.Channel_Type_Desc Else CpO.Channel End And
     OLC.Outlet_Type_Desc = Case CpO.OutletType When N'ALL' Then OLC.Outlet_Type_Desc Else CpO.OutletType End And
     OLC.SubOutlet_Type_Desc = Case CpO.SubOutletType When N'ALL' Then OLC.SubOutlet_Type_Desc Else CpO.SubOutletType End
    Order by 2
End
