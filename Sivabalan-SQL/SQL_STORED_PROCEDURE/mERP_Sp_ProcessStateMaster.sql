Create Procedure mERP_Sp_ProcessStateMaster
AS
Declare @RecID int
Declare @StateID int
Declare @StateCode nVarchar(5)
Declare @StateName nVarchar(255)
Declare @KeyValue nVarchar(255)
Declare @Errmessage nVarchar(4000)
Declare @ErrStatus int

Set @ErrStatus = 0

Declare StateCodeCursorAbs Cursor for Select  RecID  from Recd_StateMasterAbs where  IsNull(Status,0) = 0
Open StateCodeCursorAbs
Fetch From StateCodeCursorAbs  Into @RecID

While @@Fetch_Status = 0  
Begin 
	Set @ErrStatus = 0
	If Exists ( Select 'x' From Recd_StateMasterDet Where RecID = @RecID  and (StateCode = '' Or StateName = ''))
	Begin
			Set @KeyValue = ''
			Set @Errmessage = 'StateMaster:- StateCode or StateName having Null Value.' 
			Set @KeyValue = Convert(nVarchar, @RecID)
			Update Recd_StateMasterAbs Set Status = 64 where RecID = @RecID
			Update Recd_StateMasterDet Set Status = 64 Where  RecID = @RecID
			Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)    
			Values('MastersConfig', @Errmessage,  @KeyValue, getdate())  
		Goto NextAbs
	End
	If Exists ( Select 'x' From Recd_StateMasterDet Where RecID = @RecID  and ( StateCode Like '%[",<''>]%' Or StateName Like '%[",<''>]%' ))
	Begin
			Set @KeyValue = ''
			Set @Errmessage = 'StateMaster:- StateCode or StateName having Invalid Characters.' 
			Set @KeyValue = Convert(nVarchar, @RecID)
			Update Recd_StateMasterAbs Set Status = 64 where RecID = @RecID
			Update Recd_StateMasterDet Set Status = 64 Where  RecID = @RecID
			Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)    
			Values('MastersConfig', @Errmessage,  @KeyValue, getdate())  
		Goto NextAbs
	End
 

	Declare StateCodeCursor Cursor for 
	Select  StateID,StateCode,StateName  from Recd_StateMasterDet where  IsNull(Status,0) = 0 And RecID = @RecID

	Open StateCodeCursor 
	Fetch From StateCodeCursor  Into @StateID,  @StateCode,  @StateName

	While @@Fetch_Status = 0  
	Begin 

	If ( Select Count(*) from StateCode Where  StateID = @StateID) = 0 
	Begin
		Insert Into StateCode(StateID, ForumStateCode, StateName)
		Values (@StateID, @StateCode, @StateName)	
		Update Recd_StateMasterDet Set Status = 1  Where  RecID = @RecID  And StateID = @StateID
	End
	Else
	Begin
		Update StateCode Set ForumStateCode = @StateCode, StateName = @StateName Where StateID = @StateID	
		Update Recd_StateMasterDet Set Status = 2  Where  RecID = @RecID  And StateID = @StateID
	End

	Fetch Next From StateCodeCursor  Into @StateID,  @StateCode,  @StateName
	End

	Close StateCodeCursor
	DeAllocate StateCodeCursor	

	Update Recd_StateMasterAbs Set Status = 1 where RecID = @RecID 

	NextAbs:
Fetch Next From StateCodeCursorAbs  Into @RecID
End
Close StateCodeCursorAbs
DeAllocate StateCodeCursorAbs

