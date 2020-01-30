Create Procedure mERP_sp_Get_StockReconcile_BatchPrice(@Product_Code nVarchar(50), @Batch_Number nVarchar(255))
as
Begin
  Select Top 1 
  "PKD" = Case IsNull(Convert(nVarchar(10),BP.PKD,103),'') When '' Then '' Else SubString(Convert(nVarchar(10),BP.PKD,103),4,Len(Convert(nVarchar(10),BP.PKD,103))) End, 
  "Expiry" = Case IsNull(Convert(nVarchar(10),BP.Expiry,103),'') When '' Then '' Else SubString(Convert(nVarchar(10),BP.Expiry,103),4,Len(Convert(nVarchar(10),BP.Expiry,103))) End,
  ISNull(BP.PTS,0) PTS,  ISNull(BP.PTR,0) PTR,   IsNull(BP.ECP,0) ECP,  BP.TaxSuffered, BP.GRNTaxID, Batch_code  
  From Batch_products BP, Items  
  Where BP.Product_code = Items.Product_code and
  Items.Product_Code = @Product_Code and 
  BP.Batch_Number = @Batch_Number
  Group By GRN_ID,
  Case IsNull(Convert(nVarchar(10),BP.PKD,103),'') When '' Then '' Else SubString(Convert(nVarchar(10),BP.PKD,103),4,Len(Convert(nVarchar(10),BP.PKD,103))) End, 
  Case IsNull(Convert(nVarchar(10),BP.Expiry,103),'') When '' Then '' Else SubString(Convert(nVarchar(10),BP.Expiry,103),4,Len(Convert(nVarchar(10),BP.Expiry,103))) End,  
  ISNull(BP.PTR,0), ISNull(BP.PTS,0), IsNull(BP.ECP,0), BP.TaxSuffered, BP.GRNTaxID, Batch_code
  Order by GRN_ID Desc 
End
