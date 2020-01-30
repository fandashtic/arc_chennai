create function dbo.fn_HasAdminPassword(@Ordernumber nvarchar(200),@DocDate datetime,@InvUploadFlag int)
Returns nvarchar(4000)
AS
BEGIN
	/* Return 0 if NO Error else 1 or 2 or 3*/
	Declare @ReturnValue Int
	Declare @OpeningDate Datetime
	Declare @Error nvarchar(2000)
	Declare @ErrorDescription nvarchar(4000)
	Declare @TransactionDate Datetime
	
--	SELECT TOP 1 @TransactionDate = TransactionDate FROM Setup  
--	If (Getdate() < @TransactionDate)
--	BEGIN
--		Set @Error='The system date is less than the last transaction date. Change the system date and click yes to proceed. You will have to logout and login again.'
--		--exec sp_han_updatesc @Ordernumber,2
--		--exec sp_han_InsertErrorlog @Ordernumber,1,'Information','Aborted',@Error,@SalesmanID
--		Set  @ErrorDescription=@Error
--		Goto ExitFn		
--	END	

	SELECT TOP 1 @OpeningDate=OpeningDate FROM Setup
	If @InvUploadFlag=1
	BEGIN
		
		Declare @LastInventoryUpload Datetime
		Declare @GraceDays int
		Declare @ClosedayEnabled Int
		Declare @GraceDate Datetime
		
	    Select @LastInventoryUpload = LastInventoryUpload FROM Setup
		Select @GraceDays=isNull(Value,0) From  tbl_mERP_ConfigDetail  where ScreenCode=N'CLSDAY01' and Controlname=N'GracePeriod'
		select @ClosedayEnabled=isnull(Flag,0) from tbl_merp_configAbstract where ScreenCode=N'CLSDAY01' and ScreenName in (N'ClosedayEnabled')
		
		If @ClosedayEnabled=1
			Set @GraceDate= DateAdd(MI, 59, DateAdd(HH, 23, DateAdd(D, @GraceDays, @LastInventoryUpload)))
		ELSE
			Set @GraceDate= DateAdd(MI, 59, DateAdd(HH, 23, GETDATE()))
			
		Set @LastInventoryUpload = DateAdd(MI, 59, DateAdd(HH, 23, @LastInventoryUpload))
		
		If ((@DocDate < @LastInventoryUpload) Or (@DocDate > @GraceDate)) 
		BEGIN
			Set @Error='Order number ' + @Ordernumber + ' -  Day is closed.You can do transaction only between '+cast(DateAdd(D, 1,@LastInventoryUpload) as nvarchar(25))+' and '+ cast(@GraceDate as nvarchar(25))
			--exec sp_han_updatesc @Ordernumber,2
			--exec sp_han_InsertErrorlog @Ordernumber,1,'Information','Aborted',@Error,@SalesmanID
			Set @ErrorDescription=@Error
			Goto ExitFn		
		END
		
		If (@DocDate < (Select OpeningDate from Setup))
		BEGIN
			Set @Error='Transaction date '+cast(@DocDate as nvarchar(25))+' lesser than 1st Transaction Date.'
			--exec sp_han_updatesc @Ordernumber,2
			--exec sp_han_InsertErrorlog @Ordernumber,1,'Information','Aborted',@Error,@SalesmanID
			Set  @ErrorDescription=@Error
			Goto ExitFn		
		END	
		
		If (@DocDate > GETDATE())
		BEGIN
			Set @Error='Transaction date ['+@DocDate+'] is Postdated.'
			--exec sp_han_updatesc @Ordernumber,2
			--exec sp_han_InsertErrorlog @Ordernumber,1,'Information','Aborted',@Error,@SalesmanID
			Set  @ErrorDescription=@Error
			Goto ExitFn		
		END	
		Set @ReturnValue=1
	END
ExitFn:
	--Set  @ErrorDescription=''

Return @ErrorDescription
END
