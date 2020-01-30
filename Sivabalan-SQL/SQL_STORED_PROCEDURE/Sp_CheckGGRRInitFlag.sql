Create Procedure dbo.Sp_CheckGGRRInitFlag
As
Begin
	Declare @FlagValue as Int
	IF (Select Isnull(Flag,0) Flag From Tbl_Merp_ConfigAbstract Where Screencode = 'GGRRInit') = 0
	Begin
		Set @FlagValue = 1
		Goto OUT
	End

	IF Exists(Select Top 1 'X' From PendingGGRRFinalDataPost)
	Begin
		Set @FlagValue = 1
		Goto OUT
	End

OUT:
	If Isnull(@FlagValue,0) = 1
	Begin
		Update SetUp set GGRRDaycloseFlag = 1
	End
	Else If Isnull(@FlagValue,0) = 0 And (Select Isnull(GGRRDaycloseFlag,0) From Setup) = 1
	Begin
		Update SetUp set GGRRDaycloseFlag = 0
	End

	Select Isnull(@FlagValue,0) Flag
End
