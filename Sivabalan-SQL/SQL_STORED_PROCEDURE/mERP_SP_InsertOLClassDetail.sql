Create Procedure mERP_SP_InsertOLClassDetail
@ID int , @Channel_Type_Code nVarchar(15), @Channel_Type_Desc nVarchar(255), @Channel_Type_Active nVarchar(1), 
@Outlet_Type_Code nVarchar(15), @Outlet_Type_Desc nVarchar(255), @Outlet_Type_Active nVarchar(1), 
@SubOutlet_Type_Code nVarchar(15), @SubOutlet_Type_Desc nVarchar(255), @SubOutlet_Type_Active nVarchar(1), 
@Status int = 0
AS
Insert Into tbl_mERP_RecdOLClassDetail(RecdID, Channel_Type_Code, Channel_Type_Desc, Channel_Type_Active, 
Outlet_Type_Code, Outlet_Type_Desc, Outlet_Type_Active, SubOutlet_Type_Code, SubOutlet_Type_Desc, SubOutlet_Type_Active,
Status)
Values (@ID, @Channel_Type_Code, @Channel_Type_Desc, @Channel_Type_Active, 
@Outlet_Type_Code, @Outlet_Type_Desc, @Outlet_Type_Active, @SubOutlet_Type_Code, @SubOutlet_Type_Desc, 
@SubOutlet_Type_Active, @Status)
