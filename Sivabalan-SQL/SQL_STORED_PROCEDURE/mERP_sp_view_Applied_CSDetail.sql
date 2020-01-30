Create Procedure mERP_sp_view_Applied_CSDetail(@SchemeID Int, @CustomerCode nVarchar(50))
As
Declare @GroupID Int
Begin
--Select Top 1 @GroupID = GroupID from dbo.mERP_fn_Get_CSOutletScope(@SchemeID,0)
--Where CustomerCode Like @CustomerCode

DECLARE @QPS INT
DECLARE @FN_GROUPID INT
DECLARE @OUTLETID nVarchar(10)
DECLARE @OUTLETCLASS nVarchar(10)
DECLARE @CHANNELDESC nVarchar(10)

Create Table #tbl_QPSCustomer (CustomerCode nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS, Flag Int Default 0)
Create Table #tbl_Class_Customer (CustomerCode nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)
Create Table #tbl_Channel_Customer (CustomerCode nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)
Create Table #tbl_Loyalty_Customer (CustomerCode nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)
Create Table #tblQPSOutlet (SchemeID Int, GroupID Int, CustomerCode nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)

Set @QPS = 0

If ( Select Count(*) from tbl_mERP_SchemeLoyaltyList Where SchemeID  = IsNull(@SchemeID,0)) >= 1
Begin
Declare CurCSGroup Cursor For
Select GroupID From tbl_mERP_SchemeOutlet Where QPS = @QPS And SchemeID = @SchemeID Group By GroupID
Open CurCSGroup
Fetch From CurCSGroup Into @FN_GROUPID
While @@FETCH_STATUS = 0
Begin
If Exists(Select OutletID From tbl_mERP_SchemeOutlet Where SchemeID = @SchemeID and GroupID = @FN_GROUPID And OutletID= N'ALL')
Insert into #tbl_QPSCustomer
Select CustomerID, 0 from Customer Where CustomerCategory = 2

Else
Insert into #tbl_QPSCustomer
Select OutletID, 0 from tbl_mERP_SchemeOutlet Where SchemeID = @SchemeID and GroupID = @FN_GROUPID

IF Not Exists (Select Loyaltyname from tbl_mERP_SchemeLoyaltyList Where SchemeID = @SchemeID and GroupID = @FN_GROUPID And Loyaltyname =N'ALL')
Begin
Insert into #tbl_Loyalty_Customer
Select cust.CustomerID from Customer Cust, tbl_merp_Olclassmapping Olclassmap, tbl_merp_Olclass Olclass,
tbl_mERP_SchemeLoyaltyList CSLoyalty--CSSubChn
Where  Cust.CustomerID  = Olclassmap.CustomerID  and
Olclassmap.OlclassID = Olclass.ID and
Olclass.SubOutlet_Type_Desc = CSLoyalty.LoyaltyName And
CSLoyalty.SchemeID = @SchemeID and CSLoyalty.GroupID = @FN_GROUPID
and Olclassmap.Active = 1

Update QPSCust Set QPSCust.Flag = 1 From #tbl_QPSCustomer QPSCust, #tbl_Loyalty_Customer LoyaltyCust
Where LoyaltyCust.CustomerCode = QPSCust.CustomerCode
Delete From #tbl_QPSCustomer Where Flag = 0
End

IF Not Exists (Select OutletClass from tbl_mERP_SchemeOutletClass Where SchemeID = @SchemeID and GroupID = @FN_GROUPID And OutletClass =N'ALL')
Begin
Insert into #tbl_Class_Customer
Select cust.CustomerID from Customer Cust, tbl_merp_Olclassmapping Olclassmap, tbl_merp_Olclass Olclass,
tbl_mERP_SchemeOutletClass CSSubChn
Where  Cust.CustomerID  = Olclassmap.CustomerID  and
Olclassmap.OlclassID = Olclass.ID and
Olclass.Outlet_Type_Desc = CSSubChn.OutletClass And
CSSubChn.SchemeID = @SchemeID and CSSubChn.GroupID = @FN_GROUPID
and Olclassmap.Active = 1

Update QPSCust Set QPSCust.Flag = 2 From #tbl_QPSCustomer QPSCust, #tbl_Class_Customer ClassCust Where ClassCust.CustomerCode = QPSCust.CustomerCode
Delete From #tbl_QPSCustomer Where (Flag = 0 or Flag = 1)
End

If Not Exists(Select Channel from tbl_mERP_SchemeChannel Where SchemeID = @SchemeID and GroupID = @FN_GROUPID And Channel =N'ALL')
Begin

Insert into #tbl_Channel_Customer
Select cust.CustomerID from Customer Cust, tbl_merp_Olclassmapping Olclassmap, tbl_merp_Olclass Olclass,
tbl_mERP_SchemeChannel CSChn
Where  Cust.CustomerID  = Olclassmap.CustomerID  and
Olclassmap.OlclassID = Olclass.ID and
Olclass.Channel_Type_Desc = CSChn.Channel And
CSChn.SchemeID = @SchemeID and CSChn.GroupID = @FN_GROUPID
and Olclassmap.Active = 1

