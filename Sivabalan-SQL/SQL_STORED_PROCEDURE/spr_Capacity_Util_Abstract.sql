CREATE  Procedure spr_Capacity_Util_Abstract(@ParmMonth as nVarchar(25))    
AS    
Begin

Set DateFormat DMY

Declare @PlanMonth nvarchar(10)
Declare @DaysinMonth  int 
Declare @CurrentDay   int 
Declare @TillDate DateTime 
Declare @DtMonth DateTime 
Declare @FromDate DateTime 
Declare @ToDate DateTime 
Declare @Month nVarchar(25) 
Declare @WDCode NVarchar(255) 
Declare @WDDest NVarchar(255) 
Declare @CompaniesToUploadCode NVarchar(255) 
Declare @DayClose  DateTime 

Declare @PlannedCnt	as int
Declare @ActualCnt	as int
Declare @PlanActual	as Decimal(18, 6)
Declare @PlanManDays	as Decimal(18, 6)
Declare @ActualManDays as Int
Declare @PlanActManDays	as Decimal(18, 6)

Declare @TempMonth  as nvarchar(3)
Declare @TempYear   as nvarchar(4)
Declare @FinalCnt   as int

Declare @TempDate  as Datetime
Declare @Delimeter char(1)

Set @Delimeter = '/'

Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload

Select Top 1 @WDCode = RegisteredOwner From Setup

If @CompaniesToUploadCode = N'ITC001' 
	Set @WDDest= @WDCode 
Else 
	Begin 
		Set @WDDest= @WDCode 
		Set	@WDCode= @CompaniesToUploadCode 
	End 

If (Select isNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') = 1 
	--Select @DayClose = dbo.StripTimeFromDate(LastInventoryUpload) From Setup 
	Select Top 1 @DayClose =dbo.stripTimeFromdate(DayCloseDate) From DayCloseModules Where Module = 'DSType Planning'

Set @TillDate = GetDate() 


If IsDate('01/' + @ParmMonth) > 0
	Set @DtMonth = cast(Cast('01' + '/' +  @ParmMonth as nVarchar(15)) as datetime)
Else
	Goto Repend

SELECT @PlanMonth = REPLACE(RIGHT(CONVERT(VARCHAR(20), @DtMonth, 106), 8), ' ', '-')

Select @FromDate =  Convert(nVarchar(10), @DtMonth, 103) 
Select @ToDate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@DtMonth)+1,0)) 

SELECT @TempDate = DATEADD(MM, DATEDIFF(MM, 0, @FromDate) , 0) - 1

IF Not (@DayClose = @TempDate or @DayClose >= @FromDate)
	Begin
		Select "ParmMonth" ='' , "WDCode" = '' , "WDDest" = '' , "FromDate" = '',  
			"ToDate" = '', "Count of Planned DSs" = '' , "Count of Actual No. of DSs" = '', 
			"Plan vs Actual DSs%" = '' ,
			"Plan Man Days" = '' , 
			"Actual Man Days" = '' , 
			"Plan Vs Actual ManDays%" = ''

		Goto Repend
	End


If Month(@TillDate) <> Month(@FromDate) 
	Set @TillDate = @ToDate 


Set @DaysinMonth = DateDiff(DD, @FromDate, @ToDate) + 1 
Set @CurrentDay = DateDiff(DD, @FromDate, @TillDate) + 1 


IF Not Exists(Select DSTypeID From DSTypePlanning where PlanMonth=@PlanMonth)
	Begin
		Select "ParmMonth" ='' , "WDCode" = '' , "WDDest" = '' , "FromDate" = '',  
			"ToDate" = '', "Count of Planned DSs" = '' , "Count of Actual No. of DSs" = '', 
			"Plan vs Actual DSs%" = '' ,
			"Plan Man Days" = '' , 
			"Actual Man Days" = '' , 
			"Plan Vs Actual ManDays%" = ''
		
		Goto Repend
	End	

Create Table #DStypeCGMapping(DSTypeID nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS)

If (Select isnull(Flag,0) From Tbl_merp_Configabstract Where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup')=0
BEGIN
	insert into #DStypeCGMapping(DSTypeID)
	Select Distinct DSTypeID from tbl_mERP_DSTypeCGMapping where  Active = 1 and
	 GroupID In (Select GroupID from ProductCategoryGroupAbstract)
END
ELSE
BEGIN  
	insert into #DStypeCGMapping(DSTypeID)
	Select Distinct DSTypeID from tbl_mERP_DSTypeCGMapping Where  Active = 1 and
	GroupID In (Select GroupID from ProductCategoryGroupAbstract where OCGType=1 And Active=1)
END

Create Table #TempDSTypeDetail(DSTypeID Int, SalesmanID Int, InvoiceDate DateTime)

Insert Into #TempDSTypeDetail(DSTypeID, SalesmanID, InvoiceDate)
Select DsTypeID, SalesmanID, InvoiceDate From InvoiceAbstract
Where (InvoiceAbstract.Status & 128) = 0 And                  
	InvoiceType in (1,3) AND 
	InvoiceDate BETWEEN @FromDate AND @ToDate 

Create Table #TempFinal(DSTypeID Int, DSTypeValue nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, 
						PlannedCnt  Int, ActualCnt Int, PlanActualDS Decimal(18, 6), ActualWorking Int, 
						PlannedDays Int, ActualDays Int, PlanActualDays Decimal(18, 6), Update_Date DateTime, LogonUser nVarchar(20))

