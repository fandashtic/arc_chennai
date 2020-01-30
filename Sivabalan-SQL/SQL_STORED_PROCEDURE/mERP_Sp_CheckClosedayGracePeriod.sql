Create Procedure mERP_Sp_CheckClosedayGracePeriod  
As  
Declare @DayCount int  
Declare @LastInventoryUpload datetime  
Declare @TransactionDate Datetime
Begin   
	select @DayCount=isnull(Value,0) from tbl_Merp_ConfigDetail 
	where ScreenCode=N'CLSDAY01' and Controlname=N'GracePeriod'  
	select @LastInventoryUpload=LastInventoryUpload ,@TransactionDate = TransactionDate from setup
	if @DayCount=0 
	Begin
		select 0 ,@DayCount
	End 
	Else     
	Begin
		--If Datediff(day,@LastInventoryUpload,@TransactionDate)> @DayCount  	
		If Datediff(day,@LastInventoryUpload,dbo.stripTimeFromDate(GetDate()))> @DayCount  	
		Begin  
			Update tbl_Merp_ConfigDetail set Flag=1 where ScreenCode=N'CLSDAY01' and Controlname=N'ClosedayViolation'
			select 1  , @DayCount
		End  
		Else
		Begin  
			Update tbl_Merp_ConfigDetail set Flag=0 where ScreenCode=N'CLSDAY01' and Controlname=N'ClosedayViolation' 
			select 0 ,@DayCount
		End
	End 
End

