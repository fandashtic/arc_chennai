CREATE procedure [dbo].[sp_acc_rpt_SMwiseCategoryGroupWise_OutStanding_ITC_OCG](
	@SalesMan nVarchar(2550),
    @CategoryGrouptype nVarchar(100),
	@CategoryGroup nVarchar(2550),
	@FromDate datetime,
	@ToDate datetime,
	@TimeBucket1 Int,
	@TimeBucket2 Int,
	@TimeBucket3 Int,
	@TimeBucket4 Int,
	@TimeBucket5 Int,
	@TimeBucket6 Int,
	@TimeBucket7 Int,
	@TimeBucket8 Int,
	@TimeBucket9 Int,
	@TimeBucket10 Int)
As

Set DateFormat DMY

Declare @One As Datetime
Declare @Seven As Datetime
Declare @LessSeven As Datetime
Declare @EqualSeven As Datetime
Declare @Eight As Datetime
Declare @Ten As Datetime
Declare @Eleven As Datetime
Declare @Fourteen As Datetime
Declare @Fifteen As Datetime
Declare @TwentyOne As Datetime
Declare @TwentyTwo As Datetime
Declare @Thirty As Datetime
Declare @ThirtyOne As Datetime
Declare @Sixty As Datetime
Declare @SixtyOne As Datetime
Declare @Ninety As Datetime
Declare @NinetyOne As Datetime
Declare @Hundred As Datetime
Declare @HundredOne As Datetime
Declare @HundredTwo As Datetime
Declare @HundredThree As Datetime
Declare @HundredFour As Datetime

Declare @Sql nVarchar(4000)
Declare @Flag As Int 
Declare @Diff As Int
Declare @Delimeter As nvarchar(1)
Declare @GroupId As Int
Declare @Interval Int

Declare @OrderBy int

Select @OrderBy = isNull(GroupBy,0) From ReportData Where ID = 808

Set @Delimeter = Char(15)
Set @Flag = 1

Create Table #tmpSalesMan(SalesManId Int)
Create Table #tmpCategoryGroup(GroupId Int)

if @Salesman=N'%'     
Begin
   Insert into #tmpSalesMan values(0)
   Insert into #tmpSalesMan select SalesmanId from SalesMan    
End
Else    
   Insert into #tmpSalesMan Select SalesManId From SalesMan Where Salesman_name In (select * from dbo.sp_SplitIn2Rows(@Salesman,@Delimeter))    

if @CategoryGroup=N'%'     
Begin
	iF @CategoryGrouptype = 'Operational'
	Begin
		Insert into #tmpCategoryGroup Select GroupId From Productcategorygroupabstract where Isnull(OCGType,0)  = 1
	End
	Else
	Begin
		Insert into #tmpCategoryGroup Select GroupId From Productcategorygroupabstract where GroupName In (select Distinct CategoryGroup from tblcgdivmapping)
	End
End
Else    
   Insert into #tmpCategoryGroup Select GroupId From ProductCategoryGroupAbstract Where GroupName In (Select * from dbo.sp_SplitIn2Rows(@CategoryGroup,@Delimeter))    

Create Table #TmpItem(GroupId Int, Product_Code nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS) 

Declare CursorGroup Cursor For Select Distinct GroupID From ProductCategoryGroupAbstract
Open CursorGroup
Fetch From CursorGroup Into @GroupID
While @@Fetch_Status = 0    
  Begin    
   Insert Into #TmpItem Select @GroupID,Product_Code From dbo.fn_Get_CGItems(@GroupID,@CategoryGrouptype)
   Fetch Next From CursorGroup Into @GroupID
  End
Close CursorGroup
DeAllocate CursorGroup

Set @One = Cast(Datepart(dd, dbo.Sp_Acc_GetOperatingDate(getdate())) As nVarchar) + N'/' +
Cast(Datepart(mm, dbo.Sp_Acc_GetOperatingDate(getdate())) As nVarchar) + N'/' +
Cast(Datepart(yyyy, dbo.Sp_Acc_GetOperatingDate(getdate())) As nVarchar)

----------------------
-- select @One 
----------------------

If @TimeBucket1 = 0 And @TimeBucket2 = 0 And @TimeBucket3 = 0 And @TimeBucket4 = 0 And @TimeBucket5 = 0 And @TimeBucket6 = 0  And @TimeBucket7 = 0 And @TimeBucket8 = 0  And @TimeBucket9 = 0 And @TimeBucket10 = 0 
Begin
-----------------------------------------
-- Set @Diff = 0 - 1
-- Set @LessSeven = DateAdd(d, -7, @One)	
-- Set @EqualSeven = DateAdd(d, -1, @LessSeven)
-- Set @Seven = DateAdd(d, -3, @LessSeven)	
-- Set @Eight = DateAdd(d, -1, @Seven)
-- Set @Ten = DateAdd(d, -4, @Eight)
-- Set @Eleven = DateAdd(d, -1, @Ten)
-- Set @Fourteen = DateAdd(d, -7, @Eleven)
-- -- Set @Diff = Cast(@TimeBucket5 As Int) - Cast(@TimeBucket4 As Int)
-- -- Set @Diff = 0 - @Diff
-- Set @Fifteen = DateAdd(d, -1, @Fourteen)
-- Set @TwentyOne = DateAdd(d, -8, @Fifteen)
-- 
-- Set @TwentyTwo = DateAdd(d, -1, @TwentyOne)
-- Set @Thirty = DateAdd(d, -29, @TwentyTwo)
-- 
-- Set @ThirtyOne = DateAdd(d, -1, @Thirty)
-- Set @Sixty = DateAdd(d, -30, @ThirtyOne)
-- 
-- Set @SixtyOne = DateAdd(d, -1, @Sixty)
-- Set @Ninety = DateAdd(d, -30, @SixtyOne)							
-- 
-- Set @NinetyOne = DateAdd(d, -1, @Ninety)
-- Set @Hundred = DateAdd(d, @Diff, @NinetyOne)
-- Set @HundredOne = DateAdd(d, -1, @Hundred)
-- Set @HundredTwo = DateAdd(d, @Diff, @HundredOne)
-- Set @HundredThree = DateAdd(d, -1, @HundredOne)
-- Set @HundredFour = DateAdd(d, @Diff, @HundredThree)

-----------------------------------------

	Set @LessSeven = DateAdd(d, -7, @One)	
	Set @EqualSeven = DateAdd(d, -1, @LessSeven)

-- Set @Seven = DateAdd(d, -7, @One)    
-- Set @Eight = DateAdd(d, -1, @Seven)    


 	Set @Seven = DateAdd(d, -2, @EqualSeven)
	Set @Eight = DateAdd(d, -1, @Seven)

-- Set @Ten = DateAdd(d, -2, @Eight)    
-- Set @Eleven = DateAdd(d, -1, @Ten)    


	Set @Ten = DateAdd(d, -3, @Eight)
	Set @Eleven = DateAdd(d, -1, @Ten)

-- Set @Fourteen = DateAdd(d, -3, @Eleven)    
-- Set @Fifteen = DateAdd(d, -1, @Fourteen)    


	Set @Fourteen = DateAdd(d, -6, @Eleven)
	Set @Fifteen = DateAdd(d, -1, @Fourteen)

-- Set @TwentyOne = DateAdd(d, -6, @Fifteen)    
-- Set @TwentyTwo = DateAdd(d, -1, @TwentyOne)    

	Set @TwentyOne = DateAdd(d, -8, @Fifteen)
	Set @TwentyTwo = DateAdd(d, -1, @TwentyOne)

-- Set @Thirty = DateAdd(d, -8, @TwentyTwo)    
-- Set @ThirtyOne = DateAdd(d, -1, @Thirty)    

------------
	Set @Thirty = @TwentyOne --DateAdd(d, -29, @TwentyTwo)
	Set @ThirtyOne = DateAdd(d, -1, @Thirty)
--	select @Thirty , @ThirtyOne
------------

-- Set @Sixty = DateAdd(d, -29, @ThirtyOne)    
-- Set @SixtyOne = DateAdd(d, -1, @Sixty)    

	Set @Sixty = DateAdd(d, -29, @ThirtyOne)
	Set @SixtyOne = DateAdd(d, -1, @Sixty)

