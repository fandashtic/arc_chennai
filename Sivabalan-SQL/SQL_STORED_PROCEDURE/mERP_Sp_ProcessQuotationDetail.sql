Create Procedure mERP_Sp_ProcessQuotationDetail (@ID int)
As
Declare @ChannelCode nVarchar(255)
Declare @ChannelName nVArchar(510)
Declare @OutletCode nVArchar(255) 
Declare @OutletName nVArchar(510)
Declare @LoyaltyCode nVArchar(255) 
Declare @LoyaltyName nVArchar(510)
Declare @Active int
Declare @SlNo int

Declare @KeyValue nVarchar(255)
Declare @Errmessage nVarchar(4000)
Declare @ErrStatus int
Declare @tmpChannelCode int
Declare @Flag int
Declare @QType int

Set @ErrStatus = 0

Select  @QType = IsNull(QuotationType,1) From tbl_mERP_RecdQuotationDetail where RecdID = @ID 

Update tbl_mERP_QuotChannelDetail Set Active = 0 Where IsNull(QuotationType,1) = @QType


Select @Flag = Flag from tbl_merp_configAbstract where ScreenCode = N'QCC01'

Declare QuotationCursor Cursor for 
Select  ChannelCode, Channelname, OutletCode, OutletName, LoyaltyCode, LoyaltyName, Active, ID, IsNull(QuotationType,1)
From tbl_mERP_RecdQuotationDetail
where RecdID = @ID and IsNull(Status,0) = 0

Open QuotationCursor 
Fetch From QuotationCursor Into @ChannelCode,  @ChannelName,  @OutletCode , @OutletName, @LoyaltyCode, @LoyaltyName, @Active, @SlNo, @QType 

While @@Fetch_Status = 0  
Begin 

Set @ErrStatus = 0

If ((Isnull(@ChannelCode,'') = '') or (Isnull(@OutletCode,'') = N'') Or (Isnull(@LoyaltyCode,'') = N''))
Begin
	Set @Errmessage = 'ChannelCode/OutletCode/LoyaltyCode should not be Null'
	Set @ErrStatus = 1
	Goto last
End

If ((Isnull(@ChannelName,'') = N'') or (Isnull(@OutletName,'') = N'') Or (Isnull(@LoyaltyName,'') = N''))
Begin
	Set @Errmessage = 'Channelname/Outletname/LoyaltyName should not be Null'
	Set @ErrStatus = 1
	Goto last
End

If ((Isnull(@ChannelCode,'') <> N'ALL')  and (Isnull(Upper(@ChannelName),'') =  N'ALL')) Or 
	((Isnull(@ChannelCode,'') = N'ALL')  and (Isnull(Upper(@ChannelName),'') <>  N'ALL')) 
Begin
	Set @Errmessage = 'If ALL is present in ChannelName then ChannelCode Should also be All. Viceversa '
	Set @ErrStatus = 1
	Goto last
End

If ((Isnull(@OutletCode,'') <> N'ALL')  and (Isnull(Upper(@OutletName),'') =  N'ALL')) Or 
	((Isnull(@OutletCode,'') = N'ALL')  and (Isnull(Upper(@OutletName),'') <>  N'ALL')) 
Begin
	Set @Errmessage = 'If ALL is present in OutletName then OutletCode Should also be All. Viceversa '
	Set @ErrStatus = 1
	Goto last
End

If ((Isnull(@LoyaltyCode,'') <> N'ALL')  and (Isnull(Upper(@LoyaltyName),'') =  N'ALL')) Or 
	((Isnull(@LoyaltyCode,'') = N'ALL')  and (Isnull(Upper(@LoyaltyName),'') <>  N'ALL')) 
Begin
	Set @Errmessage = 'If ALL is present in OutletName then OutletCode Should also be All. Viceversa '
	Set @ErrStatus = 1
	Goto last
End

If IsNull(@Active,0) > 1
Begin
	Set @Errmessage = 'Active Should not be Greater than 1'
	Set @ErrStatus = 1
	Goto last
End



If (@Flag = 0)
Begin
	If (isNull(upper(@ChannelName),'') <> N'ALL')
	Begin
		If ( Select count(*)  from customer_Channel where ChannelDesc = LTrim(RTrim(@ChannelName))) >=1
		Begin
			Set @ChannelCode = N''
			Select @tmpChannelCode = ChannelType from Customer_Channel where ChannelDesc = LTrim(RTrim(@ChannelName))
			Set	@ChannelCode = Convert(nVarchar, @tmpChannelCode)
			Insert Into tbl_mERP_QuotChannelDetail(RecdID, Channel_Type_Code, Channel_Type_Desc, Outlet_Type_Code, Outlet_Type_Desc,
				SubOutlet_Type_Code, SubOutlet_Type_Desc, Active, QuotationType) 
			Values(@ID, @ChannelCode,  @ChannelName,  @OutletCode , @OutletName, @LoyaltyCode, @LoyaltyName, @Active, @QType)				
		End
		Else
		Begin
			Set @Errmessage = 'channel Description Doesnot exist in CustomerChannel master'
			Set @ErrStatus = 1
			Goto last
		End
	End
	Else
	Begin
			Insert Into tbl_mERP_QuotChannelDetail(RecdID, Channel_Type_Code, Channel_Type_Desc, Outlet_Type_Code, Outlet_Type_Desc,
				SubOutlet_Type_Code, SubOutlet_Type_Desc, Active, QuotationType) 
			Values(@ID, @ChannelCode,  @ChannelName,  @OutletCode , @OutletName, @LoyaltyCode, @LoyaltyName, @Active, @QType)				
	End