Update QPSCust Set QPSCust.Flag = 3 From #tbl_QPSCustomer QPSCust, #tbl_Channel_Customer ChnlCust Where ChnlCust.CustomerCode = QPSCust.CustomerCode
Delete From #tbl_QPSCustomer Where (Flag = 0 or Flag = 1 Or Flag = 2 )
End
Insert into #tblQPSOutlet Select @SchemeID, @FN_GROUPID, CustomerCode From #tbl_QPSCustomer

Delete From #tbl_QPSCustomer
Delete From #tbl_Channel_Customer
Delete From #tbl_Class_Customer
Delete From #tbl_Loyalty_Customer
Fetch From CurCSGroup Into @FN_GROUPID
END
Close CurCSGroup
Deallocate CurCSGroup
End
Else -- For Old Schemes Where LoyaltyList is not Implemented
Begin
Declare CurCSGroup Cursor For
Select GroupID From tbl_mERP_SchemeOutlet Where QPS = @QPS And SchemeID = @SchemeID Group By GroupID
Open CurCSGroup
Fetch From CurCSGroup Into @FN_GROUPID
While @@FETCH_STATUS = 0
Begin
If Exists(Select OutletID From tbl_mERP_SchemeOutlet Where SchemeID = @SchemeID and GroupID = @FN_GROUPID And OutletID= N'ALL')
Insert into #tbl_QPSCustomer
Select CustomerID, 0 from Customer Where CustomerCategory = 2
Else
Insert into #tbl_QPSCustomer
Select OutletID, 0 from tbl_mERP_SchemeOutlet Where SchemeID = @SchemeID and GroupID = @FN_GROUPID

IF Not Exists (Select OutletClass from tbl_mERP_SchemeOutletClass Where SchemeID = @SchemeID and GroupID = @FN_GROUPID And OutletClass =N'ALL')
Begin
Insert into #tbl_Class_Customer
Select Cust.CustomerID From Customer Cust, tbl_mERP_SchemeOutletClass CSSubChn,
(Select CM.TMDValue, CD.CustomerID
from Cust_TMD_Master CM, Cust_TMD_Details CD Where CD.TMDCtlPos = 6
Group By CM.TMDValue, CD.CustomerID) SubChn
Where SubChn.TMDValue = CSSubChn.OutletClass And
SubChn.CustomerID = Cust.SubChannelID And
CSSubChn.SchemeID = @SchemeID and CSSubChn.GroupID = @FN_GROUPID
Update QPSCust Set QPSCust.Flag = 1 From #tbl_QPSCustomer QPSCust, #tbl_Class_Customer ClassCust Where ClassCust.CustomerCode = QPSCust.CustomerCode
Delete From #tbl_QPSCustomer Where Flag = 0
End
If Not Exists(Select Channel from tbl_mERP_SchemeChannel Where SchemeID = @SchemeID and GroupID = @FN_GROUPID And Channel =N'ALL')
Begin
Insert into #tbl_Channel_Customer
Select CustomerID from Customer Cust, Customer_Channel CustChn, tbl_mERP_SchemeChannel CSChn
Where  CustChn.ChannelDesc = CSChn.Channel And
CustChn.ChannelType = Cust.ChannelType And
CSChn.SchemeID = @SchemeID and CSChn.GroupID = @FN_GROUPID
Update QPSCust Set QPSCust.Flag = 2 From #tbl_QPSCustomer QPSCust, #tbl_Channel_Customer ChnlCust Where ChnlCust.CustomerCode = QPSCust.CustomerCode
Delete From #tbl_QPSCustomer Where (Flag = 0 or Flag = 1)
End
Insert into #tblQPSOutlet Select @SchemeID, @FN_GROUPID, CustomerCode From #tbl_QPSCustomer

Delete From #tbl_QPSCustomer
Delete From #tbl_Channel_Customer
Delete From #tbl_Class_Customer
Fetch From CurCSGroup Into @FN_GROUPID
END
Close CurCSGroup
Deallocate CurCSGroup
End

Select Top 1 @GroupID = GroupID from #tblQPSOutlet
Where CustomerCode Like @CustomerCode

Select SlabID, Case SlabType When 1 Then 'Amount' When 2 Then 'Percentage' When 3 Then 'Free SKU' End as 'GivenAs',
Case IsNull(UOM,0) When 1 Then 'BUOM' When 2 Then 'UOM1' When 3 Then 'UOM2' When 4 Then 'Value' When 5 Then 'TLC' End as 'PrimaryUOM',
SlabStart, SlabEnd, IsNull(Onward,0) 'For Every', IsNull([Value],0) as 'Discount',
Case IsNull(FreeUOM,0) When 1 Then 'BUOM' When 2 Then 'UOM1' When 3 Then 'UOM2' When 4 Then 'Value' End as 'FreeUOM',
IsNull(Volume,0) 'Qty',dbo.mERP_fn_Get_FreeSKUList(slabID), IsNull(UOM,0)
From tbl_mERP_SchemeSlabDetail
Where SchemeID = @SchemeID And
GroupID = @GroupID
Order By SlabID

Drop Table #tbl_QPSCustomer
Drop Table #tbl_Channel_Customer
Drop Table #tbl_Class_Customer
Drop Table #tbl_Loyalty_Customer
Drop Table #tblQPSOutlet
End
