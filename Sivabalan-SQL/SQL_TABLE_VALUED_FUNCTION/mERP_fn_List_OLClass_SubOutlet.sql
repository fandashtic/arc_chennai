Create Function mERP_fn_List_OLClass_SubOutlet(@Channel_Type nVarchar(255), @Outlet_Type nVarchar(255))
Returns @SubOutlet_Type Table (SubOutlet_Type_Code nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS, SubOutlet_Type_Desc nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
as
Begin
  Insert into @SubOutlet_Type
  Select SubOutlet_Type_Code, SubOutlet_Type_Desc
  From tbl_mERP_OLClass 
  Where SubOutlet_Type_Active = 1 And Channel_Type_Desc Like @Channel_Type And Outlet_Type_Desc Like @Outlet_Type
  Group By SubOutlet_Type_Desc, SubOutlet_Type_Code
  Return 
End
