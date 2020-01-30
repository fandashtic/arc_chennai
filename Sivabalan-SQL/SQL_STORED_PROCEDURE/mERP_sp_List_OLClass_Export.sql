CREATE Procedure mERP_sp_List_OLClass_Export(@CLASSTYPE nVarchar(25))  
As  
Begin  
If @CLASSTYPE = 'CHANNEL'  
	Select Distinct Channel_Type_Desc From tbl_mERP_OLClass_Export 
	Where Channel_Type_Active = 1  
Else if @CLASSTYPE = 'OUTLET'  
	Select Distinct Outlet_Type_Desc,Channel_Type_Desc  
	From tbl_mERP_OLClass_Export Where Outlet_Type_Active = 1  
	order by Channel_Type_Desc,Outlet_Type_Desc   
Else If @CLASSTYPE = 'SUBOUTLET'  
	Select Distinct SubOutlet_Type_Desc,Channel_Type_Desc   
	From tbl_mERP_OLClass_Export   
	Where SubOutlet_Type_Active = 1 
	order by Channel_Type_Desc,SubOutlet_Type_Desc  
End 
