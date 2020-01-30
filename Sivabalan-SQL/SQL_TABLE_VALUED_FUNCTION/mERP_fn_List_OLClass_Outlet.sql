Create Function mERP_fn_List_OLClass_Outlet(@Channel_Type nVarchar(255))
Returns @Outlet_Type Table (Outlet_Type_Code nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS, Outlet_Type_Desc nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
as
Begin
  Insert into @Outlet_Type
  Select Outlet_Type_Code, Outlet_Type_Desc
  From tbl_mERP_OLClass 
  Where Outlet_Type_Active = 1 And Channel_Type_Desc Like @Channel_Type
  Group By Outlet_Type_Desc, Outlet_Type_Code
  Return 
End
