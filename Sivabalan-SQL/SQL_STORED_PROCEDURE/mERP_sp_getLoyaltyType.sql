CREATE Procedure mERP_sp_getLoyaltyType(@CustID nVarChar(50))  
As  
Begin  
	Select OLC.SubOutlet_Type_Desc 
	From tbl_mERP_OLClass OLC, tbl_mERP_OLClassMapping OLM  
	Where OLM.CustomerID = @CustID  
	And OLM.OLClassID = OLC.ID  
	And OLM.Active = 1  
End  
