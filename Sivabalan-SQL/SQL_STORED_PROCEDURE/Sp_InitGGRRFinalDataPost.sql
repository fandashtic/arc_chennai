Create Procedure Sp_InitGGRRFinalDataPost(@DaycloseFromDate DateTime = Null,@DaycloseToDate DateTime = Null)
As
Begin
	Set DateFormat DMY

	If (Select Isnull(Flag,0) Flag From Tbl_Merp_ConfigAbstract Where Screencode = 'GGRRInit') = 0
	Begin
		Set DateFormat DMY
		Exec Sp_GGRRFinaldataPost
	End
	Else If @DaycloseFromDate IS NULL And @DaycloseToDate IS NOT NULL
	Begin
		Set DateFormat DMY
		Exec Sp_GGRRFinaldataPost @DaycloseToDate
	End
	Else If @DaycloseFromDate IS NOT NULL And @DaycloseToDate IS NOT NULL
	Begin
		Declare @n as Int
		Declare @i as int
		Declare @TmpTodate as DateTime

		set @i = 0
		Set @n = DateDiff(d,@DaycloseFromDate,@DaycloseToDate)
		Set @TmpTodate = @DaycloseFromDate
		While @i <= @n
		Begin
			Set DateFormat DMY
			Set @TmpTodate = DateAdd(d,@i,@DaycloseFromDate)
			Exec Sp_GGRRFinaldataPost @TmpTodate		
			Set @i =(@i)+1 
		End
	End
	
	IF Exists(Select Top 1 'X' From PendingGGRRFinalDataPost)
	Begin
		Set DateFormat DMY
		Exec Sp_GGRRFinaldataPost Null,1
	End

	If Exists(Select 'x' From Setup Where Isnull(GGRRDaycloseFlag,0) = 1)
	Begin
		Exec Sp_UpdateDaycloseLog 'GGRR Final dataPosting is Not Completed Successfully.'
	End
End
