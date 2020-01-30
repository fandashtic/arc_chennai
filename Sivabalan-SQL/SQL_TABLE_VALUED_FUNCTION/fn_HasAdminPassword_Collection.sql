create function dbo.fn_HasAdminPassword_Collection(@Ordernumber nvarchar(200),@DocDate datetime,@InvUploadFlag int)
Returns @Ouput Table (ErrorNumber int, ErrorDescription nvarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS)
AS
BEGIN
	/* Return 0 if NO Error else 1 or 2 or 3*/
	Declare @ReturnValue Int
	Declare @OpeningDate Datetime
	Declare @Error nvarchar(2000)
	
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
			Set @Error='Serial No ' + @Ordernumber + ' -  Day is closed.You can do transaction only between '+cast(DateAdd(D, 1,@LastInventoryUpload) as nvarchar(25))+' and '+ cast(@GraceDate as nvarchar(25))
			--exec sp_han_updatesc @Ordernumber,2
			--exec sp_han_InsertErrorlog @Ordernumber,1,'Information','Aborted',@Error,@SalesmanID
			Insert into @Ouput(ErrorNumber,ErrorDescription)
			Select 0,@Error
			Goto ExitFn		
		END
		
		If (@DocDate < (Select OpeningDate from Setup))
		BEGIN
			Set @Error='Transaction date '+cast(@DocDate as nvarchar(25))+' lesser than 1st Transaction Date.'
			--exec sp_han_updatesc @Ordernumber,2
			--exec sp_han_InsertErrorlog @Ordernumber,1,'Information','Aborted',@Error,@SalesmanID
			Insert into @Ouput(ErrorNumber,ErrorDescription)
			Select 0,@Error
			Goto ExitFn		
		END	
		
		If (@DocDate > GETDATE())
		BEGIN
			Set @Error='Transaction date ['+@DocDate+'] is Postdated.'
			--exec sp_han_updatesc @Ordernumber,2
			--exec sp_han_InsertErrorlog @Ordernumber,1,'Information','Aborted',@Error,@SalesmanID
			Insert into @Ouput(ErrorNumber,ErrorDescription)
			Select 0,@Error
			Goto ExitFn		
		END	

		Set @ReturnValue=1
	END
ExitFn:
	Insert into @Ouput(ErrorNumber,ErrorDescription)
	Select 1,''

Return
END
