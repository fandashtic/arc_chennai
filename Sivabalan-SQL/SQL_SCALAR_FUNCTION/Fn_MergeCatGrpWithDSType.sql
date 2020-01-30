create Function dbo.Fn_MergeCatGrpWithDSType(@OCGFlag as Integer,@CustomerID as Nvarchar(15) ,@GGDRmonth as nvarchar(10),@DStype Nvarchar(255),@PMCategory Nvarchar(255))
Returns 
nvarchar(1000)
as
Begin
Declare @CatGrp nvarchar(200)
Declare @TotCatGrp nvarchar(1000)
set @TotCatGrp = ''
Declare @TmpCategoryGroup as Table (GroupName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
Declare @GGDRCategoryGroup as Table (GroupName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

Declare @DStypeID as Int
Set @DStypeID = (Select Top 1 DSTypeID from DStype_Master Where Isnull(DSTypeCtlPos,0) = 1 And DSTypeValue = @DSType)

Insert Into @TmpCategoryGroup (GroupName)
Select Distinct groupName From ProductCategoryGroupAbstract Where Isnull(Active,0) = 1 and Isnull(OCGType,0) = @OCGFlag
And GroupID in (Select Distinct GroupID From tbl_mERP_DSTypeCGMapping Where Isnull(Active,0) = 1 And DSTypeID = @DStypeID)

Insert Into @GGDRCategoryGroup(GroupName)
select distinct case when @OCGFlag = 0 then CatGroup else OCG end from GGDROutlet 
where OutletID = @CustomerID COLLATE SQL_Latin1_General_CP1_CI_AS  and cast('01-'+ @GGDRmonth as DateTime) between ReportFromDate and ReportToDate
And PMCatGroup = @PMCategory

Delete From @GGDRCategoryGroup Where GroupName Not in (Select Distinct GroupName From @TmpCategoryGroup)

Declare Cur Cursor For
Select Distinct GroupName From @GGDRCategoryGroup
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
End
