Create Function dbo.mERP_FN_V_SD_Outletflag()
Returns  
 
@FinalOutput Table(OutletID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
Company_Name nvarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS,
CatGrp nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
OCG nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,
SDFlag nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
ProdDefnID int,
CatGroupFlag int,
CurrentSDFlag nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,DSID int,
PMCategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

--AS
BEGIN

Declare @DSCG Table (DSID int,CG nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Insert into @DSCG Select SalesmanID,GroupName from dbo.fn_CG_View()
Declare @GGRRMonth DateTime
Select @GGRRMonth = cast(cast('01-' as nvarchar(3)) + cast(month(getdate()) as nvarchar(10)) + '-' + cast(year(getdate()) as nvarchar(4)) as datetime)
Declare @RepMonth DateTime
select @RepMonth = dbo.striptimefromdate(getdate())
Declare @StrGGRR nvarchar(10)
select @StrGGRR = cast(month(getdate()) as nvarchar(10)) + '-' + cast(year(getdate()) as nvarchar(4))
Declare @OCGFlag as Int
set @OCGFlag = (Select Top 1 isnull(Flag,0) from tbl_merp_Configabstract Where ScreenCode = 'OCGDS')

Declare @Output Table(OutletID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
Company_Name nvarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS,
CatGrp nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
OCG nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,
SDFlag nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
ProdDefnID int,
CatGroupFlag int,
CurrentSDFlag nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,DSID int,
PMCategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert into @Output (OutletID,Company_Name,CatGrp,OCG,SDFlag,ProdDefnID,CatGroupFlag,CurrentSDFlag,DSID,PMCategory)
Select Distinct isnull(G.OutletID,'') as OutletID,
C.Company_Name,
Case When isnull(G.CatGroup,'')='' then isnull(G.OCG,'') else isnull(G.Catgroup,'') end as CatGrp,
Case When isnull(G.OCG,'')='' Then isnull(G.Catgroup,'')  else isnull(G.OCG,'') end as OCG,
isnull(G.OutletStatus,'') as SDFlag,
isnull(ProdDefnID,'') as ProdDefnID,
Case When isnull(G.CatGroup,'')='' then 0 else 1 end as CatGroupFlag,
'' as CurrentSDFlag,BS.SalesmanID, G.PMCatGroup
From GGDROutlet G,Customer C,Beat_Salesman BS,@DSCG DS
Where @RepMonth between G.ReportFromDate and G.ReportToDate and
--where Cast(cast('01-' as nvarchar(3))+Substring(DateName(mm, Getdate()), 1, 3) + '-' + DateName(YYYY, Getdate()) as datetime)
--Between cast(('01-' + G.Fromdate) as DateTime) and cast(('01-' + G.Todate) as DateTime) And
G.OutletID = C.CustomerID and
isnull(C.Active,0)=1 And
G.Active=1 And
Bs.CustomerID=C.CustomerID and
BS.SalesmanId in (Select S.salesmanID From DSType_Details dd, DSType_Master dm,Salesman S 
	Where dd.DSTypeID = dm.DSTypeID And dm.DSTypeName = 'Handheld DS' And dm.DSTypeValue = 'Yes' 
	And DD.SalesmanID=S.SalesmanID
	And isnull(S.Active,0)=1
	And isnull(Dm.Active,0)=1)
And DS.DSID = BS.SalesmanID
And 
( DS.CG = G.CatGroup
OR
DS.CG=G.OCG)

Insert Into @FinalOutput
Select Distinct OutletID,Company_Name,CatGrp,OCG,SDFlag,ProdDefnId,CatGroupFlag,CurrentSDFlag,DSID,PMCategory From @Output
Where SDFlag <> 'R'

Insert Into @FinalOutput
Select Distinct OutletID,Company_Name,'','',SDFlag,0,CatGroupFlag,CurrentSDFlag,DSID,PMCategory From @Output
Where SDFlag = 'R'



update O Set O.CatGrp= P.CustomerCategory,OCG = P.CustomerCategory,ProdDefnID = P.MaxProdDefnID from @FinalOutput O,
(select Distinct DSID,CustomerID,CustomerCategory,MaxProdDefnID,PMCategory from GGRRFinalData
Where @GGRRMonth Between Fromdate and Todate And Status = 'Red') P
Where O.DSID=P.DSID
And O.OutletID = P.CustomerID
And O.SDFlag = 'R'
And O.PMCategory = P.PMCategory


Update O Set CurrentSDFlag=(
Case 
When M.CurrentStatus ='Green' Then 'G'
When M.CurrentStatus ='Red' Then 'R'
When M.CurrentStatus ='Eligible for Green' Then 'EG'
When M.CurrentStatus ='Neutral' Then 'N'End)
From (select Distinct DSID,DSType,CustomerID,CustomerCategory,MaxProdDefnID,CurrentStatus,PMCategory,ProdDefnID from GGRRFinalData
Where @GGRRMonth Between Fromdate and Todate) M,@FinalOutput O
Where M.DSID=O.DSID
And O.OutletID=M.CustomerID
And O.SDFlag <> 'R'
And O.ProdDefnID = M.ProdDefnID
And O.PMCategory = M.PMCategory

Update O Set CurrentSDFlag=(
Case 
When M.CurrentStatus ='Green' Then 'G'
When M.CurrentStatus ='Red' Then 'R'
When M.CurrentStatus ='Eligible for Green' Then 'EG'
When M.CurrentStatus ='Neutral' Then 'N'End)
From (select Distinct DSID,DSType,CustomerID,CustomerCategory,MaxProdDefnID,CurrentStatus,PMCategory,ProdDefnID from GGRRFinalData
Where @GGRRMonth Between Fromdate and Todate) M,@FinalOutput O
Where M.DSID=O.DSID
And O.OutletID=M.CustomerID
And O.ProdDefnID = M.ProdDefnID
And O.PMCategory = M.PMCategory
And O.SDFlag = 'R'

Update @FinalOutput Set CurrentSDFlag=SDFlag where Isnull(CurrentSDFlag,'')=''
Update @FinalOutPut set OCG = dbo.Fn_MergeCatGrp(@OCGFlag,OutletID,@StrGGRR) where OCG = ''
Update @FinalOutPut set CatGrp = OCG where Catgrp = ''
Update FO set FO.ProdDefnID = (select max(ProdDefnID) from GGDROutlet where OutletID = FO.OutletID and 
cast('01-'+ @StrGGRR as DateTime) between ReportFromDate and ReportToDate) 
from @FinalOutput FO where FO.ProdDefnID = 0

--Delete from @FinalOutput where CatGrp <>''
--select * into tt1 from @FinalOutput
Return
END
