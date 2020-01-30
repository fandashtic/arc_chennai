Create Procedure mERP_Sp_GetCategories(@Level int)
As
Begin
   select CategoryID,Category_name from ItemCategories where Active=1 and Level=@Level
End
