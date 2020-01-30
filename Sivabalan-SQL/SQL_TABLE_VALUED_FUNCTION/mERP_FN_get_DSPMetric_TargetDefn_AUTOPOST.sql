CREATE Function mERP_FN_get_DSPMetric_TargetDefn_AUTOPOST(@PMetricID Int, @ParamID Int, @EditLock Int)
Returns @Result Table(SalesManID int NULL,
			SalesMan_Name nvarchar(225) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			DSTypeValue nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			Target decimal(18, 6) NULL,
			MaxPoints decimal(18, 6) NULL,
			PMID int NULL,
			PMDSTypeID int NULL,
			ParamID int NULL,
			--FocusSKU nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			CGMapID int NULL,
			TargetDefnID int NOT NULL,
			SalesValue decimal(18, 6) NULL,GrowthPercentage decimal(18,6),ProposedTargetValue decimal(18,6),LastupdatedDate Datetime,AutoPostflag int,SaveFlag int,OriginalTarget Decimal(18,6))
As
Begin 

	/* If User is allowed to change the setting then do the following process*/
	if @EditLock = 0
	Begin
		Declare @tmpDSTarget as Table(SalesmanID int, Salesman_Name nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
									  PMDSTypeID Int, DSTypeValue nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, 
									  --FocusSKU nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
									  MaxPoints Decimal(18,6), CGMapID int,GrowthPercentage Decimal(18,6))

		Declare @TempFocusItems as Table (
				ProductLevel Int,
				ProductName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
				CategoryID Int,
				PMProductName Nvarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS)


		Declare @tmpPMCG as Table(CatGrpID int, CatGrp nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
		/*To get the Category Group even if its GC1 & CG3*/
		Declare @PMCGGroup as nVarchar(510)
		Declare @tmpNetsales as Table(SalesManid int, SalesValue Decimal(18,6),Days int,Flag int,salesmonth int,ProductName Nvarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS)
		Declare @AvgNetsales TABLE (SalesManid int, SalesValue Decimal(18,6),salesmonth int,ProductName Nvarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS)
		Declare @FinalNetsales Table (SalesManid int, SalesValue Decimal(18,6))
		--Declare @tmpPostedmonth as Table (MonthDate dateTime)
		Declare @Tempdata as Table (SalesManID int NULL,
			SalesMan_Name nvarchar(225) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			DSTypeValue nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			Target decimal(18, 6) NULL,
			MaxPoints decimal(18, 6) NULL,
			PMID int NULL,
			PMDSTypeID int NULL,
			ParamID int NULL,
			--FocusSKU nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			FocusID int NULL,
			CGMapID int NULL,
			TargetDefnID int NOT NULL,
			SalesValue decimal(18, 6) NULL,GrowthPercentage decimal(18,6),ProposedTargetValue decimal(18,6),LastupdatedDate Datetime,AutoPostflag int,SaveFlag int,OriginalTarget Decimal(18,6))

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

		Declare @Months Table(ID int identity(1,1),Fromdate Datetime,Todate Datetime,Days int)
		insert into @Months(Fromdate,Todate,Days)
		Select Fromdate,Todate,Days from dbo.mERP_FN_GetPMdates(@Period)
		Declare @i int
		Set @i=1
	
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

		Declare AllProd Cursor for Select distinct PMProductName from @TempFocusItems
		Open AllProd
		Fetch from  AllProd into @ProductName
		while @@fetch_status=0
		Begin
				set @i = 1
				select Top 1 @ProductLevel = ProductLevel from @TempFocusItems
				Where PMProductName=@ProductName
				
				While @i<=(Select max(ID) from @Months)
				BEGIN
					If @ProductLevel = 0
					Begin
						If @OCG=1
						Begin
							Insert into @tmpNetsales(SalesManid,SalesValue,Days,Flag,salesmonth,ProductName)
							Select SalesManid,Case When isnull(Sum(SalesValue),0) <= 0 Then 0 Else isnull((Sum(SalesValue)),0) End SalesValue,
							(Select days from @Months where ID=@i),Case When isnull((Sum(SalesValue)),0) <= 0 Then 0 else 1 End [Flag],(Select month(Fromdate) from @Months where ID=@i) [salesmonth],@ProductName From PM_DS_Data P,@TmpItems OCG 
							Where invoicedate between (Select Fromdate From @Months Where ID=@i) And (Select ToDate From @Months Where ID=@i)
							And P.Product_code=OCG.Product_code
							And Active = 1
							--And GroupName in (select Distinct CatGrp from @tmpPMCG)
							Group By SalesManid
						End
						Else
						Begin
							Insert into @tmpNetsales(SalesManid,SalesValue,Days,Flag,salesmonth,ProductName)
							Select SalesManid,Case When isnull(Sum(SalesValue),0) <= 0 Then 0 Else isnull((Sum(SalesValue)),0) End SalesValue,
							(Select days from @Months where ID=@i),Case When isnull((Sum(SalesValue)),0) <= 0 Then 0 else 1 End [Flag],(Select month(Fromdate) from @Months where ID=@i) [salesmonth],@ProductName From PM_DS_Data 
							Where invoicedate between (Select Fromdate From @Months Where ID=@i) And (Select ToDate From @Months Where ID=@i)
							And Active = 1
							And GroupName in (select Distinct CatGrp from @tmpPMCG)
							Group By SalesManid
						End
					End

					If @ProductLevel = 2
					Begin
						If @OCG=1
						Begin
							Insert into @tmpNetsales(SalesManid,SalesValue,Days,Flag,salesmonth,ProductName)
							Select SalesManid,Case When isnull((Sum(SalesValue)),0) <= 0 Then 0 Else isnull((Sum(SalesValue)),0) End SalesValue,
							(Select days from @Months where ID=@i),Case When isnull((Sum(SalesValue)),0) <= 0 Then 0 else 1  End [Flag],(Select month(Fromdate) from @Months where ID=@i) [salesmonth],@ProductName From PM_DS_Data P,@TmpItems OCG 
							Where invoicedate between (Select Fromdate From @Months Where ID=@i) And (Select ToDate From @Months Where ID=@i)
							And P.Product_code=OCG.Product_code
							And Active = 1
							--And GroupName in (select Distinct CatGrp from @tmpPMCG)
							And Division in(Select ProductName from  @TempFocusItems where PMProductName = @ProductName)
							Group By SalesManid

						End
						Else
						Begin
							Insert into @tmpNetsales(SalesManid,SalesValue,Days,Flag,salesmonth,ProductName)
							Select SalesManid,Case When isnull((Sum(SalesValue)),0) <= 0 Then 0 Else isnull((Sum(SalesValue)),0) End SalesValue,
							(Select days from @Months where ID=@i),Case When isnull((Sum(SalesValue)),0) <= 0 Then 0 else 1  End [Flag],(Select month(Fromdate) from @Months where ID=@i) [salesmonth],@ProductName From PM_DS_Data 
							Where invoicedate between (Select Fromdate From @Months Where ID=@i) And (Select ToDate From @Months Where ID=@i)
							And Active = 1
							And GroupName in (select Distinct CatGrp from @tmpPMCG)
							And Division in(Select ProductName from  @TempFocusItems where PMProductName = @ProductName)
							Group By SalesManid
						End
					End

					If @ProductLevel = 3
					Begin
						If @OCG=1
						Begin
							Insert into @tmpNetsales(SalesManid,SalesValue,Days,Flag,salesmonth,ProductName)
							Select SalesManid,Case When isnull((Sum(SalesValue)),0) <= 0 Then 0 Else isnull((Sum(SalesValue)),0) End SalesValue,
							(Select days from @Months where ID=@i),Case When isnull((Sum(SalesValue)),0) <= 0 Then 0 else 1  End [Flag],(Select month(Fromdate) from @Months where ID=@i) [salesmonth],@ProductName  From PM_DS_Data P,@TmpItems OCG 
							Where invoicedate between (Select Fromdate From @Months Where ID=@i) And (Select ToDate From @Months Where ID=@i)
							And Active = 1
							And P.Product_code=OCG.Product_code
							--And GroupName in (select Distinct CatGrp from @tmpPMCG)
							--And SubCategory = @ProductName
							And SubCategory in(Select ProductName from  @TempFocusItems where PMProductName = @ProductName)
							Group By SalesManid
						End
						Else
						Begin
							Insert into @tmpNetsales(SalesManid,SalesValue,Days,Flag,salesmonth,ProductName)
							Select SalesManid,Case When isnull((Sum(SalesValue)),0) <= 0 Then 0 Else isnull((Sum(SalesValue)),0) End SalesValue,
							(Select days from @Months where ID=@i),Case When isnull((Sum(SalesValue)),0) <= 0 Then 0 else 1  End [Flag],(Select month(Fromdate) from @Months where ID=@i) [salesmonth],@ProductName  From PM_DS_Data 
							Where invoicedate between (Select Fromdate From @Months Where ID=@i) And (Select ToDate From @Months Where ID=@i)
							And Active = 1
							And GroupName in (select Distinct CatGrp from @tmpPMCG)
							--And SubCategory = @ProductName
							And SubCategory in(Select ProductName from  @TempFocusItems where PMProductName = @ProductName)
							Group By SalesManid
						End
					End

					If @ProductLevel = 4
					Begin
						if @OCG=1
						Begin
							Insert into @tmpNetsales(SalesManid,SalesValue,Days,Flag,salesmonth,ProductName)
							Select SalesManid,Case When isnull((Sum(SalesValue)),0) <= 0 Then 0 Else isnull((Sum(SalesValue)),0) End SalesValue,
							(Select days from @Months where ID=@i),Case When isnull((Sum(SalesValue)),0) <= 0 Then 0 else 1 End [Flag],(Select month(Fromdate) from @Months where ID=@i) [salesmonth],@ProductName  From PM_DS_Data P,@TmpItems OCG 
							Where invoicedate between (Select Fromdate From @Months Where ID=@i) And (Select ToDate From @Months Where ID=@i)
							And Active = 1
							And P.Product_code=OCG.Product_code
							--And GroupName in (select Distinct CatGrp from @tmpPMCG)
							--And MarketSKU = @ProductName
							And MarketSKU in(Select ProductName from  @TempFocusItems where PMProductName = @ProductName)
							Group By SalesManid
						End
						Else
						Begin
							Insert into @tmpNetsales(SalesManid,SalesValue,Days,Flag,salesmonth,ProductName)
							Select SalesManid,Case When isnull((Sum(SalesValue)),0) <= 0 Then 0 Else isnull((Sum(SalesValue)),0) End SalesValue,
							(Select days from @Months where ID=@i),Case When isnull((Sum(SalesValue)),0) <= 0 Then 0 else 1 End [Flag],(Select month(Fromdate) from @Months where ID=@i) [salesmonth],@ProductName  From PM_DS_Data 
							Where invoicedate between (Select Fromdate From @Months Where ID=@i) And (Select ToDate From @Months Where ID=@i)
							And Active = 1
							And GroupName in (select Distinct CatGrp from @tmpPMCG)
							--And MarketSKU = @ProductName
							And MarketSKU in(Select ProductName from  @TempFocusItems where PMProductName = @ProductName)
							Group By SalesManid
						End
					End

					If @ProductLevel = 5
					Begin
						if @OCG=1
						Begin
							Insert into @tmpNetsales(SalesManid,SalesValue,Days,Flag,salesmonth,ProductName)
							Select SalesManid,Case When isnull((Sum(SalesValue)),0) <= 0 Then 0 Else isnull((Sum(SalesValue)),0) End SalesValue,
							(Select days from @Months where ID=@i),Case When isnull((Sum(SalesValue)),0) <= 0 Then 0 else 1 End [Flag],(Select month(Fromdate) from @Months where ID=@i) [salesmonth],@ProductName  From PM_DS_Data P,@TmpItems OCG 
							Where invoicedate between (Select Fromdate From @Months Where ID=@i) And (Select ToDate From @Months Where ID=@i)
							And Active = 1
							And P.Product_code=OCG.Product_code
							--And GroupName in (select Distinct CatGrp from @tmpPMCG)
							--And Product_Code = @ProductName
							And P.Product_Code in(Select ProductName from @TempFocusItems where PMProductName = @ProductName)
							Group By SalesManid
						End
						Else
						Begin
							Insert into @tmpNetsales(SalesManid,SalesValue,Days,Flag,salesmonth,ProductName)
							Select SalesManid,Case When isnull((Sum(SalesValue)),0) <= 0 Then 0 Else isnull((Sum(SalesValue)),0) End SalesValue,
							(Select days from @Months where ID=@i),Case When isnull((Sum(SalesValue)),0) <= 0 Then 0 else 1 End [Flag],(Select month(Fromdate) from @Months where ID=@i) [salesmonth],@ProductName  From PM_DS_Data 
							Where invoicedate between (Select Fromdate From @Months Where ID=@i) And (Select ToDate From @Months Where ID=@i)
							And Active = 1
							And GroupName in (select Distinct CatGrp from @tmpPMCG)
							--And Product_Code = @ProductName
							And Product_Code in(Select ProductName from @TempFocusItems where PMProductName = @ProductName)
							Group By SalesManid
						End
					End
					set @i= @i+1
				END
			Fetch next from AllProd into @ProductName
		End
		Close allProd
		Deallocate allProd

		insert into @AvgNetsales (SalesManid,Salesvalue,salesmonth,ProductName)
		Select SalesmanID,((sum(Salesvalue)/sum(Days))*30) Salesvalue,max(salesmonth),ProductName from @tmpNetsales
		Where Flag = 1
		and Salesvalue > 0
		Group by SalesmanID,ProductName
		union
		Select SalesmanID,0,0,'' from @tmpNetsales
		Where Flag = 0 and salesmanid not in (select salesmanid from @tmpNetsales where Flag = 1)


		insert into @FinalNetsales (SalesmanID,Salesvalue)
		Select SalesmanID,sum(Salesvalue) from @AvgNetsales group by SalesmanID

		/* Salesmen for whom Target is not yet defined. */
		if @OCG=1
		Begin
			Insert into @tmpDSTarget(SalesmanID, Salesman_Name, PMDSTypeID, DSTypeValue, --FocusSKU, 
			MaxPoints,GrowthPercentage)
			Select Distinct SM.SalesManID, SM.Salesman_Name, PMDS.DSTypeID, PMDS.DSType, 
			--Case IsNull(PMparam.isFocusParameter,0) When 0 Then N'Overall' Else PMFocus.ProdCat_Code End,
			PMParam.MaxPoints,PMParam.GrowthPercentage
			From tbl_mERP_PMDSType PMDS, DSTYpe_Master DSM, SalesMan SM, DSType_Details DSTDet,
			ProductCategoryGroupAbstract CGMas , 
			--@tmpPMCG PMCG, 
			tbl_mERP_DSTypeCGMapping CGMap,
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
			--And PMFocus.FocusID = @FocusID
			And SM.SalesmanID Not in (Select SalesmanID from tbl_mERP_PMetric_TargetDefn Where ParamId=@ParamId and Active = 1) --Where FocusID = @FocusID and Active = 1)
		End
		Else
		Begin
			Insert into @tmpDSTarget(SalesmanID, Salesman_Name, PMDSTypeID, DSTypeValue, --FocusSKU, 
			MaxPoints,GrowthPercentage)
			Select Distinct SM.SalesManID, SM.Salesman_Name, PMDS.DSTypeID, PMDS.DSType, 
			--Case IsNull(PMparam.isFocusParameter,0) When 0 Then N'Overall' Else PMFocus.ProdCat_Code End,
			PMParam.MaxPoints,PMParam.GrowthPercentage
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
			--And PMFocus.FocusID = @FocusID
			And SM.SalesmanID Not in (Select SalesmanID from tbl_mERP_PMetric_TargetDefn Where ParamId=@ParamId and Active = 1) --Where FocusID = @FocusID and Active = 1)
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
		--FocusSKU, 
		0 as FocusID,CGMapID, 0 TargetDefnID , NULL SalesValue,GrowthPercentage,0 ProposedTargetValue,NULL,0,0,0 OriginalTarget
		From @tmpDSTarget
		Union 
		Select PMTar.SalesmanID, SM.SalesMan_Name, PMDS.DSType, isnull(PMTar.Target,0), PMTar.MaxPoints, PMTar.PMID, PMTar.PMDSTypeID, PMTar.ParamID, 
		--Case IsNull(PMparam.isFocusParameter,0) When 0 Then N'Overall' Else PMFocus.ProdCat_Code End, 
		PMTar.FocusID, PMTar.DSTypeCGMapID, PMTar.TargetDefnID ,isnull(PMTar.Avgsales,0) Avgsales,isnull(PMTar.GrowthPerc,0) GrowthPerc,
		isnull(PMTar.ProposedTargetValue,0) ProposedTargetValue,PMTar.TargetDefnDate,isnull(PMTar.AutopostFlag,0),0,PMTar.OriginalTarget
		From tbl_mERP_PMetric_TargetDefn PMTar, Salesman SM, tbl_mERP_PMDSType PMDS, tbl_mERP_PMParamFocus PMFocus, tbl_mERP_PMParam PMparam
		Where SM.SalesmanID = PMTar.SalesmanID 
		And PMDS.DSTypeID = PMTar.PMDSTypeID
		--And PMFocus.FocusID = PMTar.FocusID
		And PMFocus.ParamID= PMparam.ParamID
		And PMparam.ParamID = PMTar.ParamID
		And PMFocus.ParamId=@ParamID
		--And PMtar.FocusID = @FocusID
		And PMtar.Active = 1 

		Update T set T.SalesValue = Isnull(T1.SalesValue,0),T.ProposedTargetValue = dbo.Fn_PM_GetRoundedTargetValue(Isnull(T1.SalesValue,0)+(Isnull(T1.SalesValue,0) * (isnull(T.GrowthPercentage,0)/100.00)))
		From @Tempdata T, @FinalNetsales T1
		Where T.SalesmanID = T1.SalesmanID
		And T.saveflag=0

		
		/* Outlet wise Target changes*/
		If (Select isnull(flag,0) from Tbl_Merp_ConfigAbstract where screencode='PMOutletTarget')=1
		BEGIN

			Declare @DStypeID int
			Select @DStypeID=isnull(DSTypeID,0) from tbl_mERP_PMParam where Paramid=@ParamID
			Declare @tmpOutletwiseData Table(DSID int,Target decimal(18,6))
			Insert into @tmpOutletwiseData(DSID,Target)
			select DSID,Target from  dbo.FN_GetOutletwisePMTarget(@PMetricID,@DStypeID,@ParamID)
			
			Update T set T.Target = dbo.Fn_PM_GetRoundedNearest500(T1.Target)--,T.ProposedTargetValue=T1.Target
			From @Tempdata T, @tmpOutletwiseData T1
			Where T.SalesmanID = T1.DSID
			And T.saveflag=0
			And T.Target is null

			Update T set T.ProposedTargetValue = dbo.Fn_PM_GetRoundedNearest500(T1.Target),T.OriginalTarget = T1.Target
			From @Tempdata T, @tmpOutletwiseData T1
			Where T.SalesmanID = T1.DSID
			And T.saveflag=0

			update @Tempdata set ProposedTargetValue=NULL where salesmanid not in (select distinct DSID from @tmpOutletwiseData)
			Delete from @tmpOutletwiseData
		END
		ELSE
		BEGIN
			Update T set T.Target = Isnull(T.ProposedTargetValue,0)
			From @Tempdata T, @FinalNetsales T1
			Where T.SalesmanID = T1.SalesmanID
			And T.saveflag=0
			And T.Target is null
		END