Insert Into #TempFinal (DSTypeID, DSTypeValue)
Select A.DSTypeID, A.DSTypeValue from DSType_Master A, DSTypePlanning B 
Where A.DSTypeID = B.DSTypeID and B.PlanMonth = @PlanMonth
Union 
Select DSM.DSTypeID, DSM.DSTypeValue From
(Select Distinct A.DSTypeID
From #DStypeCGMapping A, #TempDSTypeDetail B
Where A.DSTypeID = B.DSTypeID 
	and A.DSTypeID Not IN(Select DSTypeID From DSTypePlanning where PlanMonth=@PlanMonth)) DS, DSType_Master DSM
Where DS.DSTypeID = DSM.DSTypeID
Order By DSTypeValue

Update T Set T.PlannedCnt = A.Planned , T.Update_Date = A.CreationDate, T.LogonUser = A.LogonUser
From #TempFinal T, DsTypePlanning A
Where T.DSTypeID = A.DSTypeID
And A.PlanMonth = @PlanMonth

Update T Set T.ActualCnt = Cnt.SCount
From #TempFinal T, 
(Select A.DsTypeID, Count(*) as SCount From
		(Select DSTypeID, SalesmanID From #TempDSTypeDetail
			Group By DsTypeID, SalesmanID) As A
Group By A.DsTypeID) Cnt
Where T.DSTypeID = Cnt.DSTypeID

Update T Set T.ActualWorking = Actual.Actualwork
From #TempFinal T,
(Select DsTypeID, Count(*) as Actualwork From
(
Select DsTypeID, SalesmanID, dbo.Striptimefromdate(InvoiceDate) as Invcnt From #TempDSTypeDetail
Group By DsTypeID, SalesmanID, dbo.Striptimefromdate(InvoiceDate)
)A
Group By DsTypeID) Actual
Where T.DsTypeID = Actual.DsTypeID

IF (@DaysinMonth = 0 ) 
	SET @DaysinMonth =1 
If (@CurrentDay = 0)
	set @CurrentDay =1 

Update #TempFinal Set PlanActualDS = Cast(ActualCnt as Decimal(18, 6)) / Cast( (case when PlannedCnt = 0 then 1 else plannedcnt end) as Decimal(18, 6)) Where ActualCnt > 0
Update #TempFinal Set ActualDays =  IsNull(ActualWorking, 0) 
Update #TempFinal Set PlannedDays = Cast(PlannedCnt as Decimal(18, 6)) * ((25.00/ Cast(@DaysinMonth as Decimal(18,6))) * Cast(@CurrentDay as Decimal(18, 6)))
Update #TempFinal Set PlanActualDays = Cast(ActualDays as Decimal(18, 6)) / Cast((case when PlannedDays = 0 then 1 else PlannedDays end) as Decimal(18, 6)) Where ActualDays > 0

Select @PlannedCnt = Sum(IsNUll(PlannedCnt, 0)) From #TempFinal
Select @ActualCnt = Sum(IsNull(ActualCnt, 0)) From #TempFinal
Select @ActualManDays = Sum(IsNull(ActualDays, 0)) From #TempFinal

Set @PlanActual = Cast(Cast(@ActualCnt as Decimal(18, 6)) / Cast((Case When @PlannedCnt = 0 then 1 else @PlannedCnt end) as Decimal(18, 6)) * 100 as Decimal(18,6))
Set @PlanManDays = Round(Cast(@PlannedCnt as Decimal(18, 6)) * ((25.00/ Cast(@DaysinMonth as Decimal(18,6))) * Cast(@CurrentDay as Decimal(18, 6))), 0)
Set @PlanActManDays = Cast(Cast(@ActualManDays as Decimal(18, 6)) / Cast((case when @PlanManDays = 0 then 1 else @PlanManDays end) as Decimal(18, 6)) * 100 as Decimal(18,6)) 

Select [ParmMonth] = @ParmMonth, [WDCode] = @WDCode, [WDDest] = @WDDest, FromDate = @FromDate, 
	[ToDate] = @ToDate, [Count of Planned DSs] = @PlannedCnt, [Count of Actual No. of DSs] = @ActualCnt, 
	[Plan vs Actual DSs%] = case when IsNull(@PlannedCnt, 0) = 0 then 'NA' else cast(IsNull(@PlanActual, 0) as nvarchar) end,
	 [Plan Man Days] = @PlanManDays, 
	[Actual Man Days] = @ActualManDays, 
	[Plan Vs Actual ManDays%] = case when IsNull(@PlannedCnt, 0) = 0 then 'NA' else cast(IsNull(@PlanActManDays, 0) as nvarchar) end


Drop Table #TempFinal
Drop Table #TempDSTypeDetail
Drop Table #DStypeCGMapping

End 

Repend:

