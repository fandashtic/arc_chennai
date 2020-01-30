Create Function mERP_FN_V_SD_PM()
Returns @TmpOutput Table (SalesmanID int,SDObjective nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,TotalOutlets Decimal(18,6),ConvertedOutlets Decimal(18,6),Points decimal(18,6))
BEGIN

	Declare @CurrentDate Datetime
	Set @CurrentDate = dbo.StripTimeFromDate(Cast(GetDate() as Datetime))

	IF EXISTS (Select 'x' From HHViewLog Where dbo.StripTimeFromDate(Date) = @CurrentDate)
		Insert Into @TmpOutput (SalesmanID,SDObjective,TotalOutlets,ConvertedOutlets,Points)
		Select SalesmanID,SDObjective,TotalOutlets,ConvertedOutlets,Points From tmpDSPMSalesman
	ELSE
	BEGIN
		Declare @DateOrMonth as datetime--(10)
		Declare @OCG as Int
		Select @OCG = Isnull(Flag,0) From tbl_Merp_ConfigAbstract Where ScreenCode = 'OCGDS'
		select @DateOrMonth = dbo.striptimefromdate(getdate())--Substring(DateName(mm, Getdate()), 1, 3) + '-' + DateName(YYYY, Getdate())
		
		Declare @GGDR_DSTypeCustomer as Table (SalesmanId Int,CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, GGDRCatGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,OutletStatus Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
		Declare @SalesManCatGroup as Table (SalesmanId Int,CatGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

		Insert Into @SalesManCatGroup (SalesmanId,CatGroup)
		Select Distinct DT.SalesmanID,G.GroupName 
		from DSType_Details DT, tbl_mERP_DSTypeCGMapping M,ProductCategoryGroupAbstract G
		Where Isnull(DT.DSTypeCtlPos,0) = 1
		And DT.DStypeID = M.DSTypeID
		And Isnull(M.Active,0) = 1
		And G.GroupID = M.GroupID
		And Isnull(G.Active,0) = 1

		Insert Into @GGDR_DSTypeCustomer (SalesManID,CustomerID,GGDRCatGroup,OutletStatus)
		Select Distinct B.SalesmanID,G.OutletID,(Case When @OCG = 0 Then G.CatGroup Else G.OCG End),G.OutletStatus 
		From GGDROutlet G,Beat_salesman B,@SalesManCatGroup S
		Where isnull(B.CustomerId,'') <> ''
		And B.CustomerId = G.OutletID
		And Isnull(G.Active,0) = 1
		And @DateOrMonth between G.ReportFromDate and G.ReportToDate
		And B.SalesmanID = S.SalesmanID
		And (Case When @OCG = 0 Then G.CatGroup Else G.OCG End) = S.CatGroup
		AND Isnull(G.Flag,'')!='WS'

		--Insert into @TmpOutput
		--Select DSID,Isnull(Parameter,0),0,Isnull(ConvertedOutlets,0),Isnull(Points,0) From dbo.mERP_FN_PointsforGGDR_View()

		Insert into @TmpOutput
		Select DSID,Isnull(Parameter,0),0,Isnull(ConvertedOutlets,0),Isnull(Points,0) From dbo.mERP_FN_PointsforBLOCKBUSTER_View()
		
		

		Update T set T.TotalOutlets = T1.Cnt From @TmpOutput T,
		(Select Distinct T.SalesmanID,Count(Distinct G.CustomerId) Cnt
		From @tmpOutput T,@GGDR_DSTypeCustomer G
		Where G.SalesmanId = T.SalesmanID
		And G.OutletStatus = 'R'
		Group By T.SalesmanID) T1
		Where T.SalesmanID = T1.SalesmanID
		And T.SDObjective = 'Red'

		Update T set T.TotalOutlets = T1.Cnt From @TmpOutput T,
		(Select Distinct T.SalesmanID,Count(Distinct G.CustomerId) Cnt
		From @tmpOutput T,@GGDR_DSTypeCustomer G
		Where G.SalesmanId = T.SalesmanID
		And G.OutletStatus = 'EG'
		Group By T.SalesmanID) T1
		Where T.SalesmanID = T1.SalesmanID
		And T.SDObjective = 'Green'

		Update T set T.TotalOutlets = T1.Cnt From @TmpOutput T,
		(Select Distinct T.SalesmanID,Count(Distinct G.CustomerId) Cnt
		From @tmpOutput T,@GGDR_DSTypeCustomer G
		Where G.SalesmanId = T.SalesmanID
		And G.OutletStatus = 'EG'
		Group By T.SalesmanID) T1
		Where T.SalesmanID = T1.SalesmanID
		And T.SDObjective = 'Blockbuster'

		delete from @TmpOutput  Where SDObjective = '0'
		
		-- Logic Changes done
		Declare @GGDRmonth Nvarchar(10)
		Set @GGDRmonth=Substring(DateName(mm, Getdate()), 1, 3) + '-' + DateName(YYYY, Getdate())

		Declare @DSType as Table(SalesmanID int, DSTypeID int, DSTypeValue nVarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS)
		
		Declare @FinalData Table(CategoryGroup nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, DSID int, 
				CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, ProdDefnID Int, 
				Product_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Target Decimal(18,6), Actual Decimal(18,6))

		Insert Into @DSType(SalesmanID, DSTypeID, DSTypeValue)
		Select DS.SalesManID as DSID,DSTM.DSTypeID as DSTID,DSTM.DSTypeValue
		From Salesman DS, DSType_Master DSTM, DSType_Details DSTD
		Where DSTM.Active = 1 and DSTM.DSTypeID = DSTD.DSTypeID and
			DSTD.SalesManID = DS.SalesManID and  
			DS.Active = 1 
			and DSTD.SalesManID in (Select SalesManID from DSType_Details where salesmanID=DSTD.SalesManID and DSTYpeID = 
				(Select Top 1 DSTYpeID from DSType_Master where DSTypeName='Handheld DS' and DSTypeValue='Yes') )
			and DSTM.DSTypeName <> 'Handheld DS'

		Insert Into @FinalData(CategoryGroup, DSID, CustomerID, ProdDefnID, Product_Code, Target, Actual)
		Select PMCategory, DSID, CustomerID, ProdDefnID, D_ProductCode, D_Target, D_Actual
		From GGRRFinalData GD, @DSType DS
		Where Cast('01-' + [Month] as DateTime) = Cast('01-'+ @GGDRmonth as DateTime)
			and GD.DSID = DS.SalesmanID
			and GD.DSType = DS.DSTypeValue
			AND Isnull(GD.Flag,'')='WS'

		Insert Into @TmpOutput(SalesmanID, SDObjective, TotalOutlets, ConvertedOutlets, Points)
		Select DSID SalesmanID, 
			Case When CategoryGroup = 'GR1|GR3' Then 'WinnerFood' When CategoryGroup = 'GR2' Then 'WinnerPCP' End as SDObjective, 
			Count(*) TotalOutlets, SUM(Case When Actual - Target >=0 Then 1 Else 0 End) as  ConvertedOutlets, 0 as Points
		From @FinalData
		Group By DSID, CategoryGroup
		Order By DSID
				
	END
	Return
END
