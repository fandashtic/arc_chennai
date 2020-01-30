Create Procedure mERP_Sp_PreChkGSTDateEnabled
As
Begin
	Declare @GSTDate Datetime
	Declare @DayCloseDate Datetime
	Declare @PreChkFlag	Int
	Set @PreChkFlag = 0
	
	Select @GSTDate = dbo.striptimefromdate(GSTDateEnabled) From Setup
	Select @DayCloseDate = dbo.striptimefromdate(LastInventoryUpload) From Setup
	
	IF (Select isnull(Flag,0) From tbl_merp_ConfigAbstract Where ScreenName = 'GSTaxEnabled') = 0
	Begin	
		IF Exists(Select 'x' From tbl_mERP_RecConfigAbstract Where MenuName = 'GSTaxEnabled' and Status = 3 and isnull(Flag,0) = 1)
		Begin
			If @DayCloseDate > = dbo.striptimefromdate(DateAdd(d,-1,@GSTDate))
			Begin
				Set @PreChkFlag = 1
			End
		End		
	End
	
	Select @PreChkFlag 
End