-- Set @Ninety = DateAdd(d, -29, @SixtyOne)    
-- Set @NinetyOne = DateAdd(d, -1, @Ninety)    
-- Set @OneTwenty = DateAdd(d, -29, @NinetyOne)    

	Set @Ninety = DateAdd(d, -29, @SixtyOne)
 	Set @NinetyOne = DateAdd(d, -1, @Ninety)    

	Set @Hundred = DateAdd(d, -29, @NinetyOne)
-- 	Set @OneTwenty = DateAdd(d, -29, @NinetyOne)    


-----------------------------

-- 	Set @One = dbo.MakeDayEnd(@One)
-- 	Set @EqualSeven = dbo.MakeDayEnd(@EqualSeven)
-- 	Set @Eight = dbo.MakeDayEnd(@Eight)
-- 	Set @Eleven = dbo.MakeDayEnd(@Eleven)
-- 	Set @Fifteen = dbo.MakeDayEnd(@Fifteen)
-- 	Set @TwentyTwo = dbo.MakeDayEnd(@TwentyTwo)
-- 	Set @ThirtyOne = dbo.MakeDayEnd(@ThirtyOne)
-- 	Set @SixtyOne = dbo.MakeDayEnd(@SixtyOne)
-- 	Set @NinetyOne = dbo.MakeDayEnd(@NinetyOne)
-- 	Set @HundredOne = dbo.MakeDayEnd(@HundredOne)
-- 	Set @HundredThree = dbo.MakeDayEnd(@HundredThree)

	Set @One = dbo.MakeDayEnd(@One)
	Set @EqualSeven = dbo.MakeDayEnd(@EqualSeven)
	Set @Eight = dbo.MakeDayEnd(@Eight)
	Set @Eleven = dbo.MakeDayEnd(@Eleven)
	Set @Fifteen = dbo.MakeDayEnd(@Fifteen)
	Set @TwentyTwo = dbo.MakeDayEnd(@TwentyTwo)
	Set @ThirtyOne = dbo.MakeDayEnd(@ThirtyOne)
	Set @SixtyOne = dbo.MakeDayEnd(@SixtyOne)
	Set @NinetyOne = dbo.MakeDayEnd(@NinetyOne)
	Set @HundredOne = dbo.MakeDayEnd(@HundredOne)
	Set @HundredThree = dbo.MakeDayEnd(@HundredThree)
--select @TwentyTwo , @Thirty , @Hundred
-----------------------------
-- select @One, @LessSeven, @EqualSeven , @Seven , @Eight, @Ten , @Eleven , @Fourteen , @Fifteen 
-- select @TwentyOne, @TwentyTwo , @Thirty , @ThirtyOne , @Sixty, @SixtyOne , @Ninety
-- select @NinetyOne , @Hundred, @HundredOne, @HundredTwo , @HundredThree, @HundredFour 
-------------
-- select "in zero bt"
-- select @One
--------------

End
Else
If @TimeBucket1 = 0 
Begin
	Create table #tmpInterval1_one (SalesmanID nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS not null, SalesManName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, CategoryGroup nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, [Net Outstanding (%c)] Decimal(18,6) not null) 

-- 	Select * From tmpInterval1
-- 	Drop Table tmpInterval1
End
Else
Begin
	Set @InterVal = 1
	If @TimeBucket1 <> 0 
	Begin
		Set @Diff = 0 - @TimeBucket1
		Set @LessSeven = DateAdd(d, @Diff, @One)	
	End

	If @TimeBucket2 <> 0 
	Begin
-----------------------
-- select @one
-----------------------
	 If @TimeBucket2 > @TimeBucket1 
          Begin
	          Set @InterVal = 2
		  Set @Diff = @TimeBucket2 - @TimeBucket1
		  Set @Diff = 0 - @Diff
		  set @Diff = @Diff + 1
		  Set @EqualSeven = DateAdd(d, -1, @LessSeven)
		  Set @Seven = DateAdd(d, @Diff, @EqualSeven)	
          End
          else 
		  Set @Flag =0
        End 
	
	If @TimeBucket3 <> 0 
	Begin
		Set @InterVal = 3

		If (Cast(@TimeBucket3 As Int) > Cast(@TimeBucket2 As Int)) 
		Begin
			Set @Diff = Cast(@TimeBucket3 As Int) - Cast(@TimeBucket2 As Int)
			Set @Diff = 0 - @Diff
			set @Diff = @Diff + 1
			Set @Eight = DateAdd(d, -1, @Seven)
			Set @Ten = DateAdd(d, @Diff, @Eight)
			If Cast(@TimeBucket4 As Int) <> 0 
			Begin
				Set @InterVal = 4
				If  (Cast(@TimeBucket4 As Int) > Cast(@TimeBucket3 As Int)) 
				Begin
					Set @Diff = Cast(@TimeBucket4 As Int) - Cast(@TimeBucket3 As Int)
					Set @Diff = 0 - @Diff
					set @Diff = @Diff + 1
					Set @Eleven = DateAdd(d, -1, @Ten)
					Set @Fourteen = DateAdd(d, @Diff, @Eleven)
					If Cast(@TimeBucket5 As Int) <> 0 
					Begin
						Set @InterVal = 5
						If  (Cast(@TimeBucket5 As Int) > Cast (@TimeBucket4 As Int)) 
							Begin
								Set @Diff = Cast(@TimeBucket5 As Int) - Cast(@TimeBucket4 As Int)
								Set @Diff = 0 - @Diff
								set @Diff = @Diff + 1
								Set @Fifteen = DateAdd(d, -1, @Fourteen)
								Set @TwentyOne = DateAdd(d, @Diff, @Fifteen)
								If Cast(@TimeBucket6 As Int) <> 0
								Begin
									Set @InterVal = 6
									If  (Cast(@TimeBucket6 As Int) > Cast(@TimeBucket5 As Int))
									Begin
					Set @Diff = Cast(@TimeBucket6 As Int) - Cast(@TimeBucket5 As Int)
					Set @Diff = 0 - @Diff
					set @Diff = @Diff + 1
					Set @TwentyTwo = DateAdd(d, -1, @TwentyOne)
					Set @Thirty = DateAdd(d, @Diff, @TwentyTwo)
					If Cast(@TimeBucket7 As Int) <> 0
					Begin
					Set @InterVal = 7
					If  (Cast(@TimeBucket7 As Int) > Cast(@TimeBucket6 As Int)) 
					Begin
						Set @Diff = Cast(@TimeBucket7 As Int) - Cast(@TimeBucket6 As Int)
						Set @Diff = 0 - @Diff
						set @Diff = @Diff + 1
						Set @ThirtyOne = DateAdd(d, -1, @Thirty)
						Set @Sixty = DateAdd(d, @Diff, @ThirtyOne)
						If Cast(@TimeBucket8 As Int) <> 0
						Begin
						Set @InterVal = 8
						If  (Cast(@TimeBucket8 As Int) > Cast(@TimeBucket7 As Int))
						Begin
							Set @Diff = Cast(@TimeBucket8 As Int) - Cast(@TimeBucket7 As Int)
							Set @Diff = 0 - @Diff		
							set @Diff = @Diff + 1
							Set @SixtyOne = DateAdd(d, -1, @Sixty)
							Set @Ninety = DateAdd(d, @Diff, @SixtyOne)							
							If Cast(@TimeBucket9 As Int) <> 0
							Begin
							Set @InterVal = 9
							If  (Cast(@TimeBucket9 As Int) > Cast(@TimeBucket8 As Int)) 
							Begin
								Set @Diff = Cast(@TimeBucket9 As Int) - Cast(@TimeBucket8 As Int)
								Set @Diff = 0 - @Diff
								set @Diff = @Diff + 1
								Set @NinetyOne = DateAdd(d, -1, @Ninety)
								Set @Hundred = DateAdd(d, @Diff, @NinetyOne)
								If Cast(@TimeBucket10 As Int) <> 0
								Begin
								Set @InterVal = 10
								If  (Cast(@TimeBucket10 As Int) > Cast(@TimeBucket9 As Int))
								Begin
									Set @Diff = Cast(@TimeBucket10 As Int) - Cast(@TimeBucket9 As Int)
									Set @Diff = 0 - @Diff
									set @Diff = @Diff + 1
									Set @HundredOne = DateAdd(d, -1, @Hundred)
									Set @HundredTwo = DateAdd(d, @Diff, @HundredOne)
									Set @HundredThree = DateAdd(d, -1, @HundredOne)
									Set @HundredFour = DateAdd(d, @Diff, @HundredThree)
								End
								Else
								Set @Flag = 0
								End
								Else -- @TimeBucket10 = 0
								Begin
									Set @HundredOne = DateAdd(d, -1, @Hundred)
									Set @HundredTwo = DateAdd(d, @Diff, @HundredOne)
									Set @HundredThree = DateAdd(d, -1, @HundredOne)
									Set @HundredFour = DateAdd(d, @Diff, @HundredThree)
								End
							End
							Else
							Set @Flag = 0
							End
							Else -- @TimeBucket9 = 0
							Begin
								Set @NinetyOne = DateAdd(d, -1, @Ninety)
								Set @Hundred = DateAdd(d, @Diff, @NinetyOne)
							End
						End
						Else
						Set @Flag = 0
						End
						Else -- @TimeBucket8 = 0
						Begin
							Set @SixtyOne = DateAdd(d, -1, @Sixty)
							Set @Ninety = DateAdd(d, @Diff, @SixtyOne)
						End
					End
					Else
					Set @Flag = 0
					End
					Else -- @TimeBucket7 = 0
					Begin
						Set @ThirtyOne = DateAdd(d, -1, @Thirty)
						Set @Sixty = DateAdd(d, @Diff, @ThirtyOne)
					End
				End
				Else
				Set @Flag = 0
				End
				Else -- @TimeBucket6 = 0
				Begin
					Set @TwentyTwo = DateAdd(d, -1, @TwentyOne)
					Set @Thirty = DateAdd(d, @Diff, @TwentyTwo)
				End
			End
			Else
			Set @Flag = 0
			End
			Else -- @TimeBucket5 = 0
			Begin
				Set @Fifteen = DateAdd(d, -1, @Fourteen)
				Set @TwentyOne = DateAdd(d, @Diff, @Fifteen)
			End
		End
		Else
		Set @Flag = 0
		End
		Else -- @TimeBucket4 = 0
		Begin
			Set @Eleven = DateAdd(d, -1, @Ten)
			Set @Fourteen = DateAdd(d, @Diff, @Eleven)
		End
	End 
	Else
	Set @Flag = 0
	End
	Else -- @TimeBucket3 = 0
	Begin
		Set @Eight = DateAdd(d, -1, @Seven)
		Set @Ten = DateAdd(d, @Diff, @Eight)
	End
