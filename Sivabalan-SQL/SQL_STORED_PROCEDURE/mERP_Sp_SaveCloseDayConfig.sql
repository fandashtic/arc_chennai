Create Procedure mERP_Sp_SaveCloseDayConfig(@ID int)  
As  
Declare @CloseDayEnabled as int  
Declare @GracePeriod as int  
Declare @InventoryLock as int  
Declare @FinancialLock as int  
Declare @Flag as int  
Declare @Errmessage as nvarchar(1000) 
Declare @LastUploadDate as Datetime 
Declare @CloseDayNotUpdated as int 
Declare @ResetClsDay as Int
Declare @LastInvUploadDate as Datetime
Declare @yearCheck int

Begin  

	/*
	Changes As on 31.03.2011
	1. If Setup.LastInventoryupload is Null then updating LastInventoryupload Column with the TransactionDate - GracePeriod. (Changed Functionality)
	2. If Setup.LastInventoryupload is Not Null then updating only the Flag and Grace period Values in tbl_mERP_ConfigDetail table (Changed Functionality)
	3. If CloseDay reset option given as 1 (Yes) then updating the NULL value in Setup.LastInventoryupload and 0 Value in Flag column of tbl_mERP_ConfigDetail  (Existing Functionality)
	*/	

	--Select @LastInvUploadDate = IsNull(LastInventoryUpload,'')  from Setup
	--Select @yearCheck = Year(@LastInvUploadDate) 

	Select @LastInvUploadDate = convert(nvarchar(10),lastinventoryupload,103) from Setup

	Set @CloseDayNotUpdated = 0
	select @CloseDayEnabled = isNull(Flag,0) , @ResetClsDay = isNull(ResetOption,0) from  tbl_mERP_RecConfigAbstract where ID = @ID and MenuName = N'ClosedayEnabled'  
	select @GracePeriod = isNull([Value],0) from  tbl_mERP_RecConfigDetail where ID = @ID and FieldName = N'GracePeriod'  
	select @InventoryLock = isNull(Flag,0)  from  tbl_mERP_RecConfigDetail where ID = @ID and FieldName = N'InventoryLock'  
	select @FinancialLock = isNull(Flag,0)  from  tbl_mERP_RecConfigDetail where ID = @ID and FieldName = N'FinancialLock'  

	set @Flag=1  

	--Validations required only if close day is enabled.
	 If @CloseDayEnabled = 1 And @ResetClsDay = 0
	 Begin
		 If @GracePeriod < 0   
		 Begin        
			select @Errmessage=Message from ErrorMessages where ErrorID=143  
			Insert Into tbl_mERP_RecdErrMessages (TransactionType, ErrMessage, KeyValue, ProcessDate)  
			Values('CLSDAY01', @Errmessage, Null, GetDate())  
			set @Flag=0   
		 End   

		 If @InventoryLock > 1 or  @InventoryLock < 0  
		 Begin      
			select @Errmessage=Message from ErrorMessages where ErrorID=144  
			Insert Into tbl_mERP_RecdErrMessages (TransactionType, ErrMessage, KeyValue, ProcessDate)  
			Values('CLSDAY01', @Errmessage, Null, GetDate())  
			set @Flag=0   
		 End  

		 if @FinancialLock > 1 or  @FinancialLock < 0  
		 Begin      
			select @Errmessage=Message from ErrorMessages where ErrorID=145  
			Insert Into tbl_mERP_RecdErrMessages (TransactionType, ErrMessage, KeyValue, ProcessDate)  
			Values('CLSDAY01', @Errmessage, Null, GetDate())  
			set @Flag=0   
		 End  

		 --GracePeriod cannot be Zero if Close period is Enabled
		if @CloseDayEnabled = 1 And  @GracePeriod <= 0  
		Begin      
			select @Errmessage=Message from ErrorMessages where ErrorID=152  
			Insert Into tbl_mERP_RecdErrMessages (TransactionType, ErrMessage, KeyValue, ProcessDate)  
			Values('CLSDAY01', @Errmessage, Null, GetDate())  
			set @Flag=0   
		End  
	End
	 
	--Reset close day
	If  @ResetClsDay = 1 
		Set @Flag = 2

	
	 If (@Flag=1 and @LastInvUploadDate Is Null)
	 Begin 
		   Update tbl_mERP_ConfigAbstract set Flag = 0  where ScreenCode = 'RSTCLSDAY01' and ScreenName = N'ResetClosedDate'  	
		   Update tbl_mERP_ConfigAbstract set Flag=@CloseDayEnabled  where ScreenCode=N'CLSDAY01' and ScreenName=N'ClosedayEnabled'  
		   Update tbl_mERP_ConfigDetail set Value=@GracePeriod  where ScreenCode=N'CLSDAY01' and Controlname=N'GracePeriod'    
		   Update tbl_mERP_ConfigDetail set Flag=@InventoryLock  where ScreenCode=N'CLSDAY01' and Controlname=N'InventoryLock'  
		   Update tbl_mERP_ConfigDetail set Flag=@FinancialLock  where ScreenCode=N'CLSDAY01' and Controlname=N'FinancialLock'  
		   Update tbl_mERP_RecConfigDetail Set Status = Status | 32 where ID = @ID  
		   Update tbl_mERP_RecConfigAbstract Set Status = Status | 32 where ID = @ID  

		   --Set the last InventoryUploadDate 
		   If @CloseDayEnabled	= 1
		   Begin
			   Select @LastUploadDate	= DateAdd(day,0 - @GracePeriod,TransactionDate) From Setup
			   If 	@LastUploadDate > (Select isNull(LastInventoryUpload,'') From Setup)
					Update Setup Set LastInventoryUpload = DateAdd(day,0 - @GracePeriod,TransactionDate), OldInventoryUploadDate = DateAdd(day,0 - @GracePeriod,TransactionDate)
			   Else
			   Begin
					Set @CloseDayNotUpdated = 1
			   End			
		   End
	 End
	 Else If (@Flag=1 and @LastInvUploadDate Is Not Null)
	 Begin 
		   Update tbl_mERP_ConfigAbstract set Flag = 0  where ScreenCode = 'RSTCLSDAY01' and ScreenName = N'ResetClosedDate'  	
		   Update tbl_mERP_ConfigAbstract set Flag=@CloseDayEnabled  where ScreenCode=N'CLSDAY01' and ScreenName=N'ClosedayEnabled'  
		   Update tbl_mERP_ConfigDetail set Value=@GracePeriod  where ScreenCode=N'CLSDAY01' and Controlname=N'GracePeriod'    
		   Update tbl_mERP_ConfigDetail set Flag=@InventoryLock  where ScreenCode=N'CLSDAY01' and Controlname=N'InventoryLock'  
		   Update tbl_mERP_ConfigDetail set Flag=@FinancialLock  where ScreenCode=N'CLSDAY01' and Controlname=N'FinancialLock'  
		   Update tbl_mERP_RecConfigDetail Set Status = Status | 32 where ID = @ID  
		   Update tbl_mERP_RecConfigAbstract Set Status = Status | 32 where ID = @ID  
	 End
	 Else if @Flag = 0    
	 Begin
		Update tbl_mERP_RecConfigDetail Set Status = Status | 64 where ID = @ID
		Update tbl_mERP_RecConfigAbstract Set Status = Status | 32 where ID = @ID
	 End
	 Else If @Flag = 2 
	 Begin
		--To Reset CLloseDay Option
		Update tbl_mERP_ConfigAbstract set Flag = 1  where ScreenCode = 'RSTCLSDAY01' and ScreenName = N'ResetClosedDate'  
		Update tbl_mERP_ConfigAbstract set Flag = 0  where ScreenCode=N'CLSDAY01' and ScreenName=N'ClosedayEnabled'  
		Update tbl_mERP_ConfigDetail set Value = 0  where ScreenCode=N'CLSDAY01' and Controlname=N'GracePeriod'    
		Update tbl_mERP_ConfigDetail set Flag = 0  where ScreenCode=N'CLSDAY01' and Controlname=N'InventoryLock'  
		Update tbl_mERP_ConfigDetail set Flag = 0  where ScreenCode=N'CLSDAY01' and Controlname=N'FinancialLock'  
		Update Setup Set LastInventoryUpload = NULL, OldInventoryUploadDate = NULL, InventoryUploadStatus = 0
		Update tbl_mERP_RecConfigDetail Set Status = Status | 32 where ID = @ID
		Update tbl_mERP_RecConfigAbstract Set Status = Status | 32 where ID = @ID
	 End     

	Select @CloseDayNotUpdated     

End
