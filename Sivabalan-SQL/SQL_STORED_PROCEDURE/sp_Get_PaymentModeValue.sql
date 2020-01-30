
Create Procedure sp_Get_PaymentModeValue(@Mode Nvarchar(255)=N'',@Value nVarchar(4000)=N'')
As
Begin
Declare @Delimiter  nvarchar(1)
Declare @cur_PaymentValue  Cursor
Declare @nMode Int
Declare @ModeValue nVarchar(100)
Declare @PaymentMode nVarchar(4000)
Set @Delimiter=','
	if @Mode <> N''
	Begin
		Create Table #tmpMode(Mode Int)
		Insert Into #tmpMode Select * From dbo.sp_splitIn2Rows(@Mode,@Delimiter)
		
		--Fetches All Corresponding Payment Value For The Modes Passed  And Stores In A StringVariable Seperated By ","
		Set @cur_PaymentValue=Cursor For Select Mode From #tmpMode
		Open @Cur_PaymentValue
		Fetch Next From @Cur_PaymentValue Into @nMode
		While @@Fetch_status = 0 
		Begin
			Select @ModeValue = (Select Isnull(Value,'') From PaymentTerm Where Mode=@nMode )
			Set @PaymentMode = Isnull(@PaymentMode,'')  + ','  + @ModeValue 
			Fetch Next From @Cur_PaymentValue Into @nMode	
		End
		Set @PaymentMode = SubString(@paymentMode,2,len(@PaymentMode))
		Select @PaymentMode
		Deallocate @cur_PaymentValue
		Drop Table #tmpMode
	End	
	else if @Value <> N''
	Begin
		Create Table #tmpValue(Value Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
		Insert Into #tmpValue Select * From dbo.sp_splitIn2Rows(@Value,@Delimiter)
		
		--Fetches All Corresponding Payment Modes For The Values Passed  And Stores In A StringVariable Seperated By ","
		Set @cur_PaymentValue = Cursor For Select Value From #tmpValue
		Open @cur_PaymentValue
		Fetch Next From @cur_paymentValue Into @ModeValue
		While @@Fetch_status = 0
		Begin
			Select @nMode = (Select Isnull(Mode,0) From PaymentTerm Where Value=@ModeValue)
			Set @PaymentMode = Isnull(@PaymentMode,'') + ',' + cast(@nMode as nVarchar)
			Fetch Next From @cur_paymentValue Into @ModeValue
		End
		Set @PaymentMode = SubString(@paymentMode,2,len(@PaymentMode))
		Select @PaymentMode
		Deallocate @cur_PaymentValue
		Drop Table #tmpValue
	End
End