--	Else -- @TimeBucket2 = 0 
--	Set @Flag =0	
--	End
--     End
-- Create Temp Table for given Time Buckets
Create table #tmpInterval_two (SalesmanID nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS not null, SalesManName nVarchar(255),CategoryGroup nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, [Net Outstanding (%c)] Decimal(18,6) not null) 


------------------
-- select @Interval
-- select @TimeBucket1
-- select @One, @LessSeven, @EqualSeven , @Seven , @Eight, @Ten , @Eleven , @Fourteen , @Fifteen 
-- select @TwentyOne, @TwentyTwo , @Thirty , @ThirtyOne , @Sixty, @SixtyOne , @Ninety
-- select @NinetyOne , @Hundred, @HundredOne, @HundredTwo , @HundredThree, @HundredFour 

-----------------------

If @Interval >= 1
Begin
	Set @Sql = 'Alter table #tmpInterval_two Add [1 - ' + Cast(@TimeBucket1 As nVarchar) + ' Days ] Decimal(18, 6) null '
	Exec(@Sql)
End 

If @Interval >= 2 
Begin
	Set @Sql = 'Alter table #tmpInterval_two Add [' + Cast((@TimeBucket1 + 1 ) As nVarchar)  + ' - ' + Cast(@TimeBucket2 As nVarchar) + ' Days] Decimal(18, 6) null'
	Exec(@Sql)
End

If @Interval >= 3 
Begin
	Set @Sql = 'Alter table #tmpInterval_two Add  [' + Cast((@TimeBucket2 + 1) As nVarchar) + ' - ' + Cast(@TimeBucket3 As nVarchar) + ' Days]  Decimal(18, 6) null '
	Exec(@Sql)
End

If @Interval >= 4 
Begin
	Set @Sql = 'Alter table #tmpInterval_two Add [' + Cast((@TimeBucket3  + 1) As nVarchar) + ' - ' + Cast(@TimeBucket4 As nVarchar) + ' Days] Decimal(18, 6) null ' 
	Exec(@Sql)
End
If @Interval >= 5 
Begin
	Set @Sql = 'Alter table #tmpInterval_two Add [' + Cast((@TimeBucket4 + 1 ) As nVarchar) + ' - ' + Cast(@TimeBucket5 As nVarchar) + ' Days] Decimal(18, 6) null '  
	Exec(@Sql)
End
If @Interval >= 6 
Begin
	Set @Sql = 'Alter table #tmpInterval_two Add [' + Cast((@TimeBucket5 + 1 ) As nVarchar)  + ' - ' + Cast(@TimeBucket6 As nVarchar) + ' Days] Decimal(18, 6) null ' 
	Exec(@Sql)
End
If @Interval >= 7 
Begin
	Set @Sql = 'Alter table #tmpInterval_two Add [' + Cast((@TimeBucket6 + 1 ) As nVarchar)  + ' - ' + Cast(@TimeBucket7 As nVarchar) + ' Days] Decimal(18, 6) null ' 
	Exec(@Sql)
End
If @Interval >= 8 
Begin
	Set @Sql = 'Alter table #tmpInterval_two Add [' + Cast((@TimeBucket7 + 1 ) As nVarchar)  + ' - ' + Cast(@TimeBucket8 As nVarchar) + ' Days]   Decimal(18, 6) null ' 
	Exec(@Sql)
End
If @Interval >= 9 
Begin
	Set @Sql = 'Alter table #tmpInterval_two Add [' + Cast((@TimeBucket8 + 1 ) As nVarchar)  + ' - ' + Cast(@TimeBucket9 As nvarchar) + ' Days] Decimal(18, 6) null ' 
	Exec(@Sql)
End
If @Interval >= 10
Begin
	Set @Sql = 'Alter table #tmpInterval_two Add [' + Cast((@TimeBucket9 + 1 ) As nVarchar)  + ' - ' + Cast(@TimeBucket10 As nvarchar) + ' Days] Decimal(18, 6) null '
	Exec(@Sql)
End

End

-- If @TimeBucket1 <> 0
-- Begin
-- select 'Begin'
-- select @Interval , @Ninety , @SixtyOne 
-- select @Sixty , @ThirtyOne 
-- select @Interval ,@Hundred , @TimeBucket1 , @Ninety
If @TimeBucket1 > 0
Begin
	Set @One = dbo.MakeDayEnd(@One)
	Set @EqualSeven = dbo.MakeDayEnd(@EqualSeven)
	Set @Eight = dbo.MakeDayEnd(@Eight)
	Set @Eleven = dbo.MakeDayEnd(@Eleven)
	Set @Fifteen = dbo.MakeDayEnd(@Fifteen)
	Set @TwentyTwo = dbo.MakeDayEnd(@TwentyTwo)
	Set @ThirtyOne = dbo.MakeDayEnd(@ThirtyOne)
	Set @SixtyOne = dbo.MakeDayEnd(@SixtyOne)
	Set @NinetyOne = dbo.MakeDayEnd(@NinetyOne)
	Set @HundredOne = dbo.MakeDayEnd(@HundredOne)
	Set @HundredThree = dbo.MakeDayEnd(@HundredThree)
-------------------
-- select "outside zero bt"
-- select @One
-------------------
End
	Create table #temp
	(SalesmanID int Not Null,
	 GroupId Int Not Null,
	 Balance Decimal(18,6) not null,
	 CustomerID nvarchar(15)  COLLATE SQL_Latin1_General_CP1_CI_AS not null,
	 OnetoSeven Decimal(18, 6) null,
	 EighttoTen Decimal(18, 6) null,
	 EleventoFourteen Decimal(18, 6) null,
	 FifteentoTwentyOne Decimal(18, 6) null,
	 TwentyTwotoThirty Decimal(18, 6) null,
	 LessthanThirty Decimal(18, 6) null,
	 ThirtyOnetoSixty Decimal(18, 6) null,
	 SixtyOnetoNinety Decimal(18, 6) null,
	 MorethanNinety Decimal(18, 6) null,
	 MoreThanHundred Decimal(18,6))


