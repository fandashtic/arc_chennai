Create Procedure mERP_sp_Get_OLClassID(@CHANNEL nVarchar(255), @OUTLET nVarchar(255), @SUBOUTLET nVarchar(255))  
As  
Begin  
  Declare @OLClassID Int  	
  SET @OLClassID = 0 
  Select @OLClassID = ID from tbl_mERP_OLClass  
    Where Channel_Type_Desc = @CHANNEL And Channel_Type_Active = 1  And   
    Outlet_Type_Desc = @OUTLET And Outlet_Type_Active =1  And   
    SubOutlet_Type_Desc =  @SUBOUTLET And SubOutlet_Type_Active =1
	And Channel_Type_Desc Not In (Select Value From tbl_mERP_RestrictedOLClass Where TypeName = 'Channel_Type' And Status = 1)
	And Outlet_Type_Desc Not In (Select Value From tbl_mERP_RestrictedOLClass Where TypeName =  'Outlet_Type' And Status = 1)
	And SubOutlet_Type_Desc Not In (Select Value From tbl_mERP_RestrictedOLClass Where TypeName = 'SubOutlet_Type' And Status = 1)
  Select @OLClassID
End  
