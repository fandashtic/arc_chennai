Create Procedure mERP_sp_validate_CSProductScope(@SchemeID Int, @ProductCode nVarchar(50))
As 
Begin
  If Exists(Select * from dbo.mERP_fn_Get_CSProductScope(@SchemeID) Where Product_code = @ProductCode)
    Select 1
  Else
    Select 0
End
