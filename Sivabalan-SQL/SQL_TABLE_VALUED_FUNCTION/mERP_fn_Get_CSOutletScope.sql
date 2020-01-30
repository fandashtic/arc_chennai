Create function [dbo].[mERP_fn_Get_CSOutletScope](@SCHEMEID Int, @QPS Int=1)
Returns @tblQPSOutlet Table(SchemeID Int, GroupID Int, CustomerCode nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS) 
As
Begin
DECLARE @GROUPID INT 
DECLARE @OUTLETID nVarchar(10)
DECLARE @OUTLETCLASS nVarchar(10)
DECLARE @CHANNELDESC nVarchar(10)
DECLARE @tbl_QPSCustomer Table (CustomerCode nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS, Flag Int Default 0)
DECLARE @tbl_Class_Customer Table (CustomerCode nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)
DECLARE @tbl_Channel_Customer Table (CustomerCode nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)
DECLARE @tbl_Loyalty_Customer Table (CustomerCode nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)


If ( Select Count(*) from tbl_mERP_SchemeLoyaltyList Where SchemeID  = IsNull(@SCHEMEID,0)) >= 1
Begin
	Declare CurCSGroup Cursor For
	Select GroupID From tbl_mERP_SchemeOutlet Where QPS = @QPS And SchemeID = @SCHEMEID Group By GroupID
	Open CurCSGroup
	Fetch From CurCSGroup Into @GRoupID  
	While @@FETCH_STATUS = 0
	Begin 
	  If Exists(Select OutletID From tbl_mERP_SchemeOutlet Where SchemeID = @SCHEMEID and GroupID = @GRoupID And OutletID= N'ALL') 
		Insert into @tbl_QPSCustomer
		Select CustomerID, 0 from Customer Where CustomerCategory = 2 

	  Else
		Insert into @tbl_QPSCustomer
		Select OutletID, 0 from tbl_mERP_SchemeOutlet Where SchemeID = @SCHEMEID and GroupID = @GRoupID

	  IF Not Exists (Select Loyaltyname from tbl_mERP_SchemeLoyaltyList Where SchemeID = @SCHEMEID and GroupID = @GRoupID And Loyaltyname =N'ALL')
	  Begin 
		Insert into @tbl_Loyalty_Customer
		Select cust.CustomerID from Customer Cust, tbl_merp_Olclassmapping Olclassmap, tbl_merp_Olclass Olclass,
		tbl_mERP_SchemeLoyaltyList CSLoyalty--CSSubChn 
		Where  Cust.CustomerID  = Olclassmap.CustomerID  and
		Olclassmap.OlclassID = Olclass.ID and
		Olclass.SubOutlet_Type_Desc = CSLoyalty.LoyaltyName And 
		CSLoyalty.SchemeID = @SCHEMEID and CSLoyalty.GroupID = @GRoupID
		and Olclassmap.Active = 1

 		Update QPSCust Set QPSCust.Flag = 1 From @tbl_QPSCustomer QPSCust, @tbl_Loyalty_Customer LoyaltyCust 
		Where LoyaltyCust.CustomerCode = QPSCust.CustomerCode
		Delete From @tbl_QPSCustomer Where Flag = 0
	  End 

	  IF Not Exists (Select OutletClass from tbl_mERP_SchemeOutletClass Where SchemeID = @SCHEMEID and GroupID = @GRoupID And OutletClass =N'ALL')
	  Begin 
		Insert into @tbl_Class_Customer
		Select cust.CustomerID from Customer Cust, tbl_merp_Olclassmapping Olclassmap, tbl_merp_Olclass Olclass,
		tbl_mERP_SchemeOutletClass CSSubChn 
		Where  Cust.CustomerID  = Olclassmap.CustomerID  and
		Olclassmap.OlclassID = Olclass.ID and
		Olclass.Outlet_Type_Desc = CSSubChn.OutletClass And 
		CSSubChn.SchemeID = @SCHEMEID and CSSubChn.GroupID = @GRoupID
		and Olclassmap.Active = 1

 		Update QPSCust Set QPSCust.Flag = 2 From @tbl_QPSCustomer QPSCust, @tbl_Class_Customer ClassCust Where ClassCust.CustomerCode = QPSCust.CustomerCode
		Delete From @tbl_QPSCustomer Where (Flag = 0 or Flag = 1)
	  End 

	  If Not Exists(Select Channel from tbl_mERP_SchemeChannel Where SchemeID = @SCHEMEID and GroupID = @GRoupID And Channel =N'ALL')
	  Begin

		Insert into @tbl_Channel_Customer
		Select cust.CustomerID from Customer Cust, tbl_merp_Olclassmapping Olclassmap, tbl_merp_Olclass Olclass, 
		tbl_mERP_SchemeChannel CSChn
		Where  Cust.CustomerID  = Olclassmap.CustomerID  and
		Olclassmap.OlclassID = Olclass.ID and
		Olclass.Channel_Type_Desc = CSChn.Channel And 
		CSChn.SchemeID = @SCHEMEID and CSChn.GroupID = @GRoupID
		and Olclassmap.Active = 1

		Update QPSCust Set QPSCust.Flag = 3 From @tbl_QPSCustomer QPSCust, @tbl_Channel_Customer ChnlCust Where ChnlCust.CustomerCode = QPSCust.CustomerCode
		Delete From @tbl_QPSCustomer Where (Flag = 0 or Flag = 1 Or Flag = 2 )
	  End 
	  Insert into @tblQPSOutlet Select @SCHEMEID, @GRoupID, CustomerCode From @tbl_QPSCustomer

	  Delete From @tbl_QPSCustomer
	  Delete From @tbl_Channel_Customer
	  Delete From @tbl_Class_Customer		
	  Delete From @tbl_Loyalty_Customer	
	  Fetch From CurCSGroup Into @GRoupID  
	END
	Close CurCSGroup 
	Deallocate CurCSGroup
