Create Procedure [dbo].[mERP_spr_ListMarketPlanner](@Group nVarchar(4000),@DS nVarchar(500),
@Beat nVarchar(500),
@FromDate datetime,
@ToDate datetime,@CurDate datetime)
As
Begin
Declare @DivName as nvarchar(100)
Declare @CurrMonth as  nvarchar(8)
Declare @CustID as nvarchar(4000)
Declare @DSType as Nvarchar(100)
set dateformat dmy

Create table #TmpMarketAccompaniment(CustomerID nvarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerName nvarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS,PrevLinesCut decimal(18,6),PrevBillValue decimal(18,6),
LinesCut decimal(18,6),BillValue decimal(18,6),PrevBillCount int,BillCount int,
PBillValue decimal(18,6),PLinesCut int,TargetValue decimal(18,6))

Create table #TmpLast3week(CustomerID nvarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS,LinesCut int,Billcount decimal(18,6),BillValue decimal(18,6))
Create table #TmpCurDate(CustomerID nvarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS,LinesCut int,BillCount decimal(18,6),BillValue decimal(18,6))


Create table #TmpItems(Product_Code nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create table #tempCategory(CategoryID int,Status int)
Create table #TmpCatGroup(GroupName nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create table #TmpOutletTarget(Outletid Nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,TargetAmt decimal(18,6))


select @CurrMonth = left(DATENAME(month, @CurDate),3) +  '-' + convert(varchar(4),Year (@CurDate))

IF(select Top 1 Isnull(Flag,0) Flag from tbl_merp_Configabstract where screenCode = 'OCGDS')  = 0
Begin
If @Group='ALL'
insert into #TmpCatGroup  select distinct Top 3 CategoryGroup from tblCGDivMapping Where CategoryGroup <> 'GR4' order by CategoryGroup
Else
Declare @CG Table(CategoryGroup nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)

insert into @CG(CategoryGroup)
(Select * from dbo.sp_SplitIn2Rows(@Group, ','))
insert into #TmpCatGroup  select CategoryGroup from @CG