--	Insert Into #temp 
--	Select 	Distinct ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.GroupId,0), 
--	(Select Sum(Case When InvoiceType in (1,3) Then IsNull(Balance, 0) 
--	Else 0 - IsNull(Balance, 0) End) From InvoiceAbstract As Inv
--	Where 
--	Inv.Status & 128 = 0 And
--	Inv.InvoiceType In (1,3,4) And
--	Inv.Balance > 0 And 
--	Inv.SalesmanID = InvoiceAbstract.SalesmanID And
--	Inv.GroupId = InvoiceAbstract.GroupId And
--	Inv.CustomerID = InvoiceAbstract.CustomerID --And 
----	Inv.InvoiceID = InvoiceAbstract.InvoiceID
--	),
--	CustomerID,
--	-- Interval1
--	(Select Sum(Case When InvoiceType in (1,3) Then 
--	IsNull(Inv.Balance, 0)
--	Else 0 - IsNull(Inv.Balance, 0) End)
--	From InvoiceAbstract As Inv
--	Where 
--	Inv.Status & 128 = 0 And
--	Inv.InvoiceType In (1,3,4) And 
--	Inv.InvoiceDate Between @LessSeven And @One And 
--	Inv.Balance > 0 And 
--	Inv.SalesmanID = InvoiceAbstract.SalesmanID And
--	Inv.GroupId = InvoiceAbstract.GroupId And
--	Inv.CustomerID = InvoiceAbstract.CustomerID --And 
----	Inv.InvoiceID = InvoiceAbstract.InvoiceID
--	),
--	-- Interval2
--	(Case When @Interval < 2 Then 0 Else
--	(Select Sum(Case When InvoiceType in (1,3) Then 
--	IsNull(Inv.Balance, 0)
--	Else 0 - IsNull(Inv.Balance, 0) End)
--	From InvoiceAbstract As Inv
--	Where 
--	Inv.Status & 128 = 0 And
--	Inv.InvoiceType In (1,3,4) And 
--	Inv.InvoiceDate Between @Seven And @EqualSeven And 
--	Inv.Balance > 0 And 
--	Inv.SalesmanID = InvoiceAbstract.SalesmanID And
--	Inv.GroupId = InvoiceAbstract.GroupId And
--	Inv.CustomerID = InvoiceAbstract.CustomerID --And 
----	Inv.InvoiceID = InvoiceAbstract.InvoiceID
--	) End),
--	-- Interval3
--	(Case When @Interval < 3 Then 0 Else
--	(Select Sum(Case When InvoiceType in (1,3) Then 
--	IsNull(Inv.Balance, 0)
--	Else 0 - IsNull(Inv.Balance, 0) End)
--	From InvoiceAbstract As Inv
--	Where 
--	Inv.Status & 128 = 0 And
--	Inv.InvoiceType In (1,3,4) And 
--	Inv.InvoiceDate Between @Ten And @Eight And 
--	Inv.Balance > 0 And 
--	Inv.SalesmanID = InvoiceAbstract.SalesmanID And
--	Inv.GroupId = InvoiceAbstract.GroupId And
--	Inv.CustomerID = InvoiceAbstract.CustomerID --And 
----	Inv.InvoiceID = InvoiceAbstract.InvoiceID
--	) End),
--	-- Interval4
--	(Case When @Interval < 4 Then 0 Else
--	(Select Sum(Case When InvoiceType in (1,3) Then 
--	IsNull(Inv.Balance, 0)
--	Else 0 - IsNull(Inv.Balance, 0) End)
--	From InvoiceAbstract As Inv
--	Where 
--	Inv.Status & 128 = 0 And
--	Inv.InvoiceType In (1,3,4) And
--	Inv.InvoiceDate Between @Fourteen And @Eleven  And 
--	Inv.Balance > 0 And 
--	Inv.SalesmanID = InvoiceAbstract.SalesmanID And
--	Inv.GroupId = InvoiceAbstract.GroupId And
--	Inv.CustomerID = InvoiceAbstract.CustomerID --And 
----	Inv.InvoiceID = InvoiceAbstract.InvoiceID
--	) End),
--	-- Interval5
--	(Case When @Interval < 5 Then 0 Else
--	(Select Sum(Case When InvoiceType in (1,3) Then 
--	IsNull(Inv.Balance, 0)
--	Else 0 - IsNull(Inv.Balance, 0) End)
--	From InvoiceAbstract As Inv
--	Where 
--	Inv.Status & 128 = 0 And
--	Inv.InvoiceType In (1,3,4) And
--	Inv.InvoiceDate Between @TwentyOne And @Fifteen And 
--	Inv.Balance > 0 And 
--	Inv.SalesmanID = InvoiceAbstract.SalesmanID And
--	Inv.GroupId = InvoiceAbstract.GroupId And
--	Inv.CustomerID = InvoiceAbstract.CustomerID --And 
----	Inv.InvoiceID = InvoiceAbstract.InvoiceID
--	) End),
--	-- Interval6
-----------
--	Case When @TimeBucket1 = 0 Then 
--		(Case When @Interval < 6 Then 0 Else
--		(Select Sum(Case When InvoiceType in (1,3) Then 
--		IsNull(Inv.Balance, 0)
--		Else 0 - IsNull(Inv.Balance, 0) End)
--		From InvoiceAbstract As Inv
--		Where 
--		Inv.Status & 128 = 0 And
--		Inv.InvoiceType In (1,3,4) And
--		Inv.InvoiceDate > @Thirty  And --Between @Thirty And @TwentyTwo And 
--		Inv.Balance > 0 And 
--		Inv.SalesmanID = InvoiceAbstract.SalesmanID And
--		Inv.GroupId = InvoiceAbstract.GroupId And
--		Inv.CustomerID = InvoiceAbstract.CustomerID --And 
----		Inv.InvoiceID = InvoiceAbstract.InvoiceID
--		) End)
----------
--	Else
--		(Case When @Interval < 6 Then 0 Else
--		(Select Sum(Case When InvoiceType in (1,3) Then 
--		IsNull(Inv.Balance, 0)
--		Else 0 - IsNull(Inv.Balance, 0) End)
--		From InvoiceAbstract As Inv
--		Where 
--		Inv.Status & 128 = 0 And
--		Inv.InvoiceType In (1,3,4) And
--		Inv.InvoiceDate Between @Thirty And @TwentyTwo And 
--		Inv.Balance > 0 And 
--		Inv.SalesmanID = InvoiceAbstract.SalesmanID And
--		Inv.GroupId = InvoiceAbstract.GroupId And
--		Inv.CustomerID = InvoiceAbstract.CustomerID --And 
----		Inv.InvoiceID = InvoiceAbstract.InvoiceID
--		) End)
--	End,
--------------
--
--	-- Interval7
--	(Case When @Interval < 7 Then 0 Else
--	(Select Sum(Case When InvoiceType in (1,3) Then 
--	IsNull(Inv.Balance, 0)
--	Else 0 - IsNull(Inv.Balance, 0) End)
--	From InvoiceAbstract As Inv
--	Where 
--	Inv.Status & 128 = 0 And
--	Inv.InvoiceType In (1,3,4) And
--	Inv.InvoiceDate Between @Sixty And @ThirtyOne And 
--	Inv.Balance > 0 And 
--	Inv.SalesmanID = InvoiceAbstract.SalesmanID And
--	Inv.GroupId = InvoiceAbstract.GroupId And
--	Inv.CustomerID = InvoiceAbstract.CustomerID --And 
----	Inv.InvoiceID = InvoiceAbstract.InvoiceID
--	) End),
-------------------------------
--	--Interval8
----	Cast( @Interval as nvarchar) + ' @ ' + cast(@Ninety as nvarchar) + ' @ ' +  cast(@SixtyOne as nvarchar)
-------------------------------
--	(Case When @Interval < 8 Then 0 Else
--	(Select Sum(Case When InvoiceType in (1,3) Then 
--	IsNull(Inv.Balance, 0)
--	Else 0 - IsNull(Inv.Balance, 0) End)
--	From InvoiceAbstract As Inv
--	Where 
--	Inv.Status & 128 = 0 And
--	Inv.InvoiceType In (1,3,4) And
--	Inv.InvoiceDate Between @Ninety And @SixtyOne And 
--	Inv.Balance > 0 And 
--	Inv.SalesmanID = InvoiceAbstract.SalesmanID And
--	Inv.GroupId = InvoiceAbstract.GroupId And
--	Inv.CustomerID = InvoiceAbstract.CustomerID --And 
----	Inv.InvoiceID = InvoiceAbstract.InvoiceID
--	) End)
--,
--	-- Interval9
-------------------------------
----	cast(@Interval as nvarchar) + ' @ ' + cast(@Hundred as nvarchar)
-------------------------------
--	Case When @TimeBucket1 = 0 Then 
--		(Case When @Interval < 9 Then 0 Else
--		(Select Sum(Case When InvoiceType in (1,3) Then 
--		IsNull(Inv.Balance, 0)
--		Else 0 - IsNull(Inv.Balance, 0) End)
--		From InvoiceAbstract As Inv
--		Where 
--		Inv.Status & 128 = 0 And
--		Inv.InvoiceType In (1,3,4) And
--		Inv.InvoiceDate < @Ninety And --Between @Hundred And @NinetyOne And
--		Inv.Balance > 0 And
--		Inv.SalesmanID = InvoiceAbstract.SalesmanID And
--		Inv.GroupId = InvoiceAbstract.GroupId And
--		Inv.CustomerID = InvoiceAbstract.CustomerID --And
--	--	Inv.InvoiceID = InvoiceAbstract.InvoiceID
--		) End)
--	Else
--		(Case When @Interval < 9 Then 0 Else
--		(Select Sum(Case When InvoiceType in (1,3) Then 
--		IsNull(Inv.Balance, 0)
--		Else 0 - IsNull(Inv.Balance, 0) End)
--		From InvoiceAbstract As Inv
--		Where 
--		Inv.Status & 128 = 0 And
--		Inv.InvoiceType In (1,3,4) And
--		Inv.InvoiceDate Between @Hundred And @NinetyOne And 
--		Inv.Balance > 0 And 
--		Inv.SalesmanID = InvoiceAbstract.SalesmanID And
--		Inv.GroupId = InvoiceAbstract.GroupId And
--		Inv.CustomerID = InvoiceAbstract.CustomerID --And
--	--	Inv.InvoiceID = InvoiceAbstract.InvoiceID
--		) End)
--	End
--,
--	-- Interval10
--	(Case When @Interval < 10 Then 0 Else
--	(Select Sum(Case When InvoiceType in (1,3) Then 
--	IsNull(Inv.Balance, 0)
--	Else 0 - IsNull(Inv.Balance, 0) End)
--	From InvoiceAbstract As Inv
--	Where 
--	Inv.Status & 128 = 0 And
--	Inv.InvoiceType In (1,3,4) And
--	Inv.InvoiceDate Between @HundredTwo And @HundredOne And 
--	Inv.Balance > 0 And 
--	Inv.SalesmanID = InvoiceAbstract.SalesmanID And
--	Inv.GroupId = InvoiceAbstract.GroupId And
--	Inv.CustomerID = InvoiceAbstract.CustomerID --And 
----		Inv.InvoiceID = InvoiceAbstract.InvoiceID
--	) End)
--	from InvoiceAbstract, #tmpSalesMan S, #tmpCategoryGroup P
--	where InvoiceAbstract.Status & 128 = 0 and
--	InvoiceAbstract.InvoiceType in (1,3,4) and
--	InvoiceAbstract.InvoiceDate between @FromDate and @ToDate And
--	InvoiceAbstract.Balance > 0 and
--	IsNull(InvoiceAbstract.GroupId,0) <> 0 And 
--	InvoiceAbstract.SalesManId =  S.SalesManId And
--	InvoiceAbstract.GroupId =  P.GroupId 
--	Group By InvoiceAbstract.SalesmanID, InvoiceAbstract.CustomerID, InvoiceAbstract.GroupId, InvoiceAbstract.InvoiceID

