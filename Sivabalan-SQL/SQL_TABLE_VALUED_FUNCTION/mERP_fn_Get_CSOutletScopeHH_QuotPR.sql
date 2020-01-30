Create function mERP_fn_Get_CSOutletScopeHH_QuotPR()
Returns @tblQPSOutlet Table(SchemeID Int, GroupID Int, CustomerCode nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS) 
As
Begin
--DECLARE @GROUPID INT 
DECLARE @OUTLETID nVarchar(10)
DECLARE @OUTLETCLASS nVarchar(10)
DECLARE @CHANNELDESC nVarchar(10)
DECLARE @tbl_QPSCustomer Table (CustomerCode nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS, Flag Int Default 0)
DECLARE @tbl_Class_Customer Table (CustomerCode nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)
DECLARE @tbl_Channel_Customer Table (CustomerCode nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)
DECLARE @tbl_Loyalty_Customer Table (CustomerCode nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)

---------------------------------------  
 declare @schemeID int   
 Declare @GroupId2 int  
 Declare TmpCursor Cursor Keyset For   
 select distinct TSA.schemeID,TSSD.Groupid from tbl_mERP_SchemeAbstract TSA  
 inner join tbl_mERP_SchemeSlabDetail TSSD on TSSD.SchemeID = TSA.SchemeID   
 where isnull(TSSD.GroupID,0)<>0 and TSA.SchemeType = 5  and TSA.Active = 1   
 and dbo.StripTimeFromDate(Getdate()) between TSA.activefrom and TSA.activeto
 and IsNull(TSA.schemestatus, 0) In ( 0, 1, 2 )
 Open TmpCursor      
 Fetch From TmpCursor Into @schemeID,@GroupId2          
While @@Fetch_Status = 0          
Begin   
	------------------------------------------  
	If Exists ( Select SchemeID from tbl_mERP_SchemeLoyaltyList Where SchemeID  = IsNull(@SCHEMEID,0)) -->= 1
	Begin
--		Declare CurCSGroup Cursor For
--		Select GroupID From tbl_mERP_SchemeOutlet Where SchemeID = @SCHEMEID Group By GroupID
--		Open CurCSGroup
--		Fetch From CurCSGroup Into @GRoupID  
--		While @@FETCH_STATUS = 0
--		Begin 
		  If Exists(Select OutletID From tbl_mERP_SchemeOutlet Where SchemeID = @SCHEMEID and GroupID = @GroupId2 And OutletID= N'ALL') 
			Insert into @tbl_QPSCustomer
			Select CustomerID, 0 from Customer Where CustomerCategory = 2  And Active = 1

		  Else
			Insert into @tbl_QPSCustomer
			Select OutletID, 0 from tbl_mERP_SchemeOutlet Outlet,Customer C Where SchemeID = @SCHEMEID and GroupID = @GroupId2
			and C.CustomerID = Outlet.OutletID And C.Active = 1
		

		  IF Not Exists (Select Loyaltyname from tbl_mERP_SchemeLoyaltyList Where SchemeID = @SCHEMEID and GroupID = @GroupId2 And Loyaltyname =N'ALL')
		  Begin 
			Insert into @tbl_Loyalty_Customer
			Select cust.CustomerID from Customer Cust, tbl_merp_Olclassmapping Olclassmap, tbl_merp_Olclass Olclass,
			tbl_mERP_SchemeLoyaltyList CSLoyalty--CSSubChn 
			Where  Cust.CustomerID  = Olclassmap.CustomerID  and
			Olclassmap.OlclassID = Olclass.ID and
			Olclass.SubOutlet_Type_Desc = CSLoyalty.LoyaltyName And 
			CSLoyalty.SchemeID = @SCHEMEID and CSLoyalty.GroupID = @GroupId2
			and Olclassmap.Active = 1 And Cust.Active = 1

 			Update QPSCust Set QPSCust.Flag = 1 From @tbl_QPSCustomer QPSCust, @tbl_Loyalty_Customer LoyaltyCust 
			Where LoyaltyCust.CustomerCode = QPSCust.CustomerCode
			Delete From @tbl_QPSCustomer Where Flag = 0
		  End 

		  IF Not Exists (Select OutletClass from tbl_mERP_SchemeOutletClass Where SchemeID = @SCHEMEID and GroupID = @GroupId2 And OutletClass =N'ALL')
		  Begin 
			Insert into @tbl_Class_Customer
			Select cust.CustomerID from Customer Cust, tbl_merp_Olclassmapping Olclassmap, tbl_merp_Olclass Olclass,
			tbl_mERP_SchemeOutletClass CSSubChn 
			Where  Cust.CustomerID  = Olclassmap.CustomerID  and
			Olclassmap.OlclassID = Olclass.ID and
			Olclass.Outlet_Type_Desc = CSSubChn.OutletClass And 
			CSSubChn.SchemeID = @SCHEMEID and CSSubChn.GroupID = @GroupId2
			and Olclassmap.Active = 1 And Cust.Active = 1


 			Update QPSCust Set QPSCust.Flag = 2 From @tbl_QPSCustomer QPSCust, @tbl_Class_Customer ClassCust Where ClassCust.CustomerCode = QPSCust.CustomerCode
			Delete From @tbl_QPSCustomer Where (Flag = 0 or Flag = 1)
		  End 

		  If Not Exists(Select Channel from tbl_mERP_SchemeChannel Where SchemeID = @SCHEMEID and GroupID = @GroupId2 And Channel =N'ALL')
		  Begin

			Insert into @tbl_Channel_Customer
			Select cust.CustomerID from Customer Cust, tbl_merp_Olclassmapping Olclassmap, tbl_merp_Olclass Olclass, 
			tbl_mERP_SchemeChannel CSChn
			Where  Cust.CustomerID  = Olclassmap.CustomerID  and
			Olclassmap.OlclassID = Olclass.ID and
			Olclass.Channel_Type_Desc = CSChn.Channel And 
			CSChn.SchemeID = @SCHEMEID and CSChn.GroupID = @GroupId2
			and Olclassmap.Active = 1 And Cust.Active = 1


			Update QPSCust Set QPSCust.Flag = 3 From @tbl_QPSCustomer QPSCust, @tbl_Channel_Customer ChnlCust Where ChnlCust.CustomerCode = QPSCust.CustomerCode
			Delete From @tbl_QPSCustomer Where (Flag = 0 or Flag = 1 Or Flag = 2 )
		  End 
		  Insert into @tblQPSOutlet Select @SCHEMEID, @GroupId2, CustomerCode From @tbl_QPSCustomer

		  Delete From @tbl_QPSCustomer
		  Delete From @tbl_Channel_Customer
		  Delete From @tbl_Class_Customer		
		  Delete From @tbl_Loyalty_Customer	
--		  Fetch From CurCSGroup Into @GroupId2  
--		END
--		Close CurCSGroup 
--		Deallocate CurCSGroup
	End
Fetch Next From TmpCursor Into @schemeID,@GroupId2  
End      
Close TmpCursor      
DeAllocate TmpCursor 

Return 
End