--		Drop Table @AvgNetsales
--		Drop Table #FinalNetsales
	End
	Else
	Begin

		Insert Into @Tempdata 	  
		Select PMTar.SalesmanID, SM.SalesMan_Name, PMDS.DSType, PMTar.Target, PMTar.MaxPoints, PMTar.PMID, PMTar.PMDSTypeID, PMTar.ParamID, 
		--Case IsNull(PMparam.isFocusParameter,0) When 0 Then N'Overall' Else PMFocus.ProdCat_Code End, 
		PMTar.FocusID, PMTar.DSTypeCGMapID, PMTar.TargetDefnID ,isnull(PMTar.Avgsales,0),isnull(PMTar.GrowthPerc,0),isnull(PMTar.ProposedTargetValue,0),PMTar.TargetDefnDate,isnull(PMTar.AutopostFlag,0),1,Isnull(PMTar.OriginalTarget,0)
		From tbl_mERP_PMetric_TargetDefn PMTar, Salesman SM, tbl_mERP_PMDSType PMDS, --tbl_mERP_PMParamFocus PMFocus, 
		tbl_mERP_PMParam PMparam
		Where SM.SalesmanID = PMTar.SalesmanID 
		And PMDS.DSTypeID = PMTar.PMDSTypeID
		--And PMFocus.FocusID = PMTar.FocusID
		And PMparam.ParamID = PMTar.ParamID
--		And PMFocus.ParamId = PMparam.ParamID
--		And PMFocus.ParamId=@ParamID
		And PMparam.ParamId=@ParamID
		--And PMtar.FocusID = @FocusID
		And PMtar.Active = 1 
	End
	Insert into @Result
	select SalesManID,SalesMan_Name,DSTypeValue,Target,MaxPoints,PMID,PMDSTypeID,ParamID,--FocusSKU,
	CGMapID,TargetDefnID,SalesValue,GrowthPercentage,ProposedTargetValue,LastupdatedDate,AutoPostflag,SaveFlag,OriginalTarget
	from @Tempdata

Return
--Drop Table #AvgNetsales
End