---------------------------------------------
-- select * from #temp
--select * from #tmpItem
---------------------------------------------	

	Insert Into #temp 
	Select 	Distinct 

	Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '')
	When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else 
	IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '') End,

	IsNull(#tmpItem.GroupId,0), 
	IsNull(( Select Sum(Case When InvoiceType in (1,3) Then 
	IsNull((Idt.Amount / Inv.NetValue * Inv.Balance), 0)
	Else
	0 - IsNull((Idt.Amount / Inv.NetValue * Inv.Balance), 0) End) 
	From InvoiceAbstract Inv, InvoiceDetail Idt, #tmpItem T
	Where 
	Inv.Status & 128 = 0 And
	Inv.InvoiceType In (1,3,4) And
	Inv.Balance > 0 And
--	IsNull(Inv.GroupId,0) = 0 And

	Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = Inv.DocumentID), '')
	When '' Then ISNULL(Inv.SalesmanID, 0) Else 
	IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = Inv.DocumentID), '') End = 

	Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '')
	When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else 
	IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '') End And 

--	Inv.SalesmanID = InvoiceAbstract.SalesmanID And

	Inv.CustomerID = InvoiceAbstract.CustomerID And 
	Inv.InvoiceId = Idt.InvoiceId And
	T.GroupId = #TmpItem.GroupId And
	Idt.Product_Code = T.Product_Code 
--	Inv.InvoiceID = InvoiceAbstract.InvoiceID
	), 0),
	CustomerID,
	-- Interval1
	(Select Sum(Case When InvoiceType In (1,3) Then 
	IsNull((Idt.Amount / Inv.NetValue * Inv.Balance),0) 
	Else
	0 - IsNull((Idt.Amount / Inv.NetValue * Inv.Balance),0) End) 
	From InvoiceAbstract As Inv, 
	InvoiceDetail Idt, #tmpItem T
	Where 
	Inv.Status & 128 = 0 And
	Inv.InvoiceType In (1,3,4) And
	Inv.InvoiceDate Between @LessSeven And @One And 
	Inv.Balance > 0 And 
--	IsNull(Inv.GroupId,0) = 0 And

	Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = Inv.DocumentID), '')
	When '' Then ISNULL(Inv.SalesmanID, 0) Else 
	IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = Inv.DocumentID), '') End = 

	Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '')
	When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else 
	IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '') End And 


--	Inv.SalesmanID = InvoiceAbstract.SalesmanID And
	Inv.CustomerID = InvoiceAbstract.CustomerID And 
	Inv.InvoiceId = Idt.InvoiceId And
	T.GroupId = #TmpItem.GroupId And
	Idt.Product_Code = T.Product_Code 
--	Inv.InvoiceID = InvoiceAbstract.InvoiceID
	),
	-- Interval2
	(Case When @Interval < 2 Then 0 Else
	(Select Sum(Case When InvoiceType In (1,3) Then 
	IsNull((Idt.Amount / Inv.NetValue * Inv.Balance),0) 
	Else
	0 - IsNull((Idt.Amount / Inv.NetValue * Inv.Balance),0) End) 
	From InvoiceAbstract As Inv, 
	InvoiceDetail Idt, #tmpItem T
	Where 
	Inv.Status & 128 = 0 And
	Inv.InvoiceType In (1,3,4) And
	Inv.InvoiceDate Between @Seven And @EqualSeven And 
	Inv.Balance > 0 And 
--	IsNull(Inv.GroupId,0) = 0 And

	Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = Inv.DocumentID), '')
	When '' Then ISNULL(Inv.SalesmanID, 0) Else 
	IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = Inv.DocumentID), '') End = 

	Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '')
	When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else 
	IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '') End And 

--	Inv.SalesmanID = InvoiceAbstract.SalesmanID And 
	Inv.CustomerID = InvoiceAbstract.CustomerID And 
	Inv.InvoiceId = Idt.InvoiceId And 
	T.GroupId = #TmpItem.GroupId And
	Idt.Product_Code = T.Product_Code 
--	Inv.InvoiceID = InvoiceAbstract.InvoiceID
	) End),
	-- Interval3
	(Case When @Interval < 3 Then 0 Else
	(Select Sum(Case When InvoiceType In (1,3) Then 
	IsNull((Idt.Amount / Inv.NetValue * Inv.Balance),0) 
	Else
	0 - IsNull((Idt.Amount / Inv.NetValue * Inv.Balance),0) End) 
	From InvoiceAbstract As Inv, 
	InvoiceDetail Idt, #tmpItem T
	Where 
	Inv.Status & 128 = 0 And 
	Inv.InvoiceType In (1,3,4) And
	Inv.InvoiceDate Between @Ten And @Eight And 
	Inv.Balance > 0 And
--	IsNull(Inv.GroupId,0) = 0 And

	Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = Inv.DocumentID), '')
	When '' Then ISNULL(Inv.SalesmanID, 0) Else 
	IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = Inv.DocumentID), '') End = 

	Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '')
	When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else 
	IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '') End And 

