Create Procedure mERP_Sp_ProcessAEDetail (@ID int)
As

Declare @UserID nVarchar(15)
Declare @UserName nVarchar(255)
Declare @Password nVarchar(15)
Declare @Saleslevel nVarchar(255)
Declare @Category nVarchar(255)
Declare @Active int
Declare @Slno int 

Declare @ErrStatus int
Declare @KeyValue nVarchar(255)
Declare @Errmessage nVarchar(4000)
Set @ErrStatus = 0

Declare AECursor Cursor for 
Select  UserID, UserName, Password, Saleslevel, Category, Active, ID
from tbl_mERP_RecdAELoginDetail
where RecdID = @ID and IsNull(status,0) = 0

Open AECursor
Fetch From AECursor  Into @UserID, @UserName, @Password, @Saleslevel, @Category, @Active, @Slno

While @@Fetch_Status = 0  
Begin 

Set @ErrStatus = 0

If (Isnull(@UserID,'') = '') 
Begin
	Set @Errmessage = 'UserID should not be Null'
	Set @ErrStatus = 1
	Goto last
End

If (Isnull(@UserName,'') = '') 
Begin
	Set @Errmessage = 'Username should not be Null'
	Set @ErrStatus = 1
	Goto last
End

If (Isnull(@password,'') = '') 
Begin
	Set @Errmessage = 'Password should not be Null'
	Set @ErrStatus = 1
	Goto last
End



If (Select Count(*) from tbl_mERP_AELoginInfo where UserID = @UserID) >=1
Begin
	update tbl_mERP_AELoginInfo Set SalesLevel = @Saleslevel, UserID = @userID, UserName = @Username, Password = @Password, Category = @Category, Active = @Active 
	where UserID = @UserID
End
Else
Begin
	Insert Into tbl_mERP_AELoginInfo(UserID, username, Password, Saleslevel, Category, Active) 
	Values(@UserID, @username, @Password, @Saleslevel, @Category, @Active)
End

	-- Status Updation
	Update tbl_mERP_RecdAELoginAbstract Set Status = 1 Where RecdID = @ID
	Update tbl_mERP_RecdAELoginDetail Set Status = 1  Where ID = @SlNo  and RecdID = @ID


Last:
	-- Error Log Written and Status Updation of rejected Detail 
	If (@ErrStatus = 1)
	Begin
		Set @KeyValue = ''
		Set @Errmessage = 'AELoginInfo:- ' +  ' ' + Convert(nVarchar(4000), @Errmessage)
		Set @KeyValue = Convert(nVarchar, @ID) + '|' + Convert(nVarchar,@SlNo)
		Update tbl_mERP_RecdAELoginDetail Set Status = 2  Where ID = @SlNo  and RecdID = @ID
		Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)    
		Values('MastersConfig', @Errmessage,  @KeyValue, getdate())  
	End

Fetch Next From AECursor  Into @UserID, @UserName, @Password, @Saleslevel, @Category, @Active, @Slno
End

Close AECursor
DeAllocate AECursor	