End
Else -- For Old Schemes Where LoyaltyList is not Implemented
Begin
	Declare CurCSGroup Cursor For
	Select GroupID From tbl_mERP_SchemeOutlet Where QPS = @QPS And SchemeID = @SCHEMEID Group By GroupID
	Open CurCSGroup
	Fetch From CurCSGroup Into @GRoupID  
	While @@FETCH_STATUS = 0
	Begin 
	  If Exists(Select OutletID From tbl_mERP_SchemeOutlet Where SchemeID = @SCHEMEID and GroupID = @GRoupID And OutletID= N'ALL') 
		Insert into @tbl_QPSCustomer
		Select CustomerID, 0 from Customer Where CustomerCategory = 2 
	  Else
		Insert into @tbl_QPSCustomer
		Select OutletID, 0 from tbl_mERP_SchemeOutlet Where SchemeID = @SCHEMEID and GroupID = @GRoupID

	  IF Not Exists (Select OutletClass from tbl_mERP_SchemeOutletClass Where SchemeID = @SCHEMEID and GroupID = @GRoupID And OutletClass =N'ALL')
	  Begin 
		Insert into @tbl_Class_Customer
		Select Cust.CustomerID From Customer Cust, tbl_mERP_SchemeOutletClass CSSubChn, 
						 (Select CM.TMDValue, CD.CustomerID
						  from Cust_TMD_Master CM, Cust_TMD_Details CD Where CD.TMDCtlPos = 6
						  Group By CM.TMDValue, CD.CustomerID) SubChn
		Where SubChn.TMDValue = CSSubChn.OutletClass And 
		SubChn.CustomerID = Cust.SubChannelID And 
		CSSubChn.SchemeID = @SCHEMEID and CSSubChn.GroupID = @GRoupID 
 		Update QPSCust Set QPSCust.Flag = 1 From @tbl_QPSCustomer QPSCust, @tbl_Class_Customer ClassCust Where ClassCust.CustomerCode = QPSCust.CustomerCode
		Delete From @tbl_QPSCustomer Where Flag = 0
	  End 
	  If Not Exists(Select Channel from tbl_mERP_SchemeChannel Where SchemeID = @SCHEMEID and GroupID = @GRoupID And Channel =N'ALL')
	  Begin
		Insert into @tbl_Channel_Customer
		Select CustomerID from Customer Cust, Customer_Channel CustChn, tbl_mERP_SchemeChannel CSChn
		Where  CustChn.ChannelDesc = CSChn.Channel And 
		CustChn.ChannelType = Cust.ChannelType And 
		CSChn.SchemeID = @SCHEMEID and CSChn.GroupID = @GRoupID 
		Update QPSCust Set QPSCust.Flag = 2 From @tbl_QPSCustomer QPSCust, @tbl_Channel_Customer ChnlCust Where ChnlCust.CustomerCode = QPSCust.CustomerCode
		Delete From @tbl_QPSCustomer Where (Flag = 0 or Flag = 1)
	  End 
	  Insert into @tblQPSOutlet Select @SCHEMEID, @GRoupID, CustomerCode From @tbl_QPSCustomer

	  Delete From @tbl_QPSCustomer
	  Delete From @tbl_Channel_Customer
	  Delete From @tbl_Class_Customer		
	  Fetch From CurCSGroup Into @GRoupID  
	END
	Close CurCSGroup 
	Deallocate CurCSGroup
End

Return 
End
