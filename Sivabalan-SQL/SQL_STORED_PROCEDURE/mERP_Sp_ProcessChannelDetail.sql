Create Procedure mERP_Sp_ProcessChannelDetail (@ID int)
AS
Declare @Channel_Type_Code nVarchar(15)
Declare @Channel_Type_Desc nVarchar(255)
Declare @Channel_Type_Active int
Declare @Outlet_Type_Code nVarchar(15)
Declare @Outlet_Type_Desc nVarchar(255)
Declare @Outlet_Type_Active int
Declare @SubOutlet_Type_Code nVarchar(15)
Declare @SubOutlet_Type_Desc nVarchar(255)
Declare @SubOutlet_Type_Active int
Declare @CreationDate  datetime
Declare @ModifiedDate datetime
Declare @SlNo int
Declare @MappingID int 


Declare @Errmessage nVarchar(4000)
Declare @ErrStatus int

Set @ErrStatus = 0

Declare ChannelCursor Cursor for 
Select  Channel_Type_Code,
Channel_Type_Desc,
Channel_Type_Active,
Outlet_Type_Code,
Outlet_Type_Desc,
Outlet_Type_Active,
SubOutlet_Type_Code,
SubOutlet_Type_Desc,
SubOutlet_Type_Active,
ID
from tbl_mERP_RecdOLClassDetail
where RecdID = @ID and IsNull(Status,0) = 0




Open ChannelCursor 
Fetch From ChannelCursor  Into @Channel_Type_Code,  @Channel_Type_Desc,  @Channel_Type_Active , @Outlet_Type_Code,
@Outlet_Type_Desc,  @Outlet_Type_Active , @SubOutlet_Type_Code, @SubOutlet_Type_Desc,  @SubOutlet_Type_Active, @SlNo 

While @@Fetch_Status = 0  
Begin 

Set @ErrStatus = 0

If ((Isnull(@Channel_Type_Code,'') = '') Or (Isnull(@Outlet_Type_Code,'') = '') Or (Isnull(@SubOutlet_Type_Code,'') = ''))
Begin
	Set @Errmessage = 'Code should not be Null'
	Set @ErrStatus = 1
	Goto last
End


If ((IsNull(@Channel_Type_Desc,'') = '') Or (IsNull(@Outlet_Type_Desc,'') = '') or (IsNull(@SubOutlet_Type_Desc,'') = ''))
Begin
	Set @Errmessage = 'Name should not be Null'
	Set @ErrStatus = 1
	Goto last
End


If ((Len(@Channel_Type_Code) > 25) Or (Len(@Outlet_Type_Code) > 25) Or (Len(@SubOutlet_Type_Code) > 25))
Begin
	Set @Errmessage = 'Code should be lesser than or Equal to  15  chanracters'
	Set @ErrStatus = 1
	Goto last
End 


If ((Len(@Channel_Type_Desc) > 255) Or (Len(@Outlet_Type_Desc) > 255 ) or (Len(@SubOutlet_Type_Desc) > 255))
Begin
	Set @Errmessage = 'Name should be lesser than or Equal to  255  chanracters'
	Set @ErrStatus = 1
	Goto last
End


If ((isNull(@Channel_Type_Active, 0) > 1) Or (isNull(@Outlet_Type_Active, 0) > 1) Or (isNull(@SubOutlet_Type_Active, 0) > 1))
Begin
	Set @Errmessage = 'Active Column Value should be 0 or 1'
	Set @ErrStatus = 1
	Goto last
End



If ( Select Count(*) from tbl_mERP_OLClass Where  Channel_Type_Code = @Channel_Type_Code and Outlet_Type_Code = @Outlet_Type_Code 
and SubOutlet_Type_Code = @SubOutlet_Type_Code) = 0
Begin
	Insert Into tbl_mERP_OLClass(Channel_Type_Code, Channel_Type_Desc, Channel_Type_Active, Outlet_Type_Code,
	Outlet_Type_Desc, Outlet_Type_Active, SubOutlet_Type_Code, SubOutlet_Type_Desc, SubOutlet_Type_Active, 
	CreationDate, ModifiedDate
	)
	Values (@Channel_Type_Code, @Channel_Type_Desc, @Channel_Type_Active, @Outlet_Type_Code, @Outlet_Type_Desc,
	@Outlet_Type_Active, @SubOutlet_Type_Code, @SubOutlet_Type_Desc, @SubOutlet_Type_Active, getdate(), null)
End
Else
Begin
	Set @MappingID = 0
	Select @MappingID = ID from tbl_mERP_OLClass Where  Channel_Type_Code = @Channel_Type_Code and Outlet_Type_Code = @Outlet_Type_Code 
	and SubOutlet_Type_Code = @SubOutlet_Type_Code

	Update tbl_mERP_OLClass Set Channel_Type_Desc = @Channel_Type_Desc, Outlet_Type_Desc = @Outlet_Type_Desc,
	SubOutlet_Type_Desc = @SubOutlet_Type_Desc, Channel_Type_Active = @Channel_Type_Active, Outlet_Type_Active = @Outlet_Type_Active,
	SubOutlet_Type_Active = @SubOutlet_Type_Active, ModifiedDate = getdate() 
	Where ID = @MappingID

	If (isNull(@Channel_Type_Active,0) = 0  Or   Isnull(@Outlet_Type_Active,0) = 0 Or Isnull(@SubOutlet_Type_Active,0) = 0)
	Begin
		Update tbl_mERP_OLClassMapping Set Active = 0 where OLClassID = @MappingID
	End
	
	-- Channel_Type_Code =@Channel_Type_Code and
	-- Outlet_Type_Code = @Outlet_Type_Code and SubOutlet_Type_Code = @SubOutlet_Type_Code
End

-- Normal Status updation

	Update tbl_mERP_RecdOLClassAbstract Set Status = 1
	Update tbl_mERP_RecdOLClassDetail Set Status = 1  Where ID = @SlNo  and RecdID = @ID

Declare @KeyValue nVarchar(255)


Last:
	-- Error Log Written and Status Updation of rejected Detail 
	If (@ErrStatus = 1)
	Begin
		Set @KeyValue = ''
		Set @Errmessage = 'OLClass:- ' +  ' ' + Convert(nVarchar(4000), @Errmessage)
		Set @KeyValue = Convert(nVarchar, @ID) + '|' + Convert(nVarchar,@SlNo)
		Update tbl_mERP_RecdOLClassAbstract Set Status = 2
		Update tbl_mERP_RecdOLClassDetail Set Status = 2  Where ID = @SlNo  and RecdID = @ID
		Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)    
		Values('MastersConfig', @Errmessage,  @KeyValue, getdate())  
	End

Fetch Next From ChannelCursor  Into @Channel_Type_Code,  @Channel_Type_Desc,  @Channel_Type_Active , @Outlet_Type_Code,
@Outlet_Type_Desc,  @Outlet_Type_Active , @SubOutlet_Type_Code, @SubOutlet_Type_Desc,  @SubOutlet_Type_Active, @SlNo 
End

Close ChannelCursor
DeAllocate ChannelCursor	

