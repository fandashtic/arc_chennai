Create Procedure mERP_sp_Update_CSQPSFreeItemInfo(@SchemeID Int, @CustomerID nVarchar(50), @Product_code nVarchar(50))
As
Begin
  Update SchemeCustomerItems Set IsInvoiced = 1 Where SchemeID = @SchemeID And CustomerID = @CustomerID
  Update SchemeCustomerItems Set FreeFlag = 1 Where SchemeID = @SchemeID And CustomerID = @CustomerID And Product_Code = @Product_code
End
