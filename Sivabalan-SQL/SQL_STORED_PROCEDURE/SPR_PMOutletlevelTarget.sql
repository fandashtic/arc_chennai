Create Procedure SPR_PMOutletlevelTarget @Month nvarchar(25)
AS
BEGIN
	Set dateformat DMY
	Declare @DtMonth as Datetime
	Set @DtMonth = cast(Cast('01' + '/' +  @Month as nVarchar(15)) as datetime)	
	Declare @Period as nVarchar(8)
	Select @Period = REPLACE(RIGHT(CONVERT(VARCHAR(11), @DtMonth, 106), 8), ' ', '-')

	Create Table #PMDetails(
	PMID int,
	ParamId int,
	DStypeID int,
	PMCODE nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Description nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CGGroups nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	DStype nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ParamType nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ProdCat_Code nvarchar(max) COLLATE SQL_Latin1_General_CP1_CI_AS)

	Create Table #OutletDetails(
	PMID int,
	ParamId int,
	DStypeID int,
	PMCode nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	OutletID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
	OutletName nvarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Targets decimal(18,6),
	OCG  nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CG nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,
	DownloadedON datetime)	

	/* PM Part Starts */
	Insert into #PMDetails (PMID,ParamId,DStypeID,PMCODE,Description,CGGroups,DStype,ParamType,ProdCat_Code)
	Select distinct PMMaster.PMID,PMPARAM.ParamId,PMPARAM.DStypeID,PMMaster.PMCode,PMMaster.Description,PMMaster.CGGroups,PMDSType.DSType,Case PMPARAM.ParameterType when 3 then 'Business Achievement' When 6 Then 'Total Lines Cut' When 7 Then 'NUMERIC OUTLET ACH' end as ParamType,dbo.FN_GetPMFocusProducts(PMPARAM.ParamID) as ProdCat_Code
	From tbl_merp_PMMaster PMMaster,tbl_merp_PMDSType PMDSType,tbl_merp_PMParam PMPARAM,tbl_mERP_PMParamType PMPARAMTYPE
	where 
	PMMaster.PMID=PMDSType.PMID And
	PMPARAM.ParameterType=PMPARAMTYPE.ID And
	PMDSType.DSTYPEID=PMPARAM.DSTYPEID And
	isnull(PMMaster.Active,0)=1 And 
	Period = @Period And
	PMPARAMTYPE.ParamType in('Business Achievement','TOTAL LINES CUT','NUMERIC OUTLET ACH')
	
	/* PM Part Ends */

	update #PMDetails set ProdCat_Code = 'Overall' where ProdCat_Code ='all'
	/* Outlet wise Target Part Starts */
	Insert into	#OutletDetails(PMID,ParamId,DStypeID,PMCode,OutletID,OutletName,Targets,OCG,CG,DownloadedON)	
	Select distinct PM.PMID,PM.ParamID,PM.DSTypeID,PM.PMCode,PM.OutletID,C.Company_Name as OutletName,PM.Target as Targets,PM.OCG,PM.CG,R.CreationDate as DownloadedON from PMOutlet PM,Customer C,Recd_PMOLT R
	Where PM.OutletId=C.CustomerID And
	R.Status=1 And
	PM.OutletID=R.OutletID And
	PM.PMCode=R.PMCode And
	R.RecdDocID=PM.RecdDocID And
	R.ID=PM.ID And
	PM.Target=R.Target And
	isnull(PM.OCG,'')=isnull(R.OCG,'') And
	isnull(PM.CG,'')=isnull(R.CG,'')

	Union All

	Select distinct PM.PMID,PM.ParamID,PM.DSTypeID,PM.PMCode,PM.OutletID,C.Company_Name as OutletName,PM.Target as Targets,PM.OCG,PM.CG,R.CreationDate as DownloadedON from PMOutletAchieve PM,Customer C,Recd_PMOutletAchieve R
	Where PM.OutletId=C.CustomerID And
	R.Status=1 And
	PM.OutletID=R.OutletID And
	PM.PMCode=R.PMCode And
	R.RecdDocID=PM.RecdDocID And
	R.ID=PM.ID And
	PM.Target=R.Target And
	isnull(PM.OCG,'')=isnull(R.OCG,'') And
	isnull(PM.CG,'')=isnull(R.CG,'')

	/* Outlet wise Target Part Ends */
	
	/* Consolidated Data*/
	Select distinct @Period as Temp,@Period as [Month],P.PMCODE as [DS PM Code],P.Description as [DS PM Description],
	P.CGGroups as [Group],P.DStype as [DS Type],P.ParamType as [Parameter],P.ProdCat_Code as [Overall/Focus],
	O.OutletID as [Outlet ID],O.OutletName as [Outlet Name],O.Targets as Targets,O.OCG as OCG,O.CG as CG,convert(nvarchar(10),O.DownloadedON,103) + ' ' + convert(nvarchar(10),O.DownloadedON ,108) as [Downloaded On]
	From #PMDetails P ,#OutletDetails O
	where
	P.PMID = O.PMID And
	P.PMCode = O.PMCode And
	P.ParamID =O.ParamID And
	P.DStypeID =O.DStypeID
	union
	Select distinct @Period as Temp,@Period as [Month],P.PMCODE as [DS PM Code],P.Description as [DS PM Description],
	P.CGGroups as [Group],P.DStype as [DS Type],P.ParamType as [Parameter],P.ProdCat_Code as [Overall/Focus],
	'' as [Outlet ID],'' as [Outlet Name],NULL as Targets,'' as OCG,'' as CG,'' as [Downloaded On]
	From #PMDetails P
	where PMCode+cast(ParamID as nvarchar(10))+cast(DStypeID as nvarchar(10)) not in
	(Select PMCode+cast(ParamID as nvarchar(10))+cast(DStypeID as nvarchar(10)) from #OutletDetails)
	Order by P.PMCODE
	DROP TABLE #PMDetails
	DROP TABLE #OutletDetails
END

