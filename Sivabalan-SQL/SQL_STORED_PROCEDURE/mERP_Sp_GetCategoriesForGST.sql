Create Procedure mERP_Sp_GetCategoriesForGST(@Level int)
As
Begin
   select CategoryID,Category_name from ItemCategories where Active=1 and Level=@Level order by Category_name
End
