create procedure [dbo].[sp_PopulateGGRR_ProductView](@DayCloseFromDate DateTime = Null, @DayCloseToDate DateTime = Null)
as
Declare @StartTime as Datetime
Declare @EndTime as Datetime


Declare @LastdaycloseDate as DateTime
Declare @MonthEnddate as DateTime
Declare @MonthFirstdate as DateTime
Declare @MonthTodate as DateTime
Declare @GGDRmonth as DateTime
Declare @tmpGGDRmonth as Nvarchar(10)
Declare @OCGGlag As Int
--Declare @TmpFINALoutput Table (Salesmanid int,CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS, ProdDefnID int,SDProductCode nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,SDProductLevel int,Target decimal(18,6),TargetUOM int,MTDSales decimal(18,6),ProductFlag nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,CategoryGroup nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,DSType nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,PmCategory nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #TmpFINALoutput(Salesmanid int,CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS, ProdDefnID int,SDProductCode nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,SDProductLevel int,Target decimal(18,6),TargetUOM int,MTDSales decimal(18,6),ProductFlag nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,CategoryGroup nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,DSType nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,PmCategory nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)
Declare @Tmpoutput Table (Salesmanid int,CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS, ProdDefnID int,SDProductCode nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,SDProductLevel int,Target decimal(18,6),TargetUOM int,MTDSales decimal(18,6),ProductFlag nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,CategoryGroup nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,DSType nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)

begin

set dateformat dmy

Set @tmpGGDRmonth = (Substring(DateName(mm, Getdate()), 1, 3) + '-' + DateName(YYYY, Getdate()))
Set @OCGGlag = (Select Top 1 isnull(Flag,0) from tbl_merp_Configabstract Where ScreenCode = 'OCGDS')
Set @LastdaycloseDate = (select Top 1 LastInventoryUpload from SetUp)
Set @GGDRmonth =  cast('01-' + @tmpGGDRmonth as DateTime)
Set @MonthEnddate = (Select DateAdd(d,-1,DateAdd(m,1,Cast(('01-' + Cast(Month(Getdate())as Nvarchar) + '-' + Cast(Year(Getdate()) as Nvarchar)) as DateTime))))

--Declare @HHDS Table (SalesmanID int,CustomerID nvarchar(15)  COLLATE SQL_Latin1_General_CP1_CI_AS)
Declare @ProductwiseDet Table (Salesmanid int,CustomerID nvarchar(15)  COLLATE SQL_Latin1_General_CP1_CI_AS, ProdDefnID int,SDProductCode nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS,SalesValue decimal(18,6),DSType nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS)

Create Table #HHDS(SalesmanID int,CustomerID nvarchar(15)  COLLATE SQL_Latin1_General_CP1_CI_AS)

If exists(select 'x' from sysobjects where name like 'GGRR_AuditTrail' and xtype='U')
BEGIN
	drop Table GGRR_AuditTrail
END

CREATE TABLE [dbo].[GGRR_AuditTrail](
IFType nvarchar(250),
StartTime datetime,
EndTime datetime
)

set @StartTime=GetDate()

Insert into #HHDS
Select S.SalesmanID,C.CustomerID From
Beat_Salesman BS, Salesman S, Beat B,Customer C,DSType_Details dd, DSType_Master dm
Where
dm.DSTypeName = 'Handheld DS' And
dm.DSTypeValue = 'Yes' And
isnull(B.Active,0) = 1 And
isnull(Dm.Active,0)=1 And
isnull(C.Active,0) = 1 And
DD.SalesmanID=S.SalesmanID And
S.SalesmanId = BS.SalesmanId And
dd.DSTypeID = dm.DSTypeID And
C.CustomerID = BS.CustomerID And
isnull(S.Active,0) = 1 And
B.BeatId = BS.BeatId

set @EndTime=GetDate()

insert into GGRR_AuditTrail(IFType,StartTime,EndTime) values ('01/13 HHDS Insert',@StartTime,@EndTime)


--Declare @output Table (Salesmanid int,CustomerID nvarchar(15)  COLLATE SQL_Latin1_General_CP1_CI_AS, 
--ProdDefnID int,SDProductCode nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS,SDProductLevel int,Target decimal(18,6),TargetUOM int,
--MTDSales decimal(18,6),ProductFlag nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS,
--CategoryGroup nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS,DSType nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS,
--Status  nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS,PMcategory nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS)

--Declare @outputAlt Table (Salesmanid int,CustomerID nvarchar(15)  COLLATE SQL_Latin1_General_CP1_CI_AS, 
--ProdDefnID int,SDProductCode nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS,SDProductLevel int,Target decimal(18,6),TargetUOM int,
--MTDSales decimal(18,6),ProductFlag nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS,
--CategoryGroup nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS,DSType nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS,
--Status  nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS,PMcategory nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS)

Create Table #output(Salesmanid int,CustomerID nvarchar(15)  COLLATE SQL_Latin1_General_CP1_CI_AS, 
ProdDefnID int,SDProductCode nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS,SDProductLevel int,Target decimal(18,6),TargetUOM int,
MTDSales decimal(18,6),ProductFlag nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryGroup nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS,DSType nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS,
Status  nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS,PMcategory nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS)