--	Inv.SalesmanID = InvoiceAbstract.SalesmanID And 
	Inv.CustomerID = InvoiceAbstract.CustomerID And 
	Inv.InvoiceId = Idt.InvoiceId And
	T.GroupId = #TmpItem.GroupId And
	Idt.Product_Code = T.Product_Code 
--	Inv.InvoiceID = InvoiceAbstract.InvoiceID
	) End),
	-- Interval4
	(Case When @Interval < 4 Then 0 Else
	(Select Sum(Case When InvoiceType In (1,3) Then 
	IsNull((Idt.Amount / Inv.NetValue * Inv.Balance),0) 
	Else
	0 - IsNull((Idt.Amount / Inv.NetValue * Inv.Balance),0) End) 
	From InvoiceAbstract As Inv, 
	InvoiceDetail Idt, #tmpItem T
	Where 
	Inv.Status & 128 = 0 And
	Inv.InvoiceType In (1,3,4) And
	Inv.InvoiceDate Between @Fourteen And @Eleven And
	Inv.Balance > 0 And
--	IsNull(Inv.GroupId,0) = 0 And

	Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = Inv.DocumentID), '')
	When '' Then ISNULL(Inv.SalesmanID, 0) Else 
	IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = Inv.DocumentID), '') End = 

	Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '')
	When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else 
	IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '') End And

--	Inv.SalesmanID = InvoiceAbstract.SalesmanID And
	Inv.CustomerID = InvoiceAbstract.CustomerID And 
	Inv.InvoiceId = Idt.InvoiceId And
	T.GroupId = #TmpItem.GroupId And
	Idt.Product_Code = T.Product_Code 
--	Inv.InvoiceID = InvoiceAbstract.InvoiceID
	) End),
	---- Interval5
	(Case When @Interval < 5 Then 0 Else
	(Select Sum(Case When InvoiceType In (1,3) Then 
	IsNull((Idt.Amount / Inv.NetValue * Inv.Balance),0) 
	Else
	0 - IsNull((Idt.Amount / Inv.NetValue * Inv.Balance),0) End) 
	From InvoiceAbstract As Inv, 
	InvoiceDetail Idt, #tmpItem T
	Where 
	Inv.Status & 128 = 0 And 
	Inv.InvoiceType In (1,3,4) And
	Inv.InvoiceDate Between @TwentyOne And @Fifteen And 
	Inv.Balance > 0 And 
--	IsNull(Inv.GroupId,0) = 0 And 

	Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = Inv.DocumentID), '')
	When '' Then ISNULL(Inv.SalesmanID, 0) Else 
	IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = Inv.DocumentID), '') End = 

	Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '')
	When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else 
	IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '') End And

--	Inv.SalesmanID = InvoiceAbstract.SalesmanID And 
	Inv.CustomerID = InvoiceAbstract.CustomerID And 
	Inv.InvoiceId = Idt.InvoiceId And
	T.GroupId = #TmpItem.GroupId And
	Idt.Product_Code = T.Product_Code 
--	Inv.InvoiceID = InvoiceAbstract.InvoiceID
	) End),
	-- Interval6
	Case When @TimeBucket1 = 0 Then 
		(Case When @Interval < 6 Then 0 Else
		(Select Sum(Case When InvoiceType In (1,3) Then 
		IsNull((Idt.Amount / Inv.NetValue * Inv.Balance),0) 
		Else
		0 - IsNull((Idt.Amount / Inv.NetValue * Inv.Balance),0) End) 
		From InvoiceAbstract As Inv, 
		InvoiceDetail Idt, #tmpItem T
		Where 
		Inv.Status & 128 = 0 And
		Inv.InvoiceType In (1,3,4) And
		Inv.InvoiceDate > @TwentyTwo And --Between @Thirty And @TwentyTwo And
		Inv.Balance > 0 And
--		IsNull(Inv.GroupId,0) = 0 And

	Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = Inv.DocumentID), '')
	When '' Then ISNULL(Inv.SalesmanID, 0) Else 
	IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = Inv.DocumentID), '') End = 

	Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '')
	When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else 
	IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '') End And

--		Inv.SalesmanID = InvoiceAbstract.SalesmanID And 
		Inv.CustomerID = InvoiceAbstract.CustomerID And 
		Inv.InvoiceId = Idt.InvoiceId And 
		T.GroupId = #TmpItem.GroupId And
		Idt.Product_Code = T.Product_Code 
--		Inv.InvoiceID = InvoiceAbstract.InvoiceID
		) End)
	Else
		(Case When @Interval < 6 Then 0 Else
		(Select Sum(Case When InvoiceType In (1,3) Then 
		IsNull((Idt.Amount / Inv.NetValue * Inv.Balance),0) 
		Else
		0 - IsNull((Idt.Amount / Inv.NetValue * Inv.Balance),0) End) 
		From InvoiceAbstract As Inv, 
		InvoiceDetail Idt, #tmpItem T
		Where 
		Inv.Status & 128 = 0 And
		Inv.InvoiceType In (1,3,4) And
		Inv.InvoiceDate Between @Thirty And @TwentyTwo And 
		Inv.Balance > 0 And
--		IsNull(Inv.GroupId,0) = 0 And

	Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = Inv.DocumentID), '')
	When '' Then ISNULL(Inv.SalesmanID, 0) Else 
	IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = Inv.DocumentID), '') End = 

	Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '')
	When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else 
	IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '') End And

--		Inv.SalesmanID = InvoiceAbstract.SalesmanID And 
		Inv.CustomerID = InvoiceAbstract.CustomerID And 
		Inv.InvoiceId = Idt.InvoiceId And 
		T.GroupId = #TmpItem.GroupId And
		Idt.Product_Code = T.Product_Code 
--		Inv.InvoiceID = InvoiceAbstract.InvoiceID
		) End)
	end
	,
	-- Interval7
	(Case When @Interval < 7 Then 0 Else
	(Select Sum(Case When InvoiceType In (1,3) Then 
	IsNull((Idt.Amount / Inv.NetValue * Inv.Balance),0) 
	Else
	0 - IsNull((Idt.Amount / Inv.NetValue * Inv.Balance),0) End) 
	From InvoiceAbstract As Inv, 
	InvoiceDetail Idt, #tmpItem T
	Where 
	Inv.Status & 128 = 0 And
	Inv.InvoiceType In (1,3,4) And
	Inv.InvoiceDate Between @Sixty And @ThirtyOne And 
	Inv.Balance > 0 And
--	IsNull(Inv.GroupId,0) = 0 And

	Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = Inv.DocumentID), '')
	When '' Then ISNULL(Inv.SalesmanID, 0) Else 
	IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = Inv.DocumentID), '') End = 

	Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '')
	When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else 
	IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '') End And

--	Inv.SalesmanID = InvoiceAbstract.SalesmanID And
	Inv.CustomerID = InvoiceAbstract.CustomerID And 
	Inv.InvoiceId = Idt.InvoiceId And
	T.GroupId = #TmpItem.GroupId And
	Idt.Product_Code = T.Product_Code 
--	Inv.InvoiceID = InvoiceAbstract.InvoiceID
	) End),
	-- Interval8
	(Case When @Interval < 8 Then 0 Else
	(Select Sum(Case When InvoiceType In (1,3) Then 
	IsNull((Idt.Amount / Inv.NetValue * Inv.Balance),0) 
	Else
	0 - IsNull((Idt.Amount / Inv.NetValue * Inv.Balance),0) End) 
	From InvoiceAbstract As Inv, 
	InvoiceDetail Idt, #tmpItem T
	Where 
	Inv.Status & 128 = 0 And
	Inv.InvoiceType In (1,3,4) And
	Inv.InvoiceDate Between @Ninety And @SixtyOne And 
	Inv.Balance > 0 And
--	IsNull(Inv.GroupId,0) = 0 And

	Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = Inv.DocumentID), '')
	When '' Then ISNULL(Inv.SalesmanID, 0) Else 
	IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = Inv.DocumentID), '') End = 

	Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '')
	When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else 
	IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '') End And

--	Inv.SalesmanID = InvoiceAbstract.SalesmanID And
	Inv.CustomerID = InvoiceAbstract.CustomerID And 
	Inv.InvoiceId = Idt.InvoiceId And
	T.GroupId = #TmpItem.GroupId And
	Idt.Product_Code = T.Product_Code 
