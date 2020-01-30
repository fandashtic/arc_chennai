Create Procedure mERP_sp_List_CSProductScopeInfo(@SchemeID Int)
As
Begin
Select ProdScope.Product_Code, Items.ProductName 
from dbo.mERP_fn_Get_CSProductScope(@SchemeID) ProdScope
Left Outer Join Items On ProdScope.Product_Code = Items.Product_Code
Group By ProdScope.Product_Code, Items.ProductName  Order by 1 
End