Create Table #outputAlt(Salesmanid int,CustomerID nvarchar(15)  COLLATE SQL_Latin1_General_CP1_CI_AS, 
ProdDefnID int,SDProductCode nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS,SDProductLevel int,Target decimal(18,6),TargetUOM int,
MTDSales decimal(18,6),ProductFlag nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryGroup nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS,DSType nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS,
Status  nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS,PMcategory nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS)

set @StartTime=GetDate()

Insert into #output 
(Salesmanid,DSType,CustomerID, ProdDefnID,SDProductCode,SDProductLevel,Target,TargetUOM,MTDSales,ProductFlag,CategoryGroup,Status,PMcategory)
Select Distinct 
HS.SalesmanID,GD.DSType,G.OutletId as CustomerID,G.ProdDefnID,GP.Products as SDProductCode,GP.ProdCatLevel,GP.Target,GP.TargetUOM,
0  as MTDSales,GP.ProductFlag,
Isnull((Case When @OCGGlag = 0 Then G.CatGroup When @OCGGlag = 1 Then G.OCG End),'All') as CategoryGroup,G.OutletStatus,G.PMCatGroup
From GGDROutlet G,GGDRData GD,#HHDS HS,GGDRProduct GP
Where
G.OutletID=GD.RetailerCode And
G.ProdDefnID = GD.ProdDefnID And
GD.ProdDefnID = GP.ProdDefnID And
G.ProdDefnID = GP.ProdDefnID And
isnull(GP.isExcluded,0)=0 And
HS.CustomerID = G.OutletID And
HS.SalesmanID = GD.DSID And
Isnull(G.Active,0) = 1 And
@GGDRmonth Between G.ReportFromDate and G.ReportToDate And
GD.InvoiceDate Between G.ReportFromDate And @MonthEnddate

set @EndTime=GetDate()

insert into GGRR_AuditTrail(IFType,StartTime,EndTime) values ('02/13 @Output Table 1st Insert',@StartTime,@EndTime)

set @StartTime=GetDate()

update O Set O.MTDSales= P.D_Actual from #output O,
(
	select DSID,DSType,CustomerID,ProdDefnID,D_ProductCode,D_Actual from GGRRFinalData
	Where [Month] = @tmpGGDRmonth
) P
Where P.DSID=O.Salesmanid And
O.DSType = P.DSType And
O.CustomerID = P.CustomerID And
O.ProdDefnID=P.ProdDefnID And
o.SDProductCode = P.D_ProductCode

set @EndTime=GetDate()

insert into GGRR_AuditTrail(IFType,StartTime,EndTime) values ('03/13 @Output Table MTDSales Update',@StartTime,@EndTime)

set @StartTime=GetDate()

Insert into #OutputAlt(Salesmanid,DSType,CustomerID, ProdDefnID,SDProductCode,SDProductLevel,Target,TargetUOM,MTDSales,ProductFlag,CategoryGroup,Status,PMcategory)
Select Distinct 
HS.SalesmanID,'',G.OutletId as CustomerID,G.ProdDefnID,GP.Products as SDProductCode,GP.ProdCatLevel,
GP.Target,GP.TargetUOM,
0  as MTDSales,
GP.ProductFlag,
Isnull((Case When @OCGGlag = 0 Then G.CatGroup When @OCGGlag = 1 Then G.OCG End),'All') as CategoryGroup,G.OutletStatus,G.PMCatGroup
From GGDROutlet G,#HHDS HS,GGDRProduct GP
Where
G.ProdDefnID = GP.ProdDefnID And
HS.CustomerID = G.OutletID And
Isnull(G.Active,0) = 1 And
isnull(GP.isExcluded,0)=0 And
@GGDRmonth Between G.ReportFromDate and G.ReportToDate

set @EndTime=GetDate()

insert into GGRR_AuditTrail(IFType,StartTime,EndTime) values ('04/13 @OutputAlt Table Insert',@StartTime,@EndTime)

set @StartTime=GetDate()

delete from #OutputAlt where 
(CustomerID + cast(ProdDefnID as nvarchar(15)) +cast(SDProductCode as nvarchar(255))+cast(Salesmanid as nvarchar(255))) in
(
	select (Isnull(CustomerID,'') + cast(Isnull(proddefnID,0) as nvarchar(15)) +cast(Isnull(SDProductCode,'') as nvarchar(255))
    +cast(Isnull(salesmanid,0) as nvarchar(255))) from #output
)

set @EndTime=GetDate()

insert into GGRR_AuditTrail(IFType,StartTime,EndTime) values ('05/13 @OutputAlt Table Delete',@StartTime,@EndTime)

set @StartTime=GetDate()

insert into #Output
select * from #OutputAlt

set @EndTime=GetDate()

insert into GGRR_AuditTrail(IFType,StartTime,EndTime) values ('06/13 @OutputAlt Table Insert into @Output',@StartTime,@EndTime)

set @StartTime=GetDate()

Update O Set O.DSType = FN.DStype From  #output O, dbo.mERP_FN_getDSDStype_View() FN
Where FN.DSID=O.SalesmanID

set @EndTime=GetDate()

insert into GGRR_AuditTrail(IFType,StartTime,EndTime) values ('07/13 @Output Table DS Type Update',@StartTime,@EndTime)

set @StartTime=GetDate()

Update T Set T.SDProductCode = V.category_ID From #output T, V_Category_Master V
Where V.Category_Name = T.SDProductCode And V.[Level] = T.SDProductLevel And T.SDProductLevel In (2,3,4)
And T.SDProductCode <>'ALL'

set @EndTime=GetDate()

insert into GGRR_AuditTrail(IFType,StartTime,EndTime) values ('08/13 @Output Table Product Code Update',@StartTime,@EndTime)

set @StartTime=GetDate()


Update T set T.Target = T1.Target,T.TargetUOM = T1.TargetUOM From #output T,
(Select OutletID,Sum(Target) Target,TargetUOM,OutletStatus,PMCatGroup,ProdDefnId From ggdroutlet
Where Isnull(OutletStatus,'') = 'R' And @GGDRmonth Between ReportFromdate and ReportTodate  Group By OutletID,TargetUOM,OutletStatus,PMCatGroup,ProdDefnId) T1
Where Isnull(T.SDProductCode,'')  = 'All'
And T.CustomerID = T1.OutletID
And T.PMcategory = T1.PMCatGroup
And T.ProdDefnId = T1.ProdDefnId

set @EndTime=GetDate()

insert into GGRR_AuditTrail(IFType,StartTime,EndTime) values ('09/13 @Output Table Target Update',@StartTime,@EndTime)


