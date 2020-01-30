Create Procedure mERP_sp_List_CSOutletScopeInfo_View (@SchemeID Int, @GroupID Int,@SubGrpID Int)
As
Begin
  Declare @QPS Int 
  Select Top 1 @QPS = QPS From tbl_mERP_SchemeOutlet Where GroupID = @SubGrpID And SchemeID = @SchemeID

  Select CustScope.CustomerCode, Customer.Company_name 
  from dbo.mERP_fn_Get_CSOutletScope_View(@SchemeID,@QPS,@SubGrpID) CustScope
  Left Outer Join Customer On CustScope.CustomerCode = Customer.CustomerID
  Where GroupID = @SubGrpID Group By CustScope.CustomerCode, Customer.Company_name  
  Order by 1 
End