--	Inv.InvoiceID = InvoiceAbstract.InvoiceID
	) End),
	-- Interval9
	Case When @TimeBucket1 = 0 Then 
		(Case When @Interval < 9 Then 0 Else
		(Select Sum(Case When InvoiceType In (1,3) Then 
		IsNull((Idt.Amount / Inv.NetValue * Inv.Balance),0) 
		Else
		0 - IsNull((Idt.Amount / Inv.NetValue * Inv.Balance),0) End) 
		From InvoiceAbstract As Inv, 
		InvoiceDetail Idt, #tmpItem T
		Where 
		Inv.Status & 128 = 0 And
		Inv.InvoiceType In (1,3,4) And
		Inv.InvoiceDate < @Ninety And --Between @Hundred And @NinetyOne  And
		Inv.Balance > 0 And
--		IsNull(Inv.GroupId,0) = 0 And

		Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
		Where dsos.InvoiceDocumentID = Inv.DocumentID), '')
		When '' Then ISNULL(Inv.SalesmanID, 0) Else 
		IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
		Where dsos.InvoiceDocumentID = Inv.DocumentID), '') End = 

		Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
		Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '')
		When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else 
		IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
		Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '') End And

--		Inv.SalesmanID = InvoiceAbstract.SalesmanID And
		Inv.CustomerID = InvoiceAbstract.CustomerID And 
		Inv.InvoiceId = Idt.InvoiceId And
		T.GroupId = #TmpItem.GroupId And
		Idt.Product_Code = T.Product_Code 
	--	Inv.InvoiceID = InvoiceAbstract.InvoiceID
		) End)
	Else
		(Case When @Interval < 9 Then 0 Else
		(Select Sum(Case When InvoiceType In (1,3) Then 
		IsNull((Idt.Amount / Inv.NetValue * Inv.Balance),0) 
		Else
		0 - IsNull((Idt.Amount / Inv.NetValue * Inv.Balance),0) End) 
		From InvoiceAbstract As Inv, 
		InvoiceDetail Idt, #tmpItem T
		Where 
		Inv.Status & 128 = 0 And
		Inv.InvoiceType In (1,3,4) And
		Inv.InvoiceDate Between @Hundred And @NinetyOne  And
		Inv.Balance > 0 And
--		IsNull(Inv.GroupId,0) = 0 And

		Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
		Where dsos.InvoiceDocumentID = Inv.DocumentID), '')
		When '' Then ISNULL(Inv.SalesmanID, 0) Else 
		IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
		Where dsos.InvoiceDocumentID = Inv.DocumentID), '') End = 

		Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
		Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '')
		When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else 
		IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
		Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '') End And

--		Inv.SalesmanID = InvoiceAbstract.SalesmanID And
		Inv.CustomerID = InvoiceAbstract.CustomerID And 
		Inv.InvoiceId = Idt.InvoiceId And
		T.GroupId = #TmpItem.GroupId And
		Idt.Product_Code = T.Product_Code 
	--	Inv.InvoiceID = InvoiceAbstract.InvoiceID
		) End)

	End,
	-- Interval10
	(Case When @Interval < 10 Then 0 Else
	(Select Sum(Case When InvoiceType In (1,3) Then 
	IsNull((Idt.Amount / Inv.NetValue * Inv.Balance),0) 
	Else
	0 - IsNull((Idt.Amount / Inv.NetValue * Inv.Balance),0) End) 
	From InvoiceAbstract As Inv, 
	InvoiceDetail Idt, #tmpItem T
	Where 
	Inv.Status & 128 = 0 And
	Inv.InvoiceType In (1,3,4) And
	Inv.InvoiceDate Between @HundredTwo And @HundredOne And 
	Inv.Balance > 0 And 
--	IsNull(Inv.GroupId,0) = 0 And

	Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = Inv.DocumentID), '')
	When '' Then ISNULL(Inv.SalesmanID, 0) Else 
	IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = Inv.DocumentID), '') End = 

	Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '')
	When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else 
	IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '') End And

--	Inv.SalesmanID = InvoiceAbstract.SalesmanID And 
	Inv.CustomerID = InvoiceAbstract.CustomerID And 
	Inv.InvoiceId = Idt.InvoiceId And
	T.GroupId = #TmpItem.GroupId And
	Idt.Product_Code = T.Product_Code 
--	Inv.InvoiceID = InvoiceAbstract.InvoiceID
	) End)
	from InvoiceAbstract, #tmpSalesMan S, #tmpCategoryGroup P,
	InvoiceDetail, #tmpItem
	where InvoiceAbstract.Status & 128 = 0 and
	InvoiceAbstract.InvoiceType in (1,3,4) and
	InvoiceAbstract.InvoiceDate between @FromDate and @ToDate And
	InvoiceAbstract.Balance > 0 and
--	IsNull(InvoiceAbstract.GroupId,0) = 0 And

	Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '')
	When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else 
	IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
	Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '') End = S.SalesManId And

--	InvoiceAbstract.SalesManId =  S.SalesManId And
	InvoiceAbstract.InvoiceId = InvoiceDetail.InvoiceId And
	P.GroupId = #tmpItem.GroupId And
	InvoiceDetail.Product_Code = #tmpItem.Product_Code 
	Group By 
	InvoiceAbstract.SalesmanID, InvoiceAbstract.DocumentID, 
	InvoiceAbstract.CustomerID,#tmpItem.GroupId, InvoiceAbstract.InvoiceID
	

