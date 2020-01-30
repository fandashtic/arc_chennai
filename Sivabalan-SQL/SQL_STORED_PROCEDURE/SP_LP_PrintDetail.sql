Create Procedure SP_LP_PrintDetail(@CustomerID nvarchar(15))
AS
BEGIN
	SET Dateformat DMY
	Declare @SQL as nvarchar(max)

	Declare @TargetMonth nvarchar(150)
	Declare @AchivedTill nvarchar(150)
	Declare @LPDate as datetime 
	Declare @Dayclose as datetime
	Declare @AchivedIn nvarchar(150)
	Declare @Achievedtodate as datetime
	
	Declare @MaxPostdate as datetime
	Declare @LastDayclosedate as datetime
	Declare @TargetTodate as Datetime
	Declare @GraceDate as Datetime
	Declare @Printflag as int
	Declare @MaxDate as datetime
    Declare @MaxPeriod as nvarchar(25)

	Create Table #tmpLP (Product nvarchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,TargetMonth decimal(18,6),
	AchivedTill decimal(18,6),AchivedIn decimal(18,6),Balance decimal(18,6),sequenceno int)
	Create table #tmpDate (Data dateTime)

	Select @MaxDate =  max(cast(('01/'+(Right(Period,2) + '/' +  Left(Period,4)))as DateTime)) from LP_AchievementDetail where isnull(active,0)=1 and customerID= @customerID
	Set @MaxPeriod= CONVERT(VARCHAR(7), @MaxDate, 126)

	/* if @Printflag is 1 then we will not consider AchivedTill column for printing */
	if (select top 1 dbo.stripdatefromtime(Transactiondate) from setup) <= (select top 1 dbo.stripdatefromtime(isnull(GraceDate,getdate())) from LP_AchievementDetail where isnull(active,0)=1 and customerID= @customerID And Period =@MaxPeriod)
	Begin	
		if (select top 1 dbo.stripdatefromtime(Transactiondate) from setup) > (select top 1 isnull(achievedTo,getdate()) from LP_AchievementDetail where isnull(active,0)=1 and customerID= @customerID And Period =@MaxPeriod)
		Begin
			/* We are not checking the flag for each customer since we know that achivementto column will be blank for complete set 
			and will not change for each customer*/
			select top 1 @Printflag= isnull(Printflag,0) from LP_AchievementDetail where isnull(active,0)=1 and CustomerID=@CustomerID And Period =@MaxPeriod
			select Top 1 @LPDate='01' +'-'+ left(Period,4)+'-'+Right(Period,2) from LP_AchievementDetail where isnull(active,0)=1 and customerID= @customerID And Period =@MaxPeriod
			
			Select top 1 @Achievedtodate = isnull(AchievedTo+1,getdate()) from LP_AchievementDetail where isnull(active,0)=1 and CustomerID=@CustomerID And Period =@MaxPeriod
			select Top 1 @Dayclose= max(Dayclose) from lpcustomerscore where Dayclose > @Achievedtodate and period in (select isnull(period,'') from LP_AchievementDetail where isnull(active,0)=1 and CustomerID=@CustomerID And Period =@MaxPeriod)
			and program_type in (select isnull(program_type,'') from LP_AchievementDetail where isnull(active,0)=1 and CustomerID=@CustomerID And Period =@MaxPeriod)
			if @Dayclose is null
					select top 1 @Dayclose= dbo.stripdatefromtime(Lastinventoryupload) from setup

			Select top 1 @TargetMonth= 'Target ('+ left(convert(varchar, TargetFrom, 107),3) from LP_AchievementDetail where isnull(active,0)=1 and CustomerID=@CustomerID And Period =@MaxPeriod
			Select top 1 @TargetMonth= @TargetMonth + ' to ' + left(convert(varchar, Targetto, 107),3) from LP_AchievementDetail where isnull(active,0)=1 and CustomerID=@CustomerID And Period =@MaxPeriod
			Select top 1 @TargetMonth= @TargetMonth + ' ' + cast(year (Targetto) as varchar)+')' from LP_AchievementDetail where isnull(active,0)=1 and CustomerID=@CustomerID	And Period =@MaxPeriod
			Select top 1 @AchivedTill= 'Achv. till '+cast(right(convert(varchar, AchievedTo, 106), 8) as varchar) from LP_AchievementDetail where isnull(active,0)=1 and CustomerID=@CustomerID	 And Period =@MaxPeriod

			select top 1 @LastDayclosedate= dbo.stripdatefromtime(Lastinventoryupload) from setup
			Select Top 1 @MaxPostdate = isnull(max(dbo.stripdatefromtime(Dayclose)),getdate()) from lpcustomerscore where period in (select isnull(period,'') from LP_AchievementDetail where isnull(active,0)=1 and CustomerID=@CustomerID and isnull(dayclose,getdate()) > isnull(achievedTo+1,getdate()) And Period =@MaxPeriod)
			And program_type in (select isnull(program_type,'') from LP_AchievementDetail where isnull(active,0)=1 and CustomerID=@CustomerID and isnull(dayclose,getdate()) > isnull(achievedTo+1,getdate()) And Period =@MaxPeriod) 

			Select Top 1 @TargetTodate = isnull(max(dbo.stripdatefromtime(TargetTo)),getdate()) from LP_AchievementDetail where isnull(active,0)=1 and CustomerID=@CustomerID And Period =@MaxPeriod	
			Select Top 1 @GraceDate = isnull(max(dbo.stripdatefromtime(GraceDate)),getdate()) from LP_AchievementDetail where isnull(active,0)=1 and CustomerID=@CustomerID	And Period =@MaxPeriod

			insert into #tmpDate (Data) select @LastDayclosedate
			insert into #tmpDate (Data) select @MaxPostdate

			if (@LastDayclosedate <=@TargetTodate)
			and (@MaxPostdate <= @TargetTodate)
				Select top 1 @AchivedIn= 'Addl.Achv. till '+cast(right(convert(varchar, (select max(Data) from #tmpDate), 106), 8) as varchar)
			else
				if @LastDayclosedate <= @GraceDate
					Select top 1 @AchivedIn= 'Addl.Achv. till '+cast(right(convert(varchar, dbo.stripdatefromtime(@TargetToDate), 106), 8) as varchar)

			insert into #tmpLP (Product,TargetMonth,AchivedTill,AchivedIn,sequenceno)
			Select LA.ProductScope,Targetval,AchievedVal,sum(isnull(Achieved,0)),sequenceno
			from LP_AchievementDetail LA
			Left Outer Join lpcustomerscore LC On LA.Period= LC.Period And LA.CustomerID = LC.CustomerID And LA.ProductScope = LC.ProductScope And LA.Program_type = LC.Program_type
			where isnull(LA.active,0)=1 
			And isnull(LC.Dayclose,getdate()) > isnull(LA.Achievedto,getdate())
			and LA.CustomerID = @CustomerID
			And LA.Period =@MaxPeriod
			Group by Targetval,AchievedVal,LA.ProductScope,sequenceno
			order by sequenceno

			if (Select count(*) from #tmpLP) <> 0 
			BEGIN	
				if @Printflag = 0 
				begin
					/* To get Total of LP details*/
					insert into #tmpLP (Product,TargetMonth,AchivedTill,AchivedIn)
					Select 'Total',Sum(isnull(TargetMonth,0)),sum(isnull(AchivedTill,0)),sum(isnull(AchivedIn,0)) from  #tmpLP

					update #tmpLP set balance=
					case When (isnull(TargetMonth,0)-(isnull(AchivedTill,0)+isnull(AchivedIn,0))) < 0 
					then 0 else isnull(TargetMonth,0)-(isnull(AchivedTill,0)+isnull(AchivedIn,0)) end
					where Product <> 'Total'

					update #tmpLP set balance  = T. Balance from (Select sum(isnull(balance,0)) as Balance from #tmpLP) T
					Where Product = 'Total'
				end
				else
				begin
					insert into #tmpLP (Product,TargetMonth,AchivedIn)
					Select 'Total',Sum(isnull(TargetMonth,0)),sum(isnull(AchivedIn,0)) from  #tmpLP

					update #tmpLP set balance=
					case When (isnull(TargetMonth,0)-(isnull(AchivedIn,0))) < 0 
					then 0 else isnull(TargetMonth,0)-(isnull(AchivedIn,0)) end
					where Product <> 'Total'

					update #tmpLP set balance  = T. Balance from (Select sum(isnull(balance,0)) as Balance from #tmpLP) T
					Where Product = 'Total'	
				end				
			End 

			set @SQL='Select Product,TargetMonth as['+ @TargetMonth+'],AchivedTill as['+ @AchivedTill+'],AchivedIn as ['+@AchivedIn+'],Balance,(select top 1 isnull(Printflag,0) from LP_AchievementDetail where CustomerID = '''+ @CustomerID + '''And isnull(active,0)=1 And period ='''+@MaxPeriod+''''+' )
			from #tmpLP'

			exec sp_executesql @SQL
		End
	End
Drop table #tmpLP
drop table #tmpDate
END
