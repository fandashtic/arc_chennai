Create Procedure mERP_SP_SaveDSTypePlan_AutoPost (@DateFrom datetime,@DateTo datetime,@LogonUser nvarchar(50))
AS
BEGIN
Set dateformat dmy
Declare @Month nvarchar(10)
Declare @TempMonth datetime
Declare @TmpDate datetime

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

Create Table #tmpDates(AllDate Datetime);

WITH T(date)
AS
( 
SELECT @DateFrom 
UNION ALL
SELECT DateAdd(day,1,T.date) FROM T WHERE T.date < @DateTo
)
insert into #tmpDates(AllDate)
SELECT date FROM T OPTION (MAXRECURSION 32767);

Declare Dates Cursor For Select AllDate from #tmpDates
Open Dates
Fetch from Dates into @TmpDate
While @@Fetch_status=0
BEGIN
		/* If CloseDay date is last day of the month*/
		if dbo.stripdatefromtime((DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@TmpDate)+1,0)))) =  dbo.stripdatefromtime(@TmpDate)
		BEGIN
			/* Add one day to get next month */
			If exists (select top 1 * from DSTypePlanning ) 
				Select @TmpDate=dateadd(d,1,@TmpDate)
	
	--		Select @TmpDate=dateadd(d,1,@TmpDate)
			/*Do posting for next month*/

			Select @month=CONVERT(varchar(3), @TmpDate )+'-'+right(CONVERT(varchar(11), @TmpDate),4)

			If not exists (Select * from DSTypePlanning where PlanMonth= @Month)
			BEGIN
				Delete from DSTypePlanning where PlanMonth= @Month
				
				set @TempMonth=cast('01-'+@Month as datetime)
				Set @TempMonth=DATEADD(mm, DATEDIFF(mm, 0, @TempMonth)-1, 0)

				--CG
				If (Select isnull(Flag,0) From Tbl_merp_Configabstract Where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup')=0
				BEGIN
					insert into DSTypePlanning(PlanMonth,DSTypeID,LogonUser)
					Select @Month,M.DSTypeID,@LogonUser From DSType_Master M,#DStypeCGMapping D Where 
						(Case when DSTypeName = 'DSType' then 
						(Select flag from tbl_merp_Configabstract where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup') 
						Else IsNull(OCGtype, 0) 
						End) = IsNull(OCGtype, 0)
						and isnull(Active,0) = 1 And isnull(DSTypeCtlPos,0) = 1 And D.DSTypeID=M.DStypeID 
						order by M.DSTypeID
				END
				ELSE
				BEGIN
					insert into DSTypePlanning(PlanMonth,DSTypeID,LogonUser)
					Select @Month,DSTypeID,@LogonUser From DSType_Master Where 
						(Case when DSTypeName = 'DSType' then 
						(Select flag from tbl_merp_Configabstract where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup') 
						Else IsNull(OCGtype, 0) 
						End) = IsNull(OCGtype, 0)
					and isnull(Active,0) = 1 And isnull(DSTypeCtlPos,0) = 1 order by DSTypeID
				END

				/* To update plan target from previous month to current month*/
				Update D set D.Planned =isnull(Temp.Planned,0) From DSTypePlanning D,DSTypePlanning Temp
				Where D.DSTypeID=Temp.DSTypeID And
				D.PlanMonth=@Month And Temp.PlanMonth=(SELECT CONVERT(varchar(3), @TempMonth )+'-'+right(CONVERT(varchar(11), @TempMonth),4))	
			END
		END
	Fetch next from Dates into @TmpDate
END
Close Dates
Deallocate Dates
Drop Table #tmpDates
Drop Table #DStypeCGMapping

END