Declare @DSGroupName Table(DSID int,GroupName nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert into @DSGroupName 
Select SalesmanID,GroupName from dbo.fn_CG_View()

Declare @DSDSType Table(DSID int,DSType nvarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS)
Insert into @DSDSType 
Select DSID,DSType from dbo.mERP_FN_getDSDStype_View()

set @StartTime=GetDate()

If exists(select 'x' from sysobjects where name like 'GGRRProdFinal' and xtype='U')
BEGIN
	drop Table GGRRProdFinal
END

CREATE TABLE [dbo].[GGRRProdFinal](
	[Salesmanid] [int] NULL,
	[CustomerID] [nvarchar](15) NULL,
	[ProdDefnID] [int] NULL,
	[SDProductCode] [nvarchar](256) NULL,
	[SDProductLevel] [int] NULL,
	[Target] [decimal](18, 6) NULL,
	[TargetUOM] [int] NULL,
	[MTDSales] [decimal](18, 6) NULL,
	[ProductFlag] [nvarchar](256) NULL,
	[CategoryGroup] [nvarchar](256) NULL,
	[DSType] [nvarchar](256) NULL
)

Insert into GGRRProdFinal
Select A.Salesmanid ,A.CustomerID,A.ProdDefnID,A.SDProductCode,A.SDProductLevel,
A.Target,A.TargetUOM,A.MTDSales,A.ProductFlag,A.CategoryGroup,A.DSType 
From
(
	Select A.Salesmanid ,A.CustomerID,A.ProdDefnID,A.SDProductCode,A.SDProductLevel,Sum(A.Target) Target,A.TargetUOM,A.MTDSales,A.ProductFlag,
	A.CategoryGroup,A.DSType,A.Status 
	From #output A
	Group By A.Salesmanid ,A.CustomerID,A.ProdDefnID,A.SDProductCode,A.SDProductLevel,A.TargetUOM,A.MTDSales,A.ProductFlag,A.CategoryGroup,
	A.DSType,A.Status
) A, @DSGroupName G,@DSDSType D
Where A.SalesmanID=G.DSID And
A.CategoryGroup=G.GroupName And
A.SalesmanID=D.DSID And
A.[DSType]=D.DSType
And A.Status <> 'R'

set @EndTime=GetDate()

insert into GGRR_AuditTrail(IFType,StartTime,EndTime) values ('10/13 Final Output Table 1st Insert',@StartTime,@EndTime)

--/* As Per GGRR-FRITFITC-72 "V_SD_OutletflagProd" Changes The Month Till date should be computed based on the DSID, Outlet ID and all the Product definition ID (the category Groups defined in PM Cat Group column) for that combination. The Sum of Achieved value should be displayed in MTD Sales with Max of Product Definition ID. */

set @StartTime=GetDate()

insert into #TmpFINALoutput
Select A.Salesmanid ,A.CustomerID,max(A.ProdDefnID),A.SDProductCode,A.SDProductLevel,SUM(A.Target),A.TargetUOM,
sum(A.MTDSales),A.ProductFlag,max(A.CategoryGroup),A.DSType,A.PmCategory 
From
#output A, @DSGroupName G,@DSDSType D
Where A.SalesmanID=G.DSID And
A.CategoryGroup=G.GroupName And
A.SalesmanID=D.DSID And
A.[DSType]=D.DSType
And A.Status= 'R'
group by a.Customerid,a.SalesmanID,A.SDProductCode,A.SDProductLevel,A.TargetUOM,A.ProductFlag,A.DSType,A.PmCategory

set @EndTime=GetDate()

insert into GGRR_AuditTrail(IFType,StartTime,EndTime) values ('11/13 @TempFinal Insert for Red',@StartTime,@EndTime)

set @StartTime=GetDate()

update O Set O.CategoryGroup= P.CustomerCategory,ProdDefnID = MaxProdDefnID from #TmpFINALoutput O,
(select Distinct DSID,DSType,CustomerID,CustomerCategory,MaxProdDefnID,PMcategory from GGRRFinalData
Where [Month] = @tmpGGDRmonth And Status = 'Red') P
Where O.Salesmanid=P.DSID And
O.DSType = P.DSType And
O.CustomerID = P.CustomerID
And O.PMcategory = P.PMcategory

set @EndTime=GetDate()

insert into GGRR_AuditTrail(IFType,StartTime,EndTime) values ('12/13 @TempFinal Category Group Update for Red',@StartTime,@EndTime)

set @StartTime=GetDate()


Insert into GGRRProdFinal
Select Distinct Salesmanid ,CustomerID , ProdDefnID ,SDProductCode ,SDProductLevel ,Target ,TargetUOM ,MTDSales ,ProductFlag ,CategoryGroup ,DSType  from #TmpFINALoutput

set @EndTime=GetDate()

insert into GGRR_AuditTrail(IFType,StartTime,EndTime) values ('13/13 Final Output Table Insert for Red',@StartTime,@EndTime)

IF @DayCloseFromDate is Not Null
	Begin
		Update DayCloseTracker Set Status = 1 Where dbo.StripDateFromTime(DayCloseDate) Between @DayCloseFromDate and @DayCloseTodate and Module = 'GGDRView'
	End

Drop Table #TmpFINALoutput
Drop Table #HHDS
Drop Table #Output
Drop Table #OutputAlt

END
