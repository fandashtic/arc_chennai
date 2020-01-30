Create Function mERP_fn_GetSchemeOutletDetails_HH()
Returns @NewCustomers Table ( [SchemeID] Int,[CustomerID] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,[AllotedAmount] Decimal(18,6))
As
Begin

	Declare @CurrentDate Datetime
	Set @CurrentDate = dbo.StripTimeFromDate(Cast(GetDate() as Datetime))

	IF EXISTS (Select 'x' From HHViewLog Where dbo.StripTimeFromDate(Date) = @CurrentDate)
		Insert Into @NewCustomers
		Select SchemeID,CustomerID,AllotedAmount From TmpNewCustomers
	ELSE
	BEGIN
		Declare @Customers Table (CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, SchemeID Int, GroupID Int, QPS Int )
		Insert into @Customers 
		Select Distinct C.CustomerID, S.SchemeID, So.GroupID, So.QPS 
			From 
				tbl_mERP_SchemeAbstract S ,tbl_mERP_SchemeOutlet SO ,  tbl_mERP_SchemeChannel SC ,
				tbl_mERP_SchemeOutletClass  SOLC, tbl_mERP_SchemeLoyaltyList SLList,tbl_Merp_OlclassMapping OLM,
				tbl_merp_Olclass OL,Customer C
			Where 
				S.Active = 1 And
				C.ACTIVE = 1 AND
				OLM.Active = 1 And 
				S.SchemeType Not In (3,5) and S.Active = 1   
				and dbo.StripTimeFromDate(Getdate()) Between S.ActiveFrom and S.ActiveTo
				and IsNull(S.schemestatus, 0) In ( 0, 1, 2 ) And
				C.CustomerID = OLM.CustomerID And
				OLM.OLClassID = OL.ID And
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

		Insert Into @NewCustomers        
		Select Distinct cast(SubGrp.GroupId as varchar(5))+cast(CSO.SchemeID+10000 as varchar(25)), CSO.CustomerID ,0 
		From @Customers CSO,
		tbl_mERP_SchemeSubGroup SubGrp Where SubGrp.SubGroupID = CSO.GroupID And SubGrp.SchemeID = CSO.SchemeID
	END

	Return
End