End
Else -- If Flag = 1
Begin
	If (upper(@ChannelCode) <> N'ALL') and (upper(@OutletCode) <> N'ALL')
	Begin
		If (Select Count(*) from tbl_Merp_olclass Where Channel_Type_Code = @ChannelCode and Channel_Type_Desc = @ChannelName and
			Outlet_type_code = @OutletCode and Outlet_type_Desc = @OutletName)>=1
		Begin
			Insert Into tbl_mERP_QuotChannelDetail(RecdID, Channel_Type_Code, Channel_Type_Desc, Outlet_Type_Code, Outlet_Type_Desc,
				SubOutlet_Type_Code, SubOutlet_Type_Desc, Active, QuotationType) 
			Values(@ID, @ChannelCode,  @ChannelName,  @OutletCode , @OutletName, @LoyaltyCode, @LoyaltyName, @Active, @QType)		
		End
		Else
		Begin
			Set @Errmessage = 'Mapping of channelCode/Name and OutletCode/name Mismatch with Master'
			Set @ErrStatus = 1
			Goto last
		End
	End
	Else If (upper(@ChannelCode) <> N'ALL') and (upper(@OutletCode) = N'ALL')
	Begin
		If (Select Count(*) from tbl_Merp_olclass Where Channel_Type_Code = @ChannelCode and Channel_Type_Desc = @ChannelName) >= 1
		Begin
			Insert Into tbl_mERP_QuotChannelDetail(RecdID, Channel_Type_Code, Channel_Type_Desc, Outlet_Type_Code, Outlet_Type_Desc,
				SubOutlet_Type_Code, SubOutlet_Type_Desc, Active, QuotationType) 
			Values(@ID, @ChannelCode,  @ChannelName,  @OutletCode , @OutletName, @LoyaltyCode, @LoyaltyName, @Active, @QType)		
		End
		Else
		Begin
			Set @Errmessage = 'Mapping of channelCode/Name Mismatch with Master'
			Set @ErrStatus = 1
			Goto last
		End
	End
	Else If (upper(@ChannelCode) = N'ALL') and (upper(@OutletCode) <> N'ALL')
	Begin
		If (Select Count(*) from tbl_Merp_olclass Where Outlet_Type_Code = @OutletCode and Outlet_Type_Desc = @OutletName) >= 1
		Begin
			Insert Into tbl_mERP_QuotChannelDetail(RecdID, Channel_Type_Code, Channel_Type_Desc, Outlet_Type_Code, Outlet_Type_Desc,
				SubOutlet_Type_Code, SubOutlet_Type_Desc, Active, QuotationType) 
			Values(@ID, @ChannelCode,  @ChannelName,  @OutletCode , @OutletName, @LoyaltyCode, @LoyaltyName, @Active, @QType)		
		End
		Else
		Begin
			Set @Errmessage = 'Mapping of OutletCode/Name Mismatch with Master'
			Set @ErrStatus = 1
			Goto last
		End
	End
	Else
	Begin
			Insert Into tbl_mERP_QuotChannelDetail(RecdID, Channel_Type_Code, Channel_Type_Desc, Outlet_Type_Code, Outlet_Type_Desc,
				SubOutlet_Type_Code, SubOutlet_Type_Desc, Active, QuotationType) 
			Values(@ID, @ChannelCode,  @ChannelName,  @OutletCode , @OutletName, @LoyaltyCode, @LoyaltyName, @Active, @QType)		
	End
End -- End of Flag Check


-- Status Updation
Update tbl_mERP_RecdQuotationAbstract  Set Status = 1
Update tbl_mERP_RecdQuotationDetail Set Status = 1  Where ID = @SlNo  and RecdID = @ID

Last:
	-- Error Log Written and Status Updation of rejected Detail 
	If (@ErrStatus = 1)
	Begin
		Set @KeyValue = ''
		Set @KeyValue = Convert(nVarchar, @ID) + '|' + Convert(nVarchar,@SlNo)
		Update tbl_mERP_RecdQuotationAbstract Set Status = 2
		Update tbl_mERP_RecdQuotationDetail Set Status = 2  Where ID = @SlNo  and RecdID = @ID
		Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)    
		Values('Quotation', @Errmessage,  @KeyValue, getdate())  
	End

Fetch Next From QuotationCursor Into @ChannelCode,  @ChannelName,  @OutletCode , @OutletName, @LoyaltyCode, @LoyaltyName, @Active, @SlNo, @QType 
End

Close QuotationCursor
DeAllocate QuotationCursor

