Create Procedure mERP_sp_Check_IsCSQPSFreeItemScheme(@SchemeID Int, @CustomerID nVarchar(50))
As
Begin
  If Exists(Select SlabID from SchemeCustomerITems where SchemeID = @SchemeID and CustomerID = @CustomerID)
    Select 1
  Else
    Select 0
End
