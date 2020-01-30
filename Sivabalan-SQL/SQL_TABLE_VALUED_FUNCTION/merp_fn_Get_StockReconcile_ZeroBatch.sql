Create Function merp_fn_Get_StockReconcile_ZeroBatch(@Product_Code nVarchar(50))
Returns @ZeroBatchInfo Table (Product_Code nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, Batch_Number nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)          
As
Begin
  Insert into @ZeroBatchInfo
  Select Product_Code, IsNull(Batch_number,'') 
  From Batch_Products 
  Where Product_code = @Product_Code
  Group by Product_Code, IsNull(Batch_number,'') 
  Having Sum(Quantity) = 0
  Order by IsNull(Batch_number,'') 
  Return
End
