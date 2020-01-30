Create function mERP_fn_GetSchemeOutletDetails (@SchemeID integer)
Returns @Customers Table ( CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,SchemeID Int, GroupID Int, QPS Int )
As
Begin

Insert into @Customers 
Select Distinct C.CustomerID,S.SchemeID,So.GroupID, So.QPS 
	From 
		tbl_mERP_SchemeAbstract S ,tbl_mERP_SchemeOutlet SO ,  tbl_mERP_SchemeChannel SC ,
		tbl_mERP_SchemeOutletClass  SOLC, tbl_mERP_SchemeLoyaltyList SLList,tbl_Merp_OlclassMapping OLM,
		tbl_merp_Olclass OL,Customer C
	Where 
		S.SCHEMEID = @SchemeID AND
		S.Active = 1 And
		C.CustomerID = OLM.CustomerID And
--		C.ACTIVE = 1 AND
		OLM.OLClassID = OL.ID And
		OLM.Active = 1 And 
		S.SchemeID = SO.SchemeID And
		(SO.OutletID = C.CustomerID Or SO.OutletID = N'All')  
		And S.SchemeID = SC.SchemeID And
		SC.GroupID = SO.GroupID And
		(SC.Channel = OL.Channel_Type_Desc Or SC.Channel = N'All')  And 
		S.SchemeID = SOLC.SchemeID And
		SOLC.GroupID = SO.GroupID And
		(SOLC.OutLetClass = OL.Outlet_Type_Desc Or SOLC.OutLetClass = N'All')  And
		S.SchemeID = SLList.SchemeID And
		SLList.GroupID = SO.GroupID And
		(SLList.LoyaltyName = OL.SubOutlet_Type_Desc Or SLList.LoyaltyName = N'All')
	Group By S.SchemeID,SO.GroupID,C.CustomerID,So.QPS 
Return
End
