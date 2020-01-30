CREATE Function mERP_FN_get_PMOutletAch_TargetDefn_AUTOPOST(@PMetricID Int, @ParamID Int, @EditLock Int)
Returns @Result Table(SalesManID int NULL,
			SalesMan_Name nvarchar(225) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			DSTypeValue nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			Target decimal(18, 6) NULL,
			MaxPoints decimal(18, 6) NULL,
			PMID int NULL,
			PMDSTypeID int NULL,
			ParamID int NULL,			
			CGMapID int NULL,
			TargetDefnID int NOT NULL,
			LastupdatedDate Datetime,AutoPostflag int,SaveFlag int)
As
Begin 

	/* If User is allowed to change the setting then do the following process*/
	if @EditLock = 0
	Begin
		Declare @tmpDSTarget as Table(SalesmanID int, Salesman_Name nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
									  PMDSTypeID Int, DSTypeValue nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, 									  
									  MaxPoints Decimal(18,6), CGMapID int)

		Declare @TempFocusItems as Table (
				ProductLevel Int,
				ProductName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
				CategoryID Int,
				PMProductName Nvarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS)


		Declare @tmpPMCG as Table(CatGrpID int, CatGrp nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
		/*To get the Category Group even if its GC1 & CG3*/
		Declare @PMCGGroup as nVarchar(510)		
		
		Declare @Tempdata as Table (SalesManID int NULL,
			SalesMan_Name nvarchar(225) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			DSTypeValue nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			Target decimal(18, 6) NULL,
			MaxPoints decimal(18, 6) NULL,
			PMID int NULL,
			PMDSTypeID int NULL,
			ParamID int NULL,			
			FocusID int NULL,
			CGMapID int NULL,
			TargetDefnID int NOT NULL,
			LastupdatedDate Datetime,AutoPostflag int,SaveFlag int)

		Declare @Period as Nvarchar(255)
		Declare @OCG int
		Select @OCG=isnull(Flag,0) From Tbl_merp_Configabstract Where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup'
		--Declare @PreviousMonthName as Nvarchar(25)
		Declare @ProductLevel As Int
		Declare @ProductName As Nvarchar(500)
		Select @PMCGGroup = CGGroups, @Period = Period From tbl_mERP_PMMaster Where PMID =  @PMetricID 
		Insert into @tmpPMCG (CatGrp)
		Select LTRIM(RTRIM(ItemValue)) from dbo.sp_SplitIn2Rows(@PMCGGroup,'|')
		If @OCG=0
		Begin
			Update t Set CatGrpID = M.GroupID  From @tmpPMCG t, ProductCategoryGroupAbstract M 
			Where t.CatGrp = M.GroupName And M.Active = 1 
		End
		Else
		Begin
			Update t Set CatGrpID = M.GroupID  From @tmpPMCG t, ProductCategoryGroupAbstract M 
			Where t.CatGrp = M.GroupName And M.Active = 1  and isnull(M.OCGType,0)=1
		End
		Select @PMCGGroup = CGGroups, @Period = Period From tbl_mERP_PMMaster Where PMID =  @PMetricID 
		Insert into @tmpPMCG (CatGrp)
		Select LTRIM(RTRIM(ItemValue)) from dbo.sp_SplitIn2Rows(@PMCGGroup,'|')
		/*
		Insert Into @tmpPostedmonth select Distinct Cast(('01-' + PMMonth) as DateTime)  From PM_DS_Data
		Set @PreviousMonthName = (Select Top 1 MonthDate From @tmpPostedmonth Where  MonthDate < Cast(('01-' + @Period) as DateTime) Order By MonthDate Desc)
		Set @PreviousMonthName = Cast((select Left(DateName(Month,@PreviousMonthName),3) + '-' +  Cast(Year(@PreviousMonthName) as Nvarchar(10))) as Nvarchar(255))
		*/
		
		Insert Into @TempFocusItems (ProductLevel,ProductName)
		select ProdCat_Level,ProdCat_Code From tbl_mERP_PMParamFocus Where Paramid = @ParamID

		Update TC Set TC.CategoryID = IC.CategoryID From @TempFocusItems TC, ItemCategories IC 
		Where TC.ProductLevel = IC.Level and TC.ProductName = IC.Category_Name And IC.Active = 1 and TC.ProductLevel <> 0

		Update @TempFocusItems Set CategoryID = 1 Where ProductLevel = 0

		update @TempFocusItems Set PMProductName=tbl_mERP_PMParamFocus.PMProductName From tbl_mERP_PMParamFocus Where Paramid = @ParamID

--		Declare @Months Table(ID int identity(1,1),Fromdate Datetime,Todate Datetime,Days int)
--		insert into @Months(Fromdate,Todate,Days)
--		Select Fromdate,Todate,Days from dbo.mERP_FN_GetPMdates(@Period)
--		Declare @i int
--		Set @i=1
	
		/* OCG */
		If @OCG=1
		BEGIN
			Declare @TmpGroup Table(GroupId int)
			Declare @TmpItems Table(Product_Code nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,Category_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
			Declare @GroupID nvarchar(50)
			Insert into @TmpGroup (GroupId)
			Select Distinct GroupID from ProductCategoryGroupAbstract  
			where GroupID In (Select DSTCG.GroupID from tbl_mERP_DSTypeCGMapping DSTCG,DSType_Master DSM Where DSTCG.DSTypeID=DSM.DSTypeID and DSM.DSTypeValue in 
			(Select PMDS.DSType From tbl_mERP_PMDSType PMDS,tbl_mERP_PMParam PMParam Where PMParam.DSTypeID=PMDS.DSTypeID
			And PMParam.ParamID=@ParamID) And DSTCG.Active = 1 and isnull(DSM.active,0)=1 and isnull(DSM.OCGType,0)=1)
			and isnull(ProductCategoryGroupAbstract.active,0)=1 and isnull(ProductCategoryGroupAbstract.OCGType,0)=1
			Declare AllGroup Cursor For select Distinct cast(GroupId as nvarchar(50)) from @TmpGroup
			Open AllGroup
			Fetch from AllGroup into @GroupID
			While @@fetch_status=0
			Begin
				insert into @TmpItems (Product_Code,Category_name)	
				Select FN.Product_code,IC2.Category_Name from dbo.Fn_GetOCGSKU(@GroupID) FN,ItemCategories IC4,ItemCategories IC3,ItemCategories IC2
				Where FN.CategoryID=IC4.CategoryID
				And IC4.Parentid=IC3.CategoryID
				And IC3.ParentID=IC2.CategoryID
				Fetch next from AllGroup into @GroupID	
			End
			Close AllGroup
			Deallocate AllGroup
			
			/*Below line is written to avoid comparing Group name in the below checking */
			Delete from @TmpItems where Category_name not in(Select Distinct Division from tblCGDivMapping where Categorygroup In (Select CatGrp from @tmpPMCG))
		END

		/* Salesmen for whom Target is not yet defined. */
		if @OCG=1
		Begin
			Insert into @tmpDSTarget(SalesmanID, Salesman_Name, PMDSTypeID, DSTypeValue, --FocusSKU, 
			MaxPoints)
			Select Distinct SM.SalesManID, SM.Salesman_Name, PMDS.DSTypeID, PMDS.DSType, 
			--Case IsNull(PMparam.isFocusParameter,0) When 0 Then N'Overall' Else PMFocus.ProdCat_Code End,
			PMParam.MaxPoints
			From tbl_mERP_PMDSType PMDS, DSTYpe_Master DSM, SalesMan SM, DSType_Details DSTDet,
			ProductCategoryGroupAbstract CGMas, tbl_mERP_DSTypeCGMapping CGMap,
			tbl_mERP_PMParam PMparam, tbl_mERP_PMParamFocus PMFocus
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
			And PMparam.ParamID = PMFocus.ParamID
			And PMFocus.ParamId=@ParamId
			And isnull(DSM.OCGType,0)=1
			And isnull(CGMas.OCGType,0)=1
			And isnull(CGMas.Active,0)=1
			And isnull(DSM.Active,0)=1			
			--And SM.SalesmanID Not in (Select SalesmanID from tbl_mERP_PMetric_TargetDefn Where ParamId=@ParamId and Active = 1) --Where FocusID = @FocusID and Active = 1)
		End
		Else
		Begin
			Insert into @tmpDSTarget(SalesmanID, Salesman_Name, PMDSTypeID, DSTypeValue, --FocusSKU, 
			MaxPoints)
			Select Distinct SM.SalesManID, SM.Salesman_Name, PMDS.DSTypeID, PMDS.DSType, 			
			PMParam.MaxPoints
			From tbl_mERP_PMDSType PMDS, DSTYpe_Master DSM, SalesMan SM, DSType_Details DSTDet,
			ProductCategoryGroupAbstract CGMas , @tmpPMCG PMCG, tbl_mERP_DSTypeCGMapping CGMap,
			tbl_mERP_PMParam PMparam, tbl_mERP_PMParamFocus PMFocus
			Where PMDS.DSTypeID = PMParam.DSTypeID 
			And DSM.DSTypeValue =PMDS.DSType 
			And DSM.DSTypeCtlPos = 1 
			And DSM.DSTypeID = DSTDet.DSTypeID  
			And DSM.DSTypeCtlPos = DSTDet.DSTypeCtlPos
			And SM.SalesmanID= DSTDet.SalesmanID
			And SM.Active = 1 
			And CGMas.GroupName = PMCG.CatGrp
			And CGMas.GroupID = CGMap.GroupID
			And CGMap.Active = 1
			And DSM.DSTypeID = CGMap.DSTypeID
			And PMparam.ParamID = PMFocus.ParamID
			And PMFocus.ParamId=@ParamId
			And isnull(DSM.OCGType,0)=0
			And isnull(CGMas.OCGType,0)=0
			And isnull(CGMas.Active,0)=1
			And isnull(DSM.Active,0)=1			
			--And SM.SalesmanID Not in (Select SalesmanID from tbl_mERP_PMetric_TargetDefn Where ParamId=@ParamId and Active = 1) --Where FocusID = @FocusID and Active = 1)
		End

		/*Handled More than one Category Grouping*/
		if @OCG=0
		Begin
			Update tmptgt Set CGMapID = (Select Top 1 ID from tbl_mERP_DSTypeCGMapping Where Active = 1 And DSTypeID = DSM.DSTypeID And GroupID in (Select CatGrpID from @tmpPMCG))
			From @tmpDSTarget tmptgt, tbl_mERP_PMDSType PMDS, DSTYpe_Master DSM
			Where tmptgt.PMDSTypeID = PMDS.DSTypeID
			And PMDS.DSType = DSM.DSTypeValue
			And DSM.Active = 1 and DSM.DSTypeCtlPos = 1 
			And isnull(DSM.OCGType,0)=0
		End
		Else
		Begin
			Update tmptgt Set CGMapID = (Select Top 1 ID from tbl_mERP_DSTypeCGMapping Where Active = 1 And DSTypeID = DSM.DSTypeID And GroupID in (Select CatGrpID from @tmpPMCG))
			From @tmpDSTarget tmptgt, tbl_mERP_PMDSType PMDS, DSTYpe_Master DSM
			Where tmptgt.PMDSTypeID = PMDS.DSTypeID
			And PMDS.DSType = DSM.DSTypeValue
			And DSM.Active = 1 and DSM.DSTypeCtlPos = 1 
			And isnull(DSM.OCGType,0)=1
		End
	End

	/* User is permitted to change the PM*/
	If @EditLock = 0 
	Begin

		Insert Into @Tempdata 	
		Select SalesManID, SalesMan_Name, DSTypeValue, NULL Target, MaxPoints, @PMetricID as PMID, PMDSTypeID, @ParamID as ParamID, 		
		0 as FocusID,CGMapID, 0 TargetDefnID,NULL,0,0
		From @tmpDSTarget
		
		/* Outlet wise Target changes*/
		If (Select isnull(flag,0) from Tbl_Merp_ConfigAbstract where screencode='PMOutletTarget')=1
		BEGIN

			Declare @DStypeID int
			Select @DStypeID=isnull(DSTypeID,0) from tbl_mERP_PMParam where Paramid=@ParamID
			Declare @tmpOutletwiseData Table(DSID int,Target decimal(18,6))
			Insert into @tmpOutletwiseData(DSID,Target)
			select DSID,Target from  dbo.FN_GetOutletwise_PMOutletAch(@PMetricID,@DStypeID,@ParamID)
			
			Update T set T.Target = T1.Target
			From @Tempdata T, @tmpOutletwiseData T1
			Where T.SalesmanID = T1.DSID
			And T.saveflag=0
			And T.Target is null
			
			Delete from @tmpOutletwiseData
		END

	End
	Else
	Begin

		Insert Into @Tempdata 	  
		Select PMTar.SalesmanID, SM.SalesMan_Name, PMDS.DSType, PMTar.Target, PMTar.MaxPoints, PMTar.PMID, PMTar.PMDSTypeID, PMTar.ParamID, 		
		PMTar.FocusID, PMTar.DSTypeCGMapID, PMTar.TargetDefnID ,PMTar.TargetDefnDate,isnull(PMTar.AutopostFlag,0),1
		From tbl_mERP_PMetric_TargetDefn PMTar, Salesman SM, tbl_mERP_PMDSType PMDS,tbl_mERP_PMParam PMparam
		Where SM.SalesmanID = PMTar.SalesmanID 
		And PMDS.DSTypeID = PMTar.PMDSTypeID		
		And PMparam.ParamID = PMTar.ParamID
		And PMparam.ParamId=@ParamID		
		And PMtar.Active = 1 
	End
	Insert into @Result
	select SalesManID,SalesMan_Name,DSTypeValue,Target,MaxPoints,PMID,PMDSTypeID,ParamID,
	CGMapID,TargetDefnID,LastupdatedDate,AutoPostflag,SaveFlag
	from @Tempdata

Return

End
