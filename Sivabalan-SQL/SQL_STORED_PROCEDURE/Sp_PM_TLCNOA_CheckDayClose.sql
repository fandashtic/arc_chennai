Create Procedure dbo.Sp_PM_TLCNOA_CheckDayClose (@ParamType nvarchar(20))
As  
Begin
	Set DateFormat DMY
	Declare @LastDayCloseDate as DateTime
	Declare @CheckDate as DateTime
	Declare @LockDayCount as Int
	Declare @PMMonth as Nvarchar(25)
	Declare @AutoPostCount as Int
	Create Table #TempPMID (PMID Int)

	Set @LockDayCount = (Select IsNull(CfgDet.Value,0) From tbl_merp_configAbstract CfgAbs, tbl_merp_configDetail CfgDet  Where CfgDet.ScreenCode = 'PMSTDT01'
						And CfgAbs.ScreenCode = CfgDet.ScreenCode   And CfgDet.Flag = 1  And CfgAbs.Flag = 1)

	Set @LastDayCloseDate = (select Top 1 LastInventoryUpload from Setup)
	Set @CheckDate = cast(( cast(@LockDayCount as Nvarchar) + '/' + cast(Month(@LastDayCloseDate) as Nvarchar) + '/' + Cast(Year(@LastDayCloseDate) as Nvarchar)) As DateTime)
	Set @PMMonth =  Left(DateName(Month,@LastDayCloseDate),3) + '-' + Cast(Year(@LastDayCloseDate) as Nvarchar)
	Truncate table #TempPMID

	IF @ParamType = 'TLC'
		Insert Into #TempPMID (PMID)
		--select Distinct PMID from tbl_mERP_PMMaster Where Period in (@PMMonth) and Active = 1 and dbo.StripDateFromTime(Creationdate) <= @CheckDate and Isnull(AutoPost_TLC , 0) = 0
		Select Distinct PMID from tbl_mERP_PMMaster Where Period in (@PMMonth) and Active = 1 and Isnull(AutoPost_TLC , 0) = 0
	ELSE IF @ParamType = 'NOA'
		Insert Into #TempPMID (PMID)
		--select Distinct PMID from tbl_mERP_PMMaster Where Period in (@PMMonth) and Active = 1 and dbo.StripDateFromTime(Creationdate) <= @CheckDate and Isnull(AutoPost_NOA , 0) = 0
		Select Distinct PMID from tbl_mERP_PMMaster Where Period in (@PMMonth) and Active = 1 and Isnull(AutoPost_NOA , 0) = 0

	Set @AutoPostCount = (select Count(*) from #TempPMID)

	--If @LastDayCloseDate >= @CheckDate and @AutoPostCount > 0
	If @AutoPostCount > 0
	Begin
		Select 1 PMTargetAutoPost
		Goto OUT
	End
	Else
	Begin
		Select 0 PMTargetAutoPost
		Goto OUT
	End
OUT:
	Drop Table #TempPMID
End
