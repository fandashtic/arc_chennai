Create Procedure mERP_sp_CatHandler_DeleteCategoryMapping(@CustCode nVarchar(50))  
as  
Begin  
  Delete From CustomerProductCategory Where CustomerID = @CustCode   
  Select @@Rowcount  
End
