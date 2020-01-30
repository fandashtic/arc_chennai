Create Procedure mERP_Sp_ProcessDSTDetail (@AbsID int)
AS
Declare @DST_Code nVarchar(15)
Declare @DST_Name nVarchar(50)
Declare @DST_Active int
Declare @DST_ID int

Declare @CreationDate  datetime
Declare @ModifiedDate datetime

Declare @RecdID int
Declare @ID int
Declare @KeyValue nVarchar(255)


Declare @Errmessage nVarchar(4000)
Declare @ErrStatus int

Set @ErrStatus = 0

Declare DSTCursor Cursor for 
Select  DSTraining_Code, DSTraining_Name, DSTraining_Active, DST_ID, ID
from tbl_mERP_RecdDSTrainingDetails
where RecdID = @AbsID and IsNull(Status,0) = 0 
Order By ID

Open DSTCursor 
Fetch From DSTCursor Into @DST_Code,  @DST_Name,  @DST_Active, @DST_ID, @ID
While @@Fetch_Status = 0  
Begin 

Set @ErrStatus = 0

If ((Isnull(@DST_Code,'') = '') Or (Isnull(@DST_Name,'') = ''))
Begin
	Set @Errmessage = 'Training Code/Name/Active should not be Null'
	Set @ErrStatus = 1
	Goto last
End


If ((Len(@DST_Code) > 15)) 
Begin
	Set @Errmessage = 'Code should be lesser than 15  chanracters'
	Set @ErrStatus = 1
	Goto last
End 

If ((Len(@DST_Name) > 50))
Begin
	Set @Errmessage = 'Name should be lesser than 50  chanracters'
	Set @ErrStatus = 1
	Goto last
End 

If (Select Count(*) from tbl_mERP_DSTraining where DSTraining_Code = @DST_Code and DSTraining_ID <> IsNull(@DST_ID,0)) >=1
Begin
	Set @Errmessage = 'Training Code Already Exist - ' +  ' ' + Convert(Varchar(15), @DST_Code)
	Set @ErrStatus = 1
	Goto last
End

If (Select Count(*) from tbl_mERP_DSTraining where DSTraining_Name = @DST_Name and DSTraining_ID <> IsNull(@DST_ID,0)) >=1
Begin
	Set @Errmessage = 'Training Name Already Exist - ' +  ' ' + Convert(Varchar(50), @DST_Name)
	Set @ErrStatus = 1
	Goto last
End

If ((isNull(@DST_Active, 0) > 1) Or (IsNull(@DST_Active, 0) < 0))
Begin
	Set @Errmessage = 'Active Column Value should be 0 or 1'
	Set @ErrStatus = 1
	Goto last
End

If ( Select Count(*) from tbl_mERP_DSTraining Where DSTraining_ID = IsNull(@DST_ID,0)) = 0
Begin
	Insert Into tbl_mERP_DSTraining(DSTraining_ID, DSTraining_Code, DSTraining_Name, DSTraining_Active, ModifiedDate)
	Values (@DST_ID, @DST_Code, @DST_Name, @DST_Active, null)
End
Else
Begin
	Update	tbl_mERP_DSTraining Set DSTraining_Code = IsNull(@DST_Code,''),
			DSTraining_Name = IsNull(@DST_Name,''), DSTraining_Active = IsNull(@DST_Active,0), ModifiedDate = Getdate() 
			Where DSTraining_ID= IsNull(@DST_ID,0)
End

-- Normal Status updation
	Update tbl_mERP_RecdDSTrainingAbstract Set Status = 1
	Update tbl_mERP_RecdDSTrainingDetails Set Status = 1  Where ID = @ID

Last:
	-- Error Log Written and Status Updation of rejected Detail 
	If (@ErrStatus = 1)
	Begin
		Set @KeyValue = ''
		Set @Errmessage = 'DSTraining:- ' +  ' ' + Convert(nVarchar(4000), @Errmessage)
		Set @KeyValue = Convert(nVarchar, @DST_ID) + '|' + Convert(nVarchar,@ID)
		Update tbl_mERP_RecdDSTrainingAbstract Set Status = 2
		Update tbl_mERP_RecdDSTrainingDetails Set Status = 2  Where ID = @ID  and DST_ID = @DST_ID
		Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)    
		Values('MastersConfig', @Errmessage,  @KeyValue, getdate())  
	End

Fetch Next From DSTCursor Into @DST_Code,  @DST_Name,  @DST_Active, @DST_ID, @ID
End
Close DSTCursor
DeAllocate DSTCursor	

