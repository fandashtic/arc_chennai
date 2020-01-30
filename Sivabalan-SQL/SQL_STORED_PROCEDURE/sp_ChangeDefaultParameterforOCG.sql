Create Procedure sp_ChangeDefaultParameterforOCG
AS
BEGIN
	If (select Distinct isnull(Flag,0) from tbl_merp_Configabstract  where screenCode = 'OCGDS') = 1
	Begin
		If Not Exists(Select 'X' From parameterinfo where ParameterName = 'Category Group Type' And DefaultValue = 'Operational' And parameterID = 258)
		Begin
			Update parameterinfo Set DefaultValue = 'Operational' where ParameterName = 'Category Group Type' And DefaultValue <> 'Operational' And parameterID = 258
		End

		If Not Exists(Select 'X' From parameterinfo where ParameterName = 'Category Group Type' And DefaultValue = 'Operational' And parameterID = 259)
		Begin
			Update parameterinfo Set DefaultValue = 'Operational' where ParameterName = 'Category Group Type' And DefaultValue <> 'Operational' And parameterID = 259
		End

		If Not Exists(Select 'X' From parameterinfo where ParameterName = 'Category Group Type' And DefaultValue = 'Operational' And parameterID = 260)
		Begin
			Update parameterinfo Set DefaultValue = 'Operational' where ParameterName = 'Category Group Type' And DefaultValue <> 'Operational' And parameterID = 260
		End

		If Not Exists(Select 'X' From parameterinfo where ParameterName = 'Category Group Type' And DefaultValue = 'Operational' And parameterID = 274)
		Begin
			Update parameterinfo Set DefaultValue = 'Operational' where ParameterName = 'Category Group Type' And DefaultValue <> 'Operational' And parameterID = 274
		End

		If Not Exists(Select 'X' From parameterinfo where ParameterName = 'Category Group Type' And DefaultValue = 'Operational' And parameterID = 557)
		Begin
			Update parameterinfo Set DefaultValue = 'Operational' where ParameterName = 'Category Group Type' And DefaultValue <> 'Operational' And parameterID = 557
		End

		If Not Exists(Select 'X' From parameterinfo where ParameterName = 'Category Group Type' And DefaultValue = 'Operational' And parameterID = 558)
		Begin
			Update parameterinfo Set DefaultValue = 'Operational' where ParameterName = 'Category Group Type' And DefaultValue <> 'Operational' And parameterID = 558
		End
		-- Changes In Customer wise Category Group wise Credit Limits:
		IF Not Exists( Select 'X' From QueryParams Where QueryParamID = 103 And [Values] = 'Regular')
		Begin
			Insert Into QueryParams ([Values],QueryParamID) Values ('Regular',103)
		End
		
		IF Not Exists( Select 'X' From QueryParams Where QueryParamID = 103 And [Values] = 'Operational')
		Begin
			Insert Into QueryParams ([Values],QueryParamID) Values ('Operational',103)
		End
		Delete from ParameterInfo WHERE ParameterID = 557
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID)
		Values(557,'SalesMan',200,'$All Salesman','Salesman:Salesman_Name:Salesman_Name like ''%''',1,NUll)
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID)
		Values(557,'Beat',200,'$All Beats','(Select Distinct BeatID, SalesmanID From Beat_Salesman) BS, Beat:Description:Beat.BeatID = BS.BeatID And SalesmanID In (Select SalesmanID From Salesman Where Salesman_Name In ({1})) And [Description] Like ''%''',1,NUll)
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID)
		Values(557,'Category Group Type',200,'Operational','QueryParams:[Values]:QueryParamID IN(103) And [Values] like ''%''',Null,NUll)
		
		Update Reportdata Set Parameters = 557 WHERE Node = 'Customer Wise Category Group Wise Credit Limits'

		--**********************************************************************************************************************

		--Changes In TMD-SPM:
		Delete from ParameterInfo WHERE ParameterID = 306	
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID)
		Values(306,'Salesman Name',200,'$All Salesman','Salesman:Salesman_Name',1,0)
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID)
		Values(306,'Salesman Type',200,'$All SalesmanType','DSType_Master:DSTypeValue:DSTypeCtlPos = 1 And DSTypeValue like ''%''',1,0)
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID)
		Values(306,'Category Group Type',200,'$All','QueryParams:[Values]:QueryParamID IN(103) And [Values] like ''%''',Null,NUll)
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID)
		Values(306,'Product Hierarchy',200,'','ItemHierarchy:HierarchyName:HierarchyID IN(2,3) And HierarchyName like ''%''',0,0)
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID)
		Values(306,'Category Group',200,'$All Category Groups','ProductCategoryGroupAbstract:GroupName:GroupID In (Select * From dbo.fn_GetOCGName({$3})) and GroupName like ''%''',1,0)
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID)
		Values(306,'Category',200,'$All Categories','ItemCategories:Category_Name:CategoryID In   (Select * From dbo.fn_GetCatFrmCG_ITC_OCG({$5},{$4},Default,{$3})) and Category_Name like ''%''',1,0)
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID)
		Values(306,'From Date',7,'$MFDate',Null,0,0)
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID)
		Values(306,'To Date',10,'$Date',Null,0,0)

		--**********************************************************************************************************************
		--For TMD SPM Upload:
		If Exists(Select Distinct ParameterID From ReportParameters_Upload Where ParameterID = (Select ParameterID From Reports_To_Upload Where ReportDataID = 898))
		Begin
		Declare @ParamID as Int
		Set @ParamID = (Select Distinct ParameterID From ReportParameters_Upload Where ParameterID = (Select ParameterID From Reports_To_Upload Where ReportDataID = 898))

		Delete From ReportParameters_Upload Where ParameterID = @ParamID
		Insert  Into ReportParameters_Upload Values(@ParamID,'Salesman Name','$All Salesman',200,0)
		Insert  Into ReportParameters_Upload Values(@ParamID,'Salesman Type','$All SalesmanType',200,0)
		Insert  Into ReportParameters_Upload Values(@ParamID,'Category Group Type','$All',200,0)
		Insert  Into ReportParameters_Upload Values(@ParamID,'Product Hierarchy','',200,0)
		Insert  Into ReportParameters_Upload Values(@ParamID,'Category Group','$All Category Groups',200,0)
		Insert  Into ReportParameters_Upload Values(@ParamID,'Category','$All Salesman',200,0)
		Insert  Into ReportParameters_Upload Values(@ParamID,'From Date','$Date',7,0)
		Insert  Into ReportParameters_Upload Values(@ParamID,'To Date','$Date',10,0)
		End
		--**********************************************************************************************************************
		-- Invoice Wise Category Group Wise Report Changes:

		Delete from ParameterInfo WHERE ParameterID = 558
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID)
		Values(558,'From Date',7,'$MFDate',Null,0,0)
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID)
		Values(558,'To Date',10,'$Date',Null,0,0)
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID)
		Values(558,'Category Group Type',200,'Operational','QueryParams:[Values]:QueryParamID IN(103) And [Values] like ''%''',Null,NUll)
		Update Reportdata Set Parameters = 558 where Node = 'Collections - InvoiceWise Category GroupWise'
		
		--**********************************************************************************************************************
		--Outstanding - SalesmanWise Category GroupWise InvoiceWise
		update reportdata set forwardparam = 5 where Id = 804
		Delete from ParameterInfo where parameterId = 258
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (258, 'SalesMan', 200, '$All Salesman', 'Salesman:Salesman_Name', 1, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (258, 'Beat', 200, '$All Beats', '(Select Distinct BeatID, SalesmanID from beat_salesman) bs, Beat:Description:Beat.BeatID = bs.BeatID And SalesmanID In (Select SalesmanID From Salesman Where Salesman_Name In ({1})) And Description Like ''%''', 1, '', 0)
		Insert Into ParameterInfo (ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,DynamicParamID)
			Values(258,'Category Group Type', 200, 'Operational', 'QueryParams:[Values]:QueryParamID IN(103) And [Values] like ''%''', Null, Null)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (258, 'Category Group', 200, '$All Category Groups', 'ProductCategoryGroupAbstract:GroupName:OCGtype = ( Select Case when {3} = ''Operational'' then 1 Else 0 End ) and GroupID In (Select GroupID From tbl_merp_DSTypeCGMapping) and GroupName like ''%''', 1, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (258, 'From Date', 7, '$Date', NULL, NULL, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (258, 'To Date', 10, '$Date', NULL, NULL, '', 0)
		
		--Salesmanwise Category Groupwise Item wise Sales Analysis
		update ReportData set forwardparam = 6 where Id = 806
		Delete from ParameterInfo where parameterId = 259
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (259, 'DS Name', 200, '$All Salesman', 'Salesman:Salesman_Name:Salesman_Name like ''%''', 1, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (259, 'Beat', 200, '$All Beats', '(Select Distinct BeatID, SalesmanID From Beat_Salesman) BS, Beat:Description:Beat.BeatID = BS.BeatID And SalesmanID In (Select SalesmanID From Salesman Where Salesman_Name In ({1})) And [Description] Like ''%''', 1, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (259, 'DS Type', 200, '$All', '(select distinct "DSTypeValue"= DSTypeValue from DSTYPE_Master) DSM:DSTypeValue:DSTypevalue in (select * from dbo.fn_DSTypeValue_rpt({$1})) and DSTypeValue like ''%''',1, '', 0)
		Insert Into ParameterInfo (ParameterID, ParameterName, ParameterType, DefaultValue,AutoComplete,MultipleInput,DynamicParamID)
			Values(259,'Category Group Type', 200, 'Operational', 'QueryParams:[Values]:QueryParamID IN(103) And [Values] like ''%''', Null, Null)
		Insert Into ParameterInfo (ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (259, 'Category Group', 200, '$All Category Groups', 
			'ProductCategoryGroupAbstract:GroupName:OCGtype = ( Select Case when {4} = ''Operational'' then 1 Else 0 End ) 
			and GroupID In (Select GroupID From tbl_merp_DSTypeCGMapping 
			Where DSTypeID In (Select DSTypeID From DSType_Master Where DSTypeValue In ({3}))) And GroupName Like ''%''', 1, '', 0)
		Insert Into ParameterInfo (ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values(259, 'UOM', 200, 'UOM2', 'QueryParams:[Values]:QueryParamID in (33,37) And [Values] Not In (''UOM'') And [Values] Like ''%''', NULL, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (259, 'From Date', 7, '$Date', NULL, NULL, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (259, 'To Date', 10, '$Date', NULL, NULL, '', 0)



		--Salesmanwise Category group wise customer wise outstanding
		update ReportData set forwardparam = 4 where Id = 808
		Delete from ParameterInfo where parameterId = 260
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (260, 'SalesMan', 200, '$All Salesman', 'Salesman:Salesman_Name', 1, '',0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (260, 'Category Group Type', 200, 'Operational', 'QueryParams:[Values]:QueryParamID IN(103) And [Values] like ''%''', 0, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (260, 'Category Group', 200, '$All Category Groups', 'ProductCategoryGroupAbstract:GroupName:OCGtype = ( Select Case when {2} = ''Operational'' then 1 Else 0 End ) and GroupID In (Select GroupID From tbl_merp_DSTypeCGMapping) and GroupName like ''%''', 1, '', 0)
		Insert Into ParameterInfo (ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID)
			Values(260, 'From Date', 7, '$Date', NULL, NULL, '', 0)
		Insert Into ParameterInfo (ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (260, 'To Date', 10, '$Date', NULL, NULL, '', 0)
		Insert Into ParameterInfo (ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values(260, 'Time Bucket 1 - End time', 3, 0, NULL, NULL, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (260, 'Time Bucket 2 - End time', 3, 0, NULL, NULL, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (260, 'Time Bucket 3 - End time', 3, 0, NULL, NULL, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (260, 'Time Bucket 4 - End time', 3, 0, NULL, NULL, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (260, 'Time Bucket 5 - End time', 3, 0, NULL, NULL, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (260, 'Time Bucket 6 - End time', 3, 0, NULL, NULL, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (260, 'Time Bucket 7 - End time', 3, 0, NULL, NULL, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (260, 'Time Bucket 8 - End time', 3, 0, NULL, NULL, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (260, 'Time Bucket 9 - End time', 3, 0, NULL, NULL, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (260, 'Time Bucket 10 - End time', 3, 0, NULL, NULL, '', 0)
		--Collection - DS Wise Beat Wise
		Delete from ParameterInfo where parameterId = 274
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (274, 'Category Group Type', 200, 'Operational', 'QueryParams:[Values]:QueryParamID IN(103) And [Values] like ''%''', 0, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (274, 'Category Group', 200, '$All Category Groups', 'ProductCategoryGroupAbstract:GroupName:OCGtype = ( Select Case when {1} = ''Operational'' then 1 Else 0 End ) and GroupID In (Select GroupID From tbl_merp_DSTypeCGMapping) and GroupName like ''%''', 1, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (274, 'Product Hierarchy', 200, 'Division', 'ItemHierarchy:HierarchyName:HierarchyID in (2,3,4) and HierarchyName like ''%''', 0, '', 0)
		Insert Into ParameterInfo (ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID)
			Values (274, 'Category', 200, '$All Categories', 'ItemCategories:Category_Name:CategoryID In (Select CatId From dbo.fn_GetCGFrmCGtype_Itc({$2},{$3},{$1},Default)) 
					and Category_Name like ''%''', 1, '', 0)
		Insert Into ParameterInfo (ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (274, 'DS', 200, '$All DS', 'Salesman:Salesman_Name', 1, '', 0)
		Insert Into ParameterInfo (ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (274, 'Beat', 200, '$All Beats', 'Beat:Description:BeatID in (select * from dbo.fn_GetBeatForSalesMan_ITC({$5},Default)) 
				and [Description] like ''%''', 1, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (274, 'Document Type', 200, '$All Document Type', 'TransactionDocNumber:[DocumentType]:TransactionType=11 and DocumentType like ''%''', 0, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (274, 'Invoice From Date', 7, '', NULL, 0, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (274, 'Invoice To Date', 10, '', NULL, 0, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (274, 'Collection From Date', 7, '', NULL, 0, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (274, 'Collection To Date', 10, '', NULL, 0, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (274, 'Invoice Payment Mode', 200, '$All Values', 'QueryParams:[Values]:QueryParamID=46 And [Values] Not in (''Bank Transfer'') And [Values] Like ''%''', 0, '', 0)
		Insert Into ParameterInfo ( ParameterID, ParameterName, ParameterType, DefaultValue, AutoComplete, MultipleInput, OrderBy, DynamicParamID )
			values (274, 'Collection Payment Mode', 200, '$All Values', 'QueryParams:[Values]:QueryParamID=46 And [Values] Not in (''Credit'') And [Values] Like ''%''', 0, '', 0)

		update parameterinfo set Autocomplete='DSType_Master:DSTypeValue:DSTypeValue In(Select * From dbo.mERP_fn_Get_DSTypeForCG_RPT({$1})) And DSTypeValue like ''%''' where parameterid in (Select parameters from reportdata where iD=1117) And ParameterName='DSType'

		update reportdata set actiondata='Spr_CWGWCreditLimit_ITC_OCG' where ID = 801
		update reportdata set actiondata='spr_list_Invoicewise_Collections_ITC_OCG' where ID = 803
		update reportdata set actiondata='sp_acc_rpt_list_SMCGICustomer_OutStanding_ITC_OCG' where ID = 804
		update reportdata set actiondata='sp_acc_rpt_list_SMCGICustomer_OutStandingDetail_ITC_OCG' where ID = 805
		update reportdata set actiondata='Spr_SMWise_CGWise_ItemWise_Abstract_ITC_OCG' where ID = 806
		update reportdata set actiondata='Spr_SMWise_CGWise_ItemWise_Detail_ITC_OCG' where ID = 807
		update reportdata set actiondata='sp_acc_rpt_SMwiseCategoryGroupWise_OutStanding_ITC_OCG' where ID = 808
		update reportdata set actiondata='sp_acc_rpt_SMwiseCategoryGroupWise_OutStandingDetail_ITC_OCG' where ID = 809
		update reportdata set actiondata='spr_List_Collection_DSWise_BeatWise_Abstract_ITC_OCG' where ID = 849
		update reportdata set actiondata='spr_List_Collection_DSWise_BeatWise_Detail_ITC_OCG' where ID = 850
		update reportdata set actiondata='spr_SMan_Productivity_Measures_OCG' where ID = 898
		update reportdata set actiondata='spr_TMD_Daily_SPM_OCG' where ID = 1160

		update reports_to_upload set aliasactiondata='spr_SMan_Productivity_Measures_Upload_OCG' where ReportId=16

                update parameterinfo set Autocomplete='(Select * From dbo.fn_GetCG_Param({$4},{$3})) CG:[GroupName]' 
                where ParameterID=259 and parameterName='Category Group'

                update parameterinfo set Autocomplete='(Select * From dbo.fn_GetCG_Param({$2},default)) CG:[GroupName]' 
                where ParameterID=260 and parameterName='Category Group'

                update parameterinfo set Autocomplete='(Select * From dbo.fn_GetCG_Param({$1},default)) CG:[GroupName]' 
                where ParameterID=274 and parameterName='Category Group'	

-- OCG Master and Mapping Data Reprocess:

		Update Recd_OCG set status = 0
		Update Recd_DSType set status = 0
		Update Recd_OCGName set status = 0
		Update Recd_OCG_DSType set status = 0
		Update Recd_OCG_Product set status = 0

		Declare @RECID as Int
		Declare @Cur_OCG Cursor 
		Set @Cur_OCG = Cursor for
		Select Distinct ID From Recd_OCG Where Isnull(Status,0) = 0
		Open @Cur_OCG
		Fetch Next from @Cur_OCG into @RECID
		While @@fetch_status =0
			Begin
				Exec mERP_sp_ProcessOCG @RECID
				Fetch Next from @Cur_OCG into @RECID
			End
		Close @Cur_OCG
		Deallocate @Cur_OCG
		
-- Reset Customer Credit Limit Breakup process:
	Update CustomerCreditLimit set CreditTermDays = -1,CreditLimit = -1,NoOfBills = -1 Where GroupID In 
	(Select Distinct GroupID from ProductCategoryGroupAbstract Where Isnull(OCGType,0) = 1 And Isnull(Active,0) = 1)
-- Inactive existing Category Group which are non ocg and non GR*
	Update ProductCategoryGroupAbstract set active=0 where Isnull(OCGType,0) = 0 and GroupName not in ('GR1','GR2','GR3','GR4')

--Category Group Update Process For GGDR Changes:FITC-4462	
	If (Select Top 1 isnull(Flag,0) from tbl_merp_Configabstract Where ScreenCode = 'OCGDS') = 1
	Begin
		Update GGDRData Set CategoryGroup = Null
		Update TmpGGDRSKUDetails Set CategoryGroup = Null

		Update G Set G.CategoryGroup = O.GroupName From GGDRData G,OCGItemMaster O
		Where G.SystemSKU = O.SystemSKU

		Update G Set G.CategoryGroup = O.GroupName From TmpGGDRSKUDetails G,OCGItemMaster O
		Where G.Product_Code = O.SystemSKU
	End
	
	End
END
