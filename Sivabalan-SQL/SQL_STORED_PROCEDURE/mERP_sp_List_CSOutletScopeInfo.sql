Create Procedure mERP_sp_List_CSOutletScopeInfo (@SchemeID Int, @GroupID Int)
As
Begin
  Declare @QPS Int 
  Select Top 1 @QPS = QPS From tbl_mERP_SchemeOutlet Where 
  GroupID In(Select SubGroupID From tbl_mERP_SchemeSubGroup Where SchemeID = @SchemeID And GroupID = @GroupID) 
  And SchemeID = @SchemeID

  Select CustScope.CustomerCode, Customer.Company_name 
  from dbo.mERP_fn_Get_CSOutletScope(@SchemeID,@QPS) CustScope
  Left Outer Join Customer On CustScope.CustomerCode = Customer.CustomerID
  Where GroupID In(Select SubGroupID From tbl_mERP_SchemeSubGroup Where SchemeID = @SchemeID And GroupID = @GroupID) 
  Group By CustScope.CustomerCode, Customer.Company_name  
  Order by 1 
End
