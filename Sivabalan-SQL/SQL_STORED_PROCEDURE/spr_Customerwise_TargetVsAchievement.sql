CREATE Procedure spr_Customerwise_TargetVsAchievement(
					@salesman Nvarchar(4000),
					@Beat Nvarchar(4000),
					@Customerid Nvarchar(4000),
					@Customername Nvarchar(4000))  
As  
Begin
Declare @Trandate as DateTime
Set @Trandate = (select dbo.stripTimeFromdate(Transactiondate) from setup)


	Set DateFormat DMY 
	Declare @MaxDate as datetime
    Declare @MaxPeriod as nvarchar(25)

	Declare @Lastdayclosedate as datetime
	Declare @Delimeter as nVarchar
	Set @Delimeter = Char(15)
	Create Table #tmpSman(SalesmanID Int) 
	Create Table #tmpBeat(BeatID Int) 
	Create Table #tmpCustid(CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS) 
	Create Table #tmpCustname(Customername Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS) 
	Create TABLE #TmpCustMaster (
							Customerid Nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,
							Salesmanid Int,
							Beatid Int)

	CREATE TABLE #TempOut(
		[CustomerID] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CustomerName] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Target] Decimal(18, 6) NOT NULL,
		[Achievement] Decimal(18, 6) NOT NULL,
		[PercentageAchieved] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LastDayCloseDate] [datetime] NOT NULL,
		[ReportGenerationDateandTime] [datetime] NOT NULL DEFAULT (getdate()),
		[Period] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Program_Type] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL) 
	Declare @TgtPeriod nvarchar(20)

	If @Trandate <= (select dbo.stripTimeFromdate(Max(TargetTo)) from LP_AchievementDetail Where Active = 1)
		Begin
			--Set @Lastdayclosedate = (select dbo.stripTimeFromdate(lastinventoryupload) from Setup)
			Set @Lastdayclosedate = (Select Top 1 dbo.stripTimeFromdate(DayCloseDate) From DayCloseModules Where Module = 'Loyalty Program')
		End
	Else If @Trandate >= (select dbo.stripTimeFromdate(Max(TargetTo)) from LP_AchievementDetail Where  Active = 1) and @Trandate <= (select dbo.stripTimeFromdate(max(GraceDate)) from LP_AchievementDetail Where  Active = 1)
		Begin
			Set @Lastdayclosedate = (select dbo.stripTimeFromdate(Max(TargetTo)) from LP_AchievementDetail Where  Active = 1)
		End

	If @salesman = '%' Or @salesman = N''    
		Insert Into #tmpSman    
		Select SalesmanID From Salesman    
	Else    
		Insert Into #tmpSman    
		Select SalesmanID From Salesman Where Salesman_Name In (Select * From dbo.sp_splitin2Rows(@salesman,@Delimeter))    

	If @Beat = '%' Or @Beat = N''    
		Insert Into #tmpBeat     
		Select Distinct Beatid From Beat
	Else    
		Insert Into #tmpBeat    
		Select Beatid From Beat Where Description In (Select * From dbo.sp_splitin2Rows(@Beat,@Delimeter))    
	
	If @Customerid = '%' Or @Customerid = N''    
		Insert Into #tmpCustid     
		Select Distinct Customerid From Customer 
	Else    
		Insert Into #tmpCustid    
		Select Customerid From Customer Where Customerid In (Select * From dbo.sp_splitin2Rows(@Customerid,@Delimeter))    

	If @Customername = '%' Or @Customername = N''    
		Insert Into #tmpCustname     
		Select Distinct Company_Name From Customer 
	Else    
		Insert Into #tmpCustname    
		Select Company_Name From Customer Where Company_Name In (Select * From dbo.sp_splitin2Rows(@Customername,@Delimeter))    
	

