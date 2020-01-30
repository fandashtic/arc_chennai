Create Function mERP_fn_List_CSOutletScopeInfo (@SchemeID Int,@QPS Int) Returns @tbl_outlet table(outlet nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS default '')
As
Begin
  Declare @GroupId int
  
  --Declare @tbl_outlet table(outlet nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS default '')
  declare @tbl_group table (GroupId int)
	DECLARE Crsr_Cust CURSOR FOR
	select distinct groupid from tbl_mERP_SchemeOutlet where schemeid =@schemeid	and QPS=@QPS
	OPEN Crsr_Cust
	FETCH NEXT FROM Crsr_Cust into @GroupId
	WHILE (@@FETCH_STATUS <> -1)
	Begin
	  --Select Top 1 @QPS = QPS From tbl_mERP_SchemeOutlet Where GroupID = @GroupID And SchemeID = @SchemeID
	  Insert into @tbl_outlet
	  Select CustScope.CustomerCode from dbo.mERP_fn_Get_CSOutletScope(@SchemeID,@QPS) CustScope
	  Left Outer Join Customer On CustScope.CustomerCode = Customer.CustomerID
	  Where GroupID = @GroupID 
	  Group By CustScope.CustomerCode

	FETCH NEXT FROM Crsr_Cust into @GroupId 
	End
	Close Crsr_Cust
	Deallocate Crsr_Cust
	
	Return
  --Order by 1 
End