Declare Cur_Div Cursor for
Select Division from tblCGDivMapping where CategoryGroup in (select GroupName from #TmpCatGroup)
Open Cur_Div
Fetch From Cur_Div Into @DivName
While @@Fetch_Status = 0
Begin
Exec dbo.GetLeafCategories '%',@DivName
Insert into #TmpItems
select Product_Code from Items where
CategoryID in (select CategoryID from #tempCategory)
Truncate table #tempCategory
Fetch From Cur_Div Into @DivName
End
Close Cur_Div
Deallocate Cur_Div
Select @DSType =  DSTypeValue From DSType_Master Where DsTypeID In (Select DSTypeID From 
DSType_Details Where SalesmanID = @DS) And Active = 1 and isnull(DSTypeCtlPos , 0) = 1 And isnull(OCGType,0)=0 
End
Else
Begin
Create Table #TmpGroup (GroupId int)
Declare @GroupID nvarchar(50)
Insert into #TmpGroup (GroupId)
Select GroupID from ProductCategoryGroupAbstract where GroupName in(
Select * from dbo.sp_SplitIn2Rows(@Group, ','))
Declare AllGroup Cursor For select Distinct cast(GroupId as nvarchar(50)) from #TmpGroup
Open AllGroup
Fetch from AllGroup into @GroupID
While @@fetch_status=0
Begin
insert into #TmpItems (Product_Code)
Select Product_code from Fn_GetOCGSKU(@GroupID)
Fetch next from AllGroup into @GroupID
End
Close AllGroup
Deallocate AllGroup

Select @DSType = DSTypeValue From DSType_Master Where DsTypeID In (Select DSTypeID From DSType_Details Where
SalesmanID = @DS) And Active = 1 and isnull(DSTypeCtlPos , 0) = 1 And isnull(OCGType,0)=1 
End
/*Insert into #TmpMarketAccompaniment(CustomerID,CustomerName)
Select distinct IA.CustomerID,
CS.Company_Name
From InvoiceAbstract IA,  Customer CS
Where dbo.striptimefromdate(IA.InvoiceDate)
Between dbo.striptimefromdate(@FromDate) and dbo.striptimefromdate(@CurDate)
And (isNull(IA.Status,0) & 128 = 0 )
And CS.CustomerID = IA.CustomerID
And IA.SalesmanID=@DS
And IA.BeatID=@Beat
And (select count(*) from #TmpItems,InvoiceDetail ID where ID.InvoiceID=IA.InvoiceID
And #TmpItems.Product_Code=ID.Product_Code) > 0  */

insert into  #TmpCatGroup (GroupName) Select GroupName from ProductCategoryGroupAbstract where GroupName in(
Select * from dbo.sp_SplitIn2Rows(@Group, ','))


Insert into #TmpMarketAccompaniment(CustomerID,CustomerName)
select distinct C.CustomerID,C.Company_Name
from Beat_Salesman B,Customer C
where B.BeatID=@Beat and B.SalesmanID=@DS
and C.CustomerID=B.CustomerID
and C.Active=1


Insert into #TmpLast3week(CustomerID,Billcount,LinesCut,BillValue)
Select IA.CustomerID,case when IA.InvoiceID > 0 then 1 else 1 end,Count(Distinct ID.Product_Code),
Sum(Case IA.InvoiceType
When 4 Then	0 - (ID.Amount)
Else ID.Amount
End)
From InvoiceAbstract IA, InvoiceDetail ID, Customer CS
,#TmpMarketAccompaniment Tmp
Where dbo.striptimefromdate(IA.InvoiceDate) Between dbo.striptimefromdate(@FromDate)
And dbo.striptimefromdate(@ToDate)
And (isNull(IA.Status,0) & 128 = 0)
And IA.InvoiceType In(1,3)
And IA.InvoiceID = ID.InvoiceID
And CS.CustomerID = IA.CustomerID
and IA.CustomerID=Tmp.CustomerID
/*And IA.SalesmanID=@DS
And IA.BeatID=@Beat*/
And ID.Product_Code in (select #TmpItems.Product_Code from #TmpItems
where #TmpItems.Product_Code=ID.Product_Code)
Group by IA.CustomerID,IA.InvoiceID



Insert into #TmpLast3week(CustomerID,Billcount,LinesCut,BillValue)
Select IA.CustomerID,case when IA.InvoiceID > 0 then 0 else 0 end,0,0-Sum(ID.Amount)
From InvoiceAbstract IA, InvoiceDetail ID, Customer CS
,#TmpMarketAccompaniment Tmp
Where dbo.striptimefromdate(IA.InvoiceDate) Between dbo.striptimefromdate(@FromDate)
And dbo.striptimefromdate(@ToDate)
And (isNull(IA.Status,0) & 128 = 0 )
And IA.InvoiceType In(4)
And IA.InvoiceID = ID.InvoiceID
And CS.CustomerID = IA.CustomerID
And IA.CustomerID=Tmp.CustomerID
/*And IA.SalesmanID=@DS
And IA.BeatID=@Beat*/
And ID.Product_Code in (select #TmpItems.Product_Code from #TmpItems
where #TmpItems.Product_Code=ID.Product_Code)
Group by IA.CustomerID,IA.InvoiceID


select CustomerID,cast(sum(Billcount) as decimal(18,6)) as BillCount,sum(LinesCut) as LinesCut,
sum(BillValue) as BillValue
into  #TmpLast3week1
from #TmpLast3week  group by #TmpLast3week.CustomerID

Insert into #TmpCurDate(CustomerID,Billcount,LinesCut,BillValue)
Select IA.CustomerID,case when IA.InvoiceID > 0 then 1 else 1 end,
Count(Distinct ID.Product_Code),
Sum(Case IA.InvoiceType
When 4 Then	0 - (ID.Amount)
Else ID.Amount
End)
From InvoiceAbstract IA, InvoiceDetail ID, Customer CS
Where dbo.striptimefromdate(IA.InvoiceDate) Between dbo.striptimefromdate(@CurDate)
And dbo.striptimefromdate(@CurDate)
And (isNull(IA.Status,0) & 128 = 0)
And IA.InvoiceType In(1,3)
And IA.InvoiceID = ID.InvoiceID
And CS.CustomerID = IA.CustomerID
And IA.SalesmanID=@DS
And IA.BeatID=@Beat
And ID.Product_Code in (select #TmpItems.Product_Code from #TmpItems where #TmpItems.Product_Code=ID.Product_Code)
Group by IA.CustomerID,IA.InvoiceID


Insert into #TmpCurDate(CustomerID,Billcount,LinesCut,BillValue)
Select IA.CustomerID,case when IA.InvoiceID > 0 then 0 else 0 end,0,0-Sum(ID.Amount)
From InvoiceAbstract IA, InvoiceDetail ID, Customer CS
Where dbo.striptimefromdate(IA.InvoiceDate) Between dbo.striptimefromdate(@CurDate)
And dbo.striptimefromdate(@CurDate)
And (isNull(IA.Status,0) & 128 = 0 )
And IA.InvoiceType In(4)
And IA.InvoiceID = ID.InvoiceID
And CS.CustomerID = IA.CustomerID
And IA.SalesmanID=@DS
And IA.BeatID=@Beat
And ID.Product_Code in (select #TmpItems.Product_Code from #TmpItems
where #TmpItems.Product_Code=ID.Product_Code)
Group by IA.CustomerID,IA.InvoiceID



select #TmpCurDate.CustomerID,cast(sum(Billcount) as decimal(18,6)) as BillCount,
sum(LinesCut) as LinesCut,sum(BillValue) as BillValue
into  #TmpCurDate1
from #TmpCurDate  group by #TmpCurDate.CustomerID


select @CustID = Coalesce(@CustID + ',','') + CustomerID from #TmpMarketAccompaniment

Truncate table #TmpOutletTarget
--if not exists (select ScreenCode From tbl_merp_configabstract Where ScreenCode = 'OCGDS' and Flag = 1)
--Begin
--insert into #TmpOutletTarget
--select GGDROutlet.OutletID,sum(GGDROutlet.Target) Target from GGDROutlet,GGDRProduct,#TmpMarketAccompaniment Where  GGDROutlet.OutletID =  #TmpMarketAccompaniment.CustomerID And  GGDROutlet.ProdDefnid =  GGDRProduct.ProdDefnid
--And GGDROutlet.Active = 1 And GGDRProduct.IsExcluded  = 0  and Products = 'ALL' and CatGroup in  (select GroupName from #TmpCatGroup)
--And FromDate = @CurrMonth and Todate = @CurrMonth Group by OutletID,OutletID
--End
--Else
--Begin
--insert into #TmpOutletTarget
--select GGDROutlet.OutletID,sum(GGDROutlet.Target) Target from GGDROutlet,GGDRProduct,#TmpMarketAccompaniment Where  GGDROutlet.OutletID =  #TmpMarketAccompaniment.CustomerID And  GGDROutlet.ProdDefnid =  GGDRProduct.ProdDefnid
--And GGDROutlet.Active = 1 And GGDRProduct.IsExcluded  = 0  and Products = 'ALL' and OCG in  (select GroupName from #TmpCatGroup)
--And FromDate = @CurrMonth and Todate = @CurrMonth Group by OutletID,OutletID
--End

insert into #TmpOutletTarget select * from dbo.Fn_PMOutletlevelTarget(@CurrMonth,@Group,@custid,@DSType)




Update  #TmpMarketAccompaniment set PrevLinesCut=(select LinesCut/(case when isnull(BillCount,0)=0 then 1 else BillCount end) from #TmpLast3week1 where CustomerID=#TmpMarketAccompaniment.CustomerID),
PrevBillValue=(select BillValue/(case when isnull(BillCount,0)=0 then 1 else BillCount end) from #TmpLast3week1 where CustomerID=#TmpMarketAccompaniment.CustomerID),
LinesCut=(select LinesCut from #TmpCurDate1 where CustomerID=#TmpMarketAccompaniment.CustomerID),
BillValue=(select BillValue from #TmpCurDate1 where CustomerID=#TmpMarketAccompaniment.CustomerID),
PrevBillCount=(select BillCount from #TmpLast3week1 where CustomerID=#TmpMarketAccompaniment.CustomerID),
BillCount=(select BillCount from #TmpCurDate1 where CustomerID=#TmpMarketAccompaniment.CustomerID),
PBillValue=(select BillValue from #TmpLast3week1 where CustomerID=#TmpMarketAccompaniment.CustomerID),
PLinesCut=(select LinesCut from #TmpLast3week1 where CustomerID=#TmpMarketAccompaniment.CustomerID)


Update #TmpMarketAccompaniment set #TmpMarketAccompaniment.TargetValue = #TmpOutletTarget.TargetAmt From #TmpMarketAccompaniment,#TmpOutletTarget  Where #TmpMarketAccompaniment.CustomerId =
#TmpOutletTarget.Outletid


/* For New Columns Start */




Alter Table #TmpMarketAccompaniment Add LoyaltyProgram nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS, LastMonthSales decimal(18,6)
Create Table #tmpInv(CustomerID nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,NetValue decimal(18,6))

Declare @LMFromdate Datetime
Declare @LMTodate Datetime
/* Last Month Last Date*/
set @LMTodate= dateadd(d,-1,'01-'+cast(month(@CurDate) as varchar(20))+'-'+cast(year(@CurDate) as varchar(20)))
/* Last Month First Date*/
set @LMFromdate= dateadd(m,-1,'01-'+cast(month(@CurDate) as varchar(20))+'-'+cast(year(@CurDate) as varchar(20)))

update T set T.LoyaltyProgram=OLC.SubOutlet_Type_Desc
From tbl_mERP_OLClass OLC, tbl_mERP_OLClassMapping OLM,#TmpMarketAccompaniment T
Where T.CustomerID=OLM.CustomerID
And OLM.OLClassID = OLC.ID
And OLM.Active = 1

insert into #tmpInv(CustomerID,NetValue)
Select IA.CustomerID, Sum(Case IA.InvoiceType
When 4 Then	0 - (ID.Amount)
Else ID.Amount
End)
From InvoiceAbstract IA, InvoiceDetail ID, Customer CS
,#TmpMarketAccompaniment Tmp
Where dbo.striptimefromdate(IA.InvoiceDate) Between dbo.striptimefromdate(@LMFromdate)
And dbo.striptimefromdate(@LMTodate)
And (isNull(IA.Status,0) & 128 = 0)
And IA.InvoiceID = ID.InvoiceID
And CS.CustomerID = IA.CustomerID
and IA.CustomerID=Tmp.CustomerID
--And IA.SalesmanID=@DS
--And IA.BeatID=@Beat
And ID.Product_Code in (select #TmpItems.Product_Code from #TmpItems
where #TmpItems.Product_Code=ID.Product_Code)
Group by IA.CustomerID

update T set T.LastMonthSales=isnull(I.NetValue,0)
From #TmpMarketAccompaniment T,#tmpInv I
Where T.CustomerID=I.CustomerID

/* For New Columns End */

Alter Table #TmpMarketAccompaniment Add [ContactNo] nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS

Update T Set [ContactNo]= isnull(C.MobileNumber,'') from #TmpMarketAccompaniment T,Customer C
Where  T.CustomerID=C.CustomerID

select * from #TmpMarketAccompaniment order by CustomerName



Truncate table #TmpMarketAccompaniment
Truncate table #TmpCurDate
Truncate table #TmpLast3week
Truncate table #TmpCatGroup

Drop Table #TmpMarketAccompaniment
Drop Table #TmpCurDate
Drop Table #TmpLast3week
Drop Table #TmpCurDate1
Drop table #TmpLast3week1
Drop table #TmpItems
Drop table #tempCategory
Drop table #TmpCatGroup
Drop Table #tmpInv
--Drop Table #TmpGroup
End
