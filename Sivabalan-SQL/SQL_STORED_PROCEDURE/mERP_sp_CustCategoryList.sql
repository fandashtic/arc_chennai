Create Procedure mERP_sp_CustCategoryList (@CustID nVarChar(30))
As
Select CategoryID from CustomerProductCategory
Where CustomerID = @CustID And Active = 1
