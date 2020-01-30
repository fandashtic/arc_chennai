Create Procedure mERP_SP_GetDSTypePlan (@Month nvarchar(10))
AS
BEGIN
	Set dateformat DMY

	Declare @LDCDate Datetime
	Declare @TempMonth Datetime
	Declare @TempLDCDate Datetime
	select @LDCDate= Lastinventoryupload from setup
	/* Last Day of the month */
	If (Select dbo.stripdatefromtime((DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@LDCDate)+1,0)))))=@LDCDate
	BEGIN
		/* Add one day to the last day close date*/	
		Select @LDCDate=dateadd(d,1,@LDCDate)	
	END

	 Set @TempLDCDate= DATEADD(mm, DATEDIFF(mm, 0, @LDCDate), 0)  
	 Set @TempMonth=cast('01-'+@Month as datetime)  

	Create Table #tmpResult(DSTypeID int,DStypeValue nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,Planned int,CreationDate datetime,[Locked] int)

	Create Table #DStypeCGMapping(DSTypeID nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS)

	If (Select isnull(Flag,0) From Tbl_merp_Configabstract Where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup')=0
	BEGIN
		insert into #DStypeCGMapping(DSTypeID)
		Select distinct DSTypeID from tbl_mERP_DSTypeCGMapping where Active = 1 
		and GroupID In (Select GroupID from ProductCategoryGroupAbstract)
	END
	ELSE
	BEGIN  
		insert into #DStypeCGMapping(DSTypeID)
		Select distinct DSTypeID from tbl_mERP_DSTypeCGMapping Where Active = 1 
		and GroupID In (Select GroupID from ProductCategoryGroupAbstract where OCGType=1 And Active=1)
	END

	/* To check whether Customer selects any previous month for which day close is done, if so, dont allow user to change anything*/
	If @TempMonth < @TempLDCDate
	BEGIN
		Insert into #tmpResult(DSTypeID,DStypeValue,Planned,CreationDate,[Locked])
		Select D.DSTypeID,DStype.DStypeValue,D.Planned,cast (CONVERT(VARCHAR(10), D.CreationDate, 103) + ' '  + convert(VARCHAR(8), D.CreationDate, 14) as varchar) as CreationDate,1 as [Locked] from DSTypePlanning D,DSType_Master DStype where D.PlanMonth=@Month And D.DSTypeID=DStype.DSTypeID
	END
	ELSE
	BEGIN
		Insert into #tmpResult(DSTypeID,DStypeValue,Planned,CreationDate,[Locked])
		Select D.DSTypeID,DStype.DStypeValue,D.Planned,cast (CONVERT(VARCHAR(10), D.CreationDate, 103) + ' '  + convert(VARCHAR(8), D.CreationDate, 14) as varchar) as CreationDate,0 as [Locked] from DSTypePlanning D,DSType_Master DStype where D.PlanMonth=@Month And D.DSTypeID=DStype.DSTypeID
		--CG
		If (Select isnull(Flag,0) From Tbl_merp_Configabstract Where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup')=0
		BEGIN
			Insert into #tmpResult(DSTypeID,DStypeValue,Planned,CreationDate,[Locked])
			Select M.DSTypeID,M.DStypeValue,NULL,NULL,0 From DSType_Master M,#DStypeCGMapping D Where 
			(Case when M.DSTypeName = 'DSType' then 
			(Select flag from tbl_merp_Configabstract where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup') 
			Else IsNull(OCGtype, 0) 
			End) = IsNull(OCGtype, 0)
			and isnull(Active,0) = 1 And isnull(DSTypeCtlPos,0) = 1 And M.DSTypeID not in (select DSTypeID from #tmpResult)
			And D.DSTypeID=M.DStypeID
		END
		ELSE
		--OCG
		BEGIN
			Insert into #tmpResult(DSTypeID,DStypeValue,Planned,CreationDate,[Locked])
			Select DSTypeID,DStypeValue,NULL,NULL,0 From DSType_Master Where 
			(Case when DSTypeName = 'DSType' then 
			(Select flag from tbl_merp_Configabstract where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup') 
			Else IsNull(OCGtype, 0) 
			End) = IsNull(OCGtype, 0)
			and isnull(Active,0) = 1 And isnull(DSTypeCtlPos,0) = 1 And DSTypeID not in (select DSTypeID from #tmpResult)
		END
	END
	Select * from #tmpResult order by DStypeValue
	Drop Table #tmpResult
	Drop Table #DStypeCGMapping
END
