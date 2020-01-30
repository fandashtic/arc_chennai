CREATE Procedure mERP_sp_getChannelClass(@CustID nVarChar(50))
As
Begin

Select OLC.Channel_Type_Desc 'ChannelType', OLC.Outlet_Type_Desc 'OutletType', OLC.SubOutlet_Type_Desc 'LoyaltyProgram'
From tbl_mERP_OLClass OLC, tbl_mERP_OLClassMapping OLM
Where OLM.CustomerID = @CustID
	And OLM.OLClassID = OLC.ID
	And OLM.Active = 1

End