-----------------------------------------------------------------
-- select * from #temp
-- select @TwentyTwo , @Thirty , @Hundred
-----------------------------------------------------------------	

	If @TimeBucket1 = 0 And @TimeBucket2 = 0 And @TimeBucket3 = 0 And @TimeBucket4 = 0 And @TimeBucket5 = 0 And @TimeBucket6 = 0  And @TimeBucket7 = 0 And @TimeBucket8 = 0  And @TimeBucket9 = 0 And @TimeBucket10 = 0 
	Begin
		Select Cast(#temp.SalesmanID As nVarchar) + '; ' + Cast(#temp.GroupId As nVarchar) + '; ' + Cast(@CategoryGrouptype As nVarchar), "Salesman" = IsNull(Salesman.Salesman_Name, dbo.LookupDictionaryItem('Others',Default)), 
		"Category Group" = IsNull(ProductCategoryGroupAbstract.GroupName, dbo.LookupDictionaryItem('All Category Groups',Default)), 
		"Net Outstanding (%c)" = SUM(IsNull(Balance,0)),
		"1-7 Days" = Sum(IsNull(OnetoSeven,0)),
		"8-10 Days" = Sum(IsNull(EighttoTen,0)),
		"11-14 Days" = Sum(IsNull(EleventoFourteen,0)),
		"15-21 Days" = Sum(IsNull(FifteentoTwentyOne,0)),
		"22-30 Days" = Sum(IsNull(TwentyTwotoThirty,0)),
		"<30 Days" = Sum(IsNull(LessthanThirty,0)),
		"31-60 Days" = Sum(IsNull(ThirtyOnetoSixty,0)),
		"61-90 Days" = Sum(IsNull(SixtyOnetoNinety,0)),
		">90 Days" = Sum(IsNull(MorethanNinety,0))
		from #temp
		Left Outer Join Salesman On #temp.SalesmanID = Salesman.SalesmanID
		Left Outer Join ProductCategoryGroupAbstract On #temp.GroupID = ProductCategoryGroupAbstract.GroupID 
		WHERE Balance <> 0
		Group By #temp.SalesmanID, Salesman.Salesman_Name, ProductCategoryGroupAbstract.Groupname, #Temp.GroupId
		Order By Case @OrderBy when 2 then ProductCategoryGroupAbstract.Groupname else Salesman.Salesman_Name End
	
	--------------
	-- Select 'In the First Part'
	--------------
	End
	Else
	if @TimeBucket1 = 0
	Begin
		Select * From #tmpInterval1_one Where [Net Outstanding (%c)] > 0
		Order By Case @OrderBy When 2 Then CategoryGroup Else SalesManName End
		Drop Table #tmpInterval1_one				
	End
	Else
	Begin
		Select "SalesManId" = Cast(#temp.SalesmanID As nVarChar) + '; ' + Cast(#temp.GroupId As nVarchar) + '; ' + Cast(@CategoryGrouptype As nVarchar), 
		"SalesMan" = IsNull(Salesman.Salesman_Name, dbo.LookupDictionaryItem('Others',Default)), 
		"CategoryGroup" = IsNull(ProductCategoryGroupAbstract.GroupName, dbo.LookupDictionaryItem('All Category Groups',Default)),
		"Balance" = SUM(IsNull(Balance,0)),"OnetoSeven" =  Sum(IsNull(OnetoSeven,0)),
		"EighttoTen" =  Sum(IsNull(EighttoTen,0)),"EleventoFourteen" =  Sum(IsNull(EleventoFourteen,0)),
		"FifteentoTwentyOne" =  Sum(IsNull(FifteentoTwentyOne,0)),"TwentyTwotoThirty" =  Sum(IsNull(TwentyTwotoThirty,0)),
		"LessthanThirty" = Sum(IsNull(LessthanThirty,0)),"ThirtyOnetoSixty" = Sum(IsNull(ThirtyOnetoSixty,0)),
		"SixtyOnetoNinety" = Sum(IsNull(SixtyOnetoNinety,0)),"MorethanNinety" = Sum(IsNull(MorethanNinety,0)),"MorethanHundred" = Sum(IsNull(MorethanHundred,0))
		Into #tmpInterval1
		from #temp
		Left Outer Join Salesman On #temp.SalesmanID = Salesman.SalesmanID
		Left Outer Join ProductCategoryGroupAbstract On #temp.GroupID = ProductCategoryGroupAbstract.GroupID 
		Group By #temp.SalesmanID, Salesman.Salesman_Name, ProductCategoryGroupAbstract.Groupname, #temp.GroupId
		
		Insert Into #tmpInterval_two(SalesManId,SalesManName,CategoryGroup, [Net Outstanding (%c)]) 
		Select SalesmanId, SalesMan,CategoryGroup, Balance From #tmpInterval1
		
		If @Interval >= 1 
		Begin
		Set @Sql = 'Update #tmpInterval_two Set [1 - ' + Cast(@TimeBucket1 As nVarchar) + ' Days ] = OneToSeven From #tmpInterval_two T, #tmpInterval1 T1 ' +
		'Where T.SalesmanID = T1.SalesmanId And T.SalesManName = T1.SalesMan And T.CategoryGroup = T1.CategoryGroup'
		Exec(@Sql)
		End
		
		If @Interval >= 2 
		Begin
			Set @Sql = 'Update #tmpInterval_two Set [' + Cast((@TimeBucket1 + 1 ) As nVarchar)  + ' - ' + Cast(@TimeBucket2 As nVarchar) +  ' Days ] = EighttoTen From #tmpInterval_two T, #tmpInterval1 T1 ' +
			'Where T.SalesmanID = T1.SalesmanId And T.SalesManName = T1.SalesMan And T.CategoryGroup = T1.CategoryGroup'
			Exec(@Sql)
		End
		
		If @Interval >= 3 
		Begin
			Set @Sql = 'Update #tmpInterval_two Set [' + Cast((@TimeBucket2 + 1) As nVarchar) + ' - ' + Cast(@TimeBucket3 As nVarchar) +  ' Days ] = EleventoFourteen From #tmpInterval_two T, #tmpInterval1 T1 ' +
			'Where T.SalesmanID = T1.SalesmanId And T.SalesManName = T1.SalesMan And T.CategoryGroup = T1.CategoryGroup'
			Exec(@Sql)
		End
		
		If @Interval >= 4 
		Begin
			Set @Sql = 'Update #tmpInterval_two Set [' +Cast((@TimeBucket3  + 1) As nVarchar) + ' - ' + Cast(@TimeBucket4 As nVarchar) +  ' Days ] = FifteentoTwentyOne From #tmpInterval_two T, #tmpInterval1 T1 ' +
			'Where T.SalesmanID = T1.SalesmanId And T.SalesManName = T1.SalesMan And T.CategoryGroup = T1.CategoryGroup'
			Exec(@Sql)
		End
		If @Interval >= 5 
		Begin
			Set @Sql = 'Update #tmpInterval_two Set [' + Cast((@TimeBucket4 + 1 ) As nVarchar) + ' - ' + Cast(@TimeBucket5 As nVarchar) +  ' Days ] = TwentyTwotoThirty From #tmpInterval_two T, #tmpInterval1 T1 ' +
			'Where T.SalesmanID = T1.SalesmanId And T.SalesManName = T1.SalesMan And T.CategoryGroup = T1.CategoryGroup'
			Exec(@Sql)
		End
		If @Interval >= 6 
		Begin
			Set @Sql = 'Update #tmpInterval_two Set [' + Cast((@TimeBucket5 + 1 ) As nVarchar)  + ' - ' + Cast(@TimeBucket6 As nVarchar) +  ' Days ] = LessthanThirty From #tmpInterval_two T, #tmpInterval1 T1 ' +
			'Where T.SalesmanID = T1.SalesmanId And T.SalesManName = T1.SalesMan And T.CategoryGroup = T1.CategoryGroup'
			Exec(@Sql)
		End
		If @Interval >= 7 
		Begin
			Set @Sql = 'Update #tmpInterval_two Set [' + Cast((@TimeBucket6 + 1 ) As nVarchar)  + ' - ' + Cast(@TimeBucket7 As nVarchar) +  ' Days ] = ThirtyOnetoSixty From #tmpInterval_two T, #tmpInterval1 T1 ' +
			'Where T.SalesmanID = T1.SalesmanId And T.SalesManName = T1.SalesMan And T.CategoryGroup = T1.CategoryGroup'
			Exec(@Sql)
		End
		If @Interval >= 8 
		Begin
			Set @Sql = 'Update #tmpInterval_two Set [' + Cast((@TimeBucket7 + 1 ) As nVarchar)  + ' - ' + Cast(@TimeBucket8 As nVarchar) +  ' Days ] = SixtyOnetoNinety From #tmpInterval_two T, #tmpInterval1 T1 ' +
			'Where T.SalesmanID = T1.SalesmanId And T.SalesManName = T1.SalesMan And T.CategoryGroup = T1.CategoryGroup'
			Exec(@Sql)
		End
		If @Interval >= 9 
		Begin
			Set @Sql = 'Update #tmpInterval_two Set [' +  Cast((@TimeBucket8 + 1 ) As nVarchar)  + ' - ' + Cast(@TimeBucket9 As nvarchar)  +  ' Days ] = MorethanNinety From #tmpInterval_two T, #tmpInterval1 T1 ' +
			'Where T.SalesmanID = T1.SalesmanId And T.SalesManName = T1.SalesMan And T.CategoryGroup = T1.CategoryGroup'
			Exec(@Sql)
		End
		If @Interval >= 10
		Begin
			Set @Sql = 'Update #tmpInterval_two Set [' + Cast((@TimeBucket9 + 1 ) As nVarchar)  + ' - ' + Cast(@TimeBucket10 As nvarchar) +  ' Days ] = MorethanHundred From #tmpInterval_two T, #tmpInterval1 T1 ' +
			'Where T.SalesmanID = T1.SalesmanId And T.SalesManName = T1.SalesMan And T.CategoryGroup = T1.CategoryGroup'
			Exec(@Sql)
		End

		If @Flag = 0
			Select SalesmanID, SalesManName,CategoryGroup,[Net Outstanding (%c)] From #tmpInterval_two Where 1 = 0
			Order By Case @OrderBy When 2 Then CategoryGroup Else SalesManName End
		Else
			Select * From #tmpInterval_two Where [Net Outstanding (%c)] > 0
			Order By Case @OrderBy When 2 Then CategoryGroup Else SalesManName End
	
	------------------------------
	-- Select 'In the second Part'
	-- select @Flag
	------------------------------
		
		Drop table #tmpInterval_two
		Drop table #TmpInterval1
	End
------------------------------------------------------------------------------
-- select @One, @LessSeven, @EqualSeven 
-- select @Seven , @Eight, @Ten 
-- select @Eleven , @Fourteen , @Fifteen 
-- select @TwentyOne, @TwentyTwo , @Thirty 
-- select @ThirtyOne , @Sixty, @SixtyOne , @Ninety
-- select @NinetyOne , @Hundred, @HundredOne
-- select @HundredTwo , @HundredThree, @HundredFour 
------------------------------------------------------------------------------

Drop table #temp
-- End

Drop table #tmpSalesMan
Drop Table #tmpCategoryGroup
Drop table #tmpItem
