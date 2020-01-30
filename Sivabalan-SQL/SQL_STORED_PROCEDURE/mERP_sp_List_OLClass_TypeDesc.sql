Create Procedure mERP_sp_List_OLClass_TypeDesc(@CLASSTYPE nVarchar(25))
As
Begin
	If @CLASSTYPE = 'CHANNEL'
		Select Distinct Channel_Type_Desc,Channel_Type_Code From tbl_mERP_OLClass Where Channel_Type_Active = 1 
		And Channel_Type_Desc Not In ( select Distinct [Value] From tbl_mERP_RestrictedOLClass Where TypeName = 'Channel_Type' and Status = 1)
		order by Channel_Type_Code,Channel_Type_Desc
	Else if @CLASSTYPE = 'OUTLET'
	  --Select Distinct Outlet_Type_Desc From tbl_mERP_OLClass Where Outlet_Type_Active = 1 
		Select Distinct Outlet_Type_Desc,Channel_Type_Desc,Channel_Type_Code
		From tbl_mERP_OLClass Where Outlet_Type_Active = 1 
--		And Channel_Type_Desc Not In ( select Distinct [Value] From tbl_mERP_RestrictedOLClass Where TypeName = 'Channel_Type' and Status = 1)
		And Outlet_Type_Desc Not In ( select Distinct [Value] From tbl_mERP_RestrictedOLClass Where TypeName = 'Outlet_Type' and Status = 1)
		order by Channel_Type_Code,Outlet_Type_Desc
	Else If @CLASSTYPE = 'SUBOUTLET'
	  --Select Distinct SubOutlet_Type_Desc From tbl_mERP_OLClass Where SubOutlet_Type_Active = 1 
		Select Distinct SubOutlet_Type_Desc,Channel_Type_Desc ,Channel_Type_Code
		From tbl_mERP_OLClass 
		Where SubOutlet_Type_Active = 1 And Channel_Type_Active = 1 
--		And Channel_Type_Desc Not In ( select Distinct [Value] From tbl_mERP_RestrictedOLClass Where TypeName = 'Channel_Type' and Status = 1)
--		And Outlet_Type_Desc Not In ( select Distinct [Value] From tbl_mERP_RestrictedOLClass Where TypeName = 'Outlet_Type' and Status = 1)
		And SubOutlet_Type_Desc Not In ( select Distinct [Value] From tbl_mERP_RestrictedOLClass Where TypeName = 'SubOutlet_Type' and Status = 1)
		order by Channel_Type_Code,SubOutlet_Type_Desc
	End

