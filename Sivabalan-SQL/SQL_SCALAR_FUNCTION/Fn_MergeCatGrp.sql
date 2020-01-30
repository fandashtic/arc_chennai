create Function dbo.Fn_MergeCatGrp(@OCGFlag as Integer,@CustomerID as Nvarchar(15) ,@GGDRmonth as nvarchar(10))
Returns 
nvarchar(1000)
as
Begin
--Declare @OCGFlag as Integer,@CustomerID as Nvarchar(15),@GGDRmonth as nvarchar(10)
Declare @CatGrp nvarchar(200)
Declare @TotCatGrp nvarchar(1000)
--set @OCGFlag =0
--set @CustomerID ='101'
--set @GGDRmonth ='Jan-2014'
set @TotCatGrp = ''
--select * from GGDROutlet
Declare Cur Cursor For
select distinct case when @OCGFlag = 0 then CatGroup else OCG end from GGDROutlet 
where OutletID = @CustomerID COLLATE SQL_Latin1_General_CP1_CI_AS  and cast('01-'+ @GGDRmonth as DateTime) between ReportFromDate and ReportToDate
	Open Cur
	Fetch from Cur into @CatGrp
	While @@fetch_status =0
		Begin
			if (@TotCatGrp = '' )
				set @TotCatGrp = @CatGrp
			else
				set @TotCatGrp = @TotCatGrp + '|' + @CatGrp

		Fetch Next from Cur into @CatGrp
		End
	
Close Cur
Deallocate Cur
Return (@TotCatGrp)
--select @TotCatGrp
End
