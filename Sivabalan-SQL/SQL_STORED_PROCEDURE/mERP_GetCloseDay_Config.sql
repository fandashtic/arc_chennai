Create Procedure mERP_GetCloseDay_Config
As
Begin
	Declare @DayCloseEnabled As Int
	Declare @InventoryLock As Int
	Declare @FinancialLock As Int
	Declare @DayCls as Int

	select @DayCloseEnabled = isnull(Flag,0) from tbl_merp_configAbstract  where ScreenCode = N'CLSDAY01' 
	and ScreenName in ('ClosedayEnabled')

	select @InventoryLock = isnull(Flag,0) from tbl_Merp_ConfigDetail where ScreenCode = N'CLSDAY01' 
	and Controlname = N'InventoryLock'

	select @FinancialLock = isnull(Flag,0) from tbl_Merp_ConfigDetail where ScreenCode = N'CLSDAY01' 
	and Controlname = N'FinancialLock'

	Select @DayCls  = (Case When LastInventoryUpload is Null Then 0 Else 1 End) From SetUp


	If  @DayCls = 0 And @DayCloseEnabled = 0 
	Begin
		Set @InventoryLock = 0
		Set @FinancialLock = 0
	End
	
	Select @InventoryLock , @FinancialLock
	
End
