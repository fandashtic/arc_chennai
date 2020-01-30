Create Procedure Sp_PM_GateUOB_Post
As
BEGIN --Main
Set Dateformat DMY
Declare @LastClosedDate DateTime
Declare @Month3To DateTime

--Last Closed Day
Set @LastClosedDate = (Select Convert(Nvarchar(10),LastInventoryUpload,103) From Setup)
--Required To Date of Data Post
Set @Month3To  = DateAdd(dd,-1,Cast('01/' + Right(Convert(nVarChar(10),GETDATE(),103),7)  As DateTime))

IF @LastClosedDate >= @Month3To 
Begin --Condition1 Must day closed upto last month
	
	Declare @GateUOMType Int 
	Set @GateUOMType = 10  --(Gate-UOM ParameterType)
	Declare @CurPeriod nVarChar(8)	
	Set @CurPeriod = REPLACE(RIGHT(CONVERT(VARCHAR(11), GETDATE(), 106), 8), ' ', '-')
	
	Select PM.PMID, PM.CGGroups, PMDS.DSType, PMParam.DSTypeID, PMParam.ParamID, 
	TargetTrashole =(Select IsNull(Max(PMPF.TargetThreshold),0)  From tbl_mERP_PMParamFocus PMPF Where PMPF.ParamID = PMParam.ParamID)
	Into #tmpPMIDs  
	From tbl_mERP_PMMaster PM 
	Join tbl_mERP_PMDSType PMDS On PM.PMID = PMDS.PMID 
	Join tbl_mERP_PMParam PMParam on PMDS.DSTypeID  = PMParam.DSTypeID and PMParam.Frequency = 2 
	Where PM.Period  = @CurPeriod And Active = 1 	
	And PM.PMID not in (Select Distinct PMID from PM_GateUOB_Data Where PMMonth = @CurPeriod)
	And PMParam.ParameterType  = @GateUOMType

	IF (Select Count(PMID) from #tmpPMIDs ) > 0
	Begin --Condition2 At least one PMID found to data post				
		
		Declare @Month3From DateTime
		Declare @Month2To DateTime
		Declare @Month2From DateTime
		Declare @Month1To DateTime
		Declare @Month1From DateTime
		
		set @Month3From = Cast('01/' + Right(Convert(nVarChar(10),@Month3To,103),7)  As DateTime)
		Set @Month2To  = DateAdd(dd,-1,Cast('01/' + Right(Convert(nVarChar(10),@Month3From,103),7)  As DateTime))
		set @Month2From = Cast('01/' + Right(Convert(nVarChar(10),@Month2To,103),7)  As DateTime)
		Set @Month1To  = DateAdd(dd,-1,Cast('01/' + Right(Convert(nVarChar(10),@Month2To,103),7)  As DateTime))
		set @Month1From = Cast('01/' + Right(Convert(nVarChar(10),@Month1To,103),7)  As DateTime)

		Select * Into #InvAbs From InvoiceAbstract IA
		Where dbo.StripTimeFromDate(IA.InvoiceDate) Between dbo.StripTimeFromDate(@Month1From)  And dbo.StripTimeFromDate(@Month3To)
		And IA.InvoiceType in (1,3)
		And IsNull(IA.Status,0) & 128 = 0
		Select * Into #InvDet From InvoiceDetail Where Amount > 0 and InvoiceID in (Select InvoiceID From #InvAbs)
		
		Declare @OCG int
		Select @OCG=isnull(Flag,0) From Tbl_merp_Configabstract Where ScreenCode = 'OCGDS' And ScreenName ='OperationalCategoryGroup'

		Declare @PMID Int
		Declare @PMCGGrp nVarChar(50)
		Declare @PMDSType nVarChar(100)
		Declare @PMDSTypeID Int
		Declare @PMParamID Int
		Declare @TargetTrashole decimal(18,6)	
		
		--Select * from #tmpPMIDs  
		
		Declare rsPMIDs Cursor for Select PMID,CGGroups, DSType, DSTypeID, ParamID, TargetTrashole From #tmpPMIDs
		Open rsPMIDs
		Fetch Next from rsPMIDs Into @PMID, @PMCGGrp, @PMDSType, @PMDSTypeID, @PMParamID, @TargetTrashole
		While @@Fetch_Status = 0
		Begin --PMIDs Loop			
			
		 Create Table #tmpPMCGItems(
		 CGrp  nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
		 Comp nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
		 Div nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
		 SubCat nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
		 MSKU nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
		 Product_Code  nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)

		Create Table #tmpPMDefDS (
		SalesmanID int, Salesman_Name nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
		PMDSTypeID Int, DSTypeValue nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,CGMapID int)


		 If @OCG = 1
		  Begin
			Create Table #TmpGroup (GroupID Int)
			Create table #TmpItems(Product_Code nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,Category_Name nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
			Declare @GroupID nVarChar(50)
			
			Insert into #TmpGroup (GroupID)
			Select Distinct GroupID from ProductCategoryGroupAbstract  
			where GroupID In (Select DSTCG.GroupID from tbl_mERP_DSTypeCGMapping DSTCG,DSType_Master DSM Where DSTCG.DSTypeID=DSM.DSTypeID and DSM.DSTypeValue in 
			(Select PMDS.DSType From tbl_mERP_PMDSType PMDS,tbl_mERP_PMParam PMParam Where PMParam.DSTypeID=PMDS.DSTypeID
			And PMParam.ParamID=@PMParamID) And DSTCG.Active = 1 and isnull(DSM.active,0)=1 and isnull(DSM.OCGType,0)=1)
			and isnull(ProductCategoryGroupAbstract.active,0)=1 and isnull(ProductCategoryGroupAbstract.OCGType,0)=1
			
			Declare AllGroup Cursor For select Distinct cast(GroupId as nvarchar(50)) from #TmpGroup
			Open AllGroup
			Fetch from AllGroup into @GroupID
			While @@fetch_status=0
			Begin
				Insert Into #TmpItems (Product_Code,Category_name)	
				Select FN.Product_code,IC2.Category_Name from dbo.Fn_GetOCGSKU(@GroupID) FN,ItemCategories IC4,ItemCategories IC3,ItemCategories IC2
				Where FN.CategoryID=IC4.CategoryID
				And IC4.Parentid=IC3.CategoryID
				And IC3.ParentID=IC2.CategoryID
				Fetch next from AllGroup into @GroupID	
			End
			Close AllGroup
			Deallocate AllGroup		
		    Drop Table #TmpGroup  		    
			
			Insert Into #tmpPMCGItems (CGrp, Comp, Div, SubCat, MSKU, Product_Code)
			Select CGrp=DivMap.CategoryGroup, Comp=Comp.Category_Name, Div=Div.Category_Name, SubCat=SubCat.Category_Name, MSKU=MSKU.Category_Name,  Product_Code =I.Product_Code 
			From ItemCategories MSKU
			Join Items I On I.CategoryID = MSKU.CategoryID
			Join ItemCategories SubCat on SubCat.CategoryID  = MSKU.ParentID And SubCat.Level = 3
			Join ItemCategories Div on Div.CategoryID = SubCat.ParentID And Div.Level = 2
			Join ItemCategories Comp on Comp.CategoryID = Div.ParentID And Comp.Level = 1
			Join tblCGDivMapping DivMap on DivMap.Division = Div.Category_Name 			
			And CategoryGroup in (Select ItemValue From dbo.sp_SplitIn2Rows(@PMCGGrp,'|') )
			Join #TmpItems OCGItems On OCGItems.Category_name = DivMap.Division And OCGItems.Product_Code = I.Product_Code			
			Join tbl_mERP_PMParamFocus PMFocus On PMFocus.ProdCat_Code  =  (Case 
			When PMFocus.ProdCat_Level = 1 Then Comp.Category_Name  
			When PMFocus.ProdCat_Level = 2 Then Div.Category_Name
			When PMFocus.ProdCat_Level = 3 Then SubCat.Category_Name
			When PMFocus.ProdCat_Level = 4 Then MSKU.Category_Name
			When PMFocus.ProdCat_Level = 5 Then I.Product_Code 
			Else PMFocus.ProdCat_Code End) And PMFocus.ParamID = @PMParamID 
			Where MSKU.Level  = 4
						
			Drop Table #TmpItems			
			
			Insert into #tmpPMDefDS(SalesmanID, Salesman_Name, PMDSTypeID, DSTypeValue)
			Select Distinct SM.SalesManID, SM.Salesman_Name, PMDS.DSTypeID, PMDS.DSType			
			From tbl_mERP_PMDSType PMDS, DSTYpe_Master DSM, SalesMan SM, DSType_Details DSTDet,
			ProductCategoryGroupAbstract CGMas , 
			--@tmpPMCG PMCG, 
			tbl_mERP_DSTypeCGMapping CGMap, tbl_mERP_PMParam PMparam			
			Where PMDS.DSTypeID = PMParam.DSTypeID 
			And DSM.DSTypeValue =PMDS.DSType 
			And DSM.DSTypeCtlPos = 1 
			And DSM.DSTypeID = DSTDet.DSTypeID  
			And DSM.DSTypeCtlPos = DSTDet.DSTypeCtlPos
			And SM.SalesmanID= DSTDet.SalesmanID
			And SM.Active = 1 
			--And CGMas.GroupName = PMCG.CatGrp
			And CGMas.GroupID = CGMap.GroupID
			And CGMap.Active = 1
			And DSM.DSTypeID = CGMap.DSTypeID
			And PMparam.ParamID = @PMParamID			
			And isnull(DSM.OCGType,0)=1
			And isnull(CGMas.OCGType,0)=1
			And isnull(CGMas.Active,0)=1
			And isnull(DSM.Active,0)=1			
			--And SM.SalesmanID Not in (Select SalesmanID from tbl_mERP_PMetric_TargetDefn Where ParamId=@ParamId and Active = 1) 
		  End
		 Else -- @OCG=0
		  Begin
			Insert Into #tmpPMCGItems (CGrp, Comp, Div, SubCat, MSKU, Product_Code) 
			Select CGrp=DivMap.CategoryGroup, Comp=Comp.Category_Name, Div=Div.Category_Name, SubCat=SubCat.Category_Name, MSKU=MSKU.Category_Name,  Product_Code =I.Product_Code 
			From ItemCategories MSKU
			Join Items I On I.CategoryID = MSKU.CategoryID
			Join ItemCategories SubCat on SubCat.CategoryID  = MSKU.ParentID And SubCat.Level = 3
			Join ItemCategories Div on Div.CategoryID = SubCat.ParentID And Div.Level = 2
			Join ItemCategories Comp on Comp.CategoryID = Div.ParentID And Comp.Level = 1
			Join tblCGDivMapping DivMap on DivMap.Division = Div.Category_Name 
			And CategoryGroup in (Select ItemValue From dbo.sp_SplitIn2Rows(@PMCGGrp,'|') )
			Join tbl_mERP_PMParamFocus PMFocus On PMFocus.ProdCat_Code  =  (Case 
			When PMFocus.ProdCat_Level = 1 Then Comp.Category_Name  
			When PMFocus.ProdCat_Level = 2 Then Div.Category_Name
			When PMFocus.ProdCat_Level = 3 Then SubCat.Category_Name
			When PMFocus.ProdCat_Level = 4 Then MSKU.Category_Name
			When PMFocus.ProdCat_Level = 5 Then I.Product_Code 
			Else PMFocus.ProdCat_Code End) And PMFocus.ParamID = @PMParamID 
			Where MSKU.Level  = 4					

			Insert into #tmpPMDefDS(SalesmanID, Salesman_Name, PMDSTypeID, DSTypeValue)			
			Select Distinct SM.SalesManID, SM.Salesman_Name, PMDS.DSTypeID, PMDS.DSType			
			From tbl_mERP_PMDSType PMDS, DSTYpe_Master DSM, SalesMan SM, DSType_Details DSTDet,
			ProductCategoryGroupAbstract CGMas , (Select ItemValue From dbo.sp_SplitIn2Rows(@PMCGGrp,'|')) PMCG, 
			tbl_mERP_DSTypeCGMapping CGMap, tbl_mERP_PMParam PMparam
			Where PMDS.DSTypeID = PMParam.DSTypeID 
			And DSM.DSTypeValue =PMDS.DSType 
			And DSM.DSTypeCtlPos = 1 
			And DSM.DSTypeID = DSTDet.DSTypeID  
			And DSM.DSTypeCtlPos = DSTDet.DSTypeCtlPos
			And SM.SalesmanID= DSTDet.SalesmanID
			And SM.Active = 1 
			And CGMas.GroupName = PMCG.ItemValue
			And CGMas.GroupID = CGMap.GroupID
			And CGMap.Active = 1
			And DSM.DSTypeID = CGMap.DSTypeID
			And PMparam.ParamID = @PMParamID			
			And isnull(DSM.OCGType,0)=0
			And isnull(CGMas.OCGType,0)=0
			And isnull(CGMas.Active,0) = 1
			And isnull(DSM.Active,0) = 1			
			--And SM.SalesmanID Not in (Select SalesmanID from tbl_mERP_PMetric_TargetDefn Where ParamId=@ParamId and Active = 1) 
		  End
		  
			--Select PMID=pmdsdef.pmid,PMPAram= PMDSDef.ParamID,   DSID=PMDSDef.salesmanid 
			--Into #tmpPMDefDS
			--From tbl_mERP_PMetric_TargetDefn PMDSDef
			--Join tbl_mERP_PMDSType PMDST on PMDST.DSTypeID = PMDSDef.PMDSTypeID 			
			--Join DSType_Master DST On DST.DSTypeId = PMDSDef.DSTypeID And DST.DSTypeCtlPos = 1 
			--Join DSType_Details DSD On DSD.DSTypeId = DST.DSTypeId And DSD.SalesManID = PMDSDef.SalesmanID   And  DSD.DSTypeCtlPos = 1 
			--Join Salesman SM on sm.SalesmanID = PMDSDef.SalesmanID 
			--Where PMDSDef.Active = 1 And PMDSDef.PMID = @PMID  And PMDSDef.ParamID = @PMParamID  
			
			--Select * from #tmpPMCGItems 
			--Select * from #tmpPMDefDS			
			--Select @PMID ,@PMCGGrp  ,@PMDSType , @PMDSTypeID , @PMParamID, @TargetTrashole, @OCG As OCGFlag
			
			Insert into PM_GateUOB_Data (PMID,PMDSTypeID,PMParamID,DSID,PMMonth,Outletcount)
			Select @PMID, @PMDSTypeID, @PMParamID, DSSalesSum.DSID, @CurPeriod , Count(Distinct DSSalesSum.OutletID) 
			From (Select SalMonth=Right(Convert(nVarChar(10),IA.InvoiceDate,103),7),DSID=IA.SalesmanID 
			,OutletID = IA.CustomerID,SalVal=SUM(Amount) ,TargetTrashole=@TargetTrashole			
			From #InvAbs IA 
			Join #InvDet ID on IA.InvoiceID = ID.InvoiceID 
			Join #tmpPMCGItems ITs On Its.Product_Code = ID.Product_Code 
			Join #tmpPMDefDS DSs On DSs.SalesmanID = IA.SalesmanID 
			Join Beat_Salesman BS On BS.SalesmanID = DSs.SalesmanID And BS.CustomerID = IA.CustomerID
			--Where IA.InvoiceDate Between @Month1From  And @Month3To 
			--And IA.InvoiceType in (1,3)
			--And IsNull(IA.Status,0) & 128 = 0
			Group by Right(Convert(nVarChar(10),IA.InvoiceDate,103),7),IA.SalesmanID ,IA.CustomerID
			Having SUM(Amount) >= @TargetTrashole
			--Order By Right(Convert(nVarChar(10),IA.InvoiceDate,103),7),IA.SalesmanID ,IA.CustomerID
			) DSSalesSum
			Group By DSSalesSum.DSID

			Drop Table #tmpPMCGItems
			Drop Table #tmpPMDefDS
			
			Fetch Next from rsPMIDs Into @PMID, @PMCGGrp, @PMDSType, @PMDSTypeID, @PMParamID, @TargetTrashole
		End	 --PMIDs Loop
		Close rsPMIDs
		Deallocate rsPMIDs
		
		Drop Table #InvAbs
		Drop Table #InvDet
	End --Condition2
	--Else
	--	Begin
		Drop Table #tmpPMIDs  
	--	Select 'No PMID found to Post for ',@CurPeriod 
	--	End
End --Condition1
--Else
--	Select  'Close Day Condition Fail for' ,@LastClosedDate,@Month3From
Update DayCloseModules Set DayCloseDate = (Select Top 1 LastInventoryUpload From Setup) Where Module = 'PM GateUOB' And Priority = 11
END --Main
