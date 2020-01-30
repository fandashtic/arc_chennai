Create Function [dbo].[Fn_PMOutletlevelTarget](@CurrMonth nvarchar(8),@Group nvarchar(4000),@CustId nVarchar(4000),@DSType Nvarchar(100))  
Returns @PMOutletlevelTarget Table  
(  
        OutletID  Nvarchar(30)  COLLATE SQL_Latin1_General_CP1_CI_AS,  
        Target    Decimal(18,6)    
      
)  
AS  
BEGIN  
Declare @PMDetails Table   
(  
PMID int,  
ParamId int,  
DStypeID int,  
PMCODE nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,  
Description nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,  
CGGroups nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,  
DStype nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,  
ParamType nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,  
ProdCat_Code nvarchar(max) COLLATE SQL_Latin1_General_CP1_CI_AS  
)  
Declare  @OutletDetails Table  
(  
PMID int,  
ParamId int,  
DStypeID int,  
PMCode nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,  
OutletID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,  
OutletName nvarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS,  
Targets decimal(18,6),  
OCG  nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,  
CG nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,  
DownloadedON datetime  
)  
  
Declare  @TmpCatGrp table (GroupName nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)  
Declare  @TmpCatid table (Custid nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS)  
  
insert into @TmpCatid(Custid)   
(Select * from dbo.sp_SplitIn2Rows(@CustId, ','))  
  
  
If @Group='ALL'  
insert into @TmpCatGrp  select distinct Top 3 CategoryGroup from tblCGDivMapping Where CategoryGroup <> 'GR4' order by CategoryGroup  
Else  
insert into @TmpCatGrp(GroupName) (Select * from dbo.sp_SplitIn2Rows(@Group, ','))  
/* PM Part Starts */  
Insert into @PMDetails (PMID,ParamId,DStypeID,PMCODE,Description,CGGroups,DStype,ParamType,ProdCat_Code)  
Select distinct PMMaster.PMID,PMPARAM.ParamId,PMPARAM.DStypeID,PMMaster.PMCode,PMMaster.Description,PMMaster.CGGroups,PMDSType.DSType,'Business Achievement' as ParamType,dbo.FN_GetPMFocusProducts(PMPARAM.ParamID) as ProdCat_Code  
From tbl_merp_PMMaster PMMaster,tbl_merp_PMDSType PMDSType,tbl_merp_PMParam PMPARAM,tbl_mERP_PMParamType PMPARAMTYPE  
where  
PMMaster.PMID=PMDSType.PMID And  
PMPARAM.ParameterType=PMPARAMTYPE.ID And  
PMDSType.DSTYPEID=PMPARAM.DSTYPEID And  
isnull(PMMaster.Active,0)=1 And  
Period = @CurrMonth And  
PMPARAMTYPE.ParamType='Business Achievement'  
/* PM Part Ends */  
  
--update #PMDetails set ProdCat_Code = 'Overall' where ProdCat_Code ='all'  
/* Outlet wise Target Part Starts */  
Insert into @OutletDetails(PMID,ParamId,DStypeID,PMCode,OutletID,OutletName,Targets,OCG,CG,DownloadedON)  
Select distinct PM.PMID,PM.ParamID,PM.DSTypeID,PM.PMCode,PM.OutletID,C.Company_Name as OutletName,PM.Target as Targets,PM.OCG,PM.CG,R.CreationDate as DownloadedON from PMOutlet PM,Customer C,Recd_PMOLT R  
Where   
C.CustomerID in (select Custid From @TmpCatid) and   
PM.OutletId=C.CustomerID And  
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
  
  
  
--Select distinct @Period as Temp,@Period as [Month],P.PMCODE as [DS PM Code],P.Description as [DS PM Description],  
--P.CGGroups as [Group],P.DStype as [DS Type],P.ParamType as [Parameter],P.ProdCat_Code as [Overall/Focus],  
--O.OutletID as [Outlet ID],O.OutletName as [Outlet Name],O.Targets as Targets,O.OCG as OCG,O.CG as CG,convert(nvarchar(10),O.DownloadedON,103) + ' ' + convert(nvarchar(10),O.DownloadedON ,108) as [Downloaded On]  
--From #PMDetails P ,#OutletDetails O  
--where  
--P.PMID = O.PMID And  
--P.PMCode = O.PMCode And  
--P.ParamID =O.ParamID And  
--P.DStypeID =O.DStypeID and   
--ProdCat_Code ='all'  
  
if not exists (select ScreenCode From tbl_merp_configabstract Where ScreenCode = 'OCGDS' and Flag = 1)  
insert into @PMOutletlevelTarget  
Select O.OutletID as [Outlet ID],sum(O.Targets) as Targets  
From @PMDetails P ,@OutletDetails O  
where  
P.PMID = O.PMID And  
P.PMCode = O.PMCode And  
P.ParamID =O.ParamID And  
P.DStypeID =O.DStypeID and   
ProdCat_Code ='all'   
and isnull(O.CG,'') In (select GroupName from @TmpCatGrp)  
and P.DStype = @DSType  
Group by O.OutletID  
else  
insert into @PMOutletlevelTarget  
Select O.OutletID as [Outlet ID],sum(O.Targets) as Targets  
From @PMDetails P ,@OutletDetails O  
where  
P.PMID = O.PMID And  
P.PMCode = O.PMCode And  
P.ParamID =O.ParamID And  
P.DStypeID =O.DStypeID and   
ProdCat_Code ='all'   
and isnull(O.OCG,'') in (select GroupName from @TmpCatGrp)  
and P.DStype = @DSType  
Group by O.OutletID    
Return  
END  