if Exists (select * from LP_AchievementDetail Where dbo.stripTimeFromdate(@Trandate) >= dbo.stripTimeFromdate(TargetFrom) and dbo.stripTimeFromdate(@Trandate) <= dbo.stripTimeFromdate(GraceDate) and Active = 1)
Begin 

	Truncate table #TmpCustMaster
	Insert Into #TmpCustMaster
		Select Distinct Customerid,Salesmanid,Beatid From Beat_Salesman Where Customerid in (select Customerid from #tmpCustid) and 
				Customerid in (select Customerid from Customer Where Company_name in (select CustomerName from #tmpCustname)) And
				SalesManid in (select SalesmanID from #tmpSman) And
				Beatid in (Select Beatid from #tmpBeat)									

			Begin
				/* Since more than one active can be there for a customer, we are taking the max of Period*/
				Insert into #TempOut
				select Distinct Customerid,'',0,0,'',@Lastdayclosedate,Getdate(),
				left(datename(month,TargetFrom),3) + ' ' + cast(datepart(year,TargetFrom) as nvarchar(4)) + ' to ' + left(datename(month,TargetTo),3) + ' ' + cast(datepart(year,TargetTo) as nvarchar(4))
				,Program_Type from LP_AchievementDetail,
				(Select CONVERT(VARCHAR(7),max(cast(('01/'+(Right(Period,2) + '/' +  Left(Period,4)))as DateTime)),126) as TempPeriod,CustomerID as TempCustomerID from LP_AchievementDetail L where isnull(L.active,0)=1 and L.customerID in (select Customerid from #tmpCustid) group by L.CustomerID) Temp
				Where Active = 1 and Customerid in (select Distinct Customerid from #TmpCustMaster)
				And Period = Temp.TempPeriod
				And CustomerID =  Temp.TempCustomerID 
				Update #TempOut set CustomerName = Company_name From Customer Where #TempOut.Customerid = Customer.Customerid
				
				Declare @NewCustomerID as Nvarchar(255)
				Declare @Period as Nvarchar(255)
				Declare @Target as Decimal (18,6)
				Declare @Achievement as Decimal (18,6)
				Declare @OldAchievement as Decimal (18,6)
				Declare @NewAchievement as Decimal (18,6)
				Declare @cur Cursor 
				Set @cur = Cursor for
				select Distinct CustomerID from #TempOut
				Open @cur
				Fetch Next from @cur into @NewCustomerID
				While @@fetch_status =0
					Begin
						Set @Achievement = 0
						Set @OldAchievement = 0
						Set @NewAchievement = 0
						Select @MaxDate =  max(cast(('01/'+(Right(Period,2) + '/' +  Left(Period,4)))as DateTime)) from LP_AchievementDetail where isnull(active,0)=1 and customerID= @NewCustomerID
						Set @MaxPeriod= CONVERT(VARCHAR(7), @MaxDate, 126)

						select @Period = Period, @Target = isnull(Sum(TargetVal),0),@OldAchievement = isnull(Sum(AchievedVal),0) From LP_AchievementDetail Where Customerid = @NewCustomerID and Active = 1 And Period = @MaxPeriod Group By Customerid,Period,Program_Type
						Update #TempOut set Target = isnull(@Target,0) Where Customerid = @NewCustomerID
						Select @Achievement = Sum(Achieved) from LPCustomerScore Where Period = @Period and Customerid = @NewCustomerID And dbo.stripTimeFromdate(DayClose) > 
						(select dbo.stripTimeFromdate(Max(AchievedTo)) From LP_AchievementDetail Where Customerid = @NewCustomerID and Active = 1 and  Period = @Period) Group By Customerid,Period,Program_Type
						Set @NewAchievement = (@Achievement + @OldAchievement)
						Update #TempOut set Achievement = isnull(@NewAchievement,0) Where Customerid = @NewCustomerID
						IF @Target > 0 
							Begin
								If (select Target From #TempOut Where Customerid = @NewCustomerID) > 0
										Begin 
											Update #TempOut set PercentageAchieved =cast((isnull(((Achievement / Target) * 100),0)) as Decimal(18,2)) Where Customerid = @NewCustomerID
										End
								Else
									Update #TempOut set PercentageAchieved = Null
--								If (select PercentageAchieved from #TempOut Where Customerid = @NewCustomerID) < 0 
--									Begin 
--										Update #TempOut set PercentageAchieved = 0  Where Customerid = @NewCustomerID
--									End
							End
						Fetch Next from @cur into @NewCustomerID
					End
				Close @cur
				Deallocate @cur
			End
--	if exists (select top 1 * from  #TempOut)
--		set @TgtPeriod = (select left(datename(month,TargetFrom),3) + ' ' + cast(datepart(year,TargetFrom) as nvarchar(4)) + ' to ' + left(datename(month,TargetTo),3) + ' ' + cast(datepart(year,TargetTo) as nvarchar(4)) from LP_AchievementDetail where active=1 )
		
End	
	select [CustomerID],[CustomerID],
		[CustomerName] ,
		[Target] ,
		[Achievement] ,
		[PercentageAchieved] ,
		[LastDayCloseDate] ,
		cast(Cast(CONVERT(VARCHAR(10),[ReportGenerationDateandTime],103) as Nvarchar(25)) 
		+ ' ' + 
		Cast(CONVERT(VARCHAR(8),[ReportGenerationDateandTime],108) as Nvarchar(25)) as Nvarchar(50))
		[ReportGenerationDateandTime],[Period] from #TempOut Order by CustomerName Asc
	
	Drop table #tmpSman
	Drop table #tmpBeat
	Drop table #tmpCustid
	Drop table #tmpCustname
	Drop table #TmpCustMaster
	Drop table #TempOut

End
